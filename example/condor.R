library(condor)
session <- ssh_connect("NOUOFPCALC02")

condor_submit()
condor_q()
condor_dir()

# Wait until job has finished, then run
condor_download()
