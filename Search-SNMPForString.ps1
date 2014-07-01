
# Search-String a Sonus SNMP Log file and get the string,DateTime of the event and logfile details

$VerbosePreference = 'Continue'


#Paths For Lux Logs
$Paths = 'C:\temp\NYSyslog'

# Output collection

$OutputCollection = @()

########################################

# Set date range or AllLogs $True for all logs in that directory

$AllLogs = $True



##################################################

#Searchfor

# This string indicates a new ISDN call. Call details will be within 7 lines below this
$simplematch = 'Failed to execute AD query. Suggested action - confirm that AD is network reachable'

#############

Foreach ($Path in $Paths)

{

If ($AllLogs -eq $False) # All files or date range
    {
    $files1 = Get-ChildItem -Recurse "$Path" | where-object {$_.lastwritetime -ge $StartDate -and  $_.lastwritetime -lt $Enddate -and ! $_.PSIsContainer}
    }
else
    {

    # Sort objects by date to process most recent first, not by name order
    $files1 = Get-ChildItem -Recurse "$Path" | Sort-Object LastWriteTime -Descending
    }


$files1count = $($files1.count)
Write-host ' '
Write-Host "Searching Logs from $Path between dates (American date format) $StartDate and $Enddate"
Write-Host "Log File count is $files1count"
Write-Host "For String $($simplematch)"
Write-host ' '

$loopcount1 = $null
Foreach ($file in $files1) #Foreach File Checked
    {
    $loopcount1 = $loopcount1 + 1
    
    Write-Verbose "checking file $loopcount1 of $files1count $($file.fullname) LastWritetime: $($file.lastwritetime)"
    
    $content = Get-Content "$($file.fullname)"
    
    $AllMatches = $content | Select-String -simpleMatch $simplematch

    Write-Verbose "Total Match count $($grep1AllMatches.count)"

    $grep1AllMatches

    Foreach ($match in $AllMatches)
        {


        # Find the Date from the log line ###############################################

        $DateString = $($match.Line) | Select-String -Pattern '\b(?:[0-9]+-[0-9]+-[0-9]+| [0-9]+:[0-9]+:[0-9]+)\b'
        $TimeString = $($match.Line) | Select-String -Pattern '\b([0-9]+:[0-9]+:[0-9]+)\b'

        $darte = $null
        $Date = Get-Date "$($DateString.Matches[0].Value) $($TimeString.Matches[0].Value) "


            $output = New-Object -TypeName PSobject 
            $output | add-member NoteProperty 'DateTime' -value $Date
            $output | add-member NoteProperty 'LogString' -value $($match.line)
            $output | add-member NoteProperty 'LogFile' -value $($file.fullname)
            $output | add-member NoteProperty 'LogFileName' -value $($file.name)
            $output | add-member NoteProperty 'LogFileLastWriteTime' -value $($file.lastwritetime)
            $output | add-member NoteProperty 'MatchPattern' -value $($match.Pattern)
            
            # Write Output to Screen
            $output

            $OutputCollection += $output

        }

    } # Close Foreach File

    } # Close Foreach Path

    $OutputCollection | Sort-Object DateTime | Select-Object DateTime,LogFileName,MatchPattern | ft -AutoSize