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

import * as userData from "./userdatamodule.js"

############################################################
cachedData.initialize(cfg.persistentStateOptions)

############################################################
export serviceStartup = ->
    log "serviceStartup"
    # other startup moves
    sci.prepareAndExpose()
    # userId = "1"
    # data = userData.getUserData(userId)
    # olog data
    # data = { email: "sample-mail@dotv.ee", pwdSHH:"asdf" }
    # await userData.setUserData(userId, data)
    return
