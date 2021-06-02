/*
 * Copyright (c) 2018-2021 Talon1024, AFADoomer
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

class ShakeShaderControl : ShaderControl {
	Default {
		ShaderControl.Shader "shakeshader";
	}

	clearscope double FixedToDouble(int fixed) {
		return fixed / 65536.0;
	}

	override void SetUniforms(PlayerInfo p, RenderEvent e) {
		double speed = FixedToDouble(amount - 2);
		speed = speed / 4; // Make shake effect weaker
		Shader.SetUniform1f(p, ShaderToControl, "speed", speed);
	}
}

class OldVideoShaderControl : ShaderControl {
	Default {
		ShaderControl.Shader "oldvideoshader";
	}
}

class BlurShaderControl : ShaderControl {
	int holdTarget;

	Default {
		ShaderControl.Shader "blurshader";
	}

	override void BeginPlay()
	{
		alpha = 0;

		Super.BeginPlay();
	}

	override void DoEffect()
	{
		if (amount > 1) { holdTarget = level.time + amount; } // Set hold time based on amount in inventory

		// If we've hit the hold time or are a tank remove the effect
		if (owner is "TankPlayer" || (holdTarget && level.time > holdTarget)) 
		{
			amount = 1;
			holdTarget = 0;
			alpha = 0;
		}
		else if (holdTarget)
		{
			alpha = alpha < 1.0 ? alpha + 0.057 : 1.0; // Fade the blur effect in over the course of roughly half a second
			amount--; // Remove one from inventory every tick
		}
	}
}

class HeatShaderControl : ShaderControl
{
	int holdTarget;

	Default
	{
		ShaderControl.Shader "heatshader";
		Inventory.MaxAmount 70;
	}

	override void DoEffect()
	{
		if (amount > 1) { holdTarget = level.time + amount; } // Set hold time based on amount in inventory

		// If we've hit the hold time, are a tank, or are underwater, remove the effect
		if (owner.waterlevel > 1 || owner is "TankPlayer" || (holdTarget && level.time > holdTarget)) 
		{
			amount = 1;
			holdTarget = 0;
		}
		else if (holdTarget)
		{
			amount = max(amount - 4, 1); // This effect drops off quickly, unlike blur!
		}
	}
}

class SandShaderControl : ShaderControl
{
	Vector2 dir;
	Vector3 clr;
	Color setcolor;
	double setangle;
	int holdTarget;
	double size;
	int maxparticles;
	ParticleManager manager;
	int frozentime;

	Property ParticleColor:setcolor;
	Property Angle:setangle;
	Property Size:size;
	Property MaxParticles:maxparticles;

	Default
	{
		Alpha 0.0;
		Speed 3.0;
		SandShaderControl.Angle 0.0;
		ShaderControl.Shader "sandshader";
		SandShaderControl.ParticleColor "746251";
		SandShaderControl.Size 4;
		SandShaderControl.MaxParticles 64;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (!owner || !owner.player || !owner.player.camera) { Destroy(); return; }

		SpawnPoint = owner.player.camera.pos;

		clr = (setcolor.r, setcolor.g, setcolor.b) / 256.0;

		manager = ParticleManager.GetManager();
	}

	override void SetUniforms(PlayerInfo p, RenderEvent e)
	{
		Vector3 campos = owner.player.camera.pos + (0, 0, owner.player.crouchviewdelta) - SpawnPoint;
		campos.xy = RotateVector(campos.xy, -setangle);

		Shader.SetUniform1f(p, ShaderToControl, "timer", speed * (gametic + e.FracTic));
		Shader.SetUniform1f(p, ShaderToControl, "angle", e.viewangle - setangle);
		Shader.SetUniform1f(p, ShaderToControl, "pitch", e.viewpitch);
		Shader.SetUniform3f(p, ShaderToControl, "position", (campos.xy, p.viewz));
		Shader.SetUniform3f(p, ShaderToControl, "particlecolor", clr);
		Shader.SetUniform1f(p, ShaderToControl, "size", size);
		Shader.SetUniform1f(p, ShaderToControl, "maxparticles", maxparticles);
		Shader.SetUniform1f(p, ShaderToControl, "fov", p.FOV);

		if (IsFrozen())
		{
			Shader.SetUniform1f(p, ShaderToControl, "timer", level.time - frozentime);
		}
	}

	override void DoEffect()
	{
		if (amount > 1) { holdTarget = level.time + amount; } // Set hold time based on amount in inventory

		// If we've hit the hold time or are underwater, remove the effect
		if (owner.waterlevel > 1 || (holdTarget && level.time > holdTarget)) 
		{
			amount = 1;
			holdTarget = 0;
			alpha = 0;
		}
		else if (holdTarget)
		{
			if (IsFrozen()) { frozentime++; }
			else { frozentime = 0; }

			if (manager)
			{
				maxparticles = int(Default.maxparticles * manager.particlescaling);
			}

			double targetalpha = clamp((amount - 1) / 105.0, 0, 0.3);
			if (alpha < targetalpha) { alpha = min(targetalpha, alpha + 0.05); }
			else if (alpha > targetalpha) { alpha = max(targetalpha, alpha - 0.05); }

			amount = max(amount - 5, 1);
		}
	}
}

// Used for color grading persistence. Color grading information seems to get
// lost (at least for me), after saving, quitting, and re-loading the savegame
// Also, don't inherit from ShaderControl, so that it doesn't interfere with
// the existing color grading
class ColorGradeShaderControl : Inventory
{
	private transient ColorGradeThinker colorGrading;
	private double currentSpeed;
	private double nextSpeed;

	Default
	{
		Inventory.Amount 1; // Amount stores current and next LUTs
		Inventory.MaxAmount 2147483647;
	}

	override void DoEffect()
	{
		if (!Owner || Owner.PlayerNumber() < 0)
		{
			Destroy();
			return;
		}
		int pnum = Owner.PlayerNumber();
		if (!colorGrading)
		{
			// Probably loaded from a savegame - set up color grading
			colorGrading = ColorGradeThinker.Get();
			int nextLut = (Amount & 0xFFFF) - 1;
			int currentLut = Amount >> 16;
			colorGrading.playerStates[pnum].currentLut = currentLut;
			colorGrading.playerStates[pnum].currentSpeed = currentSpeed;
			colorGrading.playerStates[pnum].nextLut = nextLut;
			colorGrading.playerStates[pnum].nextSpeed = nextSpeed;
			colorGrading.playerStates[pnum].alpha = alpha;
			// Console.Printf("current: %d, next: %d, alpha: %.3f", currentLut, nextLut, alpha);
			Shader.SetUniform1i(players[pnum], "ColorGrade", "lutA", colorGrading.playerStates[pnum].currentLut);
			Shader.SetUniform1i(players[pnum], "ColorGrade", "lutB", colorGrading.playerStates[pnum].nextLut);
			Shader.SetUniform1f(players[pnum], "ColorGrade", "alpha", alpha);
			if (alpha < 1.0)
			{
				colorGrading.playerStates[pnum].currentLut = nextLut;
				colorGrading.playerStates[pnum].currentSpeed = nextSpeed;
			}
		}
		else
		{
			currentSpeed = colorGrading.playerStates[pnum].currentSpeed;
			nextSpeed = colorGrading.playerStates[pnum].nextSpeed;
			alpha = colorGrading.playerStates[pnum].alpha;
			if (alpha == 0.0)
			{
				// Console.Printf("new LUT %d %d", Amount >> 16, colorGrading.playerStates[pnum].nextLut);
				Amount = (1 + colorGrading.playerStates[pnum].nextLut) | (Amount & (0xFFFF << 16));
			}
			else if (alpha == 1.0)
			{
				Amount = (1 + colorGrading.playerStates[pnum].nextLut) | (colorGrading.playerStates[pnum].currentLut << 16);
			}
		}
	}
}

class NauseaShaderControl : ShaderControl
{
	int holdTarget, timer, flags;
	double velocity, oldangle, oldpitch;

	FlagDef DEPLETE:flags, 0;

	Default
	{
		ShaderControl.Shader "nausea";
		+NauseaShaderControl.DEPLETE
		Speed 1.0;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (!owner || !owner.player) { Destroy(); return; }
	}

	override void SetUniforms(PlayerInfo p, RenderEvent e)
	{
		Shader.SetUniform1f(p, ShaderToControl, "timer", speed * (gametic + e.FracTic));
	}

	override void DoEffect()
	{
		if (amount > 1) { holdTarget = level.time + amount; } // Set hold time based on amount in inventory

		// If we've hit the hold time, remove the effect
		if (holdTarget && level.time > holdTarget) 
		{
			amount = 1;
			holdTarget = 0;
			alpha = 0;
		}
		else if (holdTarget)
		{
			double targetvelocity = owner.vel.x * owner.vel.x + owner.vel.y * owner.vel.y + owner.vel.z * owner.vel.z + abs(oldangle - owner.angle) * 20 + abs(oldpitch - owner.pitch) * 20;

			if (velocity < targetvelocity) { if (velocity < 50) { velocity ++; } }
			else if (velocity > 0) { velocity --; }
			else { velocity = 0; }

			alpha = min(sin(velocity), 0.4);

			if (bDeplete)
			{
				amount--; // Remove one from inventory every tick
				alpha *= clamp(amount / 70.0, 0, 1.0); // Fade the effect out over the last 2 seconds
			}

			oldangle = owner.angle;
			oldpitch = owner.pitch;
		}
	}
}

// Item for enabling "dream state" overlays with minimal changes to older ACS code
class DreamState : NauseaShaderControl
{
	Default
	{
		Inventory.Amount 2;
		Inventory.MaxAmount 2;
		-NauseaShaderControl.DEPLETE
	}

	override void OnDestroy()
	{
		// Automatically disable the shader when the item is removed from a player's inventory
		if (owner && owner.player)
		{
			Shader.SetEnabled(owner.player, shaderToControl, false);
		}
	}
}

class PainShaderControl : ShaderControl
{
	color clr;
	double blendalpha;

	Default
	{
		ShaderControl.Shader "screenblend";
		Speed 1.0;
		Alpha 0.0;
		+Inventory.KEEPDEPLETED
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		if (!owner || !PlayerPawn(owner)) { Destroy(); return; }
	}

	override void SetUniforms(PlayerInfo p, RenderEvent e)
	{
		Shader.SetUniform1f(p, ShaderToControl, "alpha", blendalpha);
		Shader.SetUniform3f(p, ShaderToControl, "blendcolor", (clr.r, clr.g, clr.b));
	}

	override void DoEffect()
	{
		if (owner && owner.player)
		{
			[clr, blendalpha, amount] = DamageTracker.GetDamageBlend(owner.player);
		}
	}

	override void OnDestroy()
	{
		// Automatically disable the shader when the item is removed from a player's inventory
		if (owner && owner.player)
		{
			Shader.SetEnabled(owner.player, shaderToControl, false);
		}
	}
}
