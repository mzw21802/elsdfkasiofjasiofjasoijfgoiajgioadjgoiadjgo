healthInfoWindow = nil
healthBar = nil
healthLabel = nil
manaLabel = nil
manaBar = nil
experienceBar = nil
healthTooltip = 'Your character health is %d out of %d.'
manaTooltip = 'Your character mana is %d out of %d.'
experienceTooltip = 'You have %d%% to advance to level %d.'

function init()
  connect(LocalPlayer, { onHealthChange = onHealthChange,
                         onLevelChange = onLevelChange,
                         onManaChange = onManaChange })

  connect(g_game, { onGameEnd = offline })

  healthInfoWindow = g_ui.loadUI('healthinfo', modules.game_interface.getRightPanel())
  healthInfoWindow:disableResize()
  healthBar = healthInfoWindow:recursiveGetChildById('healthBar')
  manaBar = healthInfoWindow:recursiveGetChildById('manaBar')
  healthLabel = healthInfoWindow:recursiveGetChildById('healthLabel')
  manaLabel = healthInfoWindow:recursiveGetChildById('manaLabel')
  experienceBar = healthInfoWindow:recursiveGetChildById('experienceBar')
  expLabel = healthInfoWindow:recursiveGetChildById('expLabel')
  
  healthInfoWindow:getChildById('contentsPanel'):setMarginTop(5)
  
  if g_game.isOnline() then
    local localPlayer = g_game.getLocalPlayer()
    onHealthChange(localPlayer, localPlayer:getHealth(), localPlayer:getMaxHealth())
    onManaChange(localPlayer, localPlayer:getMana(), localPlayer:getMaxMana())
	onLevelChange(localPlayer, localPlayer:getLevel(), localPlayer:getLevelPercent())
  end

  healthInfoWindow:setup()
end

function terminate()
  disconnect(LocalPlayer, { onHealthChange = onHealthChange,
                            onLevelChange = onLevelChange,
                            onManaChange = onManaChange })

  disconnect(g_game, {
    onGameEnd = offline
  })

  healthInfoWindow:destroy()
end

function onHealthChange(localPlayer, health, maxHealth)
  healthLabel:setText(""..health.. "")
  healthBar:setTooltip(tr(healthTooltip, health, maxHealth))
  healthBar:setValue(health, 0, maxHealth)
end

function onManaChange(localPlayer, mana, maxMana)
  manaLabel:setText(""..mana.. "")
  manaBar:setTooltip(tr(manaTooltip, mana, maxMana))
  manaBar:setValue(mana, 0, maxMana)
end

function onLevelChange(localPlayer, value, percent)
  expLabel:setText(percent .. '%')
  experienceBar:setTooltip(tr(experienceTooltip, percent, value+1))
  experienceBar:setPercent(percent)
end

function setHealthTooltip(tooltip)
  healthTooltip = tooltip
  local localPlayer = g_game.getLocalPlayer()
  if localPlayer then
    healthBar:setTooltip(tr(healthTooltip, localPlayer:getHealth(), localPlayer:getMaxHealth()))
  end
end

function setManaTooltip(tooltip)
  manaTooltip = tooltip
  local localPlayer = g_game.getLocalPlayer()
  if localPlayer then
    manaBar:setTooltip(tr(manaTooltip, localPlayer:getMana(), localPlayer:getMaxMana()))
  end
end

function setExperienceTooltip(tooltip)
  experienceTooltip = tooltip

  local localPlayer = g_game.getLocalPlayer()
  if localPlayer then
    experienceBar:setTooltip(tr(experienceTooltip, localPlayer:getLevelPercent(), localPlayer:getLevel()+1))
  end
end

function onMiniWindowClose()
  healthInfoWindow:open()
end
