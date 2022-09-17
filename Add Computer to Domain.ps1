$domain = "vtf.redteam.com"
$ifindex = Get-NetRoute | % { Process { If (!$_.RouteMetric) { $_.ifIndex } } }; 
$username = “$domain\WaleedforVTF” #user name with privileges to add a device to the $domain 
Set-DNSClientServerAddress –interfaceIndex $ifindex –ServerAddresses ("10.0.3.4","10.0.3.4") 
$password = "WaleedforVTF#123"|ConvertTo-SecureString –asPlainText –Force #password for the above user 

$user2 = "Viper1" #administrator account of the device 
$pass2 = "Viper@RedTeam1"|ConvertTo-SecureString –asPlainText –Force #password for $user2 
$lcred = New-object –TypeName System.Management.Automation.PSCredential -ArgumentList ($user2, $pass2)  
$credential = New-object –TypeName System.Management.Automation.PSCredential -ArgumentList ($username, $password) 
Add-Computer –DomainName $domain –Credential $credential –LocalCredential $lcred –Restart –Force  



