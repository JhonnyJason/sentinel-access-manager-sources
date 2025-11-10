############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("authutilmodule")
#endregion

############################################################
import * as secUtl from "secret-manager-crypto-utils"

############################################################
export getPasswordHash = (input) ->
    log "getPasswordHash"
    return await secUtl.sha256(input)

export verifyPassword = (pwdSH, pwdSSH) ->
    toCheckSHH = await secUtl.sha256(pwdSH)
    if pwdSHH == toCheckSHH then return
    else return "Incorrect Password!" 
