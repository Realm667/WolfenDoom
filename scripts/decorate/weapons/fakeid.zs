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
		FKID AABC 4;
		FKID DDEF 6;
		FKID F 12;
		FKID CCBA 4;
		Stop;
	}
}