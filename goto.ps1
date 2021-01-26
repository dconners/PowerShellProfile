[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $Folder,
    [int]
    $Depth=3
)

$choices = Get-ChildItem -Path \ -Directory -Depth $Depth | ? Name -Match $Folder | Sort-Object FullName

if ($choices.Count -eq 0)
{
    Write-Warning "No match found for $Folder at depth $Depth"
    return
}

if ($choices.Count -eq 1)
{
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
    Write-Host "$($i+1) $($choices[$i])"
}

$choice = -1
while($choice -lt 0)
{
    $userInput = Read-Host -Prompt "Select Folder (0 to exit)"
    if ($userInput -notmatch "\d")
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
    Set-Location $choices[$choice-1]
}
