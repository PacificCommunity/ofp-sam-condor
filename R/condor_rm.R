
#' Condor remove
#' 
#' Remove a Condor job.
#' @param job.id the id number of the job would like to remove from the condor.
#' @param all whether to remove all jobs from users in the condor.
#' @param session optional object of class \code{ssh_connect}.
#' 
#' @details 
#' Use this function to remove one or all the jobs on the condor. 
#' If wish to remove one job, please specific job.id. 
#' If wish to remove all jobs, need to set all=TRUE. 
#' If both job.id and all=FALSE. The function will stop and return an error message. 
#' 
#' @return No return value, called for side effects.
#' 
#' @author Nan Yao.
#'
#'  @seealso
#' \code{\link{condor_submit}}, \code{\link{condor_q}},
#' \code{\link{condor_rm}}, \code{\link{condor_dir}}, 
#' \code{condor_download}, and
#' \code{\link{condor_rmdir}} provide the main Condor interface.
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
#' condor_rm() # if want to remove a job from condor
#' condor_dir()
#' condor_download()  # after job has finished
#' condor_rmdir()
#'
#' # Alternatively, list number of jobs being run by each user
#' condor_q(all=TRUE, count=TRUE)
#' }
#'
#' @importFrom ssh ssh_exec_wait
#'
#' @export
condor_rm <- function(job.id="",all=FALSE,session=NULL)
{
  # Look for user session
  if(is.null(session))
    session <- get("session", pos=.GlobalEnv, inherits=FALSE)
  
  # Prepare command
  arg <- ""
  if(all)
    arg <- paste(arg, "-all")
  if(job.id!="")
    arg <- job.id
  if(job.id==""&all==FALSE)
    stop("must specific either a job.id or select all==TRUE if you want to remove all jobs! ")
  
  cmd <- paste("condor_rm", arg)
  ## show rm result 
  table(ssh_exec_stdout(cmd))
  
}

