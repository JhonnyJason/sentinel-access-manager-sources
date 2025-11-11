############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("accountsmodule")
#endregion


############################################################
#region Modules from the Environment
import { makeForgetable } from "memory-decay"

############################################################
import * as cfg from "./configmodule.js"
import * as auth from "./authutilmodule.js"

############################################################
import * as uData from "./userdatamodule.js"
import * as usrM from "./usermanagementmodule.js"
import { 
    sendRegistrationMail, sendPasswordResetMail 
} from "./mailcreatormodule.js"

#endregion


############################################################
#region Local Variables
codesToAction = Object.create(null)
#endregion


############################################################
export initialize = ->
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


############################################################
export register = (email) ->
    log "register"
    log email
    user = uData.getUserByEmail(email)
    if user? then return ## already exists
    ## TODO figure out if I should turn it into a password reset
    
    action = Object.create(null)
    action.type = "register"
    action.userEmail = email

    code = auth.randomCodeGenHex(16)
    while(codesToAction[code]?)
        code = auth.randomCodeGenHex(16)

    codesToAction[code] = action
    codesToAction.letForget(code)   

    link = "#{cfg.urlSentinelDashboard}?action=register&code=#{code}"
    sendRegistrationMail(email, link)
    return

############################################################
export finalizeAction = (args) ->
    log "finalizeAction"
    code = args.code
    type = args.type
    email = args.email
    pwdSH = args.passwordSH

    errorMessage = "Problem!"

    actionObj = codesToAction[code]
    if !actionObj? then return errorMessage
    if actionObj.type != type then return errorMessage    
    if actionObj.userEmail != email then return errorMessage

    # valid reqest, we may finalize the action and delete it in the map
    delete codesToAction[code]
    usrM.finalizeUserRegistration(email, pwdSH)
    return

