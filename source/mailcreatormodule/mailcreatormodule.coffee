############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("mailcreatormodule")
#endregion

############################################################
import M from "mustache"

############################################################
import { sendMail } from "./mailsendmodule.js"

############################################################
#region Password Reset Templates

############################################################
passwordResetEmailTextTemplate = """
Guten Tag!

Wir erhielten eine Anfrage Ihr Passwort neu zu setzen.
Verwenden Sie bitte folgenden Link um dies zu tun:
{{{resetPasswordLink}}}


Wir wünschen Ihnen weiterhin Viel Erfolg!
Ihr Sentinel Team 
"""

############################################################
passwordResetEmailHtmlTemplate = """
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/><meta name="viewport" content="width=device-width, initial-scale=1.0"/><title>Sentinel Registrierung</title></head><body style="color: #012; font-size: 12pt;">
        
<h1 style="font-size:16pt;">Guten Tag!</h1>
<p>Wir erhielten eine Anfrage Ihr Passwort neu zu setzen.<br>
Verwenden Sie bitte folgenden Link um dies zu tun:<br>
<a href="{{{resetPasswordLink}}}" target="_blank">{{{resetPasswordLink}}}</a></p>
<p>Wir wünschen Ihnen weiterhin Viel Erfolg!<br>Ihr Sentinel Team</p> 

</body></html>
"""

#endregion

############################################################
#region Registration Templates

############################################################
## Already Registered Text
alreadyRegisteredEmailTextTemplate = """
Guten Tag!

Sie haben bereits einen Account mit dieser Emailadresse :-)

Wir wünschen Ihnen weiterhin Viel Erfolg!
Ihr Sentinel Team
"""

############################################################
## Already Registered HTML
alreadyRegisteredEmailHtmlTemplate = """
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/><meta name="viewport" content="width=device-width, initial-scale=1.0"/><title>Sentinel Registrierung</title></head><body style="color: #012; font-size: 12pt;">
        
<h1 style="font-size:16pt;">Guten Tag!</h1>
<p>Sie haben bereits einen Account mit dieser Emailadresse :-)</p>
<p>Wir wünschen Ihnen weiterhin Viel Erfolg!<br>Ihr Sentinel Team</p> 

</body></html>
"""


############################################################
## Registration Text
registrationEmailTextTemplate = """
Guten Tag!

Sehr gerne können Sie hier Ihre Registrierung abschließen: 
{{{registrationLink}}}

Wir wünschen Ihnen Viel Erfolg!
Ihr Sentinel Team
"""

############################################################
## Registration HTML
registrationEmailHtmlTemplate = """
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/><meta name="viewport" content="width=device-width, initial-scale=1.0"/><title>Sentinel Registrierung</title></head><body style="color: #012; font-size: 12pt;">
        
<h1 style="font-size:16pt;">Guten Tag!</h1>
<p>Sehr gerne können Sie hier Ihre Registrierung abschließen:<br>
<a href="{{{registrationLink}}}" target="_blank">{{{registrationLink}}}</a></p>
<p>Wir wünschen Ihnen Viel Erfolg!<br>Ihr Sentinel Team</p> 

</body></html>
"""

#endregion

############################################################
class Mail 
    constructor: (@receiver, @subject, @textContent, @htmlContent) -> return
    send: => sendMail(this)

############################################################
class RegistrationMail extends Mail
    constructor: (recvr, link) ->
        subj = "Sentinel Registrierung"
        cObj = {registrationLink: link}
        text = M.render(registrationEmailTextTemplate, cObj)
        html = M.render(registrationEmailHtmlTemplate, cObj)
        super(recvr, subj, text, html)

class AlreadyRegisteredMail extends Mail
    constructor: (recvr, link) ->
        subj = "Sentinel Registrierung"
        text = M.render(alreadyRegisteredEmailTextTemplate, {})
        html = M.render(alreadyRegisteredEmailHtmlTemplate, {})
        super(recvr, subj, text, html)

class PasswordResetMail extends Mail
    constructor: (recvr, link) ->
        subj = "Neues Passwort"
        cObj = {resetPasswordLink: link}
        text = M.render(passwordResetEmailTextTemplate, cObj)
        html = M.render(passwordResetEmailHtmlTemplate, cObj)
        super(recvr, subj, text, html)


############################################################
export sendRegistrationMail = (email, link) ->
    try
        mail = new RegistrationMail(email, link)
        await mail.send()
    catch err then console.error(err.message)
    return

export sendPasswordResetMail = (email, link) ->
    try
        mail = new PasswordResetMail(email, link)
        await mail.send()
    catch err then console.error(err.message)
    return

export sendAlreadyRegisteredMail = (email) ->
    try
        mail = new AlreadyRegisteredMail(email)
        await mail.send()
    catch err then console.error(err.message)
    return
