function decryptString {
    param(
        [Parameter(Mandatory=$true)]
        [string]$encryptedString
    )
    $encryptedBytes = [Convert]::FromBase64String($encryptedString)
    $decryptedBytes = [System.Security.Cryptography.ProtectedData]::Unprotect($encryptedBytes, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser)
    $decryptedString = [System.Text.Encoding]::UTF8.GetString($decryptedBytes)

    return $decryptedString
}
