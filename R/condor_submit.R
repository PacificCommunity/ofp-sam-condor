#' Condor Submit
#'
#' Submit a Condor job.
#'
#' @param local.dir local directory containing a Condor \code{*.sub} file and
#'        any other files necessary to run the job.
#' @param run.dir name of a Condor run directory to create inside
#'        \code{top.dir}.
#' @param top.dir top directory on submitter machine that contains Condor run
#'        directories.
#' @param exclude pattern identifying files in \code{local.dir} that should not
#'        be submitted to Condor.
#' @param session optional object of class \code{ssh_connect}.
#'
#' @details
#' The default value of \code{run.dir = NULL} runs the Condor job in
#' \emph{top.dir}\code{/}\emph{local.dir}. For example, if
#' \code{local.dir = "c:/yft/run01"} then the default \code{run.dir} becomes
#' \code{"condor/run01"}.
#'
#' It can be practical to organize Condor runs inside the default
#' \code{top.dir = "condor"} directory, to keep Condor runs separate from other
#' directories inside the user home. To organize Condor runs directly in the
#' home folder on the submitter machine, pass \code{top.dir = ""}.
#'
#' The default value of \code{session = NULL} looks for a \code{session} object
#' in the user workspace. This allows the user to run Condor functions without
#' explicitly specifying the \code{session}.
#'
#' @return Remote directory name with the job id as a name attribute.
#'
#' @note
#' This function performs two core tasks: (1) upload files from \code{local.dir}
#' to submitter machine, and (2) execute shell command \command{condor_submit}
#' on submitter machine to launch the Condor job.
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
#' # Alternatively, submit a specific run
#' condor_submit("c:/myruns/01_this_model")
#' }
#'
#' @importFrom ssh scp_upload ssh_exec_internal ssh_exec_wait
#' @importFrom stats setNames
#' @importFrom utils tail tar
#'
#' @export

condor_submit <- function(local.dir=".", run.dir=NULL, top.dir="condor",
                          exclude="condor_mfcl|tar.gz|End", session=NULL)
{
  # Expand dot so basename() works
  if(local.dir == ".")
    local.dir <- getwd()

  # Construct remote.dir path
  if(is.null(run.dir))
    run.dir <- basename(local.dir)
  remote.dir <- file.path(top.dir, run.dir)

  # Look for user session
  if(is.null(session))
    session <- get("session", pos=.GlobalEnv, inherits=FALSE)

  # Confirm that local.dir exists and contains one *.sub
  if(!dir.exists(local.dir))
    stop("missing local directory '", local.dir, "'")
  subfile <- dir(local.dir, pattern="\\.sub$")
  if(length(subfile) != 1)
    stop("'local.dir' must contain one *.sub file")

  # Confirm that Condor submitter does not already contain remote.dir
  already <- ssh_exec_internal(session, paste("ls", remote.dir), error=FALSE)
  if(already$status == 0)
    stop("'", remote.dir, "' already exists on Condor submitter")

  # Create Start.tar.gz (excluding existing tar.gz files) inside tempdir()
  files <- dir(local.dir, full.names=TRUE)
  files <- grep(exclude, files, invert=TRUE, value=TRUE)
  if(!dir.exists(tempdir()))  # tempdir() may not exist, ran into that yesterday
    dir.create(tempdir())
  Start.tar.gz <- file.path(tempdir(), "Start.tar.gz")
  owd <- setwd(local.dir); on.exit(setwd(owd))  # avoid paths inside tar file
  tar(Start.tar.gz, basename(files), compression="gzip")
  on.exit(file.remove(Start.tar.gz), add=TRUE)

  # Create remote.dir on submitter, upload, unzip, and run
  ssh_exec_wait(session, paste("mkdir -p", remote.dir))
  scp_upload(session, files=Start.tar.gz, to=remote.dir)
  cmd <- paste("cd", remote.dir, ";",
               "tar -xzf Start.tar.gz;",
               "condor_submit", subfile)
  stdout <- tail(ssh_exec_stdout(cmd), 1)  # final line includes job id

  # Extract and format job information
  job <- as.integer(gsub(".*?([0-9][0-9]+).*", "\\1", stdout))
  job <- setNames(basename(remote.dir), job)

  job
}
