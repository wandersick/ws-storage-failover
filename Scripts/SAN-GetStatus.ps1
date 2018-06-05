
# ------------------------------------------------------------------------------------------------------------------------
#
#   General Storage Failover and Failback PowerShell Scripts (Template) for Failover Cluster (e.g. Hyper-V)
#   with an Easy-to-Use Interactive Console Menu for Operators
#   by @wandersick - https://wandersick.blogspot.com
#
#   Version: 1.0 (first-released December 2014)
#
#   Subscript Name: SAN Storage System - Get Status (SAN-GetStatus.ps1)
#
#   Purpose: Status querying subscript called by Console Menu script
#
# ------------------------------------------------------------------------------------------------------------------------

Function checkStatus() {
	$serverTypeArg = $args[0]
	$SiteArg = $args[1]

	if ($serverTypeArg -eq 1) {
		$ServerType = "Hyper-V Server"
	} elseif ($serverTypeArg -eq 0) {
		$ServerType = "General Server"
	}
	
	if ($SiteArg -eq "Prod") {
		$sanCmdExePt = "$varSanSystemProd `($($storIpAddrPRODsite)`)"
		$sanCmdExeDirection = "from PRODsite to DRsite"
	} else {
		$sanCmdExePt = "$varSanSystemDR `($($storIpAddrDRsite)`)"
		$sanCmdExeDirection = "from DRsite to PRODsite"
	}
	
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailCs -end
	Echo "`r`n[CS_030_PRODsite_SAN] Examine Replication Status for $ServerType $sanCmdExeDirection`r`n" | tee $logFailCs -end
	Echo "SAN command to be executed on $($sanCmdExePt):`r`n" | tee $logFailCs -end
	Echo <# display tasks #> | tee $logFailCs -end
	Echo <# display remote replication tasks#> | tee $logFailCs -end
	Echo "" | tee $logFailCs -end
	$answer = Read-Host "Input [A] to accept or press [Enter] to cancel..."
	Switch -regex ($answer)
	{
		"A|a"{
			continue
		 }
		default {
			return
		 }
	}
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailCs -end

	Foreach ( $xmlLUN in $LUN.label ) {
		Echo "`r`n|| Showing replication tasks for `"$xmlLUN`"`r`n" | tee $logFailCs -end
		Run-Plink-PRODsite -exec <# command which outputs a list of tasks #> | findstr /i "$xmlLUN" 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailCs } $_ } | tee $logFailCs -end
	}

	Echo "`r`n|| Showing status for replication group `"$xmlRemoteReplGroupProd`"`r`n" | tee $logFailCs -end
	$sanCmd = <# display remote replication groups for $xmlRemoteReplGroupProd #>
	Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailCs } $_ } | tee $logFailCs -end

	Echo "" | tee $logFailCs -end
	Pause
}

# Supported arguments
# args[0]: ServerType (0=GenServ|1=VirtServ|All=Examine all servers)
# args[1]: Site (PRODsite|DRsite)

