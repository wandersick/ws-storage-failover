
# ------------------------------------------------------------------------------------------------------------------------
#
#   General Storage Failover and Failback PowerShell Scripts (Template) for Failover Cluster (e.g. Hyper-V)
#   with an Easy-to-Use Interactive Console Menu for Operators
#   by @wandersick - https://wandersick.blogspot.com
#
#   Version: 1.0 (first-released December 2014)
#
#   Subscript Name: SAN Storage System - Plink (SAN_Plink.ps1)
#
#   Purpose: Functions which command SAN using plink.exe from PuTTY
#   
# ------------------------------------------------------------------------------------------------------------------------

Function Run-Plink-PRODsite ([String]$username=$storUser, [String]$password=$storPass, [String]$storageSystem=$storIpAddrPRODsite, [String]$exec=<# default command to execute #>)
{
	$plinkExecutable = "$plinkDir\plink.exe"
	& $plinkExecutable -l $username -pw $password -auto_store_key_in_cache $storageSystem $exec

}

Function Run-Plink-DRsite ([String]$username=$storUser, [String]$password=$storPass, [String]$storageSystem=$storIpAddrDRsite, [String]$exec=<# default command to execute #>)
{

	$plinkExecutable = "$plinkDir\plink.exe"
	& $plinkExecutable -l $username -pw $password -auto_store_key_in_cache $storageSystem $exec
}

