**Note**: This is a template to ease development. The storage-vendor-specific part of the scripts have to be coded by yourself.

For download of the latest version, visit its [page at Microsoft TechNet Gallery](https://gallery.technet.microsoft.com/General-SAN-Storage-dc8875d8).

# Introduction

There sometimes comes a need to simply complex operations, in this case failover and failback operations of SAN storage replication between sites (e.g. production and DR), for reasons such as letting operators or the less technically-confident colleagues to more easily perform the operations in case of disasters or drill tests. To achieve that, this template has been created.

Written primarily in PowerShell, this package contains a set of SAN storage failover and failback scripts for Microsoft Failover Cluster (including Hyper-V cluster) and vendor-neutral pseudo code for SAN storage (for further modification to support different SAN vendors). Not only does it perform storage failover and failback, services running on top of it such as databases and virtual machines can also be catered.

Moreover, it features a user-friendly interactive console menu, where complex operations are handled by the scripts in the backend.

![Failover and Failback Console Menu](https://lh3.googleusercontent.com/-Z5E0AR-QZoQ/Ww6nkgFV2bI/AAAAAAAAB38/pmD0EEc3FR8hEmZxl9hB-KYcLI41QgX5QCHMYCw/s1600/SAN-Failover-Failback-Console-Menu%255B9%255D)

Served as a general template for implementation, one has to fill in the blanks – SAN-vendor-specific commands – to fit for his/her own use. Although the Failover Cluster parts and the interactive console menu are already there, further coding and testing cannot be avoided.

The scripts were designed to be as reusable (e.g. parameterized) as possible, in order to allow me to more easily adapt it to fit different projects. It has also been released as an open-source project on the GitHub repository [ws-storage-failover](https://github.com/wandersick/ws-storage-failover) which encourages IT pros to fork it to for their own SAN storage systems, and if possible, contribute their modified bits in returns, assisting others who might want to implement it for their own choice of SAN storage systems.

# Features

- Script failover and failback between replicated SAN storage with Microsoft Failover Cluster (Hyper-V and others)
- Operator-friendly interactive console menus through which failover, failback and validation, status reporting can be performed
- Steps can be performed individually or all at once
- Scripted in PowerShell (Windows operations) and pseudo code (SAN-specific operations) as a template to be modified or customized
- Define variables or fill in parameters in SAN-Parameters.xml and SAN-Parameters.ps1
- Pseudo code of SAN operations is provided inside &lt;# #&gt; inline comment blocks to be replaced as required per command-line reference of SAN storage
- Speed up development of automated/manual SAN failover/failback with this set of scripts
- Leverage the command-line interface usually provided by SAN storage systems over SSH which makes it possible to use plink.exe (from PuTTY) to command SAN storage systems in scripts
- Default scenario is for storage systems located in two sites with SAN-level replication
- Console outputs are logged under Logs folder, with error messages separately stored
- Open-source project on GitHub, encouraging forking

# Requirements

- SAN storage systems with SAN replication enabled (2 sites – production and DR sites assumed) with hosts running Failover Cluster (e.g. Hyper-V) in each site
- A Windows client that runs the console menu with PowerShell 3.0 or above (comes with Windows 8.1 and Windows Server 2012 R2)
- PuTTY should be installed under a location specified in SAN-Parameters.ps1
- A one-time authentication may be required by connecting to SAN storage systems in both sites via SSH (with PuTTY or plink.exe) in order to cache the host key in registry
- Run PowerShell as Administrator prior to running the Console Menu script

# Script File Structure

    ¦   SAN-Console_Menu.ps1 // Menu for selecting among operations (failover, failback, validation, etc.)
    ¦
    +---Logs // Console output and errors are recorded separately here
    ¦       ...
    ¦
    +---Parameters
    ¦       SAN-Parameters.ps1 // Script options can be specified here (PowerShell)
    ¦       SAN-Parameters.xml // SAN replication options specified here (XML)
    ¦
    +---Scripts
            SAN-Failback.ps1 // Failback operation subscript called by Console Menu script
            SAN-Failover.ps1 // Failover operation subscript called by Console Menu script
            SAN-GetStatus.ps1 // Status querying subscript called by Console Menu script
            SAN-Plink.ps1 // Functions which command SAN using plink.exe from PuTTY
            SAN-Variables.ps1 // Variables from XML, PS1 parameter files and SAN are further processed here
            SAN-Validate.ps1 // Validation subscript called by Console Menu script to confirm settings are valid

![Validation](https://lh3.googleusercontent.com/-f13xAuxWyRo/Ww6t3jIYeHI/AAAAAAAAB4Y/kNAy658r0XoInJfzdhdruU3eFQHm2dJNwCHMYCw/s1600/image%255B3%255D)

# Getting Started

1. Edit SAN-Parameters.ps1 and .xml files for options such as changing the user account for SSH communication with your SAN.
2. All pseudo code (SAN-specific operations) inside &lt;# #&gt; should be replaced with the implementation of your SAN vendor. For example, change _Echo &lt;# display LUN #&gt;_ to the actual command _lsvdisk_ (IBM/Lenovo Storwize), _lun show_ (NetApp), _volcoll_ (HPE Nimble), etc.
3. Perform further development or customization according to your needs. For example:
  - Follow the comments in the script
  - Names of functions, variables and echo messages are self-explanatory

# Core Functions

## A. Failover from Site 1 to Site 2 (e.g. Production to DR)

### 1. Hyper-V Cluster

1. End Replication - from Production Site to DR Site
2. Create Clone from Replicated LUN in DR Site
3. Present Cloned LUN to DR Site Host, Take Disk Online, Run Replication from Production Site to DR Site
4. Import VM in DR Site
5. Disconnect VM Network Adapter in DR Site

### 2. General Failover Cluster

1. End Replication - from Production Site to DR Site
2. Create Clone from Replicated LUN in DR Site
3. Present Cloned LUN to DR Site Host, Take Disk Online, Run Replication from Production Site to DR Site

## B. Failback from Site 2 to Site 1 (e.g. DR to Production)

### 1. Hyper-V Cluster

1. Stop and Delete Replication Group - from Production Site to DR Site
2. Stop and Delete Replication Group - from DR Site to Production Site
3. Stop VM in Production Site
4. Stop CSV in Production Site
5. Delete VM in Production Site
6. Unpresent LUN of CSV from Production Site Hosts
7. Delete LUN of CSV in Production Site
8. Create LUN of CSV in Production Site
9. Create Replication Group - from DR Site to Production Site
10. Add LUN to Replication Group - from DR Site to Production Site
11. Run Replication Group - from DR Site to Production Site
12. Stop VM in DR Site
13. Take Disk Offline in DR Site Host
14. Unpresent Cloned LUN from DR Site Host
15. Stop and Delete Replication Group - from DR Site to Production Site
16. Present LUN of Replicated CSV to Production Site Hosts
17. Run CSV in Production Site
18. Import VM in Production Site
19. Disconnect VM Network Adapters in Production Site
20. Run VM in Production Site
21. Create Replication Group - from Production Site to DR Site
22. Add LUN to Replication Group - from Production Site to DR Site
23. Run Replication Group - from Production Site to DR Site

### 2. General Failover Cluster

1. Stop and Delete Replication Group - from Production Site to DR Site
2. Stop and Delete Replication Group - from DR Site to Production Site
3. Stop CSV in Production Site
4. Unpresent LUN of CSV from Production Site Hosts
5. Delete LUN of CSV in Production Site
6. Create LUN of CSV in Production Site
7. Create Replication Group - from DR Site to Production Site
8. Add LUN to Replication Group - from DR Site to Production Site
9. Run Replication Group - from DR Site to Production Site
10. Take Disk Offline in DR Site Host
11. Unpresent Cloned LUN from DR Site Host
12. Stop and Delete Replication Group - from DR Site to Production Site
13. Present LUN of Replicated CSV to Production Site Hosts
14. Run CSV in Production Site
15. Create Replication Group - from Production Site to DR Site
16. Add LUN to Replication Group - from Production Site to DR Site
17. Run Replication Group - from Production Site to DR Site

# Limitations

- There is no one-size-fits-all solution – modification is inevitable
- Not all error messages are separately recorded in error log file; some errors only exist in the main log. Outputs and errors encountered in the menu are not logged
- SAN storage credentials are stored in the ps1 configuration file in clear text (protect the file properly)

## Release history

| Ver | Date | Changes |
| --- | --- | --- |
| 1.1 | 20190302 | Improved delimiter choice in Scripts\SAN-Variables.ps1 |
| 1.0a | 20141231 | First released in December 2014 |
