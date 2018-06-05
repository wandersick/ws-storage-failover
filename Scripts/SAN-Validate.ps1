
# ------------------------------------------------------------------------------------------------------------------------
#
#   General Storage Failover and Failback PowerShell Scripts (Template) for Failover Cluster (e.g. Hyper-V)
#   with an Easy-to-Use Interactive Console Menu for Operators
#   by @wandersick - https://wandersick.blogspot.com
#
#   Version: 1.0 (first-released December 2014)
#
#   Subscript Name: SAN Storage System - Validation (SAN-Validate.ps1)
#
#   Purpose: Validation subscript called by Console Menu script to confirm settings are valid
#
# ------------------------------------------------------------------------------------------------------------------------

Function testConfig() {
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailVe -end
	Echo "$selectedServerName - Part 1 of 2 - Show initial Parameters`r`n" | tee $logFailVe -end
	Pause
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailVe -end
	Echo "Preferred PRODsite Host: $desiredProdServ `($($varWinServProd)`) - [Example: PROD1]" | tee $logFailVe -end
	Echo "" | tee $logFailVe -end
	Echo "SAN Username: $storUser - [Example: username]" | tee $logFailVe -end
	Echo "SAN Password: $storPass - [Example: password]" | tee $logFailVe -end
	Echo "SAN PRODsite IP Address: $storIpAddrPRODsite - [Example: 10.1.60.108]" | tee $logFailVe -end
	Echo "SAN DRsite IP Address: $storIpAddrDRsite - [Example: 10.1.251.41]" | tee $logFailVe -end
	Echo "" | tee $logFailVe -end
	Echo "PuTTY Folder: $plinkDir - [Example: "'C:\Program Files\PuTTY]' | tee $logFailVe -end
	Echo "" | tee $logFailVe -end
	Echo "Name of PRODsite SAN System: $varSanSystemProd - [Example: PRODSAN]" | tee $logFailVe -end
	Echo "Name of DRsite SAN System: $varSanSystemDR - [Example: DRSAN]" | tee $logFailVe -end
	Echo "" | tee $logFailVe -end
	Echo "Name of PRODsite Hyper-V Host 1 `(Win`): $varWinServProd1 - [Example: PROD1]" | tee $logFailVe -end
	Echo "Name of PRODsite Hyper-V Host 2 `(Win`): $varWinServProd2 - [Example: PROD2]" | tee $logFailVe -end
	Echo "Name of DRsite Hyper-V Host `(Win`): $varWinServDR - [Example: DR1]" | tee $logFailVe -end
	Echo "" | tee $logFailVe -end
	Echo "Name of PRODsite Hyper-V Host 1 `(SAN`): $varSanServProd1 - [Example: PROD1]" | tee $logFailVe -end
	Echo "Name of PRODsite Hyper-V Host 2 `(SAN`): $varSanServProd2 - [Example: PROD2]" | tee $logFailVe -end
	Echo "Name of DRsite Hyper-V Host `(SAN`): $varSanServDR - [Example: DR1]" | tee $logFailVe -end
	Echo "" | tee $logFailVe -end
	
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailVe -end
	Echo "$selectedServerName - Part 2 of 2 - Show replication Parameters`r`n" | tee $logFailVe -end
	Pause
	Echo "`r`n********************************************************************************************`r`n" | tee $logFailVe -end
	Echo "Replication Group `(from PRODsite to DRsite`): $xmlRemoteReplGroupProd - [Example: REPL_GROUP_2_FAILOVER]" | tee $logFailVe -end
	Echo "Replication Group `(from DRsite to PRODsite`): $xmlRemoteReplGroupDR - [Example: REPL_GROUP_2_FAILBACK]" | tee $logFailVe -end
	Echo "" | tee $logFailVe -end
	# Example
	Echo "LUN `(Example`):" | tee $logFailVe -end
	Echo "  Ex 1. vol `(LUN`)" | tee $logFailVe -end
	Echo "  Ex 2. DR_vol `(DR LUN`)" | tee $logFailVe -end
	Echo "  Ex 3. DR_vol_clone `(DR Cloned Copy LUN`)" | tee $logFailVe -end
	Echo "  Ex 4. 50g `(Size`) *from SAN" | tee $logFailVe -end
	Echo "  Ex 5. FC_r6 `(UserRaidConfig`) *from SAN" | tee $logFailVe -end
	Echo "  Ex 6. FC_r6 `(ReplRaidConfig`) *from SAN" | tee $logFailVe -end
	Echo "  Ex 7. Cluster 01 `(Cluster Name in PRODsite`)" | tee $logFailVe -end
	Echo "  Ex 8. R: `(Drive Letter in DRsite`)" | tee $logFailVe -end
	Echo "" | tee $logFailVe -end
	for ($i=0; $i -lt $LUN.length; $i++) {
		Echo "LUN `(#$($i)`):" | tee $logFailVe -end
		Echo "  1. $($LUN[$i].label)" | tee $logFailVe -end
		Echo "  2. $($LUN[$i].label_DR)" | tee $logFailVe -end
		Echo "  3. $($xmlClones[$i])" | tee $logFailVe -end
		Echo "  4. $($LUN[$i].LUNSize)g" | tee $logFailVe -end
		Echo "  5. $($LUN[$i].UserRaidConfig)" | tee $logFailVe -end
		Echo "  6. $($LUN[$i].ReplRaidConfig)" | tee $logFailVe -end
		# Detect if the XML contains only one LUN instead of more than one LUNs. In that case, using [$i] would result in empty value
		if ($LUN.length -ne 1) {
			Echo "  7. $($xmlClusters[$i])" | tee $logFailVe -end
		} else {
			Echo "  7. $($xmlClusters)" | tee $logFailVe -end
		}
		Echo "  8. $($LUN[$i].DRDriveLetter)" | tee $logFailVe -end
		Echo "" | tee $logFailVe -end
	}
		
	# Different validation if it is a Hyper-V server
	if ($selectedServer -ne 0) {
		Echo "Virtual Machines `(VMs`): [Example: VMNAME]" | tee $logFailVe -end
		$xmlVMs | tee $logFailVe -end
		Echo "" | tee $logFailVe -end
		Echo "PRODsite VM Config Paths: [Example: C:\ClusterStorage\Volume1\VMNAME\...\{GUID}.xml]" | tee $logFailVe -end
		$xmlVMProdCfgs | tee $logFailVe -end
		Echo "" | tee $logFailVe -end
		Echo "PRODsite VM Config Paths `(UNC`): [Example: \\PROD1\C$\...\{GUID}.xml]" | tee $logFailVe -end
		$xmlVMProdCfgsUNC | tee $logFailVe -end
		Echo "" | tee $logFailVe -end
		Echo "DRsite VM Config Paths: [Example: Z:\VMNAME\...\{GUID}.xml]" | tee $logFailVe -end
		$xmlVMDRCfgs | tee $logFailVe -end
		Echo "" | tee $logFailVe -end
		Echo "DRsite VM Config Paths `(UNC`): [Example: \\PROD1\Z$\VMNAME\...\{GUID}.xml]" | tee $logFailVe -end
		$xmlVMDRCfgsUNC | tee $logFailVe -end
		Echo "" | tee $logFailVe -end
	}
	Pause
}

function testXMLFile() {
	[CmdletBinding()]
	param(
		[parameter(mandatory=$true)][ValidateNotNullorEmpty()]
		[string]$xmlFilePath
	)
	$xml = New-Object System.Xml.XmlDocument
	try {
		$xml.Load((Get-ChildItem -Path $xmlFilePath).FullName)
	}
	catch [System.Xml.XmlException] {
		Write-Verbose "$xmlFilePath : $($_.toString())"
		Echo "`r`n********************************************************************************************`r`n"
		Echo "ERROR: XML validation check failed"
		Echo "`r`n********************************************************************************************`r`n"
		Pause
	}
}

