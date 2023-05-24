$dbName = Read-Host -Prompt "Enter the db name"
$dbURI = Read-Host -Prompt "Enter the db uri"
$backupPath = Read-Host -Prompt "Enter the backup db path"
& mongorestore --uri=$dbURI --gzip --db $dbName $backupPath | Tee-Object -Variable dumpOutput
Write-Host "Backup restored sucessfully!" -ForegroundColor Green
