$folder = "C:\Users\prlac\Desktop\ImageSetup"

Get-ChildItem -Path $folder -Filter *.wav | ForEach-Object {
    $input = $_.FullName
    $temp = "$input.temp.wav"

    ffmpeg -y -i "$input" -ac 1 -map_metadata -1 "$temp"

    Move-Item -Force "$temp" "$input"
}