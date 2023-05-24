function encryptStringToFile {
    param(
        [Parameter(Mandatory=$true)]
        [string]$stringToEncrypt,
        [Parameter(Mandatory=$true)]
        [string]$keyFilePath,
        [Parameter(Mandatory=$true)]
        [string]$outputFilePath
    )

    $key = Get-Content $keyFilePath
    $encryptedString = Encrypt-String $stringToEncrypt $key
    $encryptedString | Out-File $outputFilePath
}