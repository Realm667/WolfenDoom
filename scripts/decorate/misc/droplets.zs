/*
 * Copyright (c) 2017-2021 Ozymandias81, AFADoomer
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

//**This is SidDoyle's Droplets effect, condensed & adapted as a single lump by Ozymandias81 for Blade of Agony**//

/////////
//POOLS//
/////////

// Moved to ZScript (miscellaneous.txt)

////////
//GIBS//
////////

class GibMe : CustomInventory
{
	States
	{
	Pickup:
		TNT1 A 0
		{
			if (health < GetGibHealth())
			{A_SpawnItemEx("GibSpray",0,0,32,Vel.X,Vel.Y,0,0,SXF_USEBLOODCOLOR);}
		}
		Stop;
	}
}

class GibletA : ParticleBase
{
	Default
	{
		Radius 2;
		Height 4;
		Speed 4;
		DeathHeight 4;
		BounceFactor 0.15;
		Gravity 0.667;
		+BOUNCEONWALLS
		+FLOORCLIP
		+FORCEXYBILLBOARD
		+MISSILE
		+MOVEWITHSECTOR
		+NOBLOCKMAP
		+NOTONAUTOMAP
		+THRUACTORS
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_ScaleVelocity(frandom(0.5, 2.0));
		GIBL A random(2,4)
		{
			A_SpawnItemEx("BloodDrop1",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,160);
			A_SpawnItemEx("BloodDrop2",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,128);
			A_SpawnItemEx("BloodDrop3",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,96);
		}
		Wait;
	Death:
		"----" A -1 A_SpawnItemEx("BloodDrop1",0,0,0,0,0,0,0,SXF_TRANSFERTRANSLATION);
		Stop;
	}
}

class GibletB : GibletA
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_ScaleVelocity(frandom(0.5, 2.0));
		GIBL B random(2,4)
		{
			A_SpawnItemEx("BloodDrop1",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,160);
			A_SpawnItemEx("BloodDrop2",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,128);
			A_SpawnItemEx("BloodDrop3",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,96);
		}
		Wait;
	}
}

class GibletC : GibletA
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_ScaleVelocity(frandom(0.5, 2.0));
		GIBL C random(2,4)
		{
			A_SpawnItemEx("BloodDrop1",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,160);
			A_SpawnItemEx("BloodDrop2",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,128);
			A_SpawnItemEx("BloodDrop3",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,96);
		}
		Wait;
	}
}

class GibletD : GibletA
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_ScaleVelocity(frandom(0.5, 2.0));
		GIBL D random(2,4)
		{
			A_SpawnItemEx("BloodDrop1",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,160);
			A_SpawnItemEx("BloodDrop2",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,128);
			A_SpawnItemEx("BloodDrop3",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,96);
		}
		Wait;
	}
}

class GibletE : GibletA
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_ScaleVelocity(frandom(0.5, 2.0));
		GIBL E random(2,4)
		{
			A_SpawnItemEx("BloodDrop1",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,160);
			A_SpawnItemEx("BloodDrop2",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,128);
			A_SpawnItemEx("BloodDrop3",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,96);
		}
		Wait;
	}
}

class GibletF : GibletA
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_ScaleVelocity(frandom(0.5, 2.0));
		GIBL F random(2,4)
		{
			A_SpawnItemEx("BloodDrop1",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,160);
			A_SpawnItemEx("BloodDrop2",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,128);
			A_SpawnItemEx("BloodDrop3",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,96);
		}
		Wait;
	}
}

class GibletG : GibletA
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_ScaleVelocity(frandom(0.5, 2.0));
		GIBL G random(2,4)
		{
			A_SpawnItemEx("BloodDrop1",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,160);
			A_SpawnItemEx("BloodDrop2",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,128);
			A_SpawnItemEx("BloodDrop3",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,96);
		}
		Wait;
	}
}

class GibletH : GibletA
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_ScaleVelocity(frandom(0.5, 2.0));
		GIBL H random(2,4)
		{
			A_SpawnItemEx("BloodDrop1",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,160);
			A_SpawnItemEx("BloodDrop2",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,128);
			A_SpawnItemEx("BloodDrop3",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,96);
		}
		Wait;
	}
}

class GibletI : GibletA
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_ScaleVelocity(frandom(0.5, 2.0));
		GIBL I random(2,4)
		{
			A_SpawnItemEx("BloodDrop1",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,160);
			A_SpawnItemEx("BloodDrop2",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,128);
			A_SpawnItemEx("BloodDrop3",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,96);
		}
		Wait;
	}
}

class GibletJ : GibletA
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_ScaleVelocity(frandom(0.5, 2.0));
		GIBL J random(2,4)
		{
			A_SpawnItemEx("BloodDrop1",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,160);
			A_SpawnItemEx("BloodDrop2",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,128);
			A_SpawnItemEx("BloodDrop3",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,96);
		}
		Wait;
	}
}

class GibletK : GibletA
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_ScaleVelocity(frandom(0.5, 2.0));
		GIBL K random(2,4)
		{
			A_SpawnItemEx("BloodDrop1",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,160);
			A_SpawnItemEx("BloodDrop2",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,128);
			A_SpawnItemEx("BloodDrop3",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,96);
		}
		Wait;
	}
}

class GibletL : GibletA
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_ScaleVelocity(frandom(0.5, 2.0));
		GIBL L random(2,4)
		{
			A_SpawnItemEx("BloodDrop1",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,160);
			A_SpawnItemEx("BloodDrop2",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,128);
			A_SpawnItemEx("BloodDrop3",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,96);
		}
		Wait;
	}
}

class GibletM : GibletA
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_ScaleVelocity(frandom(0.5, 2.0));
		GIBL M random(2,4)
		{
			A_SpawnItemEx("BloodDrop1",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,160);
			A_SpawnItemEx("BloodDrop2",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,128);
			A_SpawnItemEx("BloodDrop3",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,96);
		}
		Wait;
	}
}

class RandGiblet : GibletA
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(236,1,2,3,4,5,6,7,8,9,10,11,12,13);
		GIBL A 0 A_Jump(256,13);
		GIBL B 0 A_Jump(256,12);
		GIBL C 0 A_Jump(256,11);
		GIBL D 0 A_Jump(256,10);
		GIBL E 0 A_Jump(256,9);
		GIBL F 0 A_Jump(256,8);
		GIBL G 0 A_Jump(256,7);
		GIBL H 0 A_Jump(256,6);
		GIBL I 0 A_Jump(256,5);
		GIBL J 0 A_Jump(256,4);
		GIBL K 0 A_Jump(256,3);
		GIBL L 0 A_Jump(256,2);
		GIBL M 0;
		"----" A random(2,4)
		{
			A_SpawnItemEx("BloodDrop1",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,160);
			A_SpawnItemEx("BloodDrop2",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,128);
			A_SpawnItemEx("BloodDrop3",0,0,0,Vel.X,Vel.Y,Vel.Z+frandom(0,4),0,SXF_TRANSFERTRANSLATION,96);
		}
		Wait;
	}
}

class GibSpray: Actor
{
	Default
	{
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
		+THRUACTORS
	}
	States
	{
	Spawn:
		TNT1 A 0 A_SpawnItemEx("GibletA",frandom(-4,4),frandom(-4,4),frandom(-4,4),frandom(-2,2)+Vel.X/2,frandom(-2,2)+Vel.Y/2,frandom(0,4)+Vel.Z/2,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_SpawnItemEx("GibletB",frandom(-4,4),frandom(-4,4),frandom(-4,4),frandom(-2,2)+Vel.X/2,frandom(-2,2)+Vel.Y/2,frandom(0,4)+Vel.Z/2,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_SpawnItemEx("GibletC",frandom(-4,4),frandom(-4,4),frandom(-4,4),frandom(-2,2)+Vel.X/2,frandom(-2,2)+Vel.Y/2,frandom(0,4)+Vel.Z/2,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_SpawnItemEx("GibletD",frandom(-4,4),frandom(-4,4),frandom(-4,4),frandom(-2,2)+Vel.X/2,frandom(-2,2)+Vel.Y/2,frandom(0,4)+Vel.Z/2,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_SpawnItemEx("GibletE",frandom(-4,4),frandom(-4,4),frandom(-4,4),frandom(-2,2)+Vel.X/2,frandom(-2,2)+Vel.Y/2,frandom(0,4)+Vel.Z/2,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_SpawnItemEx("GibletF",frandom(-4,4),frandom(-4,4),frandom(-4,4),frandom(-2,2)+Vel.X/2,frandom(-2,2)+Vel.Y/2,frandom(0,4)+Vel.Z/2,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_SpawnItemEx("GibletG",frandom(-4,4),frandom(-4,4),frandom(-4,4),frandom(-2,2)+Vel.X/2,frandom(-2,2)+Vel.Y/2,frandom(0,4)+Vel.Z/2,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_SpawnItemEx("GibletH",frandom(-4,4),frandom(-4,4),frandom(-4,4),frandom(-2,2)+Vel.X/2,frandom(-2,2)+Vel.Y/2,frandom(0,4)+Vel.Z/2,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_SpawnItemEx("GibletI",frandom(-4,4),frandom(-4,4),frandom(-4,4),frandom(-2,2)+Vel.X/2,frandom(-2,2)+Vel.Y/2,frandom(0,4)+Vel.Z/2,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_SpawnItemEx("GibletJ",frandom(-4,4),frandom(-4,4),frandom(-4,4),frandom(-2,2)+Vel.X/2,frandom(-2,2)+Vel.Y/2,frandom(0,4)+Vel.Z/2,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_SpawnItemEx("GibletK",frandom(-4,4),frandom(-4,4),frandom(-4,4),frandom(-2,2)+Vel.X/2,frandom(-2,2)+Vel.Y/2,frandom(0,4)+Vel.Z/2,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_SpawnItemEx("GibletL",frandom(-4,4),frandom(-4,4),frandom(-4,4),frandom(-2,2)+Vel.X/2,frandom(-2,2)+Vel.Y/2,frandom(0,4)+Vel.Z/2,0,SXF_TRANSFERTRANSLATION);
		TNT1 A 0 A_SpawnItemEx("GibletM",frandom(-4,4),frandom(-4,4),frandom(-4,4),frandom(-2,2)+Vel.X/2,frandom(-2,2)+Vel.Y/2,frandom(0,4)+Vel.Z/2,0,SXF_TRANSFERTRANSLATION);
		Stop;
	}
}

////////////
//DROPLETS//
////////////

class BloodDrop1 : ParticleBase
{
	Default
	{
		DistanceCheck "boa_drop1_dist";
		Radius 4;
		Height 4;
		Speed 3;
		Scale 0.25;
		Friction 0.01;
		+BLOODLESSIMPACT
		+FLOORCLIP
		+FORCEXYBILLBOARD
		+MISSILE
		+MOVEWITHSECTOR
		+NOBLOCKMAP
		+NOTELEPORT
		+NOTONAUTOMAP
		+THRUACTORS
		+WINDTHRUST
		RenderStyle "Translucent";
		MaxStepHeight 1;
	}
	States
	{
	Spawn:
		DLUD A 1 NODELAY { alpha = boa_blood_alpha; }
		TNT1 A 0 A_ScaleVelocity(0.75);
		TNT1 A 0 A_ScaleVelocity(boa_blood_rand);
		TNT1 A 0 A_JumpIf(waterlevel > 0, "Underwater");
		Goto Fall;
	Fall:
		TNT1 A 0 A_JumpIf(Pos.Z <= floorz, "Death");
		DLUD ABCD 2;
		TNT1 A 0 A_JumpIf(waterlevel > 0, "Underwater");
		Loop;
	Death:
		TNT1 A 0 {bWindThrust = FALSE;}
		TNT1 AA 0 A_SpawnItemEx("BloodDrop3",0,0,4,frandom(-1.5,1.5),frandom(-1.5,1.5),frandom(0.0,0.5),0,SXF_TRANSFERTRANSLATION, 128);
		TNT1 A 0 A_SpawnItemEx("BloodDrop2",0,0,4,frandom(-1.5,1.5),frandom(-1.5,1.5),frandom(0.0,0.5),0,SXF_TRANSFERTRANSLATION, 128);
		TNT1 A 0 A_JumpIf(ceilingz - Pos.Z < 8.0, "Ceil");
		TNT1 A 0 A_JumpIf(Pos.Z > floorz + 8.0, "Goodbye");
		TNT1 A 0 A_JumpIf(CallACS("LiquidCheck"),"Fog");
		TNT1 A 0 A_SetAngle(frandom(0.0,360.0));
		TNT1 A 0 A_Jump(128, 2);
		SPLT F 1 A_SetScale(1.2 * boa_blood_size,0.1);
		Goto Splat;
		SPLT G 1 A_SetScale(1.2 * boa_blood_size,0.1);
	Splat:
		"####" "#" 1 A_SetScale(1.7 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(2.4 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(3.3 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(frandom(4.66,6.0) * boa_blood_size,0.1);
		"####" "#" 0 A_QueueCorpse;
		"####" "#" -1;
	Underwater:
		TNT1 A 0 A_SpawnItemEx("UWBloodFog",0,0,0,Vel.X/3,Vel.Y/3,Vel.Z/3,0,SXF_TRANSFERTRANSLATION);
		Stop;
	Goodbye:
		TNT1 A 0;
		Stop;
	Ceil:
		TNT1 A 0 A_JumpIf(CallACS("SkyCheck")==0,1);
		Stop;
		TNT1 A 0 A_SpawnItemEx("CeilDripper",0,0,10.0,0,0,0,0,SXF_TRANSFERTRANSLATION);
		Stop;
	Fog:
		TNT1 A 0 A_SpawnItemEx("BloodFog",0,0,0,0,0,0,0,SXF_TRANSFERTRANSLATION);
		Stop;
	Cleanup:
		"####" "#" 1 A_FadeOut(0.01,FTF_REMOVE|FTF_CLAMP);
		Loop;
	}
}

class DecoDroplet : BloodDrop1
{
	States
	{
	Death:
		TNT1 A 0 {bWindThrust = FALSE;}
		TNT1 AA 0 A_SpawnItemEx("DecoDrop3",0,0,4,frandom(-1.5,1.5),frandom(-1.5,1.5),frandom(0.0,0.5),0,SXF_TRANSFERTRANSLATION, 128);
		TNT1 A 0 A_SpawnItemEx("DecoDrop2",0,0,4,frandom(-1.5,1.5),frandom(-1.5,1.5),frandom(0.0,0.5),0,SXF_TRANSFERTRANSLATION, 128);
		SPLT A 1;
		TNT1 A 0 A_JumpIf(Pos.Z > floorz + 8.0, "Goodbye");
		TNT1 A 0 A_JumpIf(CallACS("LiquidCheck"),"Fog");
		TNT1 A 0 A_SetAngle(frandom(0.0,360.0));
		TNT1 A 0 A_Jump(128, 2);
		SPLT F 1 A_SetScale(1.2 * boa_blood_size,0.1);
		Goto Splat;
		SPLT G 1 A_SetScale(1.2 * boa_blood_size,0.1);
	Splat:
		"####" "#" 1 A_SetScale(1.7 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(2.4 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(3.3 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(frandom(4.66,6.0) * boa_blood_size,0.1);
		"####" "#" 0 A_QueueCorpse;
		Goto Cleanup;
	Fog:
		TNT1 A 0 A_SpawnItemEx("DecoFog",0,0,0,0,0,0,0,SXF_TRANSFERTRANSLATION);
		Stop;
	}
}

class BloodDrop2 : BloodDrop1
{
	Default
	{
		DistanceCheck "boa_drop2_dist";
		Radius 3;
		Height 3;
		Scale 0.18;
		Gravity 0.9;
		Friction 0.02;
		+DONTSPLASH
	}
	States
	{
	Spawn:
		DLUD A 1 NODELAY { alpha = boa_blood_alpha; }
		TNT1 A 0 A_ScaleVelocity(boa_blood_rand);
		TNT1 A 0 A_JumpIf(waterlevel > 0, "Underwater");
		Goto Fall;
	Fall:
		TNT1 A 0 A_JumpIf(Pos.Z <= floorz, "Death");
		DLUD ABCD 2;
		TNT1 A 0 A_JumpIf(waterlevel > 0, "Underwater");
		Loop;
	Death:
		TNT1 A 0 {bWindThrust = FALSE;}
		TNT1 AA 0 A_SpawnItemEx("BloodDrop3",0,0,4,frandom(-1.0,1.0),frandom(-1.0,1.0),frandom(0.0,0.5),0,SXF_TRANSFERTRANSLATION, 128);
		TNT1 A 0 A_JumpIf(ceilingz - Pos.Z < 6.0, "Ceil");
		TNT1 A 0 A_JumpIf(Pos.Z > floorz + 8.0, "Goodbye");
		TNT1 A 0 A_JumpIf(CallACS("LiquidCheck"),"Fog");
		TNT1 A 0 A_SetAngle(frandom(0.0,360.0));
		TNT1 A 0 A_Jump(128, 2);
		SPLT F 1 A_SetScale(0.69 * boa_blood_size,0.1);
		Goto Splat;
		SPLT G 1 A_SetScale(0.69 * boa_blood_size,0.1);
	Splat:
		"####" "#" 1 A_SetScale(0.97 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(1.36 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(1.9 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(frandom(2.66,4.0) * boa_blood_size,0.1);
		"####" "#" 0 A_QueueCorpse;
		"####" "#" -1;
	Underwater:
		TNT1 A 0;
		Stop;
	Ceil:
		TNT1 A 0 A_JumpIf(CallACS("SkyCheck")==0,1);
		Stop;
		TNT1 A 0 A_SpawnItemEx("CeilDrip2",0,0,10.0,0,0,0,0,SXF_TRANSFERTRANSLATION);
		Stop;
	Fog:
		TNT1 A 0 A_SpawnItemEx("BloodFog2",0,0,0,0,0,0,0,SXF_TRANSFERTRANSLATION);
		Stop;
	}
}

class DecoDrop2 : BloodDrop2
{
	Default
	{
		Speed 2;
	}
	States
	{
	Death:
		TNT1 A 0 {bWindThrust = FALSE;}
		TNT1 AA 0 A_SpawnItemEx("DecoDrop3",0,0,4,frandom(-1.0,1.0),frandom(-1.0,1.0),frandom(0.0,0.5),0,SXF_TRANSFERTRANSLATION, 128);
		SPLT A 1;
		TNT1 A 0 A_JumpIf(Pos.Z > floorz + 8.0, "Goodbye");
		TNT1 A 0 A_JumpIf(CallACS("LiquidCheck"),"Fog");

		TNT1 A 0 A_SetAngle(frandom(0.0,360.0));
		TNT1 A 0 A_Jump(128, 2);
		SPLT F 1 A_SetScale(0.69 * boa_blood_size,0.1);
		Goto Splat;
		SPLT G 1 A_SetScale(0.69 * boa_blood_size,0.1);
	Splat:
		"####" "#" 1 A_SetScale(0.97 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(1.36 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(1.9 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(frandom(2.66,4.0) * boa_blood_size,0.1);
		"####" "#" 0 A_QueueCorpse;
		Goto Cleanup;
	Fog:
		TNT1 A 0 A_SpawnItemEx("DecoFog2",0,0,0,0,0,0,0,SXF_TRANSFERTRANSLATION);
		Stop;
	}
}

class BloodDrop3 : BloodDrop1
{
	Default
	{
		DistanceCheck "boa_drop3_dist";
		Radius 2;
		Height 2;
		Scale 0.13;
		Gravity 0.81;
		Friction 0.04;
		+DONTSPLASH
	}
	States
	{
	Spawn:
		DLUD A 1 NODELAY { alpha = boa_blood_alpha; }
		TNT1 A 0 A_ScaleVelocity(1.25);
		TNT1 A 0 A_ScaleVelocity(boa_blood_rand);
		TNT1 A 0 A_JumpIf(waterlevel > 0, "Underwater");
		Goto Fall;
	Fall:
		TNT1 A 0 A_JumpIf(Pos.Z <= floorz, "Death");
		DLUD ABCD 2;
		TNT1 A 0 A_JumpIf(waterlevel > 0, "Underwater");
		Loop;
	Death:
		TNT1 A 0 {bWindThrust = FALSE;}
		TNT1 A 0 A_JumpIf(ceilingz - Pos.Z < 4.0, "Ceil");
		TNT1 A 0 A_JumpIf(Pos.Z > floorz + 8.0, "Goodbye");
		TNT1 A 0 A_JumpIf(CallACS("LiquidCheck"),"Fog");
		TNT1 A 0 A_SetAngle(frandom(0.0,360.0));
		TNT1 A 0 A_Jump(128, 2);
		SPLT F 1 A_SetScale(0.17 * boa_blood_size,0.1);
		Goto Splat;
		SPLT G 1 A_SetScale(0.17 * boa_blood_size,0.1);
	Splat:
		"####" "#" 1 A_SetScale(0.24 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(0.34 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(0.47 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(frandom(0.66,2.0) * boa_blood_size,0.1);
		"####" "#" 0 A_QueueCorpse;
		"####" "#" -1;
	Underwater:
		TNT1 A 0;
		Stop;
	Ceil:
		TNT1 A 0 A_JumpIf(CallACS("SkyCheck")==0,1);
		Stop;
		TNT1 A 0 A_SpawnItemEx("CeilDrip3",0,0,10.0,0,0,0,0,SXF_TRANSFERTRANSLATION);
		Stop;
	Fog:
		TNT1 A 0 A_SpawnItemEx("BloodFog3",0,0,0,0,0,0,0,SXF_TRANSFERTRANSLATION);
		Stop;
	}
}

class DecoDrop3 : BloodDrop3
{
	Default
	{
		Speed 2;
	}
	States
	{
	Death:
		TNT1 A 0 {bWindThrust = FALSE;}
		SPLT A 1;
		TNT1 A 0 A_JumpIf(Pos.Z > floorz + 8.0, "Goodbye");
		TNT1 A 0 A_JumpIf(CallACS("LiquidCheck"),"Fog");
		TNT1 A 0 A_SetAngle(frandom(0.0,360.0));
		TNT1 A 0 A_Jump(128, 2);
		SPLT F 1 A_SetScale(0.17 * boa_blood_size,0.1);
		Goto Splat;
		SPLT G 1 A_SetScale(0.17 * boa_blood_size,0.1);
	Splat:
		"####" "#" 1 A_SetScale(0.24 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(0.34 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(0.47 * boa_blood_size,0.1);
		"####" "#" 1 A_SetScale(frandom(0.66,2.0) * boa_blood_size,0.1);
		"####" "#" 0 A_QueueCorpse;
		Goto Cleanup;
	Fog:
		TNT1 A 0 A_SpawnItemEx("DecoFog3",0,0,0,0,0,0,0,SXF_TRANSFERTRANSLATION);
		Stop;
	}
}

class ExcessDroplet : BloodDrop3
{
	Default
	{
		DistanceCheck "boa_drop3_dist";
		Radius 2;
		Height 2;
		Scale 0.09;
		Gravity 0.58;
		+DONTSPLASH
	}
	States
	{
	Spawn:
		DLUD A 1 NODELAY { alpha = boa_blood_alpha; }
		TNT1 A 0 A_ScaleVelocity(1.5);
		TNT1 A 0 A_ScaleVelocity(boa_blood_rand);
		TNT1 A 0 A_JumpIf(waterlevel > 0, "Underwater");
		Goto Fall;
	Fall:
		TNT1 A 0 A_JumpIf(Pos.Z <= floorz, "Death");
		DLUD ABCD 2;
		TNT1 A 0 A_JumpIf(waterlevel > 0, "Underwater");
		Loop;
	Death:
		TNT1 A 0;
		Stop;
	Underwater:
		TNT1 A 0;
		Stop;
	}
}

///////////
//SQUIRTS//
///////////

class BloodHitPuff: Actor
{
	int user_force;
	int user_angmom;
	Default
	{
		Radius 1;
		Height 1;
		Scale 0.75;
		+DONTTHRUST
		+FORCEXYBILLBOARD
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
		+THRUACTORS
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY
		{
			user_force = (int) (frandom(6.0,12.0));
			user_angmom = (int) (frandom(-4.5,4.5));
			A_SetPitch(frandom(-45.0,90.0));
			A_StartSound("blood/hit",0,0,0.3);
			Scale.X *= randompick(1,-1);
		}
		BLPF AABBCCDDEE 1
		{
			A_SpawnItemEx("BloodDrop1",0,0,4,(cos(angle)*user_force),(sin(angle)*user_force),(sin(pitch)*user_force),0,SXF_TRANSFERTRANSLATION|SXF_ABSOLUTEVELOCITY, (int) (224-boa_blood_amt*48));
			angle += user_angmom;
			A_SpawnItemEx("BloodDrop2",0,0,4,(cos(angle)*user_force),(sin(angle)*user_force),(sin(pitch)*user_force),0,SXF_TRANSFERTRANSLATION|SXF_ABSOLUTEVELOCITY, (int) (160-boa_blood_amt*48));
			angle += user_angmom;
			A_SpawnItemEx("BloodDrop3",0,0,4,(cos(angle)*user_force),(sin(angle)*user_force),(sin(pitch)*user_force),0,SXF_TRANSFERTRANSLATION|SXF_ABSOLUTEVELOCITY, (int) (96-boa_blood_amt*48));
			angle += user_angmom;
			A_SpawnItemEx("ExcessDroplet",0,0,4,(cos(angle)*user_force),(sin(angle)*user_force),(sin(pitch)*user_force),0,SXF_TRANSFERTRANSLATION|SXF_ABSOLUTEVELOCITY, (int) (256-boa_blood_amt*64));
			angle += user_angmom;
			user_force = (int) (0.8 * user_force);
		}
		TNT1 A 0;
		Stop;
	}
}

class BloodHitPuffMid : BloodHitPuff
{
	Default
	{
		Scale 0.5;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY
		{
			user_force = (int) (frandom(6.0,12.0));
			user_angmom = (int) (frandom(-6.0,6.0));
			A_SetPitch(frandom(-45.0,90.0));
			A_StartSound("blood/hit",0,0,0.2);
			Scale.X *= randompick(1,-1);
		}
		BLPF AABBCCDDEE 1
		{
			A_SpawnItemEx("BloodDrop2",0,0,4,(cos(angle)*user_force),(sin(angle)*user_force),(sin(pitch)*user_force),0,SXF_TRANSFERTRANSLATION|SXF_ABSOLUTEVELOCITY, (int) (160-boa_blood_amt*48));
			angle += user_angmom;
			A_SpawnItemEx("BloodDrop3",0,0,4,(cos(angle)*user_force),(sin(angle)*user_force),(sin(pitch)*user_force),0,SXF_TRANSFERTRANSLATION|SXF_ABSOLUTEVELOCITY, (int) (96-boa_blood_amt*48));
			angle += user_angmom;
			A_SpawnItemEx("ExcessDroplet",0,0,4,(cos(angle)*user_force),(sin(angle)*user_force),(sin(pitch)*user_force),0,SXF_TRANSFERTRANSLATION|SXF_ABSOLUTEVELOCITY, (int) (256-boa_blood_amt*64));
			angle += user_angmom;
			user_force = (int) (0.8 * user_force);
		}
		TNT1 A 0;
		Stop;
	}
}

class BloodHitPuffSmall : BloodHitPuff
{
	Default
	{
		Scale 0.25;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY
		{
			user_force = (int) (frandom(6.0,12.0));
			user_angmom = (int) (frandom(-9.0,9.0));
			A_SetPitch(frandom(-45.0,90.0));
			A_StartSound("blood/hit",0,0,0.1);
			Scale.X *= randompick(1,-1);
		}
		BLPF AABBCCDDEE 1
		{
			A_SpawnItemEx("BloodDrop3",0,0,4,(cos(angle)*user_force),(sin(angle)*user_force),(sin(pitch)*user_force),0,SXF_TRANSFERTRANSLATION|SXF_ABSOLUTEVELOCITY, (int) (96-boa_blood_amt*48));
			angle += user_angmom;
			A_SpawnItemEx("ExcessDroplet",0,0,4,(cos(angle)*user_force),(sin(angle)*user_force),(sin(pitch)*user_force),0,SXF_TRANSFERTRANSLATION|SXF_ABSOLUTEVELOCITY, (int) (256-boa_blood_amt*64));
			angle += user_angmom;
			user_force = (int) (0.8 * user_force);
		}
		TNT1 A 0;
		Stop;
	}
}

class BloodSquirt: Actor
{
	Default
	{
		Mass 5;
		+ALLOWPARTICLES
		+DONTTHRUST
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
		+PUFFGETSOWNER
		+THRUACTORS
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,"Spray");
		TNT1 A 0 A_Jump(256,"Mid");
		TNT1 A 0
		{
			A_FaceTarget(0,0,0,0,FAF_MIDDLE);
			A_Warp(AAPTR_DEFAULT,cos(angle)*8,sin(angle)*8,sin(pitch)*8,0,WARPF_ABSOLUTEOFFSET);
			A_SpawnItemEx("BloodHitPuffSmall",0,0,0,0,0,0,0,SXF_TRANSFERTRANSLATION);
		}
		Stop;
	Spray:
		TNT1 A 0
		{
			A_FaceTarget(0,0,0,0,FAF_MIDDLE);
			A_Warp(AAPTR_DEFAULT,cos(angle)*8,sin(angle)*8,sin(pitch)*8,0,WARPF_ABSOLUTEOFFSET);
			A_SpawnItemEx("BloodHitPuff",0,0,0,0,0,0,0,SXF_TRANSFERTRANSLATION, (int) (128-boa_blood_amt*64));
		}
		Stop;
	Mid:
		TNT1 A 0
		{
			A_FaceTarget(0,0,0,0,FAF_MIDDLE);
			A_Warp(AAPTR_DEFAULT,cos(angle)*8,sin(angle)*8,sin(pitch)*8,0,WARPF_ABSOLUTEOFFSET);
			A_SpawnItemEx("BloodHitPuffMid",0,0,0,0,0,0,0,SXF_TRANSFERTRANSLATION, (int) (64-boa_blood_amt*32));
		}
		Stop;
	}
}

////////////
//CEILINGS//
////////////

class CeilingDroplet : DecoDroplet
{
	Default
	{
		Height 1;
		Scale 0.1;
		-MISSILE
		+NOGRAVITY
	}
	States
	{
	Spawn:
		TNT1 A 1 NODELAY { alpha = boa_blood_alpha; }
		DLUD C 6
		{
			A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
			A_SetScale(0.4,0.05);
		}
		DLUD C 5
		{
			A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
			A_SetScale(0.37,0.1);
		}
		DLUD C 4
		{
			A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
			A_SetScale(0.33,0.2);
		}
		DLUD C 3
		{
			A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
			A_SetScale(0.3,0.3);
		}
		DLUD C 2
		{
			A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
			A_SetScale(0.28,0.4);
		}
		TNT1 A 0 {bNoGravity = FALSE;}
		TNT1 A 0 A_SetScale(0.25,0.5);
		DLUD ABCD 2;
		TNT1 A 0 {bMissile = TRUE;}
		Goto Fall;
	Fall:
		TNT1 A 0 A_JumpIf(Pos.Z <= floorz, "Death");
		DLUD ABCD 2;
		TNT1 A 0 A_JumpIf(waterlevel > 0, "Underwater");
		Loop;
	}
}

class CeilingDrop2 : DecoDrop2
{
	Default
	{
		Height 1;
		Scale 0.1;
		-MISSILE
		+NOGRAVITY
	}
	States
	{
	Spawn:
		TNT1 A 1 NODELAY { alpha = boa_blood_alpha; }
		DLUD C 6
		{
			A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
			A_SetScale(0.32,0.05);
		}
		DLUD C 5
		{
			A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
			A_SetScale(0.29,0.08);
		}
		DLUD C 4
		{
			A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
			A_SetScale(0.27,0.15);
		}
		DLUD C 3
		{
			A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
			A_SetScale(0.24,0.23);
		}
		DLUD C 2
		{
			A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
			A_SetScale(0.22,0.3);
		}
		TNT1 A 0 {bNoGravity = FALSE;}
		TNT1 A 0 A_SetScale(0.2,0.4);
		DLUD ABCD 2;
		TNT1 A 0 {bMissile = TRUE;}
	Fall:
		TNT1 A 0 A_JumpIf(Pos.Z <= floorz, "Death");
		DLUD ABCD 2;
		TNT1 A 0 A_JumpIf(waterlevel > 0, "Underwater");
		Loop;
	}
}

class CeilingDrop3 : DecoDrop3
{
	Default
	{
		Height 1;
		Scale 0.1;
		-MISSILE
		+NOGRAVITY
	}
	States
	{
	Spawn:
		TNT1 A 1 NODELAY { alpha = boa_blood_alpha; }
		DLUD C 6
		{
			A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
			A_SetScale(0.24,0.05);
		}
		DLUD C 5
		{
			A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
			A_SetScale(0.22,0.09);
		}
		DLUD C 4
		{
			A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
			A_SetScale(0.2,0.12);
		}
		DLUD C 3
		{
			A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
			A_SetScale(0.18,0.16);
		}
		DLUD C 2
		{
			A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
			A_SetScale(0.17,0.2);
		}
		TNT1 A 0 {bNoGravity = FALSE;}
		TNT1 A 0 A_SetScale(0.15,0.3);
		DLUD ABCD 2;
		TNT1 A 0 {bMissile = TRUE;}
	Fall:
		TNT1 A 0 A_JumpIf(Pos.Z <= floorz, "Death");
		DLUD ABCD 2;
		TNT1 A 0 A_JumpIf(waterlevel > 0, "Underwater");
		Loop;
	}
}

class CeilDripper : ParticleBase
{
	Default
	{
		DistanceCheck "boa_drop1_dist";
		Radius 1;
		Height 1;
		Scale 0.5;
		+NOGRAVITY
		+NOTONAUTOMAP
		+SPAWNCEILING
		+THRUACTORS
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
		TNT1 A 0 A_QueueCorpse;
		SPLT F 0 A_Jump(128, 2);
		SPLT G 0;
		"####" "#" 0 A_SetAngle(frandom(0.0,360.0));
		"####" "#" 1 A_SetScale(1.3 * boa_blood_size,1);
		"####" "#" 1 A_SetScale(1.82 * boa_blood_size,1);
		"####" "#" 1 A_SetScale(2.55 * boa_blood_size,1);
		"####" "#" 1 A_SetScale(3.57 * boa_blood_size,1);
		"####" "#" 1 A_SetScale(frandom(5.0,6.0) * boa_blood_size,1);
		Goto Drippy;
	Drippy:
		"####" "######" 1 A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
		"####" "#" 0 A_Jump(254, "Drippy");
		"####" "#" 0 A_SpawnItemEx("CeilingDrop2", 0, 0, 4, 0, 0, 0, 0, SXF_TRANSFERTRANSLATION);
		Goto Drippy;
	}
}

class CeilDrip2 : CeilDripper
{
	Default
	{
		DistanceCheck "boa_drop2_dist";
		Scale 0.33;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
		TNT1 A 0 A_QueueCorpse;
		SPLT F 0 A_Jump(128, 2);
		SPLT G 0;
		"####" "#" 0 A_SetAngle(frandom(0.0,360.0));
		"####" "#" 1 A_SetScale(0.78 * boa_blood_size,1);
		"####" "#" 1 A_SetScale(1.09 * boa_blood_size,1);
		"####" "#" 1 A_SetScale(1.53 * boa_blood_size,1);
		"####" "#" 1 A_SetScale(2.14 * boa_blood_size,1);
		"####" "#" 1 A_SetScale(frandom(3.0,4.0) * boa_blood_size,1);
		Goto Drippy;
	Drippy:
		"####" "#########" 1 A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
		"####" "#" 0 A_Jump(254, "Drippy");
		"####" "#" 0 A_SpawnItemEx("CeilingDrop3", 0, 0, 4, 0, 0, 0, 0, SXF_TRANSFERTRANSLATION);
		Goto Drippy;
	}
}

class CeilDrip3 : CeilDripper
{
	Default
	{
		DistanceCheck "boa_drop3_dist";
		Scale 0.17;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
		TNT1 A 0 A_QueueCorpse;
		SPLT F 0 A_Jump(128, 2);
		SPLT G 0;
		"####" "#" 0 A_SetAngle(frandom(0.0,360.0));
		"####" "#" 1 A_SetScale(0.26 * boa_blood_size,1);
		"####" "#" 1 A_SetScale(0.36 * boa_blood_size,1);
		"####" "#" 1 A_SetScale(0.51 * boa_blood_size,1);
		"####" "#" 1 A_SetScale(0.71 * boa_blood_size,1);
		"####" "#" 1 A_SetScale(frandom(1.0,2.0) * boa_blood_size,1);
		Goto Drippy;
	Drippy:
		"####" "############" 1 A_Warp(AAPTR_DEFAULT,0,0,ceilingz - Pos.Z - 1);
		loop;
	}
}

///////////
//LIQUIDS//
///////////

class BloodFog : ParticleBase
{
	double user_size;
	double user_angle;
	double user_rot;
	Default
	{
		Radius 4;
		Height 5;
		Gravity 1;
		Speed 0.12;
		RenderStyle "Translucent";
		Alpha 0;
		+CANTLEAVEFLOORPIC
		+MOVEWITHSECTOR
		+NOBLOCKMAP
		+NOTELEPORT
		+NOTONAUTOMAP
		+SLIDESONWALLS
		MaxStepHeight 1;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_QueueCorpse;
		TNT1 A 0
		{
			user_size = frandom(0.05,0.1);
			angle = frandom(0,360);
			user_angle = angle;
			user_rot = frandom(-1.8,1.8);
		}
		Goto Pool;
	Pool:
		BFOG A 1 A_SetScale(user_size, 1.0);
		TNT1 A 0 A_Wander;
		TNT1 A 0
		{
			user_size += (3.0 - user_size) / 300;
			alpha += (0.2 - alpha) / 300;
			user_angle += user_rot;
			angle = user_angle;
		}
		TNT1 A 0 A_JumpIf(alpha < 0.15, "Pool");
		Goto Done;
	Done:
		BFOG A 1 A_SetScale(user_size, 1.0);
		TNT1 A 0 A_Wander;
		TNT1 A 0 A_FadeOut(0.0003,FTF_REMOVE|FTF_CLAMP);
		TNT1 A 0
		{
			user_size += (3.0 - user_size) / 300;
			user_angle += user_rot;
			angle = user_angle;
		}
		Loop;
	}
}

class DecoFog : BloodFog
{
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0
		{
			user_size = frandom(0.05,0.1);
			angle = frandom(0,360);
			user_angle = angle;
			user_rot = frandom(-1.8,1.8);
		}
		Goto Pool;
	Pool:
		BFOG A 1 A_SetScale(user_size, 1.0);
		TNT1 A 0 A_Wander;
		TNT1 A 0
		{
			user_size += (3.0 - user_size) / 300;
			alpha += (0.4 - alpha) / 300;
			user_angle += user_rot;
			angle = user_angle;
		}
		TNT1 A 0 A_JumpIf(alpha < 0.15, "Pool");
		Goto Done;
	Done:
		BFOG A 1 A_SetScale(user_size, 1.0);
		TNT1 A 0 A_Wander;
		TNT1 A 0 A_FadeOut(0.003,FTF_REMOVE|FTF_CLAMP);
		TNT1 A 0
		{
			user_size += (3.0 - user_size) / 300;
			user_angle += user_rot;
			angle = user_angle;
		}
		Loop;
	}
}

class BloodFog2 : BloodFog
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_QueueCorpse;
		TNT1 A 0
		{
			user_size = frandom(0.025,0.05);
			angle = frandom(0,360);
			user_angle = angle;
			user_rot = frandom(-1.8,1.8);
		}
		Goto Pool;
	Pool:
		BFOG A 1 A_SetScale(user_size, 1.0);
		TNT1 A 0 A_Wander;
		TNT1 A 0
		{
			user_size += (2.0 - user_size) / 200;
			alpha += (0.2 - alpha) / 200;
			user_angle += user_rot;
			angle = user_angle;
		}
		TNT1 A 0 A_JumpIf(alpha < 0.15, "Pool");
		Goto Done;
	Done:
		BFOG A 1 A_SetScale(user_size, 1.0);
		TNT1 A 0 A_Wander;
		TNT1 A 0 A_FadeOut(0.0006,FTF_REMOVE|FTF_CLAMP);
		TNT1 A 0
		{
			user_size += (2.0 - user_size) / 200;
			user_angle += user_rot;
			angle = user_angle;
		}
		Loop;
	}
}

class DecoFog2 : BloodFog2
{
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0
		{
			user_size = frandom(0.025,0.05);
			angle = frandom(0,360);
			user_angle = angle;
			user_rot = frandom(-1.8,1.8);
		}
		Goto Pool;
	Pool:
		BFOG A 1 A_SetScale(user_size, 1.0);
		TNT1 A 0 A_Wander;
		TNT1 A 0
		{
			user_size += (2.0 - user_size) / 200;
			alpha += (0.4 - alpha) / 200;
			user_angle += user_rot;
			angle = user_angle;
		}
		TNT1 A 0 A_JumpIf(alpha < 0.15, "Pool");
		Goto Done;
	Done:
		BFOG A 1 A_SetScale(user_size, 1.0);
		TNT1 A 0 A_Wander;
		TNT1 A 0 A_FadeOut(0.002,FTF_REMOVE|FTF_CLAMP);
		TNT1 A 0
		{
			user_size += (2.0 - user_size) / 200;
			user_angle += user_rot;
			angle = user_angle;
		}
		Loop;
	}
}

class BloodFog3 : BloodFog
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_QueueCorpse;
		TNT1 A 0
		{
			user_size = frandom(0.0125,0.025);
			angle = frandom(0,360);
			user_angle = angle;
			user_rot = frandom(-1.8,1.8);
		}
		Goto Pool;
	Pool:
		BFOG A 1 A_SetScale(user_size, 1.0);
		TNT1 A 0 A_Wander;
		TNT1 A 0
		{
			user_size += (1.0 - user_size) / 100;
			alpha += (0.2 - alpha) / 100;
			user_angle += user_rot;
			angle = user_angle;
		}
		TNT1 A 0 A_JumpIf(alpha < 0.15, "Pool");
		Goto Done;
	Done:
		BFOG A 1 A_SetScale(user_size, 1.0);
		TNT1 A 0 A_Wander;
		TNT1 A 0 A_FadeOut(0.001,FTF_REMOVE|FTF_CLAMP);
		TNT1 A 0
		{
			user_size += (1.0 - user_size) / 100;
			user_angle += user_rot;
			angle = user_angle;
		}
		Loop;
	}
}

class DecoFog3 : BloodFog3
{
	States
	{
	Spawn:
		TNT1 A 0;
		TNT1 A 0
		{
			user_size = frandom(0.0125,0.025);
			angle = frandom(0,360);
			user_angle = angle;
			user_rot = frandom(-1.8,1.8);
		}
		Goto Pool;
	Pool:
		BFOG A 1 A_SetScale(user_size, 1.0);
		TNT1 A 0 A_Wander;
		TNT1 A 0
		{
			user_size += (1.0 - user_size) / 100;
			alpha += (0.4 - alpha) / 100;
			user_angle += user_rot;
			angle = user_angle;
		}
		TNT1 A 0 A_JumpIf(alpha < 0.15, "Pool");
		Goto Done;
	Done:
		BFOG A 1 A_SetScale(user_size, 1.0);
		TNT1 A 0 A_Wander;
		TNT1 A 0 A_FadeOut(0.003,FTF_REMOVE|FTF_CLAMP);
		TNT1 A 0
		{
			user_size += (1.0 - user_size) / 100;
			user_angle += user_rot;
			angle = user_angle;
		}
		Loop;
	}
}

class UWBloodFog : ParticleBase
{
	Default
	{
		Radius 4;
		Height 5;
		Speed 0.35;
		Scale 0.25;
		RenderStyle "Translucent";
		Alpha 0.5;
		+FORCEXYBILLBOARD
		+MOVEWITHSECTOR
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
		+NOTONAUTOMAP
		+SLIDESONWALLS
		MaxStepHeight 1;
	}
	States
	{
	Spawn:
		HITB A 1 NODELAY A_ChangeVelocity(frandom(-2.0,2.0),frandom(-2.0,2.0),frandom(-2.0,2.0));
		HITB A 1 A_SetScale(Scale.X + 0.05);
		HITB A 1;
		HITB A 1 A_SetScale(Scale.X + 0.25);
		HITB A 1;
		HITB A 2 A_SetScale(Scale.X + 0.50);
		HITB A 2;
		HITB A 2 A_SetScale(Scale.X + 0.75);
		HITB A 2;
		HITB A 2 A_SetScale(Scale.X + 1.0);
	Cleanup:
		HITB A 0 A_JumpIf(waterlevel < 2, "Abort");
		TNT1 A 0 A_FadeOut(0.0125,true);
		TNT1 A 0 A_SetScale(Scale.X + 0.05);
		HITB A 3 A_Wander;
		Loop;
	Abort:
		"----" A 1 A_FadeOut(0.1,true);
		Loop;
	}
}