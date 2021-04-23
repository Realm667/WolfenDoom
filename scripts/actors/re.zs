/*
 * Copyright (c) 2020 AFADoomer
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

class REBase : SceneryBase
{
	Default
	{
		//$Category Resident Evil (BoA)
		+SOLID
		+CANPASS
		CullActorBase.CullLevel 1;
	}
}

class REChandelier : SceneryBase
{
	Default
	{
		//$Category Resident Evil (BoA)
		//$Title Entry Hall Chandelier
		+NOGRAVITY
		-SOLID
		CullActorBase.CullLevel 2;
	}

	States
	{
		Spawn:
		Inactive:
			MDLA A -1;
			Stop;
		Active:
			MDLA A -1 BRIGHT;
			Stop;
	}
}

class RETableSmall : REBase
{
	Default
	{
		//$Title Small Table
		Height 38;
		Radius 20;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class RETableSide : REBase
{
	Default
	{
		//$Title Side Table (Half circle)
		Height 48;
		Radius 20;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REVase : REBase
{
	Default
	{
		//$Title Vase
		Height 26;
		Radius 20;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class RELightStair : REBase
{
	Default
	{
		//$Title Tall Lamp
		Height 128;
		Radius 10;
		CullActorBase.CullLevel 2;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class RELightStair2 : REBase
{
	Default
	{
		//$Title Short Lamp
		Height 64;
		Radius 10;
		+NOGRAVITY
		CullActorBase.CullLevel 2;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REColumn1 : REBase
{
	Default
	{
		//$Title Suport Column (Entry hall sides)
		+NOGRAVITY
		Height 140;
		Radius 10;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REChair : REBase
{
	Default
	{
		//$Title Chair
		Height 21;
		Radius 32;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REBalusterLarge : REBase
{
	Default
	{
		//$Title Rail Support (End, Upper level)
		+NOGRAVITY
		+NOINTERACTION
		Height 32;
		Radius 6;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REBalusterLarge2 : REBase
{
	Default
	{
		//$Title Rail Support (End, Upper level (Back))
		+NOGRAVITY
		+NOINTERACTION
		Height 32;
		Radius 6;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REBalusterMedium : REBase
{
	Default
	{
		//$Title Rail Support (End)
		+NOGRAVITY
		+NOINTERACTION
		Height 32;
		Radius 6;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REBalusterSmall : SimpleActor
{
	Default
	{
		//$Category Resident Evil (BoA)
		//$Title Rail Support
		+SOLID
		+CANPASS
		+NOGRAVITY
		Height 21;
		Radius 4;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class RECarpetWeight : REBase
{
	Default
	{
		//$Title Carpet Runner Weight
		-SOLID
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REColumn2 : REBase
{
	Default
	{
		//$Title Support Column (Entry Hall, Large)
		+NOGRAVITY
		Height 212;
		Radius 16;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REArches : REBase
{
	Default
	{
		//$Title Entry Hall Arches
		+NOGRAVITY
		+NOINTERACTION
		+NOBLOCKMAP
		-SOLID
		RenderRadius 1024.0;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REColumn3 : REBase
{
	Default
	{
		//$Title Support Column (Upper Level, 128 tall)
		+NOGRAVITY
		Height 170;
		Radius 12;
		RenderRadius 32;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REColumn6 : REBase
{
	Default
	{
		//$Title Support Column (Upper Level, 112 tall)
		+NOGRAVITY
		Height 150;
		Radius 12;
		RenderRadius 32;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REColumn4 : REBase
{
	Default
	{
		//$Title Support Column (Stair Landing)
		+NOGRAVITY
		Height 214;
		Radius 16;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REColumn5 : REBase
{
	Default
	{
		//$Title Support Column (Stair Entry)
		+NOGRAVITY
		Height 170;
		Radius 16;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}


class RECeiling : REBase
{
	Default
	{
		//$Title Entry Hall Ceiling
		+NOGRAVITY
		+NOINTERACTION
		+NOBLOCKMAP
		-SOLID
		RenderRadius 1024.0;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REWindows : REBase
{
	Default
	{
		//$Title Main Windows
		Height 170;
		Radius 1;
		+NOGRAVITY
		RenderRadius 1024.0;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REBasementEntry : REBase
{
	Default
	{
		//$Title Basement Entry (Right)
		Height 0;
		Radius 0;
		+NOGRAVITY
		-SOLID
		+NOINTERACTION
		RenderRadius 1024.0;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REBasementEntry2 : REBase
{
	Default
	{
		//$Title Basement Entry (Left)
		Height 0;
		Radius 0;
		+NOGRAVITY
		-SOLID
		+NOINTERACTION
		RenderRadius 1024.0;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REBasementVault : REBase
{
	Default
	{
		//$Title Basement Vault (Right)
		Height 0;
		Radius 0;
		+NOGRAVITY
		-SOLID
		+NOINTERACTION
		RenderRadius 256.0;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}

class REBasementVault2 : REBase
{
	Default
	{
		//$Title Basement Vault (Left)
		Height 0;
		Radius 0;
		+NOGRAVITY
		-SOLID
		+NOINTERACTION
		RenderRadius 256.0;
	}

	States
	{
		Spawn:
			MDLA A -1;
			Stop;
	}
}