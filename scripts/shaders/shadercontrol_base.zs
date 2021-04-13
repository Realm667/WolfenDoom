/*
 * Copyright (c) 2018-2020 Talon1024, AFADoomer
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
/*
	Shader controller base class

	This allows mappers to control shaders using the GiveInventory/TakeInventory
	ACS functions.

	Do not use this directly! Instead, make an actor class that inherits from
	ShaderControl. Set the ShaderControl.Shader property to the name of the
	shader to control. The shader must be defined in GLDEFS.

	To enable a shader, give 2 of the ShaderControl subclass item to the player.
	For example:

	GiveInventory("ShakeShaderControl", 2);

	To disable a shader, take 1 of the shader control item away so that the
	player only has 1 of said item. For example:

	TakeInventory("ShakeShaderControl", 1);
	or
	SetInventory("ShakeShaderControl", 1);

	Note that the latter requires you to define the SetInventory function in
	your ACS code.
*/
class ShaderControl : Inventory {
	string ShaderToControl;
	property Shader: ShaderToControl;
	Default {
		Inventory.MaxAmount 0x7fffffff;
	}

	virtual ui void SetUniforms(PlayerInfo p, RenderEvent e) {}
}

class CustomShaderHandler : StaticEventHandler
{
	override void RenderOverlay(RenderEvent e)
	{
		PlayerInfo p = players[consoleplayer];
		ThinkerIterator shaderIter = ThinkerIterator.Create("ShaderControl");

		ShaderControl shaderControl;

		while (shaderControl = ShaderControl(shaderIter.Next()))
		{
			if (shaderControl.Owner && shaderControl.Owner == p.mo) {
				//Console.Printf("Shader: %s", shaderControl.ShaderToControl);
				if (shaderControl.amount >= 2)
				{
					Shader.SetUniform1f(p, shaderControl.ShaderToControl, "timer", gametic + e.FracTic);
					Shader.SetUniform1f(p, shaderControl.ShaderToControl, "amount", shaderControl.amount - 1);
					Shader.SetUniform1f(p, shaderControl.ShaderToControl, "alpha", shaderControl.alpha);
					shaderControl.SetUniforms(p, e);
					Shader.SetEnabled(p, shaderControl.ShaderToControl, true);
				}
				else
				{
					Shader.SetEnabled(p, shaderControl.ShaderToControl, false);
				}
			}
		}
	}
}
