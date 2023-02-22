#' Condor Queue
#'
#' List the Condor job queue.
#'
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
#' \code{\link{condor_dir}} lists Condor directories.
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
#' condor_dir()
#' condor_download()  # after job has finished
#' }
#'
#' @importFrom ssh ssh_exec_wait
#'
#' @export

condor_q <- function(session=NULL)
{
  # Look for user session
  if(is.null(session))
    session <- get("session", pos=.GlobalEnv, inherits=FALSE)

  ssh_exec_wait(session, "condor_q")
}
