/*
 * Copyright (c) 2017-2020 AFADoomer
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

// Map definition stays at its map position. Each player's view is calculated
// on every peer; only the choice of the rendered view is clientside.
class SkyViewPointStatic : SkyViewPoint
{
	Actor anchor;
	SkyViewPointStaticView views[MAXPLAYERS];
	int anchorRevision;
	bool initialized;
	transient bool viewsBound;
	Default
	{
		//$Category Skyboxes (BoA)
		//$Title Skybox ViewPoint (Static)
		//$Arg1 "Skybox Scene Scale"
		//$Arg1Tooltip "The scale of the skybox's scene (default is 100).  The larger this number is, the farther away the skybox contents will appear to be."
		//$Arg1Default 100
		//$Arg2 "Anchor Object TID"
		//$Arg2Tooltip "TID of an actor to anchor the skybox on.  Default value (0) means to anchor on player start spot."
		//$Arg2Default 0
		//$Arg3 "Make this the default sky"
		//$Arg3Tooltip " Should this become the default sky (as if it had no TID)?\nThis allows setting a starting TID on the viewpoint, but still setting the default level sky."
		//$Arg3Type 11
		//$Arg3Enum { 0 = "False"; 1 = "True"; }
		//$Arg3Default 0
		+NOCLIP
		Height 0;
		Radius 0;
	}

	void UpdateViews()
	{
		for (int p = 0; p < MAXPLAYERS; p++)
		{
			if (!playeringame[p] || !players[p].mo || views[p]) { continue; }
			let view = SkyViewPointStaticView(Spawn("SkyViewPointStaticView", pos));
			if (view)
			{
				view.source = self; view.pnum = p; view.angle = angle; view.args[0] = args[0];
				view.ChangeTID(level.FindUniqueTID()); views[p] = view;
			}
		}
	}
	clearscope SkyViewPointStaticView GetView(int pnum) { return views[pnum]; }
	static void SetAnchor(int tid, int anchorid = -1)
	{
		if (!tid) { return; }
		let it = Level.CreateActorIterator(tid, "SkyViewPointStatic");
		let mo = SkyViewPointStatic(it.Next());
		if (!mo) { Console.Printf("ERROR: Invalid SkyViewPointStatic TID."); return; }
		if (anchorid < 0 && mo.args[2] != 0) { anchorid = mo.args[2]; }
		if (anchorid > 0) { let anchors = Level.CreateActorIterator(anchorid, "Actor"); mo.anchor = anchors.Next(); }
		mo.anchorRevision++;
	}
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		SpawnPoint = pos; initialized = true;
		if (!tid) { ChangeTID(level.FindUniqueTID()); }
		SetAnchor(tid); UpdateViews();
		BindViews(true);
	}
	void BindViews(bool setDefault = false)
	{
		for (int i = 0; i < level.sectors.Size(); i++)
		{
			let sec = level.sectors[i];
			for (int plane = 0; plane < 2; plane++)
			{
				let box = level.sectorPortals[sec.Portals[plane]].mSkybox;
				let oldView = SkyViewPointStaticView(box);
				if (sec.GetPortalType(plane) == SectorPortal.TYPE_SKYVIEWPOINT && ((setDefault && args[3] > 0) || box == self || (oldView && oldView.source == self)))
				{
					let picker = SpawnClientSide("BoAStaticSkyPicker");
					if (picker) { picker.CurSector = sec; picker.args[0] = tid; picker.args[1] = plane == sector.ceiling ? 1 : 2; }
				}
			}
		}
		viewsBound = true;
	}
	override void Tick()
	{
		Super.Tick();
		// Older saves stored the moving view in this actor and its original
		// map position in SpawnPoint. Restore that origin before creating views.
		if (!initialized) { SetXYZ(SpawnPoint); initialized = true; }
		UpdateViews();
		// Serialized sector portals may contain another peer's selected view.
		if (!viewsBound) { BindViews(); }
	}
	override void OnDestroy()
	{
		for (int p = 0; p < MAXPLAYERS; p++) { if (views[p]) { views[p].Destroy(); } }
		Super.OnDestroy();
	}
}

class SkyViewPointStaticView : SkyViewPoint
{
	SkyViewPointStatic source;
	Actor base;
	Vector3 fallbackAnchor;
	Vector2 anchoroffset;
	int pnum, revision;
	bool anchored;
	Default { +NOCLIP Height 0; Radius 0; }
	// Never replace the default sky during construction of an auxiliary view.
	override void BeginPlay() { Actor.BeginPlay(); }
	override void Tick()
	{
		Super.Tick();
		if (!source) { Destroy(); return; }
		if (!playeringame[pnum] || !players[pnum].mo) { return; }
		let handler = InteractionHandler(EventHandler.Find("InteractionHandler"));
		let camera = handler ? handler.skyCameras[pnum] : null;
		if (!camera) { camera = players[pnum].mo; }
		if (!camera) { return; }
		bool changed = base != camera; base = camera;
		if (!anchored || revision != source.anchorRevision)
		{
			if (!anchored) { fallbackAnchor = players[pnum].mo.pos; }
			anchoroffset = (0, 0); revision = source.anchorRevision; anchored = true; changed = true;
		}
		Vector3 anchorpos = source.anchor ? source.anchor.pos : fallbackAnchor;
		double scaling = source.args[1] == 0 ? 100 : source.args[1];
		Vector2 offset = RotateVector((base.pos.xy - anchorpos.xy) / scaling, source.angle);
		double eye = base.player ? base.player.viewz : base.pos.z;
		double heightdelta = (eye - anchorpos.z) / scaling / 2;
		Vector3 dest = (source.pos.xy + offset - anchoroffset, source.pos.z + heightdelta);
		double dist = (dest.xy - pos.xy).length(); angle = source.angle;
		if (changed || base.bTeleport || dist <= 32 || level.time < 5 || source.bStandStill)
		{
			SetXYZ(dest); if (changed || base.bTeleport) { ClearInterpolation(); }
		}
		else { anchoroffset = (source.pos.xy + offset) - pos.xy; }
	}
}

// Map pickers remain synchronized. Only a reference to a personal BoA skybox
// is forwarded to an explicitly spawned local selector; other skies use the
// unchanged engine implementation.
class BoAMapSkyPicker : SkyPicker replaces SkyPicker
{
	override void PostBeginPlay()
	{
		if (args[0] != 0)
		{
			let it = Level.CreateActorIterator(args[0], "SkyViewPointStatic");
			if (it.Next())
			{
				let picker = SpawnClientSide("BoAStaticSkyPicker");
				if (picker)
				{
					picker.CurSector = CurSector;
					picker.args[0] = args[0]; picker.args[1] = args[1];
					Destroy(); return;
				}
			}
		}
		Super.PostBeginPlay();
	}
}

// Engine SkyPicker owns the native portal writes. This clientside adapter
// selects a synchronized view without spawning local networked actors.
// Spawn this explicitly: replacing the synchronized map SkyPicker with a
// CLIENTSIDE actor is forbidden and would affect unrelated map sky pickers.
class BoAStaticSkyPicker : SkyPicker
{
	Default { +CLIENTSIDE }
	override void PostBeginPlay() { SelectView(); }
	override void Tick() { SelectView(); }
	void SelectView()
	{
		let it = Level.CreateActorIterator(args[0], "SkyViewPointStatic");
		let definition = args[0] ? SkyViewPointStatic(it.Next()) : null;
		if (definition)
		{
			let view = definition.GetView(consoleplayer);
			if (!view) { return; }
			args[0] = view.tid;
		}
		Super.PostBeginPlay();
	}
}

class SkyViewpointAnchor : MapSpot
{
	Default
	{
		//$Category Skyboxes (BoA)
		//$Title Skybox ViewPoint Anchor
		//$NotAngled
	}
}
