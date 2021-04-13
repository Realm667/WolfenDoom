class KickPuff : BlastEffect
{
	Default
	{
	+NOBLOCKMAP
	+NOEXTREMEDEATH
	+NOGRAVITY
	+PUFFONACTORS
	RenderStyle "Add";
	Obituary "$OBKICKS";
	ProjectileKickback 100;
	Scale 0.4;
	DamageType "Melee";
	}
	States
	{
	Spawn:
	Melee:
	Crash:
		POOF A 3 A_StartSound("kick/hit");
		POOF A 0 A_Blast(BF_DONTWARN|BF_NOIMPACTDAMAGE, 200, random(8,16), frandom(20.0,30.0));
		POOF A 0 Radius_Quake(1,random(15,20),0,8,0);
		POOF BCDE 3;
		Stop;
	XDeath:
		POOF A 3 A_StartSound("kick/hit");
		Goto Crash+1;
	}
}