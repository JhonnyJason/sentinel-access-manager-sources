############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("userdatamodule")
#endregion

############################################################
#region Modules from the Environment

############################################################
import {
    STRINGEMAIL, STRINGHEX64, STRINGHEX64ORNOTHING, NUMBER, 
    BOOLEAN, OBJECT, createValidator
} from "thingy-schema-validate"

############################################################
import * as seStore from "./signencstoremodule.js"
import * as authUtl from "./authutilmodule.js"

#endregion

############################################################
#region Local Variables
STOREKEY = "userDataStore"

############################################################
userData = Object.create(null)
emailToUser = Object.create(null)

############################################################
## UserData Validator
validateNewUserObj = createValidator({
    email: STRINGEMAIL
    passwordSHH: STRINGHEX64
    xCode: STRINGHEX64ORNOTHING
    lastInteraction: NUMBER
    details: OBJECT
})

#endregion

############################################################
export initialize = ->
    log "initialize"
    
    userData = await seStore.load(STOREKEY)
    olog userData

    for id,data of userData
        emailToUser[data.email] = data
    return 


############################################################
export getNewUserObject = -> {
    email: ""
    passwordSHH: ""
    lastInteraction: 0,
    details: {}
}

############################################################
export getAllUserData = -> userData

############################################################
export getUserById = (userId) ->
    log "getUserById"
    return userData[userId]

export getUserByEmail = (email) ->
    log "getUserByEmail"
    return emailToUser[email]

############################################################
export addNewUser = (user) ->
    log "addNewUser"
    err = validateNewUserObj(user)
    if err
        console.error("addNewUser: invalid user object! (#{err})")
        return "deaddeaddeaddeaddeaddeaddeaddead"

    newUserId = authUtl.randomCodeGenHex(16)
    while(userData[newUserId]?)
        newUserId = authUtl.randomCodeGenHex(16)
    
    userData[newUserId] = user
    emailToUser[user.email] = user

    seStore.save(STOREKEY)
    return newUserId

############################################################
export setUserData = (userId, data) ->
    log "setUserData"
    userData[userId] = data
    seStore.save(STOREKEY)
    return

############################################################
export removeUserData = (userId) ->
    log "removeUserData"
    return unless userData[userId]?
    
    email = userData[userId].email
    delete userData[userId] 
    delete emailToUser[email]

    seStore.save(STOREKEY)
    return

############################################################
export save = -> seStore.save(STOREKEY)