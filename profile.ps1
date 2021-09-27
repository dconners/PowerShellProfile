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
        $Folder,
        [int]
        $Depth=4
    )

    $choices = Get-ChildItem -Path \ -Directory -Depth $Depth -Filter "$($folder)*" -ErrorAction SilentlyContinue | Sort-Object FullName

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