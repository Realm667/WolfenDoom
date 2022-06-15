/*
 * Copyright (c) 2015-2021 Tormentor667, Ed the Bat, Ozymandias81, MaxED, AFADoomer
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

class BarrelFrags: Actor
{
	Default
	{
		Scale 0.75;
	}
	States
	{
	Spawn:
		FRAG ABCDEFGHIJKLM 3;
		"####" N 1;
		"####" "#" 1 A_SetTics(35*boa_debrislifetime);
		DeathWait:
		"####" "#" 1 A_FadeOut(0.1);
		Wait;
	}
}

class MetalFrags : BarrelFrags { Default { Scale 0.55; Translation "13:15=3:3","64:79=80:111","236:239=108:111"; } }
class GrassFrags : BarrelFrags { Default { Scale 0.45; Translation "13:15=125:127","64:79=121:125","236:239=124:127"; } }
class GrassFrags_Dry : BarrelFrags { Default { Scale 0.45; Translation "13:15=237:239","64:79=148:151"; } }
class GrassFrags_Snowy : BarrelFrags { Default { Gravity 0.125; Scale 0.45; Translation "13:15=93:95","64:79=80:95","236:239=148:151"; } }

class TNTBarrel1 : BarrelSpawner
{
	Default
	{
		//$Category Hazards (BoA)
		//$Title TNT Barrel (disguise)
		//$Color 3
		Height 34;
		DeathSound "world/barrelboom";
	}
	States
	{
	Spawn:
		BARL A -1;
		Stop;
	Death:
		BARX A 2 BRIGHT A_SpawnItemEx("BarrelFrags");
		"####" A 0 A_SpawnItemEx("GeneralExplosion_Medium");
		"####" B 2 BRIGHT A_Scream;
		"####" CDEFG 2 BRIGHT;
		"####" H 2 BRIGHT A_Explode;
		"####" IJKLM 2 BRIGHT;
		"####" M 1050 BRIGHT A_BarrelDestroy;
		"####" M 5 A_Respawn;
		Wait;
	}
}

class TNTBarrel2 : TNTBarrel1
{
	Default
	{
		//$Title TNT Box
	}
	States
	{
	Spawn:
		BARL B -1;
		Stop;
	}
}

class TNTBarrel3 : TNTBarrel1
{
	Default
	{
		//$Title TNT Barrel
	}
	States
	{
	Spawn:
		BARL C -1;
		Stop;
	}
}

class GoodieBarrel1 : TNTBarrel1
{
	Default
	{
		//$Title Goodie Barrel (disguise)
		DeathSound "WOODBRK";
		DropItem "Ammo12Gauge", 64;
		DropItem "Ammo9mm", 64;
		DropItem "Bandages", 48;
		DropItem "Dogfood", 64;
		DropItem "GrenadePickup", 16;
		DropItem "MauserAmmo", 64, 5;
		DropItem "Meal", 32, 1;
		Dropitem "Medikit_Small", 16;
	}
	States
	{
		Death:
			TNT1 A 0 A_Scream;
			BARL A 2 A_SpawnItemEx("BarrelFrags");
			TNT1 A 0 A_SpawnItemEx("PowerPlantSmokePuff", random(-3,3), random(-3,3), 0, 0, 0, 3);
			TNT1 A 0 A_NoBlocking(false); // DropItems handled in the BarrelSpawner actor - so that you can override drops via arg0str
			Stop;
	}

	enum Types
	{
		Nothing = -1,
		Health = 0,
		Grenades,
		Bullets,
		Rifle,
		Shells,
	};

	// Items dropped and their corresponding weights for calculating preference based off of player's inventory
	static const String ammoitems[] = 	{ 	"Health", 	"GrenadePickup", 	"Ammo9mm", 	"MauserAmmo", 	"Ammo12Gauge" 	};
	static const double weights[] = 	{ 	32.0, 		4.0, 				12.0, 		16.0, 			8.0 			};

	override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod, int flags, double angle)
	{
		if (!user_spawntype)
		{
			PlayerPawn p = PlayerPawn(source);

			if (p)
			{
				// Calculate weighted values for each item type based off of player's inventory amounts
				double weightvalues[5];
				weightvalues[Health] = weights[Health] * (1.0 - double(p.health) / p.MaxHealth);
				for (int a = 1; a < 5; a++)
				{
					let ammo = p.FindInventory(ammoitems[a]);
					weightvalues[a] = weights[a] * (ammo ? (1.0 - double(ammo.Amount) / ammo.MaxAmount) : 1.0);

					// Don't give ammo that the player can't use
					switch (a)
					{
						case Bullets:
							if (!p.FindInventory("Luger9mm") && !p.FindInventory("Walther9mm") && !p.FindInventory("Sten") && !p.FindInventory("MP40") && !p.FindInventory("UMG43")) { weightvalues[a] = -1; }
						break;
						case Rifle:
							if (!p.FindInventory("G43") && !p.FindInventory("Kar98k")) { weightvalues[a] = -1; }
						break;
						case Shells:
							if (!p.FindInventory("TrenchShotgun") && !p.FindInventory("Browning5")) { weightvalues[a] = -1; }
						break;
					}
				}

				int maxindex = 0;
				int maxcount = 0;

				// Find the item type with the highest weight
				if (weightvalues[0] == 0) { maxcount++; }
				for (int i = 1; i < 5; i++)
				{
					if (weightvalues[i] == 0) { maxcount++; }
					else if (weightvalues[i] > weightvalues[maxindex]) { maxindex = i; }
				}

				// If everything is at max useful capacity, flag for special handling
				if (maxindex == 0 && weightvalues[0] == 0) { maxindex = -1; }

				// Set the highest weighted item to be spawned
				user_spawntype = maxindex > -1 ? ammoitems[maxindex] : "";

				// Pick a random number of items to spawn, varying based on spawn type
				switch (maxindex)
				{
					case Health:
						user_spawnamount = Random(10, 30);
						break;
					case Shells:
						user_spawnamount = Random(12, 16);
						break;
					case Bullets:
						user_spawnamount = Random(24, 32);
						break;
					case Rifle:
						user_spawnamount = Random(15, 20);
						break;
					case Grenades:
						user_spawnamount = Random(1, 3);
						break;
					case Nothing:
					default:
						if (maxcount == ammoitems.Size()) // Spawn gold if you are at full health and full ammo capacity for all of the types given via the barrel
						{
							user_spawntype = "CoinItem";
							user_spawnamount = Random(5, 25);
						}
						else
						{
							user_spawntype = "";
						}
						break;

					// Blank user_spawntype causes code to fall back to DropItems list spawning
				}

				if (maxindex > -1)
				{
					if (ammoitems[maxindex] == "Health")
					{
						user_spawnamount = min(user_spawnamount, p.GetMaxHealth(true) - p.health);

						if (p is "TankPlayer") // Allow spawning a repair kit if needed for a tank
						{
							Inventory kit = p.FindInventory("RepairKit");
							if (!kit || kit.amount < kit.MaxAmount)
							{
								user_spawntype = "RepairKit";
								user_spawnamount = 1;
							}
						}
					}
					else
					{
						Inventory item = p.FindInventory(ammoitems[maxindex]);
						if (item) { user_spawnamount = min(user_spawnamount, item.MaxAmount - item.Amount); }
					}
				}
			}
		}

		return Super.DamageMobj(inflictor, source, damage, mod, flags, angle);
	}
}