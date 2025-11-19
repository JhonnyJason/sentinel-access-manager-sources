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
    # configPath = path.resolve(process.cwd(), "./.config.json")
    configPath = path.resolve(process.cwd(), "../.config.json")
    localCfgString = fs.readFileSync(configPath, 'utf8')
    localCfg = JSON.parse(localCfgString)
catch err
    errorMessage = "@configmodule: localCfg could not be read or parsed!"
    errorMessage = "\n "+err.message
    bs.report(errorMessage)

#endregion

############################################################
export paypalId = localCfg.paypalId || "none"
export paypalKey = localCfg.paypalKey || "none"
export emailPassword = localCfg.emailPassword || "none"
export emailUsername = localCfg.emailUsername || "none"
export emailServer = localCfg.emailServer || "none"
export emailPort = localCfg.emailPort || 0
export urlSentinelDashboard = localCfg.urlSentinelDashboard || "https://sentinel-dashboard-dev.dotv.ee"
export urlSentinelPassword = localCfg.urlSentinelPassword || "https://sentinel-password-dev.dotv.ee"
export urlSentinelBackend = localCfg.urlSentinelBackend || "http://sentinel-backend.dotv.ee"
export snitchSocket = localCfg.snitchSocket || "/run/bugsnitch.sk"

## local development
# export urlSentinelDashboard = localCfg.urlSentinelDashboard || "https://localhost:3002"
# export urlSentinelPassword = localCfg.urlSentinelPassword || "https://localhost:3000"

############################################################
export authCodeValidityMS = 7_200_000 # 2h
export actionLiveTimeMS = 600_000 # 10m

############################################################
export persistentStateOptions = {
    basePath: "../state"
    maxCacheSize: 128
}
