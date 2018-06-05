
# ------------------------------------------------------------------------------------------------------------------------
#
#   General Storage Failover and Failback PowerShell Scripts (Template) for Failover Cluster (e.g. Hyper-V)
#   with an Easy-to-Use Interactive Console Menu for Operators
#   by @wandersick - https://wandersick.blogspot.com
#
#   Version: 1.0 (first-released December 2014)
#
#   Subscript Name: SAN Storage System - PS1 Parameters (SAN-Parameters.ps1)
#
#   Purpose: Script options defined here
#
# ------------------------------------------------------------------------------------------------------------------------

# PuTTY plink.exe Path - https://www.PuTTY.org
$plinkDir = "C:\Program Files\PuTTY" # Confirm the folder is configured

# Define name of SAN systems (Prod, DR)
$varSanSystemProd = "PRODSAN"
$varSanSystemDR = "DRSAN"

# SAN basic configuration (Prod, DR; same credentials for both)
$storIpAddrPRODsite = "10.10.10.10"
$storIpAddrDRsite = "10.20.20.20"
$storUser = "username"
$storPass = "password"

# For Hyper-V Server (assumed Hyper-V cluster of two nodes in production site; Hyper-V standalone server in DR site), specify hostnames
$varVirtWinServProd1 = "VIRTSRVPROD1"
$varVirtWinServProd2 = "VIRTSRVPROD2"
$varVirtWinServDR = "VIRTSRVDR1"

# Likewise, specify hostnames again, this time for communication with SAN (in case SAN configuration contains different names)
$varVirtSanServProd1 = "VIRTSRVPROD1"
$varVirtSanServProd2 = "VIRTSRVPROD2"
$varVirtSanServDR = "VIRTSRVDR1"

# For general server (assumed Failover Cluster of two nodes in production site; standalone server in DR site), specify hostnames
$varGenWinServProd1 = "GENSRVPROD1"
$varGenWinServProd2 = "GENSRVPROD2"
$varGenWinServDR = "GENSRVDR1"

# Likewise, specify hostnames again, this time for communication with SAN (in case SAN configuration contains different names)
$varGenSanServProd1 = "GENSRVPROD1"
$varGenSanServProd2 = "GENSRVPROD2"
$varGenSanServDR = "GENSRVDR1"

# Specify preferred cluster node in production site (to be further processed by SAN-Variables.ps1) – as an example, this is not available for DR site which normally does not have as many servers

# Preferred Hyper-V cluster node in production site [ 1 | 2 ]
$desiredVirtProdServ = 1

# Preferred general Failover Cluster node in production site [ 1 | 2 ]
$desiredGenProdServ = 1

# REMINDER: If preferred node is changed, adjust the production VMConfig path in XML accordingly (if required)

# Prefix for LUN names created in DR site, e.g. dr_
$varLUNPrefixDR = "DR_"

# Suffix for LUN names of cloned copy created in DR site, e.g. _clone
$varLUNOPCSuffixDR = "_clone"

# Settings below this line are advanced. They must not be modified easily.
# --------------------------------------------------------------------------

if ($selectedServer -eq 0) {
	# After operator selects 'Hyper-V Server' in menu
	
	# Define names of general servers specified in Windows
	$varWinServProd1 = $varGenWinServProd1
	$varWinServProd2 = $varGenWinServProd2
	$varWinServDR = $varGenWinServDR

	# Define names of general servers specified in SAN
	$varSanServProd1 = $varGenSanServProd1
	$varSanServProd2 = $varGenSanServProd2
	$varSanServDR = $varGenSanServDR

	# Define preferred cluster node in production site
	$desiredProdServ = $desiredGenProdServ

} elseif ($selectedServer -eq 1) {
	# After operator selects 'Virtual Server' in menu

	# Define names of Hyper-V servers specified in Windows
	$varWinServProd1 = $varVirtWinServProd1
	$varWinServProd2 = $varVirtWinServProd2
	$varWinServDR = $varVirtWinServDR

	# Define names of Hyper-V servers specified in SAN
	$varSanServProd1 = $varVirtSanServProd1
	$varSanServProd2 = $varVirtSanServProd2
	$varSanServDR = $varVirtSanServDR

	# Define preferred cluster node in production site
	$desiredProdServ = $desiredVirtProdServ
}

# Setting the user-preferred cluster node to use for passing commands in production site
if ($desiredProdServ -eq 1) {
	$varWinServProd = $varWinServProd1
} elseif ($desiredProdServ -eq 2) {
	$varWinServProd = $varWinServProd2
}

$dateTime = Get-Date -format "yyyyMMdd_hhmmsstt"

# Log File (stdout and stderr)
$logFailOv = "$($ScriptDir)\Logs\FailOver_$($selectedServerNameShort)_$($dateTime).log"
$logFailBk = "$($ScriptDir)\Logs\FailBack_$($selectedServerNameShort)_$($dateTime).log"
$logFailSr = "$($ScriptDir)\Logs\SuspendResume_$($selectedServerNameShort)_$($dateTime).log"
$logFailCs = "$($ScriptDir)\Logs\CheckStatus_$($selectedServerNameShort)_$($dateTime).log"
$logFailVe = "$($ScriptDir)\Logs\Verify_$($selectedServerNameShort)_$($dateTime).log"

# Error Log File (stderr)
$logErrFailOv = "$($ScriptDir)\Logs\FailOver_$($selectedServerNameShort)_$($dateTime)_Errors.log"
$logErrFailBk = "$($ScriptDir)\Logs\FailBack_$($selectedServerNameShort)_$($dateTime)_Errors.log"
$logErrFailSr = "$($ScriptDir)\Logs\SuspendResume_$($selectedServerNameShort)_$($dateTime)_Errors.log"
$logErrFailCs = "$($ScriptDir)\Logs\CheckStatus_$($selectedServerNameShort)_$($dateTime)_Errors.log"
$logErrFailVe = "$($ScriptDir)\Logs\Verify_$($selectedServerNameShort)_$($dateTime)_Errors.log"

# Define XML Parameters file path
$xmlConfigFile = "$($ScriptDir)\Parameters\SAN-Parameters.xml"

# Define subscript file paths
$ps1Plink = "$($ScriptDir)\Scripts\SAN-Plink.ps1"
$ps1ConfigFile = "$($ScriptDir)\Scripts\SAN-Variables.ps1"
$ps1FailOver = "$($ScriptDir)\Scripts\SAN-Failover.ps1"
$ps1FailBack = "$($ScriptDir)\Scripts\SAN-Failback.ps1"
$ps1CheckStatus = "$($ScriptDir)\Scripts\SAN-GetStatus.ps1"
$ps1Validation = "$($ScriptDir)\Scripts\SAN-Validate.ps1"

# Load plink function
. "$ps1Plink"

if (-not (Test-Path $plinkExecutable)) {
	Write-Host "PuTTY plink.exe does not exist in $plinkDir. Download it from https://www.PuTTY.org"
	Pause
	Exit
}

# Load variable parameters file (XML and more)
. "$ps1ConfigFile"

# Load failover, failback, check status, validation subscripts
. "$ps1FailOver"
. "$ps1FailBack"
. "$ps1CheckStatus"
. "$ps1Validation"
