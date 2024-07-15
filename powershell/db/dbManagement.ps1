$parentPath = Split-Path -Path $PSScriptRoot -Parent
$scriptsPath = Split-Path -Path $parentPath -Parent

$mongoBackupScriprPath = $PSScriptRoot + "\backup\mongodb\Backup-DBs-MongoDB.ps1"
$mongoRestoreScriprPath = $PSScriptRoot + "\restore\mongodb\Restore-DBs-MongoDB.ps1"
$mysqlBackupScriprPath = $PSScriptRoot + "\backup\mysql\Backup-DBs-MySQL.ps1"
$mysqlRestoreScriprPath = $PSScriptRoot + "\restore\mysql\Restore-DBs-MySQL.ps1"

# $rootPath = $env:ROOT_PATH
$SCRIPT_NAME_ACSII = Get-Content "$scriptsPath\banners\db\banner_p1.txt" -Raw
$SCRIPT_LOGO = Get-Content "$scriptsPath\banners\db\banner_p2.txt" -Raw

function Show-Banner {
  Process {
    Write-HostColored "#red#$SCRIPT_NAME_ACSII#"
    Write-Host $SCRIPT_LOGO -ForegroundColor White
  }
}

function Confirm-Option {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true)]
    [string]$option, # Accepting string input
    [Parameter(Mandatory = $true)]
    [Int32[]]$validOptions
  )
  Process {
    $optionAsInt = 0
    if ([int32]::TryParse($option, [ref]$optionAsInt) -and $optionAsInt -in $validOptions) {
      return $true
    }
    else {
      Write-HostColored "#red#Invalid option selected.#"
      Start-Sleep -Seconds 1
      return $false  # Explicitly returning false
    }
  }
}

function Read-Selection {
  param (
    [string]$promptMessage,
    [hashtable]$options,
    [int[]]$validOptions
  )

  do {
    Clear-Host
    Show-Banner
    Write-Output $promptMessage | Out-Null
    # [Console]::Out.Flush()
    $sorted = $options.GetEnumerator() | Sort-Object -Property Name
    foreach ($pair in $sorted) {
      Write-Host "[$($pair.Key)] $($pair.Value)`n" -NoNewline
    }
    $selection = Read-Host -Prompt "Select an option"
    $breakFlag = Confirm-Option $selection $validOptions
    if ($breakFlag) {
      return [int]$selection
    }else {
      Clear-Variable -Name selection
    }
  } while ($true)
}

function Main {
  Process {
    $targetOptions = @{ 1 = "all"; 2 = "single" }
    $dbProviders = @{ 1 = "MongoDB"; 2 = "MySQL" }
    $dbOperations = @{ 1 = "backup"; 2 = "restore" }
    $hostOptions = @{ 1 = "localhost"; 2 = "container" }

    $dbProviderValidOptions = 1..2
    $validHostOptions = 1..2
    $validDBOperationOptions = 1..2

    # Database provider selection
    $dbProvider = Read-Selection "Select a database provider:" $dbProviders $dbProviderValidOptions
    # Host selection
    $hostOption = Read-Selection "Select a host:" $hostOptions $validHostOptions
    # Database operation selection
    $operationOption = Read-Selection "Select an operation:" $dbOperations $validDBOperationOptions
    # Target selection
    $targetOption = Read-Selection "Select an option:" $targetOptions $validDBOperationOptions

    # Clear-Host
    # Write-Output "$dbProvider -- $hostOption -- $operationOption -- $targetOption"
    switch ($dbProviders[$dbProvider]) {
      'MongoDB' {
        switch ($dbOperations[$operationOption]) {
          'backup' {
            . $mongoBackupScriprPath; Backup-DBs-MongoDB $hostOptions[$hostOption] $targetOptions[$targetOption]
          }
          'restore' {
            . $mongoRestoreScriprPath; Restore-DBs-MongoDB $hostOptions[$hostOption] $targetOptions[$targetOption]
          }
          default { Write-HostColored "#red#Mmm... this doesn't looks right. 🤨 " ; Start-Sleep -Seconds 2 }
        }
      }
      'MySQL' {
        switch ($dbOperations[$operationOption]) {
          'backup' {
            . $mysqlBackupScriprPath; Backup-DBs-MySQL $hostOptions[$hostOption] $targetOptions[$targetOption]
          }
          'restore' {
            . $mysqlRestoreScriprPath; Restore-DBs-MySQL $hostOptions[$hostOption] $targetOptions[$targetOption]
          }
          default { Write-HostColored "#red#Mmm... this doesn't looks right. 🤨 " ; Start-Sleep -Seconds 2 }
        }
      }
      default { Write-HostColored "#red#Mmm... this doesn't looks right. 🤨 " ; Start-Sleep -Seconds 2 }
    }
  }
}

Main