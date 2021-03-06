# ==============================================================================
# Backup SVN repositories
# ==============================================================================

# ------------------------------------------------------------------------------
# Config
# ------------------------------------------------------------------------------
$repos_base_dir   = "C:\svn"
$repos_names      = @("testrepos")
$dump_dir         = "C:\backup"
$svnadmin_exe     = "svnadmin.exe"
$eventlog_logname = "Application"
$eventlog_source  = "bat"

$debug = $false

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

$now = get-date
$day_of_week = [Int] $now.DayOfWeek

$mesg = @(
        ("### {0} starts at {1}" -f $myinvocation.mycommand, $now.tostring()),
        ("### Is this debug? {0}" -f $debug)
    ) -join "`n"

write-host $mesg
write-eventlog -LogName $eventlog_logname -Source $eventlog_source -EntryType Information -EventId 0 -Message $mesg

foreach ($d in @($repos_base_dir, $dump_dir)) {
    if (!(test-path $d -PathType container)) {
        $mesg = "### The directory doesn't exist. ({0}). Exit." -f $d
        write-error $mesg
        exit 1
    }
}

if ((get-command $svnadmin_exe -ErrorAction SilentlyContinue) -eq $null) {
        $mesg = "### The svnadmin.exe doesn't exist. ({0}). Exit." -f $svnadmin_exe
        write-error $mesg
        exit 2
}

foreach ($repos_name in $repos_names) {
    $dump_file_path = "$dump_dir\svn.$repos_name.$day_of_week.dump"
    $repos_path = "$repos_base_dir\$repos_name"

    # Use CMD.exe bacause svnadmin.exe can't spefify a dump file path.
    # Redirect svn data to a file, error mesg to STDOUT.
    $command = "$svnadmin_exe dump --quiet $repos_path 2>&1 1> $dump_file_path"

    $mesg = "### Do dump unless debug. Repos:{0} Command:{1}" -f $repos_name, $command
    write-host $mesg
    write-eventlog -LogName $eventlog_logname -Source $eventlog_source -EntryType Information -EventId 0 -Message $mesg

    if ($debug -ne $true) {
        $result = & cmd /c $command | out-string

        if ($? -eq $false) {
            $mesg = @(
                    ("### The svnadmin dump command failed."),
                    ("### Command: {0}" -f $command),
                    ("### Message: {0}" -f $result.Trim()),
                    ("### Exit.")
                ) -join "`n"
            write-error $mesg
            write-eventlog -LogName $eventlog_logname -Source $eventlog_source -EntryType Error -EventId 0 -Message $mesg
            exit 3
        }
    }
}

$mesg = "### Finished at {0}. Exit" -f (get-date).tostring()
write-host $mesg
write-eventlog -LogName $eventlog_logname -Source $eventlog_source -EntryType Information -EventId 0 -Message $mesg

exit 0
