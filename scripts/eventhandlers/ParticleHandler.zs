class ParticleManager : EventHandler
{
	Array<Actor> particlequeue;
	Array<Actor> bloodqueue;
	Array<Actor> debrisqueue;
	Array<Actor> flatdecalqueue;
	transient CVar maxparticlescvar;
	transient CVar maxbloodcvar;
	transient CVar maxdebriscvar;
	transient CVar maxflatdecalscvar;
	int maxparticles, maxblood, maxdebris, maxflatdecals;
	int tickdelay;
	double particlescaling;
	EffectsManager effectmanager;
	
	override void OnRegister()
	{
		maxparticlescvar = CVar.FindCVar("boa_maxparticleactors");
		maxbloodcvar = CVar.FindCVar("sv_corpsequeuesize");
		maxdebriscvar = CVar.FindCVar("boa_maxdebrisactors");
		maxflatdecalscvar = CVar.FindCVar("boa_maxflatdecals");

		maxparticles = 512;
		if (maxparticlescvar) { maxparticles = max(1, maxparticlescvar.GetInt()); }

		maxblood = 1024;
		if (maxbloodcvar) { maxblood = max(1, maxbloodcvar.GetInt()); }

		maxdebris = 64;
		if (maxdebriscvar) { maxdebris = max(1, maxdebriscvar.GetInt()); }

		maxflatdecals = 256;
		if (maxflatdecalscvar) { maxflatdecals = max(1, maxflatdecalscvar.GetInt()); }
	}

	override void WorldThingSpawned(WorldEvent e)
	{
		if (
			e.thing is "Blood" ||			// NashGore actors (and engine default blood)
			e.thing is "BloodSplatter" ||
			e.thing is "NashGore_BloodBase" ||
			e.thing is "BloodPool2" || 		// Droplets actors
			e.thing is "GibletA" || 
			e.thing is "BloodDrop1" ||
			e.thing is "CeilDripper" ||
			e.thing is "BloodFog" ||
			e.thing is "UWBloodFog"
		)
		{
			if (maxbloodcvar) { maxblood = max(0, maxbloodcvar.GetInt()); }
			if (!maxblood) { e.thing.Destroy(); return; }

			bloodqueue.Insert(0, e.thing);
			ConsolidateArray(bloodqueue, maxblood);
		}
		else if (
			e.thing is "Casing9mm" ||		// All shell casings
			e.thing is "Debris_Base"		// Explosion/breakage debris
		)
		{
			if (maxdebriscvar) { maxdebris = max(0, maxdebriscvar.GetInt()); }
			if (!maxdebris) { e.thing.Destroy(); return; }

			debrisqueue.Insert(0, e.thing);
			ConsolidateArray(debrisqueue, maxdebris);
		}
		else if (
			e.thing is "ZFlatDecal"			// Flat decals
		)
		{
			if (maxflatdecalscvar) { maxflatdecals = max(0, maxflatdecalscvar.GetInt()); }
			if (!maxflatdecals) { e.thing.Destroy(); return; }

			flatdecalqueue.Insert(0, e.thing);
			ConsolidateArray(flatdecalqueue, maxflatdecals);
		}
		else if (
			e.thing is "SplashParticleBase"	||	// Ground splash particle actors
			e.thing is "ParticleBase" || 		// Handle all other ParticleBase actors last so that the above can inherit from ParticleBase and still get their own queues
			e.thing is "LightningBeam"		// Lightning segments
		)
		{
			if (maxparticlescvar) { maxparticles = max(0, maxparticlescvar.GetInt()); }
			if (!maxparticles) { e.thing.Destroy(); return; }

			particlequeue.Insert(0, e.thing);
			ConsolidateArray(particlequeue, maxparticles);

			int size = particlequeue.Size();
			if (size > maxparticles * 0.75) { tickdelay = clamp(int((size - (maxparticles * 0.75)) / (maxparticles * 0.25) * 10), 0, 10); }
			else { tickdelay = 0; }

			particlescaling = max(0.1, 1.0 - (tickdelay / 10));

			// Debug output: particle queue size and current tick delay
			if (boa_debugparticles && level.time % 35 == 0) { console.printf("%i of %i particles, %i tick delay", size, maxparticles, tickdelay); }
		}
	}

	static ParticleManager GetManager()
	{
		return ParticleManager(EventHandler.Find("ParticleManager"));
	}

	void ConsolidateArray(in out Array<Actor> input, int limit)
	{
		Array<Actor> t;
		int count = 0;

		for (int s = 0; s < input.Size(); s++)
		{
			if (!input[s]) { continue; }

			if (count >= limit)
			{
				state FadeState = input[s].FindState("Fade");

				if (FadeState) { input[s].SetState(FadeState); }
				else { input[s].Destroy(); }
			}
			else { t.Push(input[s]); }

			count++;
		}

		input.Move(t);
	}

	int GetDelay(int chunkx, int chunky, Actor origin = null)
	{
		if (!effectmanager) { effectmanager = EffectsManager.GetManager(); }

		if (origin)
		{
			[chunkx, chunky] = EffectBlock.GetBlock(origin.pos.x, origin.pos.y);
		}

		if (effectmanager && effectmanager.effectblocks[chunkx][chunky])
		{
			double interval = effectmanager.effectblocks[chunkx][chunky].cullinterval;

			if (interval > 1)
			{
				int maxinterval = clamp(boa_cullrange, 1024, 8192) / CHUNKSIZE;
				double delayfactor = interval / maxinterval;
				delayfactor = delayfactor ** 2 * interval;

				return int(tickdelay * delayfactor);
			}
			else {return 0; }
		}

		return tickdelay;
	}
}