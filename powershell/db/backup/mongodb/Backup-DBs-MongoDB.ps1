function Read-HostWithValidation {
  param (
    [string]$Prompt,
    [string]$ErrorMessage
  )

  do {
    $internalInput = Read-Host -Prompt $Prompt
    if (-not $internalInput) {
      Write-HostColored "#red#$ErrorMessage#"
    }
    else {
      return $internalInput
    }
  } while ($true)
}

function Convert-PathToUnix {
  param (
    [Parameter(Mandatory = $true)]
    [string]$Path
  )
  # replace backslashes with slashes, colons with nothing,
  # convert to lower case and trim last /
  $nixPath = (($Path -replace "\\", "/") -replace ":", "").ToLower().Trim("/")
  # remove the drive letter
  $nixPath = $nixPath.Substring(1)
  return $nixPath
}



function Backup-DBs-MongoDB {
  param (
    [string]$dbHost,
    [string]$target
  )
  if ($dbHost -eq "container") {
    $containerId = Read-HostWithValidation -Prompt "Enter the container identifier [Name/Hash_ID]" -ErrorMessage "Container ID is required."
  }
  if($target -eq "single") {
    $dbName = Read-HostWithValidation -Prompt "Enter the db name" -ErrorMessage "DB name is required."
  }
  $dbURI = Read-HostWithValidation -Prompt "Enter the db uri" -ErrorMessage "DB URI is required."
  $backupPath = Read-HostWithValidation -Prompt "Enter the backup path" -ErrorMessage "Backup path is required."
  $currentDate = Get-Date -Format 'dd-MM-yyyy'

  # Validate if backupPath is a valid directory
  if (Test-Path -Path $backupPath -PathType Container) {
    $backupDir = Join-Path -Path $backupPath -ChildPath "backup-mongodb-$currentDate"
    New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
    $backupDir = Convert-PathToUnix -Path $backupDir
  }
  else {
    Write-HostColored "#red#Invalid backup path. Using default.#"
    $backupDir = "backup-mongodb-$currentDate"
  }
  if ($target -eq "single") {
    if ($dbHost -eq "localhost") {
      Write-Host "Starting operations at $(Get-Date). Creating backup for $dbName..." -ForegroundColor DarkYellow
      & mongodump --uri=$dbURI --db $dbName --gzip --out $backupDir | Tee-Object -Variable dumpOutput
    }
    else {
      Write-Host "Starting operations at $(Get-Date). Creating backup for $dbName at $containerId..." -ForegroundColor DarkYellow
      & docker exec -i $containerId mongodump --uri=$dbURI --db $dbName --gzip --out $backupDir | Tee-Object -Variable dumpOutput
    }
  } else {
    if ($dbHost -eq "localhost") {
      Write-Host "Starting operations at $(Get-Date). Creating backup for all databases..." -ForegroundColor DarkYellow
      & mongodump --uri=$dbURI --gzip --out "$backupDir" | Tee-Object -Variable dumpOutput
    }
    else {
      Write-Host "$backupDir" -ForegroundColor Red
      Write-Host "Starting operations at $(Get-Date). Creating backup for all databases at $containerId..." -ForegroundColor DarkYellow
      & docker exec -i $containerId mongodump --uri=$dbURI --gzip --out "$backupDir" | Tee-Object -Variable dumpOutput
    }
  }

  Write-Host "Backup created successfully!" -ForegroundColor Green
}
