local backdrop = {
	bgFile = [[Interface\Buttons\WHITE8x8]],
	edgeFile = [[Interface\Buttons\WHITE8x8]],
	tile = false,
	tileSize = 0,
	edgeSize = 1,
	insets = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0
	},
}

local gen_backdrop = function(frame, ...)
	if not frame.SetBackdrop then
		Mixin(frame, BackdropTemplateMixin)
	end
	frame:SetBackdrop(backdrop)
	frame:SetBackdropBorderColor(0, 0, 0, 1)
	if (...) then
		frame:SetBackdropColor(...)
	else
		frame:SetBackdropColor(.15, .15, .15, 1)
	end
end

local gen_statusbar = function(parent, w, h, fg_color, bg_color)
	local bar = CreateFrame("StatusBar", nil, parent, BackdropTemplateMixin and "BackdropTemplate")
	bar:SetSize(w, h)
	bar:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	bar:SetBackdrop(backdrop)
	bar:GetStatusBarTexture():SetDrawLayer("BORDER", -1);
	bar:SetBackdropBorderColor(0, 0, 0, 1)

	if fg_color then
		bar:SetStatusBarColor(unpack(fg_color))
	end

	if bg_color then
		bar:SetBackdropColor(unpack(bg_color))
	else
		bar:SetBackdropColor(.15, .15, .15, 1)
	end

	return bar
end

local w, h = 100, 50
local raidFrame = CreateFrame("Frame", "StutterRaidFrame", UIParent)
raidFrame:SetSize(w * 5, h * 4)
raidFrame:SetPoint("BOTTOMRIGHT", UIParent, "CENTER")

raidFrame:SetClampedToScreen(true)
raidFrame:SetMovable(true)
raidFrame:EnableMouse(true)

raidFrame:SetScript("OnMouseDown", function(self, click)
	if click == "LeftButton" and not self.isMoving then
		self:StartMoving()
		self.isMoving = true
	end
end)

raidFrame:SetScript("OnMouseUp", function(self, click)
	if click == "LeftButton" and self.isMoving then
		self:StopMovingOrSizing()
		self.isMoving = false
	end
end)

local players, playerCount = {}, 20
for i = 0, playerCount - 1 do
	local healthBar = CreateFrame("StatusBar", "StutterPlayerHealthBar"..i, raidFrame, BackdropTemplateMixin and "BackdropTemplate")
	healthBar:SetSize(w, h)
	healthBar:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	healthBar:SetBackdrop(backdrop)
	healthBar:GetStatusBarTexture():SetDrawLayer("BORDER", -1);
	healthBar:SetBackdropBorderColor(0, 0, 0, 1)
	healthBar:SetStatusBarColor(.25, .5, .25, 1)
	healthBar:SetBackdropColor(.15, .15, .15, 1)
	local row = math.floor(i / 5)
	local col = i % 5
	healthBar:SetPoint("TOPLEFT", col * w, row * -h)
	healthBar:SetMinMaxValues(0, 100)
	healthBar:SetValue(100)

	local playerName = healthBar:CreateFontString(nil, "OVERLAY")
	playerName:SetFont([[Fonts\FRIZQT__.TTF]], 15)
	playerName:SetPoint("TOPLEFT")
	playerName:SetText("player "..i)

	players[i] = healthBar
end


w, h = 200, 25
local nameplateFrame = CreateFrame("Frame", "StutterNameplateFrame", UIParent)
nameplateFrame:SetSize(w, h * 15)
nameplateFrame:SetPoint("BOTTOMLEFT", UIParent, "CENTER")

nameplateFrame:SetClampedToScreen(true)
nameplateFrame:SetMovable(true)
nameplateFrame:EnableMouse(true)

nameplateFrame:SetScript("OnMouseDown", function(self, click)
	if click == "LeftButton" and not self.isMoving then
		self:StartMoving()
		self.isMoving = true
	end
end)

nameplateFrame:SetScript("OnMouseUp", function(self, click)
	if click == "LeftButton" and self.isMoving then
		self:StopMovingOrSizing()
		self.isMoving = false
	end
end)

local enemies, enemyCount = {}, 15
for i = 0, enemyCount - 1 do
	local healthBar = CreateFrame("StatusBar", "StutterEnemyNameplate"..i, nameplateFrame, BackdropTemplateMixin and "BackdropTemplate")
	healthBar:SetSize(w, h)
	healthBar:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	healthBar:SetBackdrop(backdrop)
	healthBar:GetStatusBarTexture():SetDrawLayer("BORDER", -1);
	healthBar:SetBackdropBorderColor(0, 0, 0, 1)
	healthBar:SetStatusBarColor(.5, .25, .25, 1)
	healthBar:SetBackdropColor(.15, .15, .15, 1)
	healthBar:SetPoint("TOPRIGHT", 0, h * -i)
	healthBar:SetMinMaxValues(0, 100)
	healthBar:SetValue(100)

	local castBar = CreateFrame("StatusBar", "StutterEnemyNameplate"..i.."Cast", nameplateFrame, BackdropTemplateMixin and "BackdropTemplate")
	castBar:SetSize(w, h)
	castBar:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	castBar:SetBackdrop(backdrop)
	castBar:GetStatusBarTexture():SetDrawLayer("BORDER", -1);
	castBar:SetBackdropBorderColor(0, 0, 0, 1)
	castBar:SetStatusBarColor(.5, .5, .25, 1)
	castBar:SetBackdropColor(.15, .15, .15, 1)
	castBar:SetPoint("TOPLEFT", healthBar, "TOPRIGHT")
	castBar:SetMinMaxValues(0, 100)
	castBar:SetValue(0)
	castBar.casting = 0
	healthBar.cast = castBar

	local castName = castBar:CreateFontString(nil, "OVERLAY")
	castName:SetFont([[Fonts\FRIZQT__.TTF]], 15)
	castName:SetPoint("TOPLEFT")
	castName:SetText("cast "..i)

	local enemyName = healthBar:CreateFontString(nil, "OVERLAY")
	enemyName:SetFont([[Fonts\FRIZQT__.TTF]], 15)
	enemyName:SetPoint("TOPLEFT")
	enemyName:SetText("enemy "..i)

	enemies[i] = healthBar
end

w, h = 300, 25
local damageMeter = CreateFrame("Frame", "StutterDamageMeter", UIParent)
damageMeter:SetSize(w, h * 20)
damageMeter:SetPoint("TOPRIGHT", UIParent, "CENTER")

damageMeter:SetClampedToScreen(true)
damageMeter:SetMovable(true)
damageMeter:EnableMouse(true)

damageMeter:SetScript("OnMouseDown", function(self, click)
	if click == "LeftButton" and not self.isMoving then
		self:StartMoving()
		self.isMoving = true
	end
end)

damageMeter:SetScript("OnMouseUp", function(self, click)
	if click == "LeftButton" and self.isMoving then
		self:StopMovingOrSizing()
		self.isMoving = false
	end
end)

local bars = {}
for i = 0, playerCount - 1 do
	local damageBar = CreateFrame("StatusBar", "StutterPlayerDamageBar"..i, damageMeter, BackdropTemplateMixin and "BackdropTemplate")
	damageBar:SetSize(w, h)
	damageBar:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	damageBar:SetBackdrop(backdrop)
	damageBar:GetStatusBarTexture():SetDrawLayer("BORDER", -1);
	damageBar:SetBackdropBorderColor(0, 0, 0, 1)
	damageBar:SetStatusBarColor(.5, .5, .5, 1)
	damageBar:SetBackdropColor(.15, .15, .15, 1)
	damageBar:SetPoint("TOPLEFT", 0, i * -h)
	damageBar:SetMinMaxValues(0, 100)
	damageBar:SetValue(100 - i * 5)

	local playerName = damageBar:CreateFontString(nil, "OVERLAY")
	playerName:SetFont([[Fonts\FRIZQT__.TTF]], 15)
	playerName:SetPoint("TOPLEFT")
	playerName:SetText("player "..i)

	local damageLabel = damageBar:CreateFontString(nil, "OVERLAY")
	damageLabel:SetFont([[Fonts\FRIZQT__.TTF]], 15)
	damageLabel:SetPoint("TOPRIGHT")
	damageLabel:SetText(0)
	damageBar.label = damageLabel

	bars[i] = damageBar
	damageBar.amount = 0
end

local stutterer = CreateFrame("Frame")
stutterer.level = 0

local stutter = function()
	if stutterer.level then
		local count = math.floor(math.random(10)) * stutterer.level
		for i=1, count do
			local type = math.floor(math.random(10000))
			if type < 1500 then
				local playerId = math.floor(math.random(playerCount) - 1)
				local player = players[playerId]
				local amount = math.random(math.floor(101 - player:GetValue())) / stutterer.level
				player:SetValue(player:GetValue() + amount)
			elseif type < 9000 then
				local playerId = math.floor(math.random(playerCount) - 1)
				local player = players[playerId]
				local amount = math.random(10) / stutterer.level
				player:SetValue(player:GetValue() - amount)
			elseif type < 9001 then
				local enemyId = math.floor(math.random(enemyCount) - 1)
				local enemy = enemies[enemyId]
				if enemy.cast.casting == 0 then
					enemy.cast.casting = GetTime()
					enemy.cast:SetScript("OnUpdate", function(castBar)
						castBar:SetValue((GetTime() - castBar.casting) / 2 * 100)
						if castBar:GetValue() == 100 then
							castBar:SetValue(0)
							castBar:SetScript("OnUpdate", nil)
							castBar.casting = 0
						end
					end)
				end
			else
				local enemyId = math.floor(math.random(enemyCount) - 1)
				local enemy = enemies[enemyId]
				local amount = math.random(10) / stutterer.level
				enemy:SetValue(enemy:GetValue() - amount)
				if enemy:GetValue() == 0 then
					enemy:SetValue(100)
				end
				local playerId = math.floor(math.random(playerCount) - 1)
				local damageBar = bars[playerId]
				damageBar.amount = damageBar.amount + amount
				damageBar.label:SetText(damageBar.amount)
			end
		end
		local maxDamage = 0
		for id, bar in pairs(bars) do
			if bar.amount > maxDamage then
				maxDamage = bar.amount
			end
		end
		for id, bar in pairs(bars) do
			bar:SetValue(bar.amount and (bar.amount / maxDamage * 100) or 0)
		end
	end
end

SlashCmdList["STUTTER"] = function(arg)
	if arg == "" then
		if stutterer.level then
			stutterer:SetScript("OnUpdate", nil)
		else
			print("provide a level: \"/stutter 5\"")
		end
		return
	else
		local level = tonumber(arg)
		stutterer.level = level
		if level == 0 then
			stutterer:SetScript("OnUpdate", nil)
		else
			stutterer:SetScript("OnUpdate", stutter)
		end
	end
end

SLASH_STUTTER1 = "/stutter"

local helpFrame = CreateFrame("Frame", "StutterHelpFrame", UIParent)
helpFrame:SetSize(400, 200)
helpFrame:SetPoint("TOPRIGHT", UIParent, "CENTER")
gen_backdrop(helpFrame)

helpFrame:SetClampedToScreen(true)
helpFrame:SetMovable(true)
helpFrame:EnableMouse(true)

helpFrame:SetScript("OnMouseDown", function(self, click)
	if click == "LeftButton" and not self.isMoving then
		self:StartMoving()
		self.isMoving = true
	end
end)

helpFrame:SetScript("OnMouseUp", function(self, click)
	if click == "LeftButton" and self.isMoving then
		self:StopMovingOrSizing()
		self.isMoving = false
	end
end)

local helpLabel = helpFrame:CreateFontString(nil, "OVERLAY")
helpLabel:SetFont([[Fonts\FRIZQT__.TTF]], 15)
helpLabel:SetAllPoints()
local text = "(you can drag these frames)\n"
text = text.."to start a stress test, use \"/stutter [level]\" to start a test or update the current one\n"
text = text.."\"level\" is a stress level, try multiples like 100, 1000, 10000, etc. then fine-tune for a significant enough performance hit that is still playable\n"
text = text.."toggle off with \"/stutter\" or \"/stutter 0\""
helpLabel:SetText(text)
