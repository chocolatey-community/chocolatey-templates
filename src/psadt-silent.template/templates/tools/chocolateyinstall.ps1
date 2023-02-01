$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$zipArchive = Join-Path $toolsDir -ChildPath '[[Zip]]'
$destination = (Join-Path $toolsDir -ChildPath $env:ChocolateyPackageName)

Get-ChocolateyUnzip -FileFullPath $zipArchive -Destination $destination

$adtFolder = 'AppDeployToolkit'
$modulePath = Join-Path $destination -ChildPath "$adtFolder"
$module = Join-Path $modulePath -ChildPath 'AppDeployToolkitMain.ps1'
. $module
$adtExe = Join-Path $destination -ChildPath "Deploy-Application.exe"
$deployScript = Join-Path $destination -ChildPath 'Deploy-Application.ps1'

try {
    $packageArgs = @{
        packagename = $env:ChocolateyPackageName
        filetype = 'exe'
        file = $adtExe
        silentArgs = "-DeploymentType 'Install' -DeployMode 'Silent'"
        validExitCodes = @(0)
        softwareName = '[[Software]]*'
    }

    Install-ChocolateyInstallPackage @packageArgs
} catch {
    $packageArgs = @{
        ExetoRun = $adtExe
        statements = "-DeploymentType 'Install' -DeployMode 'Silent'"
    }

    Start-ChocolateyProcessAsAdmin @packageArgs
} finally {
    $packageArgs = @{
        statements = "& { & '$deployScript' -DeploymentType 'Install'}"
    }

    Start-ChocolateyProcessAsAdmin @packageArgs
}

<#
try {
    $packageArgs = @{
        ExetoRun = $adtExe
        statements = "-DeploymentType 'Install' -DeployMode 'Silent'"
    }

    Start-ChocolateyProcessAsAdmin @packageArgs
}

catch {
    $packageArgs = @{
    
        statements = "& { & '$deployScript' -DeploymentType 'Install'}"
    }

    Start-ChocolateyProcessAsAdmin @packageArgs
}
#>

#Cleanup
Remove-Item $zipArchive

#Prevent shims
if(-not (Test-Path "$destination\*.ignore")){
    Get-ChildItem $toolsDir -Recurse -Filter '*.exe' | Foreach-Object { $null = New-Item "$destination\$($_.Name).ignore" -ItemType File }
}