/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, MaxED, AFADoomer
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

//Base Cloud Grey
class CloudBaseGrey : ParticleBase
{
	Default
	{
	+MISSILE
	+NOBLOCKMAP
	+NOGRAVITY
	Radius 1;
	Height 1;
	RenderStyle "Translucent";
	Alpha 0.1;
	Scale 0.5;
	+ParticleBase.CHECKPOSITION
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256, "Cloud1", "Cloud2");
	Cloud1:
		CLXG A 0;
		Goto Movement;
	Cloud2:
		CLXG B 0;
		Goto Movement;
	Movement:
		"####""###########" 3 A_FadeIn(0.05);
		"####" "#" 1000;
		Wait;
	}
}

class SmallCloudGrey : CloudBaseGrey  {	Default { Scale 1.0; } }
class MediumCloudGrey : CloudBaseGrey {	Default { Scale 2.0; } }
class LargeCloudGrey : CloudBaseGrey  {	Default { Scale 4.0; } }


//Base Cloud Tan
class CloudBaseTan : CloudBaseGrey
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256, "Cloud1", "Cloud2");
	Cloud1:
		CLXT A 0;
		Goto Movement;
	Cloud2:
		CLXT B 0;
		Goto Movement;
	}
}

//Grey Clouds
class SmallCloudTan : CloudBaseTan  { Default { Scale 1.0; } }
class MediumCloudTan : CloudBaseTan { Default { Scale 2.0; } }
class LargeCloudTan : CloudBaseTan  { Default { Scale 4.0; } }

//Base Cloud Dark
class CloudBaseDark : CloudBaseGrey
{
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256, "Cloud1", "Cloud2");
	Cloud1:
		CLXD A 0;
		Goto Movement;
	Cloud2:
		CLXD B 0;
		Goto Movement;
	}
}

//Grey Clouds
class SmallCloudDark : CloudBaseDark  {	Default	{ Scale 1.0; } }
class MediumCloudDark : CloudBaseDark { Default { Scale 2.0; } }
class LargeCloudDark : CloudBaseDark  { Default { Scale 4.0; } }