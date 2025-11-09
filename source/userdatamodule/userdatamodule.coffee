############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("userdatamodule")
#endregion

############################################################
#region Modules from the Environment
import * as dataCache from "cached-persistentstate"
import * as serviceCrypto from "./servicekeysmodule.js"

#endregion


############################################################
userDataStore = {}
userData = {}

############################################################
## UserData Schema
# {
#     email: STRINGEMAIL
#     passwordSHH: STRINGHEX64
#     subscribedUntil: NUMBER
#     isTester: BOOLEAN
#     latestInteraction: NUMBER
# }

############################################################
export initialize = ->
    log "initialize"
    userDataStore = dataCache.load("userDataStore")
    
    if userDataStore.meta? 
        try await validateUserDataStore()
        catch err
            console.error("Corrupted userDataStore!\n#{err.message}")
            process.exit(78)
    else userDataStore.meta = {}
    
    if userDataStore.encrypted?
        try userData = await serviceCrypto.decrypt(userDataStore.encrypted)
        catch err then log err

    olog userData
    return 

############################################################
validateUserDataStore = ->
    log "validateUserDataStore"
    meta = userDataStore.meta
    signature = meta.serverSig
    if !signature then throw new Error("No signature in userDataStore.meta !")
    meta.serverSig = ""
    userDataStoreString = JSON.stringify(userDataStore)
    meta.serverSig = signature
    if(await serviceCrypto.verify(signature, userDataStoreString)) then return
    else throw new Error("Invalid Signature in authCodestore.meta !")

signAndSaveUserDataStore = ->
    log "signAndSaveUserDataStore"
    userDataStore.meta.serverSig = ""
    userDataStore.meta.serverPub = serviceCrypto.getPublicKeyHex()
    userDataStore.encrypted = await serviceCrypto.encrypt(userData)
    jsonString = JSON.stringify(userDataStore)
    signature = await serviceCrypto.sign(jsonString)
    userDataStore.meta.serverSig = signature
    dataCache.save("userDataStore")
    return

############################################################
export getNewUserObject = -> {
    email: ""
    passwordSHH: ""
    subscribedUntil: 0
    isTester: false
    latestInteraction: 0
}

############################################################
export getAllUserData = -> userData

############################################################
export getUserData = (userId) ->
    log "getUserData"
    return userData[userId]

############################################################
export addNewUser = (data) ->
    log "addNewUser not implemented yet!"
    ##TODO create new userId
    return "11111111111111111111111111111111"

############################################################
export setUserData = (userId, data) ->
    log "setUserData"
    userData[userId] = data
    try await signAndSaveUserDataStore()
    catch err then log err
    return

############################################################
export removeUserData = (userId) ->
    log "removeUserData"
    if userData[userId]? then delete userData[userId] 
    try await signAndSaveUserDataStore()
    catch err then log err
    return
