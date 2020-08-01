class CloudSpawner : EffectSpawner
{
	class<Actor> cloud;
	double minspeed, maxspeed;

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

		String cloudtype = "Cloud";

		Switch(args[3])
		{
			case 0:
				cloudtype = "Small" .. cloudtype;
				break;
			case 1:
				cloudtype = "Medium" .. cloudtype;
				break;
			default:
			case 2:
				cloudtype = "Large" .. cloudtype;
				break;
		}


		Switch(args[4])
		{
			default:
				cloudtype = cloudtype .. "Grey";
				minspeed = 5.0;
				maxspeed = 8.0;
				break;
			case 1:
				cloudtype = cloudtype .. "Tan";
				minspeed = 5.0;
				maxspeed = 8.0;
				break;
			case 2:
				cloudtype = cloudtype .. "Dark";
				minspeed = 40.0;
				maxspeed = 70.0;
				break;
		}

		cloud = cloudtype;
	}

	override void SpawnEffect()
	{
		Super.SpawnEffect();

		A_SpawnItemEx(cloud, random(Args[0]*2, -Args[0]*2), random(Args[0]*2, -Args[0]*2), random(0, Args[1]), frandom(minspeed, maxspeed), 0, 0, random(6, -6), SXF_CLIENTSIDE | SXF_TRANSFERSCALE | SXF_TRANSFERRENDERSTYLE | SXF_TRANSFERSTENCILCOL, Args[2]);
	}
}