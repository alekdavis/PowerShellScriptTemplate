#------------------------------[ HELP INFO ]-------------------------------

<#
.SYNOPSIS
A reusable code template for a PowerShell script.

.DESCRIPTION
Use this template to write PowerShell scripts.

The script has the following module dependencies:

https://powershellgallery.com/packages/ConfigFile/
https://powershellgallery.com/packages/ScriptVersion/
https://powershellgallery.com/packages/StreamLogging/

If the system on which the script runs has limited or does not have access to the Internet, download these packages manually and use the '-ModulePath' to specify location of the root module folder. (You can find a number of articles explaining how to install a PowerShell module without internet access online.)

The script is accompanied by two configuration (JSON) files: one (Skeleton.ps1.json) can be used to define script parameters, while the other (Skeleton.ps1.StreamLogging.json) specifies logging configuration.

To use the script, do the following:

1. Save it with the more meaningful name.
2. Replace all references to 'Skeleton' in the script code and comments with the new name of the script.
3. Rename the 'Skeleton.ps1.json' and 'Skeleton.ps1.StreamLogging.json' files to match the new name of the script.
4. Verify and update if needed the code marked by the 'TODO' comments.
5. Implement script initialization logic in the 'Init' function.
6. Implement the main script logic in the 'Main' function.
7. When the script is complete, update this script's 'HELP INFO' section.

.PARAMETER ModulePath
Optional path to directory holding the modules used by this script. This can be useful if the script runs on the system with no or restricted access to the Internet. By default, the module path will point to the 'Modules' folder in the script's folder.

.PARAMETER ConfigFile
Path to the optional custom config file. The default config file is named after the script with the '.json' extension, such as 'CloneLocalGroups.ps1.json'.

.PARAMETER LoggingConfigFile
Path to the optional custom config file used by the 'StreamLogging' module. By default, the stream logging config file is named after the executing script with the '.StreamLogging.json' extension. If you use a non-default config file, either specify the full path or the alternative extension (in the latter case, the path will be generated by appending the new extension to the path of the executing script).

.PARAMETER Quiet
Use this switch to suppress log entries sent to the console.

.PARAMETER NoLogo
Specify this command-line switch to not print version and copyright info.

.NOTES
Version    : 1.1.0
Author     : Alek Davis
Created on : 2021-11-19
License    : MIT License
LicenseLink: https://github.com/alekdavis/PowerShellScriptTemplate/blob/master/LICENSE
Copyright  : (c) 2021 Alek Davis

.LINK
https://github.com/alekdavis/PowerShellScriptTemplate

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
.\Skeleton.ps1
Illustrates simple script execution with default parameter.

.EXAMPLE
.\Skeleton.ps1 -LoggingConfigFile '.Log.json'
Loads the log settings from the 'Skeleton.ps1.Log.json' file instead of the default file.

.EXAMPLE
.\Skeleton.ps1 -ModulePath 'C:\MyModules;D:\MyOtherModules'
Instructs the script to look for PowerShell modules in the specified folders in addition to the folders listed in the standard $PSModulePath variable.

.EXAMPLE
Get-Help .\Skeleton.ps1
Shows help information.
#>

#------------------------------[ IMPORTANT ]-------------------------------

<#
PLEASE MAKE SURE THAT THE SCRIPT STARTS WITH THE COMMENT HEADER ABOVE AND
THE HEADER IS FOLLOWED BY AT LEAST ONE BLANK LINE; OTHERWISE, GET-HELP AND
GETVERSION COMMANDS WILL NOT WORK.
#>

#------------------------[ RUN-TIME REQUIREMENTS ]-------------------------

# TODO: ADJUST THE RUNTIME REQUIREMENTS.
#Requires -Version 4.0

#------------------------[ COMMAND-LINE SWITCHES ]-------------------------

# TODO: DEFINE THE COMMAND-LINE ARGS AND ADD THEM TO THE CONFIG (JSON) FILE.
# Script command-line arguments (see descriptions in the .PARAMETER comments
# above). These parameters can also be specified in the accompanying
# configuration (.json) file.
[CmdletBinding(DefaultParameterSetName="default")]
param (
    [string]
    $ModulePath = "$PSScriptRoot\Modules",

    [Alias("Config")]
    [string]
    $ConfigFile,

    [Alias("LogConfig")]
    [string]
    $LoggingConfigFile,

    [Alias("Q")]
    [switch]
    $Quiet,

    [switch]
    $NoLogo
)

#-------------------------[ MODULE DEPENDENCIES ]--------------------------

# TODO: SET YOUR SCRIPT'S MODULE DEPENDENCIES HERE.

# Module to get script version info:
# https://www.powershellgallery.com/packages/ScriptVersion

# Module to initialize script parameters and variables from a config file:
# https://www.powershellgallery.com/packages/ConfigFile

# Module implementing logging to file and console routines:
# https://www.powershellgallery.com/packages/StreamLogging

$MODULE_ScriptVersion   = "ScriptVersion"
$MODULE_ConfigFile      = "ConfigFile"
$MODULE_StreamLogging   = "StreamLogging|1.2.1"

$MODULES = @(
    $MODULE_ScriptVersion,
    $MODULE_ConfigFile,
    $MODULE_StreamLogging
)

#------------------------[ CONFIGURABLE VARIABLES ]------------------------

# TODO: ADD SCRIPT VARIABLES THAT CAN BE OVERWRITTEN VIA THE CONFIG FILE.

#----------------------[ NON-CONFIGURABLE VARIABLES ]----------------------

# TODO: DEFINE SCRIPT VARIABLES THAT CANNOT BE OVERWRITTEN VIA THE CONFIG FILE.

#------------------------------[ CONSTANTS ]-------------------------------

# TODO: DEFINE CONSTANTS.

#------------------------------[ EXIT CODES]-------------------------------

# TODO: DEFINE EXIT CODES (IF NEEDED).
# $EXITCODE_SUCCESS = 0
# $EXITCODE_ERROR   = 1

#--------------------------[ STANDARD FUNCTIONS ]--------------------------

# THE FOLLOWING FUNCTIONS DO NOT NEED TO BE CHANGED.

#--------------------------------------------------------------------------
# SetModulePath
#   Adds custom folders to the module path.
function SetModulePath {
    [CmdletBinding()]
    param(
        $modulePath
    )
    Write-Verbose "Entered SetModulePath."

    if ($modulePath) {
        if ($env:PSModulePath -notmatch ";$") {
            $env:PSModulePath += ";"
        }

        $paths = $modulePath -split ";"

        foreach ($path in $paths){
            $path = $path.Trim();

            if (-not ($env:PSModulePath.ToLower().
                Contains(";$path;".ToLower()))) {

                $env:PSModulePath += "$path;"
            }
        }
    }

    Write-Verbose "Exiting SetModulePath."
}

#--------------------------------------------------------------------------
# GetModuleVersion
#   Returns version string for the specified module using format:
#   major.minor.build.
function GetModuleVersion {
    [CmdletBinding()]
    param(
        [PSModuleInfo]
        $moduleInfo
    )

    $major = $moduleInfo.Version.Major
    $minor = $moduleInfo.Version.Minor
    $build = $moduleInfo.Version.Build

    return "$major.$minor.$build"
}

#--------------------------------------------------------------------------
# GetVersionParts
#   Converts version string into three parts: major, minor, and build.
function GetVersionParts {
    [CmdletBinding()]
    param(
        [string]
        $version
    )

    $versionParts = $version.Split(".")

    $major = $versionParts[0]
    $minor = 0
    $build = 0

    if ($versionParts.Count -gt 1) {
        $minor = $versionParts[1]
    }

    if ($versionParts.Count -gt 2) {
        $build = $versionParts[2]
    }

    return $major, $minor, $build
}

#--------------------------------------------------------------------------
# CompareVersions
#   Compares two major, minor, and build parts of two version strings and
#   returns 0 is they are the same, -1 if source version is older, or 1
# if source version is newer than target version.
function CompareVersions {
    [CmdletBinding()]
    param(
        [string]
        $sourceVersion,

        [string]
        $targetVersion
    )

    if ($sourceVersion -eq $targetVersion) {
        return 0
    }

    $sourceMajor, $sourceMinor, $sourceBuild = GetVersionParts $sourceVersion
    $targetMajor, $targetMinor, $targetBuild = GetVersionParts $targetVersion

    $source = @($sourceMajor, $sourceMinor, $sourceBuild)
    $target = @($targetMajor, $targetMinor, $targetBuild)

    for ($i = 0; $i -lt $source.Count; $i++) {
        $diff = $source[$i] - $target[$i]

        if ($diff -ne 0) {
            if ($diff -lt 0) {
                return -1
            }

            return 1
        }
    }

    return 0
}

#--------------------------------------------------------------------------
# IsSupportedVersion
#   Checks whether the specified version is within the min-max range.
function IsSupportedVersion {
    [CmdletBinding()]
    param(
        [string]
        $version,

        [string]
        $minVersion,

        [string]
        $maxVersion
    )

    if (!($minVersion) -and (!($maxVersion))) {
        return $true
    }

    if (($version -and $minVersion -and $maxVersion) -and
        ($minVersion -eq $maxVersion) -and
        ($version -eq $minVersion)) {
        return 0
    }

    if ($minVersion) {
        if ((CompareVersions $version $minVersion) -lt 0) {
            return $false
        }
    }

    if ($maxVersion) {
        if ((CompareVersions $version $maxVersion) -gt 0) {
            return $false
        }
    }

    return $true
}

#--------------------------------------------------------------------------
# LoadModules
#   Installs (if needed) and loads the specified PowerShell modules.
function LoadModules {
    [CmdletBinding()]
    param(
        [string[]]
        $modules
    )
    Write-Verbose "Entered LoadModules."

     # Make sure we got the modules.
    if (!($modules) -or ($modules.Count -eq 0)) {
        return
    }

    $module = ""
    $cmdArgs = @{}

    try {
        foreach ($module in $modules) {
            Write-Verbose "Processing module '$module'."

            $moduleInfo = $module.Split("|:")

            $moduleName         = $moduleInfo[0]
            $moduleVersion      = ""
            $moduleMinVersion   = ""
            $moduleMaxVersion   = ""
            $cmdArgs.Clear()

            if ($moduleInfo.Count -gt 1) {
                $moduleMinVersion = $moduleInfo[1]

                if ($moduleMinVersion) {
                    $cmdArgs["MinimumVersion"] = $moduleMinVersion
                }
            }

            if ($moduleInfo.Count -gt 2) {
                $moduleMaxVersion = $moduleInfo[2]

                if ($moduleMaxVersion) {
                    $cmdArgs["MaximumVersion"] = $moduleMaxVersion
                }
            }

            Write-Verbose "Required module name: '$moduleName'."

            if ($moduleMinVersion) {
                Write-Verbose "Required module min version: '$moduleMinVersion'."
            }

            if ($moduleMaxVersion) {
                Write-Verbose "Required module max version: '$moduleMaxVersion'."
            }

            # Check if module is loaded into the process.
            $loadedModules = Get-Module -Name $moduleName

            $isLoaded       = $false
            $isInstalled    = $false

            if ($loadedModules) {
                Write-Verbose "Module '$moduleName' is loaded."

                # If version check is required, compare versions.
                if ($moduleMinVersion -or $moduleMaxVersion) {

                    foreach ($loadedModule in $loadedModules) {
                        $moduleVersion = GetModuleVersion $loadedModule

                        Write-Verbose "Checking if loaded module '$moduleName' version '$moduleVersion' is supported."

                        if (IsSupportedVersion $moduleVersion $moduleMinVersion $moduleMaxVersion) {
                            Write-Verbose "Loaded module '$moduleName' version '$moduleVersion' is supported."
                            $isLoaded       = $true
                            $isInstalled    = $true
                            break
                        }
                        else {
                            Write-Verbose "Loaded module '$moduleName' version '$moduleVersion' is not supported."
                        }
                    }
                }
                else {
                    $isLoaded       = $true
                    $isInstalled    = $true
                }
            }

            # If module is not loaded or version is wrong.
            if (!$isLoaded) {
                Write-Verbose "Required module '$moduleName' is not loaded."

                # Check if module is locally available.
                $installedModules = Get-Module -ListAvailable -Name $moduleName

                $isInstalled = $false

                # If module is found, validate the version.
                if ($installedModules) {
                    foreach ($installedModule in $installedModules) {
                        $installedModuleVersion = GetModuleVersion $installedModule
                        Write-Verbose "Found installed '$moduleName' module version '$installedModuleVersion'."

                        if (IsSupportedVersion $installedModuleVersion $moduleMinVersion $moduleMaxVersion) {

                            Write-Verbose "Module '$moduleName' version '$moduleVersion' is supported."
                            $isInstalled = $true
                            break
                        }

                        Write-Verbose "Module '$moduleName' version '$moduleVersion' is not supported."
                        Write-Verbose "Supported module '$moduleName' versions are: '$moduleMinVersion'-'$moduleMaxVersion'."
                    }
                }
            }

            if (!$isInstalled) {

                # Download module if needed.
                Write-Verbose "Installing module '$moduleName'."
                Install-Module -Name $moduleName @cmdArgs -Force -Scope CurrentUser -ErrorAction Stop
            }

            #  Import module into the process.
            Write-Verbose "Importing module '$moduleName'."
            Import-Module $moduleName -ErrorAction Stop -Force @cmdArgs
            Write-Verbose "Imported module '$moduleName'."

        }
    }
    catch {
        $errMsg = "Cannot load module '$module'."
        throw (New-Object System.Exception($errMsg, $_.Exception))
    }
    finally {
        Write-Verbose "Exiting LoadModules."
    }
}

#--------------------------------------------------------------------------
# GetScriptVersion
#   Returns script version info.
function GetScriptVersion {
    [CmdletBinding()]
    param (
    )

    $versionInfo = Get-ScriptVersion
    $scriptName  = (Get-Item $PSCommandPath).Basename

    return ($scriptName +
        " v" + $versionInfo["Version"] +
        " " + $versionInfo["Copyright"])
}

#--------------------------------------------------------------------------
# GetCommandLineArgs
#   Returns command-line arguments as a string.
function GetCommandLineArgs {
    [CmdletBinding()]
    param (
    )

    $commandLine = ""
    if ($args.Count -gt 0) {

        for ($i = 0; $i -lt $args.Count; $i++) {
            if ($args[$i].Contains(" ")) {
                $commandLine = $commandLine + '"' + $args[$i] + '" '
            }
            else {
                $commandLine = $commandLine + $args[$i] + ' '
            }
        }
    }

    return $commandLine.Trim()
}

#--------------------------------------------------------------------------
# StartLogging
#   Initializes log settings.
function StartLogging {
    [CmdletBinding()]
    param(
        [string]
        $configFile,

        [bool]
        $quiet
    )
    try {
        $logArgs = @{}

        # Set logging config file if it was explicitly specified.
        if ($configFile) {
            $logArgs.Add("ConfigFile", $configFile)
        }

        # If script was launched with the -Quiet switch, do not output log to console.
        if ($quiet) {
            $logArgs.Add("Console", $false)
        }

        # Initialize log settings.
        Start-Logging @logArgs
    }
    catch {
        "Cannot start logging."
        throw
    }
}

#--------------------------------------------------------------------------
# StopLogging
#   Clears logging resources.
function StopLogging {
    [CmdletBinding()]
    param(
    )

    if (Get-Module -Name $MODULE_StreamLogging) {
        if (Test-LoggingStarted) {
            try {
                Write-Verbose "Uninitializing logging."
                Stop-Logging
            }
            catch {
                Write-Error "Cannot stop logging."
                $_

                $Error.Clear()
            }
        }
    }
}

#--------------------------------------------------------------------------
# PreMain
#   Performs common action before the main execution logic.
function PreMain {
    [CmdletBinding()]
    param(
        [datetime]
        $startTime
    )

    try {
        # Display script version info.
        if (!($NoLogo)){
            Write-LogInfo (GetScriptVersion)
        }

        Write-LogInfo "Script started at:"
        Write-LogInfo $startTime -Indent 1

        # Get script
        $scriptArgs = GetCommandLineArgs

        # Only write command-line arguments to the log file.
        if ($scriptArgs) {
            Write-LogInfo "Command-line arguments:"
            Write-LogInfo $scriptArgs -Indent 1 -NoConsole
        }

        # Only write logging configuration to the log file.
        $loggingConfig = Get-LoggingConfig -Compress
        Write-LogInfo "Logging configuration:" -NoConsole
        Write-LogInfo $loggingConfig -Indent 1 -NoConsole
    }
    catch {
        Write-LogInfo "Error in pre-main script logic."
        Stop-Logging
        throw
    }
}

#--------------------------------------------------------------------------
# PostMain
#   Performs common action after the main execution logic.
function PostMain {
    [CmdletBinding()]
    param(
        [datetime]
        $startTime,

        [datetime]
        $endTime
    )

    try {
        $runTime = (New-TimeSpan -Start $startTime -End $endTime).
            ToString("hh\:mm\:ss\.fff")

        Write-LogInfo "Script ended at:"
        Write-LogInfo $endTime -Indent 1

        Write-LogInfo "Script ran for (hr:min:sec.msec):"
        Write-LogInfo $runTime -Indent 1
        Write-LogInfo "Done."
    }
    catch {
        Write-LogInfo "Error in post-main script logic."
        Write-LogException $Error
    }
}

#---------------------------[ CUSTOM FUNCTIONS ]---------------------------

# TODO: IMPLEMENT THE FOLLOWING FUNCTIONS AND ADD YOUR OWN IF NEEDED.

#--------------------------------------------------------------------------
# Init
#   Initializes global variables.
function Init {
    [CmdletBinding()]
    param(
    )

    # TODO: Add script initialization logic here.
}

#--------------------------------------------------------------------------
# Main
#   Implements the primary script logic.
function Main {
    [CmdletBinding()]
    param(
    )

    # TODO: Add your main script logic here.

    # This example illustrates the use of the StreamLogging module.
    try {
        try {
            # Generate an exception.
            DOTHIS
        }
        catch {
            try {
                throw (New-Object System.Exception(
                    "Something bad happened here.",
                    $_.Exception))
            }
            catch {
                # Log messages from the error objects.
                "LOG EXCEPTION (MESSAGES ONLY):"
                Write-LogException
                Write-Log -LogLevel Error
                Write-Log -LogLevel Error -Errors $Error

                "LOG EXCEPTION + MESSAGE (MESSAGES ONLY):"
                "Hello, exception!" | Write-Log -LogLevel Error
                Write-Log "Hello, exception!" -LogLevel Error
            }

            $Error.Clear()
        }

        try {
            # Generate another exception.
            DOTHAT
        }
        catch {
            try {
                throw (New-Object System.Exception(
                    "Something bad happen again.",
                    $_.Exception))
            }
            catch {
                # Log error as-is.
                "LOG EXCEPTION (RAW):"
                Write-LogException -Raw
                Write-Log -LogLevel Error -Raw
                Write-Log -LogLevel Error -Errors $Error -Raw
            }

            $Error.Clear()
        }

        "LOG ERROR:"
        Write-LogError "Hello, error!"
        "Hello, error!" | Write-LogError
        Write-Log -LogLevel Error "Hello, error!"
        "Hello, error!" | Write-Log -LogLevel Error

        "LOG WARNING:"
        Write-LogWarning "Hello, warning!"
        "Hello, warning!" | Write-LogWarning
        Write-Log -LogLevel Warning "Hello, warning!"
        "Hello, warning!" | Write-Log -LogLevel Warning

        "LOG INFO:"
        Write-LogInfo "Hello, info!"
        "Hello, info!" | Write-LogInfo
        Write-Log -LogLevel Info "Hello, info!"
        Write-Log "Hello, info!"
        "Hello, info!" | Write-Log -LogLevel Info
        "Hello, info!" | Write-Log

        "LOG DEBUG:"
        Write-LogDebug "Hello, debug!"
        "Hello, debug!" | Write-LogDebug
        Write-Log -LogLevel Debug "Hello, debug!"
        "Hello, debug!" | Write-Log -LogLevel Debug

        $object = @{
            "Key1" = "Value1"
            "Key2" = "Value2"
        }

        "LOG ERROR OBJECT:"
        Write-LogError -Object $object
        Write-Log -LogLevel Error -Object $object

        "LOG WARNING OBJECT (COMPRESS):"
        Write-LogWarning -Object $object -Compress
        Write-Log -LogLevel Warning -Object $object -Compress

        "LOG INFO OBJECT + MESSAGE (COMPRESS):"
        Write-LogInfo "Hello, object:" -Object $object -Compress
        "Hello, object:" | Write-LogInfo -Object $object -Compress
        Write-Log -LogLevel Info "Hello, object:" -Object $object -Compress
        Write-Log "Hello, object:" -Object $object -Compress
        "Hello, object:" | Write-Log -LogLevel Info -Object $object -Compress
        "Hello, object:" | Write-Log -Object $object -Compress

        "LOG DEBUG OBJECT + MESSAGE (COMPRESS):"
        Write-LogDebug "Hello, object:" -Object $object -Compress
        "Hello, object:" | Write-LogDebug -Object $object -Compress
        Write-Log -LogLevel Debug "Hello, object:" -Object $object -Compress
        "Hello, object:" | Write-Log -LogLevel Debug -Object $object -Compress
    }
    catch {
        Write-LogInfo "Error in the main script logic."
        Write-LogException $Error
    }
}

#---------------------------------[ MAIN ]---------------------------------

# We will trap errors in the try-catch blocks.
$ErrorActionPreference = 'Stop'

# There is nothing to dispose.
$dispose = $false

# Make sure we have no pending errors.
$Error.Clear()

# Add custom folder(s) to the module path.
SetModulePath $ModulePath

# Load module dependencies.
LoadModules $Modules

# Load settings from a config file, if needed (this cannot be called from a function).
try {
    Import-ConfigFile -ConfigFilePath $ConfigFile -DefaultParameters $PSBoundParameters
}
catch {
    "Cannot initialize run-time settings from a configuration file."
    throw
}

# Initialize globals.
Init

# Initialize logging.
StartLogging $LoggingConfigFile $Quiet

# TODO: Set the dispose flag to indicate that resources must be deallocated.
# This is needed, for example, if we need to close open files, such as
# log files in this example, or do some other cleanup.
$dispose = $true

# PRE-SCRIPT LOGIC
$startTime = Get-Date
PreMain $startTime

# MAIN SCRIPT LOGIC
Main

# POST-SCRIPT LOGIC.
$endTime = Get-Date
PostMain $startTime $endTime

# Uncomment the following line to illustrate the 'trap' mechanism.
# abc

# Uninitialize logging.
StopLogging

# Nothing to dispose.
$dispose = $false

# Unhandled exception handler.
trap {
    # TODO: Dispose all allocated resources.
    # We must dispose logging resources (i.e. stream writers).
    if ($dispose) {
        StopLogging
    }
}
# THE END
#--------------------------------------------------------------------------
