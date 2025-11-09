############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("samplesci")
#endregion

############################################################
import {
    STRING, STRINGCLEAN, createValidator
} from "thingy-schema-validate"

############################################################
import { sciAdd, setValidatorCreator } from "./scicoremodule.js"
setValidatorCreator(createValidator)

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
