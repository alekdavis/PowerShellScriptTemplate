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
Version    : 1.0.1
Author     : Alek Davis
Created on : 2019-10-02
License    : MIT License
LicenseLink: https://github.com/alekdavis/PowerShellScriptTemplate/blob/master/LICENSE
Copyright  : (c) 2019 Alek Davis

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

$Modules = @("ScriptVersion", "ConfigFile", "StreamLogging")

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
        [string]
        $modulePath
    )

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
}

#--------------------------------------------------------------------------
# LoadModule
#   Installs (if needed) and loads a PowerShell module.
function LoadModules {
    [CmdletBinding()]
    param(
        [string[]]
        $modules
    )

    # Make sure we got the modules.
    if (!($modules) -or ($modules.Count -eq 0)) {
        return
    }

    try {
        foreach ($module in $modules) {
            # If module is not loaded into the process.
            if (!(Get-Module -Name $module)) {

                # Check if module is locally available.
                if (!(Get-Module -Listavailable -Name $module)) {

                    # Download module if needed.
                    Write-Verbose "Installing module '$module'."
                    Install-Module -Name $module `
                        -Force -Scope CurrentUser -ErrorAction Stop
                }
            }

            #  Import module into the process.
            Write-Verbose "Importing module '$module'."
            Import-Module $module -ErrorAction Stop -Force
        }
    }
    catch {
        "Cannot load modules."
        throw
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

    try {
        Stop-Logging
    }
    catch {
        "Cannot stop logging."
        throw
    }
}

#--------------------------------------------------------------------------
# InitConfigFile
#   Loads settings from config file (if any) into the script parameters and
#   variables.
function InitConfigFile {
    [CmdletBinding()]
    param(
        [string]
        $configFile,

        [Hashtable]
        $DefaultParameters
    )
    try {
        Import-ConfigFile -ConfigFilePath $ConfigFile `
            -DefaultParameters $PSBoundParameters
    }
    catch {
        "Cannot initialize run-time settings from a configuration file."
        throw
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

#--------------------------[ STANDARD FUNCTIONS ]--------------------------

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

# Load settings from a config file (if any).
InitConfigFile -ConfigFile $ConfigFile -DefaultParameters $PSBoundParameters

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
