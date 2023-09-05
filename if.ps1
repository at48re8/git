# Function to check if system settings are already configured
function CheckSystemSettings {
    # Check if AutoAdminLogon is already enabled
    $autoAdminLogon = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name "AutoAdminLogon" -ErrorAction SilentlyContinue
    $uacEnabled = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -ErrorAction SilentlyContinue
    $firewallStatus = Get-NetFirewallProfile | ForEach-Object { $_.Enabled }

    if ($autoAdminLogon -ne $null -and $autoAdminLogon.AutoAdminLogon -eq "1" -and
        $uacEnabled -ne $null -and $uacEnabled.EnableLUA -eq 0 -and
        $firewallStatus -eq "False") {
        return $true
    }

    return $false
}

# Prompt the user to set default system settings if they are not already set
if (-not (CheckSystemSettings)) {
    Write-Host "System settings are not configured as default."
    $confirm = Read-Host "Do you want to set the default system settings? (Y/N)"
    
    if ($confirm -eq "Y" -or $confirm -eq "y") {
        # Set the system settings as before
        # ...

        Write-Host "Default system settings have been set."
        Write-Host "Please restart the system for the changes to take effect."
        pause
        Restart-Computer
    } else {
        Write-Host "Default system settings were not set."
    }
} else {
    Write-Host "System settings are already configured as default."
}

# Rest of your script here
# ...

# Prompt the user for their username and password
$username = Read-Host "Enter your username"
$password = Read-Host -AsSecureString "Enter your password"

# Set the registry keys to enable auto-login
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $regPath -Name "AutoAdminLogon" -Value "1"
Set-ItemProperty -Path $regPath -Name "DefaultUserName" -Value $username
Set-ItemProperty -Path $regPath -Name "DefaultPassword" -Value $password

# Disable UAC verification
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorUser" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 0

#Disable firewall

netsh advfirewall set allprofiles state off

# Notify the user that UAC has been disabled
Write-Host "User Account Control (UAC) verification has been disabled."
Write-Host "Please restart the system for the changes to take effect."
pause
# Set power scheme to High Performance
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Disable display turn off
powercfg -change -monitor-timeout-ac 0
powercfg -change -monitor-timeout-dc 0

# Enable automatic logon for domain-joined servers (optional)
# If your server is in a domain, you may need to set "DefaultDomainName" as well
# Set-ItemProperty -Path $regPath -Name "DefaultDomainName" -Value "YourDomainName"
# Set the NTP server to a server in Taiwan (e.g., time.stdtime.gov.tw)

$NtpServer = "time.stdtime.gov.tw"

# Set the time zone to Taipei
Set-TimeZone -Id "Taipei Standard Time"

# Display the current time zone to verify the change
Get-TimeZone


# Configure the NTP server
w32tm /config /manualpeerlist:$NtpServer /syncfromflags:manual /reliable:YES /update

# Restart the Windows Time service
Restart-Service w32time

# Force synchronization
w32tm /resync /force

# Display the current time configuration
w32tm /query /status

# Reboot the server to apply the changes
Restart-Computer