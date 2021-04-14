/*	kd:
	
	Here's how to do projections and deprojections. You'd use the subclasses
	to do anything worthwhile. You may project world to screen and backwards.
	
	*/

class Le_ProjScreen {
	
	// kd: Screen info
	protected vector2				resolution;
	protected vector2				origin;
	protected vector2				tan_fov_2;
	protected double				pixel_stretch;
	protected double				aspect_ratio;
	
	// kd: Setup calls which you'll need to call at least once.
	void CacheResolution () {
		CacheCustomResolution((Screen.GetWidth(), Screen.GetHeight()) );
	}
	
	void CacheCustomResolution (vector2 new_resolution) {
		
		// kd: This is for convenience and converting normal <-> screen pos.
		resolution = new_resolution;
		
		// kd: This isn't really necessary but I kinda like it.
		pixel_stretch = level.pixelstretch;
		
		// kd: Get the aspect ratio. 5:4 is handled just like 4:3... I GUESS
		// this'll do.
		aspect_ratio = max(4.0 / 3, Screen.GetAspectRatio());
	}
	
	double AspectRatio () const {
		return aspect_ratio;
	}
	
	// kd: Once you know you got screen info, you can call this whenever your
	// fov changes. Like CacheFov(player.fov) will do.
	void CacheFov (double hor_fov = 90) {
	
		// kd: This holds: aspect ratio = tan(horizontal fov) / tan(ver fov).
		// gzd always uses hor fov, but the fov only holds in 4:3 (in a 4:3 box
		// in your screen centre), so we just extend it.
		tan_fov_2.x	= tan(hor_fov / 2) * aspect_ratio / (4.0 / 3);
		tan_fov_2.y	= tan_fov_2.x / aspect_ratio;
	}
	
	// kd: Also need some view info. Angle is yaw, pitch, roll in world format
	// so positive pitch is up. Call one of the following functions.
	protected vector3				view_ang;
	protected vector3				view_pos;
	
	ui void OrientForRenderOverlay (RenderEvent event) {
		Reorient(
			event.viewpos, (
			event.viewangle,
			event.viewpitch,
			event.viewroll));
	}
	
	ui void OrientForRenderUnderlay (RenderEvent event) {
		Reorient(
			event.viewpos, (
			event.viewangle,
			event.viewpitch,
			event.viewroll));
	}
	
	void OrientForPlayer (PlayerInfo player) {
		Reorient(
			player.mo.vec3offset(0, 0, player.viewheight), (
			player.mo.angle,
			player.mo.pitch,
			player.mo.roll));
	}
	
	virtual void Reorient (vector3 world_view_pos, vector3 world_ang) {
		view_ang = world_ang;
		view_pos = world_view_pos;
	}
	
	// kd: Now we can do projections and such (position in the level, go to
	// your screen).
	protected double				depth;
	protected vector2				proj_pos;
	protected vector3				diff;
	
	virtual void	BeginProjection	() {}
	virtual void	ProjectWorldPos	(vector3 world_pos) {}
	virtual void	ProjectActorPos (
	Actor	mo,
	vector3	offset = (0,0,0),
	double	t = 1) {}
	
	// kd: Portal aware version.
	virtual void	ProjectActorPosPortal (
	Actor	mo,
	vector3	offset = (0,0,0),
	double	t = 1) {}
	
	virtual vector2	ProjectToNormal	() const { return (0, 0); }
	virtual vector2	ProjectToScreen	() const { return (0, 0); }
	
	virtual vector2 ProjectToCustom (
	vector2 origin,
	vector2 resolution) const {
		return (0, 0);
	}
	
	bool IsInFront () const {
		return 0 < depth;
	}
	
	bool IsInScreen () const {
		if(	proj_pos.x < -depth || depth < proj_pos.x ||
			proj_pos.y < -depth || depth < proj_pos.y) {
			return false;
		}
		
		return true;
	}
	
	// kd: Deprojection (point on screen, go into the world):
	virtual void	BeginDeprojection		() {}
	
	virtual vector3	DeprojectNormalToDiff	(
	vector2	normal_pos,
	double	depth = 1) const {
		return (0, 0, 0);
	}
	
	virtual vector3	DeprojectScreenToDiff	(
	vector2	screen_pos,
	double	depth = 1) const {
		return (0, 0, 0);
	}
	
	virtual vector3 DeprojectCustomToDiff (
	vector2	origin,
	vector2	resolution,
	vector2	screen_pos,
	double	depth = 1) const {
		return (0, 0, 0);
	}
	
	// kd: A normal position is in the -1 <= x, y <= 1 range on your screen.
	// This will be your screen no matter the resolution:
	
	/*
	
	(-1, -1) --	---	---	(0, -1) ---	---	---	---	(1, -1)
	|												|
	|												|
	|												|
	(-1, 0)				(0, 0)					(1, 0)
	|												|
	|												|
	|												|
	(-1, 1)	---	---	---	(0, 1)	---	---	---	---	(1, 1)
	
	*/
	
	// So this scales such a position back into your drawing resolution.
	
	vector2 NormalToScreen (vector2 normal_pos) const {
		normal_pos = 0.5 * (normal_pos + (1, 1));
		return (
			normal_pos.x * resolution.x,
			normal_pos.y * resolution.y);
	}
	
	// kd: And this brings a screen position to normal. Make sure the resolution
	// is the same for your cursor.
	
	vector2 ScreenToNormal (vector2 screen_pos) const {
		screen_pos = (
			screen_pos.x / resolution.x,
			screen_pos.y / resolution.y);
		return 2 * screen_pos - (1, 1);
	}
	
	// kd: Other interesting stuff.
	
	vector3 Difference () const {
		return diff;
	}
	
	double Distance () const {
		return diff.length();
	}
}
