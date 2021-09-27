[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Folder
)

#Get the list of directories to search
$searchFolders = @($env:USERPROFILE)
#get the script path
$scriptDir = Split-Path $MyInvocation.MyCommand.Path -Parent
if (Test-Path "$scriptDir\goto.lst")
{
    Get-Content "$scriptDir\goto.lst" | ForEach-Object {$searchFolders += $_}
}

$choices = @()

foreach($searchFolder in $searchFolders)
{
    Get-ChildItem -Path $searchFolder -Directory -Recurse -Filter "$($Folder)*" -ErrorAction SilentlyContinue | ForEach-Object {$choices += $_}
}
$choices = $choices | Sort-Object FullName

if ($choices.Count -eq 0)
{
    Write-Warning "No match found for $Folder"
    return
}

if ($choices.Count -eq 1)
{
    #save the current location
    Push-Location -StackName GoTo
    Set-Location -Path $choices[0]
    return
}

if ($choices.Count -gt 9)
{
    Write-Warning "Too many options"
    return
}


#We have 2-9 options
for($i=0;$i -lt $choices.Count;$i++)
{
    Write-Host -ForegroundColor Yellow -NoNewline "$($i+1) "
    Write-Host -ForegroundColor Green "$($choices[$i])"
}

$choice = -1
while($choice -lt 0)
{
    $userInput = Read-Host -Prompt "Select Folder (return to exit)"
    if ($userInput -eq "")
    {
        $choice = 0
    }
    elseif ($userInput -notmatch "\d")
    {
        Write-Warning "Please select a number"
    }
    elseif ($userInput -gt $choices.Count)
    {
        Write-Warning "Please select a number in range"
    }
    else
    {
        $choice = $userInput
    }
}
if ($choice -gt 0)
{
    #save the current location
    Push-Location -StackName GoTo
    Set-Location $choices[$choice-1]
}
