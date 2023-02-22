#' Condor Directories
#'
#' List directories on Condor submitter.
#'
#' @param top.dir top directory on submitter machine that contains Condor run
#'        directories.
#' @param session optional object of class \code{ssh_connect}.
#'
#' @details
#' The default value of \code{session = NULL} looks for a \code{session} object
#' in the user workspace. This allows the user to run Condor functions without
#' explicitly specifying the \code{session}.
#'
#' @return \code{character} vector of directory names.
#'
#' @seealso
#' \code{\link{condor_submit}}, \code{\link{condor_q}}, \code{condor_dir}, and
#' \code{\link{condor_download}} provide the main Condor interface.
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
#' condor_dir()
#' condor_download()  # after job has finished
#' }
#'
#' @importFrom ssh ssh_exec_internal
#'
#' @export

condor_dir <- function(top.dir="condor", session=NULL)
{
  # Look for user session
  if(is.null(session))
    session <- get("session", pos=.GlobalEnv, inherits=FALSE)

  # Confirm that top.dir exists
  rd.exists <- ssh_exec_internal(session, paste("cd", top.dir), error=FALSE)
  if(rd.exists$status > 0)
    stop("directory '", top.dir, "' not found on Condor submitter")


  cmd <- paste("cd", top.dir, ";", "ls -d */")  # dirs only
  dirs <- ssh_exec_stdout(cmd)
  dirs <- sub("/", "", dirs)
  dirs
}
