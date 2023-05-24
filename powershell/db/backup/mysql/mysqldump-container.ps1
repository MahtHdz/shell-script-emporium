$SQL = "SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN ('mysql','information_schema','performance_schema','sys');"

function validateOption {
  Param (
    [Parameter(Mandatory = $true)]
    [string]$inputOption,
    [Parameter(Mandatory = $true)]
    [string[]]$validOptions
  )
  Process {
    if ($inputOption -in $validOptions) {
      return $true
    }
    else {
      Write-HostColored "#red#Invalid option selected.#"
      Start-Sleep -Seconds 1
      return $false
    }
  }
}

function promptUserInput {
  Param (
    [Parameter(Mandatory = $true)]
    [string]$promptText,
    [Parameter(Mandatory = $false)]
    [bool]$maskedInput = $false
  )
  Process {
    do {
      if ($maskedInput) {
        $promptInput = Read-Host -MaskInput -Prompt $promptText
      }
      else {
        $promptInput = Read-Host -Prompt $promptText
      }
      if (-not($promptInput)) {
        Write-HostColored "#red#Input is required.#"
      }
      else {
        break
      }
    } while ($true)
    return $promptInput
  }
}

$containerName = promptUserInput "Enter the container name"

$yesNoOptions = 'Y', 'y', 'N', 'n'
$hasLoginPath = validateOption (promptUserInput "MySQL have the login-path config? [Y/n]") $yesNoOptions

if ($hasLoginPath) {
  $mysqlLoginPath = promptUserInput "Enter the username of the login-path"
}
else {
  $mysqlUsername = promptUserInput "Enter username"
  $mysqlPassword = promptUserInput "Enter password" $true
}

$backupPath = promptUserInput "Enter the path where the backup will be stored"
$useRegexFilter = validateOption (promptUserInput "Use a regex expression to filter the backup? [Y/n]") $yesNoOptions

if ($useRegexFilter) {
  $regexFilter = promptUserInput "Enter the regex expression to filter the backup"
}

Write-Host " Starting operations at $(Get-Date). Creating a backup of all databases..."  -ForegroundColor DarkYellow

switch ($hasLoginPath) {
  $true {
    $rawOutput = docker exec -it $containerName mysql --login-path=$mysqlLoginPath -s -r --disable-column-names -e "$SQL" | Out-String
  }
  $false {
    $rawOutput = docker exec -it $containerName mysql -u"$mysqlUsername" -p"$mysqlPassword" -s -r --disable-column-names -e "$SQL" | Out-String
  }
}

switch ($useRegexFilter) {
  $true {
    $dbList = $rawOutput | Select-String -Pattern $regexFilter -AllMatches | ForEach-Object { $_.Matches.Value }
  }
  $false {
    $dbList = $rawOutput -split '\r?\n'
    $dbList = $dbList.Where({ "" -ne $_ })
  }
}

foreach ($db in $dbList) {
  Write-Host "Backing up $db..." -ForegroundColor DarkYellow
  switch ($hasLoginPath) {
    $true {
      docker exec -it $containerName mysqldump --login-path=$mysqlLoginPath $db > $backupPath\$db.sql
    }
    $false {
      docker exec -it $containerName mysqldump -u"$mysqlUsername" -p"$mysqlPassword" "$db" > $backupPath\$db.sql
    }
  }
  Write-Host "Done." -ForegroundColor White
}

#Set-Location $backupPath
Write-Host "Compressing all databases in a tar gzip file..."  -ForegroundColor Blue
$currentDate = Get-Date -Format 'dd-MM-yyyy'
tar -cvzf $backupPath/"dataStageBackup_$currentDate.tgz" --directory=$backupPath *.sql
foreach ($db in $dbList) {
  Remove-Item $backupPath/"$db.sql"
}
Write-Host "Backup completed!"  -ForegroundColor Green
