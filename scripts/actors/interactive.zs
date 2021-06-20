/*
 * Copyright (c) 2020 AFADoomer, Talon1024, N00b
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

  Flatsprite floor/ceiling vent that is 0-height but walkable and solid.

  Most suitable for use as a breakable ceiling/floor vent, but can also have its
  pitch changed to match sloped surfaces, though the hitbox and blocking do not
  change, so the effect may not work quite as desired.

*/
class Debris_Vent_FloorCeiling : SwitchableDecoration
{
	Default
	{
		//$Category Special Effects (BoA)
		//$Title Vent Debris - Floor/Ceiling (activatable, solid/walkable)
		//$Color 12

		+SOLID
		+NOGRAVITY
		+ACTLIKEBRIDGE
		+FLATSPRITE
		+SHOOTABLE
		+DONTTHRUST
		+NOBLOOD
		+NOTAUTOAIMED
		Health 1;
		Height 0;
		Radius 32;
	}

	States
	{
		Spawn:
			VENT A 1;
		Active:
			VENT "#" 35;
			Wait;
		Inactive:
		Death:
			VENT B 0 {
				A_SpawnItemEx("PowerPlantSmokePuffSmall", 0, 0, 32, 0, 0, 0, 0, 0);

				if (level.time > 5) { S_StartSound("DSMETDST", CHAN_AUTO, 0, 0.5, ATTN_NORM); }

				for (int i = 0; i < 4; i++) {
					A_SpawnItemEx("Debris_Trash", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
					A_SpawnItemEx("Debris_Trash2", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
				}

				bNoInteraction = True;
			}
			"####" "#" 0; // Attempt to prevent sounds from being played when player loads their savegame - Talon1024
			VENT B -1;
			Stop;
	}

	override bool Used(Actor user)
	{
		SetStateLabel("Death");

		return Super.Used(user);
	}
}

class Debris_Wood_FloorCeiling : Debris_Vent_FloorCeiling
{
	Default
	{
		//$Title Wood Debris - Floor/Ceiling (activatable, solid/walkable)
	}

	States
	{
		Spawn:
			VENT C 1;
		Active:
			VENT "#" 35;
			Wait;
		Inactive:
		Death:
			VENT D 0 {
				A_SpawnItemEx("PowerPlantSmokePuffSmall", 0, 0, 32, 0, 0, 0, 0, 0);

				if (level.time > 5) { S_StartSound("WOODBRK", CHAN_AUTO, 0, 0.5, ATTN_NORM); }

				for (int i = 0; i < 4; i++) {
					A_SpawnItemEx("Debris_Wood", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
					A_SpawnItemEx("Debris_Wood", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
					A_SpawnItemEx("Debris_Wood", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
					A_SpawnItemEx("Debris_Wood", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
				}

				bNoInteraction = True;
			}
			"####" "#" 0; // Attempt to prevent sounds from being played when player loads their savegame - Talon1024
			VENT D -1;
			Stop;
	}
}

class Debris_Wood_FloorCeiling2 : Debris_Vent_FloorCeiling
{
	Default
	{
		//$Title Wood Debris, 2nd variant - Floor/Ceiling (activatable, solid/walkable)
	}

	States
	{
		Spawn:
			VENT E 1;
		Active:
			VENT "#" 35;
			Wait;
		Inactive:
		Death:
			TNT1 A 0 {
				A_SpawnItemEx("PowerPlantSmokePuffSmall", 0, 0, 32, 0, 0, 0, 0, 0);

				if (level.time > 5) { S_StartSound("WOODBRK", CHAN_AUTO, 0, 0.5, ATTN_NORM); }

				for (int i = 0; i < 4; i++) {
					A_SpawnItemEx("Debris_Wood", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
					A_SpawnItemEx("Debris_Wood", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
					A_SpawnItemEx("Debris_Wood", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
					A_SpawnItemEx("Debris_Wood", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
				}

				bNoInteraction = True;
			}
			"####" "#" 0; // Attempt to prevent sounds from being played when player loads their savegame - Talon1024
			TNT1 A 1;
			Stop;
	}
}

class Debris_WindowBoards : Debris_Wood_FloorCeiling2
{
	Default
	{
		//$Title Wood Debris, 3rd variant - Window boards (activatable)
		-SOLID
		Scale 0.5;
		Radius 1;
	}

	States
	{
		Spawn:
			VENT F 1;
			Goto Active;
	}
}

class TrainingTarget : SwitchableDecoration
{
	Default
	{
		//$Category Special Effects (BoA)
		//$Title HQ's Training Camp Target
		
		Radius 32;
		Height 72;
		Health 1;
		+DONTTHRUST
		+FORCEYBILLBOARD
		+NOBLOOD
		+NOGRAVITY
		+NOTAUTOAIMED
		+SHOOTABLE
		+WALLSPRITE
	}
	
	States
	{
		Spawn:
			TARG A 1;
		Active:
			TARG "#" 35;
			Wait;
		Inactive:
		Death:
			TARG B 0 { A_SpawnItemEx("PowerPlantSmokePuffSmall", 0, 0, 32, 0, 0, 0, 0, 0);
				for (int i = 0; i < 4; i++) {
					A_SpawnItemEx("Debris_FlagsW", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
					A_SpawnItemEx("Debris_FlagsW", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
				}

				bNoInteraction = True;
			}
			"####" "#" 0; // Attempt to prevent sounds from being played when player loads their savegame - Talon1024
			TARG B -1;
			Stop;
	}

	override bool Used(Actor user)
	{
		SetStateLabel("Death");
		return Super.Used(user);
	}
}

class Fahrkarten : Actor
{
	Default
	{
		//$Category Wall Decorations (BoA)
		//$Title Fahrkarten Sign
		
		Radius 2;
		Height 2;
		+FORCEYBILLBOARD
		+NOBLOCKMAP
		+NOGRAVITY
		+NOINTERACTION
		+WALLSPRITE
	}
	
	States
	{
		Spawn:
			FAHR A -1;
			Stop;
	}
}

// Workaround for this bug: https://forum.zdoom.org/viewtopic.php?f=2&t=62967 - Model by Talon1024
class ManholeCover3D : Debris_Vent_FloorCeiling
{
	Default
	{
		//$Category Models (BoA)/Scenery
		//$Title Manhole Cover (3D)
		//$Color 3
		
		-SHOOTABLE
		+INVULNERABLE
		Height 2;
	}

	States
	{
		Spawn:
			MDLA A 1;
		Active:
			MDLA "#" 35;
			Wait;
		Inactive:
		Death:
			TNT1 A 0 {
				A_SpawnItemEx("PowerPlantSmokePuffSmall", 0, 0, 32, 0, 0, 0, 0, 0);

				if (level.time > 5) { S_StartSound("DSMETDST", CHAN_AUTO, 0, 0.5, ATTN_NORM); }

				for (int i = 0; i < 4; i++) {
					A_SpawnItemEx("Debris_Trash", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
					A_SpawnItemEx("Debris_Trash2", 0, random(-32,32), random(0,64), random(-3,3), random(0,2), random(-1,4), 0, SXF_CLIENTSIDE);
				}

				bNoInteraction = True;
			}
			"####" "#" 0; // Attempt to prevent sounds from being played when player loads their savegame - Talon1024
			TNT1 A -1;
			Stop;
	}

	// Only break these when shot, not when used.
	override bool Used(Actor user)
	{
		return false;
	}
}

class StatueBreakable : Actor
{
	double tiltangle;
	double tiltpitch;
	double floorheight;
	Actor item;
	Class<Actor> itemclass;
	Vector3 spawnoffset;
	Vector3 oldpos;
	double oldpitch;
	double oldroll;
	Sound slidesound;

	Property SlideSound:slidesound;

	Default
	{
		//$Category Props (BoA)/Interactive Items
		//$Title Breakable Statue (with configurable drop item)
		//$Arg0 "Thing ID to spawn"
		//$Arg0Str "Actor class to spawn"
		//$Arg0ToolTip "What actor to spawn.  Numeric values set Thing ID, and string values set spawn class.  \nDefaults to nothing spawned."
		//$Color 3

		Radius 24;
		Height 160;
		Health 50;
		Mass 2000;
		Pushfactor 0.05;
		Scale 0.5;
		+NOBLOOD
		+NOTAUTOAIMED
		+PUSHABLE
		+SHOOTABLE
		+SOLID
		+NODAMAGE

		StatueBreakable.SlideSound "stone/slide";
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
		Fall:
			MDLA A 1 A_DoTilt(tiltangle);
			Loop;
		Death:
			MDLA A -1
			{
				if (item)
				{
					item.bNoGravity = item.Default.bNoGravity;
					item.bSpecial = item.Default.bSpecial;
					item.bSolid = item.Default.bSolid;
					item.bShootable = item.Default.bShootable;

					item.angle = tiltangle + Random(70, 110) * RandomPick(-1, 1);
					item.pitch = 75;
					item.roll = 0;
					item.bFlatSprite = item.Default.bFlatSprite;
					item.bWallSprite = item.Default.bWallSprite;

					item.scale = item.Default.scale;

					item.SetOrigin((item.pos.xy + RotateVector((Default.Radius + Random(0, 16), 0), item.angle), item.floorz), true);

					item = null;
				}

				A_DoTilt(tiltangle, 90);
				bSolid = false;

				Vector3 centerpoint = pos + (RotateVector((Default.height / 2, 0), tiltangle), 0);

				for (int d = 0; d < 25; d++)
				{
					Actor mo = Spawn("DebrisChunk", centerpoint);
					if (mo)
					{
						DebrisChunk(mo).user_variant = RandomPick(12, 13, 14);
						mo.angle = Random(0, 359);
						mo.VelFromAngle(Random(2, 6), mo.angle);
					}
				}

				A_StartSound("misc/SRCRK2", CHAN_AUTO, 0, frandom (0.3,0.5), ATTN_NORM);

				Actor smoke = Spawn("KD_HL2SmokeGenerator", centerpoint);
				if (smoke)
				{
					smoke.scale = scale;
				}

				bPushable = false;
			}
			Stop;
	}

	override void PostBeginPlay()
	{
		tiltangle = angle;

		itemclass = GetSpawnableType(args[0]);
		if (!itemclass) { itemclass = "Gem"; }

		if (itemclass)
		{
			item = Spawn(itemclass, pos + (RotateVector((13, -3), angle) * scale.x / Default.Scale.X, Default.Height * 0.76 * scale.y / Default.Scale.Y));
			if (item)
			{
				item.master = self;

				item.bNoGravity = true;
				item.bSpecial = false;
				item.bSolid = false;
				item.bShootable = false;

				item.angle = angle - 11;

				item.pitch = -40;
				if (item.sprite != item.GetSpriteIndex("MDLA"))
				{
					item.pitch -= 90;

					double r = GetSpriteRadius(item);

					if (r > 5.0)
					{
						item.scale *= (5.0 / r);
					}
				}

				item.roll = -3;
				item.bWallSprite = false;
				item.bFlatSprite = true;

				spawnoffset = item.pos - pos;

				Vector2 temp = RotateVector((spawnoffset.x, spawnoffset.y), -angle);
				spawnoffset = (temp.x, temp.y, spawnoffset.z);

				oldpos = pos;
				oldpitch = pitch;
				oldroll = roll;
			}
		}

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		floorheight = pos.z - cursector.floorplane.ZatPoint(pos.xy);

		if (BlockingLine && vel.xy.length() && floorheight > 0)
		{
			double linelength = int(BlockingLine.delta.Length());

			if (!BlockingLine.delta.x)
			{
				if (BlockingLine.v1.p.x > pos.x) { tiltangle = 180; }
				else { tiltangle = 0; }
			}
			else if (!BlockingLine.delta.y)
			{
				if (BlockingLine.v1.p.y > pos.y) { tiltangle = 270; }
				else { tiltangle = 90; }
			}
			else
			{
				tiltangle = atan2(BlockingLine.delta.y, BlockingLine.delta.x) + 90;
				if (BlockingLine.frontsector == cursector) { tiltangle += 180; }

				tiltangle = tiltangle % 360;
			}
		}

		if (vel.z < -1.0 && floorheight <= 16) { SetStateLabel("Death"); }
		if (pos.z == floorz && floorheight > 0) { SetStateLabel("Fall"); }

		if (
			item && 
			(
				pitch != oldpitch || 
				roll != oldroll || 
				pos != oldpos
			) && 
			!CheckSightOrRange(128)
		)
		{
			RotateItem();
		}

		double volume = 0.0;
		if (pos.z == floorz) { volume = vel.xy.length() / 25; }

		if (volume)
		{
			A_StartSound(slidesound, CHAN_5, CHANF_NOSTOP | CHANF_LOOP, volume);
			A_SoundVolume(CHAN_5, volume);
		}
		else
		{
			A_StopSound(CHAN_5);
		}

		Super.Tick();
	}

	void A_DoTilt(double tiltangle, double pitchinput = 0)
	{
		double angle = deltaangle(tiltangle, angle);

		if (tiltpitch < 90 || pitchinput)
		{
			if (pitchinput) { tiltpitch = pitchinput; }
			else { tiltpitch += max(1, tiltpitch / 30); }

			pitch = tiltpitch * cos(angle);
			roll = tiltpitch * sin(angle);
		}

		VelFromAngle(0.25 * (90 - tiltpitch) / (Default.radius / 1.4), tiltangle);
	}

	void RotateItem()
	{
		Vector2 temp;
		Vector3 offset;

		// Keep the actor in the correct position, regardless of pitch/roll of the master actor
		if (item && spawnoffset != (0, 0, 0)) {
			temp = RotateVector((spawnoffset.y, spawnoffset.z), roll);
			offset = (spawnoffset.x, temp.x, temp.y);

			temp = RotateVector((offset.x, offset.z), 360 - pitch);
			offset = (temp.x, offset.y, temp.y);

			temp = RotateVector((offset.x, offset.y), angle);
			offset = (temp.x, temp.y, offset.z);

			item.SetOrigin(pos + offset, true);
		}

		oldpos = pos;
		oldpitch = pitch;
		oldroll = roll;
	}

	double GetSpriteRadius(Actor item)
	{
		TextureID tex = item.SpawnState.GetSpriteTexture(0);

		if (tex) {
			Vector2 size = TexMan.GetScaledSize(tex);
			Vector2 offset = TexMan.GetScaledOffset(tex);

			return max(size.x - offset.x, offset.x) * item.scale.x; // Get the width of the widest part of the sprite (left or right of the offset center)
		}

		return 0;
	}
}

class StatueBreakable2 : StatueBreakable //has fixed hitbox so we must not scale it - ozy81
{
	Default
	{
		//$Title Breakable Statue for Manor (with configurable drop item)
		Height 96;
	}	
}

class Gem : CompassItem
{
	Default
	{
		//$Category Props (BoA)/Interactive Items
		Alpha 0.95;
		RenderStyle "Add";
		Scale 0.5;
		Inventory.Icon "GEMAA0";
		Inventory.PickupSound "misc/k_pkup";
		Inventory.PickupMessage "$PUGEM";
	}

	States
	{
		Spawn:
			MDLA A -1 Light("MineralLite");
			Stop;
	}
}

class InteractiveItem : PuzzleItem
{
	String user_displaystring, user_displayimage;
	double user_displayscale;
	private int itemflags;

	Property DisplayString:user_displaystring;
	Property DisplayImage:user_displayimage;
	Property DisplayScale:user_displayscale;

	Flagdef AllowPickup:itemflags, 0; // Allow the item to be added to player inventory
	Flagdef SetSprite:itemflags, 1; // Use args[1] input to set the sprite and inventory icon
	Flagdef UseToPickUp:itemflags, 2; // Player must press 'use' on item to pick it up

	Default
	{
		//$Category Props (BoA)/Interactive Items
		//$Color 3

		-SOLID
		+FLATSPRITE
		+NOGRAVITY
		-SPECIAL // Don't pick up automatically; requires player to 'use' the item to interact
		+InteractiveItem.ALLOWPICKUP // Pick up after used by the player, instead of being left in place
		+InteractiveItem.SETSPRITE // Set the sprite and icon based off of the second argument
		+InteractiveItem.USETOPICKUP // Must be used by the player to pick it up
		Radius 16;
		Height 32;
		Scale 0.25;
		RenderStyle 'Translucent';
		Inventory.PickupSound "pickup/papers";
		InteractiveItem.DisplayString "";
		InteractiveItem.DisplayImage "";
		InteractiveItem.DisplayScale 0.95;
	}

	override void PostBeginPlay()
	{
		if (bSetSprite)
		{
			frame = args[1];

			String ico = String.Format("%s%c%i", "TEXT", 65 + args[1], 0);
			icon = TexMan.CheckForTexture(ico, TexMan.Type_Any);
		}

		Super.PostBeginPlay();
	}

	override bool HandlePickup (Inventory item)
	{
		return false; // Never stack these items together
	}

	override bool TryPickup(in out Actor toucher)
	{
		if (bUseToPickup) { return false; } // Don't pick this actor up automatically; use it to activate it
		else
		{
			// Handling so that conversation-given items properly check the max amount before giving items to the player and taking money
			if (bDropped && maxamount > 0) // If given/dropped by another actor, and there is a max amount set...
			{
				let current = toucher.FindInventory(GetClass()); // and it's already in player inventory...
				if (current && current.Amount + Amount > maxamount) // don't pick it up if you already have max amount
				{
					bAlwaysPickup = false;	// Don't force pickup in excess of MaxAmount if the item was spawned by another actor after map load
								// This flag is checked in the internal Inventory pickup logic, regardless of the return value here.
					return false;
				}
			}

			return Super.TryPickup(toucher);
		}
	}

	override bool Use(bool pickup)
	{
		ViewItem(owner);

		return false;
	}

	override bool Used(Actor user)
	{
		if (bAllowPickup)
		{
			Inventory.TryPickup(user);
			PrintPickupMessage(user.CheckLocalView(), PickupMessage());
			if (!bAutoActivate) { S_StartSound(PickupSound, CHAN_ITEM, CHANF_UI | CHANF_NOSTOP, 1.0); }
		}
		else
		{
			ViewItem(user);
		}

		return false;
	}

	ui virtual String GetDisplayString()
	{
		return user_displaystring;
	}

	ui virtual String GetDisplayImage()
	{
		return user_displayimage;		
	}

	ui virtual double GetDisplayScale()
	{
		return user_displayscale;
	}

	void ViewItem(Actor viewer)
	{
		if (viewer && viewer.player)
		{
			viewer.player.ConversationNPC = self;
			if (viewer.player == players[consoleplayer]) { Menu.SetMenu("ViewItem"); }
			viewer.player.ConversationNPC = null;
		}

	}
}

class TextPaper : InteractiveItem
{
	Default
	{
		//$Title Paper (usable)

		//$Arg0 "Text ID"
		//$Arg0Tooltip "Predefined texts from the LANGUAGE lump, e.g. 2 is PAPERTEXT02.  Leave as 0 to use the user_displaytext property to set a string or LANGUAGE entry."
		//$Arg0Default 0
		//$Arg1 "Paper style"
		//$Arg1Tooltip "Various paper styles."
		//$Arg1Type 11
		//$Arg1Enum { 1 = "White Paper"; 2 = "Tan Paper"; 3 = "White Paper with Nazi Letterhead"; 4 = "Tan Paper with Nazi Letterhead"; 5 = "Old Dirty Paper"; 6 = "Heer Memo"; 7 = "Scrap"; 8 = "Astrostein tablet"; 0 = "Use user_displayimage variable"; }
		//$Arg1Default 1
		//$Arg2 "Font style"
		//$Arg2Tooltip "Various font styles."
		//$Arg2Type 11
		//$Arg2Enum { 1 = "Set Type (Book print)"; 2 = "Worn Typewriter"; 3 = "'Classic'"; 4 = "Handwriting 1 (Messy)"; 5 = "Handwriting 2 (Neat)"; 6 = "Handwriting 3 (Neat, small)"; 7 = "Console Font"; 8 = "Anka/Coder 16pt"; }
		//$Arg2Default 2

		-InteractiveItem.ALLOWPICKUP
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (frame == 8) { PickupSound = "pickup/generic"; }
	}

	override String GetDisplayString()
	{
		if (user_displaystring == "") { return String.Format("PAPERTEXT%02i", args[0]); }

		return user_displaystring;
	}

	States
	{
		Spawn:
			TEXT A -1;
			Stop;
	}
}

class TextPaperCollectible : TextPaper
{
	Default
	{
		//$Title Paper (usable, collectable)

		+INVENTORY.AUTOACTIVATE
		+InteractiveItem.ALLOWPICKUP
		Tag "$TAGPAPERCOLLECTIBLE";
		Inventory.Icon "TEXTG0";
		Inventory.PickupMessage "$DOCUMENT";
	}

	States
	{
		Spawn:
			TEXT G -1;
			Stop;
	}
}

class TextPaperSecretHint : TextPaperCollectible 
{
	Default
	{
		//$Title Secret Hint (usable, collectible)

		//$Arg0Tooltip "Lists of secret hints constructed from LANGUAGE lump entries. Leave as 0 to use the user_displaystring property to set a string or LANGUAGE entry."
		//$Arg2 "Not used"

		Tag "$TAGSECRETHINT";
		Inventory.Icon "TEXTF0";
		Inventory.PickupMessage "$SECRETHINTPAPER";
	}

	States
	{
		Spawn:
			TEXT F -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		args[2] = 9; // Custom font settings for secret hint paper

		Super.PostBeginPlay();
	}

	override String GetDisplayString()
	{
		// Code by N00b, with minor modifications
		if (!args[0]) { return ConstructSecretHintText(Super.GetDisplayString()); } // Just try to parse the UDMF property string if there's no argument set

		String base_name = "SECRET"..args[0], data, result;
		int i = 1;
		bool error = false;

		// Keep processing consecutive SECRET<i> strings until an entry doesn't exist
		while (!error && (data = StringTable.Localize(base_name..i, false)) && data != base_name..i)
		{
			String current;
			[current, error] = ConstructSecretHintText(data);

			result.AppendFormat(current);
			++i;
		}

		return result;
	}

	// Code by N00b, with minor modifications
	ui String, bool ConstructSecretHintText(String input)
	{
		if (input == "") { return "", true; }

		String result;
		int curToken, stringLine = 0;

		// itemids:
		//   ??? = 1, Weapon = 2, Grenade(s) = 3(4), 
		//   Gold (small, moderate, large, TREMENDOUS) = (5, 6, 7, 8), 
		//   Ammo (small, moderate, large, TREMENDOUS) = (9, 10, 11, 12), 
		//   Health (small, moderate, large, TREMENDOUS) = (13, 14, 15, 16), 
		//   Armor = 17, Various Supplies = 18
		//
		// Now decipher the input string which was passed
		//
		// The format is:
		//	t or s|comment|id|itemid|[itemid|[...]]
		//
		// example: "t|check the roof|1993|5|17" means thing with tag 1993 is a 
		// secret which gives access to a small amount of gold and an armor suit 
		// and tells the player to search for these on a roof.

		Array<String> tokens;
		input.Split(tokens, "|");

		if (tokens.size() < 4) { Console.Printf("TextPaperSecretHint.ConstructSecretHintText(): Incorrect hint format."); return "", true; }

		bool secret_found;

		// What is this secret? A thing? A sector?
		if (tokens[0] == "t") // Thing secret, a TID is given
		{
			// Find the secret item
			ActorIterator it = Level.CreateActorIterator(tokens[2].toInt());
			let item = it.Next();
			// Check whether or not it has been found
			if (!item || !item.bCOUNTSECRET) { secret_found = true; }
			else { secret_found = false; }
		}
		else if (tokens[0] == "tr") //Secret trigger
		{
			// Find the secret item
			ActorIterator it = Level.CreateActorIterator(tokens[2].toInt());
			Actor actor;
			secret_found = true;
			while ((actor = it.Next()))
			{
				if (!(actor is "SecretTrigger")) continue;
				secret_found = false;
				break;
			}
		}
		else if (tokens[0] == "s") // Sector secret, a sector number (not a tag) is given
		{
			int i = tokens[2].toInt(); //check if the sector exists
			if (Level.sectors.size() <= i) { Console.Printf("TextPaperSecretHint.ConstructSecretHintText(): Secret sector does not exist."); return "", true; }
			if (!(Level.sectors[i].flags & Sector.SECF_SECRET)) { secret_found = true; }
			else { secret_found = false; }
		} else { Console.Printf("TextPaperSecretHint.ConstructSecretHintText(): Incorrect hint format."); return "", true; }

		// now construct the line
		// let's pretend that BJ adds the red highlight mentally...
		if (secret_found) { result.AppendFormat("\cL☒ \c[SecretGreen]"); } // Use Unicode ballot checkbox characters to integrate the completion mark
		else { result.AppendFormat("\cL☐ \c[SecretRed]"); }

		// Add the items in the secret
		for (curToken = 3; curToken < tokens.size(); ++curToken)
		{
			result = result .. StringTable.Localize("SECRETITEM"..tokens[curToken], false);
			if (curToken < tokens.size() - 1)
			{
				result = result .. "; ";
			}
		}

		if (tokens[1] != "") result.AppendFormat("\cL: "..tokens[1].."\n\n");
		else result.AppendFormat("\n"); //crutch...

		return result, false;
	}
}

class CastleWolfensteinMap : InteractiveItem
{
	Default
	{
		-InteractiveItem.SETSPRITE
		-InteractiveItem.USETOPICKUP
		Inventory.MaxAmount 1;
		Inventory.Amount 1;
		Inventory.Icon "MAPIA0";
		Inventory.PickupMessage "$PAPERMAP";
		InteractiveItem.DisplayImage "PAPER9";
		InteractiveItem.DisplayScale 0.45;
		Tag "$TAGCASTLEMAP";
	}

	States
	{
		Spawn:
			MAPI B -1;
			Stop;
	}
}

class Safe : Actor
{
	bool isopen, locked, unlock;
	Class<Actor> spawnclass;

	Default
	{
		//$Category Props (BoA)/Interactive Items
		//$Arg0 "Script to run"
		//$Arg0Tooltip "[String] Actor to spawn in the safe or [Number] Script number to run"
		//$Arg0Str "Actor class to spawn"
		//$Arg1 "First number of combination"
		//$Arg2 "Second number of combination"
		//$Arg3 "Third number of combination"

		+SOLID
		Height 38;
		Radius 12;
	}

	States
	{
		Spawn:
		 	MDLA A -1;
			Stop;
		Opened:
			MDLA BCDE 5;
			MDLA F -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		BoACompass.Add(self, "SAFEICO");

		if (args[0] < 0) // If a string value was passed in, use that as the spawn class
		{
			spawnclass = GetSpawnableType(args[0]);

			if (GetDefaultByType(spawnclass).bCountItem) { level.total_items++; }
		}

		locked = true;

		Super.PostBeginPlay();
	}

	override bool Used(Actor user)
	{
		if (isopen || !user.player) { return false; }

		if (locked)
		{
			user.player.ConversationNPC = self;
			if (user.player = players[consoleplayer]) { Menu.SetMenu("CombinationSafe"); }
			user.player.ConversationNPC = null;

			return true;
		}
		else
		{
			DoOpen();
			return true;
		}

		return false;
	}

	void DoOpen()
	{
		SetStateLabel("Opened");

		locked = false;
		isopen = true;

		A_SetSize(4);

		if (spawnclass) // If arg[0] resolved to a classname
		{
			// Spawn that actor
			let mo = Spawn(spawnclass, pos + (0, 0, 4), ALLOW_REPLACE);
			mo.scale *= 0.5;
			mo.bNoGravity = true;
			mo.bDropped = false;

			if (mo.bCountItem) { level.total_items--; }
		}
		else if (args[0] > 0)
		{
			// If you passed in a script number, then run the script
			ACS_ExecuteAlways(args[0], 0, tid);
		}

		BoACompass.Remove(self);
	}
}

class Buoyancy : Actor
{
	// Modified from AActor::UpdateWaterLevel in p_mobj.cpp (waterlevel variable setting function)
	// Updated to return actual water height value
	static double, bool, Sector GetWaterHeight(Actor mo)
	{
		if (mo.curSector.MoreFlags & Sector.SECMF_UNDERWATER)
		{
			return mo.ceilingz, true, mo.curSector;
		}
		else
		{
			Sector hsec = mo.curSector.GetHeightSec();

			if (hsec)
			{
				if (hsec.MoreFlags & Sector.SECMF_UNDERWATERMASK)
				{
					double fh = hsec.floorplane.ZatPoint(mo.pos.xy);
					double ch = hsec.ceilingplane.ZatPoint(mo.pos.xy);

					if (mo.pos.z < fh)
					{
						return fh, true, hsec;
					}
					else if (!(hsec.MoreFlags & Sector.SECMF_FAKEFLOORONLY) && (mo.pos.z + mo.height > ch))
					{
						return ch, true, hsec;
					}
				}
			}
			else
			{
				for (int i = 0; i < mo.curSector.Get3DFloorCount(); i++)
				{
					F3DFloor f = mo.curSector.Get3DFloor(i);

					if (!(f.flags & F3DFloor.FF_EXISTS)) { continue; }
					if (f.flags & F3DFloor.FF_SOLID) { continue; }
					if (!(f.flags & F3DFloor.FF_SWIMMABLE)) { continue; }

					double ff_bottom = f.bottom.ZatPoint(mo.pos.xy);
					double ff_top = f.top.ZatPoint(mo.pos.xy);

					if (ff_bottom > mo.pos.z + mo.height) continue;

					return ff_top, true, f.model;
				}
			}
		}

		return 0, false, null;
	}
}

mixin class GiveBuoyancy
{
	bool inwater;
	int offset;
	double user_buoyancy;

	Property Buoyancy:user_buoyancy;

	void DoBuoyancy()
	{
		if (!user_buoyancy) { return; }

		if (offset == 0) { offset = Random(-64, 64); }

		bool iswater;
		double waterheight;
		[waterheight, iswater] = Buoyancy.GetWaterHeight(self);

		if (iswater && waterheight > floorz && pos.z < waterheight)
		{
			inwater = true;

			bNoGravity = true;
			bPushable = false;

			double heightoffset = min(abs(user_buoyancy) - 0.05, 0.1) * sin(level.time + offset);
			double waterclip = Default.height * ((1.0 - user_buoyancy) + heightoffset);

			if (waterheight > pos.z + waterclip + 1)
			{
				vel.z = 2.0 * abs(user_buoyancy);
			}
			else
			{
				SetOrigin((pos.xy, max(waterheight - waterclip, floorz)), true);
			}
		}
		else if (inwater)
		{
			inwater = false;

			bNoGravity = Default.bNoGravity;
			bPushable = Default.bPushable;
		}
	}
}