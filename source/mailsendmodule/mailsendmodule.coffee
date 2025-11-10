############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("mailsendmodule")
#endregion

############################################################
#region Modules from the Environment
import * as mailer from "nodemailer"

############################################################
import * as cfg from "./configmodule.js"

#endregion

############################################################
buildTransporter = ->
    
    transportOptions = {
        host: cfg.emailServer
        port: cfg.emailPort
        secure: true
        requireTLS: true # force TLS or STARTTLS
        auth: {
            user: cfg.emailUsername
            pass: cfg.emailPassword
        }
    } 

    transporter = mailer.createTransport(transportOptions)
    return transporter

############################################################
export sendMail = (data) ->
    transporter = buildTransporter()

    mailOptions = {
        from: cfg.emailUsername,
        to: data.receiver,
        subject: data.subject,
        text: data.textContent,
        html: data.htmlContent
    }
    if data.replyTo? then mailOptions.replyTo = data.replyTo 

    try
        logInfo = await transporter.sendMail(mailOptions)
        olog logInfo
    catch err then console.error(err.message)
    return

############################################################
export verifyAccess = ->
    transporter = buildTransporter()
    return await transporter.verify()
    