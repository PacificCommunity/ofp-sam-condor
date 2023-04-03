#' Condor Log
#'
#' Show Condor log file from a run directory on submitter machine.
#'
#' @param run.dir name of a Condor run directory inside \code{top.dir}.
#' @param top.dir top directory on submitter machine that contains Condor run
#'        directories.
#' @param session optional object of class \code{ssh_connect}.
#'
#' @details
#' The default value of \code{session = NULL} looks for a \code{session} object
#' in the user workspace. This allows the user to run Condor functions without
#' explicitly specifying the \code{session}.
#'
#' @return
#' Log file contents as an object of class \code{condor_log}.
#'
#' The \code{condor_log} class is simply a \code{"character"} vector with a
#' \code{print.condor_log} method.
#'
#' @seealso
#' \code{\link{summary.condor_log}} shows Condor log file summary.
#'
#' \code{\link{condor_dir}} lists Condor directories.
#'
#' \code{\link{condor-package}} gives an overview of the package.
#'
#' @examples
#' \dontrun{
#' session <- ssh_connect("servername")
#'
#' condor_dir()
#' condor_log()
#' summary(condor_log())
#' }
#'
#' @importFrom ssh ssh_exec_internal
#'
#' @export

condor_log <- function(run.dir=".", top.dir="condor", session=NULL)
{
  # Interpret dot and combine directory name
  if(run.dir == ".")
    run.dir <- basename(getwd())
  directory <- file.path(top.dir, run.dir)

  # Look for user session
  if(is.null(session))
    session <- get("session", pos=.GlobalEnv, inherits=FALSE)

  # Confirm that user is downloading a single remote.dir
  if(length(directory) > 1)
    stop("only one directory can be examined at a time")

  # Confirm that remote.dir exists
  d.exists <- ssh_exec_internal(session, paste("cd", directory), error=FALSE)
  if(d.exists$status > 0)
    stop("directory '", directory, "' not found on Condor submitter")

  # Look for file containing the string 'Job submitted'
  cmd <- paste("grep -l 'Job submitted'", file.path(directory, "*.log"))
  filename <- ssh_exec_stdout(cmd)
  if(length(filename) > 1)
    stop("only one *.log file should contain the string 'Job submitted'")

  txt <- ssh_exec_stdout(paste("cat", filename))
  class(txt) <- "condor_log"

  txt
}

#' @rdname condor-internal
#'
#' @export
#' @export print.condor_log

print.condor_log <- function(x, ...)
{
  writeLines(x, ...)
  invisible(x)
}
