############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("adminsci")
#endregion

############################################################
#region Modules from the Environment
import {
    STRINGEMAIL, STRINGHEX64, STRINGHEX32, ARRAY, NUMBER,
    STRINGORNOTHING, NONEMPTYSTRING, STRINGHEX128,
    STRINGEMAILORNOTHING, NUMBERORNOTHING, BOOLEANORNOTHING,
    BOOLEAN, createValidator
} from "thingy-schema-validate"

############################################################
import { sciAdd, setValidatorCreator } from "./scicoremodule.js"
setValidatorCreator(createValidator)

############################################################
import * as adminM from "./adminauthmodule.js"

############################################################
import * as usrM from "./usermanagementmodule.js"

#endregion

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
#region ADMIN Functions

############################################################ 
#region Admin Management
sciAdd("generateFirstOTC", adminM.generateFirstOTC, {
    bodySizeLimit: 998,
    argsSchema: {
        name: NONEMPTYSTRING, 
        pin: NONEMPTYSTRING 
    }
    resultSchema: NONEMPTYSTRING
})

sciAdd("generateAdminOTC", adminM.generateOTC, {
    bodySizeLimit: 998, 
    authOption: adminM.signatureAuth,
    argsSchema: {
        email: STRINGEMAIL, 
        pin: NONEMPTYSTRING,
        timestamp: NUMBER,
        publicKey: STRINGHEX64,
        signature: STRINGHEX128
    }
    resultSchema: NONEMPTYSTRING
})

sciAdd("registerAdmin", adminM.registerAdmin, {
    bodySizeLimit: 998, 
    argsSchema: {
        otc: STRINGHEX64, 
        secret: STRINGHEX64,
        timestamp: NUMBER,
        publicKey: STRINGHEX64,
        signature: STRINGHEX128
    }
})

sciAdd("removeAdminAccess", adminM.removeAdmin, {
    bodySizeLimit: 998, 
    authOption: adminM.signatureAuth,
    argsSchema: {
        action: "removeAccess"
        timestamp: NUMBER,
        publicKey: STRINGHEX64,
        signature: STRINGHEX128
    }
})

#endregion


############################################################ 
#region User Management
sciAdd("getUserList", usrM.getUserList, {
    bodySizeLimit: 568, 
    authOption: adminM.signatureAuth,
    resultSchema: ARRAY
})
#Response is always 200 containing an Array

############################################################
sciAdd("getUser", usrM.getUser, {
    bodySizeLimit: 600, 
    authOption: adminM.signatureAuth,
    argsSchema: STRINGHEX32
    resultSchema: {
        userId: STRINGHEX32,
        email: STRINGEMAIL, 
        subscribedUntil: NUMBER,
        isTester: BOOLEAN,
        lastInteraction: NUMBER
    }
})
#Response is either 200 with user data or '422 "User does not exist!"'



############################################################
sciAdd("updateUser", usrM.updateUser, {
    bodySizeLimit: 1_024,  
    authOption: adminM.signatureAuth,
    argsSchema: {
        userId: STRINGHEX32,
        email: STRINGEMAILORNOTHING, 
        subscribedUntil: NUMBERORNOTHING,
        isTester: BOOLEANORNOTHING
    }
})
# Response is either 204 or '422 "User does not exist!"'

############################################################
sciAdd("createUser", usrM.createUser, {
    bodySizeLimit: 1_220,
    authOption: adminM.signatureAuth
    argsSchema: {
        email: STRINGEMAIL, 
        passwordSH: STRINGHEX64
        subscribedUntil: NUMBERORNOTHING, 
        isTesterAccount: BOOLEANORNOTHING 
    }
    resultSchema: STRINGHEX32
})
# Response is either 200 with userId or '422  "Email already in use!"'

############################################################
sciAdd("deleteUser", usrM.deleteUser, {
    bodySizeLimit: 500 
    authOption: adminM.signatureAuth
    argsSchema: STRINGHEX32
})
# Response is always 204 

#endregion

#endregion

