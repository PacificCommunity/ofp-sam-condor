#' Condor Remove Directory
#'
#' Remove a directory on the submitter machine.
#'
#' @param run.dir name of a Condor run directory inside \code{top.dir}.
#' @param top.dir top directory on submitter machine that contains Condor run
#'        directories.
#' @param session optional object of class \code{ssh_connect}.
#'
#' @details
#' The default value of \code{run.dir = NULL} looks for a Condor run directory
#' with the same name as the current working directory:
#' \emph{top.dir}\code{/}\emph{working.dir}. For example, if the current working
#' directory is \code{"c:/yft/run01"} then the default \code{run.dir} becomes
#' \code{"condor/run01"}.
#'
#' The default value of \code{session = NULL} looks for a \code{session} object
#' in the user workspace. This allows the user to run Condor functions without
#' explicitly specifying the \code{session}.
#'
#' @return No return value, called for side effects.
#'
#' @seealso
#' \code{\link{condor_submit}}, \code{\link{condor_q}},
#' \code{\link{condor_dir}}, \code{condor_download}, and
#' \code{\link{condor_rmdir}} provide the main Condor interface.
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
#' condor_rmdir()
#'
#' # Alternatively, remove a specific directory
#' condor_rmdir("01_this_model")           # remove ~/condor/01_this_model
#' condor_rmdir("test_runs", top.dir=".")  # remove ~/test_runs
#' }
#'
#' @importFrom ssh ssh_exec_wait
#'
#' @export

condor_rmdir <- function(run.dir=NULL, top.dir="condor", session=NULL)
{
  # Construct remote.dir path
  local.dir <- getwd()
  if(is.null(run.dir))
    run.dir <- basename(local.dir)
  remote.dir <- file.path(top.dir, run.dir)

  # Look for user session
  if(is.null(session))
    session <- get("session", pos=.GlobalEnv, inherits=FALSE)

  # Confirm that user is removing a single remote.dir
  if(length(remote.dir) > 1)
    stop("only one remote directory can be removed at a time")

  # Remove remote.dir
  if(remove)
  {
    ssh_exec_wait(session, paste("cd", remote.dir, ";", "cd ..;",
                                 "rm -rf", basename(remote.dir)))
  }

  invisible(NULL)
}
