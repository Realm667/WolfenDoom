/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, MaxED
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

class UnderwaterPlant1: SceneryBase
{
	Default
	{
		//$Category Props (BoA)/Underwater
		//$Title Underwater Seaweed (long)
		//$Color 3
		Radius 8;
		Height 96;
		CullActorBase.CullLevel 1;
	}
	States
	{
	Spawn:
		UWPL A -1;
		Stop;
	}
}

class UnderwaterPlant2 : UnderwaterPlant1
{
	Default
	{
	//$Title Underwater Seaweed (small)
	Height 32;
	}
	States
	{
	Spawn:
		UWPL B -1;
		Stop;
	}
}

class UnderwaterPlant3 : UnderwaterPlant2
{
	Default
	{
	//$Title Underwater Seaweed (thin)
	}
	States
	{
	Spawn:
		UWPL C -1;
		Stop;
	}
}