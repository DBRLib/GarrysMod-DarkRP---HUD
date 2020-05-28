--[[---------------------------------------------------------------------------
EQD HUD V1.1.2

@author/coder Deven Ronquillo

@designer/artist Arawrrawr

@Version 9/22/2018

--USEFULL EQUATIONS--

equations are only relivant for 16:9 aspect ratio. they were all calculated using 1600 x 900 dimensions.

-for position-

width from the left of the screen to the object / screen width = x position

(screen height - objects height - height from the bottom of the screen to the bottom of the object) / screen height = y position

-for size-

object width / (screen width / 2) = x dimension

object height / (screen height / 2) = y dimension



---------------------------------------------------------------------------]]--


--[[---------------------------------------------------------------------------
Which default HUD elements should be hidden?
---------------------------------------------------------------------------]]--

local hideHUDElements = {
	-- if you DarkRP_HUD this to true, ALL of DarkRP's HUD will be disabled. That is the health bar and stuff,
	-- but also the agenda, the voice chat icons, lockdown text, player arrested text and the names above players' heads
	["DarkRP_HUD"] = false,

	-- DarkRP_EntityDisplay is the text that is drawn above a player when you look at them.
	-- This also draws the information on doors and vehicles
	["DarkRP_EntityDisplay"] = false,

	-- DarkRP_ZombieInfo draws information about zombies for admins who use /showzombie.
	["DarkRP_ZombieInfo"] = false,

	-- This is the one you're most likely to replace first
	-- DarkRP_LocalPlayerHUD is the default HUD you see on the bottom left of the screen
	-- It shows your health, job, salary and wallet, but NOT hunger (if you have hungermod enabled)
	["DarkRP_LocalPlayerHUD"] = true,

	-- If you have hungermod enabled, you will see a hunger bar in the DarkRP_LocalPlayerHUD
	-- This does not get disabled with DarkRP_LocalPlayerHUD so you will need to disable DarkRP_Hungermod too
	["DarkRP_Hungermod"] = true,

	-- Drawing the DarkRP agenda
	["DarkRP_Agenda"] = false,

	-- Lockdown info on the HUD
	["DarkRP_LockdownHUD"] = false,

	-- Arrested HUD
	["DarkRP_ArrestedHUD"] = false,
}

-- this is the code that actually disables the drawing.

--this code was moved into the draw hub function

--if true then return end -- REMOVE THIS LINE TO ENABLE THE CUSTOM HUD BELOW

--[[---------------------------------------------------------------------------
global vars
---------------------------------------------------------------------------]]--

local x = ScrW() --fetches screen size
local y = ScrH() --fetches screen size

-- Universal Scale Factor master function
local function uSF(pixelsAt4K)

	local percentage

	if (y <= 3840) then
		percentage = y / 3840 -- Get the screen size difference as a percentage
	else
		percentage = 1
	end

	-- Percentage Manipulations
	percentage = percentage * 3.6

	-- Number Conversion
	local rawNumber = math.Round(Lerp(percentage, 0, pixelsAt4K), 0)
	if rawNumber == 0 then
		return 1
	else
		return rawNumber
	end

end



--CHRISTMAS COLORS--
--Color(218, 218, 218, 104) --color for light grays
--Color(0, 127, 31, 237) --color for mid grays
--Color(127, 0, 0, 252) --color for dark grays

colorZone1 = CreateClientConVar("cl_colorZone1", "100 100 100 150", true, false, "Value for color zone 1 of luna's hud elements")
colorZone2 = CreateClientConVar("cl_colorZone2", "060 060 060 180", true, false, "Value for color zone 2 of luna's hud elements")
colorZone3 = CreateClientConVar("cl_colorZone3", "035 035 035 200", true, false, "Value for color zone 3 of luna's hud elements")


eqdHudColorBox1 = CreateClientConVar( "eqdHudColorBox1", "false", false, false, "" )
eqdHudColorBox2 = CreateClientConVar( "eqdHudColorBox2", "false", false, false, "" )
eqdHudColorBox3 = CreateClientConVar( "eqdHudColorBox3", "false", false, false, "" )
eqdHudColorBoxReset = CreateClientConVar( "eqdHudColorBoxReset", "false", false, false, "" )

ply = nil
playerAvatarVal = ""
playerNameVal = ""
playerJobVal = ""
playerRankVal = ""
playerMoneyVal = 0
playerSalaryVal = 0
playerWantedVal = false
playerGunLicenseVal = false
playerHealthVal = 0
playerPropCountVal = -1

surface.CreateFont( "hudBigFont", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = uSF(20),
	weight = 550,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "hudSmallFont", {
	font = "Arial", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = uSF(15),
	weight = 550,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

--[[---------------------------------------------------------------------------
HUD elements supporting functions
---------------------------------------------------------------------------]]--

local function addComma(n)

	local sn = tostring(n)
	local tab = {}
	sn = string.ToTable(sn)
	for i = 0,#sn-1 do
		if i % 3 == #sn % 3 and i ~= 0 then
			table.insert(tab, ",")
		end
		table.insert(tab, sn[ i + 1 ])
	end
	return string.Implode("", tab)
end

--print( ply )

local function checkPlayerInfo()

	ply = LocalPlayer()

	if playerAvatarVal ~= ply then

		playerAvatarVal = ply
		avatar:SetPlayer(playerAvatarVal, 184)
	end

	if playerNameVal ~= ply:getDarkRPVar("rpname") then

		playerNameVal = ply:getDarkRPVar("rpname")
		playerName:SetText(playerNameVal)
	end

	if playerJobVal ~= ply:getDarkRPVar( "job" ) then

		playerJobVal = ply:getDarkRPVar( "job" )
		playerJob:SetText( "Job: " .. playerJobVal )
	end

	if playerRankVal ~= ply:GetUserGroup() then

		playerRankVal = ply:GetUserGroup()
		playerRank:SetText( "Rank: " .. playerRankVal )
	end

	if playerMoneyVal ~= ply:getDarkRPVar( "money" ) then

		playerMoneyVal = ply:getDarkRPVar( "money" )
		playerMoney:SetText( "$" .. addComma( playerMoneyVal ))
	end

	if playerSalaryVal ~= ply:getDarkRPVar( "salary" ) then

		playerSalaryVal = ply:getDarkRPVar( "salary" )
		playerSalary:SetText( "Bits: " .. tostring( playerSalaryVal ))
	end

	if playerPropCountVal ~= ply:GetCount( "props" ) then

		playerPropCountVal = ply:GetCount( "props" )
		playerPropCount:SetText( "Props: " .. playerPropCountVal )
	end

	if playerWantedVal ~= ply:isWanted() then

		if ply:isWanted() then

			playerWantedVal = true
			playerWantedIcon:SetVisible(true)
		else
			playerWantedVal = false
			playerWantedIcon:SetVisible(false)
		end
	end

	if playerGunLicenseVal ~= ply:getDarkRPVar("HasGunlicense") then

		if ply:getDarkRPVar("HasGunlicense") then

			playerGunLicenseVal = true
			playerGunLicenseIcon:SetVisible(true)
		else
			playerGunLicenseVal = false
			playerGunLicenseIcon:SetVisible(false)
		end
	end

	if playerHealthVal ~= LocalPlayer():Health() then

		if LocalPlayer():Health() > 0 then

			playerHealthVal = LocalPlayer():Health()
			playerHealth:SetText(tostring(playerHealthVal))
		else

			playerHealthVal = 0
			playerHealth:SetText("0")
		end
	end
end

local function checkForCamera()

	if ( IsValid(ply) ) and ( ply:Health() > 0 ) then

		if ply:GetActiveWeapon():IsWeapon() and ply:GetActiveWeapon():GetClass() == "gmod_camera" and playerName:IsVisible() == true then

			avatar:SetVisible(false)

			playerName:SetVisible(false)
			playerJob:SetVisible(false)
			playerRank:SetVisible(false)
			playerMoney:SetVisible(false)
			playerSalary:SetVisible(false)
			playerHealth:SetVisible(false)
			playerPropCount:SetVisible(false)

			playerWantedIcon:SetVisible(false)
			playerGunLicenseIcon:SetVisible(false)

			fadmin:SetVisible(false)
			eqd:SetVisible(false)
			settings:SetVisible(false)
		elseif ply:GetActiveWeapon():IsWeapon() and ply:GetActiveWeapon():GetClass() ~= "gmod_camera" and playerName:IsVisible() == false then

			avatar:SetVisible(true)

			playerName:SetVisible(true)
			playerJob:SetVisible(true)
			playerRank:SetVisible(true)
			playerMoney:SetVisible(true)
			playerSalary:SetVisible(true)
			playerHealth:SetVisible(true)
			playerPropCount:SetVisible(true)

			playerWantedIcon:SetVisible(true)
			playerGunLicenseIcon:SetVisible(true)

			fadmin:SetVisible(true)
			eqd:SetVisible(true)
			settings:SetVisible(true)
		else

		end
	end
end
--[[---------------------------------------------------------------------------
HUD elements draw functions
---------------------------------------------------------------------------]]--
local healthBarPos =  105
local healthBarWidth = 260

local function drawHealthBar()

	local barCurrent =  math.ceil(260 * (LocalPlayer():Health() / 100)) --preforms operations to determine health bar length

	if barCurrent >= 260 then
		barCurrent = 260
	end

	if barCurrent == nil then
		barCurrent = 0
	end

	local barOffset = 260 - barCurrent

	healthBarPos = Lerp(5 * FrameTime(), healthBarPos, 105 + barOffset) --calculates change in health via lerp

	healthBarWidth = Lerp( 5 * FrameTime(), healthBarWidth,  barCurrent ) --calculates change in health via lerp

	draw.RoundedBox(0, math.ceil(uSF(healthBarPos) ),y - uSF(100), uSF(healthBarWidth) , uSF(30), Color(255, 0, 0, 120) )
end

local armorBarPos = 105
local armorBarWidth = 260

local function drawArmorBar()

	local armorBarCurrent =  math.ceil(260 * (LocalPlayer():Armor() / 150)) --preforms operations to determine health bar length

	if armorBarCurrent >= 260 then
		armorBarCurrent = 260
	end

	if armorBarCurrent == nil then
		armorBarCurrent = 0
	end

	local armorBarOffset = 260 - armorBarCurrent

	armorBarPos =  Lerp(5 * FrameTime(), armorBarPos, 105 + armorBarOffset) --calculates change in health via lerp

	armorBarWidth = Lerp( 5 * FrameTime(), armorBarWidth,  armorBarCurrent) --calculates change in health via lerp

	draw.RoundedBox(0, uSF(math.ceil(armorBarPos) ),y - uSF(75), uSF(armorBarWidth), uSF(5), Color(0, 0, 255, 120))
end

local energyBarWidth = 260

local function drawEnergyBar()

	local energyBarCurrent =  math.max(260 * (LocalPlayer():getDarkRPVar("Energy") / 100), 0) --preforms operations to determine health bar length

	energyBarWidth = Lerp(10 * FrameTime(), energyBarWidth, energyBarCurrent)

	draw.RoundedBox(0, uSF(115), y - uSF(55), uSF(energyBarWidth), uSF(30), Color(0, 255, 0, 120))
end

local function drawAvatar() --Grabs your steam profile picture for the HUD and sets its position and size
	avatar = vgui.Create("AvatarImage")
	avatar:SetSize(uSF(105), uSF(105) )
	avatar:SetPos( uSF(25), y - uSF(220) )
	avatar:SetPlayer(playerAvatarVal, 184)
end

local function drawPlayerName()

	playerName = vgui.Create("DLabel", self)
	playerName:SetFont("hudBigFont")
	playerName:SetPos( uSF(135),  y - uSF(220) )
	playerName:SetSize( 150, 25)
	playerName:SetText("N/A")
	playerName:SetBright(true)
end

local function drawPlayerJob()

	playerJob = vgui.Create("DLabel", self)
	playerJob:SetFont("hudSmallFont")
	playerJob:SetPos( uSF(135),  y - uSF(190) )
	playerJob:SetSize(150, 25)
	playerJob:SetText("N/A")
	playerJob:SetBright(true)
end

local function drawPlayerRank()

	playerRank = vgui.Create("DLabel", self)
	playerRank:SetFont("hudSmallFont")
	playerRank:SetPos( uSF(135),  y - uSF(160) )
	playerRank:SetSize( 150, 25)
	playerRank:SetText("N/A")
	playerRank:SetBright(true)
end

local function drawPlayerMoney()

	playerMoney = vgui.Create("DLabel", self)
	playerMoney:SetFont("hudSmallFont")
	playerMoney:SetPos( uSF(305), y - uSF(220) )
	playerMoney:SetSize( 95, 25)
	playerMoney:SetText("N/A")
	playerMoney:SetBright(true)
end

local function drawPlayerSalary()

	playerSalary = vgui.Create("DLabel", self)
	playerSalary:SetFont("hudSmallFont")
	playerSalary:SetPos( uSF(305), y - uSF(195) )
	playerSalary:SetSize( 95, 25)
	playerSalary:SetText("N/A")
	playerSalary:SetBright(true)
end

local function drawPlayerPropCount()

	playerPropCount = vgui.Create("DLabel", self)
	playerPropCount:SetFont("hudSmallFont")
	playerPropCount:SetPos( uSF(305), y - uSF(170) )
	playerPropCount:SetSize( 95, 25)
	playerPropCount:SetText("N/A")
	playerPropCount:SetBright(true)
end

local function drawPlayerHealth()

	playerHealth = vgui.Create("DLabel", self)
	playerHealth:SetFont("hudSmallFont")
	
	if ( y == 480 ) then
		playerHealth:SetPos( 1, y - 56 )
	elseif ( y == 664 ) then
		playerHealth:SetPos( 12, y - 67 )
	elseif ( y == 720 ) then
		playerHealth:SetPos( 15, y - 70 )
	elseif (y == 768 ) then
		playerHealth:SetPos( 18, y - 73 )
	elseif (y == 900 ) then
		playerHealth:SetPos( 26, y - 80 )
	elseif (y == 992 ) then
		playerHealth:SetPos( 32, y - 88 )
	elseif (y == 1080 ) then
		playerHealth:SetPos( 35, y - 90 )
	else
		playerHealth:SetPos( uSF(35), y - uSF(90) )
	end

	playerHealth:SetSize(55, 55)
	playerHealth:SetText("N/A")
	playerHealth:SetContentAlignment( 5 )
	playerHealth:SetBright(true)
end

local function drawPlayerWantedIcon() --draws the admin call button

	playerWantedIcon = vgui.Create("DImage")
	playerWantedIcon:SetPos( uSF(333), y - uSF(145) )
	playerWantedIcon:SetSize( 25, 25 )
	playerWantedIcon:SetImage( "materials/icons/wanted.png" )
end

local function drawPlayerGunLicenseIcon() --draws the admin call button

	playerGunLicenseIcon = vgui.Create("DImage")
	playerGunLicenseIcon:SetPos( uSF(303), y - uSF(145) )
	playerGunLicenseIcon:SetSize( 25, 25 )
	playerGunLicenseIcon:SetImage( "materials/icons/gunlicense.png" )
end

local function drawHealthIcon()

	surface.SetMaterial(Material("materials/icons/health.png"))
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect( uSF(30), y - uSF(95), uSF(65), uSF(65) )
end

local function drawArmorIcon()

	surface.SetMaterial(Material("materials/icons/armor.png"))
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect( uSF(70), y - uSF(53), uSF(25), uSF(25) )
end

local function drawEnergyIcon()

	surface.SetMaterial(Material("materials/icons/hunger.png"))
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect( uSF(385), y - uSF(95), uSF(65), uSF(65) )
end

local function drawSettingsPanel() --Draws the hud settings panel

	local settingsPanel = vgui.Create( "DFrame" )
	settingsPanel:SetPos( 475, y - 235 )
	settingsPanel:SetSize( 370, 225)
	settingsPanel:SetTitle( "" )
	settingsPanel:SetDraggable( false )
	settingsPanel:ShowCloseButton( true )
	settingsPanel:SetVisible( true )



	settingsPanel.Paint = function( self, w, h )
		draw.RoundedBox( 0, 0, 0, w, h, string.ToColor(colorZone1:GetString()))
		draw.RoundedBox( 0, 0, 0, w, 25, string.ToColor(colorZone3:GetString()))
	end

	settingsPanelTitle = vgui.Create("DLabel", settingsPanel)
	settingsPanelTitle:SetFont("hudSmallFont")
	settingsPanelTitle:SetPos(  5, 5)
	settingsPanelTitle:SetSize( 300, 15) --dimensions 65, 65
	settingsPanelTitle:SetText("Luna's GUI Settings")
	settingsPanelTitle:SetColor(Color(255, 255, 255))

	local ChosenColor = nil

	local colorPicker = vgui.Create( "DColorMixer", settingsPanel )
	colorPicker:SetSize( 250, 175 )
	colorPicker:SetPos( 10, 35)
	colorPicker:SetPalette( true )
	colorPicker:SetAlphaBar( true )
	colorPicker:SetWangs( true )
	colorPicker:SetColor( Color( 255, 255, 255 ) )

	local eqdHudCheckbox1 = vgui.Create( "DCheckBoxLabel", settingsPanel )
	eqdHudCheckbox1:SetPos( 270, 35 )
	eqdHudCheckbox1:SetFont("hudSmallFont")
	eqdHudCheckbox1:SetText( "Zone 1" )
	eqdHudCheckbox1:SetConVar( "eqdHudColorBox1" )
	eqdHudCheckbox1:SetValue( 0 )
	eqdHudCheckbox1:SizeToContents()

	local eqdHudCheckbox2 = vgui.Create( "DCheckBoxLabel", settingsPanel )
	eqdHudCheckbox2:SetPos( 270 , 65 )
	eqdHudCheckbox2:SetFont("hudSmallFont")
	eqdHudCheckbox2:SetText( "Zone 2" )
	eqdHudCheckbox2:SetConVar( "eqdHudColorBox2" )
	eqdHudCheckbox2:SetValue( 0 )
	eqdHudCheckbox2:SizeToContents()

	local eqdHudCheckbox3 = vgui.Create( "DCheckBoxLabel", settingsPanel )
	eqdHudCheckbox3:SetPos( 270, 95 )
	eqdHudCheckbox3:SetFont("hudSmallFont")
	eqdHudCheckbox3:SetText( "Zone 3" )
	eqdHudCheckbox3:SetConVar( "eqdHudColorBox3" )
	eqdHudCheckbox3:SetValue( 0 )
	eqdHudCheckbox3:SizeToContents()

	local eqdHudCheckboxReset = vgui.Create( "DCheckBoxLabel", settingsPanel )
	eqdHudCheckboxReset:SetPos( 270, 125 )
	eqdHudCheckboxReset:SetFont("hudSmallFont")
	eqdHudCheckboxReset:SetText( "Color Reset" )
	eqdHudCheckboxReset:SetConVar( "eqdHudColorBoxReset" )
	eqdHudCheckboxReset:SetValue( 0 )
	eqdHudCheckboxReset:SizeToContents()

	local confirmColor = vgui.Create( "DButton", settingsPanel )
	confirmColor:SetFont("hudSmallFont")
	confirmColor:SetText( "Confirm Color" )
	confirmColor:SetSize( 90, 40 )
	confirmColor:SetPos( 270, 170 )
	confirmColor.DoClick = function()
		ChosenColor = colorPicker:GetColor()

		if eqdHudColorBox1:GetBool() == true then

			colorZone1:SetString(string.FromColor(ChosenColor))
		end

		if eqdHudColorBox2:GetBool() == true then

			colorZone2:SetString(string.FromColor(ChosenColor))
		end

		if eqdHudColorBox3:GetBool() == true then

			colorZone3:SetString(string.FromColor(ChosenColor))
		end

		if eqdHudColorBoxReset:GetBool() == true then

			--NORMAL COLORS--
			colorZone1:SetString(string.FromColor(Color(100, 100, 100, 150))) --color for light grays
			colorZone2:SetString(string.FromColor(Color(060, 060, 060, 180))) --color for mid grays
			colorZone3:SetString(string.FromColor(Color(040, 040, 040, 200))) --color for dark grays
		end
	end
	settingsPanel:SetDeleteOnClose(true)
end

local function drawFadminButton() --draws the admin call button

	fadmin = vgui.Create( "DImageButton" )
	fadmin:SetPos( uSF(420), y - uSF(220) )
	fadmin:SetSize( uSF(35), uSF(35) )
	fadmin:SetImage("materials/icons/fadmin.png")

	fadmin.DoClick = function()
		LocalPlayer():ConCommand( "say /@" )
	end
end

local function drawEqdButton() --draws eqd button

	eqd = vgui.Create( "DImageButton" )
	eqd:SetPos( uSF(420), y - uSF(185) )
	eqd:SetSize( uSF(35), uSF(35) )
	eqd:SetImage("materials/icons/steam.png")

	eqd.DoClick = function()
		gui.OpenURL("http://steamcommunity.com/groups/celestialunderground")
	end
end

local function drawSettingsButton() --draws settings button

	settings = vgui.Create( "DImageButton" )
	settings:SetPos( uSF(420), y - uSF(150) )
	settings:SetSize( uSF(35), uSF(35) )
	settings:SetImage("materials/icons/settings.png")

	settings.DoClick = function()
		drawSettingsPanel()
	end
end

local function drawBaseHud()

	--base 
	draw.RoundedBox(0, uSF(10), y - uSF(235), uSF(460), uSF(225), string.ToColor(colorZone1:GetString())) --draws square that incompases the HUD

	--name/job base
	draw.RoundedBox(0, uSF(20), y - uSF(225), uSF(270), uSF(115), string.ToColor(colorZone2:GetString())) --draws a rectangle base
	draw.RoundedBox(0, uSF(20), y - uSF(225), uSF(270), uSF(35), string.ToColor(colorZone3:GetString())) --draws a rectangle base for user name

	--money base
	draw.RoundedBox(0, uSF(295), y - uSF(225), uSF(115), uSF(115), string.ToColor(colorZone2:GetString())) --draws a square base
	draw.RoundedBox(0, uSF(300), y - uSF(220), uSF(105), uSF(105), string.ToColor(colorZone3:GetString())) --draws the internal square

	--button base
	draw.RoundedBox(0, uSF(415), y - uSF(225), uSF(45), uSF(115), string.ToColor(colorZone2:GetString())) --draws rectangle base 

	--health base
	draw.RoundedBox(0, uSF(20), y - uSF(105), uSF(85), uSF(85), string.ToColor(colorZone2:GetString())) --draws base square
	draw.RoundedBox(0, uSF(25), y - uSF(100),  uSF(75), uSF(75), string.ToColor(colorZone3:GetString())) --draws internal square
	draw.RoundedBox(0, uSF(105), y - uSF(105), uSF(265), uSF(40), string.ToColor(colorZone2:GetString())) --draws base runner
	draw.RoundedBox(0, uSF(105), y - uSF(100), uSF(260), uSF(30), string.ToColor(colorZone3:GetString())) --draws internal runner

	--armour base
	draw.RoundedBox(0, uSF(375), y - uSF(105), uSF(85), uSF(85), string.ToColor(colorZone2:GetString())) --draws base square
	draw.RoundedBox(0, uSF(380), y - uSF(100), uSF(75), uSF(75), string.ToColor(colorZone3:GetString())) --draws internal square
	draw.RoundedBox(0, uSF(110), y - uSF(60), uSF(265), uSF(40), string.ToColor(colorZone2:GetString())) --draws base runner
	draw.RoundedBox(0, uSF(115), y - uSF(55), uSF(260), uSF(30), string.ToColor(colorZone3:GetString())) --draws internal runner
end

--[[---------------------------------------------------------------------------
paint HUD main function
---------------------------------------------------------------------------]]--

local function hudPaint()

	hook.Add("HUDShouldDraw", "HideDefaultDarkRPHud", function(name)  --removes the default darkrp hud items, had to be moved here due to some bullshit timing discrepancies
	if hideHUDElements[name] then return false end
	end)

	drawBaseHud()

	drawHealthIcon()
	drawArmorIcon()
	drawEnergyIcon()

	drawHealthBar()
	drawArmorBar()
	drawEnergyBar()

	checkPlayerInfo()

	checkForCamera()
end

hook.Add( "HUDShouldDraw", "hide hud", function( name ) --hides default gmod hud if visible
	if ( name == "CHudHealth" or name == "CHudBattery" ) then
		return false
	end

	-- Never return anything default here, it will break other addons using this hook.
end )

hook.Add("HUDPaint", "Draw_HUDPaint", hudPaint)

hook.Add("Initialize","Draw_drawAvatar", drawAvatar)
hook.Add("Initialize","Draw_drawFadminButton", drawFadminButton)
hook.Add("Initialize","Draw_drawEqdButton", drawEqdButton)
hook.Add("Initialize","Draw_drawSettingsButton", drawSettingsButton)

hook.Add("Initialize", "Draw_PlayerName", drawPlayerName)
hook.Add("Initialize", "Draw_PlayerJob", drawPlayerJob)
hook.Add("Initialize", "Draw_PlayerRank", drawPlayerRank)
hook.Add("Initialize", "Draw_PlayerMoney", drawPlayerMoney)
hook.Add("Initialize", "Draw_PlayerSalary", drawPlayerSalary)
hook.Add("Initialize", "Draw_PlayerPropCount", drawPlayerPropCount)
hook.Add("Initialize", "Draw_PlayerHealth", drawPlayerHealth)

hook.Add("Initialize", "Draw_PlayerGunLicenseIcon", drawPlayerGunLicenseIcon)
hook.Add("Initialize", "Draw_PlayerWantedIcon", drawPlayerWantedIcon)
