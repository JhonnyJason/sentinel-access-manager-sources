############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("subscriptionmodule")
#endregion

############################################################
#region Test Data:
sandboxPaypalId = "AZvvkfAsObhFNG7g1G5y6RLJZN0mG115RtHkb6Nu7vQVqV_ZeN2YV5FcHjhH95iUeMg9FvTLHPs-InJL"
sandboxPaypalKey = "EDVVe6Lf9h_Z5Re9iEUPofN1OFYZdiI2fVh8rouRHU2XPc6IwCOZHdnkRMHUhKFikmYWKqbFHtKG_bBN"

successfullCard = {
    cardNumber: "4032037389661931"
    expiryDate: "01/2025"
    cvc: "123"
}

## Testing Card Failures - how to?
# Test Name        | Trigger             | Processor response code
# Fraudulent card  | CCREJECT-SF         | 9500
# Card is declined | CCREJECT-BANK_ERROR | 5100
# CVC check fails  | CCREJECT-CVV_F      | 00N7
# Card expired     | CCREJECT-EC         | 5400


successful3DSVisaCard = {
    cardNumber: "4868719460707704"
    expiryDate: "01/2025"
    cvc: "123"
}

successful3DSMasterCard = {
    cardNumber: "5329879786234393"
    expiryDate: "01/2025"
    cvc: "123"
}

failed3DSVisaCard = {
    cardNumber: "4868719115514992"
    expiryDate: "01/2025"
    cvc: "123"

}

failed3DSMasterCard = {
    cardNumber: "5329879785160250"
    expiryDate: "01/2025"
    cvc: "123"
}

testPaypalAccount = {
    email: "sb-iotau47114293@business.example.com",
    pwd: "Z,#W0bI?",
    type: "Business"
}
#endregion


############################################################
export initialize = ->
    log "initialize"
    #Implement or Remove :-)
    return