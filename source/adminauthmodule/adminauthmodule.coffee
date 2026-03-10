############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("adminauthmodule")
#endregion

############################################################
import * as secUtl from "secret-manager-crypto-utils"
import { checkValidity } from "validatabletimestamp"

############################################################
import * as seStore from "./signencstoremodule.js"
import * as authUtl from "./authutilmodule.js"

############################################################
STOREKEY = "adminData"
save = -> seStore.save(STOREKEY)

############################################################
adminData = Object.create(null)
pubKeyToAdmin = Object.create(null)
otcToAdmin = Object.create(null)

############################################################
salt = "eo9pbfr567890pl,+-.,ysw35tltwadh"
urlAdminDashboard = "https://sentinel-admin.dotv.ee"

############################################################
export initialize = (cfg) ->
    log "initialize"
    if cfg.urlAdminDashboard? then urlAdminDashboard = cfg.urlAdminDashboard

    adminData = await seStore.load(STOREKEY)
    olog adminData

    for name, data of adminData
        pubKeyToAdmin[data.publicKey] = data
    return


############################################################
export generateOTC = (args) ->
    log "generateOTC"
    { adminName, pin, timestamp, publicKey } = args
    ## Here the signature has already been verified :-)
    
    initiator = pubKeyToAdmin[publicKey]
    if initiator.name != "sose" and initiator.name != adminName
        return {error: "You cannot do this!"} 

    otc = authUtl.randomCodeGenHex(16)
    secret = await secUtl.sha256(otc + pin + salt)
    
    data = adminData[adminName]
    if !data? then data = Object.create(null)
    
    data.name = adminName
    data.secret = secret
    data.otc = otc

    otcToAdmin[otc] = data
    url = urlAdminDashboard+"?otc="+otc
    return url

export registerAdmin = (args, ctx) ->
    log "registerAdmin"
    { publicKey, otc, secret, timestamp, signature } = args
    ## Here the validity of the registration needs to be verified
    err = checkValidity(timestamp)
    if err then return "Invalid Timestamp!"

    content = ctx.body.replace('"signature":"'+signature+'"', '"signature":""')
    isValid = await secUtl.verify(signature, pubKey, content)
    if !isValid then return "Invalid Signature!"

    data = otcToAdmin[otc]
    if !data then return "Invalid OTC!"
    ## OTC only valid once -> on invalid pin we need a new otc
    delete otcToAdmin[otc]
    delete data.otc

    if data.secret != secret then "Registration Failed!"
    delete data.secret ## secret not needd anymore - success!!

    data.publicKey = publicKey
    pubKeyToAdmin[publicKey] = data

    save()
    return

export removeAdmin = (args) ->
    log "removeAdmin"
    { publicKey } = args
    ## Here the signature has already been verified :-)
    data = pubKeyToAdmin[publicKey]
    delete pubKeyToAdmin[publicKey]
    delete adminData[data.name]
    
    save()
    return


############################################################
export signatureAuth = (req, ctx) ->
    log "signatureAuth"
    olog ctx
    sigHex = ctx.auth.signature
    pubKey = ctx.auth.publicKey
    
    stamp = ctx.auth.timestamp
    err = checkValidity(stamp)
    if err then return "Invalid Timestamp!"

    ## should be validated as STRINGHEX64
    if !pubKeyToAdmin[pubKey]? then return "Not an Admin!"

    content = ctx.body.replace('"signature":"'+sigHex+'"', '"signature":""')
    isValid = await secUtl.verify(sigHex, pubKey, content)
    if !isValid then return "Invalid Signature!"
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
