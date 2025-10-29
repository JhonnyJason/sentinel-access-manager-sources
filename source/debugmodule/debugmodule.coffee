import { addModulesToDebug } from "thingy-debug"

############################################################
modulesToDebug = {
    schemamodule: true
    authorizationmodule: true
    scimodule: true
    # startupmodule: true
    # userdatamodule: true

}

addModulesToDebug(modulesToDebug)
