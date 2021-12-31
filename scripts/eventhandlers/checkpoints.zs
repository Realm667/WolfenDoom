/*
 * Copyright (c) 2020 Talon1024
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
		int players = 0;
		for (int pn = 0; pn < MAXPLAYERS; pn++) {
			[pos, angle] = level.PickPlayerStart(pn);
			if (angle == 0 && pos == (0,0,0)) {
				continue; // Player start does not exist
			}
			averageStart += pos;
			averageAngle += angle;
			players++;
		}
		averageStart = averageStart / players;
		averageAngle = averageAngle / players;
	}

	override void WorldUnloaded(WorldEvent e) {
		activeCheckpoint = null;
	}

	override void PlayerEntered(PlayerEvent e) {
		// Teleport player to their new start
		if (!activeCheckpoint) return;
		// Calculate position difference
		Vector3 pos; double angle;
		[pos, angle] = level.PickPlayerStart(e.PlayerNumber);
		Vector3 posDiff = pos - averageStart;
		double angleDiff = angle - averageAngle;
	}
}

class BoACoopCheckpoint : MapSpot {
	override void Activate(Actor activator) {
		PlayerCheckpointManager pcm = PlayerCheckpointManager(StaticEventHandler.Find("PlayerCheckpointManager"));
		pcm.activeCheckpoint = self;
	}
	override void Deactivate(Actor activator) {
		PlayerCheckpointManager pcm = PlayerCheckpointManager(StaticEventHandler.Find("PlayerCheckpointManager"));
		pcm.activeCheckpoint = null;
	}
}
