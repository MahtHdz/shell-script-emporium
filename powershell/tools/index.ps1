$CURRENT_PATH = Split-Path -Parent $MyInvocation.MyCommand.Definition
. "$CURRENT_PATH\decryption\decryptString.ps1"
. "$CURRENT_PATH\encryption\encryptString.ps1"