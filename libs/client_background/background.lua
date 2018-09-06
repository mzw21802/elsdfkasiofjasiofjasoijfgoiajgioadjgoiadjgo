-- private variables
local background
local infoWindow

local accesAccountLink = "http://elveraonline.com/register"
local websiteLink = "http://elveraonline.com"

local infoTexts = {
 [1] = "ElveraOnline Client",
 [2] = "Version 8.6",
 [3] = "Copyright (C) 2016-2017",
 [4] = "FluppiX GmbH",
 [5] = "All rights reserved.",
 [6] = "Official Website",
 [7] = "ElveraOnline.com",
}

-- public functions
function init()
  background = g_ui.displayUI('background')
  background:lower()

  infoWindow = background:getChildById('infoBox')
  infoWindow:hide()
  
  connect(g_game, { onGameStart = hide })
  connect(g_game, { onGameEnd = show })
  
  setClientInfo()
end

function terminate()
  disconnect(g_game, { onGameStart = hide })
  disconnect(g_game, { onGameEnd = show })

  infoWindow:destroy()
  background:destroy()
  Background = nil
end

function hide()
  background:hide()
end

function show()
  background:show()
end

function infoShow()
  if not infoWindow:isVisible() then
     infoWindow:setVisible(true)
  end
end

function infoHide()
  if infoWindow:isVisible() then
    infoWindow:setVisible(false)
  end
end

function accesAccount()
   g_platform.openUrl(accesAccountLink)
end

function openWebsite()
   g_platform.openUrl(websiteLink)
end

function setClientInfo()
  for label, text in pairs(infoTexts) do 
    local label = infoWindow:getChildById('infoLabel' .. label)
    label:setText(text)
  end
end
