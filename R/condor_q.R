#' Condor Queue
#'
#' List the Condor job queue.
#'
#' @param all whether to list jobs from all users.
#' @param count whether to only show the number of jobs.
#' @param user username to list jobs submitted by a given user.
#' @param session optional object of class \code{ssh_connect}.
#'
#' @details
#' The default value of \code{session = NULL} looks for a \code{session} object
#' in the user workspace. This allows the user to run Condor functions without
#' explicitly specifying the \code{session}.
#'
#' @return No return value, called for side effects.
#'
#' @seealso
#' \code{\link{condor_submit}}, \code{condor_q}, \code{\link{condor_dir}}, and
#' \code{\link{condor_download}} provide the main Condor interface.
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
#' # Alternatively, list number of jobs being run by each user
#' condor_q(all=TRUE, count=TRUE)
#' }
#'
#' @importFrom ssh ssh_exec_wait
#'
#' @export

condor_q <- function(all=FALSE, count=FALSE, user="", session=NULL)
{
  # Look for user session
  if(is.null(session))
    session <- get("session", pos=.GlobalEnv, inherits=FALSE)

  # Prepare command
  arg <- ""
  if(all)
    arg <- paste(arg, "-allusers")
  if(count)
    arg <- paste(arg, "-format '%s\n' Owner")
  if(user != "")
    arg <- paste(arg, "-submitter", user)
  cmd <- paste("condor_q", arg)

  # Show count or screen output
  if(count)
    table(ssh_exec_stdout(cmd))
  else
    ssh_exec_wait(session, cmd)
}
