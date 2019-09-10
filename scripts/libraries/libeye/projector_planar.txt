/*	kd:
	
	This does projection stuff in Carmack / software renderer. It's conceptually
	simpler, but nonetheless a little tricky to understand if you're
	used to open-gl.
	
	*/

class Le_SwScreen : Le_ProjScreen {
	
	// kd: Less info necessary than for open-gl, but it's there.
	protected vector2				right_planar_unit;
	protected vector3				forw_planar_unit;
	
	override void Reorient (vector3 world_view_pos, vector3 world_ang) {
		super.Reorient(world_view_pos, world_ang);
		
		right_planar_unit = (
			sin(view_ang.x),
		-	cos(view_ang.x));
		
		forw_planar_unit = (
		-	right_planar_unit.y,
			right_planar_unit.x,
			tan(view_ang.y));
	}
	
	// kd: Projection:
	protected vector3				forw_planar_in;
	protected vector2				right_planar_in;
	
	override void BeginProjection () {
		
		// kd: This doesn't cause any imprecisions. It also prevents two
		// multiplications with every projection.
		right_planar_in		= right_planar_unit / tan_fov_2.x;
		forw_planar_in		= forw_planar_unit;
	}
	
	override void ProjectWorldPos (vector3 world_pos) {
		
		// kd: Your view is flat. If you pitch up or down, imagine that all the
		// actors move up and down in reality. That's effectively how it works.
		// You can see this in the addition to diff.z.
		diff		= levellocals.vec3diff(view_pos, world_pos);
		depth		= forw_planar_in.xy dot diff.xy;
		diff.z		+= forw_planar_in.z * depth;
		proj_pos	= (
			right_planar_in dot diff.xy,
		-	pixel_stretch * diff.z / tan_fov_2.y);
	}
	
	override void ProjectActorPos (Actor mo, vector3 offset, double t) {
		let inter_pos = mo.prev + t * (mo.pos - mo.prev);
		ProjectWorldPos(inter_pos + offset);
	}
	
	override void ProjectActorPosPortal (Actor mo, vector3 offset, double t) {
		let inter_pos = mo.prev + t * levellocals.vec3diff(mo.prev, mo.pos);
		ProjectWorldPos(inter_pos + offset);
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
	
	// kd: Just as simple. You again assume you are trying to reverse a
	// projected position from the screen back into the world.
	protected vector3				forw_planar_out;
	protected vector3				right_planar_out;
	protected vector3				down_planar_out;
	
	override void BeginDeprojection () {
		forw_planar_out.xy	= forw_planar_unit.xy;
		forw_planar_out.z	= 0;
		right_planar_out.xy	= tan_fov_2.x * right_planar_unit;
		right_planar_out.z	= 0;
		down_planar_out		= (
			0,
			0,
			tan_fov_2.y / pixel_stretch);
	}
	
	override vector3 DeprojectNormalToDiff (
	vector2	normal_pos,
	double	depth) const {
		return depth * (
			forw_planar_out +
			normal_pos.x * right_planar_out +
		-	(0, 0, forw_planar_unit.z) - normal_pos.y * down_planar_out);
	}
	
	override vector3 DeprojectScreenToDiff (
	vector2	screen_pos,
	double	depth) const {
	
		// kd: Same thing...
		let normal_pos = 2 * (
			screen_pos.x / resolution.x,
			screen_pos.y / resolution.y) - (1, 1);
		
		return depth * (
			forw_planar_out +
			normal_pos.x * right_planar_out +
		-	(0, 0, forw_planar_unit.z) - normal_pos.y * down_planar_out);
	}
}