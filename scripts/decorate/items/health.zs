/*
 * Copyright (c) 2015-2021 Tormentor667, Ozymandias81, Ed the Bat, Talon1024,
 *                         AFADoomer
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

// Meal moved to scripts/actors/items/meal.txt - Talon1024

class StackedMeal : Meal
{
	Default
	{
		//$Title Meals (2 variants, floating)
		Radius 1;
		Height 1;
		+CANPASS
		+NOGRAVITY
	}
}

class PartyMealR : Meal //no fruits for obvious reasons - ozy81
{
	Default
	{
		//$Category Health (BoA)/Party Food
		//$Title Random Edible Party Meals (+5 health)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7,8,9,10,11,12);
		PMEL A -1;
		PMEL B -1;
		PMEL C -1;
		PMEL D -1;
		PMEL E -1;
		PMEL I -1;
		PMEL J -1;
		PMEL K -1;
		PMEL L -1;
		PMEL M -1;
		PMEL P -1;
		PMEL Q -1;
		Stop;
	}
}

class StackedPartyMeal : StackedMeal
{
	Default
	{
		//$Title Party Meals (12 variants, floating)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,"MealA","MealB","MealC","MealD","MealE","MealF","MealG","MealH","MealI","MealJ","MealK","MealL");
	MealA:
		PMEL A 1;
		Loop;
	MealB:
		PMEL B 1;
		Loop;
	MealC:
		PMEL C 1;
		Loop;
	MealD:
		PMEL D 1;
		Loop;
	MealE:
		PMEL E 1;
		Loop;
	MealF:
		PMEL I 1;
		Loop;
	MealG:
		PMEL J 1;
		Loop;
	MealH:
		PMEL K 1;
		Loop;
	MealI:
		PMEL L 1;
		Loop;
	MealJ:
		PMEL M 1;
		Loop;
	MealK:
		PMEL P 1;
		Loop;
	MealL:
		PMEL Q 1;
		Loop;
	}
}

class PartyMeal1 : Meal
{
	Default
	{
		//$Category Health (BoA)/Party Food
		//$Title Edible Party Meal 1 (+5 health)
	}
	States
	{
	Spawn:
		PMEL A -1;
		Stop;
	}
}

class PartyMeal2 : PartyMeal1
{
	Default
	{
		//$Title Edible Party Meal 2 (random, +5 health)
		//$Sprite PMELB0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2);
		PMEL B -1;
		PMEL C -1;
		Stop;
	}
}

class PartyMeal3 : PartyMeal1
{
	Default
	{
		//$Title Edible Party Meal 3 (+5 health)
	}
	States
	{
	Spawn:
		PMEL J -1;
		Stop;
	}
}

class PartyMeal4 : PartyMeal1
{
	Default
	{
		//$Title Edible Party Meal 4 (random +5 health)
		//$Sprite PMELE0
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4);
		PMEL E -1;
		PMEL F -1;
		PMEL G -1;
		PMEL H -1;
		Stop;
	}
}

class PartyMeal5 : PartyMeal1
{
	Default
	{
		//$Title Edible Party Meal 5 (+5 health)
	}
	States
	{
	Spawn:
		PMEL Q -1;
		Stop;
	}
}

class PartyMeal6 : PartyMeal1
{
	Default
	{
		//$Title Edible Party Meal 6 (+5 health)
	}
	States
	{
	Spawn:
		PMEL I -1;
		Stop;
	}
}

class PartyMeal7 : PartyMeal1
{
	Default
	{
		//$Title Edible Party Meal 7 (+5 health)
	}
	States
	{
	Spawn:
		PMEL D -1;
		Stop;
	}
}

class PartyMeal8 : PartyMeal1
{
	Default
	{
		//$Title Edible Party Meal 8 (+5 health)
	}
	States
	{
	Spawn:
		PMEL K -1;
		Stop;
	}
}

class PartyMeal9 : PartyMeal1
{
	Default
	{
		//$Title Edible Party Meal 9 (+5 health)
	}
	States
	{
	Spawn:
		PMEL L -1;
		Stop;
	}
}

class PartyMeal10 : PartyMeal1
{
	Default
	{
		//$Title Edible Party Meal 10 (+5 health)
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4);
		PMEL M -1;
		PMEL N -1;
		PMEL O -1;
		PMEL P -1;
		Stop;
	}
}

class PartyMeal11 : PartyMeal1
{
	Default
	{
		//$Title Edible Party Meal 11 (+5 health)
	}
	States
	{
	Spawn:
		PMEL R -1;
		Stop;
	}
}

class PartyMeal12 : PartyMeal1
{
	Default
	{
		//$Title Edible Party Meal 12 (+5 health)
	}
	States
	{
	Spawn:
		PMEL S -1;
		Stop;
	}
}

class FastFoodR : Meal //no empty stuff and menues
{
	Default
	{
		//$Category Health (BoA)/Fast Food
		//$Title Random Edible Fast Food (+5 health)
		Scale 0.37;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6);
		FFOD A -1;
		HFHF B -1;
		FFOD G -1;
		FFOD H -1;
		FFOD J -1;
		FANT A -1;
		Stop;
	}
}

class FastFood1 : Meal
{
	Default
	{
		//$Category Health (BoA)/Fast Food
		//$Title Burger (+5 health)
		Scale 0.37;
	}
	States
	{
	Spawn:
		FFOD A -1;
		Stop;
	}
}

class FastFood2 : Meal
{
	Default
	{
		//$Category Health (BoA)/Fast Food
		//$Title Empty HFH Fried Potatoes (+1 health)
		Inventory.Amount 1;
		Scale 0.37;
	}
	States
	{
	Spawn:
		HFHF A -1;
		Stop;
	}
}

class FastFood3 : Meal
{
	Default
	{
		//$Category Health (BoA)/Fast Food
		//$Title HFH Fried Potatoes (+5 health)
		Scale 0.37;
	}
	States
	{
	Spawn:
		HFHF B -1;
		Stop;
	}
}

class FastFood4 : Meal
{
	Default
	{
		//$Category Health (BoA)/Fast Food
		//$Title Pepsi (+5 health)
		Scale 0.37;
	}
	States
	{
	Spawn:
		FFOD D -1;
		Stop;
	}
}

class FastFood5 : Meal
{
	Default
	{
		//$Category Health (BoA)/Fast Food
		//$Title Fanta (+5 health)
		Scale 0.37;
	}
	States
	{
	Spawn:
		FANT A -1;
		Stop;
	}
}

class FastFood6 : Meal
{
	Default
	{
		//$Category Health (BoA)/Fast Food
		//$Title HFH Menu (+10 health)
		Scale 0.37;
		Inventory.Amount 10;
	}
	States
	{
	Spawn:
		HFHF C -1;
		Stop;
	}
}

class FastFood7 : Meal //from Ion Fury
{
	Default
	{
		//$Category Health (BoA)/Fast Food
		//$Title Mexican Taco (+5 health)
		Scale 0.37;
	}
	States
	{
	Spawn:
		FFOD G -1;
		Stop;
	}
}

class FastFood8 : Meal //from Ion Fury
{
	Default
	{
		//$Category Health (BoA)/Fast Food
		//$Title Classic Hot Dog (+5 health)
		Scale 0.37;
	}
	States
	{
	Spawn:
		FFOD H -1;
		Stop;
	}
}

class FastFood9 : Meal
{
	Default
	{
		//$Category Health (BoA)/Fast Food
		//$Title Pop Corn, Empty (+1 health)
		Scale 0.37;
	}
	States
	{
	Spawn:
		FFOD I -1;
		Stop;
	}
}

class FastFood10 : Meal
{
	Default
	{
		//$Category Health (BoA)/Fast Food
		//$Title Pop Corn, Empty (+5 health)
		Scale 0.37;
	}
	States
	{
	Spawn:
		FFOD J -1;
		Stop;
	}
}

class FastFood11 : Meal
{
	Default
	{
		//$Category Health (BoA)/Fast Food
		//$Title Coca-Cola (+5 health)
		Scale 0.37;
	}
	States
	{
	Spawn:
		FFOD E -1;
		Stop;
	}
}

class FastFood12 : Meal
{
	Default
	{
		//$Category Health (BoA)/Fast Food
		//$Title Empty Mc Fried Potatoes (+1 health)
		Inventory.Amount 1;
		Scale 0.37;
	}
	States
	{
	Spawn:
		FFOD B -1;
		Stop;
	}
}

class FastFood13 : Meal
{
	Default
	{
		//$Category Health (BoA)/Fast Food
		//$Title Mc Fried Potatoes (+5 health)
		Scale 0.37;
	}
	States
	{
	Spawn:
		FFOD C -1;
		Stop;
	}
}

class FastFood14 : Meal
{
	Default
	{
		//$Category Health (BoA)/Fast Food
		//$Title Mc Menu (+10 health)
		Scale 0.37;
		Inventory.Amount 10;
	}
	States
	{
	Spawn:
		FFOD F -1;
		Stop;
	}
}

class EastFoodR : Meal //no empty noodles
{
	Default
	{
		//$Category Health (BoA)/Eastern Food
		//$Title Random Edible Eastern Food (+5 health)
		Scale 0.37;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3);
		EAST A -1;
		EAST C -1;
		EAST D -1;
		Stop;
	}
}

class EastFood1 : Meal
{
	Default
	{
		//$Category Health (BoA)/Eastern Food
		//$Title Noodles Can (+5 health)
		Scale 0.37;
	}
	States
	{
	Spawn:
		EAST A -1;
		Stop;
	}
}

class EastFood2 : Meal
{
	Default
	{
		//$Category Health (BoA)/Eastern Food
		//$Title Empty Noodles Can (+1 health)
		Scale 0.37;
		Inventory.Amount 1;
	}
	States
	{
	Spawn:
		EAST B -1;
		Stop;
	}
}

class EastFood3 : Meal
{
	Default
	{
		//$Category Health (BoA)/Eastern Food
		//$Title Sushi (+5 health)
	}
	States
	{
	Spawn:
		EAST C -1;
		Stop;
	}
}

class EastFood4 : Meal
{
	Default
	{
		//$Category Health (BoA)/Eastern Food
		//$Title Wasabi (+5 health)
	}
	States
	{
	Spawn:
		EAST D -1;
		Stop;
	}
}

class ShishKebab : Meal
{
	Default
	{
		//$Category Health (BoA)
		//$Title Shish Kebab (+5 health)
		Scale 0.37;
	}
	States
	{
	Spawn:
		SISH A -1;
		Stop;
	}
}

class JuicyChicken : Meal
{
	Default
	{
		//$Category Health (BoA)/Eastern Food
		//$Title Juicy Chicken (+10 health)
		Scale 0.37;
		Inventory.Amount 10;
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5);
		CHIK A -1;
		CHIK B -1;
		CHIK C -1;
		CHIK D -1;
		CHIK E -1;
		Stop;
	}
}

class CupCake1 : Meal
{
	Default
	{
		//$Category Health (BoA)/Party Food
		//$Title Cupcake, Pink (+1 health, shootable)
		Radius 4;
		Height 8;
		Health 1;
		Mass 100;
		Scale 0.08;
		Inventory.Amount 1;
		Inventory.PickupMessage "$CAKE";
		-DROPOFF
		+CANPASS
		+NOBLOOD
		+NOTAUTOAIMED
		+SHOOTABLE
		+SOLID
	}
	States
	{
	Spawn:
		CUPK A 0 NODELAY A_Jump(256,"Set1","Set2","Set3");
	Set1:
		CUPK A -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Set2:
		CUPK B -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Set3:
		CUPK C -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Death:
		"####" "#" 0 A_UnSetSolid;
		"####" "#" 0 A_StartSound("bread/crumbs", CHAN_AUTO, 0, frandom (0.5,0.8), ATTN_NORM);
		"####" "########" 0 A_SpawnItemEx("Debris_Bread", random(0,16), random(0,16), random(4,16), random(1,3), random(1,3), random(1,3), random(0,360), SXF_CLIENTSIDE);
		Stop;
	}
}

class CupCake2 : CupCake1
{
	Default
	{
		//$Title Cupcake, White (+1 health, shootable)
	}
	States
	{
	Spawn:
		CUPK D 0 NODELAY A_Jump(256,"Set1","Set2","Set3");
	Set1:
		CUPK D -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Set2:
		CUPK E -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Set3:
		CUPK F -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CupCake3 : CupCake1
{
	Default
	{
		//$Title Cupcake, Azure (+1 health, shootable)
	}
	States
	{
	Spawn:
		CUPK G 0 NODELAY A_Jump(256,"Set1","Set2","Set3");
	Set1:
		CUPK G -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Set2:
		CUPK H -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Set3:
		CUPK I -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class CupCake4 : CupCake1
{
	Default
	{
		//$Title Cupcake, Yellow (+1 health, shootable)
	}
	States
	{
	Spawn:
		CUPK J 0 NODELAY A_Jump(256,"Set1","Set2","Set3");
	Set1:
		CUPK J -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Set2:
		CUPK K -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	Set3:
		CUPK L -1 A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}
}

class Dogfood : Health
{
	Default
	{
		//$Category Health (BoA)
		//$Title Dog Food (+2)
		//$Color 6
		//$Sprite DOGFA0
		Scale 0.5;
		Inventory.Amount 2;
		Inventory.PickupMessage "$DOGFOOD";
		Inventory.PickupSound "pickup/mealfood";
	}
	States
	{
	Spawn:
		TNT1 A 0 NODELAY A_Jump(256,1,2,3,4,5,6,7);
		DOGF A -1;
		DOGF B -1;
		DOGF C -1;
		DOGF D -1;
		DOGF E -1;
		DOGF F -1;
		DOGF G -1;
		Stop;
	}

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", amount));

		return msg;
	}
}

class Medikit_Small : Health
{
	Default
	{
		//$Category Health (BoA)
		//$Title Medikit (small+10)
		//$Color 6
		Scale 0.35;
		Inventory.Amount 10;
		Inventory.PickupMessage "$MEDSML";
	}
	States
	{
	Spawn:
		MEDI A -1;
		Stop;
	}

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", amount));

		return msg;
	}
}

class Medikit_Medium : Health
{
	Default
	{
		//$Category Health (BoA)
		//$Title Medikit (medium+20)
		//$Color 6
		Scale 0.35;
		Inventory.Amount 20;
		Inventory.PickupMessage "$MEDMID";
	}
	States
	{
	Spawn:
		MEDI B -1;
		Stop;
	}

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", amount));

		return msg;
	}
}

class Medikit_Large : Health
{
	Default
	{
		//$Category Health (BoA)
		//$Title Medikit (large+40)
		//$Color 6
		Scale 0.4;
		Inventory.Amount 40;
		Inventory.PickupMessage "$MEDBIG";
	}
	States
	{
	Spawn:
		MEDI C -1 NODELAY A_SetScale(Scale.X * RandomPick(-1, 1), Scale.Y);
		Stop;
	}

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", amount));

		return msg;
	}
}

class Medikit_Fullhealth : Health //needed by Halderman on HQs
{
	Default
	{
		Inventory.Amount 200;
		Inventory.PickupMessage "$MEDBIG";
	}
	States
	{
	Spawn:
		TNT1 A -1;
		Stop;
	}
}

class FieldKit : HealthPickup
{
	Default
	{
		//$Category Health (BoA)
		//$Title Field Kit (Item, +25)
		//$Color 6
		Health 25;
		Scale 0.50;
		HealthPickup.AutoUse 1;
		Tag "$TAGFELDK";
		Inventory.Icon "FKITC0";
		Inventory.InterHubAmount 5;
		Inventory.MaxAmount 5;
		Inventory.PickupMessage "$FKIT";
		Inventory.PickupSound "Misc/I_PkUp";
		Inventory.UseSound "Misc/I_PkUp";
	}

	States
	{
		Spawn:
			FKIT AB 10;
			Loop;
	}

	override bool Use(bool pickup)
	{
		if (owner.FindInventory("HQ_Checker", true)) { return false; }
		AchievementTracker.CheckAchievement(owner.PlayerNumber(), AchievementTracker.ACH_COMBATMEDIC);
		return Super.Use(pickup);
	}

	override String PickupMessage()
	{
		String msg = StringTable.Localize(Super.PickupMessage());
		msg.Replace("%a", String.Format("%i", health));

		return msg;
	}
}
