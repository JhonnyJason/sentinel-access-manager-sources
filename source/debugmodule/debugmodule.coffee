import { addModulesToDebug } from "thingy-debug"

############################################################
modulesToDebug = {
    adminauthmodule: true
    adminaccess: true
    # accountsmodule: true
    # usermanagementmodule: true
    scicoremodule: true
    # scimodule: true
    sessionmodule: true
    # signencstoremodule: true
    # servicekeysmodule: true
    # startupmodule: true
    # userdatamodule: true
}

addModulesToDebug(modulesToDebug)
