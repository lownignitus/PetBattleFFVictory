-- Title: Pet Battle FF Victory
-- Author: LownIgnitus
-- Version: 1.2.9
-- Desc: A simple addon to change the victory sound for pet battles
-- Added Functionality to play fail sound and toggle its use

local CF = CreateFrame
local addon_name = "petbattleffvictory"
failState =	failState or "true"
levelState = levelState or "true"

--slash commands
SLASH_PBFFV1 = '/pbffv'

-- RegisterEvent table
local pbffvEvents_table = {}
-- catch functions
pbffvEvents_table.eventFrame = CF("Frame")
pbffvEvents_table.eventFrame:RegisterEvent("ADDON_LOADED")
--pbffvEvents_table.eventFrame:RegisterEvent("PET_BATTLE_OVER")
pbffvEvents_table.eventFrame:RegisterEvent("PET_BATTLE_FINAL_ROUND")
pbffvEvents_table.eventFrame:RegisterEvent("PET_BATTLE_LEVEL_CHANGED")

pbffvEvents_table.eventFrame:SetScript("OnEvent", function(self, event, ... )
	pbffvEvents_table.eventFrame[event](self, ...)
end)

function pbffvEvents_table.eventFrame:ADDON_LOADED(AddOn)
--	print("in addon load")
	if AddOn ~= addon_name then
		return
	end
--	print("in addon load after check")
	pbffvEvents_table.eventFrame:UnregisterEvent("ADDON_LOADED")

	pbffvOptionsInit()
	pbffvInitialize()
end

function pbffvOptionsInit()
	local pbffvOptions = CF("Frame", nil, InterfaceOptionsFramePanelContainer);
	local panelWidth = InterfaceOptionsFramePanelContainer:GetWidth()
	local wideWidth = panelWidth - 40
	pbffvOptions:SetWidth(wideWidth)
	pbffvOptions:Hide();
	pbffvOptions.name = "|cff00ff00Pet Battle FF Victory|r"
	pbffvOptionsBG = { edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, edgeSize = 16 }

	-- Special thanks to Ro for inspiration for the overall structure of this options panel (and the title/version/description code)
	local function createfont(fontName, r, g, b, anchorPoint, relativeto, relativePoint, cx, cy, xoff, yoff, text)
		local font = pbffvOptions:CreateFontString(nil, "BACKGROUND", fontName)
		font:SetJustifyH("LEFT")
		font:SetJustifyV("TOP")
		if type(r) == "string" then -- r is text, not position
			text = r
		else
			if r then
				font:SetTextColor(r, g, b, 1)
			end
			font:SetSize(cx, cy)
			font:SetPoint(anchorPoint, relativeto, relativePoint, xoff, yoff)
		end
		font:SetText(text)
		return font
	end

	-- Special thanks to Hugh & Simca for checkbox creation 
	local function createcheckbox(text, cx, cy, anchorPoint, relativeto, relativePoint, xoff, yoff, frameName, font)
		local checkbox = CF("CheckButton", frameName, pbffvOptions, "UICheckButtonTemplate")
		checkbox:SetPoint(anchorPoint, relativeto, relativePoint, xoff, yoff)
		checkbox:SetSize(cx, cy)
		local checkfont = font or "GameFontNormal"
		checkbox.text:SetFontObject(checkfont)
		checkbox.text:SetText(" " .. text)
		return checkbox
	end

	local title = createfont("SystemFont_OutlineThick_WTF", GetAddOnMetadata(addon_name, "Title"))
	title:SetPoint("TOPLEFT", 16, -16)
	local ver = createfont("SystemFont_Huge1", GetAddOnMetadata(addon_name, "Version"))
	ver:SetPoint("BOTTOMLEFT", title, "BOTTOMRIGHT", 4, 0)
	local date = createfont("GameFontNormalLarge", "Version Date: " .. GetAddOnMetadata(addon_name, "X-Date"))
	date:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	local author = createfont("GameFontNormal", "Author: " .. GetAddOnMetadata(addon_name, "Author"))
	author:SetPoint("TOPLEFT", date, "BOTTOMLEFT", 0, -8)
	local desc = createfont("GameFontHighlight", GetAddOnMetadata(addon_name, "Notes"))
	desc:SetPoint("TOPLEFT", author, "BOTTOMLEFT", 0, -8)

	-- Options farme
	local pbffvOptionsFarme = CF("Frame", pbffvOptionsFarme, pbffvOptions)
	pbffvOptionsFarme:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -8)
	pbffvOptionsFarme:SetBackdrop(pbffvOptionsBG)
	pbffvOptionsFarme:SetSize(240, 115)

	local optionsTitle = createfont("GameFontNormal", nil, nil, nil, "TOP", pbffvOptionsFarme, "TOP", 200, 16, 10, -8, "Pet Battle FF Victory Options")

	local failStateOpt = createcheckbox("Enable Fail sound", 18, 18, "TOPLEFT", optionsTitle, "TOPLEFT", -20, -20, "failStateOpt")

	failStateOpt:SetScript("OnClick", function(self)
		if failStateOpt:GetChecked() == true then
			failState = true
			ChatFrame1:AddMessage("Fail sound |cff00ff00enabled|r!")
		else
			failState = false
			ChatFrame1:AddMessage("Fail sound |cffff0000disabled|r!")
		end
	end)

	local failBtn = CF("Button", "failBtn", pbffvOptionsFarme, "OptionsButtonTemplate")
	failBtn:SetSize(54, 18)
	failBtn:SetPoint("TOPLEFT", failStateOpt, "TOPRIGHT", 120, 0)
	failBtn:SetScript("OnClick", function(self) 
		if failState == true then
			pbffvFail()
		end
	end)

	local failText = failBtn:CreateFontString(nil, "ARTWORK")
	isValid = failText:SetFontObject("GameFontNormal")
	failText:SetPoint("CENTER", failBtn, "CENTER", 0, 0)
	failBtn.text = failText
	failBtn.text:SetText("Test")

	local levelStateOpt = createcheckbox("Enable Level Up sound", 18, 18, "TOPLEFT", failStateOpt, "TOPLEFT", 0, -25, "levelStateOpt")

	levelStateOpt:SetScript("OnClick", function(self)
		if levelStateOpt:GetChecked() == true then
			levelState = true
			ChatFrame1:AddMessage("Level up sound |cff00ff00enabled|r!")
		else
			levelState = false
			ChatFrame1:AddMessage("Level up sound |cffff0000disabled|r!")
		end
	end)

	local levelBtn = CF("Button", "levelBtn", pbffvOptionsFarme, "OptionsButtonTemplate")
	levelBtn:SetSize(54, 18)
	levelBtn:SetPoint("TOPLEFT", levelStateOpt, "TOPRIGHT", 150, 0)
	levelBtn:SetScript("OnClick", function(self) 
		if levelState == true then
			pbffvLevelUp()
		end
	end)

	local levelText = levelBtn:CreateFontString(nil, "ARTWORK")
	isValid = levelText:SetFontObject("GameFontNormal")
	levelText:SetPoint("CENTER", levelBtn, "CENTER", 0, 0)
	levelBtn.text = levelText
	levelBtn.text:SetText("Test")

	local victoryBtn = CF("Button", "victoryBtn", pbffvOptionsFarme, "OptionsButtonTemplate")
	victoryBtn:SetSize(100, 18)
	victoryBtn:SetPoint("TOPLEFT", levelStateOpt, "BOTTOMLEFT", 0, -6)
	victoryBtn:SetScript("OnClick", function(self) pbffvVictory() end)

	local victoryText = victoryBtn:CreateFontString(nil, "ARTWORK")
	isValid = victoryText:SetFontObject("GameFontNormal")
	victoryText:SetPoint("CENTER", victoryBtn, "CENTER", 0, 0)
	victoryBtn.text = victoryText
	victoryBtn.text:SetText("Test Victory")

	function pbffvOptions.okay()
		pbffvOptions:Hide();
	end

	function pbffvOptions.cancel()
		pbffvOptions:Hide();
	end

	-- add the Options panel to the Blizzard list
	InterfaceOptions_AddCategory(pbffvOptions);
end

function pbffvInitialize()
	ChatFrame1:AddMessage(GetAddOnMetadata(addon_name, "Title") .. " " .. GetAddOnMetadata(addon_name, "Version") .. " has been loaded!")
	ChatFrame1:AddMessage("|cff00ff00/pbffv|r to access slash command list.")

	if failState == true then
		failStateOpt:SetChecked(true)
	else
		failStateOpt:SetChecked(false)
	end

	if levelState == true then
		levelStateOpt:SetChecked(true)
	else
		levelStateOpt:SetChecked(false)
	end
end

-- Print version info and slash commands
function SlashCmdList.PBFFV(msg)
	if msg == "options" then
		InterfaceOptionsFrame_OpenToCategory("|cff00ff00Pet Battle FF Victory|r")
	else
		print("Thank you for using " .. GetAddOnMetadata(addon_name, "Title"))
		print(GetAddOnMetadata(addon_name, "Version"))
		print("Slash commands are listed below to follow /pbffv:")
		print("  -- options -- Open options panel.")
	end
end

-- play victory sound
function pbffvVictory()
	StopSound(31749)
	PlaySoundFile("Interface\\AddOns\\petbattleffvictory\\Music\\Victory.ogg")
	print("|cff00ff00Victory!|r")
end

-- play Fail Sound
function pbffvFail()
	StopSound(31750)
	PlaySoundFile("Interface\\AddOns\\petbattleffvictory\\Music\\FailHorn.ogg")
	print("|cffff0000Fail....|r")
end

function pbffvLevelUp()
	StopSound(31583)
	PlaySoundFile("Interface\\AddOns\\petbattleffvictory\\Music\\LevelUp.ogg")
	print("|cffffff00Pet leveled up!|r")
end

-- detect levelup and pass to LevelUp
function pbffvEvents_table.eventFrame:PET_BATTLE_LEVEL_CHANGED()
	StopMusic();
	--print("Pet leveled up!")
	if levelState == true then
		pbffvLevelUp()
	end
end

-- detect end battle and pass to Victory or Fail
function pbffvEvents_table.eventFrame:PET_BATTLE_FINAL_ROUND(outcomenumber)
--	print("Finale Round: " .. outcomenumber)
	StopMusic();
	if outcomenumber == 1 then
		--print("1")
		pbffvVictory()
	end
	if outcomenumber == 2 then 
--		print("2 " .. failState)
		if failState == true then
--			print("Fail")
			pbffvFail()
		end
	end
end