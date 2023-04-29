// Hitscan-model collision by N00b (March 2023)
// Based on actor-model collision demo by ZZYZX: https://forum.zdoom.org/viewtopic.php?f=122&t=59069 (2018--2022)

class C3DVertex { Vector3 v; }
class C3DTriangle
{
	C3DVertex v1, v2, v3;
	int iv1, iv2, iv3;
	Vector3 normal;
	string group;
	Vector3 CalculateNormal(Vector3 vv1, Vector3 vv2, Vector3 vv3)
	{
		Vector3 norm;
		Vector3 norm_U = vv2 - vv1;
		Vector3 norm_V = vv3 - vv1;
		norm.x = norm_U.y * norm_V.z - norm_U.z * norm_V.y;
		norm.y = norm_U.z * norm_V.x - norm_U.x * norm_V.z;
		norm.z = norm_U.x * norm_V.y - norm_U.y * norm_V.x;
		return norm.Unit();
	}
	void CalculateNormals()
	{
		normal = CalculateNormal(v1.v, v2.v, v3.v);
	}
}

class C3DFrame { Array<C3DVertex> vertices; }
class C3DSurface { Vector3 normal; Array<C3DTriangle> triangles; }

class C3DCollision : Inventory
{
	Array<C3DFrame> frames;
	C3DFrame frame;
	Array<C3DTriangle> triangles;
	Array<C3DSurface> surfaces;
	Vector3 p_scale;
	double p_angle, p_pitch, p_roll;
	Vector3 p_mtranslation;
	bool hasmodel;
    bool Init(string model)
	{
		int fnum = Wads.CheckNumForFullName(model);
		if (fnum < 0)
		{
			if (model != "") { Console.Printf("\034GError: unable to open \"%s\"", model); }
			else if (developer > 0) { Console.Printf("\034GAdded a tank vehicle without model"); }
			return false;
		}
		let lump = LumpStream.Create(fnum);
		if (!lump) { Console.Printf("\034GError: unable to load \"%s\"", model); return false; }
		let br = BinaryReader.Create(lump);
		lump.Seek(0, SEEK_Begin);
		int md3_ident = br.ReadInt32();
		if (md3_ident != 0x33504449) { Console.Printf("\034GError: \"%s\" is not an MD3 file", model); return false; }
		int md3_version = br.ReadInt32();
		if (md3_version != 15) { Console.Printf("\034GError: \"%s\": unsupported MD3 version %d", model, md3_version); return false; }
		string md3_name = br.ReadString(64);
		int md3_flags = br.ReadInt32();
		int md3_frames = br.ReadInt32();
		int md3_tags = br.ReadInt32();
		int md3_surfaces = br.ReadInt32();
		int md3_skins = br.ReadInt32();
		int md3_frames_offs = br.ReadInt32();
		int md3_tags_offs = br.ReadInt32();
		int md3_surfaces_offs = br.ReadInt32();
		int md3_skins_offs = br.ReadInt32();
		lump.Seek(md3_surfaces_offs, SEEK_Begin);
		for (int i = 0; i < md3_frames; i++) { C3DFrame frame = new('C3DFrame'); frames.Push(frame); }
		int ARRAYVERTOFFSET = 0;
        int currsurf_offs = md3_surfaces_offs;
		for (int i = 0; i < md3_surfaces; ++i)
		{
			int surf_ident = br.ReadInt32();
            if (surf_ident != 0x33504449) { Console.Printf("\034GError: \"%s\": invalid MD3 surface section identifier %08X (expected IDP3)", model, surf_ident); return false; }
            string surf_name = br.ReadString(64);
			int surf_flags = br.ReadInt32();
			int surf_frames = br.ReadInt32();
			int surf_shaders = br.ReadInt32();
			int surf_verts = br.ReadInt32();
            int surf_triangles = br.ReadInt32();
			int surf_triangles_offs = br.ReadInt32();
			int surf_shaders_offs = br.ReadInt32();
			int surf_st_offs = br.ReadInt32();
            int surf_verts_offs = br.ReadInt32();
			int surf_end_offs = br.ReadInt32();
			lump.Seek(currsurf_offs+surf_verts_offs, SEEK_Begin);
            for (int i = 0; i < md3_frames; i++)
			{
				for (int j = 0; j < surf_verts; j++)
				{
					C3DVertex v = new('C3DVertex');
					v.v.x = double(br.ReadInt16()) / 64;
					v.v.y = double(br.ReadInt16()) / 64;
					v.v.z = double(br.ReadInt16()) / 64;
					int vx_normal = br.ReadInt16();
					frames[i].vertices.Push(v);
				}
			}
			lump.Seek(currsurf_offs+surf_triangles_offs, SEEK_Begin);
            for (int i = 0; i < surf_triangles; i++)
			{
				C3DTriangle tri = new('C3DTriangle');
				tri.iv1 = ARRAYVERTOFFSET + br.ReadInt32();
				tri.iv2 = ARRAYVERTOFFSET + br.ReadInt32();
				tri.iv3 = ARRAYVERTOFFSET + br.ReadInt32();
				tri.group = surf_name;
				triangles.Push(tri);
			}
			ARRAYVERTOFFSET += surf_verts;
			currsurf_offs += surf_end_offs;
			lump.Seek(currsurf_offs, SEEK_Begin);
		}
		SetFrame(0);
		hasmodel = true;
		return true;
	}
	void SetFrame(int index)
	{
		C3DFrame frame = frames[index];
		for (int i = 0; i < triangles.Size(); i++)
		{
			C3DTriangle triangle = triangles[i];
			triangle.v1 = frame.vertices[triangle.iv1];
			triangle.v2 = frame.vertices[triangle.iv2];
			triangle.v3 = frame.vertices[triangle.iv3];
			triangle.CalculateNormals();
		}
		self.frame = frame;
	}
	C3DSurface GetSurface(Vector3 normal)
	{
		for (int i = 0; i < surfaces.Size(); i++)
		{
			if (surfaces[i].normal == normal) { return surfaces[i]; }
		}
		C3DSurface surf = new ('C3DSurface');
		surf.normal = normal;
		surfaces.Push(surf);
		return surf;
	}
	Vector3 PointToModel(Vector3 point)
	{
		Vector3 deltaW = point - owner.pos, bp = deltaW, bp_rotated = bp;
		bp_rotated.x = bp.x * cos(p_angle) + bp.y * sin(p_angle); bp_rotated.y = bp.y * cos(p_angle) - bp.x * sin(p_angle); bp = bp_rotated;
		bp_rotated.z = bp.z * cos(p_pitch) + bp.x * sin(p_pitch); bp_rotated.x = bp.x * cos(p_pitch) - bp.z * sin(p_pitch); bp = bp_rotated;
		bp_rotated.y = bp.y * cos(p_roll) + bp.z * sin(p_roll); bp_rotated.z = bp.z * cos(p_roll) - bp.y * sin(p_roll);
		bp = bp_rotated - p_mtranslation;
		return (bp.x / p_scale.x, bp.y / p_scale.y, bp.z * level.pixelstretch / p_scale.z);
	}
	void SetModelTranslation(Vector3 mt) { p_mtranslation = mt; }
	void SetScale(Vector3 s) { p_scale = s; }
	void SetAngle(double a) { p_angle = a; }
	void SetPitch(double p) { p_pitch = p; }
	void SetRoll(double r) { p_roll = r; }
	const NUMMARKERS = 1;
	void SpawnMarkers(Vector3 a1, Vector3 a2, Vector3 a3) /* spawns markers on the model triangles, was used to debug the parser */
	{
		Color s = Color(random(0, 255), random(0, 255), random(0, 255), 255);
		for (int i = 0; i <= NUMMARKERS; ++i)
		{
			for (int j = 0; j <= NUMMARKERS - i; ++j)
			{
				let q = Spawn("Marker", a1 + i * (a2-a1) / NUMMARKERS + j * (a3-a1) / NUMMARKERS);
				q.A_SetRenderStyle(1.0, STYLE_STENCIL); q.SetShade(s);
			}
		}
	}
}

class ModelHitbox: Base abstract
{
	C3DCollision coll;
	string modelname;
	property Model: modelname;
	Default
	{
		Radius 32;
		Height 32;
		Health 1000;
	}
	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		GiveInventory('C3DCollision', 1, false);
		coll = C3DCollision(FindInventory('C3DCollision', false));
		if (!coll.Init(modelname)) { coll = null; return; } //'cardboard' vehicle like 251 or 222
		//if (!coll) { Console.Printf("ModelHitbox "..GetClassName().." does not exist"); return; }
		coll.SetFrame(0);
		coll.SetAngle(angle);
		coll.SetPitch(pitch);
		coll.SetRoll(roll);
	}
	Vector3, double, int TryCollideWithHitscan(Actor inflictor) const
	{
		if (!coll)
		{
			//Console.Printf("No model to calculate collision results for "..GetClassName());
			return (0, 0, 0), 0, +1;
		}
        if (inflictor is "Bullet")
		{
			double ipitch = inflictor.pitch, iangle = inflictor.angle;
			Vector3 delta, origin = coll.PointToModel(inflictor.pos);
			Vector3 dir = coll.PointToModel(inflictor.pos + (cos(ipitch) * cos(iangle), cos(ipitch) * sin(iangle), -sin(ipitch))) - origin;
			dir = dir.Unit();
			/*the above might be prone to catastrophic cancellation with exceptionally large distances, but our distances never exceed 114k, so double precision is more than enough */
			double first = 1000000000, newf;
			int firstindex = -1;
			coll.p_angle = angle; coll.p_pitch = pitch; coll.p_roll = roll;
            for (int i = 0; i < coll.triangles.Size(); ++i)
			{
				Vector3 p1 = coll.triangles[i].v1.v - origin, p2 = coll.triangles[i].v2.v - origin, p3 = coll.triangles[i].v3.v - origin, v = ZScriptTools.BasisCoefficients(p1, p2, p3, dir);
				if (v != v) { continue; }
				if (v.x >= 0 && v.y >= 0 && v.z >= 0)
				{
					double s = v.x + v.y + v.z;
					if (s <= 0) { continue; }
					v /= s;
                    delta = (v.x * p1 + v.y * p2 + v.z * p3);
					newf = delta.length();
					if (newf < first) { first = newf; firstindex = i; }
				}
			}
            if (firstindex < 0) { return (0,0,0), 1e9, -1; }
			else
			{
				int thickness = coll.triangles[firstindex].group.ToInt(10);
				double cosine = coll.triangles[firstindex].normal.Unit() dot dir;
				double derived = 10000.0, b = 0.01;
				if (cosine < 0) { cosine = -cosine; }
				if (cosine > b) { derived = double(thickness) / cosine; }
				return delta, first, int(derived);
			}
		}
		Console.Printf("Error: non-Bullet actor "..inflictor.GetClassName().." called TryCollideWithHitscan.");
		return (0,0,0), 1e9, -1;
	}
	States
	{
	Spawn:
		MDLA A -1;
		Stop;
	}
}

class Marker: Actor { Default { Radius 1; Height 1; Scale 0.2; +NOGRAVITY +NOBLOCKMAP } States { Spawn: PLSS A -1; Stop; } }