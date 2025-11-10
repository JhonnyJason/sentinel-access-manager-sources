############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("accountsmodule")
#endregion


############################################################
#region Modules from the Environment
import { makeForgetable } from "memory-decay"

############################################################
import * as auth from "./authutilmodule.js"
# import { sha256 } from "secret-manager-crypto-utils"

############################################################
import * as uData from "./userdatamodule.js"
import { 
    sendRegistrationMail, sendPasswordResetMail 
} from "./mailcreatormodule.js"

#endregion


############################################################
#region Local Variables
codesToAction = Object.create(null)
#endregion


############################################################
export initialized = () ->
    makeForgetable(codesToAction, 600_000) # ->10 minutes
    return

############################################################
verifyCorrectPassword = (email, pwdSH) ->
    user = uData.getUserByEmail(email)
    if !user? then return "User does not exist!"
    return auth.verifyPassword(pwdSH, user.passwordSHH)

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
export passwordReset = (email) ->
    log "passwordReset"
    log email
    user = uData.getUserByEmail(email)
    if !user? then return ## do nothing without user
    
    ## TODO create resetPasswordLink
    link = "https://dotv.ee/?code=f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5"
    sendPasswordResetMail(email, link)
    return


export register = (email) ->
    log "register"
    log email
    user = uData.getUserByEmail(email)
    if user? then return ## already exists
    ## TODO figure out if I should turn it into a password reset

    ## TODO create registrationLink
    link = "https://dotv.ee/?code=f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5f5"
    sendRegistrationMail(email, link)
    return

export finalizeAction = (args) ->
    log "finalizeAction"
    errorMessage = "Code was Invalid!"

    code = args.code
    email = args.params[0]
    pwdSH = args.params[1]

    action = codesToAction[code]
    if !action? then return errorMessage
    
    delete codesToAction[code]
    if action.email != email then return errorMessage

    ## TODO implement
    # if action.type = "register"
    return

