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

local movable = function(mover)
	mover:SetClampedToScreen(true)
	mover:SetMovable(true)
	mover:EnableMouse(true)

	mover:SetScript("OnMouseDown", function(self, click)
		if click == "LeftButton" and not self.isMoving then
			self:StartMoving()
			self.isMoving = true
		end
	end)

	mover:SetScript("OnMouseUp", function(self, click)
		if click == "LeftButton" and self.isMoving then
			self:StopMovingOrSizing()
			self.isMoving = false
		end
	end)
end

local unitCalls = {
	UnitIsPlayer,
	UnitInPartyIsAI,
	UnitIsConnected,
	UnitPlayerControlled,
	UnitIsTapDenied,
	UnitClass,
	UnitIsDead,
	UnitIsGhost,
	UnitClassification,
	UnitSex,
	UnitPowerType,
	UnitPowerMax,
	UnitPower,
	UnitName,
	UnitLevel,
	UnitIsGroupLeader
}

local w, h = 100, 50
local raidFrame = CreateFrame("Frame", "StutterRaidFrame", UIParent)
raidFrame:SetSize(w * 5, h * 5)
raidFrame:SetPoint("BOTTOMRIGHT", UIParent, "CENTER")
movable(raidFrame)
gen_backdrop(raidFrame)

local players, playerCount, playerHp = {}, 20, 100
for i = 0, playerCount - 1 do
	local healthBar = CreateFrame("StatusBar", "StutterPlayerHealthBar"..i, raidFrame, BackdropTemplateMixin and "BackdropTemplate")
	healthBar:SetSize(w, h)
	healthBar:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	healthBar:SetBackdrop(backdrop)
	healthBar:GetStatusBarTexture():SetDrawLayer("BORDER", -1);
	healthBar:SetBackdropBorderColor(0, 0, 0, 1)
	healthBar:SetStatusBarColor(.25, .5, .25, 1)
	healthBar:SetBackdropColor(.15, .15, .15, 1)
	local row = math.floor(i / 5) + 1
	local col = i % 5
	healthBar:SetPoint("TOPLEFT", col * w, row * -h)
	healthBar:SetMinMaxValues(0, playerHp)
	healthBar:SetValue(playerHp)

	local playerName = healthBar:CreateFontString(nil, "OVERLAY")
	playerName:SetFont([[Fonts\FRIZQT__.TTF]], 15)
	playerName:SetPoint("TOPLEFT")
	playerName:SetText("player "..i)

	healthBar.auras = {}
	for b = 1, 5 do
		local buff = CreateFrame("BUTTON", nil, healthBar, "AuraButtonArtTemplate")
		buff:SetSize(20, 20)
		buff:SetPoint("BOTTOMLEFT", (b - 1) * buff:GetWidth(), 0)
		buff.Icon:SetAllPoints()
		buff.DebuffBorder:SetAllPoints()
		buff.TempEnchantBorder:Hide()
		buff.Icon:SetColorTexture(math.random(), math.random(), math.random(), 1)
		healthBar.auras[b] = buff
	end

	healthBar.metrics = {}
	healthBar.metrics.damage = 0
	healthBar.metrics.damageTaken = 0
	healthBar.metrics.healing = 0
	healthBar.metrics.healingTaken = 0
	healthBar.metrics.damageTo = {}
	healthBar.metrics.damageFrom = {}
	healthBar.metrics.healingTo = {}
	healthBar.metrics.healingFrom = {}
	players[i] = healthBar
end


w, h = 200, 25
local nameplateFrame = CreateFrame("Frame", "StutterNameplateFrame", UIParent)
nameplateFrame:SetSize(w, h * 16)
nameplateFrame:SetPoint("BOTTOMLEFT", UIParent, "CENTER")
movable(nameplateFrame)
gen_backdrop(nameplateFrame)

local enemies, enemyCount, enemyHp = {}, 20, 100
for i = 0, enemyCount - 1 do
	local healthBar = CreateFrame("StatusBar", "StutterEnemyNameplate"..i, nameplateFrame, BackdropTemplateMixin and "BackdropTemplate")
	healthBar:SetSize(w, h)
	healthBar:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
	healthBar:SetBackdrop(backdrop)
	healthBar:GetStatusBarTexture():SetDrawLayer("BORDER", -1);
	healthBar:SetBackdropBorderColor(0, 0, 0, 1)
	healthBar:SetStatusBarColor(.5, .25, .25, 1)
	healthBar:SetBackdropColor(.15, .15, .15, 1)
	healthBar:SetPoint("TOPRIGHT", 0, h * -(i + 1))
	healthBar:SetMinMaxValues(0, enemyHp)
	healthBar:SetValue(enemyHp)

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
	healthBar.cast = castBar

	local castName = castBar:CreateFontString(nil, "OVERLAY")
	castName:SetFont([[Fonts\FRIZQT__.TTF]], 15)
	castName:SetPoint("TOPLEFT")
	castName:SetText("cast "..i)

	local enemyName = healthBar:CreateFontString(nil, "OVERLAY")
	enemyName:SetFont([[Fonts\FRIZQT__.TTF]], 15)
	enemyName:SetPoint("TOPLEFT")
	enemyName:SetText("enemy "..i)

	healthBar.auras = {}
	for b = 1, 5 do
		local buff = CreateFrame("BUTTON", nil, healthBar, "AuraButtonArtTemplate")
		buff:SetSize(20, 20)
		buff:SetPoint("BOTTOMRIGHT", -(b - 1) * buff:GetWidth(), 0)
		buff.Icon:SetColorTexture(math.random(), math.random(), math.random(), 1)
		buff.Icon:SetAllPoints()
		buff.TempEnchantBorder:Hide()
		buff.DebuffBorder:SetAllPoints()
		healthBar.auras[b] = buff
	end

	healthBar.metrics = {}
	healthBar.metrics.damage = 0
	healthBar.metrics.damageTaken = 0
	healthBar.metrics.damageTo = {}
	healthBar.metrics.damageFrom = {}
	enemies[i] = healthBar
end

w, h = 300, 25
local damageMeter = CreateFrame("Frame", "StutterDamageMeter", UIParent)
damageMeter:SetSize(w, h * (playerCount + 1))
damageMeter:SetPoint("TOPLEFT", UIParent, "CENTER")
movable(damageMeter)
gen_backdrop(damageMeter)

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
	damageBar:SetPoint("TOPLEFT", 0, (i + 1) * -h)
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
	damageBar.player = players[i]
end


w, h = 50, 50
local actionButtons = CreateFrame("Frame", "StutterActionButtons", UIParent)
actionButtons:SetSize(w * 20, h * 6)
actionButtons:SetPoint("TOPRIGHT", UIParent, "CENTER")
movable(actionButtons)
gen_backdrop(actionButtons)

local actions = {}
for i = 0, 99 do
	local actionButton = CreateFrame("CheckButton", "StutterPlayerActionButton"..i, actionButtons, "ActionButtonTemplate")
	actionButton:SetSize(w, h)
	actionButton.icon:SetColorTexture(math.random(), math.random(), math.random(), 1)
	actionButton.Name:SetText(i)

	local row = math.floor(i / 20)
	local col = i % 20
	actionButton:SetPoint("BOTTOMLEFT", col * w, row * h)

	actions[i] = actionButton
end

local stutter = CreateFrame("Frame")
stutter.level = 0

local enemyHealthUpdate = function(id, value)
	local hp, maxHp = UnitHealth("player"), UnitHealthMax("player")
	local enemy = enemies[id]
	enemy:SetMinMaxValues(0, maxHp)
	enemy:SetValue(maxHp * value)
end

local enemyDamageEvent = function(playerId, enemyId, change)
	local player = players[playerId]
	local enemy = enemies[enemyId]

	enemy.metrics.damageTaken = enemy.metrics.damageTaken + change
	enemy.metrics.damageFrom[playerId] = change + (enemy.metrics.damageFrom[playerId] or 0) 
	player.metrics.damage = player.metrics.damage + change
	player.metrics.damageTo[enemyId] = change + (player.metrics.damageTo[enemyId] or 0)
end

local playerHealthUpdate = function(id, value)
	local hp, maxHp = UnitHealth("player"), UnitHealthMax("player")
	local player = players[id]
	player:SetMinMaxValues(0, maxHp)
	player:SetValue(maxHp * value)
end

local playerDamageEvent = function(playerId, enemyId, change)
	local player = players[playerId]
	local enemy = enemies[enemyId]
	
	enemy.metrics.damage = enemy.metrics.damage + change
	enemy.metrics.damageTo[playerId] = change + (enemy.metrics.damageTo[playerId] or 0)
	player.metrics.damageTaken = player.metrics.damageTaken + change
	player.metrics.damageFrom[enemyId] = change + (player.metrics.damageFrom[enemyId] or 0)
end

local playerHealEvent = function(playerTargetId, playerSourceId, change)
	local playerTarget = players[playerTargetId]
	local playerSource = players[playerSourceId]
	
	playerTarget.metrics.healingTaken = playerTarget.metrics.healingTaken + change
	playerTarget.metrics.healingFrom[playerSourceId] = change + (playerTarget.metrics.healingFrom[playerSourceId] or 0)
	playerSource.metrics.healing = playerSource.metrics.healing + change
	playerSource.metrics.healingTo[playerTargetId] = change + (playerSource.metrics.healingTo[playerTargetId] or 0)
end

local updateAuras = function(unit)
	local infos = {}
	AuraUtil.ForEachAura("player", "HELPFUL", 5, function(...)
		local _, texture, count, debuffType, duration, expirationTime, _, _, _, spellId, _, _, _, _, timeMod = ...
		local timeLeft = (expirationTime - GetTime())
		local hideUnlessExpanded = (duration == 0) or (expirationTime == 0) or ((timeLeft) > BUFF_DURATION_WARNING_TIME)

		local helpTipInfo = nil
		local index = #infos + 1
		infos[index] = {index = index, texture = texture, count = count, debuffType = debuffType, duration = duration,  expirationTime = expirationTime, timeMod = timeMod, hideUnlessExpanded = hideUnlessExpanded, auraType = "Buff", helpTipInfo = helpTipInfo}

		return #infos > 5
	end)

	if #infos > 0 then
		local i = math.random(5)
		for b = 1, 5 do
			i = i + 1
			if i > #infos then
				i = 1
			end
			local buff = unit.auras[b]
			local buttonInfo = infos[i]

			buff.auraType = buttonInfo.auraType

			if buff.auraType == "Buff" then
				buff.DebuffBorder:Hide()
				buff.TempEnchantBorder:Hide()
			elseif buff.auraType == "Debuff" or buff.auraType == "DeadlyDebuff" then
				local color = DebuffTypeColor["none"]
				buff.DebuffBorder:SetVertexColor(color.r, color.g, color.b)
				buff.DebuffBorder:Show()
				buff.TempEnchantBorder:Hide()
			elseif buff.auraType == "TempEnchant" then
				buff.DebuffBorder:Hide()
				buff.TempEnchantBorder:Show()
			end

			buff.buttonInfo = buttonInfo;
			buff.unit = "player";

			if buff.auraType == "TempEnchant" then
				buff.Icon:SetTexture(buff.buttonInfo.textureName)
				
				
				if buttonInfo.expirationTime and buttonInfo.expirationTime > 0 then
					buff.Duration:SetShown(true)
			
					local timeLeft = (buttonInfo.expirationTime - GetTime())
					if buttonInfo.timeMod and buttonInfo.timeMod > 0 then
						buff.timeMod = buttonInfo.timeMod
						timeLeft = timeLeft / buttonInfo.timeMod
					end
			
					if not buff.timeLeft then
						buff.timeLeft = timeLeft
						buff:SetScript("OnUpdate", buff.OnUpdate)
					else
						buff.timeLeft = timeLeft
					end
				else
					buff.Duration:Hide()
					buff:SetScript("OnUpdate", nil)
					buff.timeLeft = nil
				end

				if buttonInfo.count > 1 then
					buff.Count:SetText(buttonInfo.count)
					buff.Count:Show()
				else
					buff.Count:Hide()
				end

				return
			end

			if buttonInfo.expirationTime and buttonInfo.expirationTime > 0 then
				buff.Duration:SetShown(true)
		
				local timeLeft = (buttonInfo.expirationTime - GetTime())
				if buttonInfo.timeMod and buttonInfo.timeMod > 0 then
					buff.timeMod = buttonInfo.timeMod
					timeLeft = timeLeft / buttonInfo.timeMod
				end
		
				if not buff.timeLeft then
					buff.timeLeft = timeLeft
					buff:SetScript("OnUpdate", buff.OnUpdate)
				else
					buff.timeLeft = timeLeft
				end
			else
				buff.Duration:Hide()
				buff:SetScript("OnUpdate", nil)
				buff.timeLeft = nil
			end

			buff.Icon:SetTexture(buttonInfo.texture);

			if buttonInfo.count > 1 then
				buff.Count:SetText(buttonInfo.count);
				buff.Count:Show();
			else
				buff.Count:Hide();
			end
		end
	end
end

local stutterUpdate = function()

	if stutter.level then

		local enemyHealthUpdates = {}
		local enemyDamageEvents = {}

		-- do aoe dmg; hit every enemy with a random amount from a random player
		for i = 0, stutter.level do
			local playerId = math.floor(math.random(playerCount) - 1)
			local amount = math.random(enemyHp) / enemyHp
			local change = amount / stutter.level
			for enemyId in pairs(enemies) do
				enemyHealthUpdates[enemyId] = amount
				table.insert(enemyDamageEvents, {playerId, enemyId, change})
			end
		end

		-- do direct dmg; hit random enemy with a random amount from a random player
		for i = 0, stutter.level do
			local playerId = math.floor(math.random(playerCount) - 1)
			local enemyId = math.floor(math.random(enemyCount) - 1)
			local amount = math.random(enemyHp) / enemyHp
			local change = amount / stutter.level
			enemyHealthUpdates[enemyId] = amount
			table.insert(enemyDamageEvents, {playerId, enemyId, change})
		end

		local playerHealthUpdates = {}
		local playerDamageEvents = {}

		-- do raid dmg; hit every player with a random amount
		for i = 0, stutter.level do
			local enemyId = math.floor(math.random(enemyCount) - 1)
			local amount = math.random(playerHp) / playerHp
			local change = amount / stutter.level
			for playerId in pairs(players) do
				playerHealthUpdates[playerId] = amount
				table.insert(playerDamageEvents, {playerId, enemyId, change})
			end
		end

		-- do direct dmg; hit random player with a random amount
		for i = 0, stutter.level do
			local playerId = math.floor(math.random(playerCount) - 1)
			local enemyId = math.floor(math.random(enemyCount) - 1)
			local amount = math.random(playerHp) / playerHp
			local change = amount / stutter.level
			playerHealthUpdates[playerId] = amount
			table.insert(playerDamageEvents, {playerId, enemyId, change})
		end

		local playerHealEvents = {}

		-- do aoe heal; heal every player with a random amount
		for i = 0, stutter.level do
			local playerSourceId = math.floor(math.random(playerCount) - 1)
			local amount = math.random(playerHp) / playerHp
			local change = amount / stutter.level
			for playerTargetId in pairs(players) do
				playerHealthUpdates[playerTargetId] = amount
				table.insert(playerHealEvents, {playerTargetId, playerSourceId, change})
			end
		end

		-- do direct heal; heal random player with a random amount
		for i = 0, stutter.level do
			local playerSourceId = math.floor(math.random(playerCount) - 1)
			local playerTargetId = math.floor(math.random(playerCount) - 1)
			local amount = math.random(playerHp) / playerHp
			local change = amount / stutter.level
			playerHealthUpdates[playerTargetId] = amount
			table.insert(playerHealEvents, {playerTargetId, playerSourceId, change})
		end

		for id, amount in pairs(enemyHealthUpdates) do
			enemyHealthUpdate(id, amount)
		end

		for _, event in ipairs(enemyDamageEvents) do
			enemyDamageEvent(unpack(event))
		end

		for id, amount in pairs(playerHealthUpdates) do
			playerHealthUpdate(id, amount)
		end

		for _, event in ipairs(playerDamageEvents) do
			playerDamageEvent(unpack(event))
		end

		for _, event in ipairs(playerHealEvents) do
			playerHealEvent(unpack(event))
		end

		local maxDamage = 0
		for id, player in pairs(players) do
			local damage = player.metrics.damage
			if damage > maxDamage then
				maxDamage = damage
			end
		end
		if maxDamage > 0 then
			for id, bar in pairs(bars) do
				bar:SetValue(bar.player.metrics.damage / maxDamage * 100)
				bar.label:SetText(math.floor(bar.player.metrics.damage))
			end
		end

		for i = 0, stutter.level do
			for _, call in pairs(unitCalls) do
				call("player")
			end
		end

		for _, player in pairs(players) do
			updateAuras(player)
		end
		for _, enemy in pairs(enemies) do
			updateAuras(enemy)
		end
	end
end

local startUpdates = function()
	-- have every action button on a random cooldown
	for _, action in pairs(actions) do
		if not action.cooldown.ticking then
			action.cooldown.ticking = true
			action.cooldown:SetCooldown(GetTime(), math.random(5))
			action.cooldown:SetScript("OnCooldownDone", function(cooldown)
				if stutter.level > 0 then
					cooldown:SetCooldown(GetTime(), math.random(5))
				else
					cooldown.ticking = false
					cooldown:SetScript("OnCooldownDone", nil)
				end
			end)
		end
	end

	-- have every enemey nameplate randomly casting
	for _, enemy in pairs(enemies) do
		if not enemy.cast.casting then
			enemy.cast.casting = {}
			enemy.cast.casting.start = GetTime()
			enemy.cast.casting.duration = math.random(5)
			enemy.cast:SetScript("OnUpdate", function(cast)
				cast:SetValue((GetTime() - cast.casting.start) / cast.casting.duration * 100)
				if cast:GetValue() == 100 then
					cast:SetValue(0)
					if stutter.level > 0 then
						cast.casting.start = GetTime()
						cast.casting.duration = math.random(5)
					else
						cast:SetScript("OnUpdate", nil)
						cast.casting = nil
					end
				end
			end)
		end
	end
	stutter:SetScript("OnUpdate", stutterUpdate)
end

SlashCmdList["STUTTER"] = function(arg)
	if arg == "" then
		if stutter.level then
			stutter.level = 0
			print("stutter 0")
			stutter:SetScript("OnUpdate", nil)
		else
			print("provide a level: \"/stutter 5\"")
		end
		return
	else
		local level = math.floor(tonumber(arg))
		print("stutter "..level)
		stutter.level = level
		if level == 0 then
			stutter:SetScript("OnUpdate", nil)
		else
			startUpdates()
		end
	end
end

SLASH_STUTTER1 = "/stutter"

local helpFrame = CreateFrame("Frame", "StutterHelpFrame", UIParent)
helpFrame:SetSize(400, 200)
helpFrame:SetPoint("TOP")
gen_backdrop(helpFrame)
movable(helpFrame)

local helpLabel = helpFrame:CreateFontString(nil, "OVERLAY")
helpLabel:SetFont([[Fonts\FRIZQT__.TTF]], 15)
helpLabel:SetAllPoints()
local text = "(you can drag these frames)\n"
text = text.."to start a stress test, use \"/stutter [level]\" to start a test or update the current one\n"
text = text.."\"level\" is a stress level, try multiples like 1, 10, 100 etc. then fine-tune for a significant enough performance hit that is still playable\n"
text = text.."toggle off with \"/stutter\" or \"/stutter 0\""
helpLabel:SetText(text)
