# condor 1.0.1 (2023-05-29)

* Added argument 'local'dir' to condor_dir() and condor_log().

* Added argument 'create.dir' to condor_download(). Changed argument order in
  condor_download(), so #2 is 'local.dir' and #3 is 'top.dir'.

* Improved condor_dir() to allow 'top.dir' to be different from the default
  "condor".




# condor 1.0.0 (2023-04-03)

* Initial release, providing the functions condor_dir(), condor_download(),
  condor_log(), condor_q(), condor_submit(), and ssh_exec_stdout().
