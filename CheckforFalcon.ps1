# Import the Active Directory module
Import-Module ActiveDirectory

# Prompt for credentials once and store them
$credential = Get-Credential

# Get all computer objects in Active Directory
$computers = Get-ADComputer -Filter *

# Create or clear the output file
$outputFile = "C:\Users\Administrator\FalconSensorStatus.txt"
Clear-Content -Path $outputFile -ErrorAction SilentlyContinue
New-Item -Path $outputFile -ItemType File -Force

# Loop through each computer and check for the Falcon sensor service
foreach ($computer in $computers) {
    # Get the computer name
    $computerName = $computer.Name
    
    # Use Invoke-Command to run the service check on the remote computer with stored credentials
    $serviceStatus = Invoke-Command -ComputerName $computerName -Credential $credential -ScriptBlock {
        Get-Service -Name "CSFalconService" -ErrorAction SilentlyContinue | Select-Object Name, Status
    }
    
    # Check if the service was found and append the status to the output file
    if ($serviceStatus) {
        Add-Content -Path $outputFile -Value "Computer: $computerName"
        Add-Content -Path $outputFile -Value "Service Name: $($serviceStatus.Name)"
        Add-Content -Path $outputFile -Value "Service Status: $($serviceStatus.Status)"
        Add-Content -Path $outputFile -Value ""
    }
}

# Display a message indicating the script has completed
Write-Output "Falcon sensor status check completed. Results saved to $outputFile"
