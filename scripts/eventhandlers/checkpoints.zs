/*
 * Copyright (c) 2022 Talon1024
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
**/

class PlayerCheckpointManager : StaticEventHandler {
	Vector3 averageStart;
	double averageAngle;
	Actor activeCheckpoint;

	override void WorldLoaded(WorldEvent e) {
		// Get all player starts, average them and their angle
		Vector3 pos;
		int angle;
		bool firstAngle = false;
		int players = 0;
		for (int pn = 0; pn < MAXPLAYERS; pn++) {
			[pos, angle] = level.PickPlayerStart(pn);
			if (angle == 0 && pos == (0,0,0)) {
				continue; // Player start does not exist
			}
			averageStart += pos;
			if (!firstAngle) {
				averageAngle = angle;
				firstAngle = true;
			}
			players++;
		}
		averageStart = averageStart / players;
	}

	override void WorldUnloaded(WorldEvent e) {
		activeCheckpoint = null;
	}

	override void PlayerRespawned(PlayerEvent e) {
		// Teleport player to their new start
		if (!activeCheckpoint) return;
		Vector3 newPos; double newAngle;
		[newPos, newAngle] = GetNewPosition(e.PlayerNumber, activeCheckpoint);
		players[e.PlayerNumber].mo.Teleport(newPos, newAngle, 0);
	}

	play Vector3, double GetNewPosition(int playerNumber, Actor checkpoint = null) {
		// Calculate position difference
		Vector3 pos; double angle;
		[pos, angle] = level.PickPlayerStart(playerNumber);
		if (!checkpoint) return pos, angle;
		Vector3 posDiff = pos - averageStart;
		double angleDiff = angle - averageAngle;
		// Apply differences relative to active checkpoint
		/*
		Vector2 posXYDiffRotated = Actor.RotateVector(posDiff.xy, angleDiff);
		posDiff.xy = posXYDiffRotated;
		*/
		posDiff.xy = Actor.RotateVector(posDiff.xy, angleDiff);
		double posDist = posDiff.xy.Length();
		posDiff = posDiff.Unit();
		Vector3 newPos = checkpoint.Pos + posDiff * posDist;
		double newAngle = Actor.Normalize180(checkpoint.Angle + angleDiff);
		// Ensure newPos is "good": Not below the ground or above the ceiling,
		// not too far above the floor, and not too far above or below the
		// checkpoint spot.
		bool newPosGood = false;
		double minBadZDistance = 64.0;
		while (!newPosGood && posDist > 0) {
			// Fix newPos.Z, since the destination will be in another sector
			Sector destSector = level.PointInSector(newPos.xy);
			double floorz = destSector.floorplane.ZAtPoint(newPos.xy);
			double ceilz = destSector.ceilingplane.ZAtPoint(newPos.xy);
			// Confine to floorz if newPos is above the ceiling or below the
			// floor.
			if (newPos.z < floorz || newPos.z > ceilz) {
				newPos.z = floorz;
			} else
			// Check vertical distance to floor
			if ((newPos.z - floorz) > minBadZDistance) {
				posDist -= 16.0;
				newPos = checkpoint.Pos + posDiff * posDist;
				continue;
			}
			// Check vertical distance to checkpoint
			if (abs(newPos.z - checkpoint.Pos.z) > minBadZDistance) {
				posDist -= 16.0;
				newPos = checkpoint.Pos + posDiff * posDist;
				continue;
			}
			// Check position using a dummy player mobj
			Actor pmo = Actor.Spawn(PlayerClasses[0].Type, newPos, NO_REPLACE);
			if (!pmo.TestMobjLocation()) {
				posDist -= 16.0;
				newPos = checkpoint.Pos + posDiff * posDist;
				pmo.Destroy();
				continue;
			}
			pmo.Destroy();
			newPosGood = true;
		}
		return newPos, newAngle;
	}
}

class BoACoopCheckpoint : MapSpot {
	Default {
		//$Icon CHKPT0
		//$Category Multiplayer (BoA)
		//$Title Co-op Checkpoint
		//$Color 2
		+FLATSPRITE
	}

	States {
	Spawn:
		CHKP T -1;
		Stop;
	}

	override void Activate(Actor activator) {
		// Set active level checkpoint to self
		if (!multiplayer || deathmatch) { return; }
		PlayerCheckpointManager pcm = PlayerCheckpointManager(StaticEventHandler.Find("PlayerCheckpointManager"));
		pcm.activeCheckpoint = self;
		// See https://github.com/Realm667/WolfenDoom/commit/5fe30fa8e5a5268420402fd2313991a76cd0fdce#commitcomment-63170874
		ObjectiveMessage.Init(null, "CHK_REACHED", "OBJCKPNT");
	}

	override void Deactivate(Actor activator) {
		if (!multiplayer || deathmatch) { return; }
		// Unset active level checkpoint
		PlayerCheckpointManager pcm = PlayerCheckpointManager(StaticEventHandler.Find("PlayerCheckpointManager"));
		pcm.activeCheckpoint = null;
	}

	// Purely for debugging - can be commented out
	/*
	Array<Actor> newCoopStarts;
	override void PostBeginPlay() {
		PlayerCheckpointManager pcm = PlayerCheckpointManager(StaticEventHandler.Find("PlayerCheckpointManager"));
		for (int pn = 0; pn < MAXPLAYERS; pn++) {
			Vector3 pos; double pangle;
			[pos, pangle] = pcm.GetNewPosition(pn, self);
			Actor silhouette = Actor.Spawn("BoACoopCheckpointDebug", pos, NO_REPLACE);
			silhouette.angle = pangle;
			newCoopStarts.Push(silhouette);
		}
	}

	override void Tick() {
		// If only there were CVar change events...
		if (boa_debugcoopcheckpoints) {
			bInvisible = false;
			for (int pn = 0; pn < newCoopStarts.Size(); pn++) {
				newCoopStarts[pn].bInvisible = false;
			}
		} else {
			bInvisible = true;
			for (int pn = 0; pn < newCoopStarts.Size(); pn++) {
				newCoopStarts[pn].bInvisible = true;
			}
		}
	}
	*/
}

// Purely for debugging - can be commented out
/*
class BoACoopCheckpointDebug : Actor {
	DirectionIndicator di;

	Default {
		RenderStyle "Stencil";
		StencilColor "961f1f";
		+NOINTERACTION
		+INVISIBLE
	}

	States {
	Spawn:
		PLAY A -1;
		Stop;
	}

	override void PostBeginPlay() {
		di = DirectionIndicator(DirectionIndicator.AddFor(self));
		di.bInvisible = self.bInvisible;
		Scale = GetDefaultByType("BoAPlayer").Scale;
	}

	override void Tick() {
		di.bInvisible = self.bInvisible;
	}
}
*/