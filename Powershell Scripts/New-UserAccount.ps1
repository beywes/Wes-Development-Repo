# Requires -RunAsAdministrator

function Write-LogMessage {
    param(
        [string]$Message,
        [string]$Type = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Type) {
        "Info" { "White" }
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error" { "Red" }
        default { "White" }
    }
    
    Write-Host "[$timestamp] $Message" -ForegroundColor $color
}

function Test-IsInDomain {
    $computerSystem = Get-WmiObject -Class Win32_ComputerSystem
    return $computerSystem.PartOfDomain
}

function Get-GroupList {
    $isInDomain = Test-IsInDomain
    $groups = @()
    
    if ($isInDomain) {
        try {
            Import-Module ActiveDirectory -ErrorAction Stop
            $groups = Get-ADGroup -Filter * | Select-Object Name, GroupCategory, GroupScope
        }
        catch {
            Write-LogMessage "Failed to get domain groups: $_" -Type "Error"
            return $null
        }
    }
    else {
        try {
            $computer = [ADSI]"WinNT://$env:COMPUTERNAME"
            $groups = $computer.Children | Where-Object { $_.SchemaClassName -eq 'group' } | 
                     Select-Object @{Name='Name';Expression={$_.Name[0]}}, 
                                 @{Name='GroupCategory';Expression={'Security'}}, 
                                 @{Name='GroupScope';Expression={'Local'}}
        }
        catch {
            Write-LogMessage "Failed to get local groups: $_" -Type "Error"
            return $null
        }
    }
    
    return $groups
}

function Show-GroupMenu {
    $groups = Get-GroupList
    if ($null -eq $groups) {
        return $null
    }
    
    Write-Host "`nAvailable Groups:" -ForegroundColor Cyan
    Write-Host "=================" -ForegroundColor Cyan
    
    $menuGroups = @{}
    $index = 1
    
    foreach ($group in $groups) {
        Write-Host "$index. $($group.Name) ($($group.GroupCategory) - $($group.GroupScope))"
        $menuGroups[$index] = $group.Name
        $index++
    }
    
    Write-Host "`nM. Select Multiple Groups (comma-separated numbers)"
    Write-Host "Q. Cancel"
    
    return $menuGroups
}

function New-UserWithGroups {
    param(
        [string]$Username,
        [string]$FullName,
        [string]$Password,
        [string[]]$Groups
    )
    
    $isInDomain = Test-IsInDomain
    
    try {
        if ($isInDomain) {
            # Create domain user
            Import-Module ActiveDirectory -ErrorAction Stop
            
            $userParams = @{
                Name = $Username
                SamAccountName = $Username
                UserPrincipalName = "$Username@$env:USERDNSDOMAIN"
                DisplayName = $FullName
                GivenName = ($FullName -split ' ')[0]
                Surname = ($FullName -split ' ')[-1]
                AccountPassword = (ConvertTo-SecureString -String $Password -AsPlainText -Force)
                Enabled = $true
                PasswordNeverExpires = $false
                ChangePasswordAtLogon = $true
            }
            
            New-ADUser @userParams
            Write-LogMessage "Created domain user '$Username'" -Type "Success"
            
            # Add user to groups
            foreach ($group in $Groups) {
                Add-ADGroupMember -Identity $group -Members $Username
                Write-LogMessage "Added user to group '$group'" -Type "Success"
            }
        }
        else {
            # Create local user
            $computer = [ADSI]"WinNT://$env:COMPUTERNAME"
            $user = $computer.Create("User", $Username)
            $user.SetPassword($Password)
            $user.FullName = $FullName
            $user.SetInfo()
            
            # Set user properties
            $user.UserFlags = 65536 # PASSWORD_NEVER_EXPIRES
            $user.SetInfo()
            
            Write-LogMessage "Created local user '$Username'" -Type "Success"
            
            # Add user to groups
            foreach ($group in $Groups) {
                $groupObj = [ADSI]"WinNT://$env:COMPUTERNAME/$group,group"
                $groupObj.Add("WinNT://$env:COMPUTERNAME/$Username")
                Write-LogMessage "Added user to group '$group'" -Type "Success"
            }
        }
        
        return $true
    }
    catch {
        Write-LogMessage "Failed to create user: $_" -Type "Error"
        return $false
    }
}

# Main script
Clear-Host
Write-Host "User Account Creation Wizard" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

# Get user information
$username = Read-Host "`nEnter username"
$fullName = Read-Host "Enter full name"

# Get password
do {
    $password = Read-Host "Enter password" -AsSecureString
    $passwordConfirm = Read-Host "Confirm password" -AsSecureString
    
    $passwordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
    $passwordConfirmText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($passwordConfirm))
    
    if ($passwordText -ne $passwordConfirmText) {
        Write-Host "Passwords do not match. Please try again." -ForegroundColor Red
    }
} while ($passwordText -ne $passwordConfirmText)

# Show group selection menu
$menuGroups = Show-GroupMenu
if ($null -eq $menuGroups) {
    Write-LogMessage "Failed to retrieve groups. Exiting." -Type "Error"
    exit 1
}

$selectedGroups = @()
do {
    $selection = Read-Host "`nSelect groups for the user"
    
    switch ($selection.ToUpper()) {
        'Q' {
            Write-Host "Operation cancelled." -ForegroundColor Yellow
            exit 0
        }
        'M' {
            $multiSelect = Read-Host "Enter group numbers (comma-separated)"
            $numbers = $multiSelect -split ',' | ForEach-Object { $_.Trim() }
            $selectedGroups = $numbers | Where-Object { $menuGroups.ContainsKey([int]$_) } | ForEach-Object { $menuGroups[[int]$_] }
            break
        }
        default {
            if ([int]::TryParse($selection, [ref]$null) -and $menuGroups.ContainsKey([int]$selection)) {
                $selectedGroups = @($menuGroups[[int]$selection])
            }
            else {
                Write-Host "Invalid selection. Please try again." -ForegroundColor Red
                continue
            }
        }
    }
    
    if ($selectedGroups.Count -gt 0) {
        break
    }
} while ($true)

# Create user and add to groups
if (New-UserWithGroups -Username $username -FullName $fullName -Password $passwordText -Groups $selectedGroups) {
    Write-LogMessage "User account creation completed successfully" -Type "Success"
}
else {
    Write-LogMessage "Failed to create user account" -Type "Error"
    exit 1
}
