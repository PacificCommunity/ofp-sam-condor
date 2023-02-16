#' Condor Download
#'
#' Download results from a Condor job.
#'
#' @param session created by \code{ssh_connect}.
#' @param local.dir local directory to download to.
#' @param remote.dir remote directory containing Condor job results.
#' @param pattern pattern identifying which result files to download.
#' @param overwrite.local whether to overwrite local files if they already
#'        exist.
#' @param remove.remote whether to remove the remote directory after downloading
#'        the result files.
#'
#' @seealso
#' \code{\link{condor_submit}} submits a Condor job.
#'
#' \code{\link{condor-package}} gives an overview of the package.
#'
#' @examples
#' \dontrun{
#' library(ssh)
#' session <- ssh_connect("NOUOFPCALC02")
#'
#' condor_submit(session)
#' condor_q(session)
#' condor_download(session)  # after job has finished
#' }
#'
#' @importFrom ssh scp_download ssh_exec_internal ssh_exec_wait
#'
#' @export

condor_download <- function(session, local.dir=".", remote.dir="condor_run",
                            pattern="condor_mfcl|End.tar.gz",
                            overwrite.local=FALSE, remove.remote=TRUE)
{
  # Confirm that user is downloading a single remote.dir
  if(length(remote.dir) > 1)
    stop("only one 'remote.dir' can be downloaded at a time")

  # Look for files matching pattern
  files <- ssh_exec_internal(session, paste("cd", remote.dir, "; ls"))
  files <- unlist(strsplit(rawToChar(files$stdout), "\\n"))
  files <- grep("condor_mfcl|End.tar.gz", files, value=TRUE)

  # Confirm that End.tar.gz does not already exist in local.dir
  if("End.tar.gz" %in% dir(local.dir))
  {
    if(overwrite.local)
      warning("overwriting End.tar.gz")
    else
      stop("End.tar.gz already exists - consider overwrite.local=TRUE")
  }

  # Download files and optionally remove remote.dir
  sapply(file.path(remote.dir, files), scp_download, session=session,
         to=local.dir)
  if(remove.remote)
  {
    ssh_exec_wait(session, paste("cd", remote.dir, ";", "cd ..;",
                                 "rm -rf", basename(remote.dir)))
  }

  invisible(NULL)
}
