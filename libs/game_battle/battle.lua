battleWindow = nil
battleButton = nil
battlePanel = nil
lastBattleButtonSwitched = nil
battleButtonsByCreaturesList = {}

mouseWidget = nil

function init()

  g_ui.importStyle('battlebutton')
  battleWindow = g_ui.loadUI('battle', modules.game_interface.getRightPanel())
  g_keyboard.bindKeyDown('Ctrl+B', bindedToggle)

  -- this disables scrollbar auto hiding
  local scrollbar = battleWindow:getChildById('miniwindowScrollBar')
  scrollbar:mergeStyle({ ['$!on'] = { }})

  battlePanel = battleWindow:recursiveGetChildById('battlePanel')

  mouseWidget = g_ui.createWidget('UIButton')
  mouseWidget:setVisible(false)
  mouseWidget:setFocusable(false)
  mouseWidget.cancelNextRelease = false

  battleWindow:setContentMinimumHeight(60)

  connect(Creature, {
    onSkullChange = updateCreatureSkull,
    onEmblemChange = updateCreatureEmblem,
    onOutfitChange = onCreatureOutfitChange,
    onHealthPercentChange = onCreatureHealthPercentChange,
    onPositionChange = onCreaturePositionChange,
    onAppear = onCreatureAppear,
    onDisappear = onCreatureDisappear
  })

  connect(LocalPlayer, {
    onPositionChange = onCreaturePositionChange
  })

  connect(g_game, {
    onGameStart = refresh,
    onAttackingCreatureChange = onAttack,
    onFollowingCreatureChange = onFollow,
    onGameEnd = removeAllCreatures
  })

  refresh()
  checkCreatures()
  battleWindow:setup()
  battleWindow:close()
end

function terminate()
  g_keyboard.unbindKeyDown('Ctrl+B')
  battleButtonsByCreaturesList = {}
  battleWindow:destroy()
  mouseWidget:destroy()

  disconnect(Creature, {
    onSkullChange = updateCreatureSkull,
    onEmblemChange = updateCreatureEmblem,
    onOutfitChange = onCreatureOutfitChange,
    onHealthPercentChange = onCreatureHealthPercentChange,
    onPositionChange = onCreaturePositionChange,
    onAppear = onCreatureAppear,
    onDisappear = onCreatureDisappear
  })

  disconnect(LocalPlayer, {
    onPositionChange = onCreaturePositionChange
  })

  disconnect(g_game, {
    onAttackingCreatureChange = onAttack,
    onFollowingCreatureChange = onFollow,
    onGameEnd = removeAllCreatures
  })
end

function doCreatureFitFilters(creature)
  local localPlayer = g_game.getLocalPlayer()
  if creature == localPlayer then
    return false
  end

  local pos = creature:getPosition()
  if not pos then return false end

  if pos.z ~= localPlayer:getPosition().z or not creature:canBeSeen() then return false end
  
  return true
end

function toggle()
  if battleWindow:isVisible() then
     if not modules.game_playerbars.battleButton:isChecked() then
        battleWindow:close()
     end
  else
     if modules.game_playerbars.battleButton:isChecked() then
        battleWindow:open()
     end
  end
end

function bindedToggle()
  if battleWindow:isVisible() then
     if modules.game_playerbars.battleButton:isChecked() then
        modules.game_playerbars.battleButton:setChecked(false)
        battleWindow:close()
     end
  else
     if not modules.game_playerbars.battleButton:isChecked() then
        modules.game_playerbars.battleButton:setChecked(1)
        battleWindow:open()
     end
  end
end

function onMiniWindowClose()
   modules.game_playerbars.battleButton:setChecked(false)
end

function getSortType()
  local settings = g_settings.getNode('BattleList')
  if not settings then
    return 'name'
  end
  return settings['sortType']
end

function setSortType(state)
  settings = {}
  settings['sortType'] = state
  g_settings.mergeNode('BattleList', settings)

  checkCreatures()
end

function getSortOrder()
  local settings = g_settings.getNode('BattleList')
  if not settings then
    return 'asc'
  end
  return settings['sortOrder']
end

function setSortOrder(state)
  settings = {}
  settings['sortOrder'] = state
  g_settings.mergeNode('BattleList', settings)

  checkCreatures()
end

function onChangeSortType(comboBox, option)
  setSortType(option:lower())
end

function onChangeSortOrder(comboBox, option)
  -- Replace dot in option name
  setSortOrder(option:lower():gsub('[.]', ''))
end

function refresh()
  if battleWindow:isVisible() then
     if not modules.game_playerbars.battleButton:isChecked() then
        modules.game_playerbars.battleButton:setChecked(true)
     end
  end
end

function checkCreatures()
  removeAllCreatures()

  if not g_game.isOnline() then
    return
  end

  local player = g_game.getLocalPlayer()
  local spectators = g_map.getSpectators(player:getPosition(), false)
  for _, creature in ipairs(spectators) do
    if doCreatureFitFilters(creature) then
      addCreature(creature)
    end
  end
end

function onCreatureOutfitChange(creature, outfit, oldOutfit)
  if doCreatureFitFilters(creature) then
    addCreature(creature)
  else
    removeCreature(creature)
  end
end

function onCreatureHealthPercentChange(creature, health)
  local battleButton = battleButtonsByCreaturesList[creature:getId()]
  if battleButton then
    if getSortType() == 'health' then
      removeCreature(creature)
      addCreature(creature)
      return
    end
    battleButton:setLifeBarPercent(creature:getHealthPercent())
  end
end

local function getDistanceBetween(p1, p2)
    return math.max(math.abs(p1.x - p2.x), math.abs(p1.y - p2.y))
end

function onCreaturePositionChange(creature, newPos, oldPos)
  if creature:isLocalPlayer() then
    if oldPos and newPos and newPos.z ~= oldPos.z then
      checkCreatures()
    else
      for _, battleButton in pairs(battleButtonsByCreaturesList) do
        addCreature(battleButton.creature)
      end
    end
  else
    local has = hasCreature(creature)
    local fit = doCreatureFitFilters(creature)
    if has and not fit then
      removeCreature(creature)
    elseif fit then
      if has and getSortType() == 'distance' then
        removeCreature(creature)
      end
      addCreature(creature)
    end
  end
end

function onCreatureAppear(creature)
  if creature:isLocalPlayer() then
    addEvent(function()
      updateStaticSquare(creature)
    end)
  end
  addCreature(creature)
end

function onCreatureDisappear(creature)
  removeCreature(creature)
end

function hasCreature(creature)
  return battleButtonsByCreaturesList[creature:getId()] ~= nil
end

function addCreature(creature)

  local creatureId = creature:getId()
  local battleButton = battleButtonsByCreaturesList[creatureId]

  if creature == g_game.getLocalPlayer() then
     return
  end

  if not battleButton then
    battleButton = g_ui.createWidget('BattleButton')
    battleButton:setup(creature)

    battleButton.onHoverChange = onBattleButtonHoverChange
    battleButton.onMouseRelease = onBattleButtonMouseRelease

    battleButtonsByCreaturesList[creatureId] = battleButton

    if creature == g_game.getAttackingCreature() then
      onAttack(creature)
    end

    if creature == g_game.getFollowingCreature() then
      onFollow(creature)
    end

    local healthPercent = creature:getHealthPercent()
    local playerPosition = g_game.getLocalPlayer():getPosition()
    local distance = getDistanceBetween(playerPosition, creature:getPosition())

    local childCount = battlePanel:getChildCount()
    for i = 1, childCount do
      local child = battlePanel:getChildByIndex(i)
      local childName = child:getCreature():getName():lower()
      local equal = false
    end
	
    battlePanel:insertChild(childCount + 1, battleButton)

  else
    battleButton:setLifeBarPercent(creature:getHealthPercent())
  end

  local localPlayer = g_game.getLocalPlayer()
  battleButton:setVisible(localPlayer:hasSight(creature:getPosition()) and creature:canBeSeen())
end

function removeAllCreatures()
  for i, v in pairs(battleButtonsByCreaturesList) do
    removeCreature(v.creature)
  end
end

function removeCreature(creature)
  if hasCreature(creature) then
    local creatureId = creature:getId()
    if lastBattleButtonSwitched == battleButtonsByCreaturesList[creatureId] then
      lastBattleButtonSwitched = nil
    end
    battleButtonsByCreaturesList[creatureId].creature:hideStaticSquare()
    battleButtonsByCreaturesList[creatureId]:destroy()
    battleButtonsByCreaturesList[creatureId] = nil
  end
end

function onBattleButtonMouseRelease(self, mousePosition, mouseButton)
  if mouseWidget.cancelNextRelease then
    mouseWidget.cancelNextRelease = false
    return false
  end
  if ((g_mouse.isPressed(MouseLeftButton) and mouseButton == MouseRightButton)
    or (g_mouse.isPressed(MouseRightButton) and mouseButton == MouseLeftButton)) then
    mouseWidget.cancelNextRelease = true
    g_game.look(self.creature)
    return true
  elseif mouseButton == MouseLeftButton and g_keyboard.isShiftPressed() then
    g_game.look(self.creature)
    return true
  elseif mouseButton == MouseRightButton and not g_mouse.isPressed(MouseLeftButton) then
    modules.game_interface.createThingMenu(mousePosition, nil, nil, self.creature)
    return true
  elseif mouseButton == MouseLeftButton and not g_mouse.isPressed(MouseRightButton) then
    if self.isTarget then
      g_game.cancelAttack()
    else
      g_game.attack(self.creature)
    end
    return true
  end
  return false
end

function onBattleButtonHoverChange(widget, hovered)
  if widget.isBattleButton then
    widget.isHovered = hovered
    updateBattleButton(widget)
  end
end

function onAttack(creature)
  local battleButton = creature and battleButtonsByCreaturesList[creature:getId()] or lastBattleButtonSwitched
  if battleButton then
    battleButton.isTarget = creature and true or false
    updateBattleButton(battleButton)
  end
end

function onFollow(creature)
  local battleButton = creature and battleButtonsByCreaturesList[creature:getId()] or lastBattleButtonSwitched
  if battleButton then
    battleButton.isFollowed = creature and true or false
    updateBattleButton(battleButton)
  end
end

function updateStaticSquare(creature)
  for _, battleButton in pairs(battleButtonsByCreaturesList) do
    if battleButton.isTarget or battleButton.isFollowed then
      battleButton:update()
    end
  end
end

function updateCreatureSkull(creature, skullId)
  local battleButton = battleButtonsByCreaturesList[creature:getId()]
  if battleButton then
    battleButton:updateSkull(skullId)
  end
end

function updateCreatureEmblem(creature, emblemId)
  local battleButton = battleButtonsByCreaturesList[creature:getId()]
  if battleButton then
    battleButton:updateSkull(emblemId)
  end
end

function updateBattleButton(battleButton)
  battleButton:update()
  if battleButton.isTarget or battleButton.isFollowed then
    -- set new last battle button switched
    if lastBattleButtonSwitched and lastBattleButtonSwitched ~= battleButton then
      lastBattleButtonSwitched.isTarget = false
      lastBattleButtonSwitched.isFollowed = false
      updateBattleButton(lastBattleButtonSwitched)
    end
    lastBattleButtonSwitched = battleButton
  end
end
