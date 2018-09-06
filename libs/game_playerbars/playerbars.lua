playerBarsWindow = nil
skillsButton = nil
battleButton = nil
vipButton = nil
minimapButton = nil

function init()

connect(g_game, {
    onGameStart = online,
    onGameEnd = offline
})

  playerBarsWindow = g_ui.loadUI('playerbars', modules.game_interface.getRightPanel())
  playerBarsWindow:disableResize()

  skillsButton = playerBarsWindow:recursiveGetChildById('SkillsButton')
  battleButton = playerBarsWindow:recursiveGetChildById('BattleButton')
  vipButton = playerBarsWindow:recursiveGetChildById('VipButton')
  minimapButton = playerBarsWindow:recursiveGetChildById('MiniMapButton')
  
  playerBarsWindow:getChildById('contentsPanel'):setMarginTop(3)
  
  playerBarsWindow:open()
  playerBarsWindow:setup()

end

function terminate()

disconnect(g_game, {
    onGameStart = online,
    onGameEnd = offline
})

  playerBarsWindow:destroy()
end

function offline()
  local lastPlayerBars = g_settings.getNode('LastPlayerBars')
  if not lastPlayerBars then
    lastPlayerBars = {}
  end

  local player = g_game.getLocalPlayer()
  if player then
    local char = g_game.getCharacterName()

    lastPlayerBars[char] = {
      checkSkill = getCheckedButtons(skillsButton),
      checkBattle = getCheckedButtons(battleButton),
      checkVip = getCheckedButtons(vipButton),
	  checkMiniMap = getCheckedButtons(minimapButton),
    }
    g_settings.setNode('LastPlayerBars', lastPlayerBars)
  end
end

function online()
  local player = g_game.getLocalPlayer()
  if player then
    local char = g_game.getCharacterName()
    local lastPlayerBars = g_settings.getNode('LastPlayerBars')
    if not table.empty(lastPlayerBars) then
      if lastPlayerBars[char] then

         skillsButton:setChecked(lastPlayerBars[char].checkSkill)
         battleButton:setChecked(lastPlayerBars[char].checkBattle)
         vipButton:setChecked(lastPlayerBars[char].checkVip)
		 minimapButton:setChecked(lastPlayerBars[char].checkMiniMap)

      end
    end
  end
end

function getCheckedButtons(button)
 if button:isChecked() then
   return 1
 else
   return nil
 end
end

function onMiniWindowClose()
  playerBarsWindow:open()
end
