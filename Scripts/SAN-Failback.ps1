
# ------------------------------------------------------------------------------------------------------------------------
#
#   General Storage Failover and Failback PowerShell Scripts (Template) for Failover Cluster (e.g. Hyper-V)
#   with an Easy-to-Use Interactive Console Menu for Operators
#   by @wandersick - https://wandersick.blogspot.com
#
#   Version: 1.0 (first-released December 2014)
#
#   Subscript Name: SAN Storage System - Failback (SAN-Failback.ps1)
#
#   Purpose: Failback operation subscript called by Console Menu script
#
# ------------------------------------------------------------------------------------------------------------------------

# Failback
# -------------------------------------------------

# Run on PRODsite SAN to confirm the target remote replication group does not exist before creating it.

# Connect to PRODsite SAN CLI. 

# [#1] Delete existing LUN from remote replication group from PRODsite to DRsite

Function FAILBK_010_PRODsite_SAN_StopRemoveRemoteReplGroup() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_010_PRODsite_SAN] Stop and Delete Replication Group - from PRODsite to DRsite (Optional)`r`n" | tee $logFailBk -Append
	Echo "SAN command to be executed on $varSanSystemProd `($($storIpAddrPRODsite)`):`r`n" | tee $logFailBk -Append
	Echo <# stop remote replication group $xmlRemoteReplGroupProd #> | tee $logFailBk -Append
	Echo <# remove remote replication group $xmlRemoteReplGroupProd #> | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append

	Echo "`r`n|| Stopping replication group: $xmlRemoteReplGroupProd`r`n" | tee $logFailBk -Append
	
	$sanCmd = <# stop remote replication group $xmlRemoteReplGroupProd #>
	Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append

	Echo "`r`n|| Removing replication group: $xmlRemoteReplGroupProd`r`n" | tee $logFailBk -Append
	$sanCmd = <# remove remote replication group $xmlRemoteReplGroupProd #>
	Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append

	Echo "`r`nMessage `"does not exist`" or similar may be expected when it cannot not find any replication groups for removal in PRODsite.`r`n" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

# Run on DRsite SAN to confirm the target remote replication group does not exist before creating it.

Function FAILBK_020_DRsite_SAN_StopRemoveRemoteReplGroup_FailBack() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_020_DRsite_SAN] Stop and Delete Replication Group - from DRsite to PRODsite (Optional)`r`n" | tee $logFailBk -Append
	Echo "SAN command to be executed on $varSanSystemDR `($($storIpAddrDRsite)`):`r`n" | tee $logFailBk -Append
	Echo <# stop remote replication group $xmlRemoteReplGroupDR #> | tee $logFailBk -Append
	Echo <# remove remote replication group $xmlRemoteReplGroupDR #> | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append
	
	Echo "`r`n|| Stopping replication group: $xmlRemoteReplGroupDR`r`n" | tee $logFailBk -Append
	
	$sanCmd = <# stop remote replication group $xmlRemoteReplGroupDR #>
	Run-Plink-DRsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append

	Echo "`r`n|| Removing replication group: $xmlRemoteReplGroupDR`r`n" | tee $logFailBk -Append
	$sanCmd = <# remove remote replication group $xmlRemoteReplGroupDR #>
	Run-Plink-DRsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append

	Echo "`r`nMessage `"does not exist`" or similar may be expected when it cannot not find any replication groups for removal in DRsite.`r`n" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

# Take cluster shared volume offline in PRODsite Hyper-V Host

# Specify drive letters in XML through which disk numbers are acquired

# Unpresent LUN number from PRODsite Hyper-V host

Function FAILBK_030_PRODsite_WIN_StopClusterSharedVolume() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_030_PRODsite_WIN] Stop CSV in PRODsite (Optional)`r`n" | tee $logFailBk -Append
	Echo "Windows command to be executed on $($varWinServProd):`r`n" | tee $logFailBk -Append
	Foreach ( $xmlCluster in $xmlClusters ) {
		# Stop cluster shared volume 
		Echo "Stop-ClusterResource `"$xmlCluster`""
	}
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append
	
	Foreach ( $xmlCluster in $xmlClusters ) {
		Echo "`r`n|| Stopping Cluster Shared Volume: $xmlCluster`r`n" | tee $logFailBk -Append
		# Stop cluster shared volume 
		Invoke-Command -ComputerName $varWinServProd -ScriptBlock { Stop-ClusterResource (Get-ClusterSharedVolume -Name $args[0]) } -argumentlist $xmlCluster 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
		sleep 3
	}
	Echo "" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

Function FAILBK_032_PRODsite_WIN_RemoveVM() {

	# Delete any old VM guests from PRODsite Hyper-V host before presenting LUN

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_032_PRODsite_WIN] Delete VM in PRODsite (Optional)`r`n" | tee $logFailBk -Append
	Echo "Windows command to be executed on $($varWinServProd):`r`n" | tee $logFailBk -Append
	Foreach ( $xmlVM in $xmlVMs ) {
		Echo "Remove-VM -Force -Name $xmlVM" | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append

	Foreach ( $xmlVM in $xmlVMs ) {
		Echo "`r`n|| Attempting to remove VM: $($xmlVM)...`r`n" | tee $logFailBk -Append
		Invoke-Command -ComputerName $varWinServProd -ScriptBlock { Remove-VM -Force -Name $args[0] } -argumentlist $xmlVM 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
	# Verification
	Echo "`r`nMessage `"unable to find a virtual machine`" is expected if the VM was already removed beforehand.`r`n" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

Function FAILBK_035_PRODsite_SAN_RemovePresentedLUN_Csv() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_035_PRODsite_SAN] Unpresent LUN of CSV from PRODsite Hosts (Optional)`r`n" | tee $logFailBk -Append
	Echo "SAN command to be executed on $varSanSystemProd `($($storIpAddrPRODsite)`):`r`n" | tee $logFailBk -Append
	Foreach ( $xmlLUN in $LUN.label ) {
		Echo <# Unpresent LUN $xmlLUN for first production host $varSanServProd1 #> | tee $logFailBk -Append
		Echo <# Unpresent LUN $xmlLUN for second production host $varSanServProd2 #> | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append
		
	Foreach ( $xmlLUN in $LUN.label ) {
		Echo "`r`n|| Unpresenting LUN `"$xmlLUN`" from `"$varSanServProd1`"`r`n" | tee $logFailBk -Append
		$sanCmd = <# Unpresent LUN $xmlLUN for first production host $varSanServProd1 #>
		Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
		Echo "`r`n|| Unpresenting LUN `"$xmlLUN`" from `"$varSanServProd2`"`r`n" | tee $logFailBk -Append
		$sanCmd = <# Unpresent LUN $xmlLUN for second production host $varSanServProd2 #>
		Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	}
	Echo "`r`nMessage `"No matching presented LUNs`" or similar may be expected when it cannot not find any presented LUNs for unpresenting in PRODsite.`r`n" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

# Delete any existing LUN in PRODsite site

Function FAILBK_040_PRODsite_SAN_RemoveLun_Csv() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_040_PRODsite_SAN] Delete LUN of CSV in PRODsite (Optional)`r`n" | tee $logFailBk -Append
	Echo "SAN command to be executed on $varSanSystemProd `($($storIpAddrPRODsite)`):`r`n" | tee $logFailBk -Append
	Foreach ( $xmlLUN in $LUN.label ) {
		Echo <# remove LUN $xmlLUN #> | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append
	
	Foreach ( $xmlLUN in $LUN.label ) {
		Echo "`r`n|| Removing LUN: $xmlLUN`r`n" | tee $logFailBk -Append
		$sanCmd = <# remove LUN $xmlLUN #>
		Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
		sleep 2
	}
	Echo "`r`nMessage `"not found`" or similar may be expected when it cannot not find any presented LUNs for removal in PRODsite.`r`n" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

# [#2] Create a list of new LUN in PRODsite (for use by DRsite-to-PRODsite temporary replication)

Function FAILBK_050_PRODsite_SAN_CreateLun_Csv() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_050_PRODsite_SAN] Create LUN of CSV in PRODsite`r`n" | tee $logFailBk -Append
	Echo "SAN command to be executed on $varSanSystemProd `($($storIpAddrPRODsite)`):`r`n" | tee $logFailBk -Append
	for( $i=0; $i -lt $LUN.length; $i++ ) {
		$xmlReplRaidConfig = $LUN[$i].ReplRaidConfig
		$xmlUserRaidConfig = $LUN[$i].UserRaidConfig
		$xmlLUN = $LUN[$i].label
		$xmlLUNSize = $LUN[$i].LUNSize
		Echo <# create LUN $xmlLUN based on replication RAID config $xmlReplRaidConfig and user RAID config $xmlUserRaidConfig at size $($xmlLUNSize)g in gigabytes #> | tee $logFailBk -Append
	}
	Echo <# display LUNs #> | tee $logFailBk -Append
	Echo <# display logical disk details #> | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append
	
	for( $i=0; $i -lt $LUN.length; $i++ ) {
		$xmlReplRaidConfig = $LUN[$i].ReplRaidConfig
		$xmlUserRaidConfig = $LUN[$i].UserRaidConfig
		$xmlLUN = $LUN[$i].label
		$xmlLUNSize = $LUN[$i].LUNSize
		Echo "`r`n|| Creating LUN `"$xmlLUN`" of ReplRaidConfig `"$xmlReplRaidConfig`", UserRaidConfig `"$xmlUserRaidConfig`", LUN size `"$xmlLUNSize`"`r`n" | tee $logFailBk -Append
		$sanCmd = <# create LUN $xmlLUN based on replication RAID config $xmlReplRaidConfig and user RAID config $xmlUserRaidConfig at size $($xmlLUNSize)g in gigabytes #>
		Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	}

	# Verification

	Foreach ( $xmlLUN in $LUN.label ) {
		Echo "`r`n|| Displaying statistics of LUN: $xmlLUN`r`n" | tee $logFailBk -Append
		$sanCmd = <# display LUNs for $xmlLUN #>
		Run-Plink-PRODsite -exec $sanCmd | tee $logFailBk -Append
		Echo "" | tee $logFailBk -Append
		$sanCmd = <# display logical disks for $xmlLUN #>
		Run-Plink-PRODsite -exec $sanCmd | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

Function FAILBK_060_DRsite_SAN_CreateRemoteReplGroup_FailBack() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_060_DRsite_SAN] Create Replication Group - from DRsite to PRODsite`r`n" | tee $logFailBk -Append
	Echo "SAN command to be executed on $varSanSystemDR `($($storIpAddrDRsite)`):`r`n" | tee $logFailBk -Append
	Echo <# create remote replication group $xmlRemoteReplGroupDR on SAN system $varSanSystemProd #> | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append

	Echo "`r`n|| Creating replication group: $xmlRemoteReplGroupDR`r`n" | tee $logFailBk -Append
	
	$sanCmd = <# create remote replication group $xmlRemoteReplGroupDR on SAN system $varSanSystemProd #>
	Run-Plink-DRsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

Function FAILBK_070_DRsite_SAN_AddRemoteReplLun_FailBack() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_070_DRsite_SAN] Add LUN to Replication Group - from DRsite to PRODsite`r`n" | tee $logFailBk -Append
	Echo "SAN command to be executed on $varSanSystemDR `($($storIpAddrDRsite)`):`r`n" | tee $logFailBk -Append
	for( $i=0; $i -lt $LUN.length; $i++ ) {
		# Add a list of volumes to the remote replication group
		$xmlClone = $LUN[$i].LUNClone
		$xmlLUN = $LUN[$i].label
		Echo <# add LUN $xmlClone to remote replication group $xmlRemoteReplGroupDR on SAN system $($varSanSystemProd):$xmlLUN #> | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append
	
	for( $i=0; $i -lt $LUN.length; $i++ ) {
		# Add a list of volumes to the remote replication group
		$xmlClone = $LUN[$i].LUNClone
		$xmlLUN = $LUN[$i].label
		Echo "`r`n|| Adding source LUN `"$xmlClone`" `(cloned copy`) to repl. group `"$xmlRemoteReplGroupDR`" as target LUN `"$xmlLUN`"`r`n" | tee $logFailBk -Append
		$sanCmd = <# add LUN $xmlClone to remote copy group $xmlRemoteReplGroupDR on SAN system $($varSanSystemProd):$xmlLUN #>
		Run-Plink-DRsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

Function FAILBK_080_DRsite_SAN_StartRemoteReplGroup_FailBack() {

	# Start replication

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_080_DRsite_SAN] Start Replication Group - from DRsite to PRODsite`r`n" | tee $logFailBk -Append
	Echo "SAN command to be executed on $varSanSystemDR `($($storIpAddrDRsite)`):`r`n" | tee $logFailBk -Append
	Echo <# display remote replication group for $xmlRemoteReplGroupDR #> | tee $logFailBk -Append
	Echo <# display recent tasks #> | tee $logFailBk -Append
	Echo <# display remote replication groups for $xmlRemoteReplGroupDR #> | tee $logFailBk -Append
	Echo "`r`nWARNING: This step might take a long time depending on the size of LUNs to replicate.`r`n" | tee $logFailBk -Append
	Echo "Please proceed with enough time.`r`n" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append
	
	Echo "`r`n|| Starting replication group: $xmlRemoteReplGroupDR`r`n" | tee $logFailBk -Append

	$sanCmd = <# start remote replication group $xmlRemoteReplGroupDR #>
	Run-Plink-DRsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append

	# Wait until replicated. Continuously verify recent tasks
	do {
		Echo "`r`n|| Waiting for remote replication `(refreshes every 15 seconds`)...`r`n" | tee $logFailBK -Append
		sleep 15
		$out = Run-Plink-DRsite -exec <# display recent tasks #>
		$out | findstr /i <# keyword to catch active replication tasks #> 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	} while ($LASTEXITCODE -eq 0)

	Echo "`r`nReplication is complete or inactive.`r`n" | tee $logFailBk -Append

	# Check replication status until "Synced" appears for the newly created replication pair

	Echo "`r`n|| Showing replication status`r`n" | tee $logFailBK -Append
	$sanCmd = <# display remote replication groups for $xmlRemoteReplGroupDR #>
	Run-Plink-DRsite -exec $sanCmd | tee $logFailBk -Append

	Echo "" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

Function FAILBK_090_DRsite_WIN_StopVM() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_090_DRsite_WIN] Stop VM in DRsite`r`n" | tee $logFailBk -Append
	Echo "SAN command to be executed on $($varWinServDR):`r`n" | tee $logFailBk -Append
	Foreach ( $xmlVM in $xmlVMs ) {
		Echo "Stop-VM -Name `"$xmlVM`"" | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append

	# [#4] Gracefully shut down Hyper-V guest in DRsite before taking disk offline
	Foreach ( $xmlVM in $xmlVMs ) {
		Echo "`r`n|| Stopping VM: $xmlVM`r`n" | tee $logFailBk -Append
		Invoke-Command -ComputerName $varWinServDR -ScriptBlock { Stop-VM -Name $args[0] } -argumentlist $xmlVM 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	}

	# Verification

	Foreach ( $xmlVM in $xmlVMs ) {
		Echo "`r`n|| Displaying statistics of VM: $($xmlVM)...`r`n" | tee $logFailBk -Append
		Invoke-Command -EA SilentlyContinue -ComputerName $varWinServDR -ScriptBlock { Get-VM $args[0]|select VMName,State,VMId,Status,Uptime,Path } -argumentlist $xmlVM 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	}

	Echo "" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

Function FAILBK_110_DRsite_SAN_RemovePresentedLUN_Clone() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_110_DRsite_SAN] Unpresent LUN of Cloned Copy from DRsite Host`r`n" | tee $logFailBk -Append
	Echo "SAN command to be executed on $varSanSystemDR `($($storIpAddrDRsite)`):`r`n" | tee $logFailBk -Append
	Foreach ( $xmlClone in $xmlClones ) {
			Echo <# unpresent LUN $xmlClone from host $varSanServDR #> | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append

	# Unpresent LUN from DRsite Hyper-V host
	Foreach ( $xmlClone in $xmlClones ) {
		Echo "`r`n|| Unpresenting LUN `"$xmlClone`" `(cloned copy`) from `"$varSanServDR`"`r`n" | tee $logFailBk -Append
		$sanCmd = <# unpresent LUN $xmlClone from host $varSanServDR #>
		Run-Plink-DRsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

Function FAILBK_120_DRsite_SAN_StopRemoveRemoteReplGroup_FailBack() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_120_DRsite_SAN] Stop and Delete Replication Group - from DRsite to PRODsite`r`n" | tee $logFailBk -Append
	Echo "SAN command to be executed on $varSanSystemDR `($($storIpAddrDRsite)`):`r`n" | tee $logFailBk -Append
	Echo <# stop remote replication group $xmlRemoteReplGroupDR #> | tee $logFailBk -Append
	Echo <# remove remote replication group $xmlRemoteReplGroupDR #> | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append

	# Stop and remove temp replication group of DRsite to PRODsite

	Echo "`r`n|| Stopping replication group: $xmlRemoteReplGroupDR`r`n" | tee $logFailBk -Append
	$sanCmd = <# stop remote replication group $xmlRemoteReplGroupDR #>
	Run-Plink-DRsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append

	Echo "`r`n|| Removing replication group: $xmlRemoteReplGroupDR`r`n" | tee $logFailBk -Append
	$sanCmd = <# remove remote replication group $xmlRemoteReplGroupDR #>
	Run-Plink-DRsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

# Connect to PRODsite SAN CLI

Function FAILBK_140_PRODsite_SAN_CreatePresentedLUN_Csv() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_140_PRODsite_SAN] Present LUN of Replicated CSV to PRODsite Hosts`r`n" | tee $logFailBk -Append
	Echo "SAN command to be executed on $varSanSystemProd `($($storIpAddrPRODsite)`):`r`n" | tee $logFailBk -Append
	Foreach ( $xmlLUN in $LUN.label ) {
			Echo <# present LUN $xmlLUN for first host $varSanServProd1 #> | tee $logFailBk -Append
			Echo <# present LUN $xmlLUN for second host $varSanServProd2 #> | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append
	
	# Present LUN to PRODsite Hyper-V host

	Foreach ( $xmlLUN in $LUN.label ) {
		Echo "`r`n|| Presenting LUN `"$xmlLUN`" to `"$varSanServProd1`"`r`n" | tee $logFailBk -Append
		$sanCmd = <# present LUN $xmlLUN for first host $varSanServProd1 #>
		Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
		Echo "`r`n|| Presenting LUN `"$xmlLUN`" to `"$varSanServProd2`"`r`n" | tee $logFailBk -Append
		$sanCmd = <# present LUN $xmlLUN for second host $varSanServProd2 #>
		Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	}

	# Verification

	Foreach ( $xmlLUN in $LUN.label ) {
		Echo "`r`n|| Showing statistics of presented LUN: $xmlLUN`r`n" | tee $logFailBk -Append
		$out = Run-Plink-PRODsite -exec <# display presented LUNs #>
		$out | findstr /i "$xmlLUN" | tee $logFailBk -Append
	}

	# Sleep until disk is ready in Windows
	Echo "`r`n|| Sleeping 20 seconds for presented LUNs to be ready in Windows" | tee $logFailBk -Append
	sleep 20

	Echo "" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

Function FAILBK_150_PRODsite_WIN_StartClusterSharedVolume() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_150_PRODsite_WIN] Start CSV in PRODsite`r`n" | tee $logFailBk -Append
	Echo "Windows command to be executed on $($varWinServProd):`r`n" | tee $logFailBk -Append
	Foreach ( $xmlCluster in $xmlClusters ) {
		Echo "Start-ClusterResource `"$xmlCluster`"" | tee $logFailBk -Append
		Echo "Get-ClusterSharedVolume `"$xmlCluster`"" | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append

	# Take online the presented LUN in Failover Cluster Manager of any of the clustered Hyper-V hosts in prod site
	Foreach ( $xmlCluster in $xmlClusters ) {
		Echo "`r`n|| Starting Cluster Shared Volume: $($xmlCluster)...`r`n" | tee $logFailBk -Append
		Invoke-Command -ComputerName $varWinServProd -ScriptBlock { Start-ClusterResource (Get-ClusterSharedVolume -Name $args[0]) } -argumentlist $xmlCluster 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
		sleep 3
		# Get Cluster Shared Volume information
		Echo "`r`n|| Confirming information of Cluster Shared Volume: $($xmlCluster)...`r`n" | tee $logFailBk -Append
		Invoke-Command -ComputerName $varWinServProd -ScriptBlock { Get-ClusterSharedVolume -Name $args[0] } -argumentlist $xmlCluster 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	}

	Echo "" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

Function FAILBK_160_PRODsite_WIN_ImportVM() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_160_PRODsite_WIN] Import VM in PRODsite`r`n" | tee $logFailBk -Append
	Echo "Windows command to be executed on $($varWinServProd):`r`n" | tee $logFailBk -Append
	Foreach ($xmlVMProdCfg in $xmlVMProdCfgs) {
		Echo "Import-VM -Path `"$xmlVMProdCfg`"" | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append

	# Path checking
	Foreach ($xmlVMProdCfgUNC in $xmlVMProdCfgsUNC) {
		if (!(Test-Path $xmlVMProdCfgUNC)) {
			Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
			Echo "ERROR: VM config not found: `"$xmlVMProdCfgUNC`"" | tee $logFailBk -Append
			Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
		}
	}

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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append
	
	# Import VM in PRODsite Hyper-V host 
	
	Foreach ($xmlVMProdCfg in $xmlVMProdCfgs) {
		Echo "`r`n|| Importing VM from `"$xmlVMProdCfg`"`r`n" | tee $logFailBk -Append
		Invoke-Command -ComputerName $varWinServProd -ScriptBlock { Import-VM -Path $args[0]|select VMName,State,VMId,Status,Uptime,Path } -ArgumentList $xmlVMProdCfg 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	}

	Echo "" | tee $logFailBk -Append
	Echo "NOTE: If VM import has been successful, VM statistics would be returned; otherwise, nothing would show." | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

Function FAILBK_165_PRODsite_WIN_DisconnectVMNetworkAdapter() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_165_PRODsite_WIN] Disconnect VM Network Adapters in PRODsite`r`n" | tee $logFailBk -Append
	Echo "Windows command to be executed on $($varWinServProd):`r`n" | tee $logFailBk -Append
	Foreach ($xmlVM in $xmlVMs) {
		 Echo "Get-VMNetworkAdapter -VMName `"$xmlVM`" `| Disconnect-VMNetworkAdapter" | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append
	
	# Show VM network adapter status

	Foreach ( $xmlVM in $xmlVMs ) {
		Echo "`r`n|| Showing VM Network Adapter Status: $xmlVM`r`n" | tee $logFailBk -Append
		Invoke-Command -ComputerName $varWinServProd -ScriptBlock { Get-VMNetworkAdapter -VMName $args[0]|select Name,VMName,SwitchName,MacAddress } -ArgumentList $xmlVM | tee $logFailBk -Append
	}

	# Disconnect Network Adapter

	Foreach ($xmlVM in $xmlVMs) {
		Echo "`r`n|| Disconnecting VM Network Adapters: $xmlVM`r`n" | tee $logFailBk -Append
		Invoke-Command -ComputerName $varWinServProd -ScriptBlock { Disconnect-VMNetworkAdapter (Get-VMNetworkAdapter -VMName $args[0]) } -ArgumentList $xmlVM 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	}

	# Verify virtual switch and status

	Foreach ( $xmlVM in $xmlVMs ) {
		Echo "`r`n|| Showing VM Network Adapter Status: $xmlVM`r`n" | tee $logFailBk -Append
		Invoke-Command -ComputerName $varWinServProd -ScriptBlock { Get-VMNetworkAdapter -VMName $args[0]|select Name,VMName,SwitchName,MacAddress } -ArgumentList $xmlVM | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
	Echo "NOTE: If VM network adapter is disconnected, virtual switch name would be empty." | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

Function FAILBK_170_PRODsite_WIN_StartVM() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_170_PRODsite_WIN] Start VM in PRODsite`r`n" | tee $logFailBk -Append
	Echo "Windows command to be executed on $($varWinServProd):`r`n" | tee $logFailBk -Append
	Foreach ($xmlVM in $xmlVMs) {
		Echo "Start-VM -Name `"$xmlVM`"" | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append
	
	# Start VM

	Foreach ($xmlVM in $xmlVMs) {
		Echo "`r`n|| Starting VM: $xmlVM`r`n" | tee $logFailBk -Append
		Invoke-Command -ComputerName $varWinServProd -ScriptBlock { Start-VM -Name $args[0] } -ArgumentList $xmlVM 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

Function FAILBK_180_PRODsite_SAN_CreateRemoteReplGroup() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_180_PRODsite_SAN] Create Replication Group - from PRODsite to DRsite`r`n" | tee $logFailBk -Append
	Echo "SAN command to be executed on $varSanSystemProd `($($storIpAddrPRODsite)`):`r`n" | tee $logFailBk -Append
	Echo <# create remote replication group $xmlRemoteReplGroupProd for SAN system $varSanSystemDR #> | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append
	
	Echo "`r`n|| Creating replication group: $xmlRemoteReplGroupProd`r`n" | tee $logFailBk -Append
	
	# [#7] Create replication from PRODsite to DRsite
	$sanCmd = <# create remote replication group $xmlRemoteReplGroupProd for SAN system $varSanSystemDR #>
	Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

Function FAILBK_190_PRODsite_SAN_AddRemoteReplLun() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_190_PRODsite_SAN] Add LUN to Replication Group - from PRODsite to DRsite`r`n" | tee $logFailBk -Append
	Echo "SAN command to be executed on $varSanSystemProd `($($storIpAddrPRODsite)`):`r`n" | tee $logFailBk -Append
	# Add LUN to group
	for( $i=0; $i -lt $LUN.length; $i++ ) {
		# Add a list of volumes to the remote replication group
		$xmlLUN = $LUN[$i].label
		$xmlLUN_DR = $LUN[$i].label_DR
		Echo <# add LUN $xmlLUN to remote replication group $xmlRemoteReplGroupProd for SAN system $($varSanSystemDR):$xmlLUN_DR #> | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append
	
	# Add LUN to group
	for( $i=0; $i -lt $LUN.length; $i++ ) {
		# Add a list of volumes to remote replication group
		$xmlLUN = $LUN[$i].label
		$xmlLUN_DR = $LUN[$i].label_DR
		Echo "`r`n|| Adding source LUN `"$xmlLUN`" to repl. group `"$xmlRemoteReplGroupProd`" as target LUN `"$xmlLUN`"`r`n" | tee $logFailBk -Append
		$sanCmd = <# add LUN $xmlLUN to an remote replication group $xmlRemoteReplGroupProd for SAN system $($varSanSystemDR):$xmlLUN_DR #>
		Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append
	}
	Echo "" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

Function FAILBK_200_PRODsite_SAN_StartRemoteReplGroup() {

	# For logging
	if ($args[0] -eq "Resume") {
		$logFail = $logFailSr
		$logErrFail = $logErrFailSr
	} else {
		$logFail = $logFailBk
		$logErrFail = $logErrFailBk
	}

	Echo "`r`n********************************************************************************************`r`n" | tee $logFail -Append
	Echo "`r`n[FAILBK_200_PRODsite_SAN] Start Replication Group - from PRODsite to DRsite`r`n" | tee $logFail -Append
	Echo "SAN command to be executed on $varSanSystemProd `($($storIpAddrPRODsite)`):`r`n" | tee $logFail -Append
	Echo <# start remote replication groups $xmlRemoteReplGroupProd #> | tee $logFail -Append
	Echo <# display remote replication groups $xmlRemoteReplGroupProd #> | tee $logFail -Append
	if ($args[0] -ne "Resume") {
		Echo <# display recent tasks #> | tee $logFail -Append
	}
	Echo "" | tee $logFail -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFail -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFail -Append

	Echo "`r`n|| Starting replication group: $xmlRemoteReplGroupProd`r`n" | tee $logFail -Append
	
	# Start replication

	$sanCmd = <# start remote replication group for $xmlRemoteReplGroupProd #>
	Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFail } $_ } | tee $logFail -Append

	Echo "`r`n|| Showing replication status`r`n" | tee $logFail -Append

	sleep 5

	$sanCmd = <# display remote replication groups $xmlRemoteReplGroupProd #>
	Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFail } $_ } | tee $logFail -Append
	
	if ($args[0] -ne "Resume") {
		Echo "`r`n|| Showing active replication tasks `(if available`)`r`n" | tee $logFail -Append
		sleep 5
		$out = Run-Plink-PRODsite -exec <# display recent tasks #>
		$out | findstr /i <# keyword to catch active replication tasks #> | tee $logFail -Append
	}

	# It may take time for replication to complete
	
	Echo "" | tee $logFail -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFail -Append
	Echo "" | tee $logFail -Append
	Pause

}

# Suspend and Resume
# -------------------------------------------------

Function FAILBK_015_DRsite_SAN_StopRemoteReplGroup() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	Echo "`r`n[FAILBK_015_DRsite_SAN] Stop and Delete Replication Group - from DRsite to PRODsite (Optional)`r`n" | tee $logFailBk -Append
	Echo "SAN command to be executed on $varSanSystemDR `($($storIpAddrDRsite)`):`r`n" | tee $logFailBk -Append
	Echo <# stop remote replication group for $xmlRemoteReplGroupDR #> | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailBk -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailBk -Append
	
	Echo "`r`n|| Stopping replication group: $xmlRemoteReplGroupDR`r`n" | tee $logFailBk -Append
	
	$sanCmd = <# stop remote replication group for $xmlRemoteReplGroupDR #>
	Run-Plink-DRsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailBk } $_ } | tee $logFailBk -Append

	Echo "`r`nMessage `"does not exist`" or similar may be expected when it cannot not find any replication groups for removal in DRsite.`r`n" | tee $logFailBk -Append
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailBk -Append
	Echo "" | tee $logFailBk -Append
	Pause
}

Function FAILBK_005_PRODsite_SAN_StopRemoteReplGroup() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailSr -Append
	Echo "`r`n[FAILBK_005_PRODsite_SAN] Stop Replication Group - from PRODsite to DRsite`r`n" | tee $logFailSr -Append
	Echo "SAN command to be executed on $varSanSystemProd `($($storIpAddrPRODsite)`):`r`n" | tee $logFailSr -Append
	Echo <# stop remote replication group for $xmlRemoteReplGroupProd #> | tee $logFailSr -Append
	Echo "" | tee $logFailSr -Append
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailSr -Append
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailSr -Append

	Echo "`r`n|| Stopping replication group: $xmlRemoteReplGroupProd`r`n" | tee $logFailSr -Append
	
	$sanCmd = <# stop remote replication group for $xmlRemoteReplGroupProd #>
	Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailSr } $_ } | tee $logFailSr -Append

	Echo "`r`n|| Showing replication status`r`n" | tee $logFailSr -Append

	$sanCmd = <# display remote replication groups for $xmlRemoteReplGroupProd #>
	Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -Append $logErrFailSr } $_ } | tee $logFailSr -Append
	
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailSr -Append
	Echo "" | tee $logFailSr -Append
	Pause
}

