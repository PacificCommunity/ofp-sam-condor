#' Condor Download
#'
#' Download results from a Condor job.
#'
#' @param run.dir name of a Condor run directory inside \code{top.dir}.
#' @param top.dir top directory on submitter machine that contains Condor run
#'        directories.
#' @param local.dir local directory to download to.
#' @param pattern regular expression identifying which result files to download.
#'        Passing \code{pattern="*"} will download all files.
#' @param overwrite whether to overwrite local files if they already exist.
#' @param remove whether to remove remote directory after downloading result
#'        files.
#' @param untar.end whether to extract \code{End.tar.gz} into
#'        \emph{local.dir} after downloading. (Ignored if a file named
#'        \file{End.tar.gz} was not downloaded.)
#' @param session optional object of class \code{ssh_connect}.
#'
#' @details
#' The default value of \code{run.dir = NULL} looks for Condor job results in
#' \emph{top.dir}\code{/}\emph{local.dir}. For example, if
#' \code{local.dir = "c:/yft/run01"} then the default \code{run.dir} becomes
#' \code{"condor/run01"}.
#'
#' The default value of \code{pattern="End.tar.gz|condor.*(err|log|out)$"}
#' downloads \code{End.tar.gz} and Condor log files. For many analyses, it can
#' be convenient to pack all results into End.tar.gz to make it easy to find,
#' download, and manage output files.
#'
#' The default value of \code{session = NULL} looks for a \code{session} object
#' in the user workspace. This allows the user to run Condor functions without
#' explicitly specifying the \code{session}.
#'
#' @return No return value, called for side effects.
#'
#' @seealso
#' \code{\link{condor_submit}}, \code{\link{condor_q}},
#' \code{\link{condor_dir}}, and \code{condor_download} provide the main Condor
#' interface.
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
#' @importFrom ssh scp_download ssh_exec_internal ssh_exec_wait
#' @importFrom utils untar
#'
#' @export

condor_download <- function(run.dir=NULL, top.dir="condor", local.dir=".",
                            pattern="End.tar.gz|condor.*(err|log|out)$",
                            overwrite=FALSE, remove=FALSE, untar.end=TRUE,
                            session=NULL)
{
  # Expand dot so basename() works
  if(local.dir == ".")
    local.dir <- getwd()

  # Construct remote.dir path
  if(is.null(run.dir))
    run.dir <- basename(local.dir)
  remote.dir <- file.path(top.dir, run.dir)

  # Confirm that local.dir exists
  if(!dir.exists(local.dir))
    stop(local.dir, " not found")

  # Ensure local.dir exists
  dir.create(local.dir, showWarnings=FALSE, recursive=TRUE)

  # Look for user session
  if(is.null(session))
    session <- get("session", pos=.GlobalEnv, inherits=FALSE)

  # Confirm that user is downloading a single remote.dir
  if(length(remote.dir) > 1)
    stop("only one 'remote.dir' can be downloaded at a time")

  # Confirm that remote.dir exists
  rd.exists <- ssh_exec_internal(session, paste("cd", remote.dir), error=FALSE)
  if(rd.exists$status > 0)
    stop("directory '", remote.dir, "' not found on Condor submitter")

  # Look for files matching pattern
  files <- ssh_exec_stdout(paste("cd", remote.dir, "; ls"))
  files <- grep(pattern, files, value=TRUE)

  # Confirm that files do not already exist in local.dir
  if(!overwrite)
  {
    for(f in files)
    {
      if(f %in% dir(local.dir))
        stop(f, " already exists in local.dir - consider overwrite=TRUE")
    }
  }

  # Download files and untar End.tar.gz
  sapply(file.path(remote.dir, files), scp_download, session=session,
         to=local.dir)
  if(untar.end && file.exists(file.path(local.dir, "End.tar.gz")))
    untar(file.path(local.dir, "End.tar.gz"), exdir=local.dir)

  # Remove remote.dir
  if(remove)
  {
    ssh_exec_wait(session, paste("cd", remote.dir, ";", "cd ..;",
                                 "rm -rf", basename(remote.dir)))
  }

  invisible(NULL)
}
