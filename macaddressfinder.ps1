# Get all network adapters
$networkAdapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.MACAddress -ne $null}

# Display the MAC addresses
foreach ($adapter in $networkAdapters) {
    Write-Output "Network Adapter: $($adapter.Description)"
    Write-Output "MAC Address: $($adapter.MACAddress)"
    Write-Output ""
}
