# Requires -RunAsAdministrator

# Configuration
$groupName = "ServerAdministrators"
$description = "Members of this group have administrative access to server resources"

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

function Add-GroupToLocalAdministrators {
    param(
        [string]$Group
    )
    
    try {
        $administratorsGroup = [ADSI]"WinNT://./Administrators,group"
        $administratorsGroup.Add("WinNT://./$Group,group")
        Write-LogMessage "Added $Group to local Administrators group" -Type "Success"
    }
    catch {
        Write-LogMessage "Failed to add $Group to local Administrators group: $_" -Type "Error"
    }
}

function Set-GroupPermissions {
    param(
        [string]$GroupName
    )
    
    # Define paths to secure
    $securedPaths = @(
        "C:\Program Files",
        "C:\Program Files (x86)",
        "C:\Windows"
    )
    
    foreach ($path in $securedPaths) {
        if (Test-Path $path) {
            try {
                $acl = Get-Acl $path
                $permission = New-Object System.Security.AccessControl.FileSystemAccessRule(
                    $GroupName,
                    "Modify",
                    "ContainerInherit,ObjectInherit",
                    "None",
                    "Allow"
                )
                $acl.AddAccessRule($permission)
                Set-Acl -Path $path -AclObject $acl
                Write-LogMessage "Set permissions for $GroupName on $path" -Type "Success"
            }
            catch {
                Write-LogMessage "Failed to set permissions on `$path`: $($Error[0].Message)" -Type "Error"
            }
        }
    }
}

# Main script
Write-LogMessage "Starting admin group setup..." -Type "Info"

# Check if running in domain or workgroup
$isInDomain = Test-IsInDomain

try {
    if ($isInDomain) {
        # Domain environment
        Import-Module ActiveDirectory -ErrorAction Stop
        
        # Check if group already exists
        if (Get-ADGroup -Filter {Name -eq $groupName} -ErrorAction SilentlyContinue) {
            Write-LogMessage "Group '$groupName' already exists" -Type "Warning"
        }
        else {
            # Create domain group
            New-ADGroup -Name $groupName `
                -GroupScope Global `
                -GroupCategory Security `
                -Description $description
            
            Write-LogMessage "Created domain group '$groupName'" -Type "Success"
            
            # Add to local administrators
            Add-GroupToLocalAdministrators $groupName
        }
    }
    else {
        # Workgroup environment
        $group = [ADSI]"WinNT://./Administrators,group"
        if ([ADSI]::Exists("WinNT://.\$groupName,group")) {
            Write-LogMessage "Group '$groupName' already exists" -Type "Warning"
        }
        else {
            # Create local group
            $computer = [ADSI]"WinNT://$env:COMPUTERNAME"
            $newGroup = $computer.Create("Group", $groupName)
            $newGroup.SetInfo()
            $newGroup.Description = $description
            $newGroup.SetInfo()
            
            Write-LogMessage "Created local group '$groupName'" -Type "Success"
            
            # Add to local administrators
            Add-GroupToLocalAdministrators $groupName
        }
    }
    
    # Set file system permissions
    Set-GroupPermissions $groupName
    
    Write-LogMessage "Admin group setup completed successfully" -Type "Success"
}
catch {
    Write-LogMessage "An error occurred: $($Error[0].Message)" -Type "Error"
    exit 1
}
