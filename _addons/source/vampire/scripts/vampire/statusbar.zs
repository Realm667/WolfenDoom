class VampireBoAStatusBar: BoAStatusBar
{
	DynamicValueInterpolator mBloodInterpolator;

	override void NewGame ()
	{
		Super.NewGame();

		mBloodInterpolator.Reset(0);
	}
	
	override void Tick()
	{
		VampireBoAPlayer vampire = VampireBoAPlayer(CPlayer.mo);
		if (vampire) mBloodInterpolator.Update(vampire.tics_since_last_kill);

		Super.Tick();
	}
	
	override void Init()
	{
		Super.Init();

		mBloodInterpolator = DynamicValueInterpolator.Create(0, 1.25, 1, 100);

		BloodWidget.Init("Blood Bar", Widget.WDG_BOTTOM | Widget.WDG_CENTER, 2, (0, 12));
	}
}

class BloodWidget : Widget
{
	static void Init(String widgetname, int anchor = 0, int priority = 0, Vector2 pos = (0, 0), int zindex = 0)
	{
		BloodWidget wdg = BloodWidget(Widget.Init("BloodWidget", widgetname, anchor, 0, priority, pos, zindex));

		if (wdg && wdg.flags & WDG_DRAWFRAME) { wdg.flags |= WDG_DRAWFRAME_CENTERED; }
	}

	override bool IsVisible()
	{
		if (
			VampireBoAStatusBar(StatusBar) && 
			screenblocks < 12 &&
			!automapactive && 
			!VampireHandler.VampireSpecialSequenceLevel() &&
			!player.mo.FindInventory("CutsceneEnabled") &&
			!player.morphtics
		) { return true; }
		
		return false;
	}

	override Vector2 Draw()
	{
		if (!VampireBoAStatusBar(StatusBar)) { return (0, 0); }

		size = (180, 12);

		Super.Draw();

		StatusBar.DrawBar("HORZBLDF", "HORZBLDE", 1050 - VampireBoAStatusBar(StatusBar).mBloodInterpolator.GetValue(), 1050, pos, 0, StatusBar.SHADER_HORZ, StatusBar.DI_ITEM_CENTER);

		return size;
	}
}