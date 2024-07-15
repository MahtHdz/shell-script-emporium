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

function Restore-DBs-MySQL {
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
  $mysqlUsername = Read-HostWithValidation -Prompt "Enter username" -ErrorMessage "Username is required."
  $mysqlPassword = Read-Host -MaskInput -Prompt "Enter password"
  if (-not $mysqlPassword) {
    Write-HostColored "#red#Password is required.#"
    return
  }
  if($target -eq "all") {
    $backupTarFilePath = Read-HostWithValidation -Prompt "Enter the file path of the gzip tar backup" -ErrorMessage "Path is required."
    $backupPath = Split-Path -Parent $backupTarFilePath
    Push-Location
    Set-Location $backupPath
    Write-Host "Starting operations at $(Get-Date). Restoring all databases from tar file..." -ForegroundColor DarkYellow
    Write-Host "Unzipping all databases from the tar gz file..." -ForegroundColor Blue
    tar -xvzf $backupTarFilePath

    $dbList = Get-ChildItem -Path . | ForEach-Object { $_.Name } | Select-String -Pattern "glosa(?:_[A-Z0-9]{12})?" -AllMatches | ForEach-Object { $_.Matches.Value }
    if($dbHost -eq "localhost") {
      foreach($db in $dbList){
        Write-Host "Restoring $db..." -ForegroundColor DarkYellow
        mysql -u"$mysqlUsername" -p"$mysqlPassword" -e "CREATE DATABASE IF NOT EXISTS $db;"
        Get-Content "$db.sql" | mysql -u"$mysqlUsername" -p"$mysqlPassword" $db
        Write-Host "Done." -ForegroundColor White
        Remove-Item "$db.sql"
      }
    } else {
      foreach ($db in $dbList) {
        Write-Host "Restoring $db... at $containerId" -ForegroundColor DarkYellow
        docker exec -i $containerId mysql -u"$mysqlUsername" -p"$mysqlPassword" -e "CREATE DATABASE IF NOT EXISTS $db;"
        Get-Content "$db.sql" | docker exec -i $containerId mysql -u"$mysqlUsername" -p"$mysqlPassword" $db
        Write-Host "Done." -ForegroundColor White
        Remove-Item "$db.sql"
      }
    }
    Pop-Location
    # Set-Location $currentLocation
    Write-Host "All databases restored!" -ForegroundColor Green
  }
  else {
    $backupPath = Read-HostWithValidation -Prompt "Enter the backup db path" -ErrorMessage "Backup path is required."
    if ($dbHost -eq "localhost") {
      Write-Host "Starting operations at $(Get-Date). Restoring $dbName..." -ForegroundColor DarkYellow
      mysql -u"$mysqlUsername" -p"$mysqlPassword" -e "CREATE DATABASE IF NOT EXISTS $dbName;"
      Get-Content "$backupPath" | mysql -u"$mysqlUsername" -p"$mysqlPassword" $dbName
    }
    else {
      Write-Host "Starting operations at $(Get-Date). Restoring $dbName at $containerId..." -ForegroundColor DarkYellow
      docker exec -i $containerId mysql -u"$mysqlUsername" -p"$mysqlPassword" -e "CREATE DATABASE IF NOT EXISTS $dbName;"
      Get-Content "$backupPath" | docker exec -i $containerId mysql -u"$mysqlUsername" -p"$mysqlPassword" $dbName
    }
    Write-Host "Backup restored successfully!" -ForegroundColor Green
  }
}
