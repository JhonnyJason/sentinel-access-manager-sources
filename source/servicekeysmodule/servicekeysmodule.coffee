############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("servicekeysmodule")
#endregion

############################################################
import * as cachedData from "cached-persistentstate"
cachedData.initialize()
import * as secUtl from "secret-manager-crypto-utils"
import * as validatableStamp from "validatabletimestamp"
import { ThingyCryptoNode } from "thingy-crypto-node"

############################################################
serviceState = null
godKeyHex = null
cryptoNode = null

############################################################
setReady = null
ready = new Promise (resolve) -> setReady = resolve 

############################################################
export initialize = ->
    log "initialize"
    serviceState = cachedData.load("serviceState")
    # olog serviceState
    
    if !serviceState.secretKeyHex
        kp = await secUtl.createKeyPairHex()
        serviceState.secretKeyHex = kp.secretKeyHex
        serviceState.publicKeyHex = kp.publicKeyHex
        cachedData.save("serviceState")
    
    ## Use CryptoNode
    options = {
        secretKeyHex: serviceState.secretKeyHex
        publicKeyHex: serviceState.publicKeyHex
        context: "thingy-rpc-post-connection"
    }
    cryptoNode = new ThingyCryptoNode(options)
    # olog serviceState
    setReady(true)
    return

############################################################
export isNotGod = (keyHex) -> return keyHex != godKeyHex

############################################################
export getPublicKeyHex = -> cryptoNode.id

############################################################
export sign = (content) ->
    await ready
    return await cryptoNode.sign(content)

############################################################
export verify = (sigHex, content) ->
    await ready
    return await cryptoNode.verify(sigHex, content)

############################################################
export getSignedNodeId = ->
    log "getSignedNodeId"
    await ready
    log "we are ready!"
    result = {}
    result.serverNodeId = serviceState.publicKeyHex
    result.timestamp = validatableStamp.create()
    content = JSON.stringify(result)
    result.signature = await sign(content)
    return result

############################################################
export getEntropySeed = (clientId, specificContext, timestamp) ->
    await ready
    return await cryptoNode.diffieHellmanFor(clientId, specificContext, timestamp)

############################################################
export encrypt = (data) ->
    await ready
    return await cryptoNode.encrypt(JSON.stringify(data))

export decrypt = (secretsObj) ->
    await ready
    return JSON.parse(await cryptoNode.decrypt(secretsObj))


