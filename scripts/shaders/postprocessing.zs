class TcPostProcessShaderHandler : StaticEventHandler
{
	override void RenderOverlay(RenderEvent e)
	{
		// get correct player
		PlayerInfo p = players[consoleplayer];
		
		if (Cvar.GetCVar("boa_pp_lensflares", p).GetInt() > 0)			EnableLensFlares();
		else														DisableLensFlares();
		
		if (Cvar.GetCVar("boa_pp_vignette", p).GetInt() > 0)			EnableVignette();
		else														DisableVignette();
		
		if (Cvar.GetCVar("boa_filmgrain", p).GetBool() == true)
		{
			EnableFilmGrain(p, gametic + e.FracTic);
		}
		else
		{
			DisableFilmGrain(p);
		}
	}

	//===========================================================================
	// LENS FLARES
	//===========================================================================
	
	ui void EnableLensFlares(void)
	{
		PlayerInfo p = players[consoleplayer];
		
		double threshold = CVar.GetCVar("boa_pp_lensflares_threshold", p).GetFloat();
		double distance = CVar.GetCVar("boa_pp_lensflares_distance", p).GetFloat();
		double amount = CVar.GetCVar("boa_pp_lensflares_amount", p).GetFloat();
		double samples = CVar.GetCVar("boa_pp_lensflares_samples", p).GetInt();
		Shader.SetUniform1f(p, "lensflareshader", "threshold", threshold);
		Shader.SetUniform1f(p, "lensflareshader", "distance", distance);
		Shader.SetUniform1f(p, "lensflareshader", "samples", samples);
		Shader.SetUniform1f(p, "lensflareshader", "amount", amount);
		Shader.SetEnabled(p, "lensflareshader", true);
	}

	ui void DisableLensFlares(void)
	{
		PlayerInfo p = players[consoleplayer];
		Shader.SetEnabled(p, "lensflareshader", false);
	}
	
	//===========================================================================
	// VIGNETTE (BY NASH)
	//===========================================================================
	
	ui void EnableVignette(void)
	{
		PlayerInfo p = players[consoleplayer];
		double i = CVar.GetCVar("boa_pp_vignette_intensity", p).GetFloat();
		double f = CVar.GetCVar("boa_pp_vignette_falloff", p).GetFloat();
		Shader.SetUniform1f(p, "vignetteshader", "intensity", i);
		Shader.SetUniform1f(p, "vignetteshader", "falloff", f);
		Shader.SetEnabled(p, "vignetteshader", true);
	}

	ui void DisableVignette(void)
	{
		PlayerInfo p = players[consoleplayer];
		Shader.SetEnabled(p, "vignetteshader", false);
	}
	
	//===========================================================================
	// FILM GRAIN
	//===========================================================================
	
	ui void EnableFilmGrain(PlayerInfo p, double fracTic)
	{
		CVar acv = CVar.GetCVar("boa_filmgrain_amount", p);
		double a = (acv ? CVar.GetCVar("boa_filmgrain_amount", p).GetFloat() : 0);
		int px = (acv ? CVar.GetCVar("boa_filmgrain_pixelsize", p).GetInt() : 0);
		Shader.SetUniform1f(p, "filmgrainshader", "timer", fracTic);
		Shader.SetUniform1f(p, "filmgrainshader", "amount", a);
		Shader.SetUniform1f(p, "filmgrainshader", "pixelSize", double(px));
		Shader.SetEnabled(p, "filmgrainshader", true);
	}

	ui void DisableFilmGrain(PlayerInfo p)
	{
		Shader.SetEnabled(p, "filmgrainshader", false);
	}
	
	//===========================================================================
	// PIXEL EATER MOTIONBLUR EVENTHANDLERS
	//===========================================================================
	
	int			pitch, yaw ;
	double		xtravel, ytravel ;
	
	override void PlayerEntered( PlayerEvent e )
	{
		PlayerInfo plr = players[ consoleplayer ];
		if( plr )
		{	
			xtravel = 0 ;
			ytravel = 0 ;
		}
	}
	
	override void WorldTick()
	{
		PlayerInfo	plr = players[ consoleplayer ];
		if( plr && plr.health > 0 && plr.mo && Cvar.GetCVar( "boa_mblur", plr ).GetBool() )
		{
			yaw		= plr.mo.GetPlayerInput( ModInput_Yaw );
			pitch	= -plr.mo.GetPlayerInput( ModInput_Pitch );
		}
	}
	
	override void NetworkProcess( ConsoleEvent e )
	{
		PlayerInfo	plr = players[ consoleplayer ];
		if( plr && plr.mo && e.Name == "liveupdate" )
		{
			double pitchdimin	= 1. - abs( plr.mo.pitch * 1. / 90 );
			double decay		= 1. - Cvar.GetCVar( "boa_mblur_recovery", plr ).GetFloat() * .01 ;
			double amount		= Cvar.GetCVar( "boa_mblur_strength", plr ).GetFloat() * 10. / 32767 * sqrt( pitchdimin );
			xtravel				= xtravel * decay + yaw * amount * .625 ;
			ytravel				= ytravel * decay + pitch * amount ;
			
			if( Cvar.GetCVar( "boa_mblur_autostop", plr ).GetBool() )
			{
				double threshold = Cvar.GetCVar( "boa_mblur_threshold", plr ).GetFloat() * 30 ;
				double recovery2 = 1 - Cvar.GetCVar( "boa_mblur_recovery2", plr ).GetFloat() * .01 ;
				if( abs( yaw )		<= threshold ) xtravel *= recovery2 ;
				if( abs( pitch )	<= threshold ) ytravel *= recovery2 ;
			}
		}
	}
	
	override void UiTick()
	{
		PlayerInfo	plr = players[ consoleplayer ];
		if( plr && plr.mo )
		{
			if( plr.health > 0 && Cvar.GetCVar( "boa_mblur", plr ).GetBool() && !plr.mo.FindInventory("CutsceneEnabled") )//&& yaw && pitch )
			{
				EventHandler.SendNetworkEvent( "liveupdate" );
				
				int copies			= 1 + Cvar.GetCVar( "boa_mblur_samples", plr ).GetInt() ;
				double increment	= 1. / copies ;
				vector2 travel		= ( xtravel, ytravel ) / screen.getheight() ;
				
				Shader.SetUniform2f( plr, "boa_mblur", "steps", travel * increment );
				Shader.SetUniform1f( plr, "boa_mblur", "samples", copies );
				Shader.SetUniform1f( plr, "boa_mblur", "increment", increment );
				Shader.SetUniform1f( plr, "boa_mblur", "blendmode", Cvar.GetCVar( "boa_mblur_blendmode", plr ).GetInt() );
					
				Shader.SetEnabled( plr, "boa_mblur", true );
			}
			else
			{
				Shader.SetEnabled( plr, "boa_mblur", false );
			}
		}
	}
}