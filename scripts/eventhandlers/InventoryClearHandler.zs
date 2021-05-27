/*
 * Copyright (c) 2018-2020 EdTheBat, AFADoomer
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

class InventoryClearHandler : EventHandler
{
	bool preventClearing;
	bool heartbeat;

	// Set this code as static so that it can be called from other scripts, consolidate
	// updates to one place , and avoid copy/paste duplication of the inventory resets.
	void ResetPlayerInventory(Actor mo, bool ignoreclass = false)
	{
		if (BoAPlayer(mo) || ignoreclass)
		{
			// Give the player the camera tilt handling item (modified version of Nash's Tilt++ v1.3)
			mo.A_GiveInventory("BoATilt", 1);
			mo.A_GiveInventory("BoASprinting", 1);
			mo.A_GiveInventory("BoAHeartBeat", 1);
		}

		mo.A_GiveInventory("BoAVisibility", 1);
		mo.A_GiveInventory("BoAUnderwater", 1);
		mo.A_GiveInventory("BoAFootsteps", 1);

		// Force reset of certain shader effects
		mo.A_SetInventory("OldVideoShaderControl", 1);
		mo.A_SetInventory("BlurShaderControl", 1);
		mo.A_SetInventory("HeatShaderControl", 1);
		mo.A_SetInventory("SandShaderControl", 1);
		mo.A_SetInventory("ColorGradeShaderControl", 1);
		mo.A_SetInventory("NauseaShaderControl", 1);
		mo.A_SetInventory("PainShaderControl", 1);

		mo.A_GiveInventory("NullWeapon", 1);
	}

	// Static call to allow easy resetting of the default inventory items from actor code
	static void GiveDefaultInventory(Actor mo, bool ignoreclass = false)
	{
		if (!mo) { return; }

		let handler = InventoryClearHandler(EventHandler.Find("InventoryClearHandler"));
		if (handler) { handler.ResetPlayerInventory(mo, ignoreclass); }
	}

	static void SetShouldNotClear(bool shouldNotClear)
	{
		InventoryClearHandler handler = InventoryClearHandler(EventHandler.Find("InventoryClearHandler"));
		handler.preventClearing = shouldNotClear;
	}

	override void PlayerEntered(PlayerEvent e)
	{
		let me = PlayerPawn(players[e.PlayerNumber].mo);

		if (!me) { return; }

		ResetPlayerInventory(me);

		// Remove level-specific inventory items, and other items which should
		// not persist between missions.
		static const class<Inventory> itemTypes[] = {
			"CKPogoStick",
			"CKLedgeGrab",
			"CKTreasure", // Keen levels can be played more than once now
			"CKStunnerAmmo",
			"TextPaperCollectible",
			"TextPaperSecretHint",
			"IncomingMessage",
			"CutsceneEnabled"
		};
		for (int i = 0; i < 8; i++)
		{
			let invitem = me.FindInventory(itemTypes[i]);
			if (invitem)
			{
				me.RemoveInventory(invitem);
			}
		}

		// Ed the Bat's updated weapon stripping
		if(level.levelnum!=99 || preventClearing)
			return;
		DropItem drop=me.GetDropItems();
		
		for(int i=0;i<AllActorClasses.Size();i++)
		{
			let type=AllActorClasses[i];
			// First, remove all weapons, except those with the UNDROPPABLE flag
			if(type is "Weapon")
			{
				let weptype=(class<weapon>)(type);
				let wepitem=weapon(me.FindInventory(weptype));
				if(wepitem!=null&&!wepitem.bUNDROPPABLE)
					me.A_TakeInventory(name(weptype));
			}
			// Remove all ammo, except that with the UNDROPPABLE flag
			if(type is "Ammo")
			{
				let ammotype=(class<ammo>)(type);
				let ammoitem=ammo(me.FindInventory(ammotype));
				if(ammoitem!=null&&!ammoitem.bUNDROPPABLE)
					me.A_TakeInventory(name(ammotype));
			}
		}
		//If the player has any weapons in StartItem, set them here
		//They're not supposed to come with ammo, so clear that after this
		if(drop!=null)
		{
			for(DropItem di=drop;di!=null;di=di.Next)
			{
				if(di.Name=='None')
					continue;
				let weptype=(class<weapon>)(di.Name);
				if(weptype!=null)
					me.A_SetInventory(di.Name,di.Amount);
			}
		}
		//If the player has any ammo in StartItem, set it here
		if(drop!=null)
		{
			for(DropItem di=drop;di!=null;di=di.Next)
			{
				if(di.Name=='None')
					continue;
				let ammotype=(class<ammo>)(di.Name);
				if(ammotype!=null)
					me.A_SetInventory(di.Name,di.Amount);
			}
		}
	}

	override void NetworkProcess(ConsoleEvent e)
	{
		if (e.Name == "heartbeat")
		{
			heartbeat = e.args[0];

			let mo = players[consoleplayer].mo;
			if (mo)
			{
				Inventory hb = mo.FindInventory("BoAHeartbeat");
				if (!hb) { hb = mo.GiveInventoryType("BoAHeartBeat"); }
				if (hb) { hb.bDormant = !heartbeat; }
			}
		}
	}

	override void UITick()
	{
		bool beat = !BaseStatusBar.GetGlobalACSValue(5); // This is only accessible in ui context
		bool cutscene = !!players[consoleplayer].mo.FindInventory("CutsceneEnabled");
		
		if (beat != heartbeat || cutscene)
		{
			EventHandler.SendNetworkEvent("heartbeat", cutscene ? false : beat);
		}
	}
}