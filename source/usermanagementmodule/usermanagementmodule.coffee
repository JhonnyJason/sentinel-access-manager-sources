############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("usermanagementmodule")
#endregion

############################################################
#region modules from the Environment
import { sha256 } from "secret-manager-crypto-utils"

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
export getUserById = (userId) ->
    log "getUserById"
    user = uData.getUserById(userId)
    olog  { user }
    if !user? then return "User does not exist!"
    return {
        userId: userId
        email: user.email
        subscribedUntil: user.subscribedUntil || null
        isTester: user.isTester || false
        lastInteraction: user.lastInteraction || null
    }


############################################################
export updateUser = (args) ->
    log "updateUser"
    user = uData.getUserById(args.userId)
    if !user? then return "User does not exist!"
    user.email = args.email
    user.subscribedUntil = args.subscribedUntil
    user.isTester = args.isTester
    uData.setUserData(args.userId, user)
    return

############################################################
export createUser = (args) ->
    log "createUser"
    user = uData.getNewUserObject()
    user.email = args.email
    user.subscribedUntil = args.subscribedUntil
    user.isTester = args.isTester
    user.passwordSHH = await sha256(args.passwordSH)
    userId = uData.addNewUser(user)
    return userId


############################################################
export deleteUser = (userId) ->
    log "deleteUser"
    uData.removeUserData(userId)
    return


############################################################
export registerNewUser = (args) ->
    log "registerNewUser"
    return