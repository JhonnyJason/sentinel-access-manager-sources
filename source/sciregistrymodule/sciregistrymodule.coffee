############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("sciregistrymodule")
#endregion

############################################################
sciRegistry = Object.create(null)

############################################################
export getRegistry = -> Object.freeze(sciRegistry)
export freeRegistry = -> sciRegistry = null

############################################################
export sciAdd = (route, func, conf) ->
    throw new Error("Route not a string!") unless typeof route == "string"
    throw new Error("Func not a function!") unless typeof func == "function"
    throw new Error("Cannot add route twice!") if sciRegistry[route]?
    throw new Error("function must be defined!") if !func?
    if !conf? or typeof conf != "object" then conf = {}
    sciRegistry[route] = { func, conf }
    return
