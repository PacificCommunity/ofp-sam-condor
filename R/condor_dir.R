#' Condor Directories
#'
#' List Condor run directories, either on submitter machine or on a local drive.
#'
#' @param top.dir top directory on submitter machine that contains Condor run
#'        directories.
#' @param local.dir local directory to examine instead of \code{top.dir}.
#' @param pattern regular expression identifying which run directories to show.
#'        The default is to show all directories inside \code{top.dir} or
#'        \code{local.dir}.
#' @param report whether to return a detailed report of the run status in each
#'        directory.
#' @param sort column name or column number used to sort the report data frame.
#' @param session optional object of class \code{ssh_connect}.
#' @param \dots passed to \code{\link{grep}}.
#'
#' @details
#' If the user passes \code{top.dir} that resembles a Windows local directory
#' (drive letter, colon, forward slash), it is automatically interpreted as a
#' \code{local.dir}. In other words, \code{condor_dir("c:/myruns")} and
#' \code{condor_dir(local.dir="c:/myruns")} are equivalent.
#'
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
#' \code{\link{condor_log}} and \code{\link{summary.condor_log}} are called to
#' produce the detailed report if \code{report = TRUE}.
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
#' # Alternatively, examine runs on local drive
#' condor_dir(local.dir="myruns")
#' condor_dir("c:/myruns")
#' }
#'
#' @importFrom ssh ssh_exec_internal
#'
#' @export

condor_dir <- function(top.dir="condor", local.dir=NULL, pattern="*",
                       report=TRUE, sort="job.id", session=NULL, ...)
{
  # Interpret top.dir as local.dir if it starts with drive letter, colon, slash
  if(is.null(local.dir) && isTRUE(grepl("^[A-Za-z]:/", top.dir)))
    local.dir <- top.dir  # or if it starts with slash slash
  if(is.null(local.dir) && isTRUE(grepl("^//", top.dir)))
    local.dir <- top.dir

  # Look for user session
  # We don't want to check is.null(local.dir) until after local.dir <- top.dir
  if(is.null(session) && is.null(local.dir))
    session <- get("session", pos=.GlobalEnv, inherits=FALSE)

  # Confirm that top.dir or local.dir exists
  if(is.null(local.dir))
  {
    rd.exists <- ssh_exec_internal(session, paste("cd", top.dir), error=FALSE)
    if(rd.exists$status > 0)
      stop("directory '", top.dir, "' not found on Condor submitter")
  }
  else
  {
    if(!dir.exists(local.dir))
      stop("local directory '", local.dir, "' not found")
  }

  # Get dirnames
  if(is.null(local.dir))
  {
    cmd <- paste("find", top.dir,
                 "-mindepth 1 -maxdepth 1 -type d -printf '%f\n'")
    dirs <- sort(ssh_exec_stdout(cmd))
  }
  else
  {
    dirs <- dir(local.dir, full.names=TRUE)
    dirs <- basename(dirs[dir.exists(dirs)])  # directories only
  }
  dirs <- grep(pattern, dirs, value=TRUE, ...)

  # Prepare output
  if(report)
  {
    output <- data.frame(dir=character(), job.id=integer(), status=character(),
                         submit.time=character(), runtime=character(),
                         disk=numeric(), memory=numeric())
    if(is.character(sort) && length(sort)==1 && !(sort %in% names(output)))
      stop("column '", sort, "' not found in report data frame")
    if(is.numeric(sort) && length(sort) == 1 && !(abs(sort) %in% seq_along(output)))
      stop("column ", abs(sort), " does not exist in report data frame")
    for(i in seq_along(dirs))
    {
      output[i,1] <- dirs[i]
      if(is.null(local.dir))
        output[i,-1] <- summary(condor_log(run.dir=dirs[i], top.dir=top.dir))
      else
        output[i,-1] <- summary(condor_log(local.dir=file.path(local.dir,
                                                               dirs[i])))
    }
  }
  else
  {
    output <- dirs
  }

  # Sort data frame and finalize row names
  if(is.data.frame(output))
  {
    # Valid column name
    if(is.character(sort) && length(sort) == 1)
    {
      output <- output[order(output[[sort]]),]
    }
    # Valid column number, positive or negative
    if(is.numeric(sort) && length(sort) == 1)
    {
      sign <- if(sort > 0) 1 else -1
      output <- output[order(sign * rank(output[[abs(sort)]])),]
    }
    rownames(output) <- NULL
  }

  output
}
