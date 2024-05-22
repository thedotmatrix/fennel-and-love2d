local instal = {correlate=true, moduleName="lib.fennel"}
local fennel = require("lib.fennel").install(instal)
local search = function(env) 
  return function(module_name)
    local path = module_name:gsub("%.", "/") .. ".fnl"
    if love.filesystem.getInfo(path) then
      return function(...)
        local code = love.filesystem.read(path)
        return fennel.eval(code, {env=env}, ...)
      end, path
    end
  end
end
local make_love_searcher = function(env) return search(env) end
table.insert(package.loaders, make_love_searcher(_G))
table.insert(fennel["macro-searchers"], make_love_searcher("_COMPILER"))
search(_G)("main")()
