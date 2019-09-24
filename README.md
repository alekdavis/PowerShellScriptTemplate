# PowerShellScriptTemplate
A reusable code template for a PowerShell script.

## Overview
This repository contains three files:

- `Skeleton.ps1` is a PowerShell script template that you can use to write your own scripts,
- `Skeleton.ps1.json` is a sample configuration file used by the script, and
- `Skeleton.ps1.StreamLogging.json` is a sample configuration file used by the [StreamLogging module](https://github.com/alekdavis/StreamLogging).

## Dependencies
The `Skeleton.ps1` script depends on the following modules (all available at [PowerShell gallery](https://PowerShellGallery.com/)):

- __[ScriptVersion](https://github.com/alekdavis/ScriptVersion)__ allows you to easily manage script versions.
- __[ConfigFile](https://github.com/alekdavis/ConfigFile)__ lets you read script parameters and variables form a configuration file.
- __[StreamLogging](https://github.com/alekdavis/StreamLogging)__ makes it easy to log messages to the console and/or a text file.

## Description
The `Skeleton.ps1` defines the script structure, common functions that cannot be implemented in PowerShell modules, and illustrates how to:

- Print script version information.
- Initialize script parameters and variables from a configuration file (command-line parameters override the values in the configuration file).
- Configure and use the [StreamLogging module](https://github.com/alekdavis/StreamLogging) to print log messages to the console and/or text files.
- Install (if needed) and load PowerShell modules.
- Use local modules (in case the script runs on a system not connected to the Internet or for some reason cannot download modules from the [PowerShell gallery](https://PowerShellGallery.com/).
- Print command line parameters.
- Handle unexpected exceptions.
- Calculate script run time.

## Usage
You can run the script without parameters. It will print the various log messages to the console. Then play with the script parameters and/or configuration files to achieve different results.

## Customization
Read the script comments and follow the `TODO` instructions to customize it for your own needs.
