# condor 2.0.0 (2023-06-21)

* Added function condor_rm() to stop a Condor job.

* Added function condor_rmdir() to remove a directory on the submitter machine.
  Removed argument 'remove' from condor_download().

* Added argument 'sort' in condor_dir().

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
