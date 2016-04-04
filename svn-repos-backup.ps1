$repos_base_dir = "C:\tmp"
$repos_names    = @("repos1", "repos2")
$dump_dir       = "C:\tmp"

$day_of_week = [Int] (get-date).DayOfWeek

foreach ($d in @($repos_base_dir, $dump_dir)) {
    if (!(test-path $d -PathType container)) {
        $mesg = "### The directory doesn't exist. ({0}). Exit." -f $d
        write-error $mesg
        exit 1
    }
}

foreach ($repos_name in $repos_names) {
    $dump_file_path = "$dump_dir\$repos_name.$day_of_week.dump"
    $repos_path = "$repos_base_dir\$repos_name"

    # Use CMD.exe bacause svnadmin.exe can't spefify a dump file path.
    # Redirect svn data to a file, error mesg to STDOUT.
    $command = "svnadmin dump --quiet $repos_path 2>&1 1> $dump_file_path"
    $result = & cmd /c $command | out-string

    if ($? -eq $false) {
        write-warning $result
    }
}
