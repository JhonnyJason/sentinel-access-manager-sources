import { addModulesToDebug } from "thingy-debug"

############################################################
modulesToDebug = {
    adminauthmodule: true
    accountsmodule: true
    usermanagementmodule: true
    # scicoremodule: true
    scimodule: true
    startupmodule: true
    userdatamodule: true

}

addModulesToDebug(modulesToDebug)
