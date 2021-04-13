/*
 * Copyright (c) 2018-2020 AFADoomer
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

// Electrical emitter effects
class ElectricalArc : EffectSpawner
{
	Class<LightningBeam> beam;

	Property Beam:beam;

	Default
	{
		//$Category Hazards (BoA)/ZScript
		//$Title Electrical Arc
		//$Sprite AMRKA0
		//$Color 3
		+NOGRAVITY
		Height 0;
		Radius 0;
		EffectSpawner.Range 2048;
		+EffectSpawner.ALLOWTICKDELAY
		ElectricalArc.Beam "LightningBeamArc";
	}

	States
	{
		Spawn:
		Active:
			TNT1 A 1 A_LightningBeam(beam);
			Loop;
		Inactive:
			TNT1 A 1;
			Loop;
	}

	void A_LightningBeam(Class<LightningBeam> beam = "LightningBeamArc")
	{
		tics = max(10 - boa_lightningdensity, 1);

		Super.SpawnEffect();

		Actor p;

		p = Spawn(beam, pos);
		if (LightningBeam(p))
		{
			p.master = self;
			p.pitch = pitch;
			p.angle = angle;
		}
	}
}

class ElectricalPillar : ElectricalArc
{
	Default
	{
		//$Title Electrical Pillar
		-NOGRAVITY
		ElectricalArc.Beam "LightningBeamPillar";
	}

	override void PostBeginPlay()
	{
		if (waterlevel) { beam = "LightningBeamArc"; }
		pitch = -90;
		Super.PostBeginPlay();
	}

	override void Tick()
	{
		angle = Random(1, 360);

		Super.Tick();
	}
}

Class ElectricalArc2 : ElectricalArc
{
	Default
	{
		//$Title Green Electrical Arc
		ElectricalArc.Beam "LightningBeamArc2";
	}
}

Class ElectricalPillar2 : ElectricalPillar
{
	Default
	{
		//$Title Green Electrical Pillar
		+NOGRAVITY
		+SPAWNCEILING
		ElectricalArc.Beam "LightningBeamPillar2";
	}
}