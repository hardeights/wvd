# wvd
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

