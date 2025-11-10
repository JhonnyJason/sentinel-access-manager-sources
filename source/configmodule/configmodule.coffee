############################################################
localCfg = Object.create(null)
############################################################
#region Read localCfg
import fs from "fs"
import path from "path"

try
    configPath = path.resolve(process.cwd(), "./.config.json")
    localCfgString = fs.readFileSync(configPath, 'utf8')
    localCfg = JSON.parse(localCfgString)
catch err
    console.error("Local Config File could not be read or parsed!")
    console.error(err.message)

#endregion

############################################################
export paypalId = localCfg.paypalId || "none"
export paypalKey = localCfg.paypalKey || "none"
export emailPassword = localCfg.emailPassword || "none"
export emailUsername = localCfg.emailUsername || "none"
export emailServer = localCfg.emailServer || "none"
export emailPort = localCfg.emailPort || 0

############################################################
export authCodeValidityMS = 7200000

############################################################
export persistentStateOptions = {
    basePath: "../state"
    maxCacheSize: 128
}
