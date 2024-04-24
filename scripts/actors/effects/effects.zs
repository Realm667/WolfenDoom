#include "scripts/actors/effects/ash.zs"
#include "scripts/actors/effects/bubbles.zs"
#include "scripts/actors/effects/cinder.zs"
#include "scripts/actors/effects/clouds.zs"
#include "scripts/actors/effects/confetti.zs"
#include "scripts/actors/effects/fire.zs"
#include "scripts/actors/effects/laser.zs"
#include "scripts/actors/effects/leaves.zs"
#include "scripts/actors/effects/miscellaneous.zs"
#include "scripts/actors/effects/rain.zs"
#include "scripts/actors/effects/smoke.zs"
#include "scripts/actors/effects/snow.zs"
#include "scripts/actors/effects/sparks.zs"
#include "scripts/actors/effects/starparticles.zs"
#include "scripts/actors/effects/steam.zs"
#include "scripts/actors/effects/torches.zs"
#include "scripts/actors/effects/grass.zs"
#include "scripts/actors/effects/creepy.zs"
#include "scripts/actors/effects/splash.zs"

class EffectInfo // Should just be a struct, but we can't use structs in dynamic arrays...
{
	Actor effect;
	Class<actor> type;
	Vector3 position;
	double angle, pitch, roll;
	Vector2 scale;
	Actor master, target, tracer;
	int SpawnFlags;
	int args[5];
	int tid;
	bool dormant;
	bool ingame;
	double range;
	SpriteID sprite;
	uint8 frame;
	State curstate;
	bool wasculled;
	double radius, height;
	bool bflatsprite;
	bool bspecial;
	bool bsolid;
	bool bshootable;
}

// Select actors get tracked in a dynamic array and culled when not in range of a player, then respawned when needed
class EffectsManager : Thinker
{
	Array<EffectInfo> effects;
	ChunkHandler handler;
	Vector2 playerpos[MAXPLAYERS];
	double playerangle[MAXPLAYERS];
	int lastcull;

	enum ForceLevel
	{
		FORCE_SOLID = 1,
		FORCE_TID =   2,
	}

	static EffectsManager GetManager()
	{
		ThinkerIterator it = ThinkerIterator.Create("EffectsManager", Thinker.STAT_Default);
		EffectsManager manager = EffectsManager(it.Next());

		if (!manager) { manager = new("EffectsManager"); }

		return manager;
	}

	static bool CanBeCulled(Actor effect, int force = 0)
	{
		if (!effect) { return false; }
		if (effect is "CullActorBase" && CullActorBase(effect).culllevel > boa_culllevel) { return false; }
		if (!(force & FORCE_TID) && (effect.tid || effect.master)) { return false; } // Don't add effects with a tid or a master, because we can't guarantee they'll be spawned back in when they are activated/deactivated
		if (!(force & FORCE_SOLID) && (!effect.bNoDamage && effect.bSolid && !effect.bNoInteraction)) { return false; } // Only add non-solid or non-interactive objects

		return true;
	}

	static bool Add(Actor effect, double range = -1, int force = 0)
	{
		bool cancull = EffectsManager.CanBeCulled(effect, force);

		if (!cancull)
		{
			if (effect is "CullActorBase")
			{
				CullActorBase(effect).bDontCull = true;
			}

			return false;
		}

		EffectsManager manager = EffectsManager.GetManager();
		if (!manager) { return false; }

		manager.AddEffect(effect, range);

		return true;
	}

	static void Remove(Actor effect)
	{
		if (!effect) { return; }

		EffectsManager manager = EffectsManager.GetManager();
		if (!manager) { return; }

		manager.RemoveEffect(effect);
	}

	protected uint FindEffect(Actor effect)
	{
		for (int i = 0; i < effects.Size(); i++)
		{
			if (effects[i] && effects[i].ingame && effects[i].effect == effect) { return i; }
		}
		return effects.Size();
	}

	protected void AddEffect(Actor effect, double range = -1)
	{
		if (!effect) { return; }

		int i = FindEffect(effect);
		if (i == effects.Size()) // Only add it if it's not already there somehow.
		{
			EffectInfo this = New("EffectInfo");

			this.effect = effect;
			this.type = effect.GetClass();
			this.ingame = true;

			SaveEffectInfo(effect, this, range);

			int j = effects.Push(this);

			if (!handler) { handler = ChunkHandler.Get(); }
			if (handler)
			{
				EffectChunk chunk = EffectChunk.FindChunk(effect.pos.x, effect.pos.y, handler.chunks, false);
				if (chunk) { chunk.things.Push(j); }
			}
		}
		else // Otherwise just update what's there...
		{
			SaveEffectInfo(effect, effects[i], range);
		}
	}

	protected void SaveEffectInfo(Actor mo, EffectInfo info, double range = -1)
	{
		info.position = mo.pos;
		info.angle = mo.angle;
		info.pitch = mo.pitch;
		if (mo is "TreesBase")	// Trees have special pitch handling,
		{ 			// due to the fact they can be 2D as well.
			info.pitch = TreesBase(mo).origPitch;
		}
		info.roll = mo.roll;
		info.scale = mo.scale;
		info.master = mo.master;
		info.target = mo.target;
		info.tracer = mo.tracer;
		info.SpawnFlags = mo.SpawnFlags;

		for (int a = 0; a < 5; a++)
		{
			info.args[a] = mo.args[a];
		}

		info.tid = mo.tid;
		info.dormant = mo.bDormant;
		if (range >= 0) { info.range = clamp(range, 1024, 8192); }

		info.sprite = mo.sprite;
		info.frame = mo.frame;
		info.curstate = mo.CurState;

		if (mo is "Blocker")
		{
			info.radius = mo.radius;
			info.height = mo.height;
		}

		info.bflatsprite = mo.bFlatSprite;
		info.bspecial = mo.bSpecial;
		info.bsolid = mo.bSolid;
		info.bshootable = mo.bShootable;
	}

	protected void RemoveEffect(Actor effect)
	{
		if (!effect) { return; }

		int i = FindEffect(effect);
		if (i == effects.Size()) { return; }

		effects[i] = null;
		effect.Destroy();
	}

	override void Tick()
	{
		if (!boa_culling) { return; }
		if (!handler) { handler = ChunkHandler.Get(); }

		handler.UpdateChunks();

		if (level.maptime == 2)
		{
			CullAllEffects(); // Cull everything at map start
		}
		else if (level.maptime > 2 && lastcull < level.time - 5)
		{
			bool culled;
			int cx, cy;
			[culled, cx, cy] = CullEffects(true);

			if (boa_debugculling && !culled)
			{
				console.printf("Last culled: %i, %i", cx, cy);
			}

			lastcull = level.time;
		}
	}

	int, bool Culled(Vector2 pos)
	{
		if (!boa_culling) { return 0, false; }

		if (!handler) { handler = ChunkHandler.Get(); }
		if (handler)
		{
			EffectChunk chunk = EffectChunk.FindChunk(pos.x, pos.y, handler.chunks, false);
			if (chunk) { return chunk.range, chunk.culled; }
		}

		return 0, false;
	}

	bool InRange(Vector3 pos, double range)
	{
		int interval;
		bool forceculled;

		[interval, forceculled] = Culled(pos.xy);
		if (forceculled || interval > (range / CHUNKSIZE) || interval == MAXINTERVAL) { return false; }

		return true;
	}

	protected bool, int, int CullEffects(bool recalculate = false)
	{
		bool ret = true;
		int retx = 0, rety = 0;

		if (!handler) { handler = ChunkHandler.Get(); }
		if (!handler) { return false, 0, 0; }

		int range = clamp(boa_cullrange, 1024, 8192);
		int count = 0;

		for (int p = 0; p < MAXPLAYERS && ret; p++)
		{
			if (!playeringame[p] || !players[p].camera) { continue; }

			Array<EffectChunk> chunks;
			handler.GetChunksInRadius(players[p].camera.pos.xy, range + CHUNKSIZE * players[p].camera.vel.xy.length() / (CHUNKSIZE / 64.0), chunks);
		
			for (int c = 0; c < chunks.Size() && ret; c++)
			{
				// Force removal if outside of the cull range
				bool remove = boa_culling && (chunks[c].distance > range || !chunks[c].infov);

				// Delay culling if this chunk was force culled last time and is still outside of culling range
				if (!recalculate && chunks[c].culled && remove) { continue; }

				// Cull chunks
				if (recalculate || chunks[c].culled || remove) { count += CullChunk(chunks[c], remove); }
				
				// Check against the actor limit and stop processing chunks for this tick if we've exceeded the cap
				if (boa_cullactorlimit > 0 && count > boa_cullactorlimit && !retx && !rety)
				{
					ret = false;
					retx = chunks[c].x;
					rety = chunks[c].y;
				}
			}
		}

		if (boa_debugculling && count) { console.printf("Spawned %i actors in chunk %i, %i", count, retx, rety); }

		return ret, retx, rety;
	}

	protected int CullChunk(EffectChunk chunk, bool forceremove = false)
	{
		if (!chunk) { return 0; }

		int count = 0;

		for (int i = 0; i < chunk.things.Size(); i++)
		{
			count += CullEffect(chunk, chunk.things[i], forceremove);
		}

		// Mark the chunk as culled as appropriate
		chunk.culled = forceremove;

		return count;
	}

	protected void DestroyEffect(EffectInfo e)
	{
		if (!e.effect || !e.ingame || e.effect.bDormant) { return; }

		if (e.effect.health > 0 || e.effect.health == -1)
		{
			if (e.effect is "CullActorBase") { e.wasculled = true; }

			SaveEffectInfo(e.effect, e);

			e.effect.A_RemoveChildren(TRUE, RMVF_MISC);
			e.effect.Destroy();
			e.effect = null;
			e.ingame = false;
		}
	}

	protected bool CullEffect(EffectChunk chunk, int i, bool forceremove = false)
	{
		if (i >= effects.Size()) { return false; }
		if (!effects[i]) { return false; }

		if (effects[i].master && effects[i].master.bDormant)
		{
			effects[i] = null; // If the master is deactivated, don't remember this effect anymore
			return false;
		}

		if (forceremove)
		{
			DestroyEffect(effects[i]);
		}

		bool inrange = false;
		double dist, range;
		bool ret = false;

		range = effects[i].range <= 0 ? boa_sfxlod : effects[i].range;
		range = clamp(min(range, boa_cullrange), 1024, 8192); // Minimum range is 1024, no matter what the CVARs are set to!  boa_cullrange overrides other CVARs.

		if (!boa_culling) { inrange = true; }
		else if (chunk)
		{
			dist = chunk.distance;
			if (dist < range && chunk.infov && abs(chunk.nearestplayer.pos.z - effects[i].position.z) <= range / 2) { inrange = true; }
		}

		if (inrange && !effects[i].ingame)
		{
			Actor effect = Actor.Spawn(effects[i].type, effects[i].position);
			if (effect)
			{
				effect.angle = effects[i].angle;
				effect.pitch = effects[i].pitch;
				effect.roll = effects[i].roll;
				effect.scale = effects[i].scale;
				effect.master = effects[i].master;
				effect.target = effects[i].target;
				effect.tracer = effects[i].tracer;
				effect.SpawnFlags = effects[i].SpawnFlags;
				effect.bDormant = effects[i].dormant;

				for (int a = 0; a < 5; a++)
				{
					effect.args[a] = effects[i].args[a];
				}

				effect.ChangeTID(effects[i].tid);
				if (effect.SpawnFlags & MTF_DORMANT || effects[i].dormant) { effect.SetStateLabel("Inactive"); }

				effect.sprite = effects[i].sprite;
				effect.frame = effects[i].frame;
				if (effects[i].curstate) { effect.SetState(effects[i].curstate); }

				if (effect is "Blocker") { effect.A_SetSize(effects[i].radius, effects[i].height); }

				effect.bFlatSprite = effects[i].bflatsprite;
				effect.bSpecial = effects[i].bspecial;
				effect.bSolid = effects[i].bsolid;
				effect.bShootable = effects[i].bshootable;

				effects[i].effect = effect;
				effects[i].ingame = true;
 
				if (effect is "CullActorBase")
				{
					CullActorBase(effect).bWasCulled = true;
					effect.A_SetRenderStyle(0.0, STYLE_Translucent);
					CullActorBase(effect).targetalpha = effect.Default.alpha;
				}
				else if (effect is "AlertLight") { AlertLight(effect).wasculled = true; }
				else if (effect is "EffectBase") { EffectBase(effect).wasculled = true; }

				ret = true;
			}
		}
		else if (!inrange && effects[i].effect && !effects[i].effect.bDormant)
		{
			if (effects[i].effect is "CullActorBase" && CullActorBase(effects[i].effect).alpha > 0.0)
			{
				CullActorBase(effects[i].effect).targetalpha = 0.0;
			}
			else if (!effects[i].effect.bNoDamage && effects[i].effect.health <= 0) // Don't cull destroyed actors
			{
				effects[i] = null; // ...and stop tracking them
			}
			else
			{
				Actor effect = effects[i].effect;

				if (effect is "CullActorBase") { effects[i].wasculled = true; }

				SaveEffectInfo(effect, effects[i], range);

				effects[i].effect.A_RemoveChildren(TRUE, RMVF_MISC);

				state FadeState = effects[i].effect.FindState("Fade");
				if (effects[i].effect.alpha > 0 && level.maptime > 35 && FadeState) { effects[i].effect.SetState(FadeState); }
				else {
					effects[i].effect = null;
					effect.Destroy();
					effect = null;
					effects[i].ingame = false;
				}
			}
		}
		else if (effects[i].effect && effects[i].effect is "CullActorBase")
		{
			CullActorBase(effects[i].effect).targetalpha = effects[i].effect.Default.alpha;
		}

		return ret;
	}

	protected void CullAllEffects()
	{
		for (int i = 0; i < effects.Size(); i++)
		{
			CullEffect(null, i, true);
		}
	}
}

struct ParticleSpawnPoint { // 48 bytes
	Vector3 worldPos; // World position
	double angle; // Azimuthal and polar angles
	double pitch;
	double distance; // Distance to nearest obstacle
}

const SPAWN_POINTS_PER_SPAWNER = 32;

class EffectSpawner : SwitchableDecoration
{
	ParticleManager manager;
	transient CVar switchcvar;
	String switchvar;
	int range;
	bool user_unmanaged;
	int chunkx, chunky;

	int flags;

	FlagDef AllowTickDelay:flags, 0;
	FlagDef DontCull:flags, 1;
	FlagDef DoActivation:flags, 2;

	Property Range:range;
	Property SwitchVar:switchvar;

	Default
	{
		+EffectSpawner.DoActivation // Automatically activate/deactivate based on DORMANT flag by default
	}

	States
	{
		Spawn:
		Inactive:
			TNT1 A -1;
			Wait;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (switchvar.length()) { switchcvar = CVar.FindCVar(switchvar); }

		manager = ParticleManager.GetManager();
		if (!manager) { return; }

		[chunkx, chunky] = EffectChunk.GetChunk(pos.x, pos.y);

		if (user_unmanaged)
		{
			bDontCull = true;
			bAllowTickDelay = false;
		}

		if (range > 0 && !bDontCull) { EffectsManager.Add(self, range > 0 ? min(range, boa_sfxlod) : boa_sfxlod); }

		if (bDoActivation)
		{
			if (bDormant || SpawnFlags & MTF_DORMANT) { Deactivate(null); }
			else { Activate(null); }
		}

		tics += Random[Effect](0, 35);
	}

	override void Activate(Actor activator)
	{
		if (switchcvar && !switchcvar.GetBool()) { SetStateLabel("Inactive"); }
		else
		{
			bDormant = false;
			SetStateLabel("Active");
		}
	}

	override void Deactivate(Actor activator)
	{
		bDormant = true;
		SetStateLabel("Inactive");
	}

	virtual void SpawnEffect()
	{
		if (!bAllowTickDelay || !manager) { return; }

		tics += curState.tics + manager.GetDelay(chunkx, chunky);
	}
}

class EffectBase : SimpleActor
{
	bool wasculled;

	States
	{
		Inactive:
			"####" A 0 A_Jump(256, "Spawn");
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		if (!wasculled) { EffectsManager.Add(self, boa_sfxlod); }
	}
}

class CullActorBase : Actor
{
	double targetalpha;
	int culllevel;
	int flags;
	int user_dontcull;

	FlagDef WASCULLED:flags, 0;
	FlagDef DONTCULL:flags, 1;

	Property CullLevel:culllevel;

	Default
	{
		// Most actors are level 0; detail and prop actors are 1, and light fixtures are 2
		CullActorBase.CullLevel 0;
	}

	override void PostBeginPlay()
	{
		if (user_dontcull || !boa_culling) { bDontCull = true; }
		targetalpha = Default.alpha;

		Super.PostBeginPlay();
	}

	override void Tick()
	{
		Super.Tick();

		if (!bDontCull && targetalpha >= 0)
		{
			if (targetalpha > alpha)
			{
				alpha = min(targetalpha, alpha + 0.05);
				if (GetRenderStyle() == STYLE_Normal) { A_SetRenderStyle(alpha, STYLE_Translucent); }
			}
			else if (targetalpha < alpha)
			{
				alpha = max(targetalpha, alpha - 0.05);
				if (GetRenderStyle() == STYLE_Normal) { A_SetRenderStyle(alpha, STYLE_Translucent); }
			}

			if (targetalpha == alpha && targetalpha == Default.alpha)
			{
				RestoreRenderStyle();
				targetalpha = -1;
			}
		}
		else if (alpha != Default.alpha)
		{
			alpha = Default.alpha;
			RestoreRenderStyle();
		}
	}

	override void Activate (Actor activator)
	{
		bDormant = false;
		if (FindState("Active", true)) { SetStateLabel("Active"); }
	}

	override void Deactivate (Actor activator)
	{
		bDormant = true;
		if (FindState("Inactive", true)) { SetStateLabel("Inactive"); }
	}

	bool SpawnBlock(double x, double y, double z, double r = -1, double h = -1)
	{
		Actor block = Spawn("Blocker", pos + (RotateVector((x * scale.x, y * scale.x), angle), z * scale.y));

		if (block)
		{
			block.A_SetSize(r, h);
			block.tracer = self;
			
			return true;
		}

		return false;
	}
}

class GrassBase : CullActorBase
{
	class<Actor> fragments;

	Property Fragments:fragments;	

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		if (!bDontCull && !bWasCulled) { EffectsManager.Add(self, boa_grasslod); }
	}
}

class SceneryBase : CullActorBase
{
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		if (!bDontCull && !bWasCulled) { EffectsManager.Add(self, boa_scenelod, EffectsManager.FORCE_SOLID); }
	}
}

class TreesBase : CullActorBase
{
	float origPitch;

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		origPitch = pitch;
		if (!bDontCull && !bWasCulled) { EffectsManager.Add(self, boa_treeslod, EffectsManager.FORCE_SOLID | EffectsManager.FORCE_TID); }
	}

	void A_3DPitchFix()
	{
		// If the player has 2D trees on, and turns them off during a mission...
		pitch = origPitch;
	}

	void A_2DPitchFix()
	{
		if (origPitch > 2 || origPitch < -2)
		{
			bFlatSprite = true;
			pitch = origPitch + 270;
		}
	}
}

class VolumetricBase : CullActorBase
{
	Default
	{
		//$Category Special Effects (BoA)
		//$Color 12
		//$Sprite VOLTA0
		DistanceCheck "boa_scenelod";
		Height 1;
		Radius 1;
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		XScale 0.3;
		YScale 0.45;
		Alpha 0.4;
		RenderStyle "Add";
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		if (!bDontCull && !bWasCulled) { EffectsManager.Add(self, boa_scenelod); }
	}
}

class Blocker : CullActorBase
{
	Default
	{
		+ACTLIKEBRIDGE
		+BRIGHT
		+DONTTHRUST
		+NOBLOOD
		+NODAMAGE
		+NOGRAVITY
		+NOTAUTOAIMED
		+SOLID
		+SHOOTABLE
		+INVISIBLE // Comment out to see the blocks in game for debugging
		Painchance 255;
		Radius 8;
		Height 16;
		Species "Block";
		RenderStyle "Add";
		Alpha 0.95;
	}

	States
	{
		Spawn:
			UNKN A -1;
			Stop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (!bWasCulled && tracer) { A_SetSize(Radius * tracer.scale.x, Height * tracer.scale.y); }

		scale.x = Radius * 2.0;
		scale.y = Height * level.pixelStretch;

		alpha = Default.alpha;

		if (!bWasCulled) { EffectsManager.Add(self, 256.0); } // These are invisible, so only need to be spawned in when immediately near the player
	}
}

class ParticleBase : SimpleActor // Use for non-interactive effects actors only!
{
	int checktimer;
	int flags;

	FlagDef CHECKPOSITION:flags, 0;

	States
	{
		Fade:
			"####" "#" 1 A_FadeOut(0.1, FTF_REMOVE);
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		// Set the initial check at a random tick so they don't all check at once...
		checktimer = Random[Effect](0, 35);
	}

	override void Tick()
	{
		Super.Tick();

		if (bCheckPosition && checktimer-- <= 0)
		{
			// If it's outside the level, remove it
			if (!level.IsPointInLevel(pos)) { Destroy(); return; }

			checktimer = 35; // Check once every second.
		}
	}
}

class BloodBase : ParticleBase
{
	int timer;

	override void Tick()
	{
		Super.Tick();

		if (waterlevel == 3) // Blood that's underwater fades out and gets larger over time until it disappears
		{
			timer++;

			if (timer > 35)
			{
				A_FadeOut(0.05, FTF_REMOVE);
				scale *= 1.1;
			}
		}
	}
}