############################################################
localCfg = Object.create(null)

############################################################
#region Read localCfg
import fs from "fs"
import path from "path"

############################################################
import * as bs from "./bugsnitch.js"

try
    ## local development
    configPath = path.resolve(process.cwd(), ".config.json")
    # configPath = path.resolve(process.cwd(), "../.config.json")
    localCfgString = fs.readFileSync(configPath, 'utf8')
    localCfg = JSON.parse(localCfgString)
catch err
    errorMessage = "@configmodule: localCfg could not be read or parsed!"
    errorMessage = "\n "+err.message
    bs.report(errorMessage)

#endregion

############################################################
export emailPassword = localCfg.emailPassword || "none"
export emailUsername = localCfg.emailUsername || "none"
export emailServer = localCfg.emailServer || "none"
export emailPort = localCfg.emailPort || 0


export urlSentinelDashboard = localCfg.urlSentinelDashboard || "https://sentinel-dashboard-dev.dotv.ee"
export urlSentinelPassword = localCfg.urlSentinelPassword || "https://sentinel-password-dev.dotv.ee"

export urlAdminDashboard = localCfg.urlAdminDashboard || "https://sentinel-admin.dotv.ee"

export urlSentinelBackend = localCfg.urlSentinelBackend || "https://sentinel-backend.dotv.ee"
export urlSentinelDatahub = localCfg.urlSentinelDatahub || "https://sentinel-datahub.dotv.ee"
export urlStripeService = localCfg.urlStripeService || "https://sentinel-datahub.dotv.ee"

export snitchSocket = localCfg.snitchSocket || "/run/bugsnitch.sk"

## local development
# export urlSentinelDashboard = localCfg.urlSentinelDashboard || "https://localhost:3002"
# export urlSentinelPassword = localCfg.urlSentinelPassword || "https://localhost:3000"

############################################################
export authCodeValidityMS = 7_200_000 # 2h
export actionLiveTimeMS = 600_000 # 10m

############################################################
export superAdmin = "suparmin"
export adminSalt = "eo9pbfr567890pl,+-.,ysw35tltwadh"

export jokerId = localCfg.jokerId || "3e8110543457d3b8e0b38912fd5c8f6ec995398f58243f75e8b89f20e4f06664"

############################################################
localCfg = null

############################################################
export name = "sentinel-access-manager"
export version = "v0.0.3"

############################################################
export persistentStateOptions = {
    basePath: "./state"
    maxCacheSize: 128
}
