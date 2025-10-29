############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("schemamodule")
#endregion

############################################################
## Notice: NUMBER validation
# Due to JSON limitations NaN and (-)Infinity are invalid
# This means that NUMBER type already excludes these values
# Previously we had FINITENUMBER and NONANNUMBER 
# These types are gone now :-)

############################################################
#region Schema Types and Functions
export STRING = 1
export STRINGEMAIL = 2 
export STRINGHEX = 3
export STRINGHEX32 = 4
export STRINGHEX64 = 5
export STRINGHEX128 = 6
export STRINGHEX256 = 7
export STRINGHEX512 = 8
export NUMBER = 9
export BOOLEAN = 10
export ARRAY = 11
export OBJECT = 12

export STRINGORNOTHING = 13
export STRINGEMAILORNOTHING = 14
export STRINGHEXORNOTHING = 15
export STRINGHEX32ORNOTHING = 16
export STRINGHEX64ORNOTHING = 17
export STRINGHEX128ORNOTHING = 18
export STRINGHEX256ORNOTHING = 19
export STRINGHEX512ORNOTHING = 20
export NUMBERORNOTHING = 21
export BOOLEANORNOTHING = 22
export ARRAYORNOTHING = 23
export OBJECTORNOTHING = 24

export STRINGORNULL = 25
export STRINGEMAILORNULL = 26
export STRINGHEXORNULL = 27
export STRINGHEX32ORNULL = 28
export STRINGHEX64ORNULL = 29
export STRINGHEX128ORNULL = 30
export STRINGHEX256ORNULL = 31
export STRINGHEX512ORNULL = 32
export NUMBERORNULL = 33
export BOOLEANORNULL = 34
export ARRAYORNULL = 35

export NONNULLOBJECT = 36
export NONEMPTYSTRING = 37
export NONEMPTYARRAY = 38
export NONEMPTYSTRINGHEX = 39
export NONEMPTYSTRINGCLEAN = 40
export STRINGCLEAN = 41
export STRINGCLEANORNULL = 42 
export STRINGCLEANORNOTHING = 43
export OBJECTCLEAN = 44
export NONNULLOBJECTCLEAN = 45
export OBJECTCLEANORNOTHING = 46

############################################################
typeValidationFunctions = new Array(47)
typeStringifyFunctions = new Array(47)

############################################################
#region basic typeValidationFunctions definitions
typeValidationFunctions[STRING] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    return

typeValidationFunctions[STRINGEMAIL] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length > 320 or arg.length < 5 then return INVALIDSIZE
    if invalidEmailSmallRegex.test(arg) then return INVALIDEMAIL
    # if arg.indexOf("..") >= 0 then return INVALIDEMAIL
    # if arg.indexOf("--") >= 0 then return INVALIDEMAIL
    # if arg.indexOf("-.") >= 0 then return INVALIDEMAIL
    # if arg.indexOf(".-") >= 0 then return INVALIDEMAIL

    atPos = arg.indexOf("@")
    
    if atPos <= 0 or atPos > 64 or (arg.length - atPos) < 4 or 
    arg[0] == "." or arg[atPos - 1] == "." or arg[0] == "-" or 
    arg[atPos - 1] == "-" or arg[atPos + 1] == "." or 
    arg[atPos + 1] == "-" 
        return INVALIDEMAIL
    
    # if atPos <= 0 then return INVALIDEMAIL
    # if atPos > 64 then return INVALIDEMAIL
    # if arg[0] == "." or arg[atPos - 1] == "." then return INVALIDEMAIL
    # if arg[0] == "-" or arg[atPos - 1] == "-" then return INVALIDEMAIL
    # if arg[atPos + 1] == "." or arg[atPos + 1] == "-" then return INVALIDEMAIL
    
    for c,i in arg
        if !(domainCharMap[c] or i == atPos or
            (i < atPos and (c == "+" or c == "_"))
            ) then return INVALIDEMAIL
    
    if arg[arg.length - 1] == "." or arg[arg.length - 1] == "-"
        return INVALIDEMAIL 

    lastPos = atPos
    dotPos = arg.indexOf(".", atPos + 1)
    if dotPos < 0 then return INVALIDEMAIL
    
    while (dotPos > 0)
        if (dotPos - lastPos) > 63 then return INVALIDEMAIL
        lastPos = dotPos
        dotPos = arg.indexOf(".", lastPos + 1)
    
    tld = arg.slice(lastPos + 1)
    if numericOnlyRegex.test(tld) then return INVALIDEMAIL
    return

typeValidationFunctions[STRINGHEX] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX32] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 32 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX64] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 64 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX128] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 128 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX256] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 256 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX512] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 512 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[NUMBER] = (arg) ->
    if typeof arg != "number" then return NOTANUMBER
    if arg == NaN then return ISNAN 
    if arg == Infinity or arg == -Infinity then return ISNOTFINITE
    return

typeValidationFunctions[BOOLEAN] = (arg) ->
    if typeof arg != "boolean" then return NOTABOOLEAN
    return

typeValidationFunctions[ARRAY] = (arg) ->
    if !Array.isArray(arg) then return NOTANARRAY
    return

typeValidationFunctions[OBJECT] = (arg) ->
    if typeof arg != "object" then return NOTANOBJECT
    return

typeValidationFunctions[STRINGORNOTHING] = (arg) ->
    return if arg == undefined 
    if typeof arg != "string" then return NOTASTRING
    return

typeValidationFunctions[STRINGEMAILORNOTHING] = (arg) ->
    return if arg == undefined 
    if typeof arg != "string" then return NOTASTRING
    
    if arg.length > 320 or arg.length < 5 then return INVALIDSIZE
    if invalidEmailSmallRegex.test(arg) then return INVALIDEMAIL
    # if arg.indexOf("..") >= 0 then return INVALIDEMAIL
    # if arg.indexOf("--") >= 0 then return INVALIDEMAIL
    # if arg.indexOf("-.") >= 0 then return INVALIDEMAIL
    # if arg.indexOf(".-") >= 0 then return INVALIDEMAIL

    atPos = arg.indexOf("@")
    
    if atPos <= 0 or atPos > 64 or (arg.length - atPos) < 4 or 
    arg[0] == "." or arg[atPos - 1] == "." or arg[0] == "-" or 
    arg[atPos - 1] == "-" or arg[atPos + 1] == "." or 
    arg[atPos + 1] == "-" 
        return INVALIDEMAIL
    
    # if atPos <= 0 then return INVALIDEMAIL
    # if atPos > 64 then return INVALIDEMAIL
    # if arg[0] == "." or arg[atPos - 1] == "." then return INVALIDEMAIL
    # if arg[0] == "-" or arg[atPos - 1] == "-" then return INVALIDEMAIL
    # if arg[atPos + 1] == "." or arg[atPos + 1] == "-" then return INVALIDEMAIL
    
    for c,i in arg 
        if !(domainCharMap[c] or i == atPos or
            (i < atPos and (c == "+" or c == "_"))
            ) then return INVALIDEMAIL
    
    if arg[arg.length - 1] == "." or arg[arg.length - 1] == "-"
        return INVALIDEMAIL 

    lastPos = atPos
    dotPos = arg.indexOf(".", atPos + 1)
    if dotPos < 0 then return INVALIDEMAIL
    
    while (dotPos > 0)
        if (dotPos - lastPos) > 63 then return INVALIDEMAIL
        lastPos = dotPos
        dotPos = arg.indexOf(".", lastPos + 1)
    
    tld = arg.slice(lastPos + 1)
    if numericOnlyRegex.test(tld) then return INVALIDEMAIL
    return

typeValidationFunctions[STRINGHEXORNOTHING] = (arg) ->
    return if arg == undefined
    if typeof arg != "string" then return NOTASTRING
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX32ORNOTHING] = (arg) ->
    return if arg == undefined
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 32 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX64ORNOTHING] = (arg) ->
    return if arg == undefined
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 64 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX128ORNOTHING] = (arg) ->
    return if arg == undefined
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 128 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX256ORNOTHING] = (arg) ->
    return if arg == undefined 
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 256 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX512ORNOTHING] = (arg) ->
    return if arg == undefined 
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 512 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[NUMBERORNOTHING] = (arg) ->
    return if arg == undefined 
    if typeof arg != "number" then return NOTANUMBER
    if arg == NaN then return ISNAN 
    if arg == Infinity or arg == -Infinity then return ISNOTFINITE
    return

typeValidationFunctions[BOOLEANORNOTHING] = (arg) ->
    return if arg == undefined 
    if typeof arg != "boolean" then return NOTABOOLEAN
    return

typeValidationFunctions[ARRAYORNOTHING] = (arg) ->
    return if arg == undefined 
    if !Array.isArray(arg) then return NOTANARRAY
    return

typeValidationFunctions[OBJECTORNOTHING] = (arg) ->
    return if arg == undefined
    if typeof arg != "object" then return NOTANOBJECT
    return

typeValidationFunctions[STRINGORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    return

typeValidationFunctions[STRINGEMAILORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    if arg.length > 320 or arg.length < 5 then return INVALIDSIZE
    if invalidEmailSmallRegex.test(arg) then return INVALIDEMAIL
    # if arg.indexOf("..") >= 0 then return INVALIDEMAIL
    # if arg.indexOf("--") >= 0 then return INVALIDEMAIL
    # if arg.indexOf("-.") >= 0 then return INVALIDEMAIL
    # if arg.indexOf(".-") >= 0 then return INVALIDEMAIL

    atPos = arg.indexOf("@")
    
    if atPos <= 0 or atPos > 64 or (arg.length - atPos) < 4 or
    arg[0] == "." or arg[atPos - 1] == "." or arg[0] == "-" or 
    arg[atPos - 1] == "-" or arg[atPos + 1] == "." or 
    arg[atPos + 1] == "-"
        return INVALIDEMAIL
    
    # if atPos <= 0 then return INVALIDEMAIL
    # if atPos > 64 then return INVALIDEMAIL
    # if arg[0] == "." or arg[atPos - 1] == "." then return INVALIDEMAIL
    # if arg[0] == "-" or arg[atPos - 1] == "-" then return INVALIDEMAIL
    # if arg[atPos + 1] == "." or arg[atPos + 1] == "-" then return INVALIDEMAIL
    
    for c,i in arg 
        if !(domainCharMap[c] or i == atPos or
            (i < atPos and (c == "+" or c == "_"))
            ) then return INVALIDEMAIL
    
    if arg[arg.length - 1] == "." or arg[arg.length - 1] == "-"
        return INVALIDEMAIL 

    lastPos = atPos
    dotPos = arg.indexOf(".", atPos + 1)
    if dotPos < 0 then return INVALIDEMAIL
    
    while (dotPos > 0)
        if (dotPos - lastPos) > 63 then return INVALIDEMAIL
        lastPos = dotPos
        dotPos = arg.indexOf(".", lastPos + 1)
    
    tld = arg.slice(lastPos + 1)
    if numericOnlyRegex.test(tld) then return INVALIDEMAIL
    return

typeValidationFunctions[STRINGHEXORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX32ORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 32 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX64ORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 64 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX128ORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 128 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX256ORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 256 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[STRINGHEX512ORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    if arg.length != 512 then return INVALIDSIZE
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[NUMBERORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "number" then return NOTANUMBER
    if arg == NaN then return ISNAN 
    if arg == Infinity or arg == -Infinity then return ISNOTFINITE
    return

typeValidationFunctions[BOOLEANORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "boolean" then return NOTABOOLEAN
    return

typeValidationFunctions[ARRAYORNULL] = (arg) ->
    return if arg == null
    if !Array.isArray(arg) then return NOTANARRAY
    return

typeValidationFunctions[NONNULLOBJECT] = (arg) ->
    if typeof arg != "object" then return NOTANOBJECT
    if arg == null then return ISNULL
    return

typeValidationFunctions[NONEMPTYSTRING] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length == 0 then return ISEMPTYSTRING
    return

typeValidationFunctions[NONEMPTYARRAY] = (arg) ->
    if !Array.isArray(arg) then return NOTANARRAY
    if arg.length == 0 then return ISEMPTYARRAY
    return

typeValidationFunctions[NONEMPTYSTRINGHEX] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length == 0 then return ISEMPTYSTRING
    for c in arg when !hexMap[c] then return INVALIDHEX
    return

typeValidationFunctions[NONEMPTYSTRINGCLEAN] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    if arg.length == 0 then return ISEMPTYSTRING
    for c in arg when dirtyCharMap[c] then return ISDIRTYSTRING
    return

typeValidationFunctions[STRINGCLEAN] = (arg) ->
    if typeof arg != "string" then return NOTASTRING
    for c in arg when dirtyCharMap[c] then return ISDIRTYSTRING
    return

typeValidationFunctions[STRINGCLEANORNULL] = (arg) ->
    return if arg == null
    if typeof arg != "string" then return NOTASTRING
    for c in arg when dirtyCharMap[c] then return ISDIRTYSTRING
    return

typeValidationFunctions[STRINGCLEANORNOTHING] = (arg) ->
    return if arg == undefined
    if typeof arg != "string" then return NOTASTRING
    for c in arg when dirtyCharMap[c] then return ISDIRTYSTRING
    return

typeValidationFunctions[OBJECTCLEAN] = (arg) ->
    if typeof arg != "object" then return NOTANOBJECT
    if isDirtyObject(arg) then return ISDIRTYOBJECT
    return

typeValidationFunctions[NONNULLOBJECTCLEAN] = (arg) ->
    if typeof arg != "object" then return NOTANOBJECT
    if arg == null then return ISNULL
    if isDirtyObject(arg) then return ISDIRTYOBJECT
    return

typeValidationFunctions[OBJECTCLEANORNOTHING] = (arg) ->
    return if arg == undefined
    if typeof arg != "object" then return NOTANOBJECT
    if isDirtyObject(arg) then return ISDIRTYOBJECT
    return

#endregion

############################################################
## raw type stringify 
booleanStringify = (arg) -> 
    if arg  then return 'true' else return 'false'
booleanOrNothingStringify = (arg) ->
    return arg if arg == undefined 
    if arg then return 'true'  else return 'false'
booleanOrNullStringify = (arg) ->
    return 'null' if arg == null
    if arg then return 'true' else return 'false'
numberStringify = (arg) -> ''+arg
numberOrNothingStringify = (arg) -> 
    if arg == undefined then return arg else return ''+arg
numberOrNullStringify = (arg) -> 
    if arg == null then return 'null' else return ''+arg
stringStringify = (arg) -> '"'+arg+'"'
stringOrNothingStringify = (arg) ->
    if arg == undefined then return arg else return '"'+arg+'"'
stringOrNullStringify = (arg) ->
    if arg == null then return 'null' else return '"'+arg+'"'
objectStringify = JSON.stringify
objectOrNothingStringify = (arg) -> 
    if arg == undefined then return arg else return JSON.stringify(arg)

############################################################
#region basic typeStringifyFunction definitions
typeStringifyFunctions[STRING] = stringStringify
typeStringifyFunctions[STRINGEMAIL] = stringStringify
typeStringifyFunctions[STRINGHEX] = stringStringify
typeStringifyFunctions[STRINGHEX32] = stringStringify
typeStringifyFunctions[STRINGHEX64] = stringStringify
typeStringifyFunctions[STRINGHEX128] = stringStringify
typeStringifyFunctions[STRINGHEX256] = stringStringify
typeStringifyFunctions[STRINGHEX512] = stringStringify
typeStringifyFunctions[NUMBER] = numberStringify
typeStringifyFunctions[BOOLEAN] = booleanStringify
typeStringifyFunctions[ARRAY] = objectStringify
typeStringifyFunctions[OBJECT] = objectStringify
typeStringifyFunctions[STRINGORNOTHING] = stringOrNothingStringify
typeStringifyFunctions[STRINGEMAILORNOTHING] = stringOrNothingStringify
typeStringifyFunctions[STRINGHEXORNOTHING] = stringOrNothingStringify
typeStringifyFunctions[STRINGHEX32ORNOTHING] = stringOrNothingStringify
typeStringifyFunctions[STRINGHEX64ORNOTHING] = stringOrNothingStringify
typeStringifyFunctions[STRINGHEX128ORNOTHING] = stringOrNothingStringify
typeStringifyFunctions[STRINGHEX256ORNOTHING] = stringOrNothingStringify
typeStringifyFunctions[STRINGHEX512ORNOTHING] = stringOrNothingStringify
typeStringifyFunctions[NUMBERORNOTHING] = numberOrNothingStringify
typeStringifyFunctions[BOOLEANORNOTHING] = booleanOrNothingStringify
typeStringifyFunctions[ARRAYORNOTHING] = objectOrNothingStringify
typeStringifyFunctions[OBJECTORNOTHING] = objectOrNothingStringify
typeStringifyFunctions[STRINGORNULL] = stringOrNullStringify
typeStringifyFunctions[STRINGEMAILORNULL] = stringOrNullStringify
typeStringifyFunctions[STRINGHEXORNULL] = stringOrNullStringify
typeStringifyFunctions[STRINGHEX32ORNULL] = stringOrNullStringify
typeStringifyFunctions[STRINGHEX64ORNULL] = stringOrNullStringify
typeStringifyFunctions[STRINGHEX128ORNULL] = stringOrNullStringify
typeStringifyFunctions[STRINGHEX256ORNULL] = stringOrNullStringify
typeStringifyFunctions[STRINGHEX512ORNULL] = stringOrNullStringify
typeStringifyFunctions[NUMBERORNULL] = numberOrNullStringify
typeStringifyFunctions[BOOLEANORNULL] = booleanOrNullStringify
typeStringifyFunctions[ARRAYORNULL] = objectStringify
typeStringifyFunctions[NONNULLOBJECT] =  objectStringify 
typeStringifyFunctions[NONEMPTYSTRING] = stringStringify
typeStringifyFunctions[NONEMPTYARRAY] = objectStringify
typeStringifyFunctions[NONEMPTYSTRINGHEX] = stringStringify
typeStringifyFunctions[NONEMPTYSTRINGCLEAN] = stringStringify
typeStringifyFunctions[STRINGCLEAN] = stringStringify
typeStringifyFunctions[STRINGCLEANORNULL] = stringStringify
typeStringifyFunctions[STRINGCLEANORNOTHING] = stringStringify
typeStringifyFunctions[OBJECTCLEAN] = objectStringify
typeStringifyFunctions[NONNULLOBJECTCLEAN] = objectStringify
typeStringifyFunctions[OBJECTCLEANORNOTHING] = objectStringify

#endregion

#endregion

############################################################
#region Error Codes
export NOTASTRING = 1001
export NOTANUMBER = 1002
export NOTABOOLEAN = 1003
export NOTANARRAY = 1004
export NOTANOBJECT = 1005

export INVALIDHEX = 1006
export INVALIDEMAIL = 1007
export INVALIDSIZE = 1008

export ISNAN = 1009
export ISNULL = 1010
export ISEMPTYSTRING = 1011
export ISEMPTYARRAY = 1012

export ISDIRTYSTRING = 1013
export ISDIRTYOBJECT = 1014
export ISNOTFINITE = 1015


export ISINVALID = 2222

############################################################
# NonError Code -> anything falsly is success often return void
export VALID = 0

############################################################
ErrorToMessage = Object.create(null)

ErrorToMessage[NOTASTRING] = "Not a String!"
ErrorToMessage[NOTANUMBER] = "Not a Number!"
ErrorToMessage[NOTABOOLEAN] = "Not a Boolean!"
ErrorToMessage[NOTANARRAY] = "Not an Array!"
ErrorToMessage[NOTANOBJECT] = "Not an Object!"
ErrorToMessage[INVALIDHEX] = "String is not valid hex!"
ErrorToMessage[INVALIDEMAIL] = "String is not a valid email!"
ErrorToMessage[INVALIDSIZE] = "String size mismatch!"
ErrorToMessage[ISNAN] = "Number is NaN!"
ErrorToMessage[ISNULL] = "Object is null!"
ErrorToMessage[ISEMPTYSTRING] = "String is empty!"
ErrorToMessage[ISEMPTYARRAY] = "Array is empty!"
ErrorToMessage[ISDIRTYSTRING] = "String is dirty!"
ErrorToMessage[ISDIRTYOBJECT] = "Object is dirty!"
ErrorToMessage[ISNOTFINITE] = "Number is infinity!"
ErrorToMessage[ISINVALID] = "Schema is invalid!"
#endregion

############################################################
#region Helpers
############################################################
isDirtyObject = (obj) ->
    return if obj == null
    ## as the inputs come from an object which was originalled paref from a JSON string we assume to not fall into an infinite loop
    keys = Object.keys(obj)
    for k in keys
        if k == "__proto__" or k == "constructor" or k == "prototype"
            return true
        if typeof obj[k] == "object"
            return true if isDirtyObject(obj[k])
    return false

############################################################
stringVerificationFunction = (str) ->
    return (arg) ->
        if arg != str then return ISINVALID
        return

############################################################
stringifyFunction = (type) ->
    fun = typeStringifyFunctions[type]
    if !fun? then throw new Error("Unrecognized Schematype! (#{type})")
    return fun

############################################################
validationFunction = (type) ->
    fun = typeValidationFunctions[type]
    if !fun? then throw new Error("Unrecognized Schematype! (#{type})")
    return fun

############################################################
createValidationFunctionForArray = (arr) ->
    if arr.length ==  0 then throw new Error("[] is illegal!")
    funcs = getValidationFunctionsForArray(arr)
    # olog valEntries
    
    func = (arg) ->
        if !Array.isArray(arg) then return ISINVALID
        hits = 0
        for f,i in funcs
            el = arg[i]
            if el? then hits++
            err = f(el)
            if err then return err
        
        if arg.length > hits then return ISINVALID
        return

    return func

createValidationFunctionForObject = (obj) ->
    # Obj is Schema Obj like obj = { prop1:STRING, prop2:NUMBER,... }
    if obj == null then throw new Error("null is illegal!")
    valEntries = getValidationEntriesForObject(obj)
    # olog valEntries
    if valEntries.length == 0 then throw new Error("{} is illegal!")
    
    func = (arg) ->
        # log "validating Object!"
        # olog arg
        if typeof arg != "object" then return ISINVALID
        if arg == null then return ISINVALID
        hits = 0
        for e in valEntries
            # olog e
            prop = arg[e[0]]
            if prop? then hits++
            err = e[1](prop)
            if err then return err
        
        keys = Object.keys(arg)
        if keys.length > hits then return ISINVALID
        # log "is valid!"
        return

    return func

############################################################
getValidationFunctionsForArray = (arr) ->
    funcs = new Array(arr.length)
    
    for el,i in arr
        switch
            when typeof el == "number" then funcs[i] = validationFunction(el)
            when typeof el == "string" then funcs[i] = onString(el)
            when typeof el != "object" then throw new Error("Illegal #{typeof el}!")
            when Array.isArray(el) 
                funcs[i] = createValidationFunctionForArray(el)
            else funcs[i] = createValidationFunctionForObject(el)

    return funcs

getValidationEntriesForObject = (obj) ->
    keys = Object.keys(obj)
    valEntries = []
    
    for k,i in keys
        prop = obj[k]
        if typeof prop == "number"
            valEntries.push([k, validationFunction(prop)])
            continue
        if typeof prop == "string"
            valEntries.push([k, onString(prop)])
            continue
        if typeof prop != "object" then throw new Error("Illegal #{typeof prop}!")
        if Array.isArray(prop)
            valFunc = createValidationFunctionForArray(prop)
            valEntries.push([k, valFunc])
        else 
            valFunc = createValidationFunctionForObject(prop)
            valEntries.push([k, valFunc])

    return valEntries

############################################################
createStringifyFunctionForArray = (arr) ->
    stringifyFunctions = getStringifyFunctionsForArray(arr)
    bufLen = stringifyFunctions.length
    buffer = new Array(bufLen)

    func = (arg) ->
        ## stringify contents with predefined functions
        buffer[i] = f(arg[i]) for f,i in stringifyFunctions

        ## cut off undefined tail
        while (buffer[buffer.length - 1] == undefined and buffer.length != 0)
            buffer.pop()

        ## fast return on no content
        if buffer.length == 0
            buffer.length = bufLen # restore original size
            return '[]' 

        # undefined within the array turns to 'null'
        for s,i in buffer when s == undefined
            buffer[i] = 'null'

        str = '['+ buffer[0]
        i = 1
        str += ','+buffer[i++] while(i < buffer.length)
        
        buffer.length = bufLen # restore original size
        str += ']'
        return str 

    return func

createStringifyFunctionForObject = (obj) ->
    sfEntries = getStringifyFunctionsForObject(obj) # stringify function entries
    bufLen = sfEntries.length
    buffer = new Array(bufLen)

    func = (arg) ->
        buffer[i] = el[1](arg[el[0]]) for el,i in sfEntries 

        # log "0"
        str = '{'
        i = 0
        
        while str.length == 1 and i < bufLen 
            str += '"'+sfEntries[i][0]+'":'+buffer[i] if buffer[i]?
            i++
        
        # log "1"
        while i < bufLen
            str += ',"'+sfEntries[i][0]+'":'+buffer[i] if buffer[i]?
            i++

        # log "2"
        str += '}'
        return str

    return func

############################################################
getStringifyFunctionsForArray = (arr) ->
    sfs = new Array(arr.length) ## stringify functions
    
    for el,i in arr
        type = typeof el
        if type == "number" then sfs[i] = stringifyFunction(el)
        if type == "string" then sfs[i] = stringifyFunction(STRING)
        if type != "object" then continue
        if Array.isArray(el) then sfs[i] = createStringifyFunctionForArray(el)
        else sfs[i] = createStringifyFunctionForObject(el)

    return sfs

getStringifyFunctionsForObject = (obj) ->
    keys = Object.keys(obj)
    sfes = new Array(keys.length) # stringify function entries 
    
    for k,i in keys
        prop = obj[k]
        type = typeof prop
        if type == "number" then sfes[i] = [k, stringifyFunction(prop)]
        if type == "string" then sfes[i] = [k, stringifyFunction(STRING)]
        if type != "object" then continue
        if Array.isArray(prop)
            sfes[i] = [k, createStringifyFunctionForArray(prop)] 
        else sfes[i] = [k, createStringifyFunctionForObject(prop)] 

    return sfes


#endregion

############################################################
#region local Variables
onString = null
locked = false

############################################################
numericOnlyRegex = /^\d+$/
invalidEmailSmallRegex = /(\.\.|--|-\.)|\.-/

############################################################
hexChars = "0123456789abcdefABCDEF"
hexMap = Object.create(null)
hexMap[c] = true for c in hexChars
# Object.freeze(hexMap)

############################################################
domainChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-."
domainCharMap = Object.create(null)
domainCharMap[c] = true for c in domainChars
# Object.freeze(domainCharMap)

############################################################
dirtyChars = "\x00\x01\x02\x03\x04\x05\x06\x07\x08" +  # ASCII control 0–8
    "\x0B\x0C" + # vertical tab, form feed
    "\x0E\x0F\x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F" + # rest of controls
    "\x7F" +                                  # DEL
    "\u00A0" +                                # non-breaking space
    "\u1680" +                                # ogham space mark
    "\u180E" +                                # mongolian vowel separator
    "\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200A" + # en/em/etc. spaces
    "\u200B\u200C\u200D\u200E\u200F" +        # zero-width spaces, joiners, directional
    "\u2028\u2029" +                          # line/paragraph separators
    "\u202A\u202B\u202C\u202D\u202E" +        # embedding/override control
    "\u2060\u2061\u2062\u2063\u2064\u2066\u2067\u2068\u2069" + # invisible controls
    "\u3000" +                                # ideographic space
    "\uFEFF"; 
dirtyCharMap = Object.create(null)
dirtyCharMap[c] = true for c in dirtyChars
# Object.freeze(dirtyCharMap)

#endregion

############################################################
export createStringifyFunction = (schema) ->
    type = typeof schema

    if type == "number" then return stringifyFunction(schema) 
    if type == "string" then return stringifyFunction(STRING)
    if Array.isArray(schema) then return createStringifyFunctionForArray(schema)
    else return createStringifyFunctionForObject(schema)

############################################################
export createValidationFunction = (schema, staticStrings) ->
    
    if staticStrings then onString = stringVerificationFunction
    else onString = (schema) -> throw new Error("Illegal string!")

    type = typeof schema

    if type == "number" then return validationFunction(schema)
    if type == "string" then return onString(schema)
    if type != "object" then throw new Error("Illegal #{typeof schema}!")
    if Array.isArray(schema) then return createValidationFunctionForArray(schema)
    else return createValidationFunctionForObject(schema)

############################################################
export errorMessageFor = (errorCode) ->
    msg = ErrorToMessage[errorCode]
    if typeof msg != "string" then return ""
    else return msg

############################################################
export addType = (validatorFunc, stringifyFunc) ->
    log "addType not implemented yet!"
    if locked then throw new Error("We are closed!")    
    newTypeId = typeValidationFunctions.length
    if newTypeId >= 1000 then throw new Error("Exeeding type limit!")
    typeValidationFunctions[newTypeId] = validatorFunc
    typeStringifyFunctions[newTypeId] = stringifyFunc
    return newTypeId

export addError = (errorCode, errorMessage) ->
    log "addError"
    if locked then throw new Error("We are closed!")    
    if typeof errorCode != "number" then throw new Error("Code not a Number!")
    if errorCode < 1000 or errorCode >= 2000 then throw new Error("Invalid code!")
    if typeof errorMessage != "string" then throw new Error("Message not a String!")
    if ErrorToMessage[errorCode]? then throw new Error("Already exists!")
    ErrorToMessage[errorCode] = errorMessage
    return

############################################################
export overwriteType = (type, valiatorFunc, stringifyFunc) ->
    log "overwriteType not implemented yet!"
    if locked then throw new Error("We are closed!")    
    if type >= typeValidationFunctions.length then throw new Error("Does not exist!")
    typeValidationFunctions[type] = validatorFunc
    return 

############################################################
export lock = ->
    log "lock"
    locked = true
    Object.freeze(typeValidationFunctions)
    Object.freeze(typeStringifyFunctions)
    Object.freeze(ErrorToMessage)
    return

############################################################
#region testing
export initialize = ->
    log "initialize"
    
    for s,i in testSchemas
        try validate = createValidationFunction(s, true)
        catch err then log "@#{i} createValidationFunction failed!\n#{err.message}"
        try stringify = createStringifyFunction(s)
        catch err then log "@#{i} createStringifyFunction failed!\n#{err.message}"
        try
            o = testObjects[i]
            err = validate(o)
            if err then log "@#{i}: validation failed!"
            else log "@#{i}: validation succeeded!"
            jsonString = JSON.stringify(o)
            ownString = null
            ownString = stringify(o)
            log "jsonString: #{jsonString}"
            log "ownString: #{ownString}"
        catch err then log "@#{i}Testing failed!\n#{err.message}"
        if!ownString? then log stringify.toString()

    #region Plain Type  = OK
    # sampleSchema = NONNULLOBJECT
    # validObj = {}
    # invalidObj = null
    #endregion

    #region Object Level 1 = OK
    # sampleSchema = {
    #     email: STRINGEMAIL,
    #     passwordH: STRINGHEX64,
    #     timestamp: NUMBER
    # }
    # validObj = {
    #     email: "jhonny@jason.jo"
    #     passwordH: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    #     timestamp: 1
    # }
    # invalidObj = {
    #     email: "wrong@really.11"
    #     passwordH: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    #     timestamp: 3
    # }
    # sampleSchema = {
    #     email: "myEmail@me.me",
    #     passwordH: STRINGHEX64,
    #     timestamp: NUMBER
    # }
    # validObj = {
    #     email: "myEmail@me.me"
    #     passwordH: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
    #     timestamp: 1
    # }
    # invalidObj = {
    #     email: "wrong@really.11"
    #     passwordH: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    #     timestamp: 3
    # }

    #endregion
    
    #region Array Level 1 = OK
    # sampleSchema = [ NUMBER, NUMBER, NUMBER, NUMBER, NUMBERORNOTHING ]

    # validObj = [ 10, 0.1, 51, NaN, Infinity ]
    # validObj = [ 10, 0.1, 51, NaN ]
    
    # invalidObj = [ 10, 0.1, 51, NaN, 31, 33, 25 ]

    #endregion

    #region Object Level 2
    # sampleSchema = {
    #     email: STRINGEMAIL,
    #     auth: {
    #         signature: STRINGHEX64
    #         passwordH: STRINGHEX64
    #         timestamp: NUMBER
    #         none: NUMBERORNOTHING
    #     }
    # }
    # validObj = {
    #     email: "myEmail@me.me"
    #     auth: {
    #         signature: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    #         passwordH: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    #         timestamp: 1
    #     }
    # }
    # validObj = {
    #     email: "myEmail@me.me"
    #     auth: {
    #         signature: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    #         passwordH: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    #         timestamp: 0
    #         none: 12
    #     }
    # }

    # invalidObj = {
    #     email: "myEmail@me.me"
    #     auth: {
    #         signature: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    #         passwordH: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    #         timestamp: 0
    #         none: ""
    #     }
    # }
    # invalidObj = {
    #     email: "myEmail@me.me"
    #     auth: {
    #         signature: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    #         passwordH: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    #         none: 12
    #     }
    # }
    # invalidObj = {
    #     email: "myEmail@me.me"
    #     auth: {
    #         signature: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    #         passwordH: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    #         timestamp: 4
    #         none: 12
    #     }
    # }
    # invalidObj = {
    #     email: "myEmail@me.me"
    #     auth: {
    #         signature: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    #         passwordH: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    #         timestamp: 0
    #         none: 12
    #         corrupt: true
    #     }
    # }


    #endregion

    #region Array Level 2 = OK
    # sampleSchema = {
    #     last5or4: [
    #         NUMBER,
    #         NUMBER,
    #         NUMBER,
    #         NUMBER,
    #         NUMBERORNOTHING
    #     ]
    # }
    # validObj = {
    #     last5or4: [
    #         10,
    #         0.1,
    #         51,
    #         NaN,
    #         Infinity
    #     ]
    # }
    # validObj = {
    #     last5or4: [
    #         10,
    #         0.1,
    #         51,
    #         NaN
    #     ]
    # }
    # invalidObj = { # too few entries
    #     last5or4: [
    #         10,
    #         0.1,
    #         51
    #     ]
    # }
    # invalidObj = { # too many entries
    #     last5or4: [
    #         10,
    #         0.1,
    #         51,
    #         NaN,
    #         Infinity,
    #         NaN
    #     ]
    # }

    # sampleSchema = [
    #     [ NUMBER, NUMBER, NUMBER, NUMBER ]
    # ]
    # validObj = [
    #     [ 10, 0.1, 51, NaN ]
    # ]
    # invalidObj = [
    #     [ 10, 0.1, 51, "" ]
    # ]
    
    #endregion

    #region Object Level 3
    #endregion

    #region Array Level 3
    #endregion

    # try val = createValidationFunction(sampleSchema)
    # catch err
    #     log err # probably it was a constant String in the Schema
    #     val = createValidationFunction(sampleSchema, true)

    # log val.toString() 
    # er = val(validObj)
    # log "validObj returned #{er}"
    # er = val(invalidObj)
    # log "invalidObj returned #{er}:#{ErrorToMessage[er]}"

    # return
    # console.log(val.toString())

    # er = val(validObj)
    # log "valid returned #{er}"
    # er = val(invalidObj)
    # log "invalid returned #{er}:#{ErrorToMessage[er]}"

    # check("STRING") # 100% success
    # check("STRINGEMAIL") # 100% success
    # check("STRINGHEX") # 100% success
    # check("STRINGHEX32") # 100% success
    # check("STRINGHEX64") # 100% success
    # check("STRINGHEX128") # 100% success
    # check("STRINGHEX256") # 100% success
    # check("STRINGHEX512") # 100% success
    # check("NUMBER") # 100% succcess
    # check("BOOLEAN") # 100% success
    # check("ARRAY") # 100% success
    # check("OBJECT") # 100% success
    # check("STRINGORNOTHING") # 100% success
    # check("STRINGEMAILORNOTHING") # 100% success
    # check("STRINGHEXORNOTHING") # 100% success
    # check("STRINGHEX32ORNOTHING") # 100% success
    # check("STRINGHEX64ORNOTHING") # 100% success
    # check("STRINGHEX128ORNOTHING") # 100% success
    # check("STRINGHEX256ORNOTHING") # 100% success
    # check("STRINGHEX512ORNOTHING") # 100% success
    # check("NUMBERORNOTHING") # 100% success
    # check("BOOLEANORNOTHING") # 100% success
    # check("ARRAYORNOTHING") # 100% success
    # check("OBJECTORNOTHING") # 100% success
    # check("STRINGORNULL") # 100% success
    # check("STRINGEMAILORNULL") # 100% success
    # check("STRINGHEXORNULL") # 100% success
    # check("STRINGHEX32ORNULL") # 100% success
    # check("STRINGHEX64ORNULL") # 100% success
    # check("STRINGHEX128ORNULL") # 100% success
    # check("STRINGHEX256ORNULL") # 100% success
    # check("STRINGHEX512ORNULL") # 100% success
    # check("NUMBERORNULL") # 100% success
    # check("BOOLEANORNULL") # 100% success
    # check("ARRAYORNULL") # 100% success
    # check("NONNULLOBJECT") # 100% success
    # check("NONEMPTYSTRING") # 100% success
    # check("NONEMPTYARRAY") # 100% success
    # check("NONEMPTYSTRINGHEX") # 100% success
    # check("NONEMPTYSTRINGCLEAN") # 100% success
    # check("STRINGCLEAN") # 100% success 
    # check("STRINGCLEANORNULL") # 100% success
    # check("STRINGCLEANORNOTHING") # 100% success
    # check("OBJECTCLEAN") # 100% success
    # check("NONNULLOBJECTCLEAN") # 100% success
    # check("OBJECTCLEANORNOTHING") # 100% success
    return

############################################################
check = (key) ->
    success = 0
    failedCases = []
    for test,i in tO[key]
        arg = test[0]
        er = typeValidationFunctions[tMap[key]](arg)
        if er and !test[1] then success++
        if !er and !test[1] then failedCases.push(i)
        if er and test[1] then failedCases.push(i)
        if !er and test[1] then success++

    log "Checked #{key}:"
    log "    #{success} successes"
    log "    #{failedCases.length} fails"
    log failedCases
    log " "

############################################################
#region typeMap
tMap = Object.create(null)
tMap["STRING"] = STRING
tMap["STRINGEMAIL"] = STRINGEMAIL
tMap["STRINGHEX"] = STRINGHEX 
tMap["STRINGHEX32"] = STRINGHEX32 
tMap["STRINGHEX64"] = STRINGHEX64 
tMap["STRINGHEX128"] = STRINGHEX128 
tMap["STRINGHEX256"] = STRINGHEX256 
tMap["STRINGHEX512"] = STRINGHEX512 
tMap["NUMBER"] = NUMBER
tMap["BOOLEAN"] = BOOLEAN
tMap["ARRAY"] = ARRAY
tMap["OBJECT"] = OBJECT
tMap["STRINGORNOTHING"] = STRINGORNOTHING
tMap["STRINGEMAILORNOTHING"] = STRINGEMAILORNOTHING
tMap["STRINGHEXORNOTHING"] = STRINGHEXORNOTHING
tMap["STRINGHEX32ORNOTHING"] = STRINGHEX32ORNOTHING
tMap["STRINGHEX64ORNOTHING"] = STRINGHEX64ORNOTHING
tMap["STRINGHEX128ORNOTHING"] = STRINGHEX128ORNOTHING
tMap["STRINGHEX256ORNOTHING"] = STRINGHEX256ORNOTHING
tMap["STRINGHEX512ORNOTHING"] = STRINGHEX512ORNOTHING
tMap["NUMBERORNOTHING"] = NUMBERORNOTHING
tMap["BOOLEANORNOTHING"] = BOOLEANORNOTHING
tMap["ARRAYORNOTHING"] = ARRAYORNOTHING
tMap["OBJECTORNOTHING"] = OBJECTORNOTHING
tMap["STRINGORNULL"] = STRINGORNULL
tMap["STRINGEMAILORNULL"] = STRINGEMAILORNULL
tMap["STRINGHEXORNULL"] = STRINGHEXORNULL
tMap["STRINGHEX32ORNULL"] = STRINGHEX32ORNULL
tMap["STRINGHEX64ORNULL"] = STRINGHEX64ORNULL
tMap["STRINGHEX128ORNULL"] = STRINGHEX128ORNULL
tMap["STRINGHEX256ORNULL"] = STRINGHEX256ORNULL
tMap["STRINGHEX512ORNULL"] = STRINGHEX512ORNULL
tMap["NUMBERORNULL"] = NUMBERORNULL
tMap["BOOLEANORNULL"] = BOOLEANORNULL
tMap["ARRAYORNULL"] = ARRAYORNULL
tMap["NONNULLOBJECT"] = NONNULLOBJECT
tMap["NONEMPTYSTRING"] = NONEMPTYSTRING
tMap["NONEMPTYARRAY"] = NONEMPTYARRAY
tMap["NONEMPTYSTRINGHEX"] = NONEMPTYSTRINGHEX
tMap["NONEMPTYSTRINGCLEAN"] = NONEMPTYSTRINGCLEAN
tMap["STRINGCLEAN"] = STRINGCLEAN
tMap["STRINGCLEANORNULL"] = STRINGCLEANORNULL 
tMap["STRINGCLEANORNOTHING"] = STRINGCLEANORNOTHING
tMap["OBJECTCLEAN"] = OBJECTCLEAN
tMap["NONNULLOBJECTCLEAN"] = NONNULLOBJECTCLEAN
tMap["OBJECTCLEANORNOTHING"] = OBJECTCLEANORNOTHING

#endregion


############################################################
#region Schema Tests
testSchemas = []
testObjects = []

############################################################
## @0
testSchemas.push(OBJECT)
testObjects.push({})

############################################################
## @1
testSchemas.push([NUMBERORNOTHING])
testObjects.push([])

############################################################
## @2
testSchemas.push({ email: STRINGEMAILORNOTHING })
testObjects.push({})

############################################################
## @3
testSchemas.push([ NUMBER, NUMBER, NUMBER,STRINGEMAILORNOTHING ])
testObjects.push([1,1,1, "email@alli.li"])

############################################################
## @4
testSchemas.push({
    email: STRINGEMAIL,
    name: STRING,
    sub: {
        okay: BOOLEAN
    }
})
testObjects.push({
    email: "alfred@moser.de",
    name: "alfi",
    sub: {
        okay: true
    }
})

############################################################
## @5
testSchemas.push({
    email: STRINGEMAIL,
    name: STRING,
    sub: [
        NUMBERORNOTHING,
        NUMBERORNOTHING,
        NUMBERORNOTHING,
        NUMBERORNOTHING
    ]
})
testObjects.push({
    email: "alfred@moser.de",
    name: "alfi",
    sub: [ 2, 3 ]
})

#endregion

############################################################
tO = {
  "STRING": [
    [null, false],
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["", true],
    [" ", true],
    ["a", true],
    ["hello world", true],
    ["こんにちは", true],
    ["🙂", true],
    ["abc\u200bdef", true],
    ["abc\u200ddef", true],
    ["abc\uFEFFdef", true],
    ["\u00A0", true],
    ["\t", true],
    ["\n", true],
    ["💩", true],
    ["abc\x00def", true],
    ["abc\r\n", true],
    ["𝔘𝔫𝔦𝔠𝔬𝔡𝔢", true],
    ["a".repeat(1024), true]
  ],
  "STRINGEMAIL": [
    [null, false],
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["test@example.com", true],
    ["user+filter@domain.co.uk", true],
    ["üñîçøðé@example.com", false],
    ["user@[192.168.0.1]", false],
    ["invalid@", false],
    ["@no-local-part.com", false],
    ["space in@domain.com", false],
    ["trailingdot.@example.com", false],
    ["user@-domain.com", false],
    ["user@domain..com", false],
    ["user@domain.com ", false],
    [" user@domain.com", false],
    ["user@domain.com\n", false]
  ],
  "STRINGHEX": [
    [null, false],
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["abc", true],
    ["0xabc", false],
    ["ABCDEF", true],
    ["1234567890abcdef", true],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", true],
    ["deadbeef", true],
    ["a".repeat(257), true],
    ["00ff", true],
    [" 00ff", false],
    ["00ff ", false]
  ],
  "STRINGHEX32": [
    [null, false],
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["abc", false],
    ["0xabc", false],
    ["ABCDEF", false],
    ["1234567890abcdef", false],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", false],
    ["deadbeef", false],
    ["a".repeat(257), false],
    ["00ff", false],
    [" 00ff", false],
    ["00ff ", false],
    ["a".repeat(32), true],
    ["A".repeat(32), true],
    ["0".repeat(31), false],
    ["f".repeat(33), false],
    ["abc123", false],
    ["xyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxy", false]
  ],
  "STRINGHEX64": [
    [null, false],
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["abc", false],
    ["0xabc", false],
    ["ABCDEF", false],
    ["1234567890abcdef", false],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", false],
    ["deadbeef", false],
    ["a".repeat(257), false],
    ["00ff", false],
    [" 00ff", false],
    ["00ff ", false],
    ["a".repeat(64), true],
    ["A".repeat(64), true],
    ["f".repeat(63), false],
    ["f".repeat(65), false],
    ["0x" + "f".repeat(62), false]
  ],
  "STRINGHEX128": [
    [null, false],
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["abc", false],
    ["0xabc", false],
    ["ABCDEF", false],
    ["1234567890abcdef", false],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", false],
    ["deadbeef", false],
    ["a".repeat(257), false],
    ["00ff", false],
    [" 00ff", false],
    ["00ff ", false],
    ["a".repeat(128), true],
    ["A".repeat(128), true],
    ["f".repeat(127), false],
    ["f".repeat(129), false]
  ],
  "STRINGHEX256": [
    [null, false],
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["abc", false],
    ["0xabc", false],
    ["ABCDEF", false],
    ["1234567890abcdef", false],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", false],
    ["deadbeef", false],
    ["a".repeat(257), false],
    ["00ff", false],
    [" 00ff", false],
    ["00ff ", false],
    ["a".repeat(256), true],
    ["f".repeat(255), false],
    ["f".repeat(257), false]
  ],
  "STRINGHEX512": [
    [null, false],
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["abc", false],
    ["0xabc", false],
    ["ABCDEF", false],
    ["1234567890abcdef", false],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", false],
    ["deadbeef", false],
    ["a".repeat(257), false],
    ["00ff", false],
    [" 00ff", false],
    ["00ff ", false],
    ["a".repeat(512), true],
    ["f".repeat(511), false],
    ["f".repeat(513), false]
  ],
  "NUMBER": [
    [undefined, false],
    [false, false],
    ["1", false],
    [0, true],
    [1, true],
    [-1, true],
    [1.23, true],
    [-1.23, true],
    [1e10, true],
    [-1e10, true],
    ["123", false],
    [NaN, false],
    [Infinity, false],
    [-Infinity, false],
    [null, false],
    ["", false],
    [" ", false],
    [[], false],
    [{}, false],
    ["0x11", false]
  ],
  "BOOLEAN": [
    [{}, false],
    [[], false],
    [true, true],
    [false, true],
    ["true", false],
    ["false", false],
    [1, false],
    [0, false],
    ["yes", false],
    ["no", false],
    [null, false],
    [undefined, false]
  ],
  "ARRAY": [
    [null, false],
    [undefined, false],
    [0, false],
    [false, false],
    ["", false],
    ["[]", false],
    [{}, false],
    [[], true],
    [[1], true],
    [[1, 2, 3], true],
    [["a", null, undefined], true],
    [[[]], true],
    [[true, false], true],
    [new Array(0), true],
    [new Array(100).fill("a"), true]
  ],
  "OBJECT": [
    [null, true],
    [undefined, false],
    [[], true],
    [0, false],
    [false, false],
    [{}, true],
    [{"a": 1}, true],
    [{"nested": {"x": 2}}, true],
    [{"array": [1, 2, 3]}, true],
    [Object.create(null), true],
    [{"": "emptyKey"}, true],
    [{"a": undefined}, true],
    [{"a": null}, true],
    [{"a": NaN}, true],
    [{["__proto__"]: {"polluted": true}}, true],
    [{"nested": {"x": {"constructor": {"prototype": {"polluted": true}}}}}, true],
    [{"nested": {"x": {"constrctor": {"prototype": {"polluted": true}}}}}, true],
    [{"nested": {"x": {"constructor": {"prottype": {"polluted": true}}}}}, true],
    [{"nested": {"x": {"constructr": {"prottype": {"polluted": true}}}}}, true],
    [{"nested": {"x": {"constructr": {["__proto__"]: {"polluted": true}}}}}, true]
  ],
  "STRINGORNOTHING": [
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    [undefined, true],
    ["", true],
    ["abc", true],
    ["💀", true],
    [null, false],
    ["", true],
    [" ", true],
    ["a", true],
    ["hello world", true],
    ["こんにちは", true],
    ["🙂", true],
    ["abc\u200bdef", true],
    ["abc\u200ddef", true],
    ["abc\uFEFFdef", true],
    ["\u00A0", true],
    ["\t", true],
    ["\n", true],
    ["💩", true],
    ["abc\x00def", true],
    ["abc\r\n", true],
    ["𝔘𝔫𝔦𝔠𝔬𝔡𝔢", true],
    ["a".repeat(1024), true]
  ],
  "STRINGEMAILORNOTHING": [
    [null, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    [undefined, true],
    ["test@example.com", true],
    ["invalid@", false],
    ["", false],
    ["test@example.com", true],
    ["user+filter@domain.co.uk", true],
    ["üñîçøðé@example.com", false],
    ["user@[192.168.0.1]", false],
    ["invalid@", false],
    ["@no-local-part.com", false],
    ["space in@domain.com", false],
    ["trailingdot.@example.com", false],
    ["user@-domain.com", false],
    ["user@domain..com", false],
    ["user@domain.com ", false],
    [" user@domain.com", false],
    ["user@domain.com\n", false]
  ],
  "STRINGHEXORNOTHING": [
    [null, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    [undefined, true],
    ["abc", true],
    ["123xyz", false],
    ["abc", true],
    ["0xabc", false],
    ["ABCDEF", true],
    ["1234567890abcdef", true],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", true],
    ["deadbeef", true],
    ["a".repeat(257), true],
    ["00ff", true],
    [" 00ff", false],
    ["00ff ", false]
  ],
  "STRINGHEX32ORNOTHING": [
    [null, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    [undefined, true],
    ["abc", false],
    ["0xabc", false],
    ["ABCDEF",false],
    ["1234567890abcdef", false],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", false],
    ["deadbeef", false],
    ["a".repeat(257), false],
    ["00ff", false],
    [" 00ff", false],
    ["00ff ", false],
    ["a".repeat(32), true],
    ["A".repeat(32), true],
    ["s".repeat(32), false],
    ["x".repeat(32), false],
    ["0".repeat(31), false],
    ["f".repeat(33), false],
    ["abc123", false],
    ["xyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxyzxy", false]
  ],
  "STRINGHEX64ORNOTHING": [
    [null, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    [undefined, true],
    ["abc", false],
    ["0xabc", false],
    ["ABCDEF", false],
    ["1234567890abcdef", false],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", false],
    ["deadbeef", false],
    ["a".repeat(257), false],
    ["00ff", false],
    [" 00ff", false],
    ["00ff ", false],
    ["a".repeat(64), true],
    ["A".repeat(64), true],
    ["x".repeat(64), false],
    ["f".repeat(63), false],
    ["f".repeat(65), false],
    ["0x" + "f".repeat(62), false]
  ],
  "STRINGHEX128ORNOTHING": [
    [null, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["abc", false],
    ["0xabc", false],
    ["ABCDEF", false],
    ["1234567890abcdef", false],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", false],
    ["deadbeef", false],
    ["a".repeat(257), false],
    ["00ff", false],
    [" 00ff", false],
    ["00ff ", false],
    ["a".repeat(128), true],
    ["A".repeat(128), true],
    ["s".repeat(128), false],
    ["x".repeat(128), false],
    ["f".repeat(127), false],
    ["f".repeat(129), false],
    [undefined, true],
    ["a".repeat(128), true]
  ],
  "STRINGHEX256ORNOTHING": [
    [null, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["abc", false],
    ["0xabc", false],
    ["ABCDEF", false],
    ["1234567890abcdef", false],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", false],
    ["deadbeef", false],
    ["a".repeat(257), false],
    ["00ff", false],
    [" 00ff", false],
    ["00ff ", false],
    ["a".repeat(256), true],
    ["x".repeat(256), false],
    ["f".repeat(255), false],
    ["f".repeat(257), false],
    [undefined, true],
    ["a".repeat(256), true]
  ],
  "STRINGHEX512ORNOTHING": [
    [null, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["abc", false],
    ["0xabc", false],
    ["ABCDEF", false],
    ["1234567890abcdef", false],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", false],
    ["deadbeef", false],
    ["a".repeat(257), false],
    ["00ff", false],
    [" 00ff", false],
    ["00ff ", false],
    ["a".repeat(512), true],
    ["x".repeat(512), false],
    ["f".repeat(511), false],
    ["f".repeat(513), false],
    [undefined, true],
    ["a".repeat(512), true]
  ],
  "NUMBERORNOTHING": [
    [null, false],
    [{}, false],
    [[], false],
    [false, false],
    [undefined, true],
    [123, true],
    ["123", false],
    [NaN, true]
    [undefined, true],
    [0, true],
    [1, true],
    [-1, true],
    [1.23, true],
    [-1.23, true],
    [1e10, true],
    [-1e10, true],
    [Infinity, true],
    [-Infinity, true],
    ["", false],
    [" ", false],
    ["0x11", false]
  ],
  "BOOLEANORNOTHING": [
    ["", false]
    [{}, false],
    [[], false],
    [0, false],
    [undefined, true],
    [true, true],
    [false, true],
    ["true", false],
    ["false", false],
    [1, false],
    [0, false],
    ["yes", false],
    ["no", false],
    [null, false]
  ],
  "ARRAYORNOTHING": [
    [null, false],
    [0, false],
    [false, false],
    [undefined, true],
    ["", false],
    ["[]", false],
    [{}, false],
    [[], true],
    [[1], true],
    [[1, 2, 3], true],
    [["a", null, undefined], true],
    [[[]], true],
    [[true, false], true],
    [new Array(0), true],
    [new Array(100).fill("a"), true]
  ],
  "OBJECTORNOTHING": [
    ["", false],
    ["asd", false],
    [null, true],
    [{}, true],
    [[], true],
    [0, false],
    [false, false],
    [undefined, true],
    [{}, true],
    [{"a": 1}, true],
    [{"nested": {"x": 2}}, true],
    [{"array": [1, 2, 3]}, true],
    [Object.create(null), true],
    [{"": "emptyKey"}, true],
    [{"a": undefined}, true],
    [{"a": null}, true],
    [{"a": NaN}, true],
    [{["__proto__"]: {"polluted": true}}, true],
    [{"nested": {"x": {"constructor": {"prototype": {"polluted": true}}}}}, true],
    [{"nested": {"x": {"constrctor": {"prototype": {"polluted": true}}}}}, true],
    [{"nested": {"x": {"constructor": {"prottype": {"polluted": true}}}}}, true],
    [{"nested": {"x": {"constructr": {"prottype": {"polluted": true}}}}}, true],
    [{"nested": {"x": {"constructr": {["__proto__"]: {"polluted": true}}}}}, true]
  ],
  "STRINGORNULL": [
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    [null, true],
    ["", true],
    ["abc", true],
    ["💀", true],
    ["", true],
    [" ", true],
    ["a", true],
    ["hello world", true],
    ["こんにちは", true],
    ["🙂", true],
    ["abc\u200bdef", true],
    ["abc\u200ddef", true],
    ["abc\uFEFFdef", true],
    ["\u00A0", true],
    ["\t", true],
    ["\n", true],
    ["💩", true],
    ["abc\x00def", true],
    ["abc\r\n", true],
    ["𝔘𝔫𝔦𝔠𝔬𝔡𝔢", true],
    ["a".repeat(1024), true]
  ],
  "STRINGEMAILORNULL": [
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    [null, true],
    ["test@example.com", true],
    ["invalid@", false],
    ["test@example.com", true],
    ["user+filter@domain.co.uk", true],
    ["üñîçøðé@example.com", false],
    ["user@[192.168.0.1]", false],
    ["invalid@", false],
    ["@no-local-part.com", false],
    ["space in@domain.com", false],
    ["trailingdot.@example.com", false],
    ["user@-domain.com", false],
    ["user@domain..com", false],
    ["user@domain.com ", false],
    [" user@domain.com", false],
    ["user@domain.com\n", false]
  ],
  "STRINGHEXORNULL": [
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    [null, true],
    ["abc", true],
    ["0xabc", false],
    ["ABCDEF", true],
    ["1234567890abcdef", true],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", true],
    ["deadbeef", true],
    ["a".repeat(257), true],
    ["00ff", true],
    [" 00ff", false],
    ["00ff ", false]
  ],
  "STRINGHEX32ORNULL": [
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    [null, true],
    ["abc", false],
    ["0xabc", false],
    ["ABCDEF", false],
    ["1234567890abcdef", false],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", false],
    ["deadbeef", false],
    ["a".repeat(257), false],
    ["00ff", false],
    [" 00ff", false],
    ["00ff ", false],
    ["a".repeat(32), true],
    ["A".repeat(32), true],
    ["s".repeat(32), false],
    ["a".repeat(33), false]
    ["a".repeat(31), false]
  ],
  "STRINGHEX64ORNULL": [
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    [null, true],
    ["abc", false],
    ["0xabc", false],
    ["ABCDEF", false],
    ["1234567890abcdef", false],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", false],
    ["deadbeef", false],
    ["a".repeat(257), false],
    ["00ff", false],
    [" 00ff", false],
    ["00ff ", false],
    ["a".repeat(64), true],
    ["b".repeat(64), true],
    ["A".repeat(64), true],
    ["s".repeat(64), false],
    ["X".repeat(64), false],
    ["a".repeat(63), false],
    ["a".repeat(65), false]
  ],
  "STRINGHEX128ORNULL": [
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["abc", false],
    ["0xabc", false],
    ["ABCDEF", false],
    ["1234567890abcdef", false],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", false],
    ["deadbeef", false],
    ["a".repeat(257), false],
    ["00ff", false],
    [" 00ff", false],
    ["00ff ", false],
    ["a".repeat(128), true],
    ["A".repeat(128), true],
    ["f".repeat(128), true],
    ["x".repeat(128), false],
    [".".repeat(128), false],
    ["\n".repeat(128), false],
    ["\0".repeat(128), false],
    ["f".repeat(127), false],
    ["f".repeat(129), false],
    [null, true]
  ],
  "STRINGHEX256ORNULL": [
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["abc", false],
    ["0xabc", false],
    ["ABCDEF", false],
    ["1234567890abcdef", false],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", false],
    ["deadbeef", false],
    ["a".repeat(257), false],
    ["00ff", false],
    [" 00ff", false],
    ["00ff ", false],
    ["a".repeat(256), true],
    ["f".repeat(256), true],
    ["x".repeat(256), false],
    [".".repeat(256), false],
    ["\n".repeat(256), false],
    ["\0".repeat(256), false],
    ["f".repeat(255), false],
    ["f".repeat(257), false],
    [null, true]
  ],
  "STRINGHEX512ORNULL": [
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["abc", false],
    ["0xabc", false],
    ["ABCDEF", false],
    ["1234567890abcdef", false],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", false],
    ["deadbeef", false],
    ["a".repeat(257), false],
    ["00ff", false],
    [" 00ff", false],
    ["00ff ", false],
    ["a".repeat(512), true],
    ["f".repeat(512), true],
    ["x".repeat(512), false],
    [".".repeat(512), false],
    ["\n".repeat(512), false],
    ["\0".repeat(512), false],
    ["f".repeat(511), false],
    ["f".repeat(513), false],
    [null, true]
  ],
  "NUMBERORNULL": [
    [undefined, false],
    [false, false],
    [null, true],
    [123, true],
    [NaN, true],
    [0, true],
    [1, true],
    [-1, true],
    [1.23, true],
    [-1.23, true],
    [1e10, true],
    [-1e10, true],
    ["123", false],
    [Infinity, true],
    [-Infinity, true],
    ["", false],
    [" ", false],
    [[], false],
    [{}, false],
    ["0x11", false]
  ],
  "BOOLEANORNULL": [
    ["", false],
    ["abs", false],
    [{}, false],
    [[], false],
    [0, false],
    [null, true],
    [true, true],
    [false, true],
    ["true", false],
    ["false", false],
    [1, false],
    [0, false],
    ["yes", false],
    ["no", false],
    [undefined, false]
  ],
  "ARRAYORNULL": [
    ["asd", false]
    [undefined, false],
    [0, false],
    [false, false],
    [null, true],
    ["", false],
    ["[]", false],
    [{}, false],
    [[], true],
    [[1], true],
    [[1, 2, 3], true],
    [["a", null, undefined], true],
    [[[]], true],
    [[true, false], true],
    [new Array(0), true],
    [new Array(100).fill("a"), true]
  ],
  "NONNULLOBJECT": [
    [undefined, false],
    [[], true],
    [0, false],
    [false, false],
    [null, false],
    [{}, true],
    [{"a": 1}, true],
    [{"nested": {"x": 2}}, true],
    [{"array": [1, 2, 3]}, true],
    [Object.create(null), true],
    [{"": "emptyKey"}, true],
    [{"a": undefined}, true],
    [{"a": null}, true],
    [{"a": NaN}, true],
    [{["__proto__"]: {"polluted": true}}, true],
    [{"nested": {"x": {"constructor": {"prototype": {"polluted": true}}}}}, true],
    [{"nested": {"x": {"constrctor": {"prototype": {"polluted": true}}}}}, true],
    [{"nested": {"x": {"constructor": {"prottype": {"polluted": true}}}}}, true],
    [{"nested": {"x": {"constructr": {"prottype": {"polluted": true}}}}}, true],
    [{"nested": {"x": {"constructr": {["__proto__"]: {"polluted": true}}}}}, true]
  ],
  "NONEMPTYSTRING": [
    [null, false],
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["a", true],
    [" ", true],
    ["", false],
    ["💩", true],
    [" ", true],
    ["a", true],
    ["hello world", true],
    ["こんにちは", true],
    ["🙂", true],
    ["abc\u200bdef", true],
    ["abc\u200ddef", true],
    ["abc\uFEFFdef", true],
    ["\u00A0", true],
    ["\t", true],
    ["\n", true],
    ["💩", true],
    ["abc\x00def", true],
    ["abc\r\n", true],
    ["𝔘𝔫𝔦𝔠𝔬𝔡𝔢", true],
    ["a".repeat(1024), true]
  ],
  "NONEMPTYARRAY": [
    [null, false],
    [undefined, false],
    [0, false],
    [false, false],
    [[], false],
    ["", false],
    ["[12, 12]", false],
    [{}, false],
    [[1], true],
    [[1, 2, 3], true],
    [["a", null, undefined], true],
    [[[]], true],
    [[true, false], true],
    [new Array(0), false],
    [new Array(100).fill("a"), true]
  ],
  "NONEMPTYSTRINGHEX": [
    [null, false],
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["abc", true],
    ["0xabc", false],
    ["ABCDEF", true],
    ["1234567890abcdef", true],
    ["GHIJKL", false],
    ["abc123!", false],
    ["", false],
    ["deadbeef", true],
    ["a".repeat(257), true],
    ["00ff", true],
    [" 00ff", false],
    ["00ff ", false]
  ],
  "NONEMPTYSTRINGCLEAN": [
    [null, false],
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["Hello", true],
    ["こんにちは", true],
    ["abc\x00def", false],
    ["line\nbreak", true],
    ["tab\tchar", true],
    ["💩", true],
    ["visible space ", true],
    ["abc\u200bdef", false], 
    ["abc\uFEFFdef", false], 
    ["abc\u202Edef", false],  
    ["", false],
    [" ", true],
    ["a", true],
    ["hello world", true],
    ["こんにちは", true],
    ["🙂", true],
    ["abc\u200bdef", false],
    ["abc\u200ddef", false],
    ["abc\uFEFFdef", false],
    ["\u00A0", false],
    ["\t", true],
    ["\n", true],
    ["💩", true],
    ["abc\x00def", false],
    ["abc\r\n", true],
    ["𝔘𝔫𝔦𝔠𝔬𝔡𝔢", true],
    ["a".repeat(1024), true]
  ],

  "STRINGCLEAN": [
    [null, false],
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    ["Hello", true],
    ["こんにちは", true],
    ["abc\x00def", false],
    ["line\nbreak", true],
    ["tab\tchar", true],
    ["💩", true],
    ["visible space ", true],
    ["abc\u200bdef", false], 
    ["abc\uFEFFdef", false], 
    ["abc\u202Edef", false],  
    ["", true],
    [" ", true],
    ["a", true],
    ["hello world", true],
    ["こんにちは", true],
    ["🙂", true],
    ["abc\u200bdef", false],
    ["abc\u200ddef", false],
    ["abc\uFEFFdef", false],
    ["\u00A0", false],
    ["\t", true],
    ["\n", true],
    ["💩", true],
    ["abc\x00def", false],
    ["abc\r\n", true],
    ["𝔘𝔫𝔦𝔠𝔬𝔡𝔢", true],
    ["a".repeat(1024), true]
  ],
  "STRINGCLEANORNULL": [
    [undefined, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    [null, true],
    ["こんにちは", true],
    ["abc\x00def", false],
    ["line\nbreak", true],
    ["tab\tchar", true],
    ["💩", true],
    ["visible space ", true],
    ["abc\u200bdef", false], 
    ["abc\uFEFFdef", false], 
    ["abc\u202Edef", false],
    ["Hello", true],
    ["こんにちは", true],
    ["abc\x00def", false],
    ["line\nbreak", true],
    ["tab\tchar", true],
    ["💩", true],
    ["visible space ", true],
    ["abc\u200bdef", false], 
    ["abc\uFEFFdef", false], 
    ["abc\u202Edef", false],  
    ["", true],
    [" ", true],
    ["a", true],
    ["hello world", true],
    ["こんにちは", true],
    ["🙂", true],
    ["abc\u200bdef", false],
    ["abc\u200ddef", false],
    ["abc\uFEFFdef", false],
    ["\u00A0", false],
    ["\t", true],
    ["\n", true],
    ["💩", true],
    ["abc\x00def", false],
    ["abc\r\n", true],
    ["𝔘𝔫𝔦𝔠𝔬𝔡𝔢", true],
    ["a".repeat(1024), true]
  ],
  "STRINGCLEANORNOTHING": [
    [null, false],
    [{}, false],
    [[], false],
    [0, false],
    [false, false],
    [undefined, true],
    ["こんにちは", true],
    ["abc\x00def", false],
    ["line\nbreak", true],
    ["tab\tchar", true],
    ["💩", true],
    ["visible space ", true],
    ["abc\u200bdef", false], 
    ["abc\uFEFFdef", false], 
    ["abc\u202Edef", false],  
    ["Hello", true],
    ["こんにちは", true],
    ["abc\x00def", false],
    ["line\nbreak", true],
    ["tab\tchar", true],
    ["💩", true],
    ["visible space ", true],
    ["abc\u200bdef", false], 
    ["abc\uFEFFdef", false], 
    ["abc\u202Edef", false],  
    ["", true],
    [" ", true],
    ["a", true],
    ["hello world", true],
    ["こんにちは", true],
    ["🙂", true],
    ["abc\u200bdef", false],
    ["abc\u200ddef", false],
    ["abc\uFEFFdef", false],
    ["\u00A0", false],
    ["\t", true],
    ["\n", true],
    ["💩", true],
    ["abc\x00def", false],
    ["abc\r\n", true],
    ["𝔘𝔫𝔦𝔠𝔬𝔡𝔢", true],
    ["a".repeat(1024), true]
  ],

  "OBJECTCLEAN":[
    ["", false]
    [null, true],
    [undefined, false],
    [[], true],
    [0, false],
    [false, false],
    [{}, true],
    [{"a": 1}, true],
    [{"nested": {"x": 2}}, true],
    [{"array": [1, 2, 3]}, true],
    [Object.create(null), true],
    [{"": "emptyKey"}, true],
    [{"a": undefined}, true],
    [{"a": null}, true],
    [{"a": NaN}, true],
    [{["__proto__"]: {"polluted": true}}, false],
    [{"nested": {"x": {"constructor": {"prototype": {"polluted": true}}}}}, false],
    [{"nested": {"x": {"constrctor": {"prototype": {"polluted": true}}}}}, false],
    [{"nested": {"x": {"constructor": {"prottype": {"polluted": true}}}}}, false],
    [{"nested": {"x": {"constructr": {"prottype": {"polluted": true}}}}}, true],
    [{"nested": {"x": {"constructr": {["__proto__"]: {"polluted": true}}}}}, false]
  ],
  "NONNULLOBJECTCLEAN":[
    ["", false]
    ["asd", false],
    [undefined, false],
    [[], true],
    [0, false],
    [false, false],
    [null, false],
    [{}, true],
    [{"a": 1}, true],
    [{"nested": {"x": 2}}, true],
    [{"array": [1, 2, 3]}, true],
    [Object.create(null), true],
    [{"": "emptyKey"}, true],
    [{"a": undefined}, true],
    [{"a": null}, true],
    [{"a": NaN}, true],
    [{["__proto__"]: {"polluted": true}}, false]
    [{"nested": {"x": {"constructor": {"prototype": {"polluted": true}}}}}, false],
    [{"nested": {"x": {"constrctor": {"prototype": {"polluted": true}}}}}, false],
    [{"nested": {"x": {"constructor": {"prottype": {"polluted": true}}}}}, false],
    [{"nested": {"x": {"constructr": {"prottype": {"polluted": true}}}}}, true],
    [{"nested": {"x": {"constructr": {["__proto__"]: {"polluted": true}}}}}, false]
  ],
  "OBJECTCLEANORNOTHING": [
    [[], true],
    [0, false],
    [false, false],
    [undefined, true],
    [null, true],
    [{}, true],
    [{"a": 1}, true],
    [{"nested": {"x": 2}}, true],
    [{"array": [1, 2, 3]}, true],
    [Object.create(null), true],
    [{"": "emptyKey"}, true],
    [{"a": undefined}, true],
    [{"a": null}, true],
    [{"a": NaN}, true],
    [{["__proto__"]: {"polluted": true}}, false],
    [{"nested": {"x": {"constructor": {"prototype": {"polluted": true}}}}}, false],
    [{"nested": {"x": {"constrctor": {"prototype": {"polluted": true}}}}}, false],
    [{"nested": {"x": {"constructor": {"prottype": {"polluted": true}}}}}, false],
    [{"nested": {"x": {"constructr": {"prottype": {"polluted": true}}}}}, true],
    [{"nested": {"x": {"constructr": {["__proto__"]: {"polluted": true}}}}}, false]
  ]
}
#endregion

