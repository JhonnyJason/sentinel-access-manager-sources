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
import * as mailC from "./mailcreatormodule.js"
import * as admA from "./adminaccess.js"

############################################################
STOREKEY = "adminData"

############################################################
adminData = Object.create(null)
pubKeyToAdmin = Object.create(null)
otcToAdmin = Object.create(null)

############################################################
salt = "eo9pbfr567890pl,+-.,ysw35tltwadh"
urlAdminDashboard = "https://sentinel-admin.dotv.ee"
sAdm = "suparmin"
sAdmExists = false

############################################################
export initialize = (cfg) ->
    log "initialize"
    admA.initialize(cfg)

    if cfg.urlAdminDashboard? then urlAdminDashboard = cfg.urlAdminDashboard
    if cfg.superAdmin? then sAdm = cfg.superAdmin
    if cfg.adminSalt?  then salt = cfg.adminSalt

    adminData = await seStore.load(STOREKEY)
    olog adminData

    for name, data of adminData
        if data.publicKey? then pubKeyToAdmin[data.publicKey] = data
        if data.otc? then otcToAdmin[data.otc] = data
        if name == sAdm then sAdmExists = true
    return

############################################################
saveUpdate = ->
    log "saveUpdate"
    seStore.save(STOREKEY)
    
    emails = Object.keys(adminData)

    adminKeys = []
    adminKeys.push(k) for k in emails when adminData[k].publicKey?
        
    log adminKeys
    admA.setAdminKeys(adminKeys)
    return

############################################################
export generateFirstOTC = (args) ->
    log "generateFirstOTC"
    { name, pin } = args
    if sAdmExists then return { error: "First OTC already generated!" }
    if name != sAdm then return { error: "You are not the one!" }

    otc = authUtl.randomCodeGenHex(16)
    secret = await secUtl.sha256(otc + pin + salt)
    
    data = { name, secret, otc }
    otcToAdmin[otc] = data
    adminData[name] = data
    sAdmExists = true
    saveUpdate()

    url = urlAdminDashboard+"?otc="+otc
    return url

############################################################
export generateOTC = (args) ->
    log "generateOTC"
    { email, pin, timestamp, publicKey } = args
    ## Here the signature has already been verified :-)
    
    initiator = pubKeyToAdmin[publicKey]
    if initiator.name != sAdm and initiator.name != email
        return {error: "You cannot do this!"} 

    otc = authUtl.randomCodeGenHex(16)
    secret = await secUtl.sha256(otc + pin + salt)
    
    data = adminData[email]
    if !data? then data = Object.create(null)
    
    data.name = email
    data.secret = secret
    data.otc = otc

    otcToAdmin[otc] = data
    adminData[email] = data
    saveUpdate()

    url = urlAdminDashboard+"?otc="+otc
    mailC.sendAdminOtcMail(email, url) unless email == sAdm
    return url

export registerAdmin = (args) ->
    log "registerAdmin"
    { publicKey, otc, secret, timestamp, signature } = args
    ## Here the validity of the registration needs to be verified
    err = checkValidity(timestamp)
    if err then return "Invalid Timestamp!"

    body = JSON.stringify(args)
    content = body.replace('"signature":"'+signature+'"', '"signature":""')
    isValid = await secUtl.verify(signature, publicKey, content)
    if !isValid then return "Invalid Signature!"

    data = otcToAdmin[otc]
    if !data then return "Invalid OTC!"
    ## OTC only valid once -> on invalid pin we need a new otc
    delete otcToAdmin[otc]
    delete data.otc
    
    log data.secret
    log secret

    if data.secret != secret then return "Registration Failed!"
    delete data.secret ## secret not needd anymore - success!!

    data.publicKey = publicKey
    pubKeyToAdmin[publicKey] = data

    saveUpdate()
    return

export removeAdmin = (args) ->
    log "removeAdmin"
    { publicKey } = args
    ## Here the signature has already been verified :-)
    data = pubKeyToAdmin[publicKey]
    delete pubKeyToAdmin[publicKey]
    delete adminData[data.name]
    
    saveUpdate()
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
