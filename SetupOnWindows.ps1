# Prompt the user for their username and password
$username = Read-Host "Enter your username"

# Initialize variables for password
$PlainPassword = $null
$confirmed = $false

do {
    $password_Raw1 = Read-Host "Enter your password" -AsSecureString
    $password_Raw2 = Read-Host "Confirm your password" -AsSecureString

    # Convert the secure strings to plain text for comparison
    $password1 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password_Raw1))
    $password2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password_Raw2))

    if ($password1 -ne $password2) {
        Write-Host "Passwords do not match. Please try again."
    } else {
        $PlainPassword = $password1

        # Prompt the user to confirm the password
        $confirm = Read-Host "Your entered password is: $PlainPassword. Is this correct? (yes/no)"

        if ($confirm -eq "yes" -or $confirm -eq "y") {
            $confirmed = $true
        } elseif ($confirm -eq "no" -or $confirm -eq "n") {
            Write-Host "Please try entering your password again."
        } else {
            Write-Host "Invalid response. Please enter 'yes' or 'no'."
        }
    }
} while (-not $confirmed)

# Proceed with the script after the password is confirmed
Write-Host "Password confirmed. Proceed with the script."

# Set the registry keys to enable auto-login
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
Set-ItemProperty -Path $regPath -Name "AutoAdminLogon" -Value "1"
Set-ItemProperty -Path $regPath -Name "DefaultUserName" -Value $username
Set-ItemProperty -Path $regPath -Name "DefaultPassword" -Value $PlainPassword

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

# Set the time zone to Taipei
Set-TimeZone -Id "Taipei Standard Time"

# Display the current time zone to verify the change
Get-TimeZone

# Define the NTP server address
$NtpServer = "time.stdtime.gov.tw"

# Configure the NTP server
w32tm /config /manualpeerlist:$NtpServer /syncfromflags:manual /reliable:YES /update

# Restart the Windows Time service
Restart-Service w32time

# Force synchronization
w32tm /resync /force

# Display the current time configuration
w32tm /query /status

# Reboot the server to apply the changes
Restart-Computer -Force
