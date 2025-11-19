############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("authutilmodule")
#endregion

############################################################
import * as secUtl from "secret-manager-crypto-utils"
import * as crypto from "node:crypto"
import * as tbut from "thingy-byte-utils"

############################################################
export randomCodeGenHex = (byteLength = 16) ->
    buf = crypto.randomBytes(byteLength)
    return tbut.bytesToHex(buf)

############################################################
export getPasswordHash = (input) ->
    log "getPasswordHash"
    return await secUtl.sha256(input)

export verifyPassword = (pwdSH, pwdSHH) ->
    toCheckSHH = await secUtl.sha256(pwdSH)
    if pwdSHH == toCheckSHH then return
    else return "Incorrect Password!" 

export xorHex = (a, b) ->
    aBytes = tbut.hexToBytes(a)
    bBytes = tbut.hexToBytes(b)

    if aBytes.length > bBytes.length
        rBytes = new Uint8Array(aBytes.length)
    else rBytes = new Uint8Array(bBytes.length)

    rBytes[i] = aBytes[i] ^ bBytes[i] for b,i in rBytes
    return tbut.bytesToHex(rBytes)