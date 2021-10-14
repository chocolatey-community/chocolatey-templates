Describe 'VSCode Template' {
    BeforeAll {
        $workDirectory = "$PSScriptRoot\..\_output\tests\vscode.template"
        if (!(Test-Path $workDirectory)) {
            # We use -Force here so it can create multiple directories
            New-Item $workDirectory -ItemType Directory -Force
        }
        $workDirectory = Resolve-Path $workDirectory
    }

    AfterAll {
        #Remove-Item $workDirectory -Recurse
    }

    Context 'New package without any additional arguments' {
        BeforeDiscovery {
            # We don't test for commented out values
            $nuspecValues = @(
                @{ Name = 'id'; Value = 'test-extension' }
                @{ Name = 'version'; Value = '__REPLACE__' }
                @{ Name = 'packageSourceUrl'; Value = 'https://github.com/__REPLACE_YOUR_REPO__/test-extension' }
                @{ Name = 'owners'; Value = '__REPLACE_YOUR_NAME__' }
                @{ Name = 'title'; Value = 'test-extension (VSCode Extension)' }
                @{ Name = 'authors'; Value = '__REPLACE_AUTHORS_OF_SOFTWARE_COMMA_SEPARATED__' }
                @{ Name = 'projectUrl'; Value = 'https://marketplace.visualstudio.com/items?itemName=[[ExtensionId]]' }
                @{ Name = 'licenseUrl'; Value = 'https://marketplace.visualstudio.com/items/[[ExtensionId]]/license' }
                @{ Name = 'requireLicenseAcceptance'; Value = 'true' }
                @{ Name = 'tags'; Value = 'test-extension extension vscode SPACE_SEPARATED' }
                @{ Name = 'summary'; Value = '__REPLACE__' }
                @{ Name = 'description'; Value = '__REPLACE__MarkDown_Okay ' }
            )
        }

        BeforeAll {
            $identifier = 'test-extension'

            choco new $identifier --outputdirectory "$workDirectory" --template 'vscode'
        }

        It 'Sets <Name> in nuspec to <Value>' -ForEach $nuspecValues {
            "$workDirectory\$identifier\$identifier.nuspec" | Should -FileContentMatchExactly "<$Name>$([regex]::Escape($Value))</$Name>"
        }

        It 'Contains dependency on chocolatey-vscode.extension' {
            "$workDirectory\$identifier\$identifier.nuspec" | Should -FileContentMatchExactly '<dependency id="chocolatey-vscode\.extension" version="1\.0\.0" />'
        }

        It 'Includes tools folder in files element' {
            "$workDirectory\$identifier\$identifier.nuspec" | Should -FileContentMatchExactly '<file src="tools\\\*\*" target="tools" />'
        }

        It 'Creates installation script calling extension with extension id' {
            "$workDirectory\$identifier\tools\chocolateyInstall.ps1" | Should -FileContentMatchMultilineExactly @"
\`$ErrorActionPreference = 'Stop'

Install-VsCodeExtension -extensionId '\[\[ExtensionId\]\]'
"@
        }

        It 'Creates uninstallation script calling extension with extension id' {
            "$workDirectory\$identifier\tools\chocolateyUninstall.ps1" | Should -FileContentMatchMultilineExactly @"
\`$ErrorActionPreference = 'Stop'

Uninstall-VsCodeExtension -extensionId '\[\[ExtensionId\]\]'
"@
        }
    }

    Context 'New package with custom extension identifier' {
        BeforeDiscovery {
            # We don't test for commented out values
            $nuspecValues = @(
                @{ Name = 'id'; Value = 'test-extension-id' }
                @{ Name = 'title'; Value = 'test-extension-id (VSCode Extension)' }
                @{ Name = 'projectUrl'; Value = 'https://marketplace.visualstudio.com/items?itemName=gep13.chocolatey-vscode' }
                @{ Name = 'licenseUrl'; Value = 'https://marketplace.visualstudio.com/items/gep13.chocolatey-vscode/license' }
                @{ Name = 'tags'; Value = 'test-extension-id extension vscode SPACE_SEPARATED' }
            )
        }

        BeforeAll {
            $identifier = 'test-extension-id'

            choco new $identifier --outputdirectory "$workDirectory" --template 'vscode' extensionId="gep13.chocolatey-vscode"
        }

        It 'Sets <Name> in nuspec to <Value>' -ForEach $nuspecValues {
            "$workDirectory\$identifier\$identifier.nuspec" | Should -FileContentMatchExactly "<$Name>$([regex]::Escape($Value))</$Name>"
        }

        It 'Creates installation script calling extension with extension id' {
            "$workDirectory\$identifier\tools\chocolateyInstall.ps1" | Should -FileContentMatchMultilineExactly @"
\`$ErrorActionPreference = 'Stop'

Install-VsCodeExtension -extensionId 'gep13.chocolatey-vscode'
"@
        }

        It 'Creates uninstallation script calling extension with extension id' {
            "$workDirectory\$identifier\tools\chocolateyUninstall.ps1" | Should -FileContentMatchMultilineExactly @"
\`$ErrorActionPreference = 'Stop'

Uninstall-VsCodeExtension -extensionId 'gep13.chocolatey-vscode'
"@
        }

        Context 'New package with uppercase identifier' {
            BeforeDiscovery {
                $nuspecValues = @(
                    @{ Name = 'id'; Value = 'test-kebab-title-case' }
                    @{ Name = 'title'; Value = 'Test-Kebab-Title-Case (VSCode Extension)' }
                    @{ Name = 'packageSourceUrl'; Value = 'https://github.com/__REPLACE_YOUR_REPO__/test-kebab-title-case' }
                    @{ Name = 'tags'; Value = 'test-kebab-title-case extension vscode SPACE_SEPARATED' }
                )
            }
    
            BeforeAll {
                $identifier = 'Test-Kebab-Title-Case'
    
                choco new $identifier --outputdirectory "$workDirectory" --template 'vscode'
            }
    
            It 'Sets <Name> in nuspec to <Value>' -ForEach $nuspecValues {
                "$workDirectory\$identifier\$identifier.nuspec" | Should -FileContentMatchExactly "<$Name>$([regex]::Escape($Value))</$Name>"
            }
        }

        # The following are additional replacement arguments typically
        # specified by Chocolatey itself, or officially supported by
        # Chocolatey.
        Context 'New package using argument <Argument>' -ForEach @(
            @{ Argument = '--version=5.0.0'; Name = 'version'; Value = '5.0.0' }
            @{ Argument = '--maintainer=AdmiringWorm'; Name = 'owners'; Value = 'AdmiringWorm' }
            @{ Argument = 'PackageVersion=3.2.2'; Name = 'version'; Value = '3.2.2' }
            @{ Argument = 'MaintainerName="AdmiringWorm"'; Name = 'owners'; Value = 'AdmiringWorm' }
            @{ Argument = 'MaintainerRepo="chocolatey-community/chocolatey-packages"'; Name = 'packageSourceUrl'; Value = 'https://github.com/chocolatey-community/chocolatey-packages/test-packagesourceurl' }
        ) {
            BeforeAll {
                $identifier = "test-$Name"

                choco new $identifier --template 'vscode' --outputdirectory "$workDirectory" $Argument
            }

            AfterAll {
                # We remove the package directory here, so we don't get
                # conflicts.
                Remove-Item "$workDirectory\$identifier" -Recurse -Force
            }

            It 'Sets <Name> in nuspec to <Value>' {
                "$workDirectory\$identifier\$identifier.nuspec" | Should -FileContentMatchExactly "<$Name>$([regex]::Escape($Value))</$Name>"
            }
        }
    }
}