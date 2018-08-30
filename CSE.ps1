<# Custom Script for Windows to install a file from Azure Storage using the staging folder created by the deployment script #>
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

#Add-LocalGroupMember -Group administrators -Member Test

for ($i = 1; $i -lt $UsersAmount+1; $i++) {
    Add-DnsServerPrimaryZone -Name "cssilbaseuser$i.com" -ZoneFile "cssilbaseuser$i.com.dns"
    Add-DnsServerResourceRecordA -Name "*" -ZoneName "cssilbaseuser$i.com" -IPv4Address "10.11.$i.11" -TimeToLive 00:00:00
    Add-DnsServerResourceRecordA -Name "*.scm" -ZoneName "cssilbaseuser$i.com" -IPv4Address "10.11.$i.11" -TimeToLive 00:00:00

    New-LocalUser -Name "User$i" -Password (ConvertTo-SecureString -AsPlainText -String "No_P@ssw0rd" -force) -AccountNeverExpires:$True -PasswordNeverExpires:$True -UserMayNotChangePassword:$True
    Add-LocalGroupMember -Group Administrators -Member "User$i"
}

# Cleanup
# Get-DnsServerZone  | where{$_.ZoneName -like "css*"} | Remove-DnsServerZone -Force
# Get-LocalUser user* | Remove-LocalUser

