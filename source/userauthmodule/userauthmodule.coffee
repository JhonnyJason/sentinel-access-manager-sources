############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("userauthmodule")
#endregion


############################################################
import { sha256 } from "secret-manager-crypto-utils"

############################################################
verifyCorrectPassword = (email, pwdSH) ->
    pwdSHH = await sha256(pwdSH)
    ## TODO
    return pwdSHH

############################################################
export login = (args) ->
    log "login"
    olog args
    err = await verifyCorrectPassword(args.email, args.passwordSH)
    if err then return "Incorrect Credentials!"


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