function encryptString {
    param(
        [Parameter(Mandatory=$true)]
        [string]$stringToEncrypt
    )

    $bytesToEncrypt = [System.Text.Encoding]::UTF8.GetBytes($stringToEncrypt)
    $encryptedBytes = [System.Security.Cryptography.ProtectedData]::Protect($bytesToEncrypt, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser)
    $encryptedString = [Convert]::ToBase64String($encryptedBytes)

    return $encryptedString
}