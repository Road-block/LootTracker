local LootTrackerOptions_DefaultSettings = {
	enabled = true,
	uncommon = false,
	common = false,
	rare = true,
	epic = true,
	legendary = true
}

local function LootTracker_Initialize()
	if not LootTrackerOptions  then
		LootTrackerOptions = {};
	end

	for i in LootTrackerOptions_DefaultSettings do
		if (not LootTrackerOptions[i]) then
			LootTrackerOptions[i] = LootTrackerOptions_DefaultSettings[i];
		end
	end
end
	
function LootTracker_OnLoad()

	DEFAULT_CHAT_FRAME:AddMessage(string.format("LootTracker v%s by %s", GetAddOnMetadata("LootTracker", "Version"), GetAddOnMetadata("LootTracker", "Author")));
    this:RegisterEvent("VARIABLES_LOADED");
    this:RegisterEvent("CHAT_MSG_LOOT")
	--CHAT_MSG_LOOT examples:
	--You receive loot: |cffffffff|Hitem:769:0:0:0|h[Chunk of Boar Meat]|h|r.
	--Luise receives loot: |cffffffff|Hitem:769:0:0:0|h[Chunk of Boar Meat]|h|r.
    
	SlashCmdList["LootTracker"] = LootTracker_SlashCommand;
	SLASH_LootTracker1 = "/loottracker";
	SLASH_LootTracker2 = "/lt";
	
	local MSG_PREFIX = "LootTracker"
	
	
	LootTracker_pattern_playername = "^([^%s]+) receive" 
	LootTracker_pattern_itemname = "%[(.+)]"
	LootTracker_pattern_itemid = "item:(%d+)"
	LootTracker_pattern_rarityhex = "(.+)|c(.+)|H"
 	you = "You"
	
	LootTracker_color_common = "ffffffff"
	LootTracker_color_uncommon = "ff1eff00"
	LootTracker_color_rare = "ff0070dd"
	LootTracker_color_epic = "ffa335ee"
	LootTracker_color_legendary = "ffff8000"
	
	LootTracker_dbfield_playername = "playername"
	LootTracker_dbfield_itemname = "itemname"
	LootTracker_dbfield_itemid = "itemid"
	LootTracker_dbfield_rarity = "rarity"
	LootTracker_dbfield_timestamp = "timestamp"
	LootTracker_dbfield_zone = "zone"
	LootTracker_dbfield_oldplayergp = "oldplayergp"
	LootTracker_dbfield_gpcost = "gpcost"
	LootTracker_dbfield_newplayergp = "newgp"
	LootTracker_dbfield_res1 = "res1"
	LootTracker_dbfield_res2 = "res2"
	LootTracker_dbfield_res3 = "res3"
	LootTracker_dbfield_res4 = "res4"
	LootTracker_dbfield_res5 = "res5"
end

function LootTracker_OnEvent()
	if event == "VARIABLES_LOADED" then
		this:UnregisterEvent("VARIABLES_LOADED");
		LootTracker_Initialize();
	elseif event == "CHAT_MSG_LOOT" and arg1 and LootTrackerOptions["enabled"] == true then
		
		--extract the person who looted
		local _, _, playername = string.find(arg1, LootTracker_pattern_playername)
		if playername then
			if playername == you then
				playername = UnitName("player")
			end
		end
		
		--extract the itemname
		local _, _, itemname = string.find(arg1, LootTracker_pattern_itemname)
		
		--extract the item id
		local _, _, itemid = string.find(arg1, LootTracker_pattern_itemid)

		--extract rarity
		local _, _, _, rarityhex = string.find(arg1, LootTracker_pattern_rarityhex)

		--check rarity and add itemname to db
		if rarityhex == LootTracker_color_common and LootTrackerOptions["common"] == true then
			rarity = "common"
			LootTracker_AddtoDB (playername, itemname, itemid, rarity)
		elseif rarityhex == LootTracker_color_uncommon and LootTrackerOptions["uncommon"] == true then
			rarity = "uncommon"
			LootTracker_AddtoDB (playername, itemname, itemid, rarity)
		elseif rarityhex == LootTracker_color_rare and LootTrackerOptions["rare"] == true then
			rarity = "rare"
			LootTracker_AddtoDB (playername, itemname, itemid, rarity)
		elseif rarityhex == LootTracker_color_epic and LootTrackerOptions["epic"] == true then
			rarity = "epic"
			LootTracker_AddtoDB (playername, itemname, itemid, rarity)
		elseif rarityhex == LootTracker_color_legendary and LootTrackerOptions["legendary"] == true then
			rarity = "legendary"
			LootTracker_AddtoDB (playername, itemname, itemid, rarity)
		end
	end
end

function LootTracker_AddtoDB(playername, itemname, itemid, rarity)
	
	--get the metadata
	timestamp_raidid = date("%y-%m-%d")
	timestamp_detail = date("%y-%m-%d %H:%M:%S")
	zonename = GetRealZoneText();
	raidid = timestamp_raidid .. " " .. zonename
	

	--check if db is empty
	if LootTrackerDB == nil then
		LootTrackerDB = {}
	end
	if LootTrackerDB[raidid] == nil then
		LootTrackerDB[raidid] = {}
	end
	
	--import the itemname into the db
	if playername and itemname and itemid and rarity and timestamp_detail and zonename then
		if getn(LootTrackerDB[raidid]) == 0 then
			LootTrackerDB[raidid][1] = {}
			LootTrackerDB[raidid][1][LootTracker_dbfield_playername] = playername
			LootTrackerDB[raidid][1][LootTracker_dbfield_itemname] = itemname
			LootTrackerDB[raidid][1][LootTracker_dbfield_itemid] = itemid
			LootTrackerDB[raidid][1][LootTracker_dbfield_rarity] = rarity
			LootTrackerDB[raidid][1][LootTracker_dbfield_timestamp] = timestamp_detail
			LootTrackerDB[raidid][1][LootTracker_dbfield_zone] = zonename
			LootTrackerDB[raidid][1][LootTracker_dbfield_oldplayergp] = nil
			LootTrackerDB[raidid][1][LootTracker_dbfield_gpcost] = nil
			LootTrackerDB[raidid][1][LootTracker_dbfield_newplayergp] = nil
			LootTrackerDB[raidid][1][LootTracker_dbfield_res1] = nil
			LootTrackerDB[raidid][1][LootTracker_dbfield_res2] = nil
			LootTrackerDB[raidid][1][LootTracker_dbfield_res3] = nil
			LootTrackerDB[raidid][1][LootTracker_dbfield_res4] = nil
			LootTrackerDB[raidid][1][LootTracker_dbfield_res5] = nil
		else
			lootid = getn(LootTrackerDB[raidid])+1
			LootTrackerDB[raidid][lootid] = {}
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_playername] = playername
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_itemname] = itemname
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_itemid] = itemid
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_rarity] = rarity
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_timestamp] = timestamp_detail
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_zone] = zonename
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_oldplayergp] = nil
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_gpcost] = nil
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_newplayergp] = nil
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_res1] = nil
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_res2] = nil
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_res3] = nil
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_res4] = nil
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_res5] = nil
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("LootTracker Debug: Error in LootTracker_AddtoDB")
	end
end

function LootTracker_Database()
	DEFAULT_CHAT_FRAME:AddMessage("Dumping Database:")
end

function LootTracker_SlashCommand(msg)

	if msg == "help" then
		DEFAULT_CHAT_FRAME:AddMessage("LootTracker DB is saved to: WTF\\Account\\ACCOUNTNAME\\SavedVariables\\LootTracker.lua")
		DEFAULT_CHAT_FRAME:AddMessage("LootTracker usage:")
		DEFAULT_CHAT_FRAME:AddMessage("/lt or /loottracker { help | enable | disable | toggle | show | database | reset | uncommon | common | rare | epic | legendary }")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9help|r: prints out this help")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9enable|r: enables loot tracking")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9disable|r: disables loot tracking")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9toggle|r: toggles loot tracking")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9show|r: shows the current configuration")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9database|r: shows the loot database")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9reset|r: resets the loot database")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9uncommon|r: toggles tracking uncommon loot")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9common|r: toggles tracking common loot")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9rare|r: toggles tracking rare loot")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9epic|r: toggles tracking epic loot")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9legendary|r: toggles tracking legendary loot")
	elseif msg == "toggle" then
		if LootTrackerOptions["enabled"] == true then
			LootTrackerOptions["enabled"] = false
			DEFAULT_CHAT_FRAME:AddMessage("LootTracker state: |cffff0000disabled|r")
		elseif LootTrackerOptions["enabled"] == false then
			LootTrackerOptions["enabled"] = true
			DEFAULT_CHAT_FRAME:AddMessage("LootTracker state: |cff00ff00enabled|r")
		end
	elseif msg == "enable" then
		LootTrackerOptions["enabled"] = true
			DEFAULT_CHAT_FRAME:AddMessage("LootTracker state: |cff00ff00enabled|r")
	elseif msg == "disable" then
		LootTrackerOptions["enabled"] = false
			DEFAULT_CHAT_FRAME:AddMessage("LootTracker state: |cffff0000disabled|r")
	elseif msg == "show" then
	
		if LootTrackerOptions["enabled"] == true then
			DEFAULT_CHAT_FRAME:AddMessage("LootTracker state: |cff00ff00enabled|r")
		elseif LootTrackerOptions["enabled"] == false then
			DEFAULT_CHAT_FRAME:AddMessage("LootTracker state: |cffff0000disabled|r")
		end
	
		if LootTrackerOptions["common"] == true then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffffffffcommon|r loot: |cff00ff00enabled|r")
		elseif LootTrackerOptions["common"] == false then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffffffffcommon|r loot: |cffff0000disabled|r")
		end

		if LootTrackerOptions["uncommon"] == true then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cff1eff00uncommon|r loot: |cff00ff00enabled|r")
		elseif LootTrackerOptions["uncommon"] == false then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cff1eff00uncommon|r loot: |cffff0000disabled|r")
		end

		if LootTrackerOptions["rare"] == true then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cff0070ddrare|r loot: |cff00ff00enabled|r")
		elseif LootTrackerOptions["rare"] == false then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cff0070ddrare|r loot: |cffff0000disabled|r")
		end

		if LootTrackerOptions["epic"] == true then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffa335eeepic|r loot: |cff00ff00enabled|r")
		elseif LootTrackerOptions["epic"] == false then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffa335eeepic|r loot: |cffff0000disabled|r")
		end

		if LootTrackerOptions["legendary"] == true then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffff8000legendary|r loot: |cff00ff00enabled|r")
		elseif LootTrackerOptions["legendary"] == false then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffff8000legendary|r loot: |cffff0000disabled|r")
		end

	elseif msg == "database" then
		LootTracker_Database();
	elseif msg == "reset" then
		LootTrackerDB = {}
		DEFAULT_CHAT_FRAME:AddMessage("Loot Database has been reset")
	elseif msg == "common" then		
		if LootTrackerOptions["common"] == true then
			LootTrackerOptions["common"] = false
			DEFAULT_CHAT_FRAME:AddMessage("Tracking common loot: |cffff0000disabled|r")
		elseif LootTrackerOptions["common"] == false then
			LootTrackerOptions["common"] = true
			DEFAULT_CHAT_FRAME:AddMessage("Tracking common loot: |cff00ff00enabled|r")
		end
	elseif msg == "uncommon" then		
		if LootTrackerOptions["uncommon"] == true then
			LootTrackerOptions["uncommon"] = false
			DEFAULT_CHAT_FRAME:AddMessage("Tracking uncommon loot: |cffff0000disabled|r")
		elseif LootTrackerOptions["uncommon"] == false then
			LootTrackerOptions["uncommon"] = true
			DEFAULT_CHAT_FRAME:AddMessage("Tracking uncommon loot: |cff00ff00enabled|r")
		end
	elseif msg == "rare" then		
		if LootTrackerOptions["rare"] == true then
			LootTrackerOptions["rare"] = false
			DEFAULT_CHAT_FRAME:AddMessage("Tracking rare loot: |cffff0000disabled|r")
		elseif LootTrackerOptions["rare"] == false then
			LootTrackerOptions["rare"] = true
			DEFAULT_CHAT_FRAME:AddMessage("Tracking rare loot: |cff00ff00enabled|r")
		end
	elseif msg == "epic" then		
		if LootTrackerOptions["epic"] == true then
			LootTrackerOptions["epic"] = false
			DEFAULT_CHAT_FRAME:AddMessage("Tracking epic loot: |cffff0000disabled|r")
		elseif LootTrackerOptions["epic"] == false then
			LootTrackerOptions["epic"] = true
			DEFAULT_CHAT_FRAME:AddMessage("Tracking epic loot: |cff00ff00enabled|r")
		end
	elseif msg == "legendary" then		
		if LootTrackerOptions["legendary"] == true then
			LootTrackerOptions["legendary"] = false
			DEFAULT_CHAT_FRAME:AddMessage("Tracking legendary loot: |cffff0000disabled|r")
		elseif LootTrackerOptions["legendary"] == false then
			LootTrackerOptions["legendary"] = true
			DEFAULT_CHAT_FRAME:AddMessage("Tracking legendary loot: |cff00ff00enabled|r")
		end
	elseif msg == "browse" then
		if (LootTracker_BrowseFrame:IsVisible()) then
			LootTracker_BrowseFrame:Hide()
		else
			LootTracker_RefreshBrowseList()
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("LootTracker DB is saved to: WTF\Account\ACCOUNTNAME\SavedVariables\LootTracker.lua")
		DEFAULT_CHAT_FRAME:AddMessage("LootTracker usage:")
		DEFAULT_CHAT_FRAME:AddMessage("/lt or /loottracker { help | enable | disable | toggle | show | database | reset | uncommon | common | rare | epic | legendary }")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9help|r: prints out this help")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9enable|r: enables loot tracking")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9disable|r: disables loot tracking")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9toggle|r: toggles loot tracking")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9show|r: shows the current configuration")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9database|r: shows the loot database")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9reset|r: resets the loot database")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9uncommon|r: toggles tracking uncommon loot")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9common|r: toggles tracking common loot")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9rare|r: toggles tracking rare loot")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9epic|r: toggles tracking epic loot")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cff9482c9legendary|r: toggles tracking legendary loot")
	end

end


--GUI stuff
function LootTracker_Main_OnShow()
	--if (MI2BSave and MI2BSave.framepos_L and MI2BSave.framepos_T) then
	--	this:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", MI2BSave.framepos_L, MI2BSave.framepos_T);
	--end
end


-- this function is called when the frame starts being dragged around
function LootTracker_Main_OnMouseDown(arg1)
	if (arg1 == "LeftButton") then
		this:StartMoving();
	end
end


-- this function is called when the frame is stopped being dragged around
function LootTracker_Main_OnMouseUp(arg1)
	if (arg1 == "LeftButton") then
		this:StopMovingOrSizing()
		
		-- save the position 
		--MI2BSave.framepos_L = this:GetLeft();
		--MI2BSave.framepos_T = this:GetTop();

	end
end

function LootTracker_RefreshBrowseList()
	ShowUIPanel(LootTracker_BrowseFrame, 1)
	LootTracker_BrowseTable = {}
	
	--arg needed
	local raidid = "16-12-25 Badlands"

	local iNew = 1;
	for index in LootTrackerDB[raidid] do
		DEFAULT_CHAT_FRAME:AddMessage(index)
		
		DEFAULT_CHAT_FRAME:AddMessage(LootTrackerDB[raidid][index][LootTracker_dbfield_itemid])
		DEFAULT_CHAT_FRAME:AddMessage(LootTrackerDB[raidid][index][LootTracker_dbfield_itemname])

		
		LootTracker_BrowseTable[iNew] = {}
		
		LootTracker_BrowseTable[iNew].itemid = LootTrackerDB[raidid][index][LootTracker_dbfield_itemid]
		LootTracker_BrowseTable[iNew].itemname = LootTrackerDB[raidid][index][LootTracker_dbfield_itemname]
		iNew = iNew + 1;
	end

	
	local line
	
	if (not LootTracker_BrowseTable.onePastEnd) then
		LootTracker_BrowseTable.onePastEnd = 3;	
	end
	
	for line=1, 3, 1 do
	DEFAULT_CHAT_FRAME:AddMessage(LootTracker_BrowseTable[line].itemid)
		getglobal("LootTracker_List"..line.."TextItemID"):SetText(LootTracker_BrowseTable[line].itemid);
		getglobal("LootTracker_List"..line.."TextItemName"):SetText(LootTracker_BrowseTable[line].itemname);
		getglobal("LootTracker_List"..line):Show();
	end
	
end

--fires when a line in the browse frame list is clicked
function LootTracker_ListButton_OnClick(arg1)

end
