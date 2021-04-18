/*
   Matrix Math helper class.
   (C)2018 Marisa Kirisame, UnSX Team.
   Released under the GNU Lesser General Public License version 3 (or later).
   See https://www.gnu.org/licenses/lgpl-3.0.txt for its terms.
*/

Class BoAMatrix4
{
	private double m[16];

	BoAMatrix4 init()
	{
		int i;
		for ( i=0; i<16; i++ ) m[i] = 0;
		return self;
	}

	static BoAMatrix4 create()
	{
		return new("BoAMatrix4").init();
	}

	static BoAMatrix4 identity()
	{
		BoAMatrix4 o = BoAMatrix4.create();
		for ( int i=0; i<4; i++ ) o.set(i,i,1);
		return o;
	}

	double get( int c, int r )
	{
		return m[r*4+c];
	}

	void set( int c, int r, double v )
	{
		m[r*4+c] = v;
	}

	BoAMatrix4 add( BoAMatrix4 o )
	{
		BoAMatrix4 r = BoAMatrix4.create();
		int i, j;
		for ( i=0; i<4; i++ ) for ( j=0; j<4; j++ )
			r.set(j,i,get(j,i)+o.get(j,i));
		return r;
	}

	BoAMatrix4 scale( double s )
	{
		BoAMatrix4 r = BoAMatrix4.create();
		int i, j;
		for ( i=0; i<4; i++ ) for ( j=0; j<4; j++ )
			r.set(j,i,get(j,i)*s);
		return r;
	}

	BoAMatrix4 mul( BoAMatrix4 o )
	{
		BoAMatrix4 r = BoAMatrix4.create();
		int i, j;
		for ( i=0; i<4; i++ ) for ( j=0; j<4; j++ )
			r.set(j,i,get(0,i)*o.get(j,0)+get(1,i)*o.get(j,1)+get(2,i)*o.get(j,2)+get(3,i)*o.get(j,3));
		return r;
	}

	Vector3 vmat( Vector3 o )
	{
		double x, y, z, w;
		x = get(0,0)*o.x+get(1,0)*o.y+get(2,0)*o.z+get(3,0);
		y = get(0,1)*o.x+get(1,1)*o.y+get(2,1)*o.z+get(3,1);
		z = get(0,2)*o.x+get(1,2)*o.y+get(2,2)*o.z+get(3,2);
		w = get(0,3)*o.x+get(1,3)*o.y+get(2,3)*o.z+get(3,3);
		return (x,y,z)/w;
	}

	static BoAMatrix4 rotate( Vector3 axis, double theta )
	{
		BoAMatrix4 r = BoAMatrix4.identity();
		double s, c, oc;
		s = sin(theta);
		c = cos(theta);
		oc = 1.0-c;
		r.set(0,0,oc*axis.x*axis.x+c);
		r.set(1,0,oc*axis.x*axis.y-axis.z*s);
		r.set(2,0,oc*axis.x*axis.z+axis.y*s);
		r.set(0,1,oc*axis.y*axis.x+axis.z*s);
		r.set(1,1,oc*axis.y*axis.y+c);
		r.set(2,1,oc*axis.y*axis.z-axis.x*s);
		r.set(0,2,oc*axis.z*axis.x-axis.y*s);
		r.set(1,2,oc*axis.z*axis.y+axis.x*s);
		r.set(2,2,oc*axis.z*axis.z+c);
		return r;
	}

	static BoAMatrix4 perspective( double fov, double ar, double znear, double zfar )
	{
		BoAMatrix4 r = BoAMatrix4.create();
		double f = 1/tan(fov*0.5);
		r.set(0,0,f/ar);
		r.set(1,1,f);
		r.set(2,2,(zfar+znear)/(znear-zfar));
		r.set(3,2,(2*zfar*znear)/(znear-zfar));
		r.set(2,3,-1);
		return r;
	}

	// UE-like axes from rotation
	static Vector3, Vector3, Vector3 getaxes( double pitch, double yaw, double roll )
	{
		Vector3 x = (1,0,0), y = (0,-1,0), z = (0,0,1);	// y inverted for left-handed result
		BoAMatrix4 mRoll = BoAMatrix4.rotate((1,0,0),roll);
		BoAMatrix4 mPitch = BoAMatrix4.rotate((0,1,0),pitch);
		BoAMatrix4 mYaw = BoAMatrix4.rotate((0,0,1),yaw);
		BoAMatrix4 mRot = mRoll.mul(mYaw);
		mRot = mRot.mul(mPitch);
		x = mRot.vmat(x);
		y = mRot.vmat(y);
		z = mRot.vmat(z);
		return x, y, z;
	}

// Below functions are from Gutamatics - https://gitlab.com/Gutawer/gzdoom-gutamatics/-/tree/master
/*
Copyright 2020 Jessica Russell
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
	/// Returns a rotation matrix from euler angles.
	static BoAMatrix4 fromEulerAngles(double yaw, double pitch, double roll) {
		BoAMatrix4 rYaw = BoAMatrix4.identity();
		double sYaw = sin(yaw);
		double cYaw = cos(yaw);
		rYaw.set(0, 0,  cYaw);
		rYaw.set(1, 0, -sYaw);
		rYaw.set(0, 1,  sYaw);
		rYaw.set(1, 1,  cYaw);

		BoAMatrix4 rPitch = BoAMatrix4.identity();
		double sPitch = sin(pitch);
		double cPitch = cos(pitch);
		rPitch.set(0, 0,  cPitch);
		rPitch.set(0, 2, -sPitch);
		rPitch.set(2, 0,  sPitch);
		rPitch.set(2, 2,  cPitch);

		BoAMatrix4 rRoll = BoAMatrix4.identity();
		double sRoll = sin(roll);
		double cRoll = cos(roll);
		rRoll.set(1, 1,  cRoll);
		rRoll.set(2, 1, -sRoll);
		rRoll.set(1, 2,  sRoll);
		rRoll.set(2, 2,  cRoll);

		// concatenate ypr to get the final matrix
		BoAMatrix4 ret = rYaw.mul(rPitch);
		ret = ret.mul(rRoll);
		return ret;
	}

	/// Converts back from the rotation matrix to euler angles.
	double, double, double rotationToEulerAngles() {
		if (closeEnough(get(0, 2), -1)) {
			double x = 90;
			double y = 0;
			double z = atan2(get(1, 0), get(2, 0));
			return z, x, y;
		}
		else if (closeEnough(get(0, 2), 1)) {
			double x = -90;
			double y = 0;
			double z = atan2(-get(1, 0), -get(2, 0));
			return z, x, y;
		}
		else {
			float x1 = -asin(get(0, 2));
			float x2 = 180 - x1;

			float y1 = atan2(get(1, 2) / cos(x1), get(2, 2) / cos(x1));
			float y2 = atan2(get(1, 2) / cos(x2), get(2, 2) / cos(x2));

			float z1 = atan2(get(0, 1) / cos(x1), get(0, 0) / cos(x1));
			float z2 = atan2(get(0, 1) / cos(x2), get(0, 0) / cos(x2));

			if ((abs(x1) + abs(y1) + abs(z1)) <= (abs(x2) + abs(y2) + abs(z2))) {
				return z1, x1, y1;
			}
			else {
				return z2, x2, y2;
			}
		}
	}

	/// Returns if two values are close enough to be considered equal.
	static bool closeEnough(double a, double b, double epsilon = double.epsilon) {
		if (a == b) return true;
		return abs(a - b) <= epsilon;
	}
}