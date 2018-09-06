filename =  nil
loaded = false

function init()
  connect(g_game, { onClientVersionChange = load })
end

function terminate()
  disconnect(g_game, { onClientVersionChange = load })
end

function setFileName(name)
  filename = name
end

function isLoaded()
  return loaded
end

function load()
  local version = g_game.getClientVersion()

  local datPath, sprPath
  if filename then
    datPath = resolvepath('/things/' .. filename)
    sprPath = resolvepath('/things/' .. filename)
  else
    datPath = resolvepath('/things/' .. version .. '/Tibia/')
    sprPath = resolvepath('/things/' .. version .. '/Tibia/')
  end

  g_things.loadDat('Tibia.dat')
  
  local errorMessage = ''
  loaded = (errorMessage:len() == 0)

  if errorMessage:len() > 0 then
    local messageBox = displayErrorBox(tr('Error'), errorMessage)
    addEvent(function() messageBox:raise() messageBox:focus() end)

    disconnect(g_game, { onClientVersionChange = load })
    g_game.setClientVersion(0)
    g_game.setProtocolVersion(0)
    connect(g_game, { onClientVersionChange = load })
  end
end
