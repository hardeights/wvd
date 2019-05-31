# STEP 1 - optional
# Make sure you can run PS in unrestricted mode
Set-ExecutionPolicy unrestricted

# STEP 2 Import\Install Module
Install-Module -Name Microsoft.RDInfra.RDPowerShell

# Step 3 login global admin of AAD tenant
Add-RDSAccount -DeploymentUrl https://rdbroker.wvd.microsoft.com

# Set the context 
Set-RdsContext -TenantGroupName "Microsoft Internal or your default group"

#Set the tenant
Set-RdsTenant -Name "jojenner" -AzureSubscriptionId "dfg456545445645745"

# Step 4 - Add other accounts to the WVD Tenant
New-RdsRoleAssignment -SignInName USER@XXXX.onmicrosoft.com -RoleDefinitionName "RDS Owner" -TenantName "XXXX"

# STEP 5 RUNNING LIST OF HOSTPOOL ASSIGNMENTS HOUSE CLEANING
$tenant = "XXXX"
$Hostpool = "win10apps1"

# STEP 6 Create new host pools, remove hostpools and session hosts for desktop sharing and applications
# Get-RdsHostPool -TenantName $tenant > c:\list.txt -Name $Hostpool4       -Persistent for 1:1 desktops in the pool
# Set-RdsHostPool -TenantName $tenant -Name $Hostpool1 -Description "Office 365 with FSX UPD and Application Masking" 
New-RDSHostPool $tenant -Name $Hostpool
New-RdsHostPool -TenantName $tenant -Name $Hostpool -Persistent            

# OPTIONAL STEP TO ENABLE OR DISABLE REVERSE CONNECT. If off, then you need PIP and NSG options
# Use Reverse Connect is True by default, use "0" to turn it off when first starting out to get it working. Use "1" to turn it back on
Set-RdsHostPool $tenant $Hostpool -UseReverseConnect 0

# to remove a session host from a hostpool
# get-rdssessionhost -TenantName $tenant -HostPoolName $Hostpool2
Remove-RdsSessionHost -TenantName $tenant -HostPoolName $Hostpool -Name "XXXX.mycloud.com" -Force

# Must remove all app groups before you can remove hostpool
Remove-RdsAppGroup -TenantName $tenant -HostPoolName $Hostpool -AppGroupName "Desktop Application Group"
New-RdsAppGroup -TenantName $tenant -HostPoolName $Hostpool -AppGroupName "Applications"

# Remove Hostpool
Remove-RdsHostPool -TenantName $tenant -HostPoolNam $Hostpool
Remove-RdsHostPool -TenantName $tenant -HostPoolNam $Hostpool

# STEP 7 Create token key to be used on session hosts to register them to the pool if using the manual method 
New-RdsRegistrationInfo -TenantName $tenant -HostPoolName $Hostpool -ExpirationHours 120 | Select-Object -ExpandProperty Token
Export-RdsRegistrationInfo -TenantName $tenant -HostPoolName $Hostpool | Select-Object -ExpandProperty Token

# STEP 8 Add users to the desktop sharing group or application group 
# use wvdapps3 to show the E5 license and FSX application masking for O365 $Hostpool1 = "win10apps2"
# use wvduser2 to show FSX Masking and how the user can't run any office apps $Hostpool1 = "win10apps2"
Add-RdsAppGroupUser -TenantName $tenant -HostPoolName $Hostpool6 -AppGroupName “Applications” -UserPrincipalName wvduser1@mycloud.com
Add-RdsAppGroupUser -TenantName $tenant -HostPoolName $Hostpool3 -AppGroupName “Desktop Application Group” -UserPrincipalName wvdapps3@mycloud.com


# STEP 9 Create new group for published applications called 'applications'
New-RdsAppGroup $tenant $Hostpool Applications -ResourceType “RemoteApp”

# List apps in appgroup
get-rdsappgroup -TenantName $tenant -HostPoolName $Hostpool -Name "Desktop Application Group"

# STEP 10 Add users to the application group -----NOTE these users can't belong to the same host pool if combining desktop sharing and application sharing groups, they can only beling to 1 group
Add-RdsAppGroupUser -TenantName $tenant -HostPoolName $Hostpool -AppGroupName “Applications” -UserPrincipalName wvduser2@mycloud.com

# Get User to application mapping
Get-RdsAppGroupUser -TenantName $tenant -HostPoolName $Hostpool -AppGroupName “Applications” -UserPrincipalName wvduser2@mycloud.com
Get-RdsAppGroupUser -TenantName $tenant -HostPoolName $Hostpool -AppGroupName “Desktop Application Group” -UserPrincipalName wvduser2@mycloud.com

# Remove user from app group
Remove-RdsAppGroupUser -TenantName $tenant -HostPoolName $Hostpool -AppGroupName “Desktop Application Group” -UserPrincipalName wvduser2@mycloud.com

# STEP 11 Create applications to be shared out of session hosts
# New-RdsRemoteApp $tenant1 $Hostpool1 applications <remoteappname> -Filepath <filepath>  -IconPath <iconpath> -IconIndex <iconindex>
New-RdsRemoteApp $tenant $Hostpool Applications "Server Manager" -Filepath "C:\Windows\system32\ServerManager.exe -IconPath C:\Windows\system32\svrmgrnc.dll" -IconIndex 0
New-RdsRemoteApp $tenant $Hostpool Applications "wordpad" -Filepath "C:\Program Files\Windows NT\Accessories\wordpad.exe" -IconPath "C:\Program Files\Windows NT\Accessories\wordpad.exe" -IconIndex 0
New-RdsRemoteApp $tenant $Hostpool Applications "Remote Desktop Connection" -Filepath "C:\Windows\system32\mstsc.exe -IconPath C:\Windows\system32\mstsc.exe" -IconIndex 0

# Office 365 Pro Plus locally installed 
New-RdsRemoteApp $tenant $Hostpool Applications "Office 365 - Word" -Filepath "C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.EXE" -IconPath "C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.EXE" -IconIndex 0
New-RdsRemoteApp $tenant $Hostpool Applications "Office 365 - PowerPoint" -Filepath "C:\Program Files (x86)\Microsoft Office\root\Office16\POWERPNT.EXE" -IconPath "C:\Program Files (x86)\Microsoft Office\root\Office16\POWERPNT.EXE" -IconIndex 0

# Query the system for applications in a remoteapp group
Get-RdsRemoteApp $tenant $Hostpool -AppGroupName 'Applications'

# To remove an app from an app group
Remove-RdsRemoteApp $tenant $Hostpool applications "Remote Desktop Connection"
Remove-RdsRemoteApp $tenant $Hostpool applications "Calculator" 
Remove-RdsRemoteApp $tenant $Hostpool applications "excel" 

# OPTIONAL STEP RENAME SESSION HOST DESKTOP ICONS 
Set-RdsRemoteDesktop -TenantName $tenant -HostPoolName $Hostpool -AppGroupName "Desktop Application Group" -FriendlyName "win10origsso"

# Diagnostics
Get-RdsDiagnosticActivities -TenantName $tenant -Detailed
Get-RdsDiagnosticActivities -TenantName $tenant -ActivityId e3cad88a-cd21-4d1c-b1ba-3fc55faf0000
Get-RdsDiagnosticActivities -TenantName $tenant -UserName wvdapps3@mycloud.com 
Get-RdsDiagnosticActivities -TenantName $tenant -ActivityType Management

# SPN Creation 
$myTenantGroupName = "Microsoft Internal"
$myTenantName = "XXXX"
$powerShellLocation = "C:\Users\XXX\Documents\2019\Windows Virtual Desktop\RDPowershell" 

Import-Module AzureAD
$aadContext = Connect-AzureAD
$svcPrincipal = New-AzureADApplication -AvailableToOtherTenants $true -DisplayName "WVD Svc Principal"
$svcPrincipalCreds = New-AzureADApplicationPasswordCredential -ObjectId $svcPrincipal.ObjectId

Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"
Set-RdsContext -TenantGroupName $myTenantGroupName
New-RdsRoleAssignment -RoleDefinitionName "RDS Owner" -ApplicationId $svcPrincipal.AppId -TenantGroupName $myTenantGroupName -TenantName $myTenantName

$creds = New-Object System.Management.Automation.PSCredential($svcPrincipal.AppId, (ConvertTo-SecureString $svcPrincipalCreds.Value -AsPlainText -Force))
Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com" -Credential $creds -ServicePrincipal -AadTenantId $aadContext.TenantId.Guid

# RDP Printer and USB redirection - Need to change to disabled
# gpedit local computer Computer Configuration \ Administrative Templates \ Windows Components \ Remote Desktop Services \ Remote Desktop Session Hosts \ Device and Resource Redirection \ Do not allow clipboard redirection