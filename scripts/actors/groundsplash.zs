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

mixin class SpawnsGroundSplash
{
	String groundSplashType;
	Property SplashType: groundSplashType;

	void A_SpawnGroundSplash()
	{
		GroundSplashBase.SpawnGroundSplash(self, self.groundSplashType);
	}
}

class SplashParticleBase : SimpleActor
{
	Default
	{
		Scale .25;
		-NOGRAVITY
		+NOINTERACTION
		+ROLLSPRITE
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		Roll = frandom(0.0, 360.0);
	}

	void A_CheckGround()
	{
		Sector theSector = Level.PointInSector(Pos.XY);
		if (Pos.Z < theSector.floorplane.ZatPoint(Pos.XY))
		{
			Destroy();
		}
	}
}

class SoilSplashParticle : SplashParticleBase
{
	States
	{
	Spawn:
		SLP1 A 0 NoDelay A_Jump(128, 1);
		Goto Flight;
		SLP1 B 0;
	Flight:
		"####" "#" 35 A_CheckGround;
		Loop;
	}

	override void Tick()
	{
		Super.Tick();
		// Apply gravity and add roll
		if (!Level.isFrozen())
		{
			Roll += frandom(1.0, 3.0);
			Vel.Z -= GetGravity();
		}
	}
}

class SnowSplashParticle : SoilSplashParticle
{
	States
	{
	Spawn:
		SLP1 C 0 NoDelay A_Jump(128, 1, 2);
		Goto Flight;
		SLP1 D 0;
		Goto Flight;
		SLP1 E 0;
		Goto Flight;
	}
}

// Moves differently compared to Soil/SnowSplashParticle
class SandSplashParticle : SplashParticleBase
{
	Default
	{
		Scale 1.0;
	}

	States
	{
	Spawn:
		SLP1 F 0;
		Goto Flight;
	Flight:
		"####" "#" 1 {
			Scale *= 1.0625;
			Roll += frandom(1.0, 3.0);
			A_FadeOut(0.03125, FTF_REMOVE);
		}
		Loop;
	}
}

class SnowSplashParticleExtra : SandSplashParticle
{
	States
	{
	Spawn:
		SLP1 G 0;
		Goto Flight;
	}
}

class GroundSplashBase : Actor
{
	Default
	{
		+NOINTERACTION
	}

	virtual void A_SpawnAltSplash(String particleClassNames, double endradius = 2, double increment = .25, int ring = 5)
	{
		Array<String> classNames;
		particleClassNames.Split(classNames, "|", TOK_SKIPEMPTY);
		int height = classNames.Size();
		if (increment <= 0.0) { increment = .25; }
		if (endradius < 0.0) { endradius = increment; }
		for (double radius = 0.0; radius < endradius; radius += increment)
		{
			for (int i = 0; i < height; i++)
			{ // Height is how many particles to spawn vertically
				class<Actor> particleClass = classNames[i];
				if (!particleClass) { continue; }
				for (int j = 0; j < ring; j++)
				{ // Ring is how many particles to spawn in a ring horizontally
					double angleFrac = 1.0/ring;
					double angleDiff = 360 * angleFrac; // Angle difference between each ring theta particle
					double pangle = angleDiff * j;
					Actor particle = Spawn(particleClass, Pos, ALLOW_REPLACE);
					SetParticleVelocity(particle, radius, endradius, pangle, angleDiff, i);
				}
			}
		}
	}

	virtual void SetParticleVelocity(Actor particle, double radius, double endradius, double pangle, double angleDiff, int curHeight = 0)
	{
		particle.VelFromAngle(radius, pangle + frandom(-angleDiff / 2, angleDiff / 2));
		particle.Vel.Z = ((curHeight + 1) * 3) * cos(60 * (radius / endradius)) + frandom(-1.0, 1.0);
	}

	// Spawn an alternative ground splash
	// mo - the actor which is used to check position and floor texture
	// splashType - The "ground splash class" - e.g. Missile, Mine, etc.
	// zthreshold - Maximum distance from splash actor to ground for spawning
	// ground splash. Default is 3.
	static Actor SpawnGroundSplash(Actor mo, String splashType, double zthreshold = 3)
	{
		// Check CVar
		CVar groundPlumeSwitch = CVar.FindCVar("boa_groundplume");
		if(!groundPlumeSwitch.GetBool()) { return null; }
		// Get floor texture
		String textureName;
		if (mo.Pos.Z <= (mo.CurSector.floorplane.ZatPoint(mo.Pos.XY) + zthreshold)) {
			// mo is on the ground
			textureName = TexMan.GetName(mo.floorpic);
		} else {
			// mo is (probably) on a 3D floor
			Sector ffSector;
			double ffz;
			[ffz, ffSector] = mo.CurSector.NextLowestFloorAt(mo.Pos.X, mo.Pos.Y, mo.Pos.Z, 0, 0);
			if (mo.Pos.Z > (ffz + zthreshold)) { return null; }
			// A 3D floor control sector ceiling becomes a floor
			TextureID ffTexture = ffSector.GetTexture(1);
			textureName = TexMan.GetName(ffTexture);
		}
		if (textureName == "") { return null; }
		// Work around issue with full path textures being parsed incorrectly by FileReader.GetString
		textureName.Replace(".", ">");
		// Get data from handler
		GroundSplashDataHandler splashData = GroundSplashDataHandler(StaticEventHandler.Find("GroundSplashDataHandler"));
		// Resolve splash actor class
		String splashActorStr = FileReader.GetString(splashData.data, splashType .. "." .. textureName);
		if (splashActorStr != "") {
			class<Actor> splashActor = splashActorStr;
			if (splashActor)
			{
				return Actor.Spawn(splashActor, mo.Pos, ALLOW_REPLACE);
			}
			else
			{
				if (developer)
				{
					Console.Printf("Warning: Ground splash actor class %s does not exist!", splashActorStr);
				}
			}
		}
		return null;
	}
}

class DirtGroundSplash : GroundSplashBase
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnAltSplash("SoilSplashParticle|SoilSplashParticle|SoilSplashParticle|SoilSplashParticle|SoilSplashParticle|SoilSplashParticle", 3, 1);
		Stop;
	}
}

// "Small" variant for Nebelwerfer and grenades
class DirtGroundSplashSmall : GroundSplashBase
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnAltSplash("SoilSplashParticle|SoilSplashParticle|SoilSplashParticle", 5, 2);
		Stop;
	}
}

class SnowGroundSplash : GroundSplashBase
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnAltSplash("SoilSplashParticle|SoilSplashParticle|SoilSplashParticle|SoilSplashParticle|SoilSplashParticle|SnowSplashParticle", 3, 1);
		TNT1 A 0 A_SpawnItemEx("SnowGroundSplashExtra");
		Stop;
	}
}

// "Small" variant for Nebelwerfer and grenades
class SnowGroundSplashSmall : GroundSplashBase
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnAltSplash("SoilSplashParticle|SoilSplashParticle|SnowSplashParticle", 5, 2);
		TNT1 A 0 A_SpawnItemEx("SnowGroundSplashExtra");
		Stop;
	}
}

// The "soil" particles could also be mud
class SandGroundSplash : GroundSplashBase
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnAltSplash("SoilSplashParticle|SoilSplashParticle|SoilSplashParticle", 5, 2);
		TNT1 A 0 A_SpawnItemEx("SandGroundSplashSmall");
		Stop;
	}
}

class SandGroundSplashSmall : GroundSplashBase
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnAltSplash("SandSplashParticle", 5, 5, 5);
		Stop;
	}

	override void SetParticleVelocity(Actor particle, double radius, double endradius, double pangle, double angleDiff, int curHeight)
	{
		particle.Vel3DFromAngle(3, pangle + frandom(-angleDiff / 2, angleDiff / 2), -1);
	}
}

class SnowGroundSplashExtra : SandGroundSplashSmall
{
	States
	{
	Spawn:
		TNT1 A 0 NoDelay A_SpawnAltSplash("SnowSplashParticleExtra", 5, 5, 5);
		Stop;
	}
}