#
# Script Version 1.0a                                                                                #
# Created by John.Jenner@microsoft.com                                                               #
# Date: 4-15-19                                                                                      #
# Windows Virtual Desktop Removing a Hostpool, Applications groups, Applications and session hosts   #
# Get all hostpools and rds owners assigned                                                          #
#                                                                                                    #
######################################################################################################
#
#
# # # # # # # # READ ME READ ME READ ME READ ME READ ME READ ME # # # # # # # # 
#
# The first selection (Hostpool) takes that choice and uses that for the rest of the menu options. 
# If you need to change the (Hostpool Name) then go back and select. All actions are based on the
# HostPool name you select. 
#
#
# You must login with your own credentials, Set the group and the name with YOUR AZURE SUBSCRIPTION.
#
# Set the variable $Tenant = "" to match your own environment
#
# $Login = Add-RDSAccount -DeploymentUrl https://rdbroker.wvd.microsoft.com -Credential XXXX@XXXX.onmicrosoft.com
# $Tenantgrp = Set-RdsContext -TenantGroupName "XXXXX" 
# Set-RdsTenant -Name "XXXXXX" -AzureSubscriptionId a5915b41-XXXX-XXX-9dcc-5019fcc116e3 
# $Tenant = "XXXXXXX"


Install-Module -Name Microsoft.RDInfra.RDPowerShell

CLS

do {
    do {
        write-host ""
        write-host "A - Delete Windows Virtual Desktop HostPool"
        write-host "B - Delete Windows Virtual Desktop Application Group"
        write-host "C - Delete Windows Virtual Desktop Applications"
        write-host "D - Delete Windows Virtual Desktop Session-Host"
        write-host "E - Show Exisiting Host Pools In Your WVD Tenant"
        write-host "F - Show RDS Owners Of Your WVD Tenant"
        write-host ""
        write-host "X - Exit"
        write-host ""
        write-host -nonewline "Please Select an option and press Enter: "
        
        $choice = read-host
        
        write-host ""
        
        $ok = $choice -match '^[abcdefghijklmnox]+$'
        
        if ( -not $ok) { write-host "Invalid selection" }
    } until ( $ok )
    
    switch -Regex ( $choice ) {
        "A"
        {
            $HostPoolchoice = Get-RdsHostPool -TenantName $Tenant | Select-Object -Property HostPoolName

If($HostPoolchoice.Count -gt 1){
    $Title = "Windows Virtual Desktop HostPool Selection"
    $Message = "Which HostPool do you want to remove?, If you see *RED TEXT* below stating there are application groups left, please run next script"

    # Build the Choices menu
    $Choices = @()
    For($Index = 0; $Index -lt $HostPoolchoice.Count; $Index++){
        $Choices += New-Object System.Management.Automation.Host.ChoiceDescription ($HostPoolchoice[$Index]).HostPoolName
    }

    $Options = [System.Management.Automation.Host.ChoiceDescription[]]$Choices
    $Result = $host.ui.PromptForChoice($Title, $Message, $Options, 0) 

    $HostPoolchoice = $HostPoolchoice[$Result]
    write-host = (Remove-RdsHostPool -TenantName $Tenant -HostPoolName $HostPoolchoice.HostPoolName)
}
If($HostPoolchoice.Count -eq 1){
    $Title = "Delete Remaining HostPool?"
    $Message = "Do you want to delete the last HostPool?"

    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Deletes the last HostPool."
    $No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Keeps the last HostPool."
    $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
    $Result = $host.ui.PromptForChoice($Title, $Message, $Options, 0)

switch ($Result)
{
0 {Write-Host ("`n`t", (write-host = (Remove-RdsHostPool -TenantName $Tenant -HostPoolName $HostPoolchoice.HostPoolName))) `n`, -Fore Yellow} 
1 {"You selected No. No change has been made"}
}
}
$HostPoolchoice
        }
        
        "B"
        {
            $Appgrpnames = get-rdsappgroup -TenantName $Tenant -HostPoolName $HostPoolchoice.HostPoolName

If($Appgrpnames.Count -gt 1){
    $Title = "Windows Virtual Desktop Application Group Selection"
    $Message = "Which Application Group do you want to remove? If you see *RED TEXT* please remove applications frist by running the next script"

    # Build the Choices menu
    $Choices = @()
    For($Index = 0; $Index -lt $Appgrpnames.Count; $Index++){
        $Choices += New-Object System.Management.Automation.Host.ChoiceDescription ($Appgrpnames[$Index]).AppGroupName
    }

    $Options = [System.Management.Automation.Host.ChoiceDescription[]]$Choices
    $Result = $host.ui.PromptForChoice($Title, $Message, $Options, 0) 

    $Appgrpnames = $Appgrpnames[$Result]
    write-host = (Remove-RdsAppGroup -TenantName $Tenant -HostPoolName $HostPoolchoice.HostPoolName -AppGroupName $Appgrpnames.AppGroupName)
}
If($Appgrpnames.Count -eq 1){
    $Title = "Delete Remaining Application Group?"
    $Message = "Do you want to delete the last Application Group?"

    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Deletes the last Application Group."
    $No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Keeps the last Application Group."
    $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
    $Result = $host.ui.PromptForChoice($Title, $Message, $Options, 0)

switch ($Result)
{
0 {Write-Host ("`n`t", (write-host = (Remove-RdsAppGroup -TenantName $Tenant -HostPoolName $HostPoolchoice.HostPoolName -AppGroupName $Appgrpnames.AppGroupName))) `n`, -Fore Yellow} 
1 {"You selected No. No change has been made"}
}
}
$Appgrpnames
        }

        "C"
        {
            $Applications = Get-RdsRemoteApp $Tenant $HostPoolchoice.HostPoolName -AppGroupName $Appgrpnames.AppGroupName

If($Applications.Count -gt 1){
    $Title = "Windows Virtual Desktop Applications Selection"
    $Message = "Which Applications do you want to remove? Once complete, please try and run the remove application group script again"

    # Build the Choices menu
    $Choices = @()
    For($Index = 0; $Index -lt $Applications.Count; $Index++){
        $Choices += New-Object System.Management.Automation.Host.ChoiceDescription ($Applications[$Index]).RemoteAppName
    }

    $Options = [System.Management.Automation.Host.ChoiceDescription[]]$Choices
    $Result = $host.ui.PromptForChoice($Title, $Message, $Options, 0) 

    $Applications = $Applications[$Result]
    write-host = (Remove-RdsRemoteApp $Tenant $HostPoolchoice.HostPoolName $Appgrpnames.AppGroupName $Applications.RemoteAppName)
}
If($Applications.Count -eq 1){
    $Title = "Delete Remaining Application"
    $Message = "Do you want to delete the remaining Application?"

    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Deletes the last application."
    $No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Keeps the last application."
    $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
    $Result = $host.ui.PromptForChoice($Title, $Message, $Options, 0)

switch ($Result)
{
0 {Write-Host ("`n`t", (write-host = (Remove-RdsRemoteApp $Tenant $HostPoolchoice.HostPoolName $Appgrpnames.AppGroupName $Applications.RemoteAppName))) `n`, -Fore Yellow} 
1 {"You selected No. No change has been made"}
}
}
$Applications
        }

        "D"
        {
            $SessionHostDel = (get-rdssessionhost -TenantName $Tenant -HostPoolName $HostPoolchoice.HostPoolName)

If($SessionHostDel.Count -gt 1){
    $Title = "Windows Virtual Desktop Session-Host Selection"
    $Message = "Which Session Host do you want to remove?"

    # Build the Choices menu
    $Choices = @()
    For($Index = 0; $Index -lt $SessionHostDel.Count; $Index++){
        $Choices += New-Object System.Management.Automation.Host.ChoiceDescription ($SessionHostDel[$Index]).SessionHostName
    }

    $Options = [System.Management.Automation.Host.ChoiceDescription[]]$Choices
    $Result = $host.ui.PromptForChoice($Title, $Message, $Options, 0) 

    $SessionHostDel = $SessionHostDel[$Result]
    write-host = (Remove-RdsSessionHost -TenantName $Tenant -HostPoolName $HostPoolchoice.HostPoolName -Name $SessionHostDel.SessionHostName -Force)
}
If($SessionHostDel.Count -eq 1){
    $Title = "Delete Remaining Session Host?"
    $Message = "Do you want to delete the remaining Session Host?"

    $Yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Deletes the last Session Host."
    $No = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Keeps the last Session Host."
    $Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
    $Result = $host.ui.PromptForChoice($Title, $Message, $Options, 0)

switch ($Result)
{
0 {Write-Host ("`n`t", (write-host = (Remove-RdsSessionHost -TenantName $Tenant -HostPoolName $HostPoolchoice.HostPoolName -Name $SessionHostDel.SessionHostName -Force))) `n`, -Fore Yellow} 
1 {"You selected No. No change has been made"}
}
}
$SessionHostDel
        }

        "E"
        {Get-RdsHostPool -TenantName $Tenant | Select-Object -Property HostPoolName | Out-GridView -Title 'All Hostpools'}

        "F"
        {Get-RdsRoleAssignment -TenantName $Tenant | Select-Object -Property TenantGroupName,SignInName,RoleDefinitionName | Out-GridView -Title 'All Role Assignments'}
    }
} until ( $choice -match "X" )