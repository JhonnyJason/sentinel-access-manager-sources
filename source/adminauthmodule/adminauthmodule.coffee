############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("adminauthmodule")
#endregion


############################################################
export initialize = ->
    log "initialize"
    #Implement or Remove :-)
    return


############################################################
export signatureAuth = (req, ctx) ->
    log "signatureAuth"
    olog ctx
    return

export addServerSignature = (result, ctx) ->
    log "addServerSignature"
    log result
    olog ctx
    signature = "ffffffff".repeat(16)
    serverId = "aaaaaaaa".repeat(8)
    timestamp = Date.now()
    attachement = ',"auth":{"serverId":"'+serverId+'","timestamp":'+timestamp+',"signature":\\}}'
    resultLen = result.length
    payload = result.slice(0,-1)+attachement
    log payload
    nonSig = '"signature":\\'
    withSig = '"signature":"'+signature+'"'
    payload = payload.replace(nonSig, withSig)
    try olog(JSON.parse(payload))
    catch err then console.error(err)
    return payload
