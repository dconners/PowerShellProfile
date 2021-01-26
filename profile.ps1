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

if ($Install)
{
    if (Test-Administrator)
    {
        Write-Warning "In elevated prompt, not installing"
        return
    }
    try
    {
        Copy-Item -Path $MyInvocation.MyCommand.Path -Destination $profile
    }
    catch
    {
        Write-Error "Error installing profile`n$_"
    }
}