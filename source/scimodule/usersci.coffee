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
import { login, register, passwordReset } from "./userauthmodule.js"

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
    bodySizeLimit: 348,
    argsSchema: {
        email: STRINGEMAIL,
        passwordSH: STRINGHEX64
    },
    resultSchema: { authCode: STRINGHEX64, validUntil: NUMBER }
})
# only 200 with certain payload - no expeted Errors

############################################################
sciAdd("register", register, {
    bodySizeLimit: 267, 
    argsSchema: STRINGEMAIL
})
# 204 on success - 422 on expected Error: email already in use

############################################################
sciAdd("requestPasswordReset", passwordReset, {
    bodySizeLimit: 267
    argsSchema: { email: STRINGEMAIL }
})
# always 204 - no expected errors :-)

#endregion
