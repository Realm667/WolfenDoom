// Written by N00b, Sep 2023
// NOTE: this messy reinvented wheel should be purged after the effect of
// cl_gfxlocalization is restored in GZDoom (if ever):
// https://forum.zdoom.org/viewtopic.php?t=75523
// You'll also have to move the "textures/localized" folder to the root and
// rename them to the GZDoom convention.

class TextureLanguageReplacement
{
	string texture;
	Array<string> languages;
}

class LocalizedTexturesHandler: EventHandler
{
	string oldlang, newlang;
	Array<TextureLanguageReplacement> rules;
	override void WorldTick()
	{
		for (int i = 0; i < MAXPLAYERS; ++i)
		{
			if (playeringame[i]) // won't be clientside anyway
			{
				newlang = CVar.GetCVar("language", players[i]).GetString();
				newlang = IsDefaultLanguage(newlang) ? "" : newlang;
				if (newlang != oldlang)
				{
					LocalizeBoATextures();
					oldlang = newlang;
				}
			}
		}
	}
	override void OnRegister()
	{
		oldlang = "";
		ParsedValue data = FileReader.Parse("data/LocalizedTextures.txt");
		rules.Resize(data.Children.Size());
		for (int i = 0; i < data.Children.Size(); i++)
		{
			rules[i] = new("TextureLanguageReplacement");
			rules[i].texture = data.Children[i].KeyName;
			data.Children[i].Value.split(rules[i].languages, ",");
		}
	}
	bool IsDefaultLanguage(string lang)
	{
		return lang == "" || lang == "auto" || lang == "default" || lang.Left(2) == "en";
	}
	string TransformTexName(string tex, string lang)
	{
		let s = lang..tex.Mid(lang.Length()); 
		return s;
	}
	void LocalizeBoATextures()
	{
		for (int i = 0; i < rules.Size(); ++i)
		{
			if (rules[i].languages.Find(newlang) != rules[i].languages.Size())
			{
				level.ReplaceTextures(TransformTexName(rules[i].texture, oldlang), TransformTexName(rules[i].texture, newlang), 0);
			}
		}
	}
}