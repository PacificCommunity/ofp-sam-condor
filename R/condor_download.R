#' Condor Download
#'
#' Download results from a Condor job.
#'
#' @param remote.dir remote directory containing Condor job results.
#' @param local.dir local directory to download to.
#' @param pattern pattern identifying which result files to download.
#' @param overwrite whether to overwrite local files if they already exist.
#' @param remove whether to remove remote directory after downloading result
#'        files.
#' @param untar.end whether to extract \code{End.tar.gz} into
#'        \emph{local.dir}\code{/End}. (Ignored if a file named
#'        \file{End.tar.gz} was not downloaded.)
#' @param session optional object of class \code{ssh_connect}.
#'
#' @details
#' The default value of \code{remote.dir = NULL} looks for Condor job results in
#' \code{condor/}\emph{local.dir}. For example, if
#' \code{local.dir = "c:/yft/run01"} then the default \code{remote.dir} becomes
#' \code{"condor/run01"}.
#'
#' The default value of \code{session = NULL} looks for a \code{session} object
#' in the user workspace. This allows the user to run Condor functions without
#' explicitly specifying the \code{session}.
#'
#' @seealso
#' \code{\link{condor_submit}} submits a Condor job.
#'
#' \code{\link{condor_q}} lists the Condor job queue.
#'
#' \code{\link{condor_dir}} lists Condor directories.
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
#' condor_download()  # after job has finished
#' }
#'
#' @importFrom ssh scp_download ssh_exec_internal ssh_exec_wait
#' @importFrom utils untar
#'
#' @export

condor_download <- function(remote.dir=NULL, local.dir=".",
                            pattern="condor_mfcl|End.tar.gz", overwrite=FALSE,
                            remove=TRUE, untar.end=TRUE, session=NULL)
{
  # Expand dot so basename() works
  if(local.dir == ".")
    local.dir <- getwd()

  # Default remote.dir
  if(is.null(remote.dir))
    remote.dir <- file.path("condor", basename(local.dir))

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
  files <- ssh_exec_internal(session, paste("cd", remote.dir, "; ls"))
  files <- unlist(strsplit(rawToChar(files$stdout), "\\n"))
  files <- grep("condor_mfcl|End.tar.gz", files, value=TRUE)

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
    untar(file.path(local.dir, "End.tar.gz"), exdir=file.path(local.dir, "End"))

  # Remove remote.dir
  if(remove)
  {
    ssh_exec_wait(session, paste("cd", remote.dir, ";", "cd ..;",
                                 "rm -rf", basename(remote.dir)))
  }

  invisible(NULL)
}
