-- SLADE Script - convert all short-named textures to full-path textures
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

--[[
local function min(first, second)
	local lowest = first
	if second < first then lowest = second end
	return lowest
end
--]]
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
else
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

	local editor = App.mapEditor()
	local map = editor.map
	local replaced = {
		flats = 0;
		walls = 0;
	}

	for i,sec in ipairs(map.sectors) do
		if texShortToFull[sec.textureFloor] ~= nil then
			sec:setStringProperty("texturefloor", texShortToFull[sec.textureFloor])
			replaced.flats = replaced.flats + 1
		end
		if texShortToFull[sec.textureCeiling] ~= nil then
			sec:setStringProperty("textureceiling", texShortToFull[sec.textureCeiling])
			replaced.flats = replaced.flats + 1
		end
	end

	for i,side in ipairs(map.sidedefs) do
		if texShortToFull[side.textureBottom] ~= nil then
			side:setStringProperty("texturebottom", texShortToFull[side.textureBottom])
			replaced.walls = replaced.walls + 1
		end
		if texShortToFull[side.textureMiddle] ~= nil then
			side:setStringProperty("texturemiddle", texShortToFull[side.textureMiddle])
			replaced.walls = replaced.walls + 1
		end
		if texShortToFull[side.textureTop] ~= nil then
			side:setStringProperty("texturetop", texShortToFull[side.textureTop])
			replaced.walls = replaced.walls + 1
		end
	end

	App.messageBox("Done with " .. map.name .. "!", "Replaced " .. replaced.flats .. " floor/ceiling textures and " .. replaced.walls .. " wall textures")
end
