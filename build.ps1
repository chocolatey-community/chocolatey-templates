[CmdletBinding(DefaultParameterSetName = 'testing')]
param(
    [Parameter(ParameterSetName = 'building')]
    [string[]]$Names,
    [switch]$Build,
    [switch]$Install,
    
    [Parameter(ParameterSetName = 'testing')]
    [switch]$Test
)

$outputDirectory = "$PSScriptRoot\_output"
$packagesDirectory = "$outputDirectory\packages"

if (!(Test-Path $outputDirectory)) {
    $null = New-Item $outputDirectory -ItemType Directory
}

if (!(Test-Path $packagesDirectory)) {
    $null = New-Item $packagesDirectory -ItemType Directory
}

if ($null -ne $Names) {
    $Names = $Names | ForEach-Object { if (!$_.EndsWith('.template')) { "$_.template" } else { $_ } }
}

function Build-AllTemplates {
    $null = Remove-Item "$packagesDirectory\*.nupkg"
    $nuspecs = Get-ChildItem "$PSScriptRoot\src" -Filter '*.nuspec' -Recurse | Where-Object {
        $null -eq $Names -or $_.BaseName -in $Names
    }

    $nuspecs | ForEach-Object {
        "Building template $($_.BaseName)"
        Start-Process 'choco' -ArgumentList 'pack', $_.FullName, '--out', "$packagesDirectory" -Wait -NoNewWindow
    }
}

function Install-PackageTemplates {
    $names = (Get-ChildItem "$PSScriptRoot\src" -Filter '*.nuspec' -Recurse | Where-Object {
        $null -eq $Names -or $_.BaseName -in $Names
    } | ForEach-Object BaseName) -join " "

    Start-Process 'choco' -ArgumentList 'install', $names, '-y', '--source', "$packagesDirectory" -Wait -NoNewWindow
}

function Invoke-PesterTests {
    $null = Remove-Item "$outputDirectory\tests" -Recurse -ErrorAction Ignore

    Invoke-Pester -Path "$PSScriptRoot\test" -Output Detailed
}

if (!$Build -and !$Install -and !$Test) {
    $Build = $Install = $true
    if ($null -eq $Names) {
        $Test = $true
    }
}

if ($Build) {
    Build-AllTemplates
}

if ($Install) {
    Install-PackageTemplates
}

if ($Test) {
    Invoke-PesterTests
}