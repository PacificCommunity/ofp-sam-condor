#' Condor Remove
#'
#' Stop Condor jobs.
#'
#' @param job.id a vector of integers or directory names, indicating Condor jobs
#'        to stop.
#' @param all whether to stop all Condor jobs owned by user.
#' @param top.dir top directory on submitter machine that contains Condor run
#'        directories.
#' @param session optional object of class \code{ssh_connect}.
#'
#' @details
#' The \code{top.dir} argument only has an effect when \code{job.id} is a vector
#' of directory names. For example, \code{condor_rm("01_this")} will stop the
#' Condor job corresponding to directory \code{condor/01_this} on the submitter
#' machine.
#'
#' The default value of \code{session = NULL} looks for a \code{session} object
#' in the user workspace. This allows the user to run Condor functions without
#' explicitly specifying the \code{session}.
#'
#' @return No return value, called for side effects.
#'
#' @author Nan Yao and Arni Magnusson.
#'
#' @seealso
#' \code{\link{condor_submit}}, \code{\link{condor_q}},
#' \code{\link{condor_dir}}, and \code{\link{condor_download}} provide the main
#' Condor interface.
#'
#' \code{condor_rm} stops Condor jobs and \code{\link{condor_rmdir}} removes
#' directories on the submitter machine.
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
#' # Stop one or multiple jobs
#' condor_rm(123456)                   # stop one job (integer)
#' condor_rm(c(123456, 123789))        # stop two jobs (integers)
#' condor_rm("01_this")                # stop one job (dirname)
#' condor_rm(c("01_this", "02_that"))  # stop two jobs (dirnames)
#' condor_rm(all=TRUE)                 # stop all jobs
#' }
#'
#' @importFrom ssh ssh_exec_wait
#' @importFrom utils type.convert
#'
#' @export

condor_rm <- function(job.id=NULL, all=FALSE, top.dir="condor", session=NULL)
{
  # Look for user session
  if(is.null(session))
    session <- get("session", pos=.GlobalEnv, inherits=FALSE)

  # Convert job.id to integer, unless all=TRUE
  if(!all)
  {
    if(is.null(job.id))
      stop("user must pass 'job.id' or 'all=TRUE'")
    job.id <- type.convert(job.id, as.is=TRUE)  # "123456" -> 123456
    if(is.character(job.id))
    {
      for(i in seq_along(job.id))
      {
        job.id[i] <- gsub("\\^||\\$", "", job.id[i])  # clean existing ^ and $
        job.id[i] <- paste0("^", job.id[i], "$")
        job.id[i] <- condor_dir(pattern=job.id[i])$job.id
      }
      job.id <- type.convert(job.id, as.is=TRUE)
    }
  }

  # Stop job(s)
  cmd <- paste("condor_rm", if(all) "-all" else job.id)
  invisible(sapply(cmd, ssh_exec_wait, session=session))

  invisible(NULL)
}
