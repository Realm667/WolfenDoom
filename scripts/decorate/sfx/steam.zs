/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, m-x-d, AFADoomer
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

class ZyklonBSteamSpawner : SteamSpawner
{
	Default
	{
	//$Title Zyklon B Steam Spawner
	//$Sprite ZTEMA0
	SteamSpawner.Particle "ZyklonBSteamParticle";
	}
}

class ZyklonBSteamParticle : SteamParticle
{
	Default
	{
	Height 16;
	Radius 8;
	DamageFunction (random(1,8));
	PoisonDamage 4;
	DamageType "UndeadPoisonAmbience";
	Projectile;
	}
	States
	{
	Spawn:
		ZTEM A 0;
		"####" A 2 A_SetScale(Scale.X+0.013, Scale.Y+0.013);
		"####" A 0 A_FadeOut(.04,FTF_REMOVE);
		Loop;
	}
}

class ZyklonBSteamSpawner_C3M6A : SteamSpawner
{
	Default
	{
	//$Title Zyklon B Steam Spawner (long range)
	//$Sprite ZTEMA0
	SteamSpawner.Particle "ZyklonBSteamParticle_C3M6A";
	}
}

class ZyklonBSteamParticle_C3M6A : ZyklonBSteamParticle
{
	Default
	{
    DamageFunction (2*random(1,8));
    PoisonDamage 8;
	}
    States
	{
	Spawn:
		ZTEM A 0;
		"####" A 2 A_SetScale(Scale.X+0.002, Scale.Y+0.002);
		"####" A 0 A_FadeOut(.001,FTF_REMOVE);
		Loop;
	}
}