############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("scimodule")
#endregion

############################################################
#region modules from the Environment
import { sciStartServer } from "./scicoremodule.js"

############################################################
## just parse our interfaces
import "./samplesci.js"
import "./adminsci.js"
import "./usersci.js"

#endregion

############################################################
export prepareAndExpose = ->
    log "prepareAndExpose"
    listenOn = "systemd"
    options = { listenOn }
    try await sciStartServer(options)
    catch err then console.error(err.message)
    return
