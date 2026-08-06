
class M2HBTruck: NebelwerferTruck
{
	Default
	{
		Tag "Browning M2HB";
	}
	States
	{
		Ready:
			M2HB A 1 {
				A_WeaponReady(WRF_NOSWITCH);
				invoker.AdjustPitch();
			}
			Loop;
		Deselect:
			M2HB A 0 A_Lower();
			M2HB A 1 A_Lower();
			Loop;
		Select:
			M2HB A 0 A_Raise();
			M2HB A 1 A_Raise();
			Loop;
		Fire:
			M2HB A 0 A_JumpIf(height<=30,"Fire.LowRecoil");
			M2HB A 0 A_GunFlash();
			M2HB A 0 A_StartSound("tank/50cal", CHAN_WEAPON);
			M2HB BC 1 Bright;
			M2HB C 0 A_FireProjectile("M2HBTracer");
			M2HB CD 1 Bright A_SetPitch(pitch-(0.4*boa_recoilamount));
			M2HB E 1;
			M2HB A 1 A_ReFire();
			Goto Ready;
		Fire.LowRecoil:
			M2HB A 0 A_GunFlash();
			M2HB A 0 A_StartSound("tank/50cal", CHAN_WEAPON);
			M2HB BC 1;
			M2HB C 0 A_FireProjectile("M2HBTracer");
			M2HB CD 1 A_SetPitch(pitch-(0.2*boa_recoilamount));
			M2HB E 1;
			M2HB A 1 A_ReFire();
			Goto Ready;
		Flash:
			TNT1 A 2 A_Light2;
			TNT1 A 2 A_Light1;
			Goto LightDone;
		Spawn:
			M2HB A -1;
			Stop;
		GoAway:
			TNT1 A -1;
			Stop;
	}
	
	override void Tick()
	{
		Super.Tick();
		Inventory existing = FindInventory("NebelwerferTruck");
		if (!existing)
		{
			SetState(ResolveState("GoAway"));
			GoAwayAndDie();
			ScriptUtil.SetWeapon(self, "NullWeapon");
		}
	}
}

class M2HBTracer : PlayerTracer
{
	Default
	{
		ProjectileKickback 100;
		DamageFunction (random(70,65));
		Speed 180;
		Decal "Scorch";
		DamageType "Rifle";
	}
	States
	{
		Death:
		Crash:
			TNT1 A 0 A_SpawnItemEx("M2HBTracerExplosion", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE); //Boom! High explosive rounds.
			TNT1 AAA 0 {
				if (trailactor) { trailactor.Destroy(); }
				bWindThrust = false;
			}
			PUFF B 3 BRIGHT LIGHT("BPUFF1") {
				A_SpawnItemEx("ZScorch");
			}
			PUFF CD 3 BRIGHT LIGHT("BPUFF1");
			Stop;
		XDeath:
			TNT1 A 0 A_SpawnItemEx("M2HBTracerExplosion", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
			TNT1 A 1 {
				bWindThrust = false;
				A_StartSound("hitflesh");
			}
			Stop;
	}
}

class M2HBTracerExplosion: GrenadeBase
{
	default
	{
		+NOINTERACTION
		Scale 0.25;
		GrenadeBase.SplashType "Missile";
	}
	States
	{
	Spawn:
	Active:
		TNT1 A 0 Radius_Quake(7,10,0,8,0);
		Goto Explosion;
	Explosion:
		TNT1 A 0 A_Explode(32, 96);
		TNT1 A 0 A_StartSound("EXPLOSION_SOUND", CHAN_AUTO);
		TNT1 A 0 A_RadiusGive("BlurShaderControl", 192, RGF_PLAYERS | RGF_GIVESELF, 80);
		TNT1 A 0 A_JumpIf(boa_boomswitch == 0, "Inactive");
		TNT1 A 0 A_SpawnItemEx("KD_HL2Flash", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
		TNT1 A 0 A_SpawnItemEx("NebNuke",0,0,0,0,0,0,0,SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
		//TNT1 A 0 A_SpawnItemEx("GeneralExplosion_ShockwaveOrange", 0, 0, 0, 0, 0, 0, 0,SXF_CLIENTSIDE | SXF_TRANSFERSCALE);
	Inactive:
		TNT1 A 350;
		Wait;
	}
}