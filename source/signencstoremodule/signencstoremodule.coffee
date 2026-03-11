############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("signencstoremodule")
#endregion

############################################################
import * as dataCache from "cached-persistentstate"
import {
    STRINGHEX64, STRINGHEX128, STRINGHEX, createValidator
} from "thingy-schema-validate"
dataCache
############################################################
import * as servKey from "./servicekeysmodule.js"
import * as cfg from "./configmodule.js"

############################################################
dataCache.initialize(cfg.persistentStateOptions)


############################################################
## StoreObj Validator
validateStoreObj = createValidator({
    meta: {
        serverPub: STRINGHEX64,
        serverSig: STRINGHEX128
    }
    encrypted: {
        referencePointHex: STRINGHEX64,
        encryptedContentHex: STRINGHEX
    }
})

############################################################
storeMap = Object.create(null)
dataMap = Object.create(null)
saveState = Object.create(null)

############################################################


############################################################
cleanSaveState = -> { saving: false, delayedSave: false }

############################################################
loadAndVerifyStoreObj = (storeKey) ->
    storeObj = dataCache.load(storeKey)
    err = validateStoreObj(storeObj)
    saveState[storeKey] = cleanSaveState() unless saveState[storeKey]? 
    
    if err 
        console.error("Loading store: #{storeKey} - empty or corrupted!")
        return await saveNew(storeKey, Object.create(null))
    else
        await signatureCheck(storeObj)
        dataMap[storeKey] = await servKey.decrypt(storeObj.encrypted)
        storeMap[storeKey] = storeObj
    return

############################################################
signatureCheck = (storeObj) ->
    log "signatureCheck"
    sigHex = storeObj.meta.serverSig
    pubKey = storeObj.meta.serverPub
    storeObj.meta.serverSig = ""
    dataString = JSON.stringify(storeObj)
    storeObj.meta.serverSig = sigHex

    serverPubKey = await servKey.getPublicKeyHex()
    if pubKey != serverPubKey then throw new Error("Server key changed!")

    isValid = await servKey.isValidSignature(sigHex, dataString)    
    if !isValid then throw new Error("StoreObj carried invalid Signature!")
    return


############################################################
export load = (storeKey) ->
    log "load (#{storeKey})"
    return dataMap[storeKey] if dataMap[storeKey]?

    try await loadAndVerifyStoreObj(storeKey)
    catch err 
        console.error("Error on loading storeObj: #{err.message}")
        process.exit(78)

    return dataMap[storeKey]
    

############################################################
export save = (storeKey) ->
    log "save (#{storeKey})"
    sS = saveState[storeKey]
    
    if sS.saving
        sS.delayedSave = true
        return

    sS.delayedSave = false ## does not matter but keeps finally block cleaner
    sS.saving = true

    try
        log "actually saving now..."
        storeObj = storeMap[storeKey]
        data = dataMap[storeKey]
        storeObj.meta.serverSig = ""
        storeObj.encrypted = await servKey.encrypt(data)

        jsonString =  JSON.stringify(storeObj)
        sigHex = await servKey.sign(jsonString)
        storeObj.meta.serverSig = sigHex

        dataCache.save(storeKey)
    catch err then bs.report("storeObj save (#{storeKey}): "+err.message)
    finally
        sS.saving = false
        if sS.delayedSave then save(storeKey)
    return

############################################################
export saveNew = (storeKey, data) ->
    log "saveNew (#{storeKey})"
    sS = saveState[storeKey]
    if sS.saving then throw new Error("You shall not race-condition saveNew!")
    
    sS.saving = true
    try
        storeObj = Object.create(null)
        storeMap[storeKey] = storeObj
        dataMap[storeKey] = data

        storeObj.meta = Object.create(null)
        storeObj.meta.serverPub = await servKey.getPublicKeyHex()
        storeObj.meta.serverSig = ""
        storeObj.encrypted = await servKey.encrypt(data)
        
        jsonString =  JSON.stringify(storeObj)
        sigHex = await servKey.sign(jsonString)
        storeObj.meta.serverSig = sigHex

        dataCache.save(storeKey, storeObj)
        log "actually saved #{storeKey}!"
    catch err then bs.report("storeObj saveNew (#{storeKey}): "+err.message)
    finally
        sS.saving = false
        if sS.delayedSave then save(storeKey)
    return