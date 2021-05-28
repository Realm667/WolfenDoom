/*
 * Copyright (c) 2017-2021 jpalomo, Ozymandias81
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

class Harpoon : Actor
{
	Default
	{
		Height 8;
		Radius 16;
		Speed 30;
		Damage 1;
		Scale 0.85;
		Projectile;
		MaxStepHeight 8;
		ActiveSound "harpoon/swish";
		SeeSound "harpoon/chain";
	}

	States
	{
	Spawn:
		HPON A 1 A_HarpoonChain();
		Loop;
	Death:
		HPON A 3;
		Stop;
	}

	override int DoSpecialDamage (Actor victim, int damage, Name damagetype)
	{

		if (victim != NULL && target != NULL && !victim.bDontThrust)
		{
			Vector3 thrust = victim.Vec3To(target);
			victim.Vel += thrust.Unit() * (255. * 50 / max(victim.Mass, 1));
		}
		return damage;
	}

	void A_HarpoonChain ()
	{
		A_StartSound ("harpoon/active", CHAN_ITEM);
		Spawn("Harpoon_TrailX", Pos, ALLOW_REPLACE);
		Spawn("Harpoon_TrailX", Vec3Offset(-Vel.x/2., -Vel.y/2., -Vel.z/2.), ALLOW_REPLACE);
		Spawn("Harpoon_TrailX", Vec3Offset(-Vel.x, -Vel.y, -Vel.z), ALLOW_REPLACE);
		Spawn("Harpoon_TrailY", Pos, ALLOW_REPLACE);
		Spawn("Harpoon_TrailY", Vec3Offset(-Vel.x/2., -Vel.y/2., -Vel.z/2.), ALLOW_REPLACE);
		Spawn("Harpoon_TrailY", Vec3Offset(-Vel.x, -Vel.y, -Vel.z), ALLOW_REPLACE);
	}
}

class Harpoon_TrailX : Actor
{
	Default
	{
		Scale 0.85;
		+FLATSPRITE
		+NOBLOCKMAP
		+NOGRAVITY
		+ROLLSPRITE
	}
	States
	{
	Spawn:
		HPON B 2 {A_SetRoll(roll + 50.0, SPF_INTERPOLATE); A_FadeOut(0.09);}
		Loop;
	}
}

class Harpoon_TrailY : Harpoon_TrailX
{
	Default
	{
		-FLATSPRITE
		+WALLSPRITE
	}
	States
	{
	Spawn:
		HPON B 2 {A_SetRoll(roll - 50.0, SPF_INTERPOLATE); A_FadeOut(0.09);}
		Loop;
	}
}