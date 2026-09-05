############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("usermanagementmodule")
#endregion

############################################################
#region modules from the Environment
# import { sha256 } from "secret-manager-crypto-utils"

import * as authUtl from "./authutilmodule.js"

############################################################
import * as uData from "./userdatamodule.js"

#endregion

############################################################
export getUserList = ->
    log "getUserList"
    userData = uData.getAllUserData()
    list = []
    for id,user of userData
        list.push({
            userId: id
            email: user.email
            lastInteraction: user.lastInteraction,
            details: user.details
        })
    return list

############################################################
export getUser = (userId) ->
    log "getUser"
    user = uData.getUserById(userId)
    olog  { user }
    if !user? then return "User does not exist!"
    return {
        userId: userId
        email: user.email
        lastInteraction: user.lastInteraction,
        details: user.details
    }


############################################################
export updateUser = (args) ->
    log "updateUser"
    user = uData.getUserById(args.userId)
    if !user? then return "User does not exist!"

    ## random repair...
    if !user.details? then user.details = Object.create(null)
    if user.isTester 
        user.details.isTester = user.isTester
        delete user.isTester
    if user.subscribedUntil
        user.details.subscribedUntil = user.subscribedUntil
        delete user.subscribedUntil

    if args.subscribedUntil? then user.details.subscribedUntil = args.subscribedUntil
    if args.isTester? then user.details.isTester = args.isTester


    if args.email? then user.email = args.email
    uData.setUserData(args.userId, user)
    return

############################################################
export createUser = (args) ->
    log "createUser"
    user = uData.getNewUserObject()
    user.details.subscribedUntil = args.subscribedUntil
    user.details.isTester = args.isTester

    user.email = args.email
    user.passwordSHH = await authUtl.getPasswordHash(args.passwordSH)
    userId = uData.addNewUser(user)
    return userId


############################################################
export deleteUser = (userId) ->
    log "deleteUser"
    uData.removeUserData(userId)
    return


############################################################
export finalizeUserRegistration = (email, pwdSH) ->
    log "finalizeUserRegistration"
    user = uData.getNewUserObject()
    user.email = email
    user.passwordSHH = await authUtl.getPasswordHash(pwdSH)
    user.lastInteraction = Date.now()
    return uData.addNewUser(user)
    
############################################################
export finalizePasswordReset = (email, pwdSH) ->
    log "finalizePasswordReset"
    user = uData.getUserByEmail(email)
    if !user? 
        console.error("Finalizing pwReset: User for #{email} not Found!")
        return
        
    user.passwordSHH = await authUtl.getPasswordHash(pwdSH)
    user.lastInteraction = Date.now()
    uData.save()
    return 