/*
 * Copyright (c) 2018-2020 AFADoomer
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

/*

 Base actor for the gatekeeper.  These actors started life as Star Trek-style sliding doors.

  On map load, these actors make whatever line they are placed on impassible.  When a player 
  approaches, the line is made passible and the actor's state is changed.  Once the player
  moves away, the line returns to being impassible, and the actor returns to the Spawn state.

  The actor can optionally be configured to check for a specific class and amount of an 
  inventory item that the player must be carrying in order to pass.

  Gatekeepers can be linked together (both will deactivate if one is passed) by assigning
  them the same TID.

 The GhostGate actor below uses this base actor to create an impassible swirling portal that
 spews unfriendly ghosts that cause damage to player in range who do not carry the necessary
 amount of the 'Soul' inventory item.  The amount of 'Soul' needed can be specified in the
 first argument of the map object (default is 25).

 The GhostGateHelper actor is the same as the GhostGate actor, but has no swirl, light, spirits,
 or numeric display effects.  It's intended for use when you want to block multiple linedefs
 with a single Ghostgate - just give the helpers the same TID as the main GhostGate actor.

*/
class GateKeeper : Actor
{
	Array<Actor> Activators;
	Class<Inventory> key;
	Line linedef;
	double lineangle;
	int timeout, maxtimeout, activationradius, user_keyamount, linelength;

	Property ActivationRadius:ActivationRadius;
	Property Key:key;
	Property KeyAmount:user_keyamount;
	Property Timeout:maxtimeout;

	Default
	{
		Height 92;
		Radius 8;
		-SOLID
		+INVISIBLE
		+SPECIAL
		GateKeeper.ActivationRadius 92;
		GateKeeper.Timeout 5;
		ActiveSound "";
	}

	States
	{
		Spawn:
			UNKN A -1;
			Stop;
		Disperse:
			UNKN A -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		// Find the line that this actor's centerpoint is closest to
		double dist;

		BlockLinesIterator it = BlockLinesIterator.Create(self);

		While (it.Next())
		{
			Line current = it.curline;

			// Discard lines that definitely don't cross the actor's center point
			if (
				(current.v1.p.x > pos.x + radius && current.v2.p.x > pos.x + radius) ||
				(current.v1.p.x < pos.x - radius && current.v2.p.x < pos.x - radius) ||
				(current.v1.p.y > pos.y + radius && current.v2.p.y > pos.y + radius) ||
				(current.v1.p.y < pos.y - radius && current.v2.p.y < pos.y - radius) 
			) { continue; }

			// Find the line that is closest based on proximity to end vertices
			double curdist = (current.v1.p - pos.xy + current.v2.p - pos.xy).Length();
			if (!linedef || curdist <= dist)
			{
				linedef = current;
				dist = curdist;
			}
		}

		if (!linedef)
		{
			Destroy(); 
			return;
		}

		linedef.flags |= Line.ML_BLOCKEVERYTHING;
		linelength = int(linedef.delta.Length());

		if (!linedef.delta.x) { lineangle = 0; }
		else if (!linedef.delta.y) { lineangle = 90; }
		else { lineangle = (atan(linedef.delta.y / linedef.delta.x) + 270) % 360; }

		angle = lineangle;

		activationradius = max(activationradius, linelength);

		A_SetSize(activationradius);

		if (user_keyamount && skill < 2) // If skill 0-2
		{
			double multiplier = 2. / 3; // Cut the amount down to 2/3 its value for each skill level
			double newamt = user_keyamount;

			// Reduce the amount by 1/3 for each skill level below normal
			for (int i = 0; i < 2 - skill; i++) { newamt *= multiplier; }

			// Set the new amount - cap minimum at 1 so that the gates still have some purpose
			user_keyamount = max(int(newamt), 1);
		}

		Activators.Clear();
	}

	override void Touch(Actor toucher)
	{
		if (Activators.Find(toucher) == Activators.Size()) { Activators.Push(toucher); }
	}

	override void Tick()
	{
		if (globalfreeze || level.Frozen) { return; }

		Super.Tick();

		target = null;

		for (int i = 0; i < Activators.Size(); i++)
		{
			if (Activators[i])
			{
				if (
					Distance2D(Activators[i]) <= Activators[i].Radius * 2 ||
					Distance2D(Activators[i]) <= Radius
				)
				{
					if (
						!key || 
						(
							Activators[i].FindInventory(key) &&
							Activators[i].FindInventory(key).Amount >= user_keyamount
						) ||
						timeout < 0
					)
					{
						if (maxtimeout < 0 && timeout > maxtimeout)
						{
							if (Distance2D(Activators[i]) < min(linelength / 2, 96))
							{
								Activators[i].TakeInventory(key, user_keyamount);
								user_keyamount = 0;
								timeout = maxtimeout;
							}
						}
						else
						{
							timeout = maxtimeout;
						}
						if (!target || Distance2D(Activators[i]) < Distance2D(target)) { target = Activators[i]; }
					}
					else
					{
						if (Distance2D(Activators[i]) <= min(linelength * 3 / 5, 192))
						{
							Activators[i].Thrust(0.5, AngleTo(Activators[i]));
						}
					}
				}
				else { Activators.Delete(i); }
			}
		}

		if (timeout == 0)
		{
			if (!InStateSequence(CurState, SpawnState)) { SetStateLabel("Spawn"); }
			if (linedef) { linedef.flags |= Line.ML_BLOCKEVERYTHING; }
		}
		else
		{
			if (!InStateSequence(CurState, FindState("Disperse"))) { SetStateLabel("Disperse"); }
			if (linedef) { linedef.flags &= ~Line.ML_BLOCKEVERYTHING; }

			if (tid)
			{ // If there's a TID, affect all Gatekeepers with that TID
				let it = ActorIterator.Create(tid, "Gatekeeper");
				Actor mo;

				while (mo = Actor(it.Next()))
				{
					Gatekeeper(mo).timeout = timeout;
					GateKeeper(mo).user_keyamount = user_keyamount;

					if (GhostGate(mo))
					{
						if (GhostGate(mo).swirl) { GhostGate(mo).swirl.Destroy(); }
						if (GhostGate(mo).light) { GhostGate(mo).light.Destroy(); }
					}
				}
			}
		}

		if (timeout > 0) { timeout--; }
	}
}

Class CreepyEffect : Actor
{
	Vector3 offset;
	int dir, angledelta;

	Default
	{
		Height 16;
		Radius 8;
		+NOCLIP
		+NOGRAVITY
		RenderStyle 'Add';
		Alpha 0.45;
	}

	States
	{
		Spawn:
			SPI1 BAABBAABB 2 Bright { A_FadeIn(0.05); }
		SpawnLoop:
			SPI1 AABB 2 Bright { A_FadeOut(0.01); }
			Loop;
	}

	override void BeginPlay()
	{
		alpha = 0;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (master)
		{
			offset = pos - master.pos;
			if (master is "GateKeeper") { angledelta = max(64 * 8 / GateKeeper(master).linelength, 1); }
			else { angledelta = 8; }
		}

		dir = offset.y > 0 ? 1 : -1;
	}

	override void Tick()
	{
		Super.Tick();

		if (globalfreeze || level.Frozen) { return; }
	
		if (master)
		{
			Warp(master, 0, offset.y, offset.z, angle + angledelta * dir, WARPF_ABSOLUTEANGLE | WARPF_NOCHECKPOSITION | WARPF_INTERPOLATE);
		}

		if (alpha > 0.25) { A_Explode(1, 1); }
	}
}

class GateLight : DynamicLight
{
	Color clr;
	int lightradius;
	int targetradius;

	override void BeginPlay ()
	{
		clr.r = 50;
		clr.g = 180;
		clr.b = 128;

		lightradius = 64;
		targetradius = 64;

		args[LIGHT_RED] = clr.r;
		args[LIGHT_GREEN] = clr.g;
		args[LIGHT_BLUE] = clr.b;
		args[LIGHT_INTENSITY] = lightradius;

		Super.BeginPlay();
	}

	override void Tick()
	{
		if (globalfreeze || level.Frozen || CheckSightOrRange(512)) { return; }

		scale.x = max(scale.x, 1.0);

		args[LIGHT_RED] = int(clr.r / scale.x);
		args[LIGHT_GREEN] = int(clr.g / scale.x);
		args[LIGHT_BLUE] = int(clr.b / scale.x);

		if (lightradius > 64) { lightradius = 64; }
		if (targetradius > 64) { targetradius = 64; }

		if (level.time)
		{
			if (args[LIGHT_INTENSITY] == targetradius)
			{
				targetradius = int((lightradius + Random(-2, 2)) * scale.x);
			}
			else
			{
				int step = max(abs(args[LIGHT_INTENSITY] - targetradius) / 4, 1);

				if (args[LIGHT_INTENSITY] > targetradius) { args[LIGHT_INTENSITY] = max(targetradius, args[LIGHT_INTENSITY] - step); }
				if (args[LIGHT_INTENSITY] < targetradius) { args[LIGHT_INTENSITY] = min(targetradius, args[LIGHT_INTENSITY] + step); }
			}
		}
		else { args[LIGHT_INTENSITY] = 0; }

		Super.Tick();
	}
}

class GhostGate : GateKeeper
{
	Actor swirl, light;
	Array<Actor> numbers;
	Array<Actor> spawns;
	Array<GhostGate> peers;
	bool inactivation;
	color textcolor, targetcolor;
	double pulseratio;
	double startalpha;
	int activationtime;
	int textspeed;
	sound loopsound, opensound;

	Property LoopSound:loopsound;
	Property OpenSound:opensound;

	Default
	{
		//$Category Hazards (BoA)/ZScript
		//$Title Soul Gate
		//$Sprite SWRLZ0
		//$Arg0 "Amount of 'Soul' item required"
		//$Arg0Default 25;
		//$Arg0Tooltip "How many of the 'Soul' inventory item must be carried by the player to pass this gate.\nCan also be set via the 'user_keyamount' UDMF property."
		//$Arg1 "Script number to run when passed"
		//$Arg1Tooltip "What script to call when the gate is passed.  Zero means no script. \nFirst argument passed to the script will be this actor's TID."

		GateKeeper.Key "Soul";
		GateKeeper.KeyAmount 25;
		GateKeeper.ActivationRadius 192;
		GateKeeper.Timeout -1;

		GhostGate.LoopSound "creepyrift/loop";
		GhostGate.OpenSound "creepy/born";
	}

	States
	{
		Spawn:
			UNKN A 2 {
				if (spawns.Size() < min(user_keyamount, 15) && swirl && !CheckSightOrRange(512))
				{
					tics = Random(1, 10);

					bool sp;
					Actor mo;
	
					[sp, mo] = A_SpawnItemEx("CreepyEffect", Random(-linelength / 2, linelength / 2), 0, Random(16, int(64 + 32 * scale.x)), 0, 0, random(1, 2), 0, SXF_NOCHECKPOSITION | SXF_SETMASTER);

					if (sp)
					{
						mo.alpha = 0;
						mo.Scale *= FRandom(0.4, 0.6);
						spawns.Push(mo);
					}
				}
			}
			Loop;
		Disperse:
			UNKN A 1;
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		numbers.Clear();
		spawns.Clear();
		peers.Clear();

		if (!linedef)
		{
			console.printf("\cgERROR: \clSoul Gate actor at %d, %d, %d was not placed on a linedef!", pos.x, pos.y, pos.z);
			return;
		}
		else if (!linedef.sidedef[0] || !linedef.sidedef[1])
		{
			console.printf("\cgERROR: \clSoul Gate actor at %d, %d, %d was placed on a one-sided line!  Unexpected behavior may result.", pos.x, pos.y, pos.z);
		}

		SpawnPoint = pos;

		if (user_keyamount == Default.user_keyamount && args[0]) { user_keyamount = args[0]; }

		FindPeers();

		SpawnDigits(user_keyamount, "FlatNumber");

		swirl = Spawn("Swirl_Wall", pos + (0, 0, 32 + 32 * scale.y));

		if (swirl)
		{
			swirl.angle = angle;
			swirl.scale = scale;
		}

		light = Spawn("GateLight", pos + (0, 0, 32 + 32 * scale.y));

		if (light)
		{
			GateLight(light).lightradius = int(scale.x * linelength / 2);
			GateLight(light).targetradius = int(scale.x * linelength / 2);
		}

		TextureID tex = TexMan.CheckForTexture("WATR_G98", TexMan.Type_Any);
		bool outside = TexMan.GetName(ceilingpic) == "F_SKY1";

		if (tex && !outside)
		{
			if (linedef.sidedef[0])
			{
				linedef.sidedef[0].SetTexture(Side.mid, tex);
				linedef.sidedef[0].SetTextureXScale(Side.mid, 3);
				linedef.sidedef[0].SetTextureYScale(Side.mid, 3);
			}

			if (linedef.sidedef[1])
			{
				linedef.sidedef[1].SetTexture(Side.mid, tex);
				linedef.sidedef[1].SetTextureXScale(Side.mid, 3);
				linedef.sidedef[1].SetTextureYScale(Side.mid, 3);
			}

			linedef.alpha = 0.05;

			linedef.flags |= Line.ML_WRAP_MIDTEX ;
		}

		startalpha = linedef.alpha;

		targetcolor = "189454"; // Creepy green;
		textspeed = 8;

		A_StartSound(loopsound, CHAN_6, CHANF_LOOPING, 0.45 * scale.x, ATTN_NORM);
	}

	void FindPeers()
	{
		if (tid)
		{
			let it = ActorIterator.Create(tid, GetClassName());
			Actor mo;

			while (mo = Actor(it.Next()))
			{
				if (mo == self) { continue; }

				if (mo.GetClassName() == GetClassName()) { peers.Push(GhostGate(mo)); }
			}
		}
	}

	Actor ClosestPlayer(double dist = 0)
	{
		Actor ClosestPlayer = null;

		for (int p = 0; p < MAXPLAYERS; p++) { // Iterate through all of the players and find the closest one
			Actor mo = players[p].mo;

			if (mo) {
				if (dist > 0 && Distance2d(mo) > dist) { continue; }
				if (!mo.bShootable || mo.health <= 0) { continue; }
				if (ClosestPlayer && Distance2d(mo) > Distance2d(ClosestPlayer)) { continue; }

				ClosestPlayer = mo;
			}
		}
		return ClosestPlayer;
	}

	void SpawnDigits(int number, Class<Actor> numactor)
	{
		int digits;
		int temp = number;

		double position;
		double width = 14 * 0.4;

		while (temp)
		{
			digits++;
			temp /= 10;
		}

		position = width * digits / 2 - width / 2;

		for (int i = 0; i < digits; i++)
		{
			int digit = number % 10;

			bool sp;
			Actor mo;
	
			[sp, mo] = A_SpawnItemEx(numactor, 2, -position, 30, flags: SXF_NOCHECKPOSITION);
			if (sp)
			{
				numbers.Push(mo);
				FlatNumber(mo).value = digit;
				mo.master = self;
				mo.scale *= scale.x;
			}

			[sp, mo] = A_SpawnItemEx(numactor, -2, -position, 30, angle:180, flags: SXF_NOCHECKPOSITION);
			if (sp)
			{
				numbers.Push(mo);
				FlatNumber(mo).value = digit;
				mo.master = self;
				mo.scale *= scale.x;
			}

			number /= 10;
			position -= width;
		}
	}

	SpriteID LookupSprite(Name spritecheck)
	{
		SpriteID temp = GetSpriteIndex(spritecheck);
		if (temp > -1) { return temp; }

		console.printf("\cgERROR: \cjThe sprite name index for '\cf%s\cj' could not be found.  Did you forget to add it to one of the actor's states?", spritecheck);
		return sprite;
	}

	override void Tick()
	{
		if (globalfreeze || level.Frozen) { return; }

		Super.Tick();

		double pratio = 1.0;

		if (target)
		{
			alpha = clamp(sin((Distance2D(target) - 64) * 90 / (activationradius - 64)), 0.001, 1.0);
			activationtime = level.time;
			inactivation = true;
		}
		else if (inactivation)
		{
			alpha = 1.0;
			inactivation = false;
		}

		Actor p = ClosestPlayer(activationradius);
		if (p) { pratio = Distance2D(p) / activationradius; }

		linedef.alpha = alpha * startalpha;

		if (swirl)
		{
			if (target)
			{
				swirl.scale = swirl.default.scale * scale.x / pratio;
			}
			else
			{
				swirl.scale = swirl.default.scale * scale.x;
			}
			swirl.alpha = 0.85 * alpha;
		}

		if (alpha <= 0.05 && !user_keyamount)
		{
			A_StartSound(opensound, CHAN_6, 0, 0.25 * scale.x, ATTN_NORM);

			if (args[1] > 0)
			{
				Level.ExecuteSpecial(80, p, null, false, args[1], 0, tid, args[2], args[3]);
			}
				
			if (swirl) { swirl.Destroy(); }
		}

		if (light)
		{
			if (target) { light.scale = light.default.scale / pratio ** 2; }
			else { light.scale = light.default.scale; }

			if (pratio <= 0.05 && !user_keyamount)
			{
				light.Destroy();
			}
		}

		for (int i = 0; i < spawns.Size(); i++)
		{
			if (spawns[i] && alpha < 1)
			{
				spawns[i].alpha = min(spawns[i].alpha, alpha * spawns[i].default.alpha);
			}

			if (!spawns[i])
			{
				spawns.Delete(i);
			}
		}

		if (textcolor != targetcolor)
		{
			if (textcolor.r < targetcolor.r) { textcolor.r = int(min(targetcolor.r, textcolor.r + textspeed)); }
			else if (textcolor.r > targetcolor.r) { textcolor.r = int(max(targetcolor.r, textcolor.r - textspeed)); }

			if (textcolor.g < targetcolor.g) { textcolor.g = int(min(targetcolor.g, textcolor.g + textspeed)); }
			else if (textcolor.g > targetcolor.g) { textcolor.g = int(max(targetcolor.g, textcolor.g - textspeed)); }

			if (textcolor.b < targetcolor.b) { textcolor.b = int(min(targetcolor.b, textcolor.b + textspeed)); }
			else if (textcolor.b > targetcolor.b) { textcolor.b = int(max(targetcolor.b, textcolor.b - textspeed)); }
		}

		for (int i = 0; i < numbers.Size(); i++)
		{
			if (numbers[i])
			{
				if (!user_keyamount) { numbers[i].Destroy(); }
				else if (!target)
				{
					double sratio = p ? sin(level.time * textspeed) : 0;

					if (!p) { targetcolor = "189454"; }

					if (sratio != pulseratio)
					{
						if (sratio > pulseratio)
						{
							targetcolor = "FF0000";
						}
						else
						{
							targetcolor = "189454";
						}
					}

					pulseratio = sratio;

					numbers[i].alpha = (numbers[i].alpha + (alpha * numbers[i].default.alpha + sratio * (1.0 - numbers[i].default.alpha))) / 2; // Smooth any abrupt transitions
					numbers[i].scale = (numbers[i].default.scale.x * scale.x + 0.05 * sratio, numbers[i].default.scale.y * scale.y + 0.05 * sratio); // Make the number pulse when a player is in range but doesn't have enough souls
				}
				else
				{
					numbers[i].alpha = alpha * numbers[i].default.alpha;
				}

				if (numbers[i]) { numbers[i].SetShade(textcolor); }
			}

			if (!numbers[i])
			{
				numbers.Delete(i);
			}
		}

		for (int i = 0; i < peers.Size(); i++)
		{
			if (peers[i])
			{
				if (peers[i].activationtime > activationtime) // Time when last approached by a player with enough souls to activate.
				{
					user_keyamount = peers[i].user_keyamount;
					alpha = peers[i].alpha;
				}
			}
			else
			{
				peers.Delete(i);
			}
		}

		if (!swirl && !light && !user_keyamount && !Spawns.Size() && !numbers.Size())
		{
			Destroy();
		}

		if (pos != SpawnPoint) { SetOrigin(SpawnPoint, true); }

	}
}

// Ghost gate with no swirl, light, spirits, or numbers.
class GhostGateHelper : GhostGate
{
	Default
	{
		//$Category Hazards (BoA)/ZScript
		//$Title Soul Gate (No effects)
		//$Sprite SWRLY0
	}

	States
	{
		Spawn:
			UNKN A 2;
			Loop;
		Disperse:
			UNKN A 1;
			Loop;
	}

	override void PostBeginPlay()
	{
		GateKeeper.PostBeginPlay();

		if (!linedef)
		{
			console.printf("\cgERROR: \clSoul Gate helper actor at %d, %d, %d was not placed on a linedef!", pos.x, pos.y, pos.z);
			return;
		}
		else if (!linedef.sidedef[0] || !linedef.sidedef[1])
		{
			console.printf("\cgERROR: \clSoul Gate helper actor at %d, %d, %d was placed on a one-sided line!  Unexpected behavior may result.", pos.x, pos.y, pos.z);
		}

		if (!master)
		{
			master = FindParent();

			let g = GhostGate(master);

			if (g)
			{
				// Add this line's length to the main gate actor's line length
				g.linelength += linelength;
				g.activationradius = max(g.activationradius, g.linelength);

				// And reset it's radius to match
				g.A_SetSize(g.activationradius);
			}
		}

		SpawnPoint = pos;

		if (master)
		{
			user_keyamount = GhostGate(master).user_keyamount;
			alpha = master.alpha;
			scale = master.scale;
		}
		else
		{
			if (user_keyamount == Default.user_keyamount && args[0]) { user_keyamount = args[0]; } // Still support setting locally, just in case we want to use it that way in the future...
		}

		TextureID tex = TexMan.CheckForTexture("WATR_G98", TexMan.Type_Any);
		bool outside = TexMan.GetName(ceilingpic) == "F_SKY1";

		if (tex && !outside)
		{
			if (linedef.sidedef[0])
			{
				linedef.sidedef[0].SetTexture(Side.mid, tex);
				linedef.sidedef[0].SetTextureXScale(Side.mid, 3);
				linedef.sidedef[0].SetTextureYScale(Side.mid, 3);
			}

			if (linedef.sidedef[1])
			{
				linedef.sidedef[1].SetTexture(Side.mid, tex);
				linedef.sidedef[1].SetTextureXScale(Side.mid, 3);
				linedef.sidedef[1].SetTextureYScale(Side.mid, 3);
			}

			linedef.alpha = 0.05;

			linedef.flags |= Line.ML_WRAP_MIDTEX ;
		}

		startalpha = linedef.alpha;

		A_StartSound(loopsound, CHAN_6, CHANF_LOOPING, 0.45 * scale.x, ATTN_NORM);
	}

	override void Tick()
	{
		if (master) { alpha = master.alpha; }

		Super.Tick();
	}

	Actor FindParent()
	{
		if (tid)
		{
			let it = ActorIterator.Create(tid, "Gatekeeper");
			Actor mo;

			while (mo = Actor(it.Next()))
			{
				if (mo.GetClass() == "GhostGate")
				{
					return mo;
				}
			}
		}
		return null;
	}
}

class FlatNumber : Actor
{
	int value;
	Vector3 offset;

	Default
	{
		Radius 0;
		Height 0;
		Scale 0.4;
		+MASKROTATION
		+NOGRAVITY
		+NOINTERACTION
		+WALLSPRITE
		Renderstyle 'AddShaded';
		Alpha 0.85;
		StencilColor "000000";
		VisibleAngles -90, 90;
		VisiblePitch -90, 90;
	}

	States
	{
		Spawn:
			FNUM A -1 Bright;
			Stop;
	}

	override void PostBeginPlay()
	{
		SpawnPoint = pos;
		offset = pos - master.pos;
		offset = (RotateVector(offset.xy, -master.angle), offset.z);

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (globalfreeze || level.Frozen) { return; }

		frame = value;

		if (level.time && master)
		{
			Vector2 newpos = RotateVector((offset.x * scale.x / default.scale.x, offset.y * scale.x / default.scale.x), master.angle);

			SetXYZ((master.pos.x + newpos.x, master.pos.y + newpos.y, master.pos.z + offset.z + 2 * sin(level.time) / 2));
		}

		Super.Tick();
	}
}

class DoorHandler : Actor
{
	bool walkablemidtex, active, closed;
	int moveamt, maxmoveamt, movetimeout, activationradius, locknumber, closedelay, offsetstart[2], maxoffset;
	double movespeed, olddir, lineangle, texscale;
	Line linedef;
	Array<Actor> Activators;
	Sound opensound, closesound;
	Array<Actor> doorthings;

	Property MoveSpeed:movespeed;
	Property ActivationRadius:ActivationRadius;
	Property MidTex:walkablemidtex;
	Property CloseDelay:closedelay;
	Property HandleWidth:maxoffset;

	Default
	{
		//$Category Doors (BoA)
		//$Title Sliding Door (Line-based)
		//$Sprite SLIDA0
		//$Arg0 "Key"
		//$Arg0ToolTip "What key should this door use (default none)?"
		//$Arg0Type 11
		//$Arg0Enum "keys"
		//$Arg1 "No height blocking"
		//$Arg1ToolTip "Disables height blocking for the door - normally only used if the door is a 3D midtex and the upper/lower areas need to be passable"
		//$Arg1Type 11
		//$Arg1Enum { 0 = "False"; 1 = "True"; }
		//$Arg2 "Door Speed"
		//$Arg2Default 6;
		//$Arg2ToolTip "How fast should the door open/close"
		//$Arg3 "Door Sound"
		//$Arg3ToolTip "Which sound set should the door use?"
		//$Arg3Type 11
		//$Arg3Enum { 0 = "Classic Wolf3D"; 1 = "Metal"; 2 = "Mechanical"; 3 = "Prison"; 4 = "Elevator"; 5 = "Astrostein"; }

		-SOLID
		+WALLSPRITE // Modified render style, etc. for GZDB appearance...
		RenderStyle "Translucent";
		Alpha 0.25;
		Height 92;
		Radius 24;
		Scale 0.5;
		DoorHandler.MoveSpeed 6;
		DoorHandler.ActivationRadius 72;
		DoorHandler.CloseDelay 150; // Includes the time that the door takes to open!
		DoorHandler.HandleWidth 2;
	}

	States
	{
		Spawn:
			UNKN A -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		double dist;

		if (ActivationRadius > Radius) { A_SetSize(ActivationRadius); }

		BlockLinesIterator it = BlockLinesIterator.Create(self, 1);

		walkablemidtex = args[1];
      
		While (it.Next())
		{
			Line current = it.curline;

			if (current)
			{ // Find the line that this actor's centerpoint is closest to
				// Discard lines that definitely don't cross the actor's center point
				if (
					(current.v1.p.x > pos.x + radius && current.v2.p.x > pos.x + radius) ||
					(current.v1.p.x < pos.x - radius && current.v2.p.x < pos.x - radius) ||
					(current.v1.p.y > pos.y + radius && current.v2.p.y > pos.y + radius) ||
					(current.v1.p.y < pos.y - radius && current.v2.p.y < pos.y - radius) 
				) { continue; }
	
				// Find the line that is closest based on proximity to end vertices
				double curdist = (current.v1.p - pos.xy + current.v2.p - pos.xy).Length();
				if (!linedef || curdist <= dist)
				{
					linedef = current;
					dist = curdist;
				}
			}
		}

		if (!linedef) { Destroy(); return; }

		if (!linedef.delta.x) { lineangle = 0; }
		else if (!linedef.delta.y) { lineangle = 90; }
		else { lineangle = (atan(linedef.delta.y / linedef.delta.x) + 270) % 360; }

//		if (angle != lineangle && angle != lineangle + 180 && angle != lineangle - 180) { angle = lineangle; }

		double linelength = linedef.delta.length();
		TextureID tex = linedef.sidedef[0].GetTexture(Side.mid);
		texscale = linedef.sidedef[0].GetTextureXScale(Side.mid);
		offsetstart[0] = int(linedef.sidedef[0].GetTextureXOffset(Side.mid));
		offsetstart[1] = int(linedef.sidedef[1].GetTextureXOffset(Side.mid));

		if (!linedef.special) { linedef.special = 121; } // Give it a useless special so that the NOWAY sound doesn't play (121 is Line_SetIdentification)

		if (walkablemidtex) // If you want the door to be passable in 3D space, it needs to be a 3D midtex - some blocking issues, unfortunately...  Doesn't stop hitscans.
		{
			linedef.flags |= Line.ML_3DMIDTEX;
			linedef.flags |= Line.ML_BLOCKSIGHT;
		}
		else // By default, the line will block everything
		{
			linedef.flags |= Line.ML_BLOCKING;
			linedef.flags |= Line.ML_BLOCKEVERYTHING;
			linedef.flags |= Line.ML_SOUNDBLOCK;
		}

		locknumber = args[0];
		active = false;
		closed = true;
		if (!tex) { texscale = 1.0; }
		maxmoveamt = int(linelength - maxoffset);

		movespeed = (args[2] ? args[2] : movespeed);

		if (tid && !master)
		{ // If there's a TID, find the actor with that TID to also move
			let it = ActorIterator.Create(tid, "Actor");
			Actor mo;			

			while (mo = Actor(it.Next()))
			{
				if (mo == self) { continue; }

				mo.master = self;
				mo.SpawnPoint = mo.pos;
				doorthings.Push(mo);
			}
		}

		SpawnPoint = pos;

		if (alpha == Default.alpha)
		{
			if (sprite == GetSpriteIndex("UNKN")) { bInvisible = true; }
			else { alpha = 1.0; }
		}
	}

	void Move(double dir, Actor activator = null)
	{
		if (dir < 0 && moveamt <= 0)
		{
			// Fully closed
			active = false;
			closed = true;
			return;
		}
		else if (dir > 0 && moveamt > maxmoveamt)
		{
			// Fully open
			active = false;
			return;
		}

		active = true;

		dir = dir * movespeed;

		if (!linedef) { return; }

		if (dir < 0 && moveamt < maxmoveamt / 2) // Door is opening
		{
			if (walkablemidtex)
			{
				linedef.flags |= Line.ML_3DMIDTEX;
				linedef.flags |= Line.ML_BLOCKSIGHT;
			}
			else
			{
				linedef.flags |= Line.ML_BLOCKING;
				linedef.flags |= Line.ML_BLOCKEVERYTHING;
				linedef.flags |= Line.ML_SOUNDBLOCK;
			}
		}
		else if (dir > 0 && moveamt > maxmoveamt / 2) // Door is closing
		{
			if (walkablemidtex)
			{
				linedef.flags &= ~Line.ML_3DMIDTEX;
				linedef.flags &= ~Line.ML_BLOCKSIGHT;
			}
			else
			{
				linedef.flags &= ~Line.ML_BLOCKING;
				linedef.flags &= ~Line.ML_BLOCKEVERYTHING;
				linedef.flags &= ~Line.ML_SOUNDBLOCK;
			}
		}

		if (dir != olddir)
		{
			switch (args[3])
			{
				//1 = "Metal", 2 = "Mechanical", 3 = "Prison", 4 = "Elevator", 5 = "Astrostein"
				case 1:
					OpenSound = "DR_MTL01";
					CloseSound = "DR_MTL02";
					break;
				case 2:
					OpenSound = "doors/dr1_open";
					CloseSound = "doors/dr1_stop";
					break;
				case 3:
					OpenSound = "DR_PRS01";
					CloseSound = "DR_PRS02";
					break;
				case 4:
					OpenSound = "ELDOR_OP";
					CloseSound = "ELDOR_CL";
					break;
				case 5:
					OpenSound = "astrostein/dooropen";
					CloseSound = "astrostein/doorclose";
					break;
				default:
					if (OpenSound == "") { OpenSound = "door/classic/open"; }
					if (CloseSound == "") { CloseSound = "door/classic/close"; }
					break;
			}

			if (dir > 0) { A_StartSound(OpenSound, CHAN_VOICE, 0, 0.7); }
			else {  A_StartSound(CloseSound, CHAN_VOICE, 0, 0.7); }
		}

		moveamt = int(clamp(moveamt + dir, 0, maxmoveamt));

		Actor controller = self;
		while (controller.master) { controller = controller.master; }

		// Move the door thing and any attached objects.
		SetOrigin(SpawnPoint + (RotateVector((moveamt, 0), angle + 90), 0), true);

		linedef.sidedef[0].SetTextureXOffset(Side.mid, int(clamp(offsetstart[0] - moveamt * texscale, -maxmoveamt * texscale, 0)));
		linedef.sidedef[1].SetTextureXOffset(Side.mid, int(clamp(offsetstart[1] + moveamt * texscale, 0, maxmoveamt * texscale)));

		for (int i = 0; i < doorthings.Size(); i++)
		{
			let door = doorthings[i];

			if (door is "DoorHandler") // If it's a DoorHandler, move it with its own internal code
			{
				continue;
			}
			else if (door) // If it's just a tagged object, move it over
			{
				door.SetOrigin(door.SpawnPoint + (RotateVector((moveamt, 0), angle + 90), 0), true);
			}
			else // Otherwise it's a bad entry that shouldn't be here...
			{
				doorthings.Delete(i);
			}
		}

		olddir = dir;
	}

	void GetActivators(double range = 64, double doorheight = 96)
	{
		BlockThingsIterator it = BlockThingsIterator.Create(self, 1);

		while (it.Next())
		{
			if (!it.thing.bIsMonster && !(it.thing is "PlayerPawn") && !(it.thing is "PlayerFollower")) { continue; } // Ignore everything except players and monsters
			if (
				(DistanceFromLine(it.thing, linedef) > range + it.thing.radius) || // Check if the actor can reach the door, with some fudging to account for square collision boxes
				(it.thing.pos.z + it.thing.height < pos.z) || // Z-height check (player below door)
				(it.thing.pos.z > pos.z + doorheight) // Z-height check (player above door)
			)
			{
				if (Activators.Find(it.thing) != Activators.Size()) // If the actor was already on the Activators list
				{
					Activators.Delete(Activators.Find(it.thing)); // ...and delete if from the Activators list.  
					Activators.ShrinkToFit(); // Re-shrink the array
				}
				continue;
			}

			if (Activators.Find(it.thing) == Activators.Size()) { Activators.Push(it.thing); } // Add the actor to the list of Activators if it's not already there
		}
	}

	// Ugh.  Math.  Adapted from https://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment
	double DistanceFromLine(Actor mo, Line l)
	{
		if (!l || !mo) { return 0; }

		Vector2 v1, v2, delta, point;

		v1 = l.v1.p;
		v2 = l.v2.p;
		delta = l.delta;
		point = mo.pos.xy;

		double lengthsquared = (v2 - v1).length() ** 2;

		if (!lengthsquared) { return (v1 - point).length(); }

		double t = clamp((point - v1) dot delta / lengthsquared, 0, 1);
		Vector2 projection = v1 + t * delta;

		return (point - projection).length();
	}

	override void Tick()
	{
		bool blocked = false;

		GetActivators(ActivationRadius);

		for (int i = 0; i < Activators.Size(); i++)
		{
			if (Activators[i])
			{
				let mo = Activators[i];
				let p = mo.player;

				if (mo.health <= 0 || !mo.bShootable) { Activators.Delete(i); continue; }

				double offsetangle = absangle(angle, mo.angle);
				if (offsetangle > 90) { offsetangle = 180 - offsetangle; }

				double dist = DistanceFromLine(mo, linedef);

				if (
					(
						dist <= mo.Radius ||  // Standing in the doorway
						(
							dist <= ActivationRadius && // Standing within the activation range and looking at the door
							(offsetangle < 50)
						)
					) &&
					(!locknumber || !p || mo.CheckKeys(locknumber, false)) // And it's unlocked, or it's not a player, or the player has the key
				)
				{
					if (closed) // If the door is closed
					{
						// If not a player, or of the player just pressed use
						if (!p || (dist <= PlayerPawn(p.mo).UseRange && (p.buttons & BT_USE && !(p.oldbuttons & BT_USE))))
						{
							// Open the door
							movetimeout = closedelay;
							blocked = true;
							closed = false;
						}
					}
					else if (dist > mo.radius) // If it's open and you're not standing in the doorway
					{
						// If you're a player who pressed use
						if (p && (dist <= PlayerPawn(p.mo).UseRange && (p.buttons & BT_USE && !(p.oldbuttons & BT_USE))))
						{
							// Close the door
							movetimeout = 0;
							blocked = true;
						}
					}
					else // Otherwise, if it's open and you're in the doorway
					{
						blocked = true; // Don't move the door...
					}
				}
				else { Activators.Delete(i); }
			}
		}

		if (movetimeout <= 0)
		{
			// Only close the door if there's no one in the doorway
			if (!blocked) { Move(-1); }
			else { Move(1); }
		}
		else { Move(1); }

		if (movetimeout > 0) { movetimeout--; }

		Super.Tick();
	}
}

class ClassicSlidingDoor : DoorHandler
{
	Default
	{
		//$Title Classic Wolf3D Sliding Door (Line-based)
		Radius 48;
		Scale 1.0;
	}

	States
	{
		Spawn:
			SLID A -1;
			Loop;
	}
}

class SlidingDoor : DoorHandler
{
	Default
	{
		//$Title Wooden Sliding Door (Line-based)
		//$Sprite SLIDB0
		DoorHandler.HandleWidth 6;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Loop;
	}

	override void PostBeginPlay()
	{
		OpenSound = "ELDOR_OP";
		CloseSound = "ELDOR_CL";

		Super.PostBeginPlay();
	}
}