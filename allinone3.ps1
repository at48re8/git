# Define the username and password for the account you want to enable auto-login for
$username = "Administrator"
$password = "!qaz2wsX"

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