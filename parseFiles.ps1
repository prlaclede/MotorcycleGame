# ================================
# CONFIG
# ================================
$InputDirectory = ".\"
$OutputJson     = ".\audio-metadata.json"

# ================================
# SCRIPT
# ================================
$Shell = New-Object -ComObject Shell.Application
$Results = @()

# Only WAV files, NO recursion (root only)
$Files = Get-ChildItem -Path $InputDirectory -File |
    Where-Object {
        $_.Extension -eq ".wav"
    }

foreach ($File in $Files) {
    $Folder = $Shell.Namespace($File.DirectoryName)
    $Item = $Folder.ParseName($File.Name)

    $Metadata = [ordered]@{
        FileName  = $File.Name
        FullPath  = $File.FullName
        Extension = $File.Extension
        SizeBytes = $File.Length
        Created   = $File.CreationTime
        Modified  = $File.LastWriteTime
        Metadata  = [ordered]@{}
    }

    for ($i = 0; $i -lt 400; $i++) {
        $PropertyName = $Folder.GetDetailsOf($null, $i)
        $Value        = $Folder.GetDetailsOf($Item, $i)

        if (![string]::IsNullOrWhiteSpace($PropertyName) -and
            ![string]::IsNullOrWhiteSpace($Value)) {
            $Metadata.Metadata[$PropertyName] = $Value
        }
    }

    $Results += [pscustomobject]$Metadata
}

# Write JSON
$Results |
    ConvertTo-Json -Depth 10 |
    Out-File -FilePath $OutputJson -Encoding UTF8

Write-Host "Exported metadata for $($Results.Count) WAV files (root only) to $OutputJson"