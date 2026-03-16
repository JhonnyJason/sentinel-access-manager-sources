############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("adminaccess")
#endregion

############################################################
import *  as stamp from "validatabletimestamp"

############################################################
import * as bs from "./bugsnitch.js"

############################################################
import * as servKey from "./servicekeysmodule.js"
import * as auth from "./authutilmodule.js"

############################################################
noSigKey = '"\'\\'

############################################################
urlBackend = "http://localhost:3333"
urlDatahub = "http://localhost:3344"
nonce = Math.floor(Math.random() * 123456)

############################################################
export initialize = (c) ->
    log "initialize"
    if c.urlSentinelBackend? then urlBackend = c.urlSentinelBackend
    if c.urlSentinelDatahub? then urlDatahub = c.urlSentinelDatahub
    return

############################################################
sendPost = (url, bodyString) ->
    options = {
        method: 'POST'
        body: bodyString
        headers: { 'Content-Type':'application/json' }
    }
    try response = await fetch(url, options)
    catch err then bs.report("@adminaccess.sendPost: "+err.message)
    
    if response.ok then return

    try
        console.error("Response was not OK! (#{response.status})")
        errorMsg = await response.text()
        bs.report(errorMsg)
    catch err then bs.report("@adminaccess.sendPost - parsing error: "+ err.message)
    return

############################################################
createBodyStringWithAuth = (args) ->
    argsString = JSON.stringify(args)
    pubKeyHex = await servKey.getPublicKeyHex()
    
    result = '{"auth":{"senderId":"'+pubKeyHex+'",'
    result += '"timestamp":'+stamp.create()+',"nonce":'+nonce+','
    result += '"signature":"'+noSigKey+'"},"args":'+argsString+'}'
    
    nonce++

    sig = await servKey.sign(result)
    result = result.replace(noSigKey, sig)
    # resultObj = JSON.parse(result)
    # olog resultObj
    return result

############################################################
export setAdminKeys = (adminKeys) ->
    log "setAdminKeys"
    args = { adminKeys }
    try bodyString = await createBodyStringWithAuth(args)
    catch err then bs.report("@adminaccess.setAdminKeys createBodyStringWithAuth failed: "+err.message)
    log bodyString

    url = urlBackend+'/setAdminKeys'
    try await sendPost(url, bodyString)
    catch err then bs.report("@adminaccess.setAdminKeys sendPost to Backend failed: "+err.message)

    url = urlDatahub+'/setAdminKeys'
    try await sendPost(url, bodyString)
    catch err then bs.report("@adminaccess.setAdminKeys sendPost to Datahub failed: "+err.message)
    return


