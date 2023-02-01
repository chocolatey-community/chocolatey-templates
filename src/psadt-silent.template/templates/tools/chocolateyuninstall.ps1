$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$destination = (Join-Path $toolsDir -ChildPath $env:ChocolateyPackageName)


$adtExe = Join-Path $destination -ChildPath "Deploy-Application.exe"

$packageArgs = @{
    ExetoRun = $adtExe
    statements = "-DeploymentType 'Uninstall' -DeployMode 'Silent'"
}

Start-ChocolateyProcessAsAdmin @packageArgs