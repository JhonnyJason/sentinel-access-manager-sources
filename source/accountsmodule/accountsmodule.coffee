############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("accountsmodule")
#endregion


############################################################
#region Modules from the Environment
import { makeForgetable } from "memory-decay"

############################################################
import * as bs from "./bugsnitch.js"
############################################################
import * as cfg from "./configmodule.js"
import * as auth from "./authutilmodule.js"

############################################################
import * as uData from "./userdatamodule.js"
import * as usrM from "./usermanagementmodule.js"
import { 
    sendRegistrationMail, sendPasswordResetMail, sendAlreadyRegisteredMail 
} from "./mailcreatormodule.js"

############################################################
import * as sess from "./sessionmodule.js"

#endregion


############################################################
#region Local Variables
codesToAction = Object.create(null)
emailToCode = Object.create(null)

#endregion

############################################################
ttlActionMS = 600_000
ttlAuthCodeMS = 7_200_000

############################################################
export initialize = (c) ->
    if c.actionLiveTimeMS? then ttlActionMS = c.actionLiveTimeMS
    if c.authCodeValidityMS? then ttlAuthCodeMS = c.authCodeValidityMS
    makeForgetable(codesToAction, ttlActionMS) 
    makeForgetable(emailToCode, ttlActionMS)
    return

############################################################
verifyCorrectPassword = (email, pwdSH) ->
    user = uData.getUserByEmail(email)
    if !user? then return "User does not exist!"
    return auth.verifyPassword(pwdSH, user.passwordSHH)

shxToPasswordSH = (email, pwdSHX) ->
    user = uData.getUserByEmail(email)
    if !user? then return "User does not exist!"
    if !user.xCode? then return "User has no xCode!"
    return auth.xorHex(pwdSHX, user.xCode)

removeActionFor = (email) ->
    log "removeActionFor"
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

executeLogin = (email, pwdSH) ->
    log "executeLogin"
    try session = await sess.startSession(email)
    catch err then bs.report("@executeLogin error on startSession: "+ err.message)
    
    xCode = auth.randomCodeGenHex(32)
    user = uData.getUserByEmail(email)
    user.xCode = xCode
    uData.save()

    authCode = session.authCode
    validUntil = session.validUntil
    passwordSHX = auth.xorHex(xCode, pwdSH)

    return { authCode, validUntil, passwordSHX}


############################################################
#region Session Management (login, logout + refreshSession)
export login = (args) ->
    log "login"
    olog args
    err = await verifyCorrectPassword(args.email, args.passwordSH)
    if err then return "Incorrect Credentials!"

    return executeLogin(args.email, args.passwordSH)

export loginX = (args) ->
    log "loginX"
    olog args
    passwordSH = shxToPasswordSH(args.email, args.passwordSHX)

    err = await verifyCorrectPassword(args.email, passwordSH)
    if err then return "Incorrect Credentials!"

    return executeLogin(args.email, passwordSH)

############################################################
export logout = (authCode) ->
    sess.stopSession(authCode)
    return

############################################################
export refreshSession = (authCode) ->
    log "refreshSession"
    session = await sess.refreshSession(authCode)
    if session? then return session
    return "Invalid authCode!"

#endregion

############################################################
#region Email Link Actions (paassword Reset + registration)
export passwordReset = (email) ->
    log "passwordReset"
    log email
    user = uData.getUserByEmail(email)
    if !user? then return ## do nothing without user

    removeActionFor(email)    
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

    removeActionFor(email)
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

#endregion

############################################################
#region Account Management ()
export updateEmail = (args) ->
    log "updateEmail"
    return "/updateEmail: Not implmented yet!"

############################################################
export updatePassword = (args) ->
    log "updatePasword"
    return "/updatePassword: Not implemented yet!"

############################################################
export deleteAccount = (args) ->
    log "deleteAccount"
    return "/deleteAccount: Not implemented yet!"
    
#endregion