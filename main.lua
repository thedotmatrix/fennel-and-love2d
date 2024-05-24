local instal = {correlate=true, moduleName="lib.fennel"}
local fennel = require("lib.fennel").install(instal)
table.insert(package.loaders, 1, fennel.searcher)
table.insert(fennel["macro-searchers"], fennel.searcher("_COMPILER"))
require("wrap")
