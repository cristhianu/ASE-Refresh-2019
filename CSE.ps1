<# Custom Script to install DNS, create DNS Zones and records used by ASE and disabling IE Enhanced Security . #>
param (
    [int]$UsersAmount
)

#$UsersAmount = 50

Import-Module ServerManager
Install-WindowsFeature DNS,RSAT-DNS-Server

Import-Module DnsServer
#Add-DnsServerPrimaryZone -Name test.local -ZoneFile test.local.dns
#Add-DnsServerResourceRecordA -Name "www" -ZoneName "test.local" -IPv4Address "10.11.$i.11" -TimeToLive 00:00:00

Import-Module Microsoft.PowerShell.LocalAccounts
#New-LocalUser Test -Password (ConvertTo-SecureString -AsPlainText -String "H2OBarrentA@" -force) -AccountNeverExpires:$True -PasswordNeverExpires:$True -UserMayNotChangePassword:$True

Add-DnsServerPrimaryZone -Name "asetraining.com" -ZoneFile "asetraining.com.dns"
Add-DnsServerResourceRecordA -Name "*" -ZoneName "asetraining.com" -IPv4Address "10.11.3.11" -TimeToLive 00:00:00
Add-DnsServerResourceRecordA -Name "*.scm" -ZoneName "asetraining.com" -IPv4Address "10.11.3.11" -TimeToLive 00:00:00

#Add-LocalGroupMember -Group administrators -Member Test

 for ($i = 1; $i -lt $UsersAmount+1; $i++) {
#    $dnszonecount = $i * 2;  
    New-LocalUser -Name "User$i" -Password (ConvertTo-SecureString -AsPlainText -String "No_P@ssw0rd!" -force) -AccountNeverExpires:$True -PasswordNeverExpires:$True -UserMayNotChangePassword:$True
    Add-LocalGroupMember -Group Administrators -Member "User$i"
}

# Cleanup
# Get-DnsServerZone  | where{$_.ZoneName -like "css*"} | Remove-DnsServerZone -Force
# Get-LocalUser user* | Remove-LocalUser

function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
    #Stop-Process -Name Explorer -force
    #Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
}

Disable-InternetExplorerESC
