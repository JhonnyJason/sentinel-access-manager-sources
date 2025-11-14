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
    sendRegistrationMail, sendPasswordResetMail, sendAlreadyRegisteredMail 
} from "./mailcreatormodule.js"

#endregion


############################################################
#region Local Variables
codesToAction = Object.create(null)
emailToCode = Object.create(null)

#endregion


############################################################
export initialize = ->
    makeForgetable(codesToAction, 600_000) # -> 10 minutes
    makeForgetable(emailToCode, 600_000) # -> 10 minutes
    return

############################################################
verifyCorrectPassword = (email, pwdSH) ->
    user = uData.getUserByEmail(email)
    if !user? then return "User does not exist!"
    return auth.verifyPassword(pwdSH, user.passwordSHH)

removeOldActionFor = (email) ->
    log "removeOldActionFor"
    code = emailToCode[email]
    if code?
        delete emailToCode[email]
        delete codesToAction[code]
    return

addUserAction = (type, email) ->
    log "addUserAction"
    action = Object.create(null)
    action.type = type
    action.userEmail = email
    
    code = auth.randomCodeGenHex(16)
    while(codesToAction[code]?)
        code = auth.randomCodeGenHex(16)

    emailToCode[email] = code       
    emailToCode.letForget(email)

    codesToAction[code] = action
    codesToAction.letForget(code)
    return code


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

    removeOldActionFor(email)    
    code = addUserAction("reset", email)

    link = "#{cfg.urlSentinelPassword}?action=reset&code=#{code}"
    sendPasswordResetMail(email, link)
    return


############################################################
export register = (email) ->
    log "register"
    user = uData.getUserByEmail(email)
    
    if user? ## Notify users they already have an account 
        sendAlreadyRegisteredMail(email)
        return

    removeOldActionFor(email)
    code = addUserAction("register", email)

    link = "#{cfg.urlSentinelPassword}?action=register&code=#{code}"
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

    # valid action, we may finalize and delete it in the maps
    delete codesToAction[code]
    delete emailToCode[email]

    if type == "register" then usrM.finalizeUserRegistration(email, pwdSH)
    if type == "reset" then usrM.finalizePasswordReset(email, pwdSH)
    return

