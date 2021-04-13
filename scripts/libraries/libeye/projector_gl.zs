/*	kd:
	
	In open-gl, your screen rotates nicely and you can do mostly what you know
	to be sane. It's all about making a rotation of your view and using what
	you know about right triangles.
	
	*/

class Le_GlScreen : Le_ProjScreen {
	protected vector3				forw_unit;
	protected vector3				right_unit;
	protected vector3				down_unit;
	
	override void Reorient (vector3 world_view_pos, vector3 world_ang) {
	
		// kd: Pitch is a weird gzd joke. It's probably to compensate looking
		// speed and all. After that, you see what makes this fast.
		world_ang.y = VectorAngle(
			cos(world_ang.y),
			sin(world_ang.y) * pixel_stretch);
		
		
		super.Reorient(world_view_pos, world_ang);
		
		let cosang	= cos(world_ang.x);
		let cosvang	= cos(world_ang.y);
		let cosrang	= cos(world_ang.z);
		let sinang	= sin(world_ang.x);
		let sinvang	= sin(world_ang.y);
		let sinrang	= sin(world_ang.z);
		
		let right_no_roll	= (
			sinang,
		-	cosang,
			0);
		
		let down_no_roll	= (
		-	sinvang * cosang,
		-	sinvang * sinang,
		-	cosvang);
		
		forw_unit = (
			cosvang * cosang,
			cosvang * sinang,
		-	sinvang);
		
		down_unit	= cosrang * down_no_roll	- sinrang * right_no_roll;
		right_unit	= cosrang * right_no_roll	+ sinrang * down_no_roll;
	}
	
	// kd: Projection handling. These get called to make stuff a little faster,
	// since you may wanna project many many times.
	protected vector3				forw_in;
	protected vector3				right_in;
	protected vector3				down_in;
	
	override void BeginProjection () {
		forw_in		= forw_unit;
		right_in	= right_unit / tan_fov_2.x;
		down_in		= down_unit  / tan_fov_2.y;
		
		forw_in.z	*= pixel_stretch;
		right_in.z	*= pixel_stretch;
		down_in.z	*= pixel_stretch;
	}
	
	override void ProjectWorldPos (vector3 world_pos) {
		diff			= levellocals.vec3diff(view_pos, world_pos);
		proj_pos		= (diff dot right_in, diff dot down_in);
		depth			= diff dot forw_in;
	}
	
	override void ProjectActorPos (Actor mo, vector3 offset, double t) {
		let inter_pos	= mo.prev + t * (mo.pos - mo.prev);
		diff			= levellocals.vec3diff(view_pos, inter_pos + offset);
		proj_pos		= (diff dot right_in, diff dot down_in);
		depth			= diff dot forw_in;
	}
	
	override void ProjectActorPosPortal (Actor mo, vector3 offset, double t) {
		let inter_pos	= mo.prev + t * levellocals.vec3diff(mo.prev, mo.pos);
		diff			= levellocals.vec3diff(view_pos, inter_pos + offset);
		proj_pos		= (diff dot right_in, diff dot down_in);
		depth			= diff dot forw_in;
	}
	
	override vector2 ProjectToNormal () const {
		return proj_pos / depth;
	}
	
	override vector2 ProjectToScreen () const {
		let normal_pos = proj_pos / depth + (1, 1);
		
		return 0.5 * (
			normal_pos.x * resolution.x,
			normal_pos.y * resolution.y);
	}
	
	override vector2 ProjectToCustom (
	vector2	origin,
	vector2	resolution) const {
		let normal_pos = proj_pos / depth + (1, 1);
		
		return origin + 0.5 * (
			normal_pos.x * resolution.x,
			normal_pos.y * resolution.y);
	}
	
	// kd: Same deal but backwards-ish.
	protected vector3				forw_out;
	protected vector3				right_out;
	protected vector3				down_out;
	
	override void BeginDeprojection () {
		
		// kd: Same deal as above, but reversed. This time, we're compensating
		// for what we rightfully assume is a projected position.
		forw_out	= forw_unit;
		right_out	= right_unit * tan_fov_2.x;
		down_out	= down_unit  * tan_fov_2.y;
		
		forw_out.z	/= pixel_stretch;
		right_out.z /= pixel_stretch;
		down_out.z	/= pixel_stretch;
	}
	
	override vector3 DeprojectNormalToDiff (
	vector2	normal_pos,
	double	depth) const {
		return depth * (
			forw_out +
			normal_pos.x * right_out +
			normal_pos.y * down_out);
	}
	
	override vector3 DeprojectScreenToDiff (
	vector2	screen_pos,
	double	depth) const {
	
		// kd: Same thing...
		let normal_pos = 2 * (
			screen_pos.x / resolution.x,
			screen_pos.y / resolution.y) - (1, 1);
		
		return depth * (
			forw_out +
			normal_pos.x * right_out +
			normal_pos.y * down_out);
	}
}