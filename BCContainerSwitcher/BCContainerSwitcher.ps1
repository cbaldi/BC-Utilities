<#
.SYNOPSIS
This script helps me out with switching BC Containers.

.DESCRIPTION
USAGE
    .\BCContainer.ps1 <command>

COMMANDS
    showRunning     run `docker ps --format '{{.Names}}'`, exit by pressing any key.
    switchTo        Stops all running containers and starts the target one
    help, -?        show this help message
#>
param(
    [Parameter(Position = 0, Mandatory = $True)]
    [ValidateSet("init", "showRunning", "switchTo", "help")]
    [string]$Command
)

$OUTPUTS_PATH = "C:\Users\eosadmin\PWSH_scripts\BCContainerOutputs"

# WIP
<# function CommandInit {
    if (!(Test-Path $OUTPUTS_PATH -PathType Container)) {
        New-Item $OUTPUTS_PATH -type Directory
    }
} #>
function CommandShowRunning {
    do {
        Write-Host '----------------------'
        docker ps --format '{{.Names}}'
        Start-Sleep(1)
    } until ([System.Console]::KeyAvailable)
}
function CommandSwitchTo {
    $targetContainer = Read-Host "Target Container"
    $WATCH = New-Object System.Diagnostics.Stopwatch
    $runninContainers = docker ps --format '{{.Names}}'

    $WATCH.Start()
    foreach ($container in $runninContainers) {
        # $OutputFilePath = '"$($OUTPUTS_PATH)\Stop-BcContainer_$($using:container)_Output.txt"' # idk how to make this work...
        Start-Job -Name "Stopping_$($container)" -ScriptBlock {
            Start-Sleep(2)
            if (!(Test-Path "$($using:OUTPUTS_PATH)\Stop-BcContainer_$($using:container)_Output.txt" <# $OutputFilePath #> -PathType Leaf)) {
                New-Item "$($using:OUTPUTS_PATH)\Stop-BcContainer_$($using:container)_Output.txt" <# $OutputFilePath #> -type file
            }
            Stop-BcContainer $using:container
        }
    }
    # WIP
    # while (true) {
    #     $Jobs = Get-Job
    #     if $Jobs.
    # }
    Get-Job | Wait-Job # waiting for all jobs to complete
    Remove-Job -State Completed # removes all jobs that were completed
    Write-Host "Elapsed time: $($WATCH.Elapsed.Seconds)"

    Write-Host '----------------------'
    Write-Host 'Running containers were:'
    Write-Host $runninContainers
    Write-Host '----------------------'

    Start-BcContainer $targetContainer
}


switch ($Command) {
    # "init" { CommandInit } # WIP
    "showRunning" { CommandShowRunning }
    "switchTo" { CommandSwitchTo }
    "help" { Get-Help .\BCContainer.ps1 }
}
