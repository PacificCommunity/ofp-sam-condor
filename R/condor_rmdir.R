#' Condor Remove Directory
#'
#' Remove directories on the submitter machine.
#'
#' @param run.dir name of a Condor run directory inside \code{top.dir}.
#' @param top.dir top directory on submitter machine that contains Condor run
#'        directories.
#' @param quiet whether to suppress messages.
#' @param session optional object of class \code{ssh_connect}.
#'
#' @details
#' The default value of \code{session = NULL} looks for a \code{session} object
#' in the user workspace. This allows the user to run Condor functions without
#' explicitly specifying the \code{session}.
#'
#' @return No return value, called for side effects.
#'
#' @author Arni Magnusson.
#'
#' @seealso
#' \code{\link{condor_submit}}, \code{\link{condor_q}},
#' \code{\link{condor_dir}}, and \code{condor_download} provide the main Condor
#' interface.
#'
#' \code{\link{condor_rm}} stops Condor jobs and \code{\link{condor_rmdir}}
#' removes directories on the submitter machine.
#'
#' \code{\link{condor-package}} gives an overview of the package.
#'
#' @examples
#' \dontrun{
#'
#' # General workflow
#' session <- ssh_connect("servername")
#'
#' condor_submit()
#' condor_q()
#' condor_dir()
#' condor_download()  # after job has finished
#'
#' # Remove one or more directories
#' condor_rmdir("01_this")                 # remove ~/condor/01_this (one run)
#' condor_rmdir(c("01_this", "02_that"))   # remove two model runs inside condor
#' condor_rmdir("test_runs", top.dir=".")  # remove ~/my_runs (many subdirs)
#' }
#'
#' @importFrom ssh ssh_exec_internal ssh_exec_wait
#'
#' @export

condor_rmdir <- function(run.dir, top.dir="condor", quiet=FALSE, session=NULL)
{
  # Look for user session
  if(is.null(session))
    session <- get("session", pos=.GlobalEnv, inherits=FALSE)

  # Construct remote.dir path
  if(is.null(run.dir))
    stop("run.dir = NULL is not a valid directory name")
  for(i in seq_along(run.dir))
  {
    if(run.dir[i] == "")
      stop("run.dir = \"\"", run.dir[i], " is not a valid directory name")
    if(grepl("\\*", run.dir[i]))
      stop("run.dir = '", run.dir[i], "' is not a valid directory name")
  }
  remote.dir <- file.path(top.dir, run.dir)

  # Confirm that remote.dir exists
  for(i in seq_along(remote.dir))
  {
    cmd <- paste("cd", remote.dir[i])
    rd.exists <- ssh_exec_internal(session, cmd, error=FALSE)
    if(rd.exists$status > 0)
      stop("directory '", remote.dir[i], "' not found on Condor submitter")
  }

  # Remove remote.dir
  for(i in seq_along(run.dir))
  {
    if(!quiet)
      cat("Removing directory '", run.dir[i], "'\n", sep="")
    cmd <- paste("cd", top.dir, ";", "rm -rf", run.dir[i])
    ssh_exec_wait(session, cmd)
  }

  invisible(NULL)
}
