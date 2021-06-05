/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, AFADoomer
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

//////////////////////
// ITEMS & POWERUPS //
//////////////////////
class CKShikadiSoda : CKTreasure
{
	Default
	{
		//$Category Commander Keen (BoA)/Pickups
		//$Title Pickup (Shikadi Soda, 1pts)
		//$Color 13
		Radius 10;
		Height 36;
		Inventory.Amount 1;
		Inventory.PickupMessage "$CKSODA";
		+BRIGHT
	}
	States
	{
	Spawn:
		CKPU AB 15;
		Loop;
	Pickup:
		"####" C -1;
		Stop;
	}
}

class CKGum : CKTreasure
{
	Default
	{
		//$Category Commander Keen (BoA)/Pickups
		//$Title Pickup (Three-Tooth Gum, 2pts)
		//$Color 13
		Radius 16;
		Height 32;
		Inventory.Amount 2;
		Inventory.PickupMessage "$CKCANDY";
		+BRIGHT
	}
	States
	{
	Spawn:
		CKPU ST 15;
		Loop;
	Pickup:
		"####" U -1;
		Stop;
	}
}

class CKShikkersCandyBar : CKTreasure
{
	Default
	{
		//$Category Commander Keen (BoA)/Pickups
		//$Title Pickup (Shikkers Candy Bar, 5pts)
		//$Color 13
		Radius 14;
		Height 36;
		Inventory.Amount 5;
		Inventory.PickupMessage "$CKCANDY";
		+BRIGHT
	}
	States
	{
	Spawn:
		CKPU DE 15;
		Loop;
	Pickup:
		"####" F -1;
		Stop;
	}
}

class CKJawbreaker : CKTreasure
{
	Default
	{
		//$Category Commander Keen (BoA)/Pickups
		//$Title Pickup (Jawbreaker, 10pts)
		//$Color 13
		Radius 16;
		Height 30;
		Inventory.Amount 10;
		Inventory.PickupMessage "$CKJAW";
		+BRIGHT
	}
	States
	{
	Spawn:
		CKPU PQ 15;
		Loop;
	Pickup:
		"####" R -1;
		Stop;
	}
}

class CKDoughnut : CKTreasure
{
	Default
	{
		//$Category Commander Keen (BoA)/Pickups
		//$Title Pickup (Dougnut, 20pts)
		//$Color 13
		Radius 15;
		Height 30;
		Inventory.Amount 20;
		Inventory.PickupMessage "$CKDNUT";
		+BRIGHT
	}
	States
	{
	Spawn:
		CKPU GH 15;
		Loop;
	Pickup:
		"####" I -1;
		Stop;
	}
}

class CKIceCreamCone : CKTreasure
{
	Default
	{
		//$Category Commander Keen (BoA)/Pickups
		//$Title Pickup (IceCreamCone, 50pts)
		//$Color 13
		Radius 10;
		Height 32;
		Inventory.Amount 50;
		Inventory.PickupMessage "$CKCONE";
		Inventory.PickupSound "ckeen/pickup";
		+BRIGHT
	}
	States
	{
	Spawn:
		CKPU JK 15;
		Loop;
	Pickup:
		"####" L -1;
		Stop;
	}
}

class CKRaindrop : CKHealth
{
	Default
	{
		//$Title Health (Raindrop, +1)
		Radius 10;
		Height 32;
		+INVENTORY.ALWAYSPICKUP
		Inventory.Amount 1;
		Inventory.MaxAmount 200;
		Inventory.PickupMessage "$CKDROP";
		Inventory.PickupSound "ckeen/raindrop";
		CKHealth.VSpeed 0;
	}
	States
	{
	Spawn:
		CKDP ABCB 6;
		Loop;
	Pickup:
		"####" DEF 3;
		Stop;
	}
}

class CKOneUp : CKHealth
{
	Default
	{
		//$Title Health (Lifewater Flask, +100)
		Radius 12;
		Height 36;
		+INVENTORY.ALWAYSPICKUP
		+INVENTORY.AUTOACTIVATE
		Inventory.Amount 100;
		Inventory.MaxAmount 200;
		Inventory.PickupMessage "$CKONEUP";
		Inventory.PickupSound "ckeen/life";
		+BRIGHT
	}
	States
	{
	Spawn:
		CKPU MN 15;
		Loop;
	Pickup:
		"####" O -1;
		Stop;
	}
}

/////////////
// WEAPONS //
/////////////

class CKStunnerAmmo : Ammo
{
	Default
	{
		Tag "$TAGECELL";
		+INVENTORY.IGNORESKILL
		Inventory.MaxAmount 99;
		Inventory.Icon "CKNE01";
	}
}

////////////////////
// KEYS & KEYPOTS //
////////////////////
class CKBlueKey : CKPuzzleItem
{
	Default
	{
		//$Title Gem, blue (Blue Card)
		Radius 15;
		Height 24;
		PuzzleItem.Number 101;
		Inventory.PickupMessage "$CKBGEM";
		Inventory.Icon "CKKEYS1";
		Inventory.PickupSound "ckeen/gem";
		Species "BoABlueKey";
		+BRIGHT
	}
	States
	{
	Spawn:
		CKKY CD 5;
		Loop;
	Pickup:
		"####" G -1;
		Stop;
	}
}

class CKYellowKey : CKPuzzleItem
{
	Default
	{
		//$Title Gem, yellow (Yellow Card)
		Radius 15;
		Height 24;
		PuzzleItem.Number 102;
		Inventory.PickupMessage "$CKYGEM";
		Inventory.Icon "CKKEYS0";
		Inventory.PickupSound "ckeen/gem";
		Species "BoAYellowKey";
		+BRIGHT
	}
	States
	{
	Spawn:
		CKKY EF 5;
		Loop;
	Pickup:
		"####" G -1;
		Stop;
	}
}

class CKRedKey : CKPuzzleItem
{
	Default
	{
		//$Title Gem, red (Red Card)
		Radius 15;
		Height 24;
		PuzzleItem.Number 103;
		Inventory.PickupMessage "$CKRGEM";
		Inventory.Icon "CKKEYS2";
		Inventory.PickupSound "ckeen/gem";
		Species "BoARedKey";
		+BRIGHT
	}
	States
	{
	Spawn:
		CKKY AB 5;
		Loop;
	Pickup:
		"####" G -1;
		Stop;
	}
}

class CKGreenKey : CKPuzzleItem
{
	Default
	{
		//$Title Gem, green (Green Card)
		Radius 15;
		Height 24;
		PuzzleItem.Number 104;
		Inventory.PickupMessage "$CKGGEM";
		Inventory.Icon "CKKEYS3";
		Inventory.PickupSound "ckeen/gem";
		Species "BoAGreenKey";
		+BRIGHT
	}
	States
	{
	Spawn:
		CKKY HI 5;
		Loop;
	Pickup:
		"####" G -1;
		Stop;
	}
}

class CKRedKeyPod : SwitchableDecoration
{
	Default
	{
		//$Category Commander Keen (BoA)/Items
		//$Title Gempod, red
		//$Color 13
		Radius 13;
		Height 22;
		Scale 2.0;
		+DONTTHRUST
		+SOLID
		+USESPECIAL
	}
	States
	{
	Spawn:
	Inactive:
		CKKS B -1;
		Stop;
	Active:
		TNT1 A 0 A_StartSound("ckeen/gemuse");
		CKKS A -1 BRIGHT;
		Stop;
	}
}

class CKBlueKeyPod : CKRedKeyPod
{
	Default
	{
		//$Category Commander Keen (BoA)/Items
		//$Title Gempod, blue
		//$Color 13
	}
	States
	{
	Spawn:
	Inactive:
		CKKS D -1;
		Stop;
	Active:
		TNT1 A 0 A_StartSound("ckeen/gemuse");
		CKKS C -1 BRIGHT;
		Stop;
	}
}

class CKYellowKeyPod : CKRedKeyPod
{
	Default
	{
		//$Category Commander Keen (BoA)/Items
		//$Title Gempod, yellow
		//$Color 13
	}
	States
	{
	Spawn:
	Inactive:
		CKKS F -1;
		Stop;
	Active:
		TNT1 A 0 A_StartSound("ckeen/gemuse");
		CKKS E -1 BRIGHT;
		Stop;
	}
}

class CKGreenKeyPod : CKRedKeyPod
{
	Default
	{
		//$Category Commander Keen (BoA)/Items
		//$Title Gempod, green
		//$Color 13
	}
	States
	{
	Spawn:
	Inactive:
		CKKS H -1;
		Stop;
	Active:
		TNT1 A 0 A_StartSound("ckeen/gemuse");
		CKKS G -1 BRIGHT;
		Stop;
	}
}

//////////////
// MONSTERS //
//////////////
class CKArachnut : CKBaseEnemy
{
	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title Arachnut
		//$Color 4
		Speed 6;
		Radius 30;
		Height 56;
		Mass 400;
		+FLOORCLIP
		+LOOKALLAROUND
		Obituary "$CK_ARACH";
		CKBaseEnemy.StunTime 120;
	}
	States
	{
	Spawn:
		CKAC A 10 A_Look;
		Loop;
	See:
		"####" AAABBBCCCDDD 1 Fast A_Chase(null, null);
		Loop;
	Stunned:
		CKAC E -1;
		Stop;
	Revive:
		CKAC AEAE 10;
		Goto See;
	}
}

class CKMadMushroom : CKBaseEnemy
{
	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title Mad Mushroom
		//$Color 4
		Radius 30;
		Height 56;
		Obituary "$CK_MUSH";
		+NOTAUTOAIMED
		CKBaseEnemy.StunTime 0;
	}
	States
	{
	Spawn:
		CKMR AB 4 CK_MushroomBounce;
		Loop;
	}
}

class CKPoisonSlug : CKBaseEnemy
{
	Default
	{
		//$Category Commander Keen (BoA)/Monsters
		//$Title Poison Slug
		//$Color 4
		Speed 16;
		Radius 16;
		Height 32;
		Obituary "$CK_SLUG";
		CKBaseEnemy.StunFrames 2;
	}

	States
	{
		Spawn:
			CKPS A 10 A_Look;
			Loop;
		See:
			"####" AABB 4 A_Wander;
			"####" C 0 DoSlime();
			Loop;
		Stunned:
			CKPS E 1 A_ChangeVelocity(2, 0, 6, CVF_RELATIVE);
			CKPS E -1;
			Stop;
	}

	void DoSlime()
	{
		if (Random() > 16) { return; }

		A_StartSound("ckeen/slugpoo");
		Actor slime = Spawn("CKPoisonSlugPoison", pos);
		tics = 30;
	}
}

class CKPoisonSlugPoison : CKBaseEnemy
{
	Default
	{
		Radius 8;
		Height 0.5;
		Scale 3.0;
		-CASTSPRITESHADOW
		+FLATSPRITE
		+ROLLSPRITE
		+NOTAUTOAIMED
		-COUNTKILL
		-SHOOTABLE
		CKBaseEnemy.StunTime 0;
	}

	States
	{
		Spawn:
			CKSL Z 150;
			CKSL Y 30 { SetDamage(0); } // No damage during fading frame
			Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (cursector.floorplane.IsSlope())
		{
			let normal = cursector.floorplane.normal;
			Vector3 gradient;
			gradient.x = normal.x * normal.z;
			gradient.y = normal.y * normal.z;
			gradient.z = (normal.x * normal.x) + (normal.y * normal.y);

			roll = -angle;
			angle = atan2(gradient.y, gradient.x);
			pitch = atan2(gradient.z, gradient.xy.length());
		}
	}
}

class CKOracle : CKBaseEnemy
{
	Default
	{
		//$Category Commander Keen (BoA)/NPCs
		//$Title Oracle of Wisdom (Council Member)
		//$Color 11
		Speed 3;
		Radius 16;
		Height 64;
		Damage 0;
		+FRIENDLY
		+NOTAUTOAIMED
		CKBaseEnemy.StunTime 0;
		CKBaseEnemy.TouchSound "ckeen/message";
	}
	States
	{
	Spawn:
		CKCC A 1;
	See:
		"####" AAAAABBBBB 1 A_Wander;
		"####" A 0 A_Jump(24, "Stand");
		Loop;
	Stand:
		"####" C 60;
		Goto See;
	}
}

class CKCloud: Actor
{
	Default
	{
		//$Category Commander Keen (BoA)/Props
		//$Title Cloud
		//$Color 3
		Radius 32;
		Height 32;
		Scale 2.0;
		+NOGRAVITY
		-SOLID
	}
	States
	{
	Spawn:
		CKCL A -1;
		Stop;
	}
}

class CKThunderbolt: Actor
{
	Default
	{
		Radius 70;
		Height 32;
		Speed 0;
		Scale 2.0;
		+DONTTHRUST
		+NOGRAVITY
		-SOLID
	}
	States
	{
	Spawn:
		CKTH A 0 NODELAY A_StartSound("ckeen/shothit");
		CKTH ABABAB 8 A_Explode;
		Stop;
	}
}

class CKCoral1: Actor
{
	Default
	{
		//$Category Commander Keen (BoA)/Props
		//$Title Coral (large)
		//$Color 3
		Radius 32;
		Height 32;
		Scale 2.0;
		+NOGRAVITY
		-SOLID
	}
	States
	{
	Spawn:
		CKCR A -1;
		Stop;
	}
}

class CKCoral2: CKCoral1
{
	Default
	{
		//$Category Commander Keen (BoA)/Props
		//$Title Coral (small)
		//$Color 3
	}
	States
	{
	Spawn:
		CKCR B -1;
		Stop;
	}
}

class CKAlge1: Actor
{
	Default
	{
		//$Category Commander Keen (BoA)/Props
		//$Title Alge (single)
		//$Color 3
		Radius 32;
		Height 32;
		Scale 2.0;
		+NOGRAVITY
		-SOLID
	}
	States
	{
	Spawn:
		CKAL ABCD 10;
		Loop;
	}
}

class CKAlge2 : CKAlge1
{
	Default
	{
		//$Title Alge (triple)
	}
	States
	{
	Spawn:
		CKAL EFGH 10;
		Loop;
	}
}

class CKFireplace: Actor
{
	Default
	{
		//$Category Commander Keen (BoA)/Props
		//$Title Fireplace
		//$Color 3
		Radius 32;
		Height 32;
		Scale 2.0;
		+NOGRAVITY
		-SOLID
	}
	States
	{
	Spawn:
		CKFR ABCD 10;
		Loop;
	}
}

class CKGroundfire : CKBaseEnemy
{
	Default
	{
		//$Category Commander Keen (BoA)/Props
		//$Title Groundfire
		//$Color 3
		Radius 32;
		Height 0.5;
		+NOTAUTOAIMED
		-COUNTKILL
		-SHOOTABLE
		CKBaseEnemy.StunTime 0;
	}
	States
	{
	Spawn:
		CKFR EFGH 10;
		Loop;
	}
}

class CKWallSlug: Actor
{
	Default
	{
		//$Category Commander Keen (BoA)/Props
		//$Title Wall Slug
		//$Color 3
		Radius 8;
		Height 32;
		Scale 2.0;
		-SOLID
		+NOBLOCKMAP
		+NOGRAVITY
		+WALLSPRITE
	}
	States
	{
	Spawn:
		CKWS YZ 30;
		Loop;
	}
}

class CKTreeBranch: Actor
{
	Default
	{
		//$Category Commander Keen (BoA)/Props
		//$Title Tree Branch
		//$Color 3
		Radius 90;
		Height 1;
		Scale 1.0;
		+NOGRAVITY
		+NOBLOCKMAP
		+FLATSPRITE
		+ROLLSPRITE
	}
	States
	{
	Spawn:
		CKBW A -1;
		Stop;
	}
}

class CKWallFire : CKWallSlug
{
	Default
	{
		//$Title Wall Fire
	}
	States
	{
	Spawn:
		CKWF ABCD 10;
		Loop;
	}
}

class CKCaveEyes : CKWallSlug
{
	Default
	{
		//$Title Wall Eyes
	}
	States
	{
	Spawn:
		CKCE ABB 35;
		Loop;
	}
}

class CKFireBowl : CKWallSlug
{
	Default
	{
		//$Title Fire Bowl
		Radius 32;
		-NOBLOCKMAP
	}
	States
	{
	Spawn:
		CKFB A -1;
		Stop;
	}
}

class CKExitSign1: Actor
{
	Default
	{
		//$Category Commander Keen (BoA)/Props
		//$Title Exit Sign (1)
		//$Color 3
		Radius 32;
		Height 32;
		Scale 2.0;
		+NOGRAVITY
		-SOLID
	}
	States
	{
	Spawn:
		CKEX A -1;
		Stop;
	}
}

class CKExitSign2 : CKExitSign1
{
	Default
	{
		//$Title Exit Sign (2)
	}
	States
	{
	Spawn:
		CKEX B -1;
		Stop;
	}
}

class CKPCKFSign1 : CKExitSign1
{
	Default
	{
		//$Title PCKF Sign (1)
		Scale 0.5;
	}
	States
	{
	Spawn:
		PCK1 BBAA 1 A_SetTics(random(4,8));
		Loop;
	}
}

class CKFireColumn : CKExitSign1
{
	Default
	{
		//$Title Fire Column
	}
	States
	{
	Spawn:
		CKFC ABC 10;
		Loop;
	}
}

class CKNisaba : CKExitSign1
{
	Default
	{
		//$Title Nisaba Easteregg
	}
	States
	{
	Spawn:
		CKNB A -1;
		Stop;
	}
}

class CKAquaDrop: Actor
{
	Default
	{
		//$Category Commander Keen (BoA)/Props
		//$Title Aqua Drop
		//$Color 3
		Radius 8;
		Height 32;
		Scale 2.0;
		+FLATSPRITE
		+NOGRAVITY
		-SOLID
	}
	States
	{
	Spawn:
		CKDR ABCDE 10;
	Waiter:
		TNT1 A 10 A_Jump(80, "Spawn");
		Loop;
	}
}

class CKGroundThruster : CKBaseEnemy
{
	Default
	{
		//$Category Commander Keen (BoA)/Props
		//$Title Platform Thruster
		//$Color 3
		Radius 8;
		Height 64;
		+NOGRAVITY
		-SOLID
		-SHOOTABLE
	}
	States
	{
	Spawn:
		CKJT AB 10;
		loop;
	}
}

class CKSpike : CKBaseEnemy
{
	Default
	{
		//$Category Commander Keen (BoA)/Props
		//$Title Spike
		//$Color 3
		Damage 100;
		Radius 16;
		Height 48;
		+NOTAUTOAIMED
		-COUNTKILL
		-SHOOTABLE
		CKBaseEnemy.StunTime 0;
	}
	States
	{
	Spawn:
		CKSK A -1;
		Stop;
	}
}