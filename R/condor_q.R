#' Condor Queue
#'
#' List the Condor job queue.
#'
#' @param all whether to list jobs from all users.
#' @param count whether to only show the number of jobs.
#' @param global whether to list jobs submitted from all submitter machines.
#' @param user username to list jobs submitted by a given user.
#' @param session optional object of class \code{ssh_connect}.
#'
#' @details
#' The default value of \code{session = NULL} looks for a \code{session} object
#' in the user workspace. This allows the user to run Condor functions without
#' explicitly specifying the \code{session}.
#'
#' @return
#' Screen output from the \command{condor_q} shell command, or a table if
#' \code{count = TRUE}.
#'
#' @note
#' The \code{condor_q} R function has the same defaults as the
#' \command{condor_q} shell command, listing only jobs that were submitted by
#' the current user from the current submitter machine.
#'
#' The \code{condor_qq} alternative is the same function but with different
#' default argument values, convenient for a \emph{quick} overview of the
#' \emph{queue}.
#'
#' @author Arni Magnusson.
#'
#' @seealso
#' \code{\link{condor_submit}}, \code{condor_q}, \code{\link{condor_dir}}, and
#' \code{\link{condor_download}} provide the main Condor interface.
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
#' # Alternatively, list number of jobs being run by each user
#' condor_q(all=TRUE, count=TRUE)
#' }
#'
#' @importFrom ssh ssh_exec_wait
#' @importFrom utils capture.output
#'
#' @export

condor_q <- function(all=FALSE, count=FALSE, global=FALSE, user="",
                     session=NULL)
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
  if(global)
    arg <- paste(arg, "-global")
  if(user != "")
    arg <- paste(arg, "-submitter", user)
  cmd <- paste("condor_q", arg)

  # Table or screen output
  if(count)
  {
    out <- table(ssh_exec_stdout(cmd))
  }
  else
  {
    out <- capture.output(ssh_exec_wait(session, cmd))
    out <- out[out != "[1] 0"]
    class(out) <- "condor_q"
  }
  out
}

#' @rdname condor_q
#'
#' @export

condor_qq <- function(all=TRUE, count=TRUE, global=TRUE, user="", session=NULL)
{
  condor_q(all=all, count=count, global=global, user=user, session=session)
}

#' @rdname condor-internal
#'
#' @export
#' @export print.condor_q

print.condor_q <- function(x, ...)
{
  writeLines(x, ...)
  invisible(x)
}

#' @rdname condor-internal
#'
#' @export
#' @export summary.condor_q

summary.condor_q <- function(object, ...)
{
  NULL
}
