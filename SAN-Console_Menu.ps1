
# ------------------------------------------------------------------------------------------------------------------------
#
#   General Storage Failover and Failback PowerShell Scripts (Template) for Failover Cluster (e.g. Hyper-V)
#   with an Easy-to-Use Interactive Console Menu for Operators
#   by @wandersick - https://wandersick.blogspot.com
#
#   Version: 1.0 (first-released December 2014)
#
#   SAN Storage System - Console Menu (SAN-Console_Menu.ps1)
#
#   Purpose: Menu for selecting among operations of failover, failback, validation, etc.
#
# ------------------------------------------------------------------------------------------------------------------------

# Configure script folder

$ScriptDir = $PSScriptRoot
$Hostname=[System.Net.Dns]::GetHostName()
$Logo="Operation Menu"

# Test path and load initial parameters file

if (!(Test-Path "$($ScriptDir)\Parameters\SAN-Parameters.ps1")) {
	Write-Error "Config file `"$($ScriptDir)\Parameters\SAN-Parameters.ps1`" does not exist"
	exit
}

# Menu for checking replication status

Function status_menu()
{
		:status_menu while (1)
		{
			clear
			Get-Date -UFormat "`n  %Y-%m-%d | %T | %A | UTC%Z | $Hostname | $env:USERNAME"
			Write-Host ""
			Write-Host "  :: $Logo > Status Menu > $selectedServerName"
			Write-Host ""
			Write-Host "  A. Examine Replication Status - from Prod to DR"
			Write-Host "  z. Back to Server Selection Menu"
			Write-Host "" 
			Write-Host $msg
			$answer = Read-Host "  :: Please make a selection"
			$msg=""
			
			switch -regex ($answer)
			{
				"A|a"{
					checkStatus $selectedServer Prod
				 }
				"B|b"{
					checkStatus $selectedServer DR
				}
				"Z|z"{
					break status_menu
				}
				default{
					$msg="`n  :: INFO - Wrong selection`n"
				 }
			}
		}
}

# Pre-failover menu

Function failover_pre_menu()
{
   :failover_pre_menu while(1)
	{
		clear
		Get-Date -UFormat "`n  %Y-%m-%d | %T | %A | UTC%Z | $Hostname | $env:USERNAME"
		Write-Host ""
		Write-Host "  :: $Logo > Procedure Selection > $selectedServerName"
		Write-Host ""
		Write-Host "  A. Disaster Recovery"
		Write-Host "  B. Fallback after Disaster Recovery"
		Write-Host "  z. Back to Server Selection Menu"
		Write-Host ""
		Write-Host $msg
		$answer = Read-Host "  :: Please make a selection"
		$msg=""
		
		switch -regex ($answer)
		{   
		   "A|a"{
				failover_menu $selectedServer
				$msg=""
			}
		   "B|b"{
				failover_fallback_menu $selectedServer
				$msg=""
			}
			"Z|z"{
				break failover_pre_menu
			}
			default {
				$msg="`n  :: INFO - Wrong selection`n"
			}
		}
	}
}

Function failover_fallback_menu()
{
	$msg=""

	:failover_fallback_menu while (1)
	{
		clear
		Get-Date -UFormat "`n  %Y-%m-%d | %T | %A | UTC%Z | $Hostname | $env:USERNAME"
		Write-Host ""
		Write-Host "  :: $Logo > Fallback after Disaster Recovery > $selectedServerName"
		Write-Host ""
		if ($selectedServer -eq 0) {
			# General Server
			Write-Host "  A. [FAILOV_050_DRsite_SAN] Unpresent Old Cloned Copy and Source LUN from DR Host"
			Write-Host "  B. [FAILOV_060_DRsite_SAN] Delete Old Cloned Copy LUN in DR Site"
			Write-Host "  C. Perform All of the Above"
		} elseif ($selectedServer -eq 1) {
			# Hyper-V Server
			Write-Host "  A. [FAILOV_040_DRsite_WIN] Delete VM in DR Site"
			Write-Host "  B. [FAILOV_050_DRsite_SAN] Unpresent Old Cloned Copy and Source LUN from DR Host"
			Write-Host "  C. [FAILOV_060_DRsite_SAN] Delete Old Cloned Copy LUN in DR Site"
			Write-Host "  D. Perform All of the Above"
		}
		Write-Host "  z. Back to Procedure Selection Menu"
		Write-Host ""
		Write-Host $msg
		$answer = Read-Host "  :: Please make a selection"
		$msg=""
		
		switch -regex ($answer)
		{   
			"A|a"{
				if ($selectedServer -eq 0) {
					FAILOV_050_DRsite_SAN_RemovePresentedLUN_Clone
				} elseif ($selectedServer -eq 1) {
					FAILOV_040_DRsite_WIN_RemoveVM
				}
			}
			"B|b"{
				if ($selectedServer -eq 0) {
					FAILOV_060_DRsite_SAN_RemoveLun_Clone
				} elseif ($selectedServer -eq 1) {
					FAILOV_050_DRsite_SAN_RemovePresentedLUN_Clone
				}
			}
			"C|c"{
				if ($selectedServer -eq 0) {
					FAILOV_050_DRsite_SAN_RemovePresentedLUN_Clone
					FAILOV_060_DRsite_SAN_RemoveLun_Clone
				} elseif ($selectedServer -eq 1) {
					FAILOV_060_DRsite_SAN_RemoveLun_Clone
				}
			}
			"D|d"{
				if ($selectedServer -eq 0) {
					$msg="`n  :: INFO - Wrong selection`n"
				} elseif ($selectedServer -eq 1) {
					FAILOV_040_DRsite_WIN_RemoveVM
					FAILOV_050_DRsite_SAN_RemovePresentedLUN_Clone
					FAILOV_060_DRsite_SAN_RemoveLun_Clone
				}
			}
			"Z|z"{
				break failover_fallback_menu
			}
			default {
				$msg="`n  :: INFO - Wrong selection`n"
		   }
		}
	}
}

# Menu for failover

Function failover_menu()
{
	$msg=""

	:failover_menu while (1)
	{
		clear
		Get-Date -UFormat "`n  %Y-%m-%d | %T | %A | UTC%Z | $Hostname | $env:USERNAME"
		Write-Host ""
		Write-Host "  :: $Logo > Disaster Recovery Failover from Production site to DR site > $selectedServerName"
		Write-Host ""
		if ($selectedServer -eq 0) {
			# General Server
			Write-Host "  A. [FAILOV_030_PRODsite_SAN] End Replication - from Prod to DR"
			Write-Host "  B. [FAILOV_070_DRsite_SAN] Create Clone from Replicated LUN in DR Site"
			Write-Host "  C. [FAILOV_080_DRsite_ALL] Present Cloned LUN to DR Host, Take Disk Online, Run Replication from Prod to DR"
			Write-Host "  D. Perform All of the Above"
		} elseif ($selectedServer -eq 1) {
			# Hyper-V Server
			Write-Host "  A. [FAILOV_030_PRODsite_SAN] End Replication - from Prod to DR"
			Write-Host "  B. [FAILOV_070_DRsite_SAN] Create Clone from Replicated LUN in DR Site"
			Write-Host "  C. [FAILOV_080_DRsite_ALL] Present Cloned LUN to DR Host, Take Disk Online, Run Replication from Prod to DR"
			Write-Host "  D. [FAILOV_090_DRsite_WIN] Import VM in DR Site"
			Write-Host "  E. [FAILOV_095_DRsite_WIN] Disconnect VM Network Adapter in DR Site"
			Write-Host "  F. Perform All of the Above"
		}
		Write-Host "  z. Back to Procedure Selection Menu"
		Write-Host ""
		Write-Host $msg
		$answer = Read-Host "  :: Please make a selection"
		$msg=""
		
		Switch -regex ($answer)
		{   
			"A|a"{
				if ($selectedServer -eq 0) {
					FAILOV_030_PRODsite_SAN_StopRemoteRepl
				} elseif ($selectedServer -eq 1) {
					FAILOV_030_PRODsite_SAN_StopRemoteRepl
				}
			}
			"B|b"{
				if ($selectedServer -eq 0) {
					FAILOV_070_DRsite_SAN_CreateLunCopy_Clone
				} elseif ($selectedServer -eq 1) {
					FAILOV_070_DRsite_SAN_CreateLunCopy_Clone
				}
			}
			"C|c"{
				if ($selectedServer -eq 0) {
					FAILOV_080_DRsite_ALL_CreatePresentedLUNClone_OnlineDisk_StartRepl
				} elseif ($selectedServer -eq 1) {
					FAILOV_080_DRsite_ALL_CreatePresentedLUNClone_OnlineDisk_StartRepl
				}
			}
			"D|d"{
				if ($selectedServer -eq 0) {
					FAILOV_030_PRODsite_SAN_StopRemoteRepl
					FAILOV_070_DRsite_SAN_CreateLunCopy_Clone
					FAILOV_080_DRsite_ALL_CreatePresentedLUNClone_OnlineDisk_StartRepl
				} elseif ($selectedServer -eq 1) {
					FAILOV_090_DRsite_WIN_ImportVM
				}
			}
			"E|e"{
				if ($selectedServer -eq 0) {
					$msg="`n  :: INFO - Wrong selection`n"
				} elseif ($selectedServer -eq 1) {
					FAILOV_095_DRsite_WIN_DisconnectVMNetworkAdapter
				}
			}
			"F|f"{
				if ($selectedServer -eq 0) {
					$msg="`n  :: INFO - Wrong selection`n"
				} elseif ($selectedServer -eq 1) {
					FAILOV_030_PRODsite_SAN_StopRemoteRepl
					FAILOV_070_DRsite_SAN_CreateLunCopy_Clone
					FAILOV_080_DRsite_ALL_CreatePresentedLUNClone_OnlineDisk_StartRepl
					FAILOV_090_DRsite_WIN_ImportVM
					FAILOV_095_DRsite_WIN_DisconnectVMNetworkAdapter
				}
			}
			"Z|z"{
				break failover_menu
			}
			default {
				$msg="`n  :: INFO - Wrong selection`n"
		   }
		}
	}
}

# Main menu for failback

Function failback_menu()
{
	$msg=""

	:failback_menu while (1)
	{
		clear
		Get-Date -UFormat "`n  %Y-%m-%d | %T | %A | UTC%Z | $Hostname | $env:USERNAME"
		Write-Host ""
		Write-Host "  :: $Logo > Disaster Recovery Failback from DR site to Production site > $selectedServerName"
		Write-Host ""
		if ($selectedServer -eq 0) {
			Write-Host "  A. [FAILBK_010_PRODsite_SAN] Stop and Delete Replication Group - from Prod to DR (Opt)"
			Write-Host "  B. [FAILBK_020_DRsite_SAN] Stop and Delete Replication Group - from DR to Prod (Opt)"
			# Reusing function from failover procedure
			Write-Host "  C. [FAILBK_030_PRODsite_WIN] Stop CSV in Prod (Opt)"
			Write-Host "  D. [FAILBK_035_PRODsite_SAN] Unpresent LUN of CSV from Prod Hosts (Opt)"
			Write-Host "  E. [FAILBK_040_PRODsite_SAN] Delete LUN of CSV in Prod (Opt)"
			Write-Host "  F. [FAILBK_050_PRODsite_SAN] Create LUN of CSV in Prod"
			Write-Host "  G. [FAILBK_060_DRsite_SAN] Create Replication Group - from DR to Prod"
			Write-Host "  H. [FAILBK_070_DRsite_SAN] Add LUN to Replication Group - from DR to Prod"
			Write-Host "  I. [FAILBK_080_DRsite_SAN] Run Replication Group - from DR to Prod"
			Write-Host "  J. [FAILBK_100_DRsite_WIN] Take Disk Offline in DR Host"
			Write-Host "  K. [FAILBK_110_DRsite_SAN] Unpresent Cloned LUN from DR Host"
			Write-Host "  L. [FAILBK_120_DRsite_SAN] Stop and Delete Replication Group - from DR to Prod"
			Write-Host "  M. [FAILBK_140_PRODsite_SAN] Present LUN of Replicated CSV to Prod Hosts"
			Write-Host "  N. [FAILBK_150_PRODsite_WIN] Run CSV in Prod"
			Write-Host "  O. [FAILBK_180_PRODsite_SAN] Create Replication Group - from Prod to DR"
			Write-Host "  P. [FAILBK_190_PRODsite_SAN] Add LUN to Replication Group - from Prod to DR"
			Write-Host "  Q. [FAILBK_200_PRODsite_SAN] Run Replication Group - from Prod to DR"
			Write-Host "  R. Perform All of the Above"
		} elseif ($selectedServer -eq 1) {
			Write-Host "  A. [FAILBK_010_PRODsite_SAN] Stop and Delete Replication Group - from Prod to DR (Opt)"
			Write-Host "  B. [FAILBK_020_DRsite_SAN] Stop and Delete Replication Group - from DR to Prod (Opt)"
			# Reusing function from failover procedure
			Write-Host "  C. [FAILOV_010_PRODsite_WIN] Stop VM in Prod (Opt)"
			Write-Host "  D. [FAILBK_030_PRODsite_WIN] Stop CSV in Prod (Opt)"
			Write-Host "  E. [FAILBK_032_PRODsite_WIN] Delete VM in Prod (Opt)"
			Write-Host "  F. [FAILBK_035_PRODsite_SAN] Unpresent LUN of CSV from Prod Hosts (Opt)"
			Write-Host "  G. [FAILBK_040_PRODsite_SAN] Delete LUN of CSV in Prod (Opt)"
			Write-Host "  H. [FAILBK_050_PRODsite_SAN] Create LUN of CSV in Prod"
			Write-Host "  I. [FAILBK_060_DRsite_SAN] Create Replication Group - from DR to Prod"
			Write-Host "  J. [FAILBK_070_DRsite_SAN] Add LUN to Replication Group - from DR to Prod"
			Write-Host "  K. [FAILBK_080_DRsite_SAN] Run Replication Group - from DR to Prod"
			Write-Host "  L. [FAILBK_090_DRsite_WIN] Stop VM in DR Site"
			Write-Host "  M. [FAILBK_100_DRsite_WIN] Take Disk Offline in DR Host"
			Write-Host "  N. [FAILBK_110_DRsite_SAN] Unpresent Cloned LUN from DR Host"
			Write-Host "  O. [FAILBK_120_DRsite_SAN] Stop and Delete Replication Group - from DR to Prod"
			Write-Host "  P. [FAILBK_140_PRODsite_SAN] Present LUN of Replicated CSV to Prod Hosts"
			Write-Host "  Q. [FAILBK_150_PRODsite_WIN] Run CSV in Prod"
			Write-Host "  R. [FAILBK_160_PRODsite_WIN] Import VM in Prod"
			Write-Host "  S. [FAILBK_165_PRODsite_WIN] Disconnect VM Network Adapters in Prod"
			Write-Host "  T. [FAILBK_170_PRODsite_WIN] Run VM in Prod"
			Write-Host "  U. [FAILBK_180_PRODsite_SAN] Create Replication Group - from Prod to DR"
			Write-Host "  V. [FAILBK_190_PRODsite_SAN] Add LUN to Replication Group - from Prod to DR"
			Write-Host "  W. [FAILBK_200_PRODsite_SAN] Run Replication Group - from Prod to DR"
			Write-Host "  X. Perform All of the Above"
		}
		Write-Host "  z. Back to Server Selection Menu"
		Write-Host ""
		Write-Host $msg
		$answer = Read-Host "  :: Please make a selection"
		$msg=""
		
		Switch -regex ($answer)
		{   
			"A|a"{
				if ($selectedServer -eq 0) {
					FAILBK_010_PRODsite_SAN_StopRemoveRemoteReplGroup
				} elseif ($selectedServer -eq 1) {
					FAILBK_010_PRODsite_SAN_StopRemoveRemoteReplGroup
				}
			}
			"B|b"{
				if ($selectedServer -eq 0) {
					FAILBK_020_DRsite_SAN_StopRemoveRemoteReplGroup_FailBack
				} elseif ($selectedServer -eq 1) {
					FAILBK_020_DRsite_SAN_StopRemoveRemoteReplGroup_FailBack
				}
			}
			"C|c"{
				if ($selectedServer -eq 0) {
					FAILBK_030_PRODsite_WIN_StopClusterSharedVolume
				} elseif ($selectedServer -eq 1) {
					FAILOV_010_PRODsite_WIN_StopVM
				}
			}
			"D|d"{
				if ($selectedServer -eq 0) {
					FAILBK_035_PRODsite_SAN_RemovePresentedLUN_Csv
				} elseif ($selectedServer -eq 1) {
					FAILBK_030_PRODsite_WIN_StopClusterSharedVolume
				}
			}
			"E|e"{
				if ($selectedServer -eq 0) {
					FAILBK_040_PRODsite_SAN_RemoveLun_Csv
				} elseif ($selectedServer -eq 1) {
					FAILBK_032_PRODsite_WIN_RemoveVM
				}
			}
			"F|f"{
				if ($selectedServer -eq 0) {
					FAILBK_050_PRODsite_SAN_CreateLun_Csv
				} elseif ($selectedServer -eq 1) {
					FAILBK_035_PRODsite_SAN_RemovePresentedLUN_Csv
				}
			}
			"G|g"{
				if ($selectedServer -eq 0) {
					FAILBK_060_DRsite_SAN_CreateRemoteReplGroup_FailBack
				} elseif ($selectedServer -eq 1) {
					FAILBK_040_PRODsite_SAN_RemoveLun_Csv
				}
			}
			"H|h"{
				if ($selectedServer -eq 0) {
					FAILBK_070_DRsite_SAN_AddRemoteReplLun_FailBack
				} elseif ($selectedServer -eq 1) {
					FAILBK_050_PRODsite_SAN_CreateLun_Csv
				}
			}
			"I|i"{
				if ($selectedServer -eq 0) {
					FAILBK_080_DRsite_SAN_StartRemoteReplGroup_FailBack
				} elseif ($selectedServer -eq 1) {
					FAILBK_060_DRsite_SAN_CreateRemoteReplGroup_FailBack
				}
			}
			"J|j"{
				if ($selectedServer -eq 0) {
					FAILBK_100_DRsite_WIN_Diskpart_Offline
				} elseif ($selectedServer -eq 1) {
					FAILBK_070_DRsite_SAN_AddRemoteReplLun_FailBack
				}
			}
			"K|k"{
				if ($selectedServer -eq 0) {
					FAILBK_110_DRsite_SAN_RemovePresentedLUN_Clone
				} elseif ($selectedServer -eq 1) {
					FAILBK_080_DRsite_SAN_StartRemoteReplGroup_FailBack
				}
			}
			"L|l"{
				if ($selectedServer -eq 0) {
					FAILBK_120_DRsite_SAN_StopRemoveRemoteReplGroup_FailBack
				} elseif ($selectedServer -eq 1) {
					FAILBK_090_DRsite_WIN_StopVM
				}
			}
			"M|m"{
				if ($selectedServer -eq 0) {
					FAILBK_140_PRODsite_SAN_CreatePresentedLUN_Csv
				} elseif ($selectedServer -eq 1) {
					FAILBK_100_DRsite_WIN_Diskpart_Offline
				}
			}
			"N|n"{
				if ($selectedServer -eq 0) {
					FAILBK_150_PRODsite_WIN_StartClusterSharedVolume
				} elseif ($selectedServer -eq 1) {
					FAILBK_110_DRsite_SAN_RemovePresentedLUN_Clone
				}
			}
			"O|o"{
				if ($selectedServer -eq 0) {
					FAILBK_180_PRODsite_SAN_CreateRemoteReplGroup
				} elseif ($selectedServer -eq 1) {
					FAILBK_120_DRsite_SAN_StopRemoveRemoteReplGroup_FailBack
				}
			}
			"P|p"{
				if ($selectedServer -eq 0) {
					FAILBK_190_PRODsite_SAN_AddRemoteReplLun
				} elseif ($selectedServer -eq 1) {
					FAILBK_140_PRODsite_SAN_CreatePresentedLUN_Csv
				}
			}
			"Q|q"{
				if ($selectedServer -eq 0) {
					FAILBK_200_PRODsite_SAN_StartRemoteReplGroup
				} elseif ($selectedServer -eq 1) {
					FAILBK_150_PRODsite_WIN_StartClusterSharedVolume
				}
			}
			"R|r"{
				if ($selectedServer -eq 0) {
					FAILBK_010_PRODsite_SAN_StopRemoveRemoteReplGroup
					FAILBK_020_DRsite_SAN_StopRemoveRemoteReplGroup_FailBack
					FAILBK_030_PRODsite_WIN_StopClusterSharedVolume
					FAILBK_035_PRODsite_SAN_RemovePresentedLUN_Csv
					FAILBK_040_PRODsite_SAN_RemoveLun_Csv
					FAILBK_050_PRODsite_SAN_CreateLun_Csv
					FAILBK_060_DRsite_SAN_CreateRemoteReplGroup_FailBack
					FAILBK_070_DRsite_SAN_AddRemoteReplLun_FailBack
					FAILBK_080_DRsite_SAN_StartRemoteReplGroup_FailBack
					FAILBK_100_DRsite_WIN_Diskpart_Offline
					FAILBK_110_DRsite_SAN_RemovePresentedLUN_Clone
					FAILBK_120_DRsite_SAN_StopRemoveRemoteReplGroup_FailBack
					FAILBK_140_PRODsite_SAN_CreatePresentedLUN_Csv
					FAILBK_150_PRODsite_WIN_StartClusterSharedVolume
					FAILBK_180_PRODsite_SAN_CreateRemoteReplGroup
					FAILBK_190_PRODsite_SAN_AddRemoteReplLun
					FAILBK_200_PRODsite_SAN_StartRemoteReplGroup
				} elseif ($selectedServer -eq 1) {
					FAILBK_160_PRODsite_WIN_ImportVM
				}
			}
			"S|s"{
				if ($selectedServer -eq 0) {
					$msg="`n  :: INFO - Wrong selection`n"
				} elseif ($selectedServer -eq 1) {
					FAILBK_165_PRODsite_WIN_DisconnectVMNetworkAdapter
				}
			}
			"T|t"{
				if ($selectedServer -eq 0) {
					$msg="`n  :: INFO - Wrong selection`n"
				} elseif ($selectedServer -eq 1) {
					FAILBK_170_PRODsite_WIN_StartVM
				}
			}
			"U|u"{
				if ($selectedServer -eq 0) {
					$msg="`n  :: INFO - Wrong selection`n"
				} elseif ($selectedServer -eq 1) {
					FAILBK_180_PRODsite_SAN_CreateRemoteReplGroup
				}
			}
			"V|v"{
				if ($selectedServer -eq 0) {
					$msg="`n  :: INFO - Wrong selection`n"
				} elseif ($selectedServer -eq 1) {
					FAILBK_190_PRODsite_SAN_AddRemoteReplLun
				}
			}
			"W|w"{
				if ($selectedServer -eq 0) {
					$msg="`n  :: INFO - Wrong selection`n"
				} elseif ($selectedServer -eq 1) {
					FAILBK_200_PRODsite_SAN_StartRemoteReplGroup
				}
			}
			"X|x"{
				if ($selectedServer -eq 0) {
					$msg="`n  :: INFO - Wrong selection`n"
				} elseif ($selectedServer -eq 1) {
					FAILBK_010_PRODsite_SAN_StopRemoveRemoteReplGroup
					FAILBK_020_DRsite_SAN_StopRemoveRemoteReplGroup_FailBack
					FAILOV_010_PRODsite_WIN_StopVM
					FAILBK_030_PRODsite_WIN_StopClusterSharedVolume
					FAILBK_032_PRODsite_WIN_RemoveVM
					FAILBK_035_PRODsite_SAN_RemovePresentedLUN_Csv
					FAILBK_040_PRODsite_SAN_RemoveLun_Csv
					FAILBK_050_PRODsite_SAN_CreateLun_Csv
					FAILBK_060_DRsite_SAN_CreateRemoteReplGroup_FailBack
					FAILBK_070_DRsite_SAN_AddRemoteReplLun_FailBack
					FAILBK_080_DRsite_SAN_StartRemoteReplGroup_FailBack
					FAILBK_090_DRsite_WIN_StopVM
					FAILBK_100_DRsite_WIN_Diskpart_Offline
					FAILBK_110_DRsite_SAN_RemovePresentedLUN_Clone
					FAILBK_120_DRsite_SAN_StopRemoveRemoteReplGroup_FailBack
					FAILBK_140_PRODsite_SAN_CreatePresentedLUN_Csv
					FAILBK_150_PRODsite_WIN_StartClusterSharedVolume
					FAILBK_160_PRODsite_WIN_ImportVM
					FAILBK_165_PRODsite_WIN_DisconnectVMNetworkAdapter
					FAILBK_170_PRODsite_WIN_StartVM
					FAILBK_180_PRODsite_SAN_CreateRemoteReplGroup
					FAILBK_190_PRODsite_SAN_AddRemoteReplLun
					FAILBK_200_PRODsite_SAN_StartRemoteReplGroup
				}
			}
			"Z|z"{
				break failback_menu
			}
			default {
				$msg="`n  :: INFO - Wrong selection`n"
		   }
		}
	}
}

# Common menu for failover and failback

Function dr_menu()
{
   :dr_menu while(1)
	{
		clear
		Get-Date -UFormat "`n  %Y-%m-%d | %T | %A | UTC%Z | $Hostname | $env:USERNAME"
		Write-Host ""
		Write-Host "  :: $Logo > Server Selection"
		Write-Host ""
		Write-Host "  A. General Server"
		Write-Host "  B. Hyper-V Server"
		Write-Host "  z. Back to Main Menu"
		Write-Host ""
		Write-Host $msg
		$answer = Read-Host "  :: Please make a selection"
		$msg=""
		
		switch -regex ($answer)
		{   
		   "A|a"{
				# Define General Server
				$selectedServer = 0
				$selectedServerName = "General Server"
				$selectedServerNameShort = "GenServ"

				# Load / refresh Parameters with selected server
				. "$($ScriptDir)\Parameters\SAN-Parameters.ps1"

				# XML, path, variable checks

				# Testing Path: XML Config File
				if (!(Test-Path "$xmlConfigFile")) {
					Echo ""
					Echo "ERROR: Config file `"$xmlConfigFile`" does not exist"
					Echo ""
					Pause
				}
				
				# Validate XML Config
				testXMLFile "$xmlConfigFile" -Verbose
				
				# Dynamically acquired values from SAN (UserRaidConfig, ReplRaidConfig, LUNSize)
				$chkError = 0
				
				for ($i=0; $i -lt $LUN.length; $i++) {
					$chkLUNSize = "$($LUN[$i].LUNSize)g"
					$chkUserRaidConfig = "$($LUN[$i].UserRaidConfig)"
					$chkReplRaidConfig = "$($LUN[$i].ReplRaidConfig)"
					if ($chkLUNSize -eq "0g") {
						$chkError = 1
						Echo ""
						Echo "WARNING: Wrong size `"$($chkLUNSize)`" of Disaster Recovery LUN `"$($LUN[$i].label_DR)`" from SAN."
						Echo ""
					}
					if (!($chkUserRaidConfig)) {
						$chkError = 1
						Echo ""
						Echo "WARNING: Wrong UserRaidConfig `"$($chkUserRaidConfig)`" of Disaster Recovery LUN `"$($LUN[$i].label_DR)`" from SAN."
						Echo ""
					}
					if (!($chkReplRaidConfig)) {
						$chkError = 1
						Echo ""
						Echo "WARNING: Wrong ReplRaidConfig `"$($chkReplRaidConfig)`" of Disaster Recovery LUN `"$($LUN[$i].label_DR)`" from SAN."
						Echo ""
					}
				}
				if ($chkError -eq 1) {
					Echo "`r`n********************************************************************************************`r`n"
					Echo 'In order to solve the problem, consider the following:'
					Echo ""
					Echo '- Does the LUN exist on the SAN? (The size and RAID config are to be acquired using the LUN name)'
					Echo '- Is the LUN name too lengthy? (The name displayed in SAN GUI may not exceed certain number of characters, as the logical disks behind LUNs may have a shorter limit on name length)'
					Echo ""
					Echo 'Below sub-routines involving creating LUN and creating cloned copy of LUN may fail.'
					Echo ""
					Echo "1. FAILOV_070_DRsite_SAN"
					Echo "2. FAILBK_050_PRODsite_SAN"
					Echo ""
					Echo 'Kindly correct the problem before running the script.'
					Echo ""
					Echo 'If you must proceed without fixing them (not recommended), you may skip those sub-routines, reconstruct commands of above sub-routine, then run them manually in SAN during failover/failback operation'
					Echo "`r`n********************************************************************************************`r`n"
					Pause
				}

				if ( "$($args[0])" -eq "FAILOVER")
				{
					failover_pre_menu
					$msg=""
				}
				elseif ( "$($args[0])" -eq "FAILBACK" )
				{
					failback_menu $selectedServer
					$msg=""
				}
				elseif ( "$($args[0])" -eq "SUSPEND_RESUME" )
				{
					suspend_resume_menu $selectedServer
					$msg=""
				}
				elseif ( "$($args[0])" -eq "CHECK" )
				{
					status_menu $selectedServer
					$msg=""
				}
				elseif ( "$($args[0])" -eq "VERIFY" )
				{
					testConfig
					$msg=""
				}
			}
		   "B|b"{
				# Define Hyper-V Server
				$selectedServer = 1
				$selectedServerName = "Hyper-V Server"
				$selectedServerNameShort = "VirtServ"

				# Load or refresh parameters from specified server
				. "$($ScriptDir)\Parameters\SAN-Parameters.ps1"

				# Basic checking of XML, path and variables

				# Testing Path of XML config file
				
				if (!(Test-Path "$xmlConfigFile")) {
					Echo ""
					Echo "ERROR: Config file `"$xmlConfigFile`" does not exist"
					Echo ""
					Pause
				}
				
				testXMLFile "$xmlConfigFile" -Verbose

				$chkError = 0
				
				for ($i=0; $i -lt $LUN.length; $i++) {
					$chkLUNSize = "$($LUN[$i].LUNSize)g"
					$chkUserRaidConfig = "$($LUN[$i].UserRaidConfig)"
					$chkReplRaidConfig = "$($LUN[$i].ReplRaidConfig)"
					if ($chkLUNSize -eq "0g") {
						$chkError = 1
						Echo ""
						Echo "WARNING: Wrong size `"$($chkLUNSize)`" of Disaster Recovery LUN `"$($LUN[$i].label_DR)`" from SAN."
						Echo ""
					}
					if (!($chkUserRaidConfig)) {
						$chkError = 1
						Echo ""
						Echo "WARNING: Wrong UserRaidConfig `"$($chkUserRaidConfig)`" of Disaster Recovery LUN `"$($LUN[$i].label_DR)`" from SAN."
						Echo ""
					}
					if (!($chkReplRaidConfig)) {
						$chkError = 1
						Echo ""
						Echo "WARNING: Wrong ReplRaidConfig `"$($chkReplRaidConfig)`" of Disaster Recovery LUN `"$($LUN[$i].label_DR)`" from SAN."
						Echo ""
					}
				}
				if ($chkError -eq 1) {
					Echo "`r`n********************************************************************************************`r`n"
					Echo 'In order to solve the problem, consider the following:'
					Echo ""
					Echo '- Does the LUN exist on the SAN? (The size and RAID config are to be acquired using the LUN name)'
					Echo '- Is the LUN name too lengthy? (The name displayed in SAN GUI may not exceed certain number of characters, as the logical disks behind LUNs may have a shorter limit on name length)'
					Echo ""
					Echo 'Below sub-routines involving creating LUN and creating cloned copy of LUN may fail.'
					Echo ""
					Echo "1. FAILOV_070_DRsite_SAN"
					Echo "2. FAILBK_050_PRODsite_SAN"
					Echo ""
					Echo 'Kindly correct the problem before running the script.'
					Echo ""
					Echo 'If you must proceed without fixing them (not recommended), you may skip those sub-routines, reconstruct commands of above sub-routine, then run them manually in SAN during failover/failback operation'
					Echo "`r`n********************************************************************************************`r`n"
					Pause
				}
				
				if ( "$($args[0])" -eq "FAILOVER")
				{
					failover_pre_menu
					$msg=""
				}
				elseif ( "$($args[0])" -eq "FAILBACK" )
				{
					failback_menu $selectedServer
					$msg=""
				}
				elseif ( "$($args[0])" -eq "SUSPEND_RESUME" )
				{
					suspend_resume_menu $selectedServer
					$msg=""
				}
				elseif ( "$($args[0])" -eq "CHECK" )
				{
					status_menu $selectedServer
					$msg=""
				}
				elseif ( "$($args[0])" -eq "VERIFY" )
				{
					testConfig
					$msg=""
				}
			}
			"Z|z"{
				break dr_menu
			}
			default {
				$msg="`n  :: INFO - Wrong selection`n"
			}
		}
	}
}

Function suspend_resume_menu()
{
		$msg=""
		:suspend_resume_menu while (1)
		{
			clear
			Get-Date -UFormat "`n  %Y-%m-%d | %T | %A | UTC%Z | $Hostname | $env:USERNAME"
			Write-Host ""
			Write-Host "  :: $Logo > End or Begin Replication Groups > $selectedServerName"
			Write-Host ""
			Write-Host "  A. End Replication - from Prod to DR" 
			Write-Host "  B. Begin Replication - from Prod to DR"
			Write-Host "  z. Back to Server Selection Menu"
			Write-Host ""
			Write-Host $msg
			$answer = Read-Host "  :: Please make a selection"
			$msg=""
			
			switch -regex ($answer)
			{   
				"A|a"{
					FAILBK_005_PRODsite_SAN_StopRemoteReplGroup
				}
				"B|b"{
					FAILBK_200_PRODsite_SAN_StartRemoteReplGroup Resume
				}
		   "Z|z"{
				break suspend_resume_menu;
		   }
		   default {
				$msg="`n  :: INFO - Wrong selection`n"
		   }
		}
	}
}

# Main menu (placed at the end)

:MAIN_MENU while (1)
{
	clear
	Get-Date -UFormat "`n  %Y-%m-%d | %T | %A | UTC%Z | $Hostname | $env:USERNAME"
	Write-Host ""
	Write-Host "  :: $Logo > Main"
	Write-Host ""
	Write-Host "  A. Disaster Recovery - Failover (from Prod to DR)"
	Write-Host "  B. Disaster Recovery - Failback (from DR to Prod)"
	Write-Host "  C. End or Begin Replication Groups"
	Write-Host "  D. Examine Replication Status"
	Write-Host "  E. Verify Parameters"
	Write-Host "  q. Quit"
	Write-Host $msg
	$answer = Read-Host "  :: Please make a selection"
	$msg=""
	
	switch -regex ($answer)
	{
		"A|a"{
			
			dr_menu FAILOVER
		 }
		"B|b"{
			
			dr_menu FAILBACK
		 }
		"C|c"{
			dr_menu SUSPEND_RESUME
		}
		"D|d"{
			dr_menu CHECK
		}
		"E|e"{
			dr_menu VERIFY
		}
		"Q|q"{
			break MAIN_MENU
		 }
		default{
			$msg="`n  :: INFO - Wrong selection`n"
		 }
	}
}

