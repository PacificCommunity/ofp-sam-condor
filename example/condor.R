library(condor)
session <- ssh_connect("NOUOFPCALC02")

condor_submit()
condor_q()

# Wait until job has finished, then run
condor_download()
