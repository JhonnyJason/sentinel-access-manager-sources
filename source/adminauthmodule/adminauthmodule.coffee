############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("adminauthmodule")
#endregion


############################################################
export initialize = ->
    log "initialize"
    #Implement or Remove :-)
    return


############################################################
export signatureAuth = (req, ctx) ->
    log "signatureAuth"
    return

export addServerSignature = (result) ->
    log "addServerSignature"
    return
