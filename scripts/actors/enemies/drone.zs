/*
 * Copyright (c) 2019-2020 AFADoomer
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

Class ProtoDrone : Nazi //ozy81
{
	int firecount;

	Default
	{
		//$Category Monsters (BoA)
		//$Title Prototype Drone
		//$Color 4
		Scale 0.87;
		Health 250;
		Height 48;
		Radius 32;
		Mass 400;
		MeleeRange 256;
		MeleeThreshold 256; //forces the melee attack
		MaxTargetRange 896; //same of Arch-Vile, guess it's enough
		Speed 2;
		-FLOORCLIP
		+FLOAT
		+LOOKALLAROUND
		+NOBLOOD
		+NOGRAVITY
		+NOINFIGHTING
		+NOPAIN
		Obituary "$PDRONE";
		SeeSound "proto/see";
		PainSound "drone_pain";
		DeathSound "astrostein/explosion";
		ActiveSound "proto/see";
	}

	States
	{
		Spawn:
			PROT A 0;
			"####" "#" 0 { user_incombat = true; } //mxd
			Goto Look;
		Look:
			PROT A 1 A_Look();
			Loop;
		See:
			PROT A 1
			{
				A_Chase();
				A_StopLaser();
			}
			"####" AA 1 A_Chase(null, null, CHF_NOPLAYACTIVE);
			Loop;
		Idle:
			PROT AAA 1 A_Wander();
			"####" A 0
			{
				A_LookEx(LOF_NOSEESOUND);
				if (Random(0, 2) == 0) { PlayActiveSound(); }
			}
			Loop;
		Melee:
			PROT B 0 A_Jump(128,"Melee2");
			"####" B 5
			{
				A_FaceTarget();
				A_StopLaser();
			}
			"####" B 0 A_StartSound("astrochaingun/fire", CHAN_WEAPON);
			"####" CDE 8 LIGHT("PROTOFIRE") A_SpawnProjectile("EnemyProtoTracer",Scale.X*2,Scale.Y*-16,random(-12,12));
			"####" B 5 A_FaceTarget();
			"####" B 0 A_StartSound("astrochaingun/fire", CHAN_WEAPON);
			"####" CDE 8 LIGHT("PROTOFIRE") A_SpawnProjectile("EnemyProtoTracer",Scale.X*2,Scale.Y*-16,random(-12,12));
			Goto See;
		Melee2:
			"####" N 5
			{
				A_FaceTarget();
				A_StopLaser(); 
			}
			"####" N 0 A_Jump(128,2);
			"####" N 1 ThrustThing(int(Angle*256/360-192), 8, 1, 0);
			"####" N 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
			"####" FGHI 2 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",Scale.X*2,Scale.Y*16,random(-24,24));
			"####" I 0 A_SpawnItemEx("Casing9mm", Scale.X*2, Scale.Y*16, random(-2,2), RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
			"####" N 5 A_FaceTarget();
			"####" N 0 A_Jump(128,2);
			"####" N 1 ThrustThing(int(Angle*256/360-192), 8, 1, 0);
			"####" N 0 A_StartSound("chaingun/fire", CHAN_WEAPON);
			"####" FGHI 2 LIGHT("NAZIFIRE") A_SpawnProjectile("EnemyPistolTracer",Scale.X*2,Scale.Y*16,random(-24,24));
			"####" I 0 A_SpawnItemEx("Casing9mm", Scale.X*2, Scale.Y*16, random(-2,2), RandomPick(-3, 3), random(-1,1), random(2,4), random(-55,-80),SXF_NOCHECKPOSITION);
			Goto See;
		Missile:
			PROT A 10 {
				A_StartSound("proto/marker", CHAN_AUTO, 0, 0.75);
				firecount = 0;
			}
		Missile.Sight:
			PROT A 1;
			PROT A 0 {
				A_FaceTarget(1.0, 180, flags:FAF_MIDDLE);
				A_FireLaser(0, "", 46, 0, 0.1);

				if (firecount++ < 70 || (!hitpointtracer.Results.HitActor || hitpointtracer.Results.HitActor != target)) { SetStateLabel("Missile.Sight"); }
				else { firecount = 0; }
			}
		Missile.Loop:
			PROT A 1;
			PROT A 0 {
				double laseralpha = max(0.1, double(firecount) / 25);
				A_FireLaser(firecount % 3 == 0, "tesla/loop", 46, firecount % 10 == 0, laseralpha, laseralpha);

				if (firecount++ < 35) { SetStateLabel("Missile.Loop"); }
				else { A_StopLaser(); }
			}
			Goto See;
		Death:
			PROT OPQRS 3;
			"####" T 1 {
				A_Scream();
				A_SpawnItemEx("ProtoExplosion_Medium", 0, 0, 48);
				A_NoBlocking();
			}
			"####" TTTTTTTTTTTT 0 A_SpawnItemEx("Debris_MetalJunk", random(0,8), random(0,16), random(0,48), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
			"####" TTTTTTTTTTTT 0 A_SpawnItemEx("Debris_MetalJunk", random(8,16), random(16,32), random(48,64), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
			"####" TTTTTTTTTTTT 0 A_SpawnItemEx("Debris_MetalJunk", random(16,32), random(32,48), random(64,80), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
			"####" U 3;
			Stop;
	}
}