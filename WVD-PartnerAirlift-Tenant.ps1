# How to create another tenant for WVD or a new tenant from scratch
# If you have not already done so please execute the consent here using your AAD GA account  
# RDBroker : https://rdweb.wvd.microsoft.com/

<------------------------------------------------------------------------------------------------------------------>
# Check your PS version 
$PSVersionTable.PSVersion

#Run the below if unsure you have unrestricted rights
Set-ExecutionPolicy unrestricted

#Install the WVD modules for PS if you do not have them
Install-Module -Name Microsoft.RDInfra.RDPowerShell

#Import them if you already installed them
Import-module Microsoft.RDInfra.RDPowershell.dll

#Sign-in to the WVD Service
Add-RDSAccount -DeploymentUrl https://rdbroker.wvd.microsoft.com 

#Set the context
Set-RdsContext -TenantGroupName "XXXXXXXXX"

<------------------------------------------------------------------------------------------------------------------>

#In Azure Portal, make your user a owner\contributor of the subscription

#Bounce over to the Azure AD portal, click enterprise applications. Search for Windows Virtual Desktop. Users and Groups. Add role assignment there.

<------------------------------------------------------------------------------------------------------------------>

#Execute the below to create a new tenant
New-RdsTenant -Name "wvdairlift" -AadTenantId bad69d79-XXXX-4e94-XXXX-966cbd2d9933 -AzureSubscriptionId a5915b41-XXXX-4f34-XXXX-5019fcc116e3

#Set the context to the new tenant
Set-RdsTenant -Name "wvdairlift" 

#Assign the WVD role to the user for the tenant
New-RdsRoleAssignment -SignInName wvduser1@mycloud.com -RoleDefinitionName "RDS Owner" -TenantName "wvdairlift" -AadTenantId bad69d79-XXX-4e94-XXX-966cbd2d9933

#Assign the WVD role to the user for the tenantgroup 
New-RdsRoleAssignment -SignInName wvduser1@mycloud.com -RoleDefinitionName "RDS Owner" -TenantGroupName "XXXXXX" -AadTenantId bad69d79-XXX-4e94-XXXX-966cbd2d9933

<------------------------------------------------------------------------------------------------------------------>

########## Validation ##########

#Login and test the account
Add-RDSAccount -DeploymentUrl https://rdbroker.wvd.microsoft.com

#Set the context
Set-RdsContext -TenantGroupName "XXXXX"

#Set the context to the new tenant
Set-RdsTenant -Name "wvdairlift"

#Get role assignment
Get-RdsRoleAssignment -TenantName "wvdairlift"

<------------------------------------------------------------------------------------------------------------------>

#Create Host Pool Options - Design considerations - Skus\User Persona\LOB\Departments
New-RdsHostPool -TenantName wvdairlift -Name partnerair
New-RdsHostPool -TenantName wvdairlift -Name partnerair -Persistent
New-RdsHostPool -TenantName wvdairlift -Name partnerair -ValidationEnv $true

# Existing Hostpool
Set-RdsHostPool -TenantName wvdairlift -Name "partnerair" -ValidationEnv $true            
Get-RdsHostPool -TenantName wvdairlift -Name "partnerair" -ValidationEnv $true            


## Display all Host Pools in this tenant
$HP = Get-RdsHostPool -TenantName wvdairlift | Out-GridView -Title 'The Hostpools are....'

## Display application groups
$AG = get-rdsappgroup -TenantName wvdairlift -HostPoolName partnerair | Out-GridView -Title 'Applications Groups'

## Display users to application group mapping
$User = Get-RdsAppGroupUser -TenantName wvdairlift -HostPoolName partnerair -AppGroupName “Desktop Application Group” | Out-GridView -Title 'Desktop Application Group') | Out-GridView -Title 'Users to Desktop Application Group'

## Display applications published
$apps = Get-RdsRemoteApp wvdairlift partnerair -AppGroupName 'Applications' | Out-GridView -Title 'All Applications'

## Display Roleassignments
$RA = Get-RdsRoleAssignment -TenantName wvdairlift | Out-GridView -Title 'All RDS Roles assigned'

