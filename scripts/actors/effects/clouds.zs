class CloudSpawner : EffectSpawner
{
	static const string cloudsprites[] = { "CLXGA0", "CLXGB0", "CLXTA0", "CLXTB0", "CLXDA0", "CLXDB0" };
	double minspeed, maxspeed, s;
	int i;

	Default
	{
		//$Category Special Effects (BoA)
		//$Title Cloudstorm Spawner (arg1 xRadius, arg2 zRadius, arg3 Chance, arg4 Size, arg5 Color; Renderstyle, Stencilcolor and Scale are taken into account)
		//$Color 12
		//$Arg0 "Radius(x/y)"
		//$Arg0Tooltip "Radius of spawn area in map units"
		//$Arg1 "Height(z)"
		//$Arg1Tooltip "Height of spawn area in map units"
		//$Arg2 "Frequency"
		//$Arg2Tooltip "0 is always, 255 is never at a 30-tic basis"
		//$Arg3 "Size"
		//$Arg3Type 11
		//$Arg3Enum { 0 = "Small"; 1 = "Medium"; 2 = "Large"; }
		//$Arg4 "Color"
		//$Arg4Type 11
		//$Arg4Enum { 0 = "Grey (slow)"; 1 = "Tan (slow)"; 2 = "Dark (fast)"; }

		+CLIENTSIDEONLY
		+NOBLOCKMAP
		+NOCLIP
		+NOGRAVITY
		+NOINTERACTION
		+NOSECTOR
		+EffectSpawner.ALLOWTICKDELAY
	}

	States
	{
		Spawn:
			TNT1 A 0;
		Active:
			TNT1 A 30 SpawnEffect();
			Loop;
		Death:
			"####" "#" 5 A_FadeOut(0.05, FTF_REMOVE);
			Loop;
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();
		s = 4.0;
		Switch(args[3])
		{
			case 0:
				s = 1.0;
				break;
			case 1:
				s = 2.0;
				break;
			default:
			case 2:
				break;
		}

		i = 0;
		Switch(args[4])
		{
			default:
				minspeed = 5.0;
				maxspeed = 8.0;
				break;
			case 1:
				i = 1;
				minspeed = 5.0;
				maxspeed = 8.0;
				break;
			case 2:
				i = 2;
				minspeed = 40.0;
				maxspeed = 70.0;
				break;
		}
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();
		if (Random(0, 255) < Args[2]) { return; }
		A_SpawnParticleEx(
			/*color1*/ "FFFFFF",
			/*texture*/ TexMan.CheckForTexture(cloudsprites[2 * i + Random(0, 1)]),
			/*style*/ STYLE_Translucent,
			/*flags*/ SPF_FULLBRIGHT | SPF_RELATIVE,
			/*lifetime*/ 35000, // was infinite
			/*size*/ 384 * s,
			/*angle*/ frandom(-6, 6),
			/*posoff*/ frandom(args[0]*2,-args[0]*2), frandom(args[0]*2,-args[0]*2), frandom(0, args[1]),
			/*vel*/ frandom(minspeed, maxspeed), 0, 0,
			/*acc*/ 0, 0, 0,
			/*startalphaf*/ 0.5,
			/*fadestepf*/ 0);
	}
}