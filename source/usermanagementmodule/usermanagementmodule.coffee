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
            subscribedUntil: user.subscribedUntil
            isTester: user.isTester,
            lastInteraction: user.lastInteraction
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
        subscribedUntil: user.subscribedUntil
        isTester: user.isTester 
        lastInteraction: user.lastInteraction
    }


############################################################
export updateUser = (args) ->
    log "updateUser"
    user = uData.getUserById(args.userId)
    if !user? then return "User does not exist!"
    if args.email? then user.email = args.email
    if args.subscribedUntil? then user.subscribedUntil = args.subscribedUntil
    if args.isTester? then user.isTester = args.isTester
    uData.setUserData(args.userId, user)
    return

############################################################
export createUser = (args) ->
    log "createUser"
    user = uData.getNewUserObject()
    user.email = args.email
    user.subscribedUntil = args.subscribedUntil || 0
    user.isTester = args.isTester || false
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
    