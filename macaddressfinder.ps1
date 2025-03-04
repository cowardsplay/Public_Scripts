# Import the Active Directory module
Import-Module ActiveDirectory

# Prompt for credentials once and store them
$credential = Get-Credential

# Get all computer objects in Active Directory
$computers = Get-ADComputer -Filter *

# Create or clear the output file
$outputFile = "C:\Users\Administrator\AllMACAddresses.txt"
Clear-Content -Path $outputFile -ErrorAction SilentlyContinue
New-Item -Path $outputFile -ItemType File -Force

# Loop through each computer and get the MAC addresses
foreach ($computer in $computers) {
    # Get the computer name
    $computerName = $computer.Name
    
    # Use Invoke-Command to run the MAC address check on the remote computer with stored credentials
    $result = Invoke-Command -ComputerName $computerName -Credential $credential -ScriptBlock {
        Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'" | Select-Object MACAddress
    }
    
    # Check if MAC addresses were found and append the information to the output file
    if ($result) {
        Add-Content -Path $outputFile -Value "Computer: $computerName"
        foreach ($macAddress in $result.MACAddress) {
            Add-Content -Path $outputFile -Value "MAC Address: $macAddress"
        }
        Add-Content -Path $outputFile -Value ""
    }
}

# Display a message indicating the script has completed
Write-Output "MAC address collection completed. Results saved to $outputFile"
