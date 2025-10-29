############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("authutilmodule")
#endregion

############################################################
import * as secUtl from "secret-manager-crypto-utils"

############################################################
export initialize = ->
    log "initialize"
    #Implement or Remove :-)
    return

############################################################
export getPasswordHash = (input) ->
    log "getPasswordHash"
    return await secUtl.sha256(input)