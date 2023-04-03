#' Condor Directories
#'
#' List directories on Condor submitter.
#'
#' @param pattern regular expression identifying which run directories to show.
#'        The default is to show all directories inside \code{top.dir}.
#' @param top.dir top directory on submitter machine that contains Condor run
#'        directories.
#' @param report whether to return a detailed report of the run status in each
#'        directory.
#' @param session optional object of class \code{ssh_connect}.
#' @param \dots passed to \code{\link{grep}}.
#'
#' @details
#' The default value of \code{session = NULL} looks for a \code{session} object
#' in the user workspace. This allows the user to run Condor functions without
#' explicitly specifying the \code{session}.
#'
#' @return
#' A data frame containing details about each directory, or if
#' \code{report = FALSE} a \code{character} vector of directory names.
#'
#' @note
#' If there are many Condor run directories, the report generation can take
#' substantial time (one SSH execution per run directory). To quickly return a
#' vector of directory names, pass \code{report = FALSE}.
#'
#' @seealso
#' \code{\link{condor_submit}}, \code{\link{condor_q}}, \code{condor_dir}, and
#' \code{\link{condor_download}} provide the main Condor interface.
#'
#' \code{\link{condor_log}} and \code{\link{summary.condor_log}} are called to
#' produce the detailed report if \code{report = TRUE}.
#'
#' \code{\link{condor-package}} gives an overview of the package.
#'
#' @examples
#' \dontrun{
#' session <- ssh_connect("servername")
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

condor_dir <- function(pattern="*", top.dir="condor", report=TRUE, session=NULL,
                       ...)
{
  # Look for user session
  if(is.null(session))
    session <- get("session", pos=.GlobalEnv, inherits=FALSE)

  # Confirm that top.dir exists
  rd.exists <- ssh_exec_internal(session, paste("cd", top.dir), error=FALSE)
  if(rd.exists$status > 0)
    stop("directory '", top.dir, "' not found on Condor submitter")

  # Get dirnames
  cmd <- paste("cd", top.dir, ";", "ls -d */")  # dirs only
  dirs <- ssh_exec_stdout(cmd)
  dirs <- sub("/", "", dirs)
  dirs <- grep(pattern, dirs, value=TRUE, ...)

  # Prepare output
  if(report)
  {
    output <- data.frame(dir=character(), job.id=integer(), status=character(),
                         submit.time=character(), runtime=character(),
                         disk=numeric(), memory=numeric())
    for(i in seq_along(dirs))
    {
      output[i,1] <- dirs[i]
      output[i,-1] <- summary(condor_log(dirs[i]))
    }
  }
  else
  {
    output <- dirs
  }

  output
}
