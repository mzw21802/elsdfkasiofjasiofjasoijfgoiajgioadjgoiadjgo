-- this is the first file executed when the application starts
-- we have to load the first modules form here
-- setup logger
PROTOCOL_VERSION = 772
ENABLE_TERMINAL = true
g_app.setName("ElveraOnline")

-- add modules directory to the search path
if not g_resources.addSearchPath(g_resources.getWorkDir() .. "libs", true) then
  g_logger.fatal("Unable to add data directory to the search path.")
end

if not g_resources.fileExists('tibia.dat') then
  g_logger.fatal('Cannot find the ".dat" file (Error Code 1)')
end

if not g_sprites.loadSpr('tibia.spr') then
  g_logger.fatal('Cannot find the ".spr" file (Error Code 2)')
end

-- setup directory for saving configurations
if not g_resources.addSearchPath(g_resources.getWorkDir() .. "config", true) then
   g_resources.setWriteDir(g_resources.getWorkDir())
   g_resources.makeDir("config")
end

g_resources.setWriteDir(g_resources.getWorkDir() .. "config")

-- search all packages
g_resources.searchAndAddPackages('/', '.otpkg', true)

-- load settings
g_configs.loadSettings("/config.otml")

g_modules.discoverModules()

-- libraries modules 0-99
g_modules.autoLoadModules(99)
g_modules.ensureModuleLoaded("corelib")
g_modules.ensureModuleLoaded("gamelib")

-- client modules 100-499
g_modules.autoLoadModules(499)
g_modules.ensureModuleLoaded("client")

-- game modules 500-999
g_modules.autoLoadModules(999)
g_modules.ensureModuleLoaded("game_interface")

-- mods 1000-9999
g_modules.autoLoadModules(9999)