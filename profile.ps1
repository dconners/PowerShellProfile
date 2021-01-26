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

function Ask-YesNo(
                    [Parameter(Mandatory=$true)] 
                    [String]
                    $Question,
                    [Parameter(Mandatory=$false)] 
                    [String]
                    $Title,
                    [Parameter(Mandatory=$false)] 
                    [ValidateSet("Yes","No")] 
                    [String] 
                    $Default = "No")
{

    $Options = ((New-Object System.Management.Automation.Host.ChoiceDescription "&Yes"),`
                (New-Object System.Management.Automation.Host.ChoiceDescription "&No"))
    
    if ($Default -eq "Yes") {$DefaultOption = 0}
    else {$DefaultOption = 1}
    

    $result = $host.ui.PromptForChoice($Title, $Question, $Options, $DefaultOption) 

    switch ($result)
    {
        0 {return $true}
        1 {return $false}
    }
    
}

function install-self
{
    if (test-path $profile) {return}
    if (Ask-YesNo -Question "No profile found, create profile referencing this script?" -Default Yes)
    {
        Write-host -f Yellow "Installing self into profile"
        write-host -f Yellow 'execute . $profile to load into memory or open new session'
        $basicprofile = ". " + $MyInvocation.ScriptName
        $basicprofile | Set-Content -Path $profile
    }
}

# function go-to($shortcut)
# {
#     #Assuming that I have moved my 1DRVs to the same location as the Documents directory
#     $Target = (get-itemproperty ([Environment]::GetFolderPath("MyDocuments"))).Parent.FullName


#     $target = $null
#     foreach ($match in gci -Path $Target -Recurse -Directory -Include $shortcut)
#     {
#         if (-not ($match.FullName.StartsWith("$home\Favorites")))
#         {
#             if ($target) {Write-Verbose "Ambiguous Destination";return}
#             else {$target = $match}
#         }
#     }
#     if ($target)
#     {
#         cd $target
#     }
#     else
#     {
#         write-verbose "Target not found"
#     }
# }

function Test-Administrator
{    
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}


# #Aliases
# New-Alias goto Go-To

if (!(Test-Administrator))
{   
    #don't want to install when elevated
    install-self
}