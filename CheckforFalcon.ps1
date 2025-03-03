# Import the Active Directory module
Import-Module ActiveDirectory

# Get all computer objects in Active Directory
$computers = Get-ADComputer -Filter *

# Loop through each computer and check for the Falcon sensor service
foreach ($computer in $computers) {
    # Get the computer name
    $computerName = $computer.Name
    
    # Use Invoke-Command to run the service check on the remote computer
    $serviceStatus = Invoke-Command -ComputerName $computerName -ScriptBlock {
        Get-Service -Name "CSFalconService" -ErrorAction SilentlyContinue | Select-Object Name, Status
    } -Credential (Get-Credential)
    
    # Check if the service was found and display the status
    if ($serviceStatus) {
        Write-Output "Computer: $computerName"
        Write-Output "Service Name: $($serviceStatus.Name)"
        Write-Output "Service Status: $($serviceStatus.Status)"
        Write-Output ""
    } else {
        Write-Output "Computer: $computerName - Falcon sensor not found"
        Write-Output ""
    }
}
