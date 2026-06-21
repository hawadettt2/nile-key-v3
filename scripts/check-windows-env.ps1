$ErrorActionPreference = 'Stop'

function Test-Port {
    param(
        [Parameter(Mandatory)]
        [string]$ComputerName,

        [Parameter(Mandatory)]
        [int]$Port
    )

    try {
        Test-NetConnection -ComputerName $ComputerName -Port $Port -InformationLevel Quiet
    } catch {
        $false
    }
}

$wslStatus = (wsl --status 2>&1 | Out-String) -replace "`0", ''
$wslInstalled = (wsl --list --verbose 2>&1 | Out-String) -replace "`0", ''
$wslOnline = (wsl --list --online 2>&1 | Out-String) -replace "`0", ''
$mariadb3307 = Test-Port -ComputerName '127.0.0.1' -Port 3307
$mariadb3306 = Test-Port -ComputerName '127.0.0.1' -Port 3306
$redis6379 = Test-Port -ComputerName '127.0.0.1' -Port 6379

$computerInfo = Get-ComputerInfo -Property HyperVisorPresent, HyperVRequirementVirtualizationFirmwareEnabled, OsName, OsVersion -ErrorAction SilentlyContinue

$result = [ordered]@{
    timestamp_utc = (Get-Date).ToUniversalTime().ToString('o')
    os_name = $computerInfo.OsName
    os_version = $computerInfo.OsVersion
    hypervisor_present = $computerInfo.HyperVisorPresent
    virtualization_firmware_enabled = $computerInfo.HyperVRequirementVirtualizationFirmwareEnabled
    wsl_status = $wslStatus.Trim()
    wsl_installed_distributions = $wslInstalled.Trim()
    wsl_online_distributions = $wslOnline.Trim()
    mariadb_127_0_0_1_3307 = $mariadb3307
    mariadb_127_0_0_1_3306 = $mariadb3306
    redis_127_0_0_1_6379 = $redis6379
}

$result | ConvertTo-Json -Depth 4

if (-not $computerInfo.HyperVisorPresent) {
    Write-Host "`nWARNING: HyperVisorPresent is False. WSL2/Docker may not start until reboot or BIOS/UEFI virtualization is enabled." -ForegroundColor Yellow
}

if (-not $mariadb3307 -and -not $mariadb3306) {
    Write-Host "WARNING: MariaDB was not detected on 127.0.0.1:3306 or 127.0.0.1:3307." -ForegroundColor Yellow
}

if (-not $redis6379) {
    Write-Host "WARNING: Redis was not detected on 127.0.0.1:6379." -ForegroundColor Yellow
}
