// Text credits. The map owns the schedule; layout never changes its duration.
// CREDITROLL_ORDER lists B:KEY (BIGFONT) / S:KEY (SMALLFONT), one per line.
// Text and ordering are maintained in the LANGUAGE Google spreadsheet.
class CreditsRollHandler : EventHandler
{
    int startTic, duration;
    bool running;

    transient ui Array<String> lines;
    transient ui Array<bool> headings;
    transient ui Array<double> offsets;
    transient ui double totalHeight;
    transient ui Font titleFont, bodyFont;
    transient ui double titleScale, bodyScale;
    transient ui String cachedLanguage;
    transient ui bool layoutReady;

    const ViewWidth = 640;
    const ViewHeight = 480;
    const TextWidth = 540;

    static void Start(int tics)
    {
        let handler = CreditsRollHandler(EventHandler.Find("CreditsRollHandler"));
        if (!handler || tics <= 0) { return; }
        handler.startTic = level.maptime;
        handler.duration = tics;
        handler.running = true;
    }

    override void WorldTick()
    {
        if (running && level.maptime - startTic >= duration) { running = false; }
    }

    ui void BuildLayout()
    {
        lines.Clear(); headings.Clear(); offsets.Clear();
        totalHeight = 0;
        titleFont = Font.GetFont("BIGFONT");
        bodyFont = Font.GetFont("SMALLFONT");
        titleScale = 24.0 / max(1, titleFont.GetHeight());
        bodyScale = 14.0 / max(1, bodyFont.GetHeight());

        Array<String> entries;
        String order = StringTable.Localize("CREDITROLL_ORDER", false);
        order.Split(entries, "\n");
        for (int i = 0; i < entries.Size(); i++)
        {
            String entry = entries[i];
            if (entry.Left(2) != "B:" && entry.Left(2) != "S:") { continue; }
            bool heading = entry.Left(2) == "B:";
            String key = entry.Mid(2);
            String text = StringTable.Localize(key, false);
            // Missing/empty entries do not leave holes or print identifiers.
            if (!text.Length() || text == key) { continue; }
            Font fnt = heading ? titleFont : bodyFont;
            double scale = heading ? titleScale : bodyScale;
            let wrapped = fnt.BreakLines(text, int(TextWidth / scale));
            if (heading && lines.Size()) { totalHeight += 20; }
            for (int j = 0; j < wrapped.Count(); j++)
            {
                lines.Push(wrapped.StringAt(j));
                headings.Push(heading);
                offsets.Push(totalHeight);
                totalHeight += fnt.GetHeight() * scale + 4;
            }
            totalHeight += heading ? 8 : 12;
        }
        cachedLanguage = CVar.FindCVar("language").GetString();
        layoutReady = true;
    }

    override void RenderOverlay(RenderEvent e)
    {
        if (!running) { return; }
        if (!layoutReady || cachedLanguage != CVar.FindCVar("language").GetString()) { BuildLayout(); }

        // Measure AFTER localization and word wrapping. All lengths cross the
        // same two endpoints at exactly the same simulation tics, even at low FPS.
        double elapsed = clamp(level.maptime - startTic + e.FracTic, 0, duration);
        double top = ViewHeight - (ViewHeight + totalHeight) * elapsed / duration;
        double scale = min(Screen.GetWidth() / double(ViewWidth), Screen.GetHeight() / double(ViewHeight));
        double left = (Screen.GetWidth() - ViewWidth * scale) * 0.5;
        double upper = (Screen.GetHeight() - ViewHeight * scale) * 0.5;

        for (int i = 0; i < lines.Size(); i++)
        {
            Font fnt = headings[i] ? titleFont : bodyFont;
            double size = headings[i] ? titleScale : bodyScale;
            double y = top + offsets[i];
            if (y + fnt.GetHeight() * size < 0 || y >= ViewHeight) { continue; }
            double x = (ViewWidth - fnt.StringWidth(lines[i]) * size) * 0.5;
            Screen.DrawText(fnt, Font.CR_WHITE, left + x * scale, upper + y * scale, lines[i],
                DTA_ScaleX, size * scale, DTA_ScaleY, size * scale,
                DTA_ClipTop, int(upper), DTA_ClipBottom, int(upper + ViewHeight * scale));
        }
    }
}
