import { addModulesToDebug } from "thingy-debug"

############################################################
modulesToDebug = {
    adminauthmodule: true
    userauthmodule: true
    rpcapimodule: true
    scimodule: true
    # startupmodule: true
    userdatamodule: true

}

addModulesToDebug(modulesToDebug)
