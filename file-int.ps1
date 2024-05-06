Write-Host ""
Write-Host "Welcome to File-Integrity Monitoring"
Write-Host ""
Write-Host "A) Collect Baseline or B) Start Monitoring" 
$response = Read-Host -Prompt " Please Enter A or B"

function calculate-file-hash ($filepath) {
$filehash = Get-FileHash -Path $filepath -Algorithm SHA256
return $filehash
}

function check-if-baseline-exists (){
$fileexist = Test-Path -Path .\baseline.txt
if ($fileexist){
Remove-Item -Path .\baseline.txt
}
}

if ($response -eq "A".ToLower()) {
check-if-baseline-exists

$files = Get-ChildItem -Path .\files


foreach ($f in $files) {
$hash = calculate-file-hash $f.FullName
"$($hash.Path)|$($hash.Hash)" | Out-File .\baseline.txt -Append
    }
Write-Host "Hashes Calculated" -ForegroundColor DarkYellow

}


elseif ($response -eq "B".ToLower()) {
Write-Host "Monitoring" -ForegroundColor cyan

$filehashdic = @{}
$filepathandhash = Get-Content -Path .\baseline.txt

foreach ($f in $filepathandhash){
$filehashdic.add($f.split("|")[0], $f.split("|")[1])
}
}

while($true){
    start-sleep -Seconds 1
    $files = Get-ChildItem -Path .\files

    foreach ($f in $files) {
        $hash = calculate-file-hash $f.FullName

        #notifies if any new file has been created
        if($filehashdic[$hash.Path] -eq $null) {
        Write-Host "$($hash.path) has been created" 
        
        }

        if($filehashdic[$hash.Path] -eq $hash.Hash) {
        #filenotchanged
        }
        else{
        Write-Host "$($hash.Path) has been changed" -ForegroundColor Red
        }

    }

}
