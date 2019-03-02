
# ------------------------------------------------------------------------------------------------------------------------
#
#   General Storage Failover and Failback PowerShell Scripts (Template) for Failover Cluster (e.g. Hyper-V)
#   with an Easy-to-Use Interactive Console Menu for Operators
#   by @wandersick - https://wandersick.blogspot.com
#
#   Version: 1.0.1 (updated on 2 March 2019)
#
#   Subscript Name: SAN Storage System - Processing of Variables (SAN-Variables.ps1)
#
#   Purpose: Variables from XML, PS1 config files and SAN are further processed here
#
# ------------------------------------------------------------------------------------------------------------------------

$tempFile = [IO.Path]::GetTempFileName()
if ( -not( Test-Path $xmlConfigFile))
{
	Write-Host "File $xmlConfigFile does not exist"
	Pause
	exit
}

type $xmlConfigFile | Out-File $tempFile

# Load Parameters from XML
[xml]$xml = Get-Content $tempFile

# External VBScript for converting drive letter to physical disk number
$vol2PhyDisk = "$($ScriptDir)\Scripts\ConvertVolToPhyDisk.vbs"

# Load name of Production remote relication group
$xmlRemoteReplGroupProd = $xml.Definitions.Servers.Server[$selectedServer].ReplicationGroups.RemoteReplGroup.Prod

# Load name of Disaster Recovery remote replication group
$xmlRemoteReplGroupDR = $xml.Definitions.Servers.Server[$selectedServer].ReplicationGroups.RemoteReplGroup.DR

# Delete on each new return to Server Menu so that parameters are refreshed from SAN dynamically (LUN size, RAID config) according to the LUNs of selected server

Remove-Item Variable:\dynamicLUNs -EA SilentlyContinue -Recurse
Remove-Item Variable:\xmlClones -EA SilentlyContinue -Recurse

# Acquire LUNs from XML: $LUN[0].label, $LUN[1].label
$LUN = $xml.Definitions.Servers.Server[$selectedServer].LUNs.LUN

# Form a new array (with dynamic data from SAN and static data from XML)
$counter = 0

Foreach ($xmlLUN in $LUN.label) {

	$objMember = New-Object PSObject

	# Load LUN names in a new array to be created
	Add-Member -InputObject $objMember -MemberType NoteProperty -Name 'Label' -Value "$xmlLUN"
	$tmpLUNDR = "$varLUNPrefixDR" + "$xmlLUN"

	Add-Member -InputObject $objMember -MemberType NoteProperty -Name 'Label_DR' -Value "$tmpLUNDR"

	# end _clone to LUN names as cloned copy names ($LUN[0].LUNClone)

	$tmpLUNOPCDR = "$varLUNPrefixDR" + "$xmlLUN" + "$varLUNOPCSuffixDR"
	Add-Member -InputObject $objMember -MemberType NoteProperty -Name 'LUNClone' -Value "$tmpLUNOPCDR"

	# For backward compatibility, also store cloned copy names in xmlClones array
	[array]$xmlClones += "$tmpLUNOPCDR"

	# Acquire LUN ReplRaidConfigs from SAN: $LUN[0].ReplRaidConfig, $LUN[1].ReplRaidConfig
	# Acquire LUN UserRaidConfigs from SAN: $LUN[0].UserRaidConfig, $LUN[1].UserRaidConfig

	$sanCmd = <# display logical disk and LUN details for $tmpLUNDR #>
	# It is required to use $xmlLUN as a workaround below since child logical disk does not contain dr_ prefix although parent LUN is dr_.
	$out = Run-Plink-DRsite -exec $sanCmd | findstr /i "$xmlLUN"
	$out = $out -split "\s+"

	Add-Member -InputObject $objMember -MemberType NoteProperty -Name 'ReplRaidConfig' -Value $out[2]
	Add-Member -InputObject $objMember -MemberType NoteProperty -Name 'UserRaidConfig' -Value $out[2]

	# Acquire LUN size from SAN: $LUN[0].LUNSize, $LUN[1].LUNSize

	$sanCmd = <# display a list of LUNs for $tmpLUNDR #>
	$out = Run-Plink-DRsite -exec $sanCmd | findstr /i "$tmpLUNDR"
	$out = $out -split "\s+"
	$out = [Int]$out[-1]/1024

	Add-Member -InputObject $objMember -MemberType NoteProperty -Name 'LUNSize' -Value $out

	# Detect if the XML contains only one LUN instead of more than one LUNs. In that case, using [$counter] would result in empty value

	if ($LUN[0].label) {
		$xmlDriveLetter = $LUN[$counter].DRDriveLetter
		$xmlClusterName = $LUN[$counter].ProdClusterName
	} else {
		$xmlDriveLetter = $LUN.DRDriveLetter
		$xmlClusterName = $LUN.ProdClusterName
	}

	# Load Disaster Recovery drive letter from XML

	Add-Member -InputObject $objMember -MemberType NoteProperty -Name 'DRDriveLetter' -Value $xmlDriveLetter

	# Load prod cluster drive letter from XML

	Add-Member -InputObject $objMember -MemberType NoteProperty -Name 'ProdClusterName' -Value $xmlClusterName

	[array]$dynamicLUNs += $objMember

	$counter++
}

# Hyper-V VM and VM config paths do not need to be stored in the new array because there is no need to relate them to individual LUN. Just start/stop them altogether.

# For backward compatibility (the array is named LUN although data from XML and SAN are used)
$LUN = $dynamicLUNs

# Enumerate VM names
$xmlVMs = $xml.Definitions.Servers.Server[$selectedServer].LUNs.LUN.VirtualMachines.VM.Label

# Enumerate names of clusters used in PRODsite Hyper-V hosts
# For backward compatibility (subscripts use $xmlClsuters instead of $LUN[$i].ProdClusterName)
$xmlClusters = $xml.Definitions.Servers.Server[$selectedServer].LUNs.LUN.ProdClusterName

# Enumerate Prod VM config paths
$xmlVMProdCfgs = $xml.Definitions.Servers.Server[$selectedServer].LUNs.LUN.VirtualMachines.VM.VMConfig.Prod

Remove-Item Variable:\xmlVMProdCfgsUNC -EA SilentlyContinue -Recurse

# Convert to UNC path so that Test-Path can check it on any server
Foreach ($xmlVMProdCfg in $xmlVMProdCfgs) {
   [array]$xmlVMProdCfgsUNC += $xmlVMProdCfg -replace "^(.).","\\$varWinServProd\`$1$"
}

# Enumerate Disaster Recovery VM config paths
$xmlVMDRCfgs = $xml.Definitions.Servers.Server[$selectedServer].LUNs.LUN.VirtualMachines.VM.VMConfig.DR

Remove-Item Variable:\xmlVMDRCfgsUNC -EA SilentlyContinue -Recurse

# Convert to UNC path so that Test-Path can check it on any server
Foreach ($xmlVMDRCfg in $xmlVMDRCfgs) {
   [array]$xmlVMDRCfgsUNC += $xmlVMDRCfg -replace "^(.).","\\$varWinServDR\`$1$"
}

