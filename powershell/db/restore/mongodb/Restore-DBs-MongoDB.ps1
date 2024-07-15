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

function Restore-DBs-MongoDB {
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
  $backupPath = Read-HostWithValidation -Prompt "Enter the backup db path" -ErrorMessage "Backup path is required."

  if ($dbHost -eq "localhost") {
    if ($target -eq "all") {
      Write-Host "Starting operations at $(Get-Date). Restoring all databases..." -ForegroundColor DarkYellow
      & mongorestore --uri=$dbURI --gzip --drop $backupPath | Tee-Object -Variable dumpOutput
    }
    else {
      Write-Host "Starting operations at $(Get-Date). Restoring $dbName..." -ForegroundColor DarkYellow
      & mongorestore --uri=$dbURI --gzip --drop --db $dbName $backupPath | Tee-Object -Variable dumpOutput
    }
  }
  else {
    if ($target -eq "all") {
      Write-Host "Starting operations at $(Get-Date). Restoring all databases at $containerId..." -ForegroundColor DarkYellow
      & docker exec -i $containerId mongorestore --uri=$dbURI --gzip --drop $backupPath | Tee-Object -Variable dumpOutput
    }
    else {
      Write-Host "Starting operations at $(Get-Date). Restoring $dbName at $containerId..." -ForegroundColor DarkYellow
      & docker exec -i $containerId mongorestore --uri=$dbURI --gzip --drop --db $dbName $backupPath | Tee-Object -Variable dumpOutput
    }
  }
  Write-Host "Backup restored successfully!" -ForegroundColor Green
}
