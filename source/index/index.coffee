import Modules from "./allmodules"

############################################################
global.allModules = Modules
import *  as cfg from "./configmodule.js"

############################################################
run = ->
    try
        promises = (m.initialize(cfg) for n,m of Modules when m.initialize?) 
        await Promise.all(promises)
        await Modules.startupmodule.serviceStartup()
    catch err then console.error(err)

############################################################
run()
