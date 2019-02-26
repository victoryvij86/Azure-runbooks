$AdminName = "UPN Name"

$Pass = Get-Content "<Path>" | ConvertTo-SecureString

$Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $AdminName, $PassSection-1
Read-Host -Prompt "Enter your tenant password" -AsSecureString | ConvertFrom-SecureString | Out-File "C:\users\administartor\cred.txt"
