<# SEND MAIL VIA SMTP
Author: Giuseppe Malandrone
Description: Sends a mail via SMTP protocol with parameters passed as input
Input: $SMTPServer, $SenderMailAddress, $SenderMailPassword, $SenderName, $RecipientMailAddress, $Subject,  $Body 
Output: -
Use:
	SendMailViaSMTP $SMTPServer $SenderMailAddress $SenderMailPassword $SenderName $RecipientMailAddress $Subject $Body
#>
function SendMailViaSMTP {
    param (
	[Parameter(Mandatory=$true)] [string] $SMTPServer,
	[Parameter(Mandatory=$true)] [string] $SenderMailAddress,
	[Parameter(Mandatory=$true)] [string] $SenderMailPassword,
	[Parameter(Mandatory=$true)] [string] $SenderName,
	[Parameter(Mandatory=$true)] [string] $RecipientMailAddress,
	[Parameter(Mandatory=$true)] [string] $Subject,
	[Parameter(Mandatory=$true)] [string] $Body
	)

$SMTPClient = New-Object Net.Mail.SMTPClient($SmtpServer, 587)
$SMTPClient.EnableSSL = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential($SenderMailAddress , $SenderMailPassword)

$emailMessage = New-Object System.Net.Mail.MailMessage
$emailMessage.From = $SenderName
$emailMessage.To.Add($RecipientMailAddress)
$emailMessage.Subject =  $Subject
$emailMessage.Body = $Body

$SMTPClient.Send($emailMessage)

return
}