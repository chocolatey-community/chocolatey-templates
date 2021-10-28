$ErrorActionPreference = 'Stop';

[[AutomaticPackageNotesInstaller]]
$packageName= '[[PackageName]]'
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
#$fileLocation = Join-Path $toolsDir 'NAME_OF_EMBEDDED_ZIP_FILE'

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $toolsDir
  url           = '[[Url]]' # download url, HTTPS preferred
  url64bit      = '[[Url64]]' # 64bit URL here (HTTPS preferred) or remove - if installer contains both (very rare), use $url
  #file         = $fileLocation
  #fileFullPath = $fileLocation
  destination   = $toolsDir

  checksum      = '[[Checksum]]'
  checksumType  = 'sha256' #default is md5, can also be sha1, sha256 or sha512
  checksum64    = '[[Checksum64]]'
  checksumType64= 'sha256'
}

# https://docs.chocolatey.org/en-us/create/functions/install-chocolateyzippackage
Install-ChocolateyZipPackage @packageArgs

## Unzips a file to the specified location - auto overwrites existing content
## - https://docs.chocolatey.org/en-us/create/functions/get-chocolateyunzip
#Get-ChocolateyUnzip @packageArgs