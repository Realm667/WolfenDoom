/*
 * Copyright (c) 2016-2021 Tormentor667, Ozymandias81, AFADoomer
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

const SPLASHES_FLAGS = SXF_CLIENTSIDE | SXF_TRANSFERRENDERSTYLE | SXF_TRANSFERSTENCILCOL;

class WaterSplashGeneratorNormal : EffectSpawner
{
	int spawncount;

	Default
	{
		//$Category Special Effects (BoA)
		//$Title Water Splash Generator (normal; Renderstyle, Stencilcolor are taken into account)
		//$Color 12
		//$Sprite WTSAA0
		//$Arg3 "Sound"
		//$Arg3Type 11
		//$Arg3Enum { 0 = "Yes"; 1 = "No"; }
		+CLIENTSIDEONLY
		+DONTSPLASH
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		EffectSpawner.Range 2048;
		EffectSpawner.SwitchVar "boa_splashswitch";
		+EffectSpawner.ALLOWTICKDELAY
		+EffectSpawner.DONTCULL
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 0 { if (!args[3]) { A_StartSound("water/lap", CHAN_7, 0, 1.0); } }
		Active.Loop:
			TNT1 A 2 SpawnEffect();
			Loop;
		Inactive:
			TNT1 A -1;
			Loop;
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		// A_SpawnItemEx("WaterSplashObject", 0, 0, 0, 0, 0, 0, 0, SPLASHES_FLAGS);
		// boashaders.txt:L2060-L2082
		static const double rolls[] = { 2.0, 3.0, 2.5, 3.5 };

		int variant = Random[Splash](0, 3);

		TextureID splash = TexMan.CheckForTexture(String.Format("WTS%cA0", 0x41 + variant));

		A_SpawnParticleEx(
			"FFFFFF", // color1
			splash, // texture
			GetRenderStyle(), // style (SXF_TRANSFERRENDERSTYLE)
			SPF_RELATIVE | SPF_ROLL, // flags
			32, // lifetime (0.8 / 0.025)
			153.6, // size (0.3 * 512.)
			FRandom[Splash](0.0, 360.0), // angle
			0.0, // xoff
			0.0, // yoff
			0.0, // zoff
			Random[Splash](0, 1), // velx
			0.0, // vely
			FRandom[Splash](1.0, 2.0), // velz
			0.0, // accelx
			0.0, // accely
			0.0, // accelz (-NOGRAVITY does not work for SimpleActors and particle actors)
			0.8, // startalphaf
			0.025, // fadestepf
			5.12, // sizestep (512 * 0.01)
			0.0, // startroll
			rolls[variant], // rollvel
			0.0 // rollacc
		);


		if (spawncount++ > 7) { SetStateLabel("Inactive"); }
	}
}

// Kept for savegame compatibility - Talon1024 and N00b
class WaterSplashObject: ParticleBase
{
	Default
	{
		Mass 100;
		Gravity 6.0;
		Alpha 0.8;
		Scale 0.3;
		-NOGRAVITY
		+CLIENTSIDEONLY
		+DONTSPLASH
		+NOINTERACTION
	}

	States
	{
		Spawn:
			WTSA A 0;
		Spawn.Loop:
			"####" A 1 A_SetScale(Scale.x + 0.01, Scale.y + 0.01);
			"####" A 0 A_FadeOut(0.025, FTF_REMOVE);
			Loop;
		Sprites:
			WTSA A 0;
			WTSB A 0;
			WTSC A 0;
			WTSD A 0;
	}

	override void PostBeginPlay()
	{
		vel = (RotateVector((Random[Splash](0, 1), 0), FRandom[Splash](0.0, 360.0)), FRandom[Splash](1.0, 2.0));

		int newsprite = GetSpriteIndex(String.Format("WTS%c", Random[Splash](65, 68)));
		if (newsprite > 0) { sprite = newsprite; }

		Super.PostBeginPlay();
	}
}

class WaterSplashCloud : ParticleBase
{
	Default
	{
	Mass 100;
	Gravity 6.0;
	Alpha 0.0;
	Scale 0.7;
	-NOGRAVITY
	+CLIENTSIDEONLY
	+DONTSPLASH
	+NOINTERACTION
	}
	States
	{
	Spawn:
		WTFG A 0 NODELAY;
		"####" A 0 ThrustThingZ(0,random[Splash](1,4),0,0);
		"####" A 0 ThrustThing(Random[Splash](0,255),random[Splash](0,1),0,0);
		"####" AAAAAAAAA 2 A_FadeIn(.03);
		"####" A 2 A_SetScale(Scale.X+0.01, Scale.Y+0.01);
		"####" A 0 A_FadeOut(.03,FTF_REMOVE);
		Goto Spawn+12;
	}
}

class WaterSplashGeneratorNormalLooping : WaterSplashGeneratorNormal
{
	bool what;

	Default
	{
		//$Title Water Splash Generator (normal, looping; Renderstyle, Stencilcolor are taken into account)
		-EffectSpawner.DONTCULL
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 4 SpawnEffect();
			Loop;
		Inactive:
			TNT1 A -1;
			Loop;
	}
	
	override void SpawnEffect()
	{
		EffectSpawner.SpawnEffect();

		what = !what;

		// Alternate spawning steam and splash every 4 tics
		if (what) {
			// A_SpawnItemEx("WaterSplashObject", 0, 0, 0, 0, 0, 0, 0, SPLASHES_FLAGS);
			// boashaders.txt:L2060-L2082
			static const double rolls[] = { 2.0, 3.0, 2.5, 3.5 };

			int variant = Random[Splash](0, 3);

			TextureID splash = TexMan.CheckForTexture(String.Format("WTS%cA0", 0x41 + variant));

			A_SpawnParticleEx(
				"FFFFFF", // color1
				splash, // texture
				GetRenderStyle(), // style (SXF_TRANSFERRENDERSTYLE)
				SPF_RELATIVE | SPF_ROLL, // flags
				32, // lifetime (0.8 / 0.025)
				153.6, // size (0.3 * 512.)
				FRandom[Splash](0.0, 360.0), // angle
				0.0, // xoff
				0.0, // yoff
				0.0, // zoff
				Random[Splash](0, 1), // velx
				0.0, // vely
				FRandom[Splash](1.0, 2.0), // velz
				0.0, // accelx
				0.0, // accely
				0.0, // accelz (-NOGRAVITY does not work for SimpleActors and particle actors)
				0.8, // startalphaf
				0.025, // fadestepf
				5.12, // sizestep (512 * 0.01)
				0.0, // startroll
				rolls[variant], // rollvel
				0.0 // rollacc
			);
		}
		else { A_SpawnItemEx("WaterSplashCloud", Random[Splash](-8, 8), Random[Splash](-8, 8), Random[Splash](0, 16), 0, 0, 0, 0, SPLASHES_FLAGS); }
	}
}