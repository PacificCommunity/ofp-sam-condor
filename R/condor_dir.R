#' Condor Directories
#'
#' List directories on Condor submitter machine.
#'
#' @param path top directory on submitter machine that contains Condor run
#'        directories.
#' @param session optional object of class \code{ssh_connect}.
#'
#' @details
#' The default value of \code{session = NULL} looks for a \code{session} object
#' in the user workspace. This allows the user to run Condor functions without
#' explicitly specifying the \code{session}.
#'
#' @seealso
#' \code{\link{condor_submit}} submits a Condor job.
#'
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
#' condor_dir()
#' }
#'
#' @importFrom ssh ssh_exec_internal
#'
#' @export

condor_dir <- function(path="condor", session=NULL)
{
  # Look for user session
  if(is.null(session))
    session <- get("session", pos=.GlobalEnv, inherits=FALSE)

  # Confirm that path exists
  rd.exists <- ssh_exec_internal(session, paste("cd", path), error=FALSE)
  if(rd.exists$status > 0)
    stop("directory '", path, "' not found on Condor submitter")


  cmd <- paste("cd", path, ";", "ls -d */")  # dirs only
  dirs <- ssh_exec_internal(session, cmd)$stdout
  dirs <- unlist(strsplit(rawToChar(dirs), "\\n"))
  dirs <- sub("/", "", dirs)
  dirs
}
