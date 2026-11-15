<#
.SYNOPSIS
    Creates and manages a Hyper-V test VM for PalexusOS live ISO and install testing.

.DESCRIPTION
    Windows counterpart to build/test-iso-boot.sh. Needs an elevated PowerShell (or a
    member of "Hyper-V Administrators"); the script asks for elevation itself.

    Actions:
      Create    New Gen 2 VM (UEFI, Secure Boot off), empty disk, ISO in the DVD drive,
                DVD first in the boot order, and a "clean" checkpoint to roll back to.
      Start     Start the VM and open its console window.
      BootDisk  After an install: put the hard disk first and eject the ISO.
      BootIso   Put the ISO back first (to retest the live session or reinstall).
      Reset     Roll back to the "clean" checkpoint (empty disk, ISO first).
      Remove    Stop and delete the VM and its disk. Asks first unless -Force.
      Status    Show the VM's state, boot order and checkpoints.

.EXAMPLE
    .\build\hyperv-vm.ps1 -Action Create -IsoPath C:\Users\me\VMs\palexusos.iso
    .\build\hyperv-vm.ps1 -Action Start
    .\build\hyperv-vm.ps1 -Action BootDisk
#>
[CmdletBinding()]
param(
    [ValidateSet('Create', 'Start', 'BootDisk', 'BootIso', 'Reset', 'Remove', 'Status')]
    [string]$Action = 'Status',
    [string]$Name = 'PalexusOS-Test',
    [string]$IsoPath,
    [string]$VmRoot = (Join-Path $env:USERPROFILE 'VMs'),
    [ValidateRange(2, 64)][int]$MemoryGB = 4,
    [ValidateRange(1, 64)][int]$Cpus = 4,
    [ValidateRange(20, 2048)][int]$DiskGB = 40,
    [string]$SwitchName = 'Default Switch',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

function Test-HyperVAccess {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    if ($p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { return $true }
    # S-1-5-32-578 is the built-in "Hyper-V Administrators" group.
    return [bool]($id.Groups | Where-Object { $_.Value -eq 'S-1-5-32-578' })
}

if (-not (Test-HyperVAccess)) {
    Write-Host 'Hyper-V needs admin rights. Asking Windows for elevation...'
    $argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-NoExit', '-File', "`"$PSCommandPath`"")
    foreach ($kv in $PSBoundParameters.GetEnumerator()) {
        if ($kv.Value -is [switch]) {
            if ($kv.Value.IsPresent) { $argList += "-$($kv.Key)" }
        } else {
            $argList += "-$($kv.Key)"
            $argList += "`"$($kv.Value)`""
        }
    }
    Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList $argList
    exit 0
}

if (-not (Get-Command Get-VM -ErrorAction SilentlyContinue)) {
    throw 'The Hyper-V PowerShell module is not installed. Turn on "Hyper-V" in Windows Features.'
}

function Get-TestVM {
    $vm = Get-VM -Name $Name -ErrorAction SilentlyContinue
    if (-not $vm) { throw "No VM named '$Name'. Run with -Action Create first." }
    return $vm
}

function Set-BootFirst([Microsoft.HyperV.PowerShell.VirtualMachine]$vm, [string]$what) {
    $fw = Get-VMFirmware -VM $vm
    $dvd = $fw.BootOrder | Where-Object { $_.BootType -eq 'Drive' -and $_.Device -is [Microsoft.HyperV.PowerShell.DvdDrive] }
    $hdd = $fw.BootOrder | Where-Object { $_.BootType -eq 'Drive' -and $_.Device -is [Microsoft.HyperV.PowerShell.HardDiskDrive] }
    # Installed systems register their own UEFI entries (BootType 'File'); keep them right after the disk.
    $files = $fw.BootOrder | Where-Object { $_.BootType -eq 'File' }
    $rest = $fw.BootOrder | Where-Object { $_ -notin @($dvd) + @($hdd) + @($files) }
    if ($what -eq 'Dvd') { $order = @($dvd) + @($hdd) + @($files) + @($rest) }
    else { $order = @($files) + @($hdd) + @($dvd) + @($rest) }
    Set-VMFirmware -VM $vm -BootOrder ($order | Where-Object { $_ })
}

function Show-Status {
    $vm = Get-TestVM
    $vm | Format-List Name, State, CPUUsage, MemoryStartup, ProcessorCount, Uptime
    Write-Host 'Boot order:'
    (Get-VMFirmware -VM $vm).BootOrder | ForEach-Object {
        $label = if ($_.Device) { $_.Device.Path } else { $_.Description }
        Write-Host ("  {0,-6} {1}" -f $_.BootType, $label)
    }
    Write-Host 'Checkpoints:'
    Get-VMSnapshot -VM $vm | ForEach-Object { Write-Host "  $($_.Name)  ($($_.CreationTime))" }
}

switch ($Action) {
    'Create' {
        if (-not $IsoPath) { throw 'Create needs -IsoPath <path to the PalexusOS .iso>.' }
        $IsoPath = (Resolve-Path $IsoPath).Path
        if (Get-VM -Name $Name -ErrorAction SilentlyContinue) {
            throw "A VM named '$Name' already exists. Use -Action Reset, or -Action Remove first."
        }
        if (-not (Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue)) {
            throw "No virtual switch named '$SwitchName'. Pass -SwitchName with one from Get-VMSwitch."
        }
        $vmDir = Join-Path $VmRoot $Name
        $vhd = Join-Path $vmDir "$Name.vhdx"
        New-Item -ItemType Directory -Force -Path $vmDir | Out-Null

        Write-Host "Creating $Name ($Cpus CPUs, $MemoryGB GB RAM, $DiskGB GB disk)..."
        $vm = New-VM -Name $Name -Generation 2 -Path $VmRoot `
            -MemoryStartupBytes ([int64]$MemoryGB * 1GB) `
            -NewVHDPath $vhd -NewVHDSizeBytes ([int64]$DiskGB * 1GB) -SwitchName $SwitchName
        # Static memory: Linux guests boot and install more reliably without ballooning.
        Set-VMMemory -VM $vm -DynamicMemoryEnabled $false
        Set-VMProcessor -VM $vm -Count $Cpus
        # PalexusOS's own bootloader is not signed for the Microsoft CA.
        Set-VMFirmware -VM $vm -EnableSecureBoot Off
        Set-VM -VM $vm -AutomaticCheckpointsEnabled $false -CheckpointType Standard
        Enable-VMIntegrationService -VM $vm -Name 'Guest Service Interface' -ErrorAction SilentlyContinue
        Add-VMDvdDrive -VM $vm -Path $IsoPath
        Set-BootFirst $vm 'Dvd'
        Checkpoint-VM -VM $vm -SnapshotName 'clean'
        Write-Host "Created. Disk: $vhd"
        Write-Host "Next: .\build\hyperv-vm.ps1 -Action Start"
        Show-Status
    }
    'Start' {
        $vm = Get-TestVM
        if ($vm.State -ne 'Running') { Start-VM -VM $vm }
        Start-Process -FilePath 'vmconnect.exe' -ArgumentList 'localhost', "`"$Name`""
    }
    'BootDisk' {
        $vm = Get-TestVM
        if ($vm.State -ne 'Off') { Stop-VM -VM $vm -Force }
        Set-BootFirst $vm 'Disk'
        Get-VMDvdDrive -VM $vm | Set-VMDvdDrive -Path $null
        Write-Host 'ISO ejected; the installed system boots first.'
        Show-Status
    }
    'BootIso' {
        $vm = Get-TestVM
        if (-not $IsoPath) { throw 'BootIso needs -IsoPath <path to the PalexusOS .iso>.' }
        if ($vm.State -ne 'Off') { Stop-VM -VM $vm -Force }
        Get-VMDvdDrive -VM $vm | Set-VMDvdDrive -Path (Resolve-Path $IsoPath).Path
        Set-BootFirst $vm 'Dvd'
        Show-Status
    }
    'Reset' {
        $vm = Get-TestVM
        $snap = Get-VMSnapshot -VM $vm -Name 'clean' -ErrorAction SilentlyContinue
        if (-not $snap) { throw "No 'clean' checkpoint on $Name." }
        if ($vm.State -ne 'Off') { Stop-VM -VM $vm -TurnOff -Force }
        Restore-VMSnapshot -VMSnapshot $snap -Confirm:$false
        Write-Host "Rolled $Name back to its clean state."
    }
    'Remove' {
        $vm = Get-TestVM
        $vmDir = Join-Path $VmRoot $Name
        if (-not $Force) {
            $answer = Read-Host "Delete VM '$Name' and everything in $vmDir? Type yes"
            if ($answer -ne 'yes') { Write-Host 'Cancelled.'; return }
        }
        if ($vm.State -ne 'Off') { Stop-VM -VM $vm -TurnOff -Force }
        Get-VMSnapshot -VM $vm | Remove-VMSnapshot -Confirm:$false
        Remove-VM -VM $vm -Force
        if (Test-Path $vmDir) { Remove-Item -Recurse -Force $vmDir }
        Write-Host "Removed $Name."
    }
    'Status' { Show-Status }
}
