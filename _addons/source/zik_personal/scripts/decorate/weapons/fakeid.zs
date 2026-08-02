/*
 * Copyright (c) 2019-2021 Ozymandias81, AFADoomer
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

class FakeID : NullWeapon
{
	Default
	{
	Tag "$TAGKARTE";
	Weapon.SelectionOrder 10002;
	}
	States
	{
	Select:
		TNT1 A 1 A_Raise;
		Loop;
	Deselect:
		TNT1 A 1 A_Lower;
		Loop;
	Fire:
	Ready:
		TNT1 A 1 A_WeaponReady(WRF_NOFIRE);
		TNT1 A 1 A_StartSound("mohpapers/please", CHAN_AUTO);
		TNT1 A 1 A_StartSound("mohpapers/show", CHAN_AUTO);
		FKID AABC 4;
		FKID DDEF 6;
		FKID F 30;
		FKID E 1 A_StartSound("mohpapers/holster", CHAN_AUTO);
		FKID DCBA 4;
		Stop;
	}
}