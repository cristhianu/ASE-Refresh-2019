<# Custom Script for Windows to install a file from Azure Storage using the staging folder created by the deployment script #>
param (
    [int]$UsersAmount
)

Import-Module Microsoft.PowerShell.LocalAccounts

for ($i = 1; $i -lt $UsersAmount+1; $i++) {
    New-LocalUser -Name "User$i" -Password (ConvertTo-SecureString -AsPlainText -String "No_P@ssw0rd!" -force) -AccountNeverExpires:$True -PasswordNeverExpires:$True -UserMayNotChangePassword:$True
    Add-LocalGroupMember -Group Administrators -Member "User$i"
}

# Cleanup
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
