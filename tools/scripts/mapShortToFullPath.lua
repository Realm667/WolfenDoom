-- SLADE Script - convert all short-named textures to full-path textures

function execute(map)
	-- Utility functions
	local function strEndsWith(haystack, needle, case)
		if case == nil then case = true end -- Default value
		local rneedle = string.reverse(needle)
		local rhaystack = string.reverse(haystack)
		if case == false then
			rneedle = string.upper(rneedle)
			rhaystack = string.upper(rhaystack)
		end

		if (string.find(rhaystack, rneedle) == 1) then return true end
		return false
	end

	local function strStartsWith(haystack, needle, case)
		if case == nil then case = true end
		if case == false then
			haystack = string.upper(haystack)
			needle = string.upper(needle)
		end
		if (string.find(haystack, needle) == 1) then return true end
		return false
	end

	local function min(...)
		local args = {...}
		local lowest = args[1]
		for i,n in ipairs(args) do
			if n < lowest then lowest = n end
		end
		return lowest
	end

	-- Main code

	local function archiveByName(name)
		for i,archive in ipairs(Archives.all()) do
			if strEndsWith(archive.filename, name) then
				return archive
			end
		end
		return nil
	end

	local archiveName = "WolfenDoom"
	local archive = archiveByName(archiveName)

	-- Ensure WolfenDoom archive is open

	if archive == nil then
		App.messageBox(archiveName .. " is not open!", "Please open " .. archiveName)
		return nil
	end

	-- Get all short-named textures, and their full-path equivalents
	local texShortToFull = {}

	for i,entry in ipairs(archive.entries) do
		if strStartsWith(entry.path, "/textures", false) then
			-- Poor man's way of distinguishing between directories and files
			local dotPos = string.find(entry.name, ".", 1, true)
			if (dotPos ~= nil) then
				dotPos = dotPos - 1
				local short = string.upper(string.sub(entry.name, 1, min(dotPos, 8) ))
				local long = string.sub(entry.path .. entry.name, 2)
				texShortToFull[short] = long
			end
		end
	end

	if map.name == "" then
		App.messageBox("Error", "No map open!")
		return nil
	end

	local replaced = {
		flats = 0;
		walls = 0;
	}

	texShortToFull["F_SKY1"] = nil -- Do not replace skies!

	for i,sec in ipairs(map.sectors) do
		-- Just in case...
		local floortex = string.upper(sec.textureFloor)
		local ceiltex = string.upper(sec.textureCeiling)

		if texShortToFull[floortex] ~= nil then
			sec:setStringProperty("texturefloor", texShortToFull[floortex])
			replaced.flats = replaced.flats + 1
		end
		if texShortToFull[ceiltex] ~= nil then
			sec:setStringProperty("textureceiling", texShortToFull[ceiltex])
			replaced.flats = replaced.flats + 1
		end
	end

	for i,side in ipairs(map.sidedefs) do
		-- Again, just in case.
		local btmtex = string.upper(side.textureBottom)
		local midtex = string.upper(side.textureMiddle)
		local toptex = string.upper(side.textureTop)

		if texShortToFull[btmtex] ~= nil then
			side:setStringProperty("texturebottom", texShortToFull[btmtex])
			replaced.walls = replaced.walls + 1
		end
		if texShortToFull[midtex] ~= nil then
			side:setStringProperty("texturemiddle", texShortToFull[midtex])
			replaced.walls = replaced.walls + 1
		end
		if texShortToFull[toptex] ~= nil then
			side:setStringProperty("texturetop", texShortToFull[toptex])
			replaced.walls = replaced.walls + 1
		end
	end

	App.messageBox("Done with " .. map.name .. "!", "Replaced " .. replaced.flats .. " floor/ceiling textures and " .. replaced.walls .. " wall textures")

end