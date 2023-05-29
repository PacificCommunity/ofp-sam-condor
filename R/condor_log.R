#' Condor Log
#'
#' Show Condor log file from a run directory, either on submitter machine or on
#' a local drive.
#'
#' @param run.dir name of a Condor run directory inside \code{top.dir}.
#' @param top.dir top directory on submitter machine that contains Condor run
#'        directories.
#' @param local.dir local directory to examine instead of
#'        \emph{top.dir}\code{/}\emph{run.dir}.
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
#'
#' # Examine log files on submitter machine
#' session <- ssh_connect("servername")
#'
#' condor_dir()
#' condor_log()
#' summary(condor_log())
#'
#' # Alternatively, examine log file on local drive
#' condor_dir(local.dir="c:/myruns")
#' condor_log(local.dir="c:/myruns/01_this_model")
#' summary(condor_log(local.dir="c:/myruns/01_this_model"))
#' }
#'
#' @importFrom ssh ssh_exec_internal
#'
#' @export

condor_log <- function(run.dir=".", top.dir="condor", local.dir=NULL,
                       session=NULL)
{
  # Interpret dot and combine directory name
  if(run.dir == ".")
    run.dir <- basename(getwd())
  directory <- if(is.null(local.dir)) file.path(top.dir, run.dir) else local.dir

  # Look for user session
  if(is.null(session) && is.null(local.dir))
    session <- get("session", pos=.GlobalEnv, inherits=FALSE)

  # Confirm that user is downloading a single remote.dir
  if(length(directory) > 1)
    stop("only one directory can be examined at a time")

  # Confirm that remote.dir exists
  if(is.null(local.dir))
  {
    d.exists <- ssh_exec_internal(session, paste("cd", directory), error=FALSE)
    if(d.exists$status > 0)
      stop("directory '", directory, "' not found on Condor submitter")
  }

  # Look for file containing the string 'Job submitted'
  if(is.null(local.dir))
  {
    cmd <- paste("grep -l 'Job submitted'", file.path(directory, "*.log"))
    filename <- ssh_exec_stdout(cmd)
    if(length(filename) > 1)
      stop("only one *.log file should contain the string 'Job submitted'")
    txt <- ssh_exec_stdout(paste("cat", filename))
  }
  else
  {
    filename <- dir(directory, pattern="\\.log$", full.names=TRUE)
    txt <- sapply(filename, readLines)
    long <- lapply(txt, paste, collapse="\n")
    filename <- filename[sapply(long, grepl, pattern="Job submitted")]
    if(length(filename) > 1)
      stop("only one *.log file should contain the string 'Job submitted'")
    txt <- txt[[filename]]
  }

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
