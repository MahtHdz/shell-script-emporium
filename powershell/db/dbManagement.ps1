$CURRENT_PATH = Split-Path -Parent $MyInvocation.MyCommand.Definition
<# . "$CURRENT_PATH\db_restore\mysql\restoreDBsFromTarGzFileToContainer.ps1"
. "$CURRENT_PATH\db-backups\mysql\backupAllDBsToTarGzFileFromContainer.ps1" #>
$SCRIPT_NAME_ACSII = Get-Content "$CURRENT_PATH\..\..\banners\db\banner_p1.txt" -Raw
$SCRIPT_LOGO = Get-Content "$CURRENT_PATH\..\..\banners\db\banner_p2.txt" -Raw

<#
.SYNOPSIS
Display a default banner in the console.
#>
function DisplayBanner {
  Process {
    Write-HostColored "#red#$SCRIPT_NAME_ACSII#"
    Write-Host $SCRIPT_LOGO -ForegroundColor White
  }
}

function validateOption {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true)]
    [Int32]$option,
    [Parameter(Mandatory = $true)]
    [Int32[]]$validOptions
  )
  Process {
    if ($option -in $validOptions) {
      return $true
    } else {
      if (-not($option)) {
        Write-HostColored "#red#No option selected. Select an option.#"
        Start-Sleep -Seconds 1
      } else {
        Write-HostColored "#red#Invalid option selected.#"
        Start-Sleep -Seconds 1
      }
    }
  }
}

function DiplayMenu {
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory = $true)]
    [Int32]$dbProvider,
    [Parameter(Mandatory = $true)]
    [Int32]$selectedHost
  )
  Process {
    $operationValidOptions = 1..5
    Write-Host $dbProvider
    $hostStringSpace = "          "
    $compressedFileType = ""
    if ($dbProvider -eq 1) {
      $compressedFileType = "bson gz"
    }
    elseif ($dbProvider -eq 2) {
      $compressedFileType += "tar gz"
    }

    if($selectedHost -eq 1) {
      $hostStringSpace = "localhost"
    }elseif ($selectedHost -eq 2){
      $hostStringSpace = "container"
    }


    $menu = "`n *************************** Menu ***************************"
    $menu += "`n * 1. Restore databases from $compressedFileType file to $hostStringSpace.     *"
    $menu += "`n * 2. Restore a single database to $hostStringSpace.               *"
    $menu += "`n * 3. Backup all databases from $hostStringSpace.                  *"
    $menu += "`n * 4. Backup a single database from $hostStringSpace.              *"
    $menu += "`n * 5. Exit.                                                 *"
    $menu += "`n ************************************************************"
    do {
      Clear-Host
      DisplayBanner
      Write-Host $menu
      $option = Read-Host -Prompt "Select an option"
      $breakFlag = validateOption $option $operationValidOptions
      if ($breakFlag) {
        break
      }
    } while ($true)
    return $option
  }
}

function Main {
  Process {
    $hosts = 1..2
    $dbProviders = 1..2
    $breakFlag = $false
    do {
      Clear-Host
      DisplayBanner
      Write-Host "`n Select a database provider:"
      Write-Host " 1. MongoDB"
      Write-Host " 2. MySQL"
      $dbProvider = Read-Host -Prompt "Select an option"
      try {
        $breakFlag = validateOption $dbProvider $dbProviders
      } catch {
        Write-HostColored "#red#Invalid option selected.#"
        Start-Sleep -Seconds 1
      }
      if ($breakFlag) {
        $breakFlag = $false
        break
      }
    } while ($true)
    do {
      Clear-Host
      DisplayBanner
      Write-Host "`n Select a host:"
      Write-Host " 1. localhost"
      Write-Host " 2. container"
      $dbHost = Read-Host -Prompt "Select an option"
      try {
        $breakFlag = validateOption $dbHost $hosts
      } catch {
        Write-HostColored "#red#Invalid option selected.#"
        Start-Sleep -Seconds 1
      }
      if ($breakFlag) {
        break
      }
    } while ($true)
    $operationNum = DiplayMenu $dbProvider $dbHost
    switch ($operationNum) {
      1 { restoreDBsFromTarGzFileToContainer ; Break }
      2 { Write-Host "You selected option 2" ; Break }
      3 { backupAllDBsToTarGzFileFromContainer ; Break }
      4 { Write-Host "You selected option 4" ; Break }
      5 { Write-Host "Bye! :)" ; exit 0 }
      default { Write-HostColored "#red#Mmm... this doesn't looks right. 🤨 " ; Start-Sleep -Seconds 2 }
    }
  }
}

Main
