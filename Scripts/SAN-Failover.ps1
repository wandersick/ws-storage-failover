
# ------------------------------------------------------------------------------------------------------------------------
#
#   General Storage Failover and Failback PowerShell Scripts (Template) for Failover Cluster (e.g. Hyper-V)
#   with an Easy-to-Use Interactive Console Menu for Operators
#   by @wandersick - https://wandersick.blogspot.com
#
#   Version: 1.0 (first-released December 2014)
#
#   Subscript Name: SAN Storage System - Failover (SAN-Failover.ps1)
#
#   Purpose: Failover operation subscript called by Console Menu script
#
# ------------------------------------------------------------------------------------------------------------------------

# Failover
# -------------------------------------------------

Function FAILOV_010_PRODsite_WIN_StopVM() {
	
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	Echo "`r`n[FAILOV_010_PRODsite_WIN] Stop VM in PRODsite (Optional)`r`n" | tee $logFailOv -end
	Echo "Windows command to be executed on $($varWinServProd):`r`n" | tee $logFailOv -end
	Foreach ( $xmlVM in $xmlVMs ) {
		# On PRODsite Hyper-V host, stop each VM on hosts
		Echo "Stop-VM -Name $xmlVM" | tee $logFailOv -end
		Echo "Get-VM $xmlVM" | tee $logFailOv -end
	}
	Echo "" | tee $logFailOv -end
	Echo "NOTE: Message `"Shutdown integration service is unavailable`" is expected if VM is in an unstable state." | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	
	Foreach ( $xmlVM in $xmlVMs ) {
		# On PRODsite Hyper-V host, stop each VM on hosts
		Echo "|| Stopping VM: $($xmlVM)...`r`n" | tee $logFailOv -end
		Invoke-Command -ComputerName $varWinServProd -ScriptBlock { Stop-VM -Name $args[0] } -argumentlist $xmlVM 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end
		# Verification. In case of timeout, check VM manaully using Hyper-V Manager
		Echo "`r`n|| Displaying statistics of VM: $($xmlVM)...`r`n" | tee $logFailOv -end
		Invoke-Command -ComputerName $varWinServProd -ScriptBlock { Get-VM $args[0]|select VMName,State,VMId,Status,Uptime,Path } -argumentlist $xmlVM | tee $logFailOv -end
	}
	Echo "" | tee $logFailOv -end
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	Pause
}

Function FAILOV_020_PRODsite_WIN_StopClusterSharedVolume() { 

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	Echo "[FAILOV_020_PRODsite_WIN] Stop CSV in PRODsite (Optional)`r`n" | tee $logFailOv -end
	Echo "Windows command to be executed on $($varWinServProd):`r`n" | tee $logFailOv -end
	Foreach ( $xmlCluster in $xmlClusters ) {
		# Stop cluster shared volume 
		Echo "Stop-ClusterResource `"$xmlCluster`"" | tee $logFailOv -end
	}
	Echo "" | tee $logFailOv -end
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end

	Foreach ( $xmlCluster in $xmlClusters ) {
		# Stop cluster shared volume 
		Echo "|| Stopping Cluster Shared Volume: $($xmlCluster)...`r`n" | tee $logFailOv -end
		Invoke-Command -ComputerName $varWinServProd -ScriptBlock { Stop-ClusterResource (Get-ClusterSharedVolume -Name $args[0]) } -argumentlist $xmlCluster 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end
		sleep 3
	}
	Echo "" | tee $logFailOv -end
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	Pause
}

Function FAILOV_030_PRODsite_SAN_StopRemoteRepl() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	Echo "`r`n[FAILOV_030_PRODsite_SAN] Stop Replication - from PRODsite to DRsite (Optional)`r`n" | tee $logFailOv -end
	Echo "SAN command to be executed on $varSanSystemProd `($($storIpAddrPRODsite)`):`r`n" | tee $logFailOv -end
	Echo <# display tasks #> | tee $logFailOv -end
	Echo <# display remote replication group $xmlRemoteReplGroupProd #> | tee $logFailOv -end
	Echo <# stop remote replication group $xmlRemoteReplGroupProd #> | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailOv -end


	# Confirm previous replications are done. Wait and check continuously
	do {
		Echo "`r`n|| Checking replication status `(continously until done`)...`r`n" | tee $logFailOv -end
		sleep 5
		$out = Run-Plink-DRsite -exec <# display tasks #>
		$out | findstr /i <# keyword to catch active tasks #> | tee $logFailOv -end
	} while ($LASTEXITCODE -eq 0)

	Echo "`r`nReplication is complete or inactive.`r`n" | tee $logFailOv -end

	# Verification
	Echo "`r`n|| Displaying replication status`r`n" | tee $logFailOv -end

	# On PRODsite SAN, verify replication rcopy group (PRODsite to DRsite) is successful (Status: Synced)
	$sanCmd = <# display remote replication groups $xmlRemoteReplGroupProd #>
	Run-Plink-PRODsite -exec $sanCmd | tee $logFailOv -end
	Foreach ( $xmlLUN in $LUN.label ) {
		$out | findstr /i "$xmlLUN" | tee $logFailOv -end
	}

	Echo "`r`n|| Stopping replication group: $($xmlRemoteReplGroupProd)`r`n" | tee $logFailOv -end

	# Stop the replication job that replicates from PRODsite to DRsite
	$sanCmd = <# stop remote replication group $xmlRemoteReplGroupProd #>
	Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end

	# Verification

	Echo "`r`n|| Displaying replication status`r`n" | tee $logFailOv -end

	$sanCmd = <# display remote replication group $xmlRemoteReplGroupProd #>
	Run-Plink-PRODsite -exec $sanCmd | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	Pause
}

# Run in DRsite SAN

Function FAILOV_040_DRsite_WIN_RemoveVM() {

	# Under DRsite DR Hyper-V host, ensure VM is removed in Hyper-V Manager before taking LUN online in Disk Management, in order to prevent failure

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	Echo "[FAILOV_040_DRsite_WIN] Delete VM in DRsite (Preparation)`r`n" | tee $logFailOv -end
	Echo "Windows command to be executed on $($varWinServDR):`r`n" | tee $logFailOv -end
	Foreach ( $xmlVM in $xmlVMs ) {
		Echo "Remove-VM -Force -Name $xmlVM" | tee $logFailOv -end
	}
	Echo "" | tee $logFailOv -end
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	
	Echo "Error messages can be expected if it cannot find any VM to remove in DRsite, which is an expected condition.`r`n"

	Foreach ( $xmlVM in $xmlVMs ) {
		Echo "|| Attempting to remove VM: $($xmlVM)...`r`n" | tee $logFailOv -end
		Invoke-Command -EA SilentlyContinue -ComputerName $varWinServDR -ScriptBlock { Remove-VM -Force -Name $args[0] } -argumentlist $xmlVM 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end
	}
	# Verification
	Echo "" | tee $logFailOv -end
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	Pause
}

Function FAILOV_050_DRsite_SAN_RemovePresentedLUN_Clone() {
	
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	Echo "`r`n[FAILOV_050_DRsite_SAN] Unpresent Old Cloned Copy and Source LUN from DRsite Host (Preparation)`r`n" | tee $logFailOv -end
	Echo "SAN command to be executed on $varSanSystemDR `($($storIpAddrDRsite)`):`r`n" | tee $logFailOv -end
	Foreach ( $xmlClone in $xmlClones ) {
		Echo <# unpresent LUN $xmlClone from host $varSanServDR #> | tee $logFailOv -end
	}
	Foreach ( $xmlLUN in $LUN.label ) {
			Echo <# unpresent LUN $xmlLUN from host $varSanServDR #> | tee $logFailOv -end
	}
	Echo "" | tee $logFailOv -end
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	
	# To prevent failure, ensure cloned copy of LUN is not presented to DR Hyper-V host previously

	Foreach ( $xmlClone in $xmlClones ) {
			Echo "|| Unpresenting LUN `"$xmlClone`" `(cloned copy`) from `"$varSanServDR`"`r`n" | tee $logFailOv -end
			$sanCmd = <# unpresent LUN $xmlClone for host $varSanServDR #>
			Run-Plink-DRsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end
			Echo "" | tee $logFailOv -end
	}

	# To prevent failure, ensure no LUN is presented to DR Hyper-V host previously (optional)

	Foreach ( $xmlLUN in $LUN.label ) {
			Echo "|| Unpresenting LUN `"$xmlLUN`" `(source`) from `"$varSanServDR`"`r`n" | tee $logFailOv -end
			$sanCmd = <# unpresent LUN $xmlLUN for host $varSanServDR #>
			Run-Plink-DRsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end
			Echo "" | tee $logFailOv -end
	}

	sleep 5
	Echo "Message `"No matching presented LUNs`" or similar may be expected if any LUN does not exist." | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	Echo "Please confirm LUN is unpresented from Windows before carrying on DR failover task [FAILOV_080_DRsite_ALL]." | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	Pause
}

Function FAILOV_060_DRsite_SAN_RemoveLun_Clone() {
# To prevent failure, ensure no target LUN exists before cloned copy

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	Echo "`r`n[FAILOV_060_DRsite_SAN] Delete Old Cloned Copy LUN in DRsite (Preparation)`r`n" | tee $logFailOv -end
	Echo "SAN command to be executed on $varSanSystemDR `($($storIpAddrDRsite)`):`r`n" | tee $logFailOv -end
	Foreach ( $xmlClone in $xmlClones ) {
			Echo <# remove LUN $xmlClone #> | tee $logFailOv -end
	}
	Echo "" | tee $logFailOv -end
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	
	Foreach ( $xmlClone in $xmlClones ) {
			$sanCmd = <# remove LUN $xmlClone #>
			Run-Plink-DRsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end
	}

	Echo "`r`nMessage `"Not found`" is expected if target LUN `(cloned copy`) has never been created in DRsite." | tee $logFailOv -end

	# Error observed when LUN is still being replicated during removal "Volume <name> has some region moves in progress. It cannot be deleted at this time."
	Echo "" | tee $logFailOv -end
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	Pause
}

Function FAILOV_070_DRsite_SAN_CreateLunCopy_Clone() {

	# Perform cloning in DRsite SAN (replication RAID config) (user RAID config)

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	Echo "`r`n[FAILOV_070_DRsite_SAN] Create Cloned Copy from Replicated LUN in DRsite`r`n" | tee $logFailOv -end
	Echo "SAN command to be executed on $varSanSystemDR `($($storIpAddrDRsite)`):`r`n" | tee $logFailOv -end
	for( $i=0; $i -lt $LUN.length; $i++ ) {
		$xmlLUN = $LUN[$i].label
		$xmlLUN_DR = $LUN[$i].label_DR
		$xmlReplRaidConfig = $LUN[$i].ReplRaidConfig
		$xmlUserRaidConfig = $LUN[$i].UserRaidConfig
		$xmlClone = $LUN[$i].LUNClone
		Echo <# create clone of LUN $xmlLUN_DR as $xmlClone based on replication RAID config $xmlReplRaidConfig and user RAID config $xmlUserRaidConfig #> | tee $logFailOv -end
	}
	Echo <# display tasks #> | tee $logFailOv -end
	Echo <# display LUN #> | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end

	Echo "|| Creating cloned copy`r`n" | tee $logFailOv -end
	
	for( $i=0; $i -lt $LUN.length; $i++ ) {
		$xmlLUN = $LUN[$i].label
		$xmlLUN_DR = $LUN[$i].label_DR
		$xmlReplRaidConfig = $LUN[$i].ReplRaidConfig
		$xmlUserRaidConfig = $LUN[$i].UserRaidConfig
		$xmlClone = $LUN[$i].LUNClone
		$sanCmd = <# create clone of LUN $xmlLUN_DR as $xmlClone for replication RAID config $xmlReplRaidConfig and user RAID config $xmlUserRaidConfig #> | tee $logFailOv -end
		Run-Plink-DRsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end
	}

	Echo "`r`n|| Displaying recent tasks of clone creation`r`n" | tee $logFailOv -end
	sleep 5
	$out = Run-Plink-DRsite -exec <# display recent tasks #>
	$out | findstr /i <# keyword to catch clone creation tasks #> | tee $logFailOv -end
	# It may take time for the creation
	
	# Verification

	Echo "`r`n|| Displaying LUN statistics`r`n" | tee $logFailOv -end

	Foreach ( $xmlClone in $xmlClones ) {
			$out = Run-Plink-DRsite -exec <# command which outputs LUN details #>
			$out | findstr /i "$xmlClone" | tee $logFailOv -end
	}
	Echo "" | tee $logFailOv -end
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	Pause

}

Function FAILOV_080_DRsite_ALL_CreatePresentedLUNClone_OnlineDisk_StartRepl() {

	# Before present, acquire number of disks in Windows which is to be incremented in diskpart section for each new LUN to mount

	$WindowsDiskNumberTotal = gwmi win32_diskdrive | select index
	$WindowsDiskNumberTotal = $WindowsDiskNumberTotal.index | sort-object

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	Echo "`r`n[FAILOV_080_DRsite_ALL] Present Cloned Copy LUN to DRsite Host, Take Disk Online, Start Replication from PRODsite to DRsite`r`n" | tee $logFailOv -end
	Echo "SAN command to be executed on $varSanSystemDR `($storIpAddrDRsite`) and $($varWinServDR):`r`n" | tee $logFailOv -end
	Foreach ( $xmlClone in $xmlClones ) {
		Echo <# present LUN $xmlClone for host $varSanServDR #> | tee $logFailOv -end
	}
		Echo <# display presented LUNs #> | tee $logFailOv -end

	for( $i=1; $i -le $LUN.length; $i++ ) {
		Echo "" | tee $logFailOv -end
		$diskNumber = $WindowsDiskNumberTotal[-1]+$i
		$diskpartScript = @"
select disk $diskNumber
online disk noerr
attributes disk clear readonly
"@
		Echo "diskpart" | tee $logFailOv -end
		$diskpartScript | tee $logFailOv -end
		
		$xmlDriveLetter = $LUN[$i-1].DRDriveLetter

		# Check for colon in drive letter
		if (!($xmlDriveLetter -match ":")) {
			Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
			Echo "ERROR: Drive letter `"$($xmlDriveLetter)`" does not contain colon" | tee $logFailOv -end
			Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
		}

		# --------------- Start of unassigning drive letter as a precaution ---------------
   
		Echo "" | tee $logFailOv -end
		$diskpartScript = @"
select volume $($xmlDriveLetter)
remove
"@
		Echo "diskpart" | tee $logFailOv -end
		$diskpartScript | tee $logFailOv -end

		# --------------- End of unassigning drive letter as a precaution ---------------

		$diskpartScript = @"
select disk $diskNumber
select partition 1 (with 'select partition 2' as a workaround if 1 fails)
assign letter=$($xmlDriveLetter)
"@
		Echo "" | tee $logFailOv -end
		Echo "diskpart" | tee $logFailOv -end
		$diskpartScript | tee $logFailOv -end		
	}

	Echo "" | tee $logFailOv -end
	Echo <# start remote replication group $xmlRemoteReplGroupProd #> | tee $logFailOv -end
	Echo <# display remote replication groups $xmlRemoteReplGroupProd #> | tee $logFailOv -end
	Echo <# display recent tasks #> | tee $logFailOv -end

	# Show currently mounted drive and drive letters defined in XML and confirm whether to remove those drive letters
	
	Echo "`r`nNOTE: Diskpart errors are displayed in white instead of red. Examine them with care." | tee $logFailOv -end
	Echo "`r`nWARNING: Make sure all unneeded LUNs are unpresented from Windows before performing this task." | tee $logFailOv -end
	Echo "`r`nWARNING: Drive letters specified in XML below will first be unassigned `(if already exist`) in DRsite:`r`n" | tee $logFailOv -end

	$xmlDriveLetters = $LUN.DRDriveLetter
	$xmlDriveLetters 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end

	Echo "" | tee $logFailOv -end
	Echo "Please proceed with care.`r`n" | tee $logFailOv -end

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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailOv -end
	
	# Present LUN to DRsite Hyper-V host
	
	Foreach ( $xmlClone in $xmlClones ) {
		Echo "`r`n|| Presenting LUN: $xmlClone `(Cloned Copy`) to $varSanServDR`r`n" | tee $logFailOv -end
		$sanCmd = <# present LUN $xmlClone for host $varSanServDR #>
		Run-Plink-DRsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end
		sleep 2
	}

	# Verification

	Foreach ( $xmlClone in $xmlClones ) {
		Echo "`r`n|| Displaying statistics of presented LUN: $xmlClone `(Cloned Copy`)`r`n" | tee $logFailOv -end
		$out = Run-Plink-DRsite -exec <# display presented LUNs #>
		$out | findstr /i "$xmlClone" | tee $logFailOv -end
	}

	# Sleep for disk to be ready
	Echo "`r`n|| Sleeping 20 seconds for presented LUNs to be ready in Windows`r`n" | tee $logFailOv -end
	sleep 20

	## --- DISKPART BEGINS ---

	# Take LUN online in Disk Management

	for( $i=1; $i -le $LUN.length; $i++ ) {
		# Increment the last disk number by 1, to be used as the disk number for the new LUN
		$diskNumber = $WindowsDiskNumberTotal[-1]+$i
		Echo "`r`n|| Taking disk $diskNumber online in Windows`r`n" | tee $logFailOv -end
		$diskpartScript = @"
select disk $diskNumber
online disk noerr
attributes disk clear readonly
"@
		$diskpartScript | diskpart 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end
		sleep 3

		$xmlDriveLetter = $LUN[$i-1].DRDriveLetter
			
		# --------------- Start of unassigning drive letter as a precaution ---------------

		# Unassign all drive letters defined in xml for safety reason
	
		Echo "`r`n|| Unassigning $($xmlDriveLetter) from Windows disk volumes as a precaution. `(Message `"does not exist`" or similar may be expected`)`r`n" | tee $logFailOv -end
		$diskpartScript = @"
select volume $($xmlDriveLetter)
remove
"@
		$diskpartScript | diskpart 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end

		# --------------- End of unassigning drive letter as a precaution ---------------
		
		Echo "`r`n|| Assigning drive letter $($xmlDriveLetter) to partition 1 of disk $diskNumber`r`n" | tee $logFailOv -end
		$diskpartScript = @"
select disk $diskNumber
select partition 1
assign letter=$($xmlDriveLetter)
"@
		$diskpartScript | diskpart 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end

		# To workaround a problem in which partition 1 sometimes becomes Reserved for no reason and partition 2 becomes the Primary partition, automatically try partition 2 if failed

		if (!(Test-Path $xmlDriveLetter)) {

			Echo "`r`n|| Assigning drive letter $($xmlDriveLetter) to partition 2 of disk $diskNumber `(Workaround`)`r`n" | tee $logFailOv -end
			$diskpartScript = @"
select disk $diskNumber
select partition 2
assign letter=$($xmlDriveLetter)
"@
			$diskpartScript | diskpart 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end

		}
	}

	# --- DISKPART ENDS ---

	Echo "`r`nNOTE: Error messages from diskpart `(if available`) would be shown in regular color instead of red`r`n" | tee $logFailOv -end

	# Start replication

	Echo "`r`n|| Starting replication group: $($xmlRemoteReplGroupProd)`r`n" | tee $logFailOv -end

	$sanCmd = <# start remote replication group $xmlRemoteReplGroupProd #>
	Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end

	Echo "`r`n|| Displaying replication status`r`n" | tee $logFailOv -end

	sleep 5

	$sanCmd = <# display remote replication groups $xmlRemoteReplGroupProd #>
	Run-Plink-PRODsite -exec $sanCmd 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end
	
	Echo "`r`n|| Displaying active replication tasks `(if available`)`r`n" | tee $logFailOv -end
	sleep 5
	$out = Run-Plink-PRODsite -exec <# display recent tasks #>
	$out | findstr /i <# keyword to catch active replication tasks #> | tee $logFailOv -end

	# It may take time for the replication to complete

	Echo "" | tee $logFailOv -end
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	Pause
}

Function FAILOV_090_DRsite_WIN_ImportVM() {

	# Import VM

	Echo "`r`n|| Import-VM`r`n" | tee $logFailOv -end
	
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	Echo "`r`n[FAILOV_090_DRsite_WIN] Import VM in DRsite`r`n" | tee $logFailOv -end
	Echo "Windows command to be executed on $($varWinServDR):`r`n" | tee $logFailOv -end
	Foreach ($xmlVMDRCfg in $xmlVMDRCfgs) {
		Echo "Import-VM -Path `"$xmlVMDRCfg`"" | tee $logFailOv -end
	}

	# Path check
	Foreach ($xmlVMDRCfgUNC in $xmlVMDRCfgsUNC) {
		if (!(Test-Path $xmlVMDRCfgUNC)) {
			Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
			Echo "ERROR: VM config not found: `"$xmlVMDRCfgUNC`"" | tee $logFailOv -end
			Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
		}
	}

	Echo "" | tee $logFailOv -end
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	
	Foreach ($xmlVMDRCfg in $xmlVMDRCfgs) {
		Echo "`r`n|| Importing VM from `"$xmlVMDRCfg`"`r`n" | tee $logFailOv -end
		Invoke-Command -EA SilentlyContinue -ComputerName $varWinServDR -ScriptBlock { Import-VM -Path $args[0]|select VMName,State,VMId,Status,Uptime,Path } -argumentlist $xmlVMDRCfg 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end
	}
	Echo "" | tee $logFailOv -end
	Echo "NOTE: If VM import has been successful, VM statistics would be returned; otherwise, nothing would show." | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	Pause

}

Function FAILOV_095_DRsite_WIN_DisconnectVMNetworkAdapter() {

	# Disconnect VM Network Adapter
	
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	Echo "`r`n[FAILOV_095_DRsite_WIN] Disconnect VM Network Adapters in DRsite`r`n" | tee $logFailOv -end
	Echo "Windows command to be executed on $($varWinServDR):`r`n" | tee $logFailOv -end
	Foreach ($xmlVM in $xmlVMs) {
		 Echo "Get-VMNetworkAdapter -VMName `"$xmlVM`" `| Disconnect-VMNetworkAdapter" | tee $logFailOv -end
	}
	Echo "" | tee $logFailOv -end
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailOv -end
	
	# Show VM network adapter status for operator to record virtual switch and status info

	Foreach ( $xmlVM in $xmlVMs ) {
		Echo "`r`n|| Displaying VM Network Adapter Status: $xmlVM`r`n" | tee $logFailOv -end
		Invoke-Command -ComputerName $varWinServDR -ScriptBlock { Get-VMNetworkAdapter -VMName $args[0]|select Name,VMName,SwitchName,MacAddress } -ArgumentList $xmlVM | tee $logFailOv -end
	}

	# Disconnect Network Adapter

	Foreach ($xmlVM in $xmlVMs) {
		Echo "`r`n|| Disconnecting VM Network Adapters: $xmlVM`r`n" | tee $logFailOv -end
		Invoke-Command -ComputerName $varWinServDR -ScriptBlock { Disconnect-VMNetworkAdapter (Get-VMNetworkAdapter -VMName $args[0])|select Name,VMName,SwitchName,MacAddress } -ArgumentList $xmlVM 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end
	}

	# Verify virtual switch and status info (shodld be emptied)

	Foreach ( $xmlVM in $xmlVMs ) {
		Echo "`r`n|| Displaying VM Network Adapter Status: $xmlVM`r`n" | tee $logFailOv -end
		Invoke-Command -ComputerName $varWinServDR -ScriptBlock { Get-VMNetworkAdapter -VMName $args[0]|select Name,VMName,SwitchName,MacAddress } -ArgumentList $xmlVM | tee $logFailOv -end
	}
	Echo "" | tee $logFailOv -end
	Echo "NOTE: If VM network adapter is disconnected, virtual switch name would be empty." | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	Pause
}

Function FAILOV_100_DRsite_WIN_StartVM() {

	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	Echo "`r`n[FAILOV_100_DRsite_WIN] Start VM in DRsite (Optional)`r`n" | tee $logFailOv -end
	Echo "Windows command to be executed on $($varWinServDR):`r`n" | tee $logFailOv -end
	Foreach ($xmlVM in $xmlVMs) {
		 Echo "Start-VM -Name `"$xmlVM`"" | tee $logFailOv -end
	}
	Echo "" | tee $logFailOv -end
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
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailOv -end
	$startTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* Start Time: $startTime" | tee $logFailOv -end
	
	# Start VM

	Foreach ($xmlVM in $xmlVMs) {
		Echo "`r`n|| Starting VM: $xmlVM`r`n" | tee $logFailOv -end
		 Invoke-Command -ComputerName $varWinServDR -ScriptBlock { Start-VM -Name $args[0] } -argumentlist $xmlVM 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end
	}

	# Verification

	Foreach ( $xmlVM in $xmlVMs ) {
		Echo "`r`n|| Displaying status of VM: $xmlVM`r`n" | tee $logFailOv -end
		Invoke-Command -EA SilentlyContinue -ComputerName $varWinServDR -ScriptBlock { Get-VM $args[0]|select VMName,State,VMId,Status,Uptime,Path } -argumentlist $xmlVM 2>&1 | % { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_ | Out-File -end $logErrFailOv } $_ } | tee $logFailOv -end
	}
	Echo "" | tee $logFailOv -end
	$endTime = Get-Date -format "yyyy-MM-dd hh:mm:ss tt"; Echo "* End Time: $endTime" | tee $logFailOv -end
	Echo "" | tee $logFailOv -end
	Pause
}

