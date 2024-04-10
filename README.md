# Remote-File-Integrity-Monitoring
 This project contributes to cybersecurity integrity efforts by enabling file integrity monitoring and remote execution capabilities. By proactively monitoring file integrity and facilitating remote management, the  script enhances security posture, supports incident detection and response, and assists organizations in meeting compliance requirements in the ever-evolving landscape of cybersecurity threats.

# Requirements
Environment: A Windows environment where PowerShell is installed and accessible. The script is designed to run on Windows operating systems.

Access Permissions: Ensure that you have the necessary permissions to read, write, and execute files and folders, both locally and on remote systems if applicable.

Script Dependencies: The script relies on the availability of PowerShell modules such as Microsoft.PowerShell.Utility for functions like Get-FileHash. Ensure that these modules are installed and accessible in your PowerShell environment.

Corrected Remote Paths: If you intend to use the remote execution functionality, ensure that you have corrected the remote paths in the Copy-FilesToRemote and Execute-ScriptRemotely functions to point to valid directories on the remote computer.

Network Connectivity: For remote execution, ensure that the remote computer is reachable over the network, and you have the necessary network access permissions.

Execution Policy: Depending on your system's PowerShell execution policy, you might need to adjust it to allow the execution of PowerShell scripts. You can set the execution policy using the Set-ExecutionPolicy cmdlet.
 





# Usage
