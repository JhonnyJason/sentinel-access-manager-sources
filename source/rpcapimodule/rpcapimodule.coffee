############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("rpcapimodule")
#endregion

############################################################
import {
    STRING, STRINGEMAIL, STRINGHEX64, STRINGHEX32, NUMBER, 
    ARRAY, BOOLEAN, STRINGCLEAN, STRINGHEX, NUMBERORNULL,
    STRINGEMAILORNOTHING, NUMBERORNOTHING, BOOLEANORNOTHING 
} from "thingy-schema-validate"

############################################################
import {
    userLoginAuth, onLoginSuccess, register, 
    passwordReset, getPasswordHash 
} from "./userauthmodule.js"

import { signatureAuth, addServerSignature } from "./adminauthmodule.js"

############################################################
import { sciAdd } from "./sciregistrymodule.js"

############################################################
import * as uData from "./userdatamodule.js"

############################################################
## Config Object with all options
# { 
#   bodySizeLimit: # limit body size for this route -> whole payload
#   authOption:  # add a function for request authentication (req, ctx)
#   argsSchema: # required for arguments - will be validated
#   resultSchema: # required for results - will be validated
#   responseAuth: # add a function to proof response authenticity (resultString, ctx)
# }

############################################################
#region Sample Functions

############################################################
echo = (echo) -> echo
############################################################
sciAdd("echo", echo, {
    bodySizeLimit: 100_000, # body larger than ~100kb will cause a 400 return 
    argsSchema: STRING,
    resultSchema: STRING
})

############################################################
ping = -> return "pong"
############################################################
sciAdd("ping", ping, {
    bodySizeLimit: 0, # any body will cause a 400 return
    resultSchema: STRINGCLEAN
})

############################################################
# no options for areYouOkay -> default settings
#     no auth, no args, no result, no responseAuthentication -> 204
sciAdd("areYouOkay", () -> return)

#endregion


############################################################
#region User Functions

############################################################
sciAdd("login", onLoginSuccess, {
    bodySizeLimit: 348,
    authOption: userLoginAuth
    argsSchema: { # 1
        email: STRINGEMAIL, # 10 + 256 -> 267
        passwordSH: STRINGHEX64 # -> 14 + 66 -> 347
    }, # 1 -> 348
    resultSchema: { authCode: STRINGHEX64, validUntil: NUMBER }
})
# only 200 with certain payload - no expeted Errors

############################################################
sciAdd("register", register, {
    bodySizeLimit: 267, 
    argsSchema: { email: STRINGEMAIL }
})
# 204 on success - 422 on expected Error: email already in use

############################################################
sciAdd("requestPasswordReset", passwordReset, {
    bodySizeLimit: 267
    argsSchema: { email: STRINGEMAIL }
})
# always 204 - no expected errors :-)

#endregion


############################################################ 
#region ADMIN Functions

############################################################ 
getUserList = -> 
    log "getUserList"
    return uData.getUserList()

############################################################ 
sciAdd("getUserList", uData.getUserList, {
    bodySizeLimit: 568, 
    authOption: signatureAuth,
    resultSchema: ARRAY
})
#Response is always 200 containing an Array


############################################################ 
getUserData = (userId) ->
    log "getUserData"
    user = uData.getUserData(userId)
    olog  { user }
    if !user? then return "User does not exist!"
    return {
        userId: userId
        email: user.email
        subscribedUntil: user.subscribedUntil || null
        isTester: user.isTester || false
        lastInteraction: user.lastInteraction || null
    }
############################################################
sciAdd("getUser", getUserData, {
    bodySizeLimit: 600, 
    authOption: signatureAuth,
    argsSchema: STRINGHEX 
    resultSchema: {
        userId: STRINGHEX,
        email: STRINGEMAIL, 
        subscribedUntil: NUMBERORNULL,
        isTester: BOOLEAN,
        lastInteraction: NUMBERORNULL
    }
    responseAuth: addServerSignature
})
#Response is either 200 with user data or '422 "User does not exist!"'


############################################################
updateUser = (args) ->
    log "updateUser"
    user = uData.getUserData(args.userId)
    if !user? then return "User does not exist!"
    user.email = args.email
    user.subscribedUntil = args.subscribedUntil
    user.isTester = args.isTester
    uData.setUserData(args.userId, user)
    return

############################################################
sciAdd("updateUser", updateUser, {
    bodySizeLimit: 1_024,  
    authOption: signatureAuth,
    argsSchema: {
        userId: STRINGHEX32,
        email: STRINGEMAILORNOTHING, 
        subscribedUntil: NUMBERORNOTHING,
        isTester: BOOLEANORNOTHING
    }
})
# Response is either 204 or '422 "User does not exist!"'


############################################################
createUser = (args) ->
    log "createUser"
    user = uData.getNewUserObject()
    user.email = args.email
    user.subscribedUntil = args.subscribedUntil
    user.isTester = args.isTester
    user.passwordSHSH = await getPasswordHash(args.passwordSH)
    userId = uData.addNewUser(user)
    return userId

############################################################
sciAdd("createUser", createUser, {
    bodySizeLimit: 1_220,
    authOption: signatureAuth
    argsSchema: { 
        email: STRINGEMAIL, 
        passwordSH: STRINGHEX64
        subscribedUntil: NUMBERORNOTHING, 
        isTesterAccount: BOOLEANORNOTHING 
    }
    resultSchema: STRINGHEX32
    responseAuth: addServerSignature
})
# Response is either 200 with userId or '422  "Email already in use!"'


############################################################
deleteUser = (userId) ->
    log "deleteUser"
    uData.removeUserData(userId)
    return
############################################################
sciAdd("deleteUser", deleteUser, {
    bodySizeLimit: 500 
    authOption: signatureAuth
    argsSchema: STRINGHEX
})
# Response is always 204 


#endregion

