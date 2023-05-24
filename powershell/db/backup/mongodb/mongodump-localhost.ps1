$dbName = Read-Host -Prompt "Enter the db name"
$dbURI = Read-Host -Prompt "Enter the db uri"
$backupPath = Read-Host -Prompt "Enter the backup path"
$currentDate = Get-Date -Format 'dd-MM-yyyy'
mongodump --uri=$dbURI --db $dbName --gzip --out "$backupPath\backup-mongodb-$currentDate" | Tee-Object -Variable dumpOutput
Write-Host "Backup created sucessfully!" -ForegroundColor Green
