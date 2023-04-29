// Based on HD-style slow bullet by Matt: https://forum.zdoom.org/viewtopic.php?f=105&t=71473 (2017--2021)

class TankShellTracer: LineTracer
{
	Bullet bullet;
	Actor shooter;
	override ETraceStatus TraceCallback()
	{
		if (!bullet) { return TRACE_Stop; }
		if (results.hittype == TRACE_HitFloor || results.hittype == TRACE_HitCeiling)
		{ 
			int skipsize = bullet.tracesectors.Size();
			for (int i = 0; i < skipsize; ++i)
			{
				if (bullet.tracesectors[i] == results.hitsector) { return TRACE_Skip; }
			}
		}
		if (results.hittype == TRACE_HitActor)
		{
			if (!results.hitactor.bShootable || results.hitactor == bullet || results.hitactor == shooter || results.hitactor.species == bullet.species
				|| results.hitactor is "TankBlocker")
			{
				return TRACE_Skip;
			}
			int skipsize = bullet.traceactors.Size();
			for (int i = 0; i < skipsize; ++i)
			{
				if (bullet.traceactors[i] == results.hitactor) { return TRACE_Skip; }
			}
			if (ModelHitbox(results.hitactor) || results.hitactor.bShootable) { return TRACE_Stop; }
			return TRACE_Skip;
		}
		if (results.hittype == TRACE_HitWall)
		{
			int skipsize = bullet.tracelines.Size();
			for (int i = 0; i < skipsize; ++i)
			{
				if (bullet.tracelines[i] == results.hitline) { return TRACE_Skip; }
			}
		}
		return TRACE_Stop;
	}
}

const MAXHITBOXRADIUS = 256;

//We already have 'Shell's in Doom, and Round gets confused with round() while casting.
class Bullet: Actor
{
	mixin SpawnsGroundSplash;

	Array<Line> tracelines;
	Array<Actor> traceactors;
	Array<Sector> tracesectors;
	Vector3 realpos;
	Name decal, ricochetdecal;
	int basepen, basedmg, stype;
	bool HIT, DEAD;
	property Decal: decal;
	property Penetration: basepen;
	property BaseDamage: basedmg;
	property Type: stype;
	Default
	{
		Projectile;
		Height 0.1;
		Radius 0.1;
		+BRIGHT +CANNOTPUSH +DONTSPLASH +FORCEXYBILLBOARD +MISSILE +NODAMAGETHRUST -NOGRAVITY +NOTELEPORT +NODAMAGE +WINDTHRUST +THRUSPECIES +MTHRUSPECIES
		//Alpha 0.75;
		//Scale 0.4;
		RenderStyle "Add";
		MissileType "BulletPuff";
		Bullet.Decal "Scorch";
		Bullet.Penetration 80;
		Bullet.BaseDamage 80;
		Speed 80;
		Gravity 0.33;
		DeathSound "weapons/rocklx";
	}
	enum DamageFlags { SBDF_GEOMETRY = 1 }
	enum ShellType { SHELL_AP, SHELL_APCR, SHELL_HEAT, SHELL_HE, }
	virtual int GetDamage(int flags = 0) { return random(int(basedmg * .75), int(basedmg * 1.25)); }
	virtual int GetPenetration(int flags = 0) { return random(int(basepen * .75), int(basepen * 1.25)); }
	virtual void ImpactLine(Line hitline, int hitside){ ExplodeBullet(hitline); }
	virtual void ImpactSector(Sector hitsector, int hittype){ ExplodeBullet(hitsector:hitsector); }
	virtual void ExplodeBullet(Line hitline = null, Actor hitactor = null, Sector hitsector = null, StateLabel stateoverride = "null")
	{
		bMISSILE = false;
		vel = (0, 0, 0);
		A_FaceMovementDirection(0,0);
		A_SprayDecal(decal, max(radius, radius + 4));
		A_StartSound(deathsound, CHAN_BODY);
		if (stateoverride != "null") { SetStateLabel(stateoverride); }
		else if (hitactor)
		{
			if (hitactor.bNOBLOOD && FindState("Crash", true)) { SetStateLabel("Crash"); }
			else if (Findstate("XDeath", true)) { SetStateLabel("XDeath"); }
			else { SetStateLabel("Death"); }
		}
		else { SetStateLabel("Death"); }
	}
	virtual void ApplyGravity() { if (vel.z > -65536) { vel.z = max(-65536, vel.z - GetGravity()); } }
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		A_StartSound(seesound, CHAN_BODY);
		realpos = pos;
		HIT = false;
		if (target) { species = target.species; vel += target.vel; angle = target.angle; pitch = target.pitch; }
	}
	override void Tick()
	{
		if (IsFrozen()) { return; }
		if (HIT) { ExplodeBullet(); HIT = false; DEAD = true; return; }
		if (!bMISSILE || vel == (0, 0, 0) || DEAD) { Super.Tick(); return; }
		tracelines.Clear(); traceactors.Clear(); tracesectors.Clear();
		if (realpos.xy != pos.xy)
		{
			SetOrigin((realpos.xy, clamp(realpos.z, GetZAt(realpos.x, realpos.y, flags: GZF_ABSOLUTEPOS),
			GetZAt(realpos.x, realpos.y, flags: GZF_ABSOLUTEPOS | GZF_CEILING) - height)), true);
		}
		if (ceilingz < realpos.z && ceilingz - realpos.z < vel.z)
		{
			if (!(level.time & 255) && (vel.xy dot vel.xy < 64.) && !level.IsPointInLevel(pos)) { Destroy(); return; }
			bNOINTERACTION = bINVISIBLE = true;
			realpos += vel;
			ApplyGravity();
			return;
		}
		if (bNOINTERACTION) { bNOINTERACTION = false; bINVISIBLE = false; }
		TankShellTracer blt = TankShellTracer(new("TankShellTracer"));
		blt.bullet = Bullet(self);
		blt.shooter = target;
		Vector3 oldpos = realpos, newpos = oldpos, vu;
		double distanceleft = vel.length(), curspeed = distanceleft;
		A_FaceMovementDirection();
		do
		{
			if (curspeed > speed) { distanceleft -= (curspeed - speed); curspeed = speed; }
			vu = vel.unit();
			blt.Trace(realpos, cursector, vu, distanceleft, TRACE_HitSky);
			TraceResults bres = blt.results;
			if (!bINCOMBAT && (!target || bres.distance > target.height)) { bINCOMBAT = true; }
			BlockThingsIterator BI = BlockThingsIterator.Create(self, Default.speed + MAXHITBOXRADIUS * sqrt(3));
			ModelHitbox mo, mosaved;
			double dist = 1e9, distnew;
			Vector3 delta;
			int thck = -1, thcksaved = -1;
			while (BI.Next())
			{
				mo = ModelHitbox(BI.thing);
				if (mo && (mo.species == target.species)) { traceactors.Push(mo); continue; }
				if (mo && Distance3D(mo) <= Default.speed + 1 + mo.radius * sqrt(3))
				{
					[delta, distnew, thck] = mo.TryCollideWithHitscan(self);
					if (distnew < dist && distnew < Default.speed + 1 + mo.radius * sqrt(3) && thck >= 0) { dist = distnew; HIT = true; mosaved = mo; thcksaved = thck; }
				}
			} 
			int q = -1;
			TankPlayer tank = TankPlayer(target);
			if (HIT && thcksaved >= 0)
			{
				q = GetPenetration();
				if (q >= thcksaved)
				{
					// The shell penetrated the armour and exploded inside the tank.
					Console.Printf("\c[Green]"..q.." has penetrated "..thcksaved);
					if (mosaved.master)
					{
						mosaved.master.DamageMobj(self, target, GetDamage(), "TankShell"); // full damage
					}
				}
				else
				{
					Console.Printf("\c[Red]"..q.." has not penetrated "..thcksaved);
					// The armour stopped the shell and most of its damage. The explosion might still made the inner armour split.
					if (mosaved.master)
					{
						mosaved.master.DamageMobj(self, target, GetDamage() / 10.0, "TankShell"); // only a small fraction
					}
				}
				SetOrigin(pos + delta, true);
				Destroy();
			}
			newpos = bres.hitpos; realpos = newpos;
			distanceleft -= max(bres.distance, 100.);			
			if (bres.hittype == TRACE_HitNone) { }
			else if (bres.hittype == TRACE_HitActor)
			{
				realpos += vel;
				newpos = bres.hitpos;
				if (bres.hitactor.bShootable && !(bres.hitactor is "ModelHitbox" || bres.hitactor is "TankBase"))
				{
					HIT = true;
					bres.hitactor.DamageMobj(self, target, GetDamage(), "TankShell"); // full damage on non-armoured targets.
				}
			}
			else if (bres.hittype == TRACE_HasHitSky)
			{
				HIT = true;
				realpos += vel;
				newpos = bres.hitpos;
			}
			else
			{
				newpos = bres.hitpos - vu * 0.1; realpos = newpos;
				distanceleft -= max(bres.distance, 10.);
				if (bres.hittype == TRACE_HitWall)
				{
					SetOrigin(realpos, true);
					let hitline = bres.hitline;
					tracelines.Push(hitline);
					Sector othersector;
					othersector = (bres.hitsector == hitline.frontsector) ? hitline.backsector : hitline.frontsector;
					if (hitline.special == Line_Horizon) { Destroy(); break; }
					else
					{
						bool isblocking = (!(hitline.flags & line.ML_TWOSIDED) || hitline.flags & line.ML_BLOCKHITSCAN || hitline.flags & Line.ML_BLOCKPROJECTILE
							|| hitline.GetHealth() > 0 || (((bres.tier == TIER_Upper) && (othersector.GetTexture(othersector.ceiling) != skyflatnum)) || ((bres.tier == TIER_Lower)
							&& (othersector.GetTexture(othersector.floor) != skyflatnum))) || !CheckMove(bres.hitpos.xy + vu.xy * 0.4));
						if (!isblocking)
						{
							hitline.Activate(target, bres.side, SPAC_PCross | SPAC_AnyCross);
							realpos.xy += vu.xy * 0.2;
							SetOrigin(realpos, true);
						}
						else
						{
							HIT = true;
							hitline.Activate(target, bres.side, SPAC_Impact | SPAC_Damage);
							Destructible.DamageLinedef(hitline, self, GetDamage(SBDF_GEOMETRY), damagetype, bres.side, pos, false); ImpactLine(hitline, bres.side);
						}
					}
				}
				else if (bres.hittype == TRACE_HitFloor || bres.hittype == TRACE_HitCeiling)
				{
					Sector hitsector = bres.hitsector;
					tracesectors.Push(hitsector);
					SetOrigin(realpos, true);
					if ((bres.hittype == TRACE_HitCeiling && (hitsector.GetTexture(hitsector.ceiling) == skyflatnum || ceilingz > pos.z + 0.1)) || (bres.hittype == TRACE_HitFloor
						&& (hitsector.GetTexture(hitsector.floor) == skyflatnum || floorz < pos.z - 0.1))) { continue; }
					HIT = true;
					Destructible.DamageSector(hitsector, self, GetDamage(SBDF_GEOMETRY), damagetype, bres.hittype == TRACE_HitCeiling ? SECPART_Ceiling: SECPART_Floor, pos, false);
					ImpactSector(hitsector, bres.hittype);
				}
			}
			if (HIT)
			{
				ExplodeBullet();
				HIT = false;
				DEAD = true;
				return;
			}
		} while (!!self && bMISSILE && distanceleft > 0);
		blt.destroy();
		ApplyGravity();
		if (abs(oldpos.x - realpos.x) < .01 && abs(oldpos.y - realpos.y) < .01 && abs(oldpos.z - realpos.z) < .01 ) { ExplodeBullet(); }
	}
	
	states {
		Spawn:
			MNSS A 1 Bright Light("BOAFLMW2") A_StartSound("panzer/fly", CHAN_VOICE, CHANF_LOOPING, 1.0);
			MNSS A 1 Bright Light("BOAFLMW2"); //no flames, it is a regular projectile
			Wait;
		Death:
			EXP1 A 0 A_SpawnGroundSplash;
			EXP1 A 0 A_SetScale(0.75, 0.75);
			EXP1 A 0 A_StopSound(CHAN_VOICE);
			EXP1 A 0 A_StartSound("panzer/explode", CHAN_VOICE, 0, 1.0, ATTN_NORM);
			EXP1 A 0 { if (HIT) { A_Explode(0, 192, 0, TRUE, 320); A_SpawnItemEx("ZScorch"); } }
			TNT1 AAAAAAAAAAAAAAAAAAAAAAAAAAA 0 A_SpawnItemEx("TracerSpark_Longlive", 0, 0, 0, random(-5,5), random(-5,5), random(-5,5), random(0,359)); //T667 improvements
			TNT1 A 0 A_SpawnItemEx("PanzerNuke", 0, 0, 0, 0, 0, 0, 0, SXF_TRANSFERPOINTERS|SXF_NOCHECKPOSITION);
			TNT1 A 8 {
				Actor ex = Spawn("GeneralExplosion_Large", pos + (RotateVector((56, 0), angle), 32));
				if (ex)
				{
					ex.target = target;
					ex.damagetype = damagetype;
				}
			}
			EXP1 A 2 Bright Light("BOAFLMW2") A_Quake(9, 15, 0, 1024, "");
			EXP1 BCDEFGHIJKLMN 2 Bright Light("BOAFLMW2");
			Stop;
	}
}
