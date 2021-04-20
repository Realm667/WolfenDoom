// Shader effect givers
class EffectGiver : EffectSpawner
{
	bool Active;
	Array<Actor> Activators;
	class<ShaderControl> controlclass;

	Property Control:controlclass;

	Default
	{
		//$Category Special Effects (BoA)
		//$Color 12
		Radius 128;
		Alpha 0.5;
		RenderStyle "Stencil";
		+SOLID
		+NOCLIP
		EffectSpawner.SwitchVar "boa_shaderoverlayswitch";
	}

	States
	{
		Spawn:
			MDLA A 1;
		Active:
			TNT1 A 35;
			Loop;
	}

	override void PostBeginPlay()
	{
		bInvisible = True;

		double fz = GetZAt(0, 0, 0, GZF_NO3DFLOOR);
		double cz = GetZAt(0, 0, 0, GZF_CEILING | GZF_NO3DFLOOR);

		SetOrigin((pos.xy, fz), false);

		// Resize to the scaled size and fill the height of the sector, plus 32 units to allow for a border on the edges where the value will properly be zero
		// This sets the actor size so that the player can touch it when the effect is still at amount zero, allowing gradual fade-in/out
		A_SetSize(Radius * scale.x + 32, cz - fz); 

		Super.PostBeginPlay();
	}

	override bool CanCollideWith(Actor other, bool passive)
	{
		if (!Activators.Size() && switchcvar && !switchcvar.GetBool()) { return false; }
		if (other.player && Activators.Find(other) == Activators.Size()) { Activators.Push(other); return true; }

		return false;		
	}

	override void Tick()
	{
		if (Activators.Size() && switchcvar && !switchcvar.GetBool())
		{
			for (int i = 0; i < Activators.Size(); i++)
			{
				Actor mo = Activators[i];

				if (mo && mo is "PlayerPawn")
				{
					ShaderControl control = ShaderControl(mo.FindInventory(controlclass));
					if (control) { control.amount = 1; }
					Activators.Delete(i);
				}
			}
		}
		else if (!bDormant && level.time % 5 == 0)
		{
			for (int i = 0; i < Activators.Size(); i++)
			{
				Actor mo = Activators[i];

				if (mo && mo is "PlayerPawn")
				{
					// Set the amount of the powerup based off of the original radius and scale values
					// Always scale from 0 to 128, regardless of scale/radius of actor
					int amt = clamp(int(128 * (1.0 - Distance2D(mo) / (Default.radius * scale.x))), 0, 128);

					ShaderControl control = ShaderControl(mo.FindInventory(controlclass));
					if (control)
					{
						if (amt - 5 >= control.amount) { SetParams(control); } // If this is the dominant giver, allow it to set shader parameters
						amt = max(amt, control.amount); // Don't cancel out other givers - just go with whichever is giving the most
					}

					if (amt <= 1) { Activators.Delete(i); continue; }

					mo.SetInventory(controlclass, min(1 + amt, 128));
				}
			}
		}

		Super.Tick();
	}

	virtual void SetParams(ShaderControl control) {}
}

class HeatEffectGiver : EffectGiver
{
	Default
	{
		//$Title Heat Effect Giver
		StencilColor "Orange";
		EffectGiver.Control "HeatShaderControl";
	}
}

class SandEffectGiver : EffectGiver
{
	Default
	{
		//$Title Sand Effect Giver
		StencilColor "Tan";
		EffectGiver.Control "SandShaderControl";
	}

	override void SetParams(ShaderControl control)
	{
		SandShaderControl ctrl = SandShaderControl(control);

		if (!ctrl) { return; }

		double destangle = Normalize180(angle + 90);
		if (destangle - ctrl.setangle > 180) { destangle -= 360; }

		if (ctrl.setangle > destangle) { ctrl.setangle = max(destangle, ctrl.setangle - 5 * ctrl.speed); }
		else if (ctrl.setangle < destangle) { ctrl.setangle = min(destangle, ctrl.setangle + 5 * ctrl.speed); }
	}
}

// Hitler spawn and death
class Tornado : Actor
{
	class<Actor> segment;
	int skinframe;
	class<Actor> lightning;
	class<Actor> dust;

	Property Segment:segment;
	Property SegmentSkin:skinframe;
	Property Lightning:lightning;
	Property Dust:dust;

	Default
	{
		//$Category Special Effects (BoA)
		//$Color 12
		+NOINTERACTION

		Scale 3.5;
		Speed 1.0;
		Alpha 1.0;

		Tornado.Segment "TornadoSegment";
		Tornado.SegmentSkin 0; // 0-5 uses various waterfall/water/poison/lava textures as the model skin
		Tornado.Lightning "LightningBeamArc2";
		Tornado.Dust "ZyklonBCloud";
	}

	override void PostBeginPlay()
	{
		double factor = (ceilingz - floorz) / 896.;

		scale *= factor;

		Actor prev;
		double spawnscale = scale.x;
		double spawnspeed = speed;

		for (double i = ceilingz; i >= floorz; i -= 48 * factor)
		{
			Actor mo = Spawn(segment, (pos.xy, i));

			if (mo)
			{
				TornadoSegment(mo).destscale = spawnscale;
				TornadoSegment(mo).skinframe = skinframe;
				TornadoSegment(mo).dust = dust;
				TornadoSegment(mo).lightning = lightning;
				mo.bBright = bBright;
				mo.alpha = alpha;
				mo.speed = spawnspeed;
				mo.scale.y = factor;
				if (prev) { prev.master = mo; }

				prev = mo;
			}

			spawnscale *= 0.85;
			spawnspeed *= 1.2;
		}

		Destroy();
	}

	States
	{
		Spawn:
			TNT1 A 1;
			Loop;
	}
}

class TornadoSegment : Actor
{
	Vector3 offset;
	double destscale;
	int timeoffset;
	class<Actor> lightning;
	class<Actor> dust;
	int skinframe;

	Default
	{
		+NOINTERACTION
		+NOGRAVITY

		Renderstyle "Add";
		Scale 0.05;
	}

	States
	{
		Spawn:
			MDLA # 0;
			MDLA # 70;
		Disperse:
			MDLA # 5 {
				A_FadeOut(0.025);
				scale.x *= 1.0125;
			}
			Loop;
	}

	override void PostBeginPlay()
	{
		angle = Random(0, 359);
		timeoffset = Random(1, 360);
		frame = skinframe;
		SpawnPoint = pos;

		if (master)
		{
			offset = pos - master.pos;
		}

		A_StartSound("WIND_SILENT", CHAN_6, CHANF_LOOPING, 1.0, ATTN_NONE);

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		if (isFrozen()) { return; }

		angle += speed;
		roll = 5 * sin((level.time + timeoffset) * 2) * scale.y;

		if (master)
		{
			if (scale.x < destscale)
			{
				scale.x = min(destscale, scale.x * 1.05);
				master.scale.x = scale.x * 0.85;

				master.alpha = min(alpha, scale.x / destscale);
			}

			Vector3 offsetalt = offset;

			offsetalt.x += 16 * scale.x * sin(level.time);
			offsetalt.y += 16 * scale.x * cos(level.time);
			SetOrigin(master.pos + offsetalt, true);
		}

		int radius = int(64 * scale.x);

		if (level && level.time && level.time % (timeoffset * 5) == 0)
		{
			if (dust)
			{
				Actor cloud = Spawn(dust, (SpawnPoint.xy + (Random(-radius, radius), Random(-radius, radius)), floorz));
				if (cloud) { cloud.scale *= FRandom(0.5, 1.2); }
			}

			if (lightning)
			{
				Actor l = Spawn(lightning, pos + (Random(-radius, radius), Random(-radius, radius), 0));
				if (l)
				{
					l.master = self;
					l.angle = Random(0, 359);
					l.pitch = Random(0, 359);
					LightningBeam(l).maxdistance = 256 * scale.x;
				}
			}
		}

		A_SoundVolume(CHAN_6, alpha * 0.75);

		Super.Tick();
	}
}

class ExplosionLight : AlertPointLight
{
	override void Tick()
	{
		Super.Tick();

		if (master)
		{
			args[DynamicLight.LIGHT_INTENSITY] = int(master.scale.x * 2048 * master.alpha);
		}
		else
		{
			args[DynamicLight.LIGHT_INTENSITY]--;
		}

		if (args[DynamicLight.LIGHT_INTENSITY] <= 0) { Destroy(); }
	}
}

class ExplosionSphere : Actor
{
	Actor light;
	Array<Actor> sparks;

	Default
	{
		+NOGRAVITY
		+BRIGHT
		RenderStyle "AddStencil";
		StencilColor "BBBBFF";
		Scale 0.01;
		Alpha 0.7;
	}

	States
	{
		Spawn:
			MDLA A 1;
			Loop;
	}

	override void PostBeginPlay()
	{
		light = Spawn("ExplosionLight", pos);
		light.args[DynamicLight.LIGHT_RED] = 0xBB;
		light.args[DynamicLight.LIGHT_GREEN] = 0xBB;
		light.args[DynamicLight.LIGHT_BLUE] = 0xFF;
		light.master = self;

		for (int i = 1; i <= 6; i++)
		{
			Class<Actor> sparkclass = "SparkFlareW";

			Actor spark;

			for (int j = 0; j < 32; j++)
			{
				spark = Spawn(sparkclass, pos);

				if (spark)
				{
					spark.A_SetRenderStyle(alpha, STYLE_AddShaded);
					spark.SetShade(fillcolor);
					spark.bMissile = true;
					spark.A_SetTics(Random(30, 280));
					spark.scale *= FRandom(0.125, 0.5);
					spark.alpha *= FRandom(0.25, 1.0);
					spark.speed = FRandom(1, 32);
					spark.angle = FRandom(0, 359);
					spark.pitch = FRandom(-30, 0);

					spark.Vel3DFromAngle(spark.speed, spark.angle, spark.pitch);

					sparks.push(spark);
				}
			}
		}
	}

	override void Tick()
	{
		if (IsFrozen()) { return; }

		scale.x = scale.y = (scale.x + 0.2);
		alpha = max(0, alpha - 0.05);

		for (int s = 0; s < sparks.Size(); s++)
		{
			if (!sparks[s]) { sparks.Delete(s); continue; }

			sparks[s].angle += 2;
			sparks[s].pitch -= 0.5;

			sparks[s].Vel3DFromAngle(sparks[s].speed, sparks[s].angle, sparks[s].pitch);
		}

		if (light && alpha == 0.0) { light.master = null; }

		if (!sparks.Size())
		{
			Destroy();
		}

		Super.Tick();
	}
}

class ExplosionCore : Actor
{
	Default
	{
		+NOGRAVITY
		+BRIGHT
		RenderStyle "AddStencil";
		StencilColor "005500";

		Alpha 0.0;
		Scale 10.0;
	}

	States
	{
		Spawn:
			MDLA A 1;
			Loop;
	}

	override void Tick()
	{
		if (IsFrozen()) { return; }

		scale.x = scale.y = (scale.x - 0.4);
		alpha = min(0.7, alpha + 0.005);

		if (scale.x <= 0.0)
		{
			Spawn("ExplosionSphere", pos);
			Destroy();
		}

		Super.Tick();
	}
}

// Astrostein overhead ship
class DecorationShip : SwitchableDecoration
{
	ParticleManager manager;

	Default
	{
		//$Category Astrostein (BoA)/Props
		//$Title Space Ship (viper, activatable)
		//$Color 3
		Radius 8;
		Height 6;
		Speed 6;
		Damage 3;
		SeeSound "viper/flyby";
		Projectile;
		-ACTIVATEIMPACT
		+ACTIVATEPCROSS
		+CLIENTSIDEONLY
		+DONTSPLASH
		+NOGRAVITY
	}

	States
	{
		Spawn:
			MDLA A 0;
		Active:
			MDLA A 1 SpawnEffect();
			Loop;
		Inactive:
			MDLA A -1;
			Stop;
		Death:
			MDLA A 4;
			Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		manager = ParticleManager.GetManager();
	}

	void SpawnEffect()
	{
		tics = curState.tics + manager.GetDelay(0, 0, self);

		A_SpawnItemEx("DecorationShip_Steam", -32, -5, -1);
		A_SpawnItemEx("DecorationShip_Steam", -32, 5, -1);
	}
}

class DecorationShip_Steam : SmokeBase
{
	Default
	{
		DistanceCheck "boa_scenelod";
		Radius 1;
		Height 1;
		RenderStyle "Add";
		Alpha 0.2;
		Scale 0.2;
		+CLIENTSIDEONLY
		+FORCEXYBILLBOARD
		+MISSILE
		+NOBLOCKMAP
		+NOGRAVITY
		SmokeBase.FadeInTics 1;
		SmokeBase.FadeOutTics 1;
		SmokeBase.MaxAlpha 1.0;
	}

	States
	{
		Spawn:
			SSST A 1 DoFade(0.2, 0.1);
			Loop;
	}
}

// ZScript converted Droplets BleedMe actor
class BleedMe : Inventory
{
	override bool TryPickup(in out Actor toucher)
	{
		if (toucher.health > 0) { return false; }

		toucher.A_SpawnItemEx("BloodPool2", 0, 0, 0, toucher.vel.x, toucher.vel.y, toucher.vel.z, 0, SXF_USEBLOODCOLOR | SXF_SETMASTER);
		Destroy();

		return false;
	}
}

// ZScript converted Droplets BloodPool2 actor, with some shadow offsetting from Nash shadows integrated
class BloodPool2 : ParticleBase
{
	double size, maxsize;

	Property Size:size;
	Property MaxSize:maxsize;

	Default
	{
		Radius 1;
		Height 1;
		+DONTSPLASH
		+MOVEWITHSECTOR
		+NOTELEPORT
		+NOTONAUTOMAP
		+THRUACTORS
		RenderStyle "Translucent";
		Scale 0;
		BloodPool2.Size 0.02;
		BloodPool2.MaxSize 1.11;
	}

	States
	{
		Spawn:
			SPLT F 1;
			SPLT F 0 {
				if (size >= maxsize) { SetStateLabel("Done"); }
				else
				{
					size += (1.15 - size) / 175.0;
					A_SetScale(size, 0.5);
				}
			}
			Loop;
		Done:
			SPLT F 1;
			SPLT F 0 { tics = 35 * boa_bloodlifetime; }
			"####" "#" 0 A_Jump(256, "FadeOut");
		FadeOut:
			"####" "#" 2 A_FadeOut(0.05);
			Loop;
	}

	override void PostBeginPlay()
	{
		angle = FRandom(0.0, 360.0);
		CheckWaterLevel();

		Super.PostBeginPlay();
	}

	virtual void CheckWaterLevel()
	{
		if (waterlevel)
		{
			String fogactor = "BloodFog"; // Actor is still in DECORATE
			A_SpawnItemEx(fogactor, 0, 0, 0, FRandom(-2.0, 2.0), FRandom(-2.0, 2.0), 0, 0, SXF_TRANSFERTRANSLATION);

			Destroy();
		}
	}

	override void Tick()
	{
		Super.Tick();

		if (master) // Offset the pool from the current player camera in order to avoid overlapping sprites - modified from Nash sprite shadow code
		{
			if (!players[consoleplayer].camera) return;

			Vector3 sPos = (
				master.Pos.X + cos(players[consoleplayer].camera.Angle) * 0.01,
				master.Pos.Y + sin(players[consoleplayer].camera.Angle) * 0.01,
				master.Pos.Z
				);
			SetOrigin(sPos, true);
		}
	}
}

// Urine pool for surrendering enemies; same logic as the blood pools, but transparent, with random size
class PeePool : BloodPool2
{
	Default
	{
		Alpha 0.35;
	}

	override void PostBeginPlay()
	{
		// Random pool size and clarity
		maxsize = FRandom(0.5, 0.8);
		alpha *= FRandom(0.75, 1.25);

		Super.PostBeginPlay();
	}

	override void CheckWaterLevel() // These don't spawn in water
	{
		if (waterlevel) { Destroy(); }
	}
}