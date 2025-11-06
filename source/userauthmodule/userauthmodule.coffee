############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("userauthmodule")
#endregion

############################################################
export initialize = ->
    log "initialize"
    #Implement or Remove :-)
    return

############################################################
export userLoginAuth = (req, ctx) ->
    log "userLoginAuth"
    olog ctx
    return

export onLoginSuccess = (args) ->
    log "onLoginSuccess"
    olog args
    # here we are authenticated already :)!
    # TODO set AccessToken and answer 
    authCode = "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff"
    validUntil = Date.now()
    result = { authCode, validUntil }
    return result

############################################################
export passwordReset = (args) ->
    log "passwordReset"
    olog args
    
    return


export register = (args) ->
    log "register"
    olog args
    return


export getPasswordHash = (input) ->
    return "afafafafaffaffafafafafafaffaffafafafafafaffaffafafafafafaffaffaf"