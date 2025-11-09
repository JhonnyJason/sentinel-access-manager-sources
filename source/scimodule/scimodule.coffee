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
    options = { }
    sciStartServer(options)
    return
