#' Condor Submit
#'
#' Submit a Condor job.
#'
#' @param session created by \code{ssh_connect}.
#' @param local.dir local directory containing \code{condor.sub} and any other
#'        files necessary to run the job.
#' @param remote.dir remote directory containing Condor job results.
#'
#' @seealso
#' \code{\link{condor_q}} lists the Condor job queue.
#'
#' \code{\link{condor_download}} downloads results from a Condor job.
#'
#' \code{\link{condor-package}} gives an overview of the package.
#'
#' @examples
#' \dontrun{
#' library(ssh)
#' session <- ssh_connect("NOUOFPCALC02")
#'
#' condor_submit(session)
#' condor_q(session)
#' condor_download(session)  # after job has finished
#' }
#'
#' @importFrom ssh scp_upload ssh_exec_internal ssh_exec_wait
#' @importFrom stats setNames
#' @importFrom utils tar
#'
#' @export

condor_submit <- function(session, local.dir=".", remote.dir="condor_run")
{
  # Confirm that local.dir contains condor.sub
  if(!("condor.sub" %in% dir(local.dir)))
    stop("condor.sub not found - please check 'local.dir'")

  # Confirm that Condor submitter does not already contain remote.dir
  already <- ssh_exec_internal(session, paste("ls", remote.dir), error=FALSE)
  if(already$status == 0)
    stop(remote.dir, " already exists on Condor submitter")

  # Create Start.tar.gz in local.dir (excluding existing tar.gz files)
  files <- dir(local.dir, full.names=TRUE)
  files <- grep("tar.gz$", files, invert=TRUE, value=TRUE)
  tar(file.path(local.dir, "Start.tar.gz"), files, compression="gzip")

  # Create remote.dir on submitter, upload, unzip, and run
  ssh_exec_wait(session, paste("mkdir -p", remote.dir))
  scp_upload(session, files="Start.tar.gz", to=remote.dir)
  file.remove("Start.tar.gz")
  cmd <- paste("cd", remote.dir, ";",
               "tar -xzf Start.tar.gz;",
               "condor_submit condor.sub")
  output <- ssh_exec_internal(session, cmd)

  # Extract and format job.id
  job.id <- rawToChar(output$stdout)
  job.id <- as.integer(gsub(".*?([0-9][0-9]+).*", "\\1", job.id))
  job.id <- setNames(job.id, remote.dir)

  job.id
}
