# condor 3.0.0 (2024-11-12)

* Changed the default behavior of condor_submit() to ensure that shell scripts
  with a '.sh' file extension have Unix line endings. Pass unix=FALSE to disable
  conversion of line endings.

* Added functions dos2unix() and unix2dos() to convert line endings in a text
  file.

* Added argument 'unix' to condor_submit().

* Added a simple class 'condor_q' for the output of condor_q() with a print()
  method. This helps distinguish it from the 'condor_log' class, which has
  print() and summary() methods.

* Improved condor_dir() output when log files include multiple values of disk
  and memory usage.




# condor 2.1.0 (2023-08-28)

* Added function condor_qq() to produce a quick overview of the queue.

* Added argument 'global' to condor_q().

* Improved condor_q() so it captures and returns the screen output from the
  condor_q shell command.




# condor 2.0.0 (2023-06-21)

* Added function condor_rm() to stop a Condor job.

* Added function condor_rmdir() to remove a directory on the submitter machine.
  Removed argument 'remove' from condor_download().

* Added argument 'sort' to condor_dir().

* Changed argument order in condor_dir() so 'top.dir' comes first. First
  argument is automatically interpreted as a 'local'dir' if it resembles a
  Windows local directory, as in condor_dir("c:/myruns").

* Improved condor_dir() by adding a status category 'aborted' to identify runs
  that were aborted by user.

* Improved condor_dir() and condor_log() error messages when directories are
  missing or empty, log files are missing or not containing keywords, also
  distinguishing between files and directories.




# condor 1.0.1 (2023-05-29)

* Added argument 'local.dir' to condor_dir() and condor_log().

* Added argument 'create.dir' to condor_download(). Changed argument order in
  condor_download(), so #2 is 'local.dir' and #3 is 'top.dir'.

* Improved condor_dir() to allow 'top.dir' to be different from the default
  "condor".




# condor 1.0.0 (2023-04-03)

* Initial release, providing the functions condor_dir(), condor_download(),
  condor_log(), condor_q(), condor_submit(), and ssh_exec_stdout().
