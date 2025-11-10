############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("startupmodule")
#endregion

############################################################
import * as cachedData from "cached-persistentstate"

############################################################
import * as sci from "./scimodule.js"
import * as cfg from "./configmodule.js"

import { verifyAccess } from "./mailsendmodule.js"

############################################################
cachedData.initialize(cfg.persistentStateOptions)

############################################################
export serviceStartup = ->
    log "serviceStartup"
    # other startup moves
    await verifyAccess()
    sci.prepareAndExpose()
    return
