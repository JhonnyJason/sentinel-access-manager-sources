############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("sessionmodule")
#endregion

############################################################
import *  as stamp from "validatabletimestamp"

############################################################
import * as bs from "./bugsnitch.js"
############################################################
import * as keyM from "./servicekeysmodule.js"
import * as auth from "./authutilmodule.js"

############################################################
#region Local Variables
codeToSession = Object.create(null)
emailToSession = Object.create(null)

#endregion

############################################################
# sessionObj = {
#     email: STRINGEMAIL
#     authCode: STRINGHEX32
#     validUntil: NUMBER
# }

############################################################
noSigKey = '"\'\\'

############################################################
urlBackend = "http://localhost:3333"
nonce = Math.floor(Math.random() * 123456)

############################################################
## cleanup timing and TTL
authCodeLifeMS = 7_200_000 # ~2h
# relatively "long" interval saves compute time
cleanInterval = 45_000 # ~45s 
# tolerance how long access code should be valid on actual server
# should be bigger than potential cleanup delay if we prefer to
# manually call "unsetAccess" instead of letting it timeout
ttlTolerance = 50_000 # ~50s 

############################################################
export initialize = (c) ->
    log "initialize"
    if c.authCodeValidityMS? then authCodeLifeMS = c.authCodeValidityMS
    if c.urlSentinelBackend? then urlBackend = c.urlSentinelBackend
    
    setInterval(cleanSessions, cleanInterval) # ~45s
    return


############################################################
cleanSessions = ->
    log "cleanSessions"
    now = Date.now()

    for sess, code of codeToSession when (sess.validUntil < now)
        # removeSession(code)
        delete emailToSession[sess.email]
        delete codeToSession[code]
        # the ones with 0 we already unset manually ;-)
        unsetAccess(code) unless sess.validUntil == 0 

    return

############################################################
sendPost = (url, bodyString) ->
    options = {
        method: 'POST'
        body: bodyString
        headers: { 'Content-Type':'application/json' }
    }
    try response = await fetch(url, options)
    catch err then bs.report("@sessionmodule.sendPost: "+err.message)
    
    if response.ok then return

    try 
        console.error("Response was not OK! (#{response.status})")
        errorMsg = await response.text()
        console.error(errorMsg)
    catch err then bs.report("@sessionmodule.sendPost - parsing error: "+ err.message)
    return

############################################################
setAccess = (authCode, ttlMS) ->
    log "setAcccess"
    args = {authCode, ttlMS}
    try bodyString = await createBodyStringWithAuth(args)
    catch err then bs.report("@setAccess auth creation failed: "+err.message)

    url = urlBackend+'/grantAccess'
    try await sendPost(url, bodyString)
    catch err then bs.report("@setAccess error on sendPost: "+err.message)
    return

unsetAccess = (authCode) ->
    log "unsetAccess"
    try bodyString = await createBodyStringWithAuth(authCode)
    catch err then bs.report("@unsetAccess auth creation failed: "+err.message)

    url = urlBackend+'/revokeAccess'
    try await sendPost(url, bodyString)
    catch err then bs.report("@unsetAccess error on sendPost: "+err.message)
    return

############################################################
createBodyStringWithAuth = (args) ->
    argsString = JSON.stringify(args)
    result = '{"auth":{"senderId":"'+keyM.getPublicKeyHex()+'",'
    result += '"timestamp":'+stamp.create()+',"nonce":'+nonce+','
    result += '"signature":"'+noSigKey+'"},"args":'+argsString+'}'
    
    nonce++

    sig = await keyM.sign(result)
    result = result.replace(noSigKey, sig)
    # resultObj = JSON.parse(result)
    # olog resultObj
    return result

############################################################
export startSession = (email) ->
    log "startSession"
    s = {
        authCode: auth.randomCodeGenHex(16)
        validUntil: Date.now() + authCodeLifeMS
    }

    codeToSession[s.authCode] = s
    emailToSession[email] = s

    ttlMS = authCodeLifeMS + ttlTolerance    
    await setAccess(s.authCode, ttlMS)
    return s

export stopSession = (code) ->
    log "stopSession"
    s = codeToSession[code]
    if !s? then return

    # simply set invalid and let it be cleaned up here :-) 
    s.validUntil = 0
    ## still we will manually unsetAccess now
    unsetAccess(code)
    return

############################################################
export refreshSession = (code) ->
    log "refreshSession"
    s = codeToSession[code]
    if !s? then return null

    now = Date.now()
    # cannot refresh already invalid session
    if s.validUntil < now then return 

    delete codeToSession[code]

    s.authCode = auth.randomCodeGenHex(16)
    s.validUntil = now + authCodeLifeMS
    ttlMS = authCodeLifeMS + ttlTolerance
    
    codeToSession[s.authCode] = s

    unsetAccess(code)
    await setAccess(s.authCode, ttlMS) 
    return s


