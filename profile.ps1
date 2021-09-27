param([switch]$Install)
function prompt
{

    #Shorten the path for common locations
    $path = $pwd.Path.Replace($Home,"~")
    $path = $path.Replace("OneDrive - Ravenswood Technology Group, LLC","OneDriveRTG")

    #Use the Verbose color settings and show the working directory
    write-host -f ($host.PrivateData.VerboseForegroundColor) -b ($host.PrivateData.VerboseBackgroundColor) $path

    #Tag the prompt when in Admin mode
    if (Test-Administrator)
    {
        write-host -f ($host.PrivateData.ErrorForegroundColor) -b ($host.PrivateData.ErrorBackgroundColor) -n "[ADMIN]"
    }

    ">"

}

function Update-Self
{
    if (Test-Administrator)
    {
        Write-Warning "In elevated prompt, not updating"
        return
    }

    try
    {
        #https://raw.githubusercontent.com/dconners/PowerShellProfile/master/profile.ps1
        Invoke-WebRequest -Uri "https://git.io/dacprofile" -OutFile $profile
        Write-Host "Updated profile, please restart PowerShell"
    }
    catch
    {
        Write-Error "Error updating profile`n$_"
    }

}

function Test-Administrator
{    
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

# quick navigation function

function goto
{
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

}

function goback
{
    Pop-Location -StackName GoTo
}


#Self install if we run the script with the appropriate switch
if ($Install)
{
    if (Test-Administrator)
    {
        Write-Warning "In elevated prompt, not installing"
        return
    }
    try
    {
        if (Test-Path $profile)
        {
            Write-Warning "Profile already exists"
        }
        Copy-Item -Path $MyInvocation.MyCommand.Path -Destination $profile -Confirm
    }
    catch
    {
        Write-Error "Error installing profile`n$_"
    }
}

#Optional module imports. Import if present

#PScolors for pretty colors in get-childitem. Explicit import since otherwise will lose custom prompt function
if (Get-Module -Name PSColors -ListAvailable) {Import-Module PSColors -Function Get-ChildItem}