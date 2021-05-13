/*
 * Copyright (c) 2020 Talon1024
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

// Old ZPolyobject-based code
/*
class RevolvingDoorEffector : PolyobjectEffector
{
	double torque; // Rotational momentum
	double friction; // Amount to decrease torque by
	int duration; // Tic duration for each rotation
	int timer; // Rotation timer

	override void PolyTick()
	{
		Super.PolyTick();
		int special = 0; // The special to run
		int sign = 1;
		if (torque > 0)
		{
			sign = -1;
			special = Polyobj_OR_RotateLeft;
		}
		else if (torque < 0)
		{
			special = Polyobj_OR_RotateRight;
		}
		if (special && !timer)
		{
			// To rotate the polyobject in 1 tic, set the speed of
			// the rotation to byteAngle * 8
			// In this case, we are rotating over duration
			// Also, prevent byteAngle from exceeding 255, since that
			// will trigger perpetual motion
			int byteAngle = min(int(floor(abs(torque))), 254);
			int speed = byteAngle * 8 / duration;
			// Console.Printf("angle %d, speed %d, torque %.3f", byteAngle, speed, torque);
			Level.ExecuteSpecial(special, null, Polyobject.StartLine, false, Polyobject.PolyobjectNum, speed, byteAngle);
			timer = duration - 1;
			torque += friction * sign;
		}
		else if (timer)
		{
			timer--;
		}
		if (abs(torque) < friction)
		{
			torque = 0;
		}
	}

	void AddTorque(double torque, double distance)
	{
		self.torque += torque * (distance / 64);
	}
}
*/

class RevolvingDoorInstance : Thinker
{
	private double torque; // Rotational momentum (private)
	double friction; // Amount to decrease torque by
	int duration; // Tic duration for each rotation
	private int timer; // Rotation timer (private)
	private Line lastLine; // Line which was last activated
	private Actor lastActivator; // Actor who activated the line
	private bool specialActivated; // Door was rotated by a player this tic

	void Activate(Line line, Actor activator, double addTorque = 0)
	{
		lastLine = line;
		lastActivator = activator;
		specialActivated = true;
		Rotate(addTorque);
	}

	private void Rotate(double addTorque = 0)
	{
		torque += addTorque;
		int special = 0; // The special to run
		int sign = 1;
		if (abs(torque * duration) < friction)
		{
			torque = 0;
		}
		if (torque > 0)
		{
			sign = -1;
			special = Polyobj_OR_RotateLeft;
		}
		else if (torque < 0)
		{
			special = Polyobj_OR_RotateRight;
		}
		if (special && !timer)
		{
			// To rotate the polyobject in 1 tic, set the speed of
			// the rotation to byteAngle * 8
			// In this case, we are rotating over duration
			// Also, prevent byteAngle from exceeding 255, since that
			// will trigger perpetual motion
			int byteAngle = min(int(floor(abs(torque * duration))), 254);
			int speed = byteAngle * 8 / duration;
			lastLine.special = special;
			lastLine.args[1] = speed;
			lastLine.args[2] = byteAngle;
			if (!specialActivated)
			{
				Level.ExecuteSpecial(special, lastActivator, lastLine, false, lastLine.args[0], speed, byteAngle);
			}
			timer = duration - 1;
			torque += friction * sign;
		}
	}

	bool isMoving()
	{
		return timer > 0;
	}

	clearscope String getInfo()
	{
		return String.Format("Torque: %.3f, Friction: %.3f, Timer: %d", torque, friction, timer);
	}

	override void Tick()
	{
		Super.Tick();
		if (timer)
		{
			timer--;
		}
		if (specialActivated)
		{
			specialActivated = false;
		}
		else
		{
			Rotate();
		}
	}
}

class RevolvingDoorHandler : EventHandler
{
	private ParsedValue doorData;
	private Dictionary ponums;
	private Dictionary poLineSpecials;
	private Array<RevolvingDoorInstance> doors;
	private Array<double> torque;

	override void WorldLoaded(WorldEvent e)
	{
		doorData = FileReader.Parse("data/RevolvingDoors.txt");
		if (doorData)
		{
			ponums = Dictionary.Create();
			poLineSpecials = Dictionary.Create();
			for (int i = 0; i < doorData.Children.Size(); i++)
			{
				if (doorData.Children[i].KeyName ~== Level.MapName)
				{
					AddDoors(doorData.Children[i]);
				}
			}
		}
	}

	private void AddDoors(ParsedValue defs)
	{
		for (int tidx = 0; tidx < defs.Children.Size(); tidx++)
		{
			String ponum = defs.children[tidx].keyname;
			String tnum = String.Format("%d", doors.Size());
			RevolvingDoorInstance door = new("RevolvingDoorInstance");
			door.friction = FileReader.GetDouble(defs, ponum .. ".friction");
			door.duration = FileReader.GetInt(defs, ponum .. ".duration");
			doors.Push(door);
			torque.Push(FileReader.GetDouble(defs, ponum .. ".torque"));
			ponums.Insert(ponum, tnum);
		}
	}

	private String AddLineSpecial(Line line)
	{
		String lineIndex = String.Format("%d", line.Index());
		String lineSpecialStr = String.Format(
			"%d %d %d %d %d %d", // The original special and arguments
			line.special,
			line.args[0],
			line.args[1],
			line.args[2],
			line.args[3],
			line.args[4]);
		poLineSpecials.Insert(lineIndex, lineSpecialStr);
		return lineSpecialStr;
	}

	protected int getOriginalSpecial(Line line)
	{
		String lineIndex = String.Format("%d", line.Index());
		String lineSpecialStr = poLineSpecials.At(lineIndex);
		if (!lineSpecialStr.Length())
		{
			lineSpecialStr = AddLineSpecial(line);
		}
		return lineSpecialStr.ToInt(10);
	}

	protected int getOriginalArg(Line line, int arg)
	{
		String lineIndex = String.Format("%d", line.Index());
		String lineSpecialStr = poLineSpecials.At(lineIndex);
		if (!lineSpecialStr.Length())
		{
			lineSpecialStr = AddLineSpecial(line);
		}
		int lineSpecialStrLength = lineSpecialStr.Length();
		int spacesToSkip = arg + 1; // First number is the special
		int spacesSkipped = 0;
		int pos = 0;
		while (pos < lineSpecialStrLength)
		{
			if (lineSpecialStr.ByteAt(pos) == 32) // Space
			{
				spacesSkipped += 1;
			}
			pos++;
			if (spacesSkipped == spacesToSkip)
			{
				return lineSpecialStr.Mid(pos).ToInt(10);
			}
		}
		return 0;
	}

	protected int getPoArrayIndex(int ponum)
	{
		String postr = String.Format("%d", ponum);
		String tnum = ponums.At(postr);
		if (tnum.Length())
		{
			return tnum.ToInt();
		}
		return -1;
	}

	override void WorldLinePreActivated(WorldEvent e)
	{
		// Get line's original special
		int lineIndex = e.ActivatedLine.Index();
		int special = getOriginalSpecial(e.ActivatedLine);
		// Check if special is supported
		static const int pospecials[] = { 0, Polyobj_OR_RotateLeft, Polyobj_OR_RotateRight, Polyobj_RotateLeft, Polyobj_RotateRight };
		static const int factors[] = { 0, 1, -1, 1, -1 };
		int sign = 4; // Used as torque multiplier, as well as a check for
		// whether the special is supported.
		for (;sign > 0; sign--)
		{
			if (special == pospecials[sign])
			{
				sign = factors[sign];
				break;
			}
		}
		if (!sign) { return; } // NOTE: -1 is truthy, 0 is not
		// Do the thing
		int poindex = getPoArrayIndex(e.ActivatedLine.Args[0]);
		if (poindex >= 0)
		{
			e.ShouldActivate = !doors[poindex].isMoving();
			doors[poindex].Activate(e.ActivatedLine, e.Thing, torque[poindex] * sign * getOriginalArg(e.ActivatedLine, 1));
		}
	}

	/*
	ui void ShowDoorInfo(RevolvingDoorInstance rd, int ponum, double x, double y)
	{
		String text = String.Format("po: %d, %s", ponum, rd.getInfo());
		Screen.DrawText(smallfont, Font.CR_GRAY, x, y, text);
	}

	override void RenderOverlay(RenderEvent e)
	{
		return;
		double x = 20, y = 20;
		DictionaryIterator iter = DictionaryIterator.Create(ponums);
		while (iter.Next())
		{
			int ponum = iter.Key().ToInt();
			int tidx = iter.Value().ToInt();
			ShowDoorInfo(doors[tidx], ponum, x, y);
			y += 12;
		}
	}
	*/
}