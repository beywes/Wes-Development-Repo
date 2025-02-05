# Requires -RunAsAdministrator

function Show-Menu {
    param (
        [string]$Title = 'Windows Server Roles Installation'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host
    Write-Host "1: Active Directory Domain Services (AD DS)"
    Write-Host "2: DNS Server"
    Write-Host "3: DHCP Server"
    Write-Host "4: File and Storage Services"
    Write-Host "5: Print and Document Services"
    Write-Host "6: Web Server (IIS)"
    Write-Host "7: Remote Desktop Services"
    Write-Host "8: Windows Server Backup"
    Write-Host "9: Windows Server Update Services (WSUS)"
    Write-Host "10: Network Policy and Access Services"
    Write-Host
    Write-Host "M: Install Multiple Roles (Comma-separated numbers)"
    Write-Host "V: View Currently Installed Roles"
    Write-Host "Q: Quit"
}

# Define roles and their corresponding Windows feature names
$roles = @{
    1 = @{
        Name = "Active Directory Domain Services"
        Feature = "AD-Domain-Services"
        AdditionalFeatures = @("RSAT-AD-Tools", "RSAT-ADDS")
    }
    2 = @{
        Name = "DNS Server"
        Feature = "DNS"
        AdditionalFeatures = @("RSAT-DNS-Server")
    }
    3 = @{
        Name = "DHCP Server"
        Feature = "DHCP"
        AdditionalFeatures = @("RSAT-DHCP")
    }
    4 = @{
        Name = "File and Storage Services"
        Feature = "FileAndStorage-Services"
        AdditionalFeatures = @("Storage-Services")
    }
    5 = @{
        Name = "Print and Document Services"
        Feature = "Print-Services"
        AdditionalFeatures = @("RSAT-Print-Services")
    }
    6 = @{
        Name = "Web Server (IIS)"
        Feature = "Web-Server"
        AdditionalFeatures = @("Web-Mgmt-Tools")
    }
    7 = @{
        Name = "Remote Desktop Services"
        Feature = "Remote-Desktop-Services"
        AdditionalFeatures = @("RSAT-RDS-Tools")
    }
    8 = @{
        Name = "Windows Server Backup"
        Feature = "Windows-Server-Backup"
        AdditionalFeatures = @()
    }
    9 = @{
        Name = "Windows Server Update Services"
        Feature = "UpdateServices"
        AdditionalFeatures = @("UpdateServices-UI")
    }
    10 = @{
        Name = "Network Policy and Access Services"
        Feature = "NPAS"
        AdditionalFeatures = @("RSAT-NPAS")
    }
}

function Install-ServerRole {
    param (
        [int]$RoleNumber
    )
    
    if (-not $roles.ContainsKey($RoleNumber)) {
        Write-Host "Invalid role number: $RoleNumber" -ForegroundColor Red
        return
    }
    
    $role = $roles[$RoleNumber]
    Write-Host "Installing $($role.Name)..." -ForegroundColor Yellow
    
    try {
        # Check if role is already installed
        $installed = Get-WindowsFeature -Name $role.Feature
        if ($installed.Installed) {
            Write-Host "$($role.Name) is already installed." -ForegroundColor Green
            return
        }
        
        # Install main feature
        $result = Install-WindowsFeature -Name $role.Feature -IncludeManagementTools
        
        # Install additional features
        foreach ($feature in $role.AdditionalFeatures) {
            Write-Host "Installing additional feature: $feature" -ForegroundColor Yellow
            Install-WindowsFeature -Name $feature -ErrorAction SilentlyContinue
        }
        
        if ($result.Success) {
            Write-Host "$($role.Name) was installed successfully." -ForegroundColor Green
            
            # Special post-installation steps
            switch ($RoleNumber) {
                1 { # AD DS
                    Write-Host "Note: You need to run 'Install-ADDSForest' to promote this server to a domain controller." -ForegroundColor Yellow
                }
                9 { # WSUS
                    Write-Host "Note: You need to configure WSUS using the WSUS Configuration Wizard." -ForegroundColor Yellow
                }
            }
        }
        else {
            Write-Host "Failed to install $($role.Name)" -ForegroundColor Red
            if ($result.ExitCode) {
                Write-Host "Exit code: $($result.ExitCode)" -ForegroundColor Red
            }
        }
    }
    catch {
        Write-Host "Error installing $($role.Name): $_" -ForegroundColor Red
    }
}

function Show-InstalledRoles {
    Write-Host "`nCurrently Installed Server Roles:" -ForegroundColor Cyan
    foreach ($roleNum in $roles.Keys) {
        $role = $roles[$roleNum]
        $installed = Get-WindowsFeature -Name $role.Feature
        if ($installed.Installed) {
            Write-Host "$roleNum. $($role.Name) - " -NoNewline
            Write-Host "Installed" -ForegroundColor Green
        }
        else {
            Write-Host "$roleNum. $($role.Name) - " -NoNewline
            Write-Host "Not Installed" -ForegroundColor Gray
        }
    }
    Write-Host "`nPress any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Main script
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "This script must be run as Administrator" -ForegroundColor Red
    exit 1
}

do {
    Show-Menu
    $input = Read-Host "`nPlease make a selection"
    
    switch ($input.ToUpper()) {
        'Q' {
            return
        }
        'V' {
            Show-InstalledRoles
        }
        'M' {
            $selections = Read-Host "Enter role numbers (comma-separated)"
            $roleNumbers = $selections -split ',' | ForEach-Object { $_.Trim() }
            
            foreach ($num in $roleNumbers) {
                if ([int]::TryParse($num, [ref]$null)) {
                    Install-ServerRole ([int]$num)
                }
                else {
                    Write-Host "Invalid input: $num" -ForegroundColor Red
                }
            }
            
            Write-Host "`nPress any key to continue..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        default {
            if ([int]::TryParse($input, [ref]$null)) {
                Install-ServerRole ([int]$input)
                Write-Host "`nPress any key to continue..."
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
            else {
                Write-Host "Invalid selection. Please try again." -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        }
    }
} while ($true)
