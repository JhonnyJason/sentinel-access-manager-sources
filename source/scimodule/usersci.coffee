############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("usersci")
#endregion

############################################################
import {
    STRING, STRINGEMAIL, STRINGHEX64, STRINGHEX32, NUMBER, 
    ARRAY, BOOLEAN, STRINGCLEAN, STRINGHEX, NUMBERORNULL,
    STRINGEMAILORNOTHING, NUMBERORNOTHING, BOOLEANORNOTHING,
    createValidator
} from "thingy-schema-validate"

############################################################
import { sciAdd, setValidatorCreator } from "./scicoremodule.js"
setValidatorCreator(createValidator)

############################################################
import { 
    login, register, passwordReset, finalizeAction
} from "./accountsmodule.js"

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
#region User Functions

############################################################
sciAdd("login", login, {
    bodySizeLimit: 360,
    argsSchema: {
        email: STRINGEMAIL,
        passwordSH: STRINGHEX64
    },
    resultSchema: { authCode: STRINGHEX64, validUntil: NUMBER }
})
# 200 with payload - expected Error: Invalid credentials!

############################################################
sciAdd("register", register, {
    bodySizeLimit: 256, 
    argsSchema: STRINGEMAIL
})
# always 204 - don't give away if email exists ;-)

############################################################
sciAdd("requestPasswordReset", passwordReset, {
    bodySizeLimit: 256
    argsSchema: STRINGEMAIL
})
# always 204 - don't give away if email exists ;-)

############################################################
sciAdd("finalizeAction", finalizeAction, {
    bodySizeLimit: 360,
    argsSchema: { 
        code: STRINGHEX32, 
        type:STRING, 
        email: STRINGEMAIL, 
        passwordSH: STRINGHEX64 
    }
})
# 204 or 422 "Code was Invalid!" 

#endregion
