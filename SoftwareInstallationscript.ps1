# Define the paths to the installers and their names
$softwareList = @(
    @{
        InstallerPath = "C:\Users\Administrator\Downloads\aspnetcore-runtime-8.0.10-win-x64.exe"
        SoftwareName = "aspnetcore-runtime-8.0.10-win-x64.exe"
        InstallCommand = "/quiet /norestart"
    },
    @{
        InstallerPath = "C:\Users\Administrator\Downloads\dotnet-sdk-8.0.406-win-x64.exe"
        SoftwareName = "dotnet-sdk-8.0.406-win-x64.exe"
        InstallCommand = "/quiet /norestart"
    },
    @{
        InstallerPath = "C:\Users\Administrator\Downloads\jdk-8u431-windows-x64.exe"
        SoftwareName = "jdk-8u431-windows-x64.exe"
        InstallCommand = "/s"
    },
    @{
        InstallerPath = "C:\Users\Administrator\Downloads\mattermost-desktop-5.8.1-x64.msi"
        SoftwareName = "mattermost-desktop-5.8.1-x64.msi"
        InstallCommand = "/qn /norestart"
    },
    @{
        InstallerPath = "C:\Users\Administrator\Downloads\msodbcsql.msi"
        SoftwareName = "msodbcsql.msi"
        InstallCommand = "/qn IACCEPTMSODBCSQLLICENSETERMS=YES"
    },
    @{
        InstallerPath = "C:\Users\Administrator\Downloads\msoledbsql.msi"
        SoftwareName = "msoledbsql.msi"
        InstallCommand = "/qn IACCEPTMSOLEDBSQLLICENSETERMS=YES"
    },
    @{
        InstallerPath = "C:\Users\Administrator\Downloads\windowsdesktop-runtime-8.0.10-win-x64.exe"
        SoftwareName = "windowsdesktop-runtime-8.0.10-win-x64.exe"
        InstallCommand = "/install /quiet /norestart"
    },
    @{
        InstallerPath = "C:\Users\Administrator\Downloads\CitrixWorkspaceApp.exe"
        SoftwareName = "CitrixWorkspaceApp.exe"
        InstallCommand = "/silent /norestart"
    }
)

$allowedIPs = @("192.168.6.11", "192.168.6.10")

# Get the IP address of the domain controller
$dcIP = (Test-Connection -ComputerName $env:COMPUTERNAME -Count 1).IPv4Address.IPAddressToString
Write-Host "Domain Controller IP: $dcIP"

# Get the list of all computers in the domain
$computers = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name

foreach ($computer in $computers) {
    # Get the IP address of the current computer
    $ipAddress = (Test-Connection -ComputerName $computer -Count 1).IPv4Address.IPAddressToString
    Write-Host "Processing computer: $computer with IP: $ipAddress"

    # Check if the IP address is in the list of allowed IPs and is not the domain controller
    if ($allowedIPs -contains $ipAddress -and $ipAddress -ne $dcIP) {
        Write-Host "Installing on computer: $computer with IP: $ipAddress"

        # Create the tools directory on the remote machine
        mkdir "\\$computer\C$\Users\Administrator\tools" -ErrorAction SilentlyContinue

        foreach ($software in $softwareList) {
            # Copy each installer to the remote machine
            $destPath = "\\$computer\C$\Users\Administrator\tools\$($software["SoftwareName"])"
            Write-Host "Copying $($software["SoftwareName"]) to $destPath"
            Copy-Item -Path $software["InstallerPath"] -Destination $destPath -Force

            # Run the installer silently
            Write-Host "Running $($software["SoftwareName"]) on $computer"
            try {
                if ($software["SoftwareName"] -like "*.exe") {
                    Invoke-Command -ComputerName $computer -ScriptBlock { param ($path, $cmd) Start-Process -FilePath $path -ArgumentList $cmd -Wait -NoNewWindow } -ArgumentList $destPath, $software["InstallCommand"] -ErrorAction Stop
                } elseif ($software["SoftwareName"] -like "*.msi") {
                    Invoke-Command -ComputerName $computer -ScriptBlock { param ($path, $cmd) Start-Process -FilePath msiexec.exe -ArgumentList "/i $path $cmd" -Wait -NoNewWindow } -ArgumentList $destPath, $software["InstallCommand"] -ErrorAction Stop
                }
                Write-Host "Successfully installed $($software["SoftwareName"]) on $computer"
            } catch {
                Write-Host "Failed to install $($software["SoftwareName"]) on $computer. Error: $_"
            }
        }
    } else {
        Write-Host "Skipping computer: $computer with IP: $ipAddress"
    }
}
