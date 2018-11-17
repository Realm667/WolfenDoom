// Written by Marisa Kirisame - from https://forum.zdoom.org/viewtopic.php?f=122&t=61944&p=1071848
class ShapeUtil
{
	// create a square shape (not usable until calling MoveSquare)
	static clearscope Shape2D MakeSquare()
	{
		// the shape that will be drawn
		Shape2D square = new("Shape2D");

		// texture coordinates of each corner
		square.PushCoord((0, 0));
		square.PushCoord((1, 0));
		square.PushCoord((0, 1));
		square.PushCoord((1, 1));

		// two triangles make up the square
		// the points have to be in counter-clockwise order
		square.PushTriangle(0, 3, 1);
		square.PushTriangle(0, 2, 3);

		return square;
	}

	// set the positions of an existing square shape's vertices
	static clearscope void MoveSquare(Shape2D shape, Vector2 size, Vector2 pos, double angle, Vector2 targetscreen = (-1, -1))
	{
		// clear any vertices already set
		shape.Clear(Shape2D.C_Verts);

		// corners of a square centered on 0,0
		Vector2 points[4];
		points[0] = (-0.5 * size.X, -0.5 * size.Y);
		points[1] = (0.5 * size.X, -0.5 * size.Y);
		points[2] = (-0.5 * size.X, 0.5 * size.Y);
		points[3] = (0.5 * size.X, 0.5 * size.Y);

		// apply a 2D rotation matrix:
		// then move the points by the set offset
		for (int i = 0; i < 4; i++)
		{
			Vector2 oldpos = points[i];
			points[i].X = oldpos.X * cos(angle) - oldpos.Y * sin(angle) + pos.X;
			points[i].Y = oldpos.X * sin(angle) + oldpos.Y * cos(angle) + pos.Y;
			shape.PushVertex(points[i]);
		}
	}
}