param (
    [string]$ResourceGroupName
)

$NSGName = "ASE-TR-NSG-User"
$RG = $ResourceGroupName
$Location = (Get-AzResourceGroup $ResourceGroupName).Location
$SubnetConfigName = "Subnet5"
$NSGName = "Subnet5-NSG"


# Inbound Rules
$ir1 = New-AzNetworkSecurityRuleConfig -Name "Inbound-management" -Description "Used to manage ASE from public VIP" `
    -Access Deny -Protocol * -Direction Inbound -Priority 100 -SourceAddressPrefix AppServiceManagement `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 454-455

$ir2 = New-AzNetworkSecurityRuleConfig -Name "Inbound-load-balancer-port" -Description "ASE-internal-inbound" `
    -Access Allow -Protocol * -Direction Inbound -Priority 110 -SourceAddressPrefix AzureLoadBalancer `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 16001
    
$ir3 = New-AzNetworkSecurityRuleConfig -Name "ASE-internal-inbound" -Description "ASE-internal-inbound" `
    -Access Allow -Protocol * -Direction Inbound -Priority 120 -SourceAddressPrefix 10.11.4.0/24 `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange *

$ir4 = New-AzNetworkSecurityRuleConfig -Name "Inbound-FTP" -Description "Allow FTP over port 21" `
    -Access Allow -Protocol * -Direction Inbound -Priority 130 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 21     
    
$ir5 = New-AzNetworkSecurityRuleConfig -Name "Inbound-FTPs" -Description "Allow FTPS" `
    -Access Allow -Protocol * -Direction Inbound -Priority 140 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 990 
    
$ir6 = New-AzNetworkSecurityRuleConfig -Name "Inbound-FTP-Data" -Description "Allow FTP Data" `
    -Access Allow -Protocol * -Direction Inbound -Priority 150 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 10001-10020         

$ir7 = New-AzNetworkSecurityRuleConfig -Name "Inbound-Remote-Debugging" -Description "Visual Studio remote debugging" `
    -Access Allow -Protocol * -Direction Inbound -Priority 160 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 4016-4022    

# Outbound Rules
$or1 = New-AzNetworkSecurityRuleConfig -Name "Outbound-80-443" -Description "HTTP/HTTPS" `
    -Access Allow -Protocol * -Direction Outbound -Priority 100 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 443
    
$or2 = New-AzNetworkSecurityRuleConfig -Name "Time-NTP" -Description "Azure Storage queue" `
    -Access Allow -Protocol * -Direction Outbound -Priority 110 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 123

$or3 = New-AzNetworkSecurityRuleConfig -Name "Outbound-DB" -Description "Database" `
    -Access Allow -Protocol * -Direction Outbound -Priority 120 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 1433
    
$or4 = New-AzNetworkSecurityRuleConfig -Name "Outbound-Monitor" -Description "Monitoring" `
    -Access Allow -Protocol * -Direction Outbound -Priority 130 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 12000

$or5 = New-AzNetworkSecurityRuleConfig -Name "ASE-internal-outbound" -Description "Azure Internal Outbound" `
    -Access Allow -Protocol * -Direction Outbound -Priority 160 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix 10.11.4.0/24 -DestinationPortRange * 

$or6 = New-AzNetworkSecurityRuleConfig -Name "Internet-Outbound" -Description "Internet Outbound" `
    -Access Deny -Protocol * -Direction Outbound -Priority 1000 -SourceAddressPrefix * `
    -SourcePortRange * -DestinationAddressPrefix Internet -DestinationPortRange *

New-AzNetworkSecurityGroup -Name $NSGName -ResourceGroupName $RG -SecurityRules $ir1,$ir2,$ir3,$ir4,$ir5,$ir6,$ir7,$or1,$or2,$or3,$or4,$or5,$or6 -Location $Location

Start-Sleep -Seconds 30

$VNet = Get-AzVirtualNetwork -Name "ASE-TR-VNET" -ResourceGroupName $RG
$SubnetConfig = Get-AzVirtualNetworkSubnetConfig -Name ($SubnetConfigName) -VirtualNetwork $VNet
Set-AzVirtualNetworkSubnetConfig -Name $SubnetConfig.Name -VirtualNetwork $VNet -AddressPrefix $SubnetConfig.AddressPrefix -NetworkSecurityGroup $NSGName
$VNet | Set-AzVirtualNetwork