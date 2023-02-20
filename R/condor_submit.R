#' Condor Submit
#'
#' Submit a Condor job.
#'
#' @param local.dir local directory containing a Condor \code{*.sub} file and
#'        any other files necessary to run the job.
#' @param remote.dir remote directory where Condor job should run.
#' @param exclude pattern identifying files that should not be submitted to
#'        Condor.
#' @param session optional object of class \code{ssh_connect}.
#'
#' @details
#' The default value of \code{remote.dir} uses the same directory name as
#' \code{local.dir}.
#'
#' The default value of \code{session = NULL} looks for a \code{session} object
#' in the user workspace. This allows the user to run Condor functions without
#' explicitly specifying the \code{session}.
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
#' condor_submit()
#' condor_q()
#' condor_download()  # after job has finished
#' }
#'
#' @importFrom ssh scp_upload ssh_exec_internal ssh_exec_wait
#' @importFrom stats setNames
#' @importFrom utils tar
#'
#' @export

condor_submit <- function(local.dir=getwd(), remote.dir=basename(local.dir),
                          exclude="condor_mfcl|tar.gz|End", session=NULL)
{
  # Look for user session
  if(is.null(session))
    session <- get("session", pos=.GlobalEnv, inherits=FALSE)

  # Confirm that local.dir contains one *.sub
  subfile <- dir(local.dir, pattern="\\.sub$")
  if(length(subfile) != 1)
    stop("'local.dir' must contain one *.sub file")

  # Confirm that Condor submitter does not already contain remote.dir
  already <- ssh_exec_internal(session, paste("ls", remote.dir), error=FALSE)
  if(already$status == 0)
    stop(remote.dir, " already exists on Condor submitter")

  # Create Start.tar.gz in local.dir (excluding existing tar.gz files)
  files <- dir(local.dir, full.names=TRUE)
  files <- grep(exclude, files, invert=TRUE, value=TRUE)
  owd <- setwd(local.dir)
  tar("Start.tar.gz", basename(files), compression="gzip")
  setwd(owd)

  # Create remote.dir on submitter, upload, unzip, and run
  ssh_exec_wait(session, paste("mkdir -p", remote.dir))
  scp_upload(session, files=file.path(local.dir, "Start.tar.gz"), to=remote.dir)
  file.remove(file.path(local.dir, "Start.tar.gz"))
  cmd <- paste("cd", remote.dir, ";",
               "tar -xzf Start.tar.gz;",
               "condor_submit", subfile)
  output <- ssh_exec_internal(session, cmd)

  # Extract and format job.id
  job.id <- rawToChar(output$stdout)
  job.id <- as.integer(gsub(".*?([0-9][0-9]+).*", "\\1", job.id))
  job.id <- setNames(job.id, remote.dir)

  job.id
}
