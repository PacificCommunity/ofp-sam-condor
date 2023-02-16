#' Condor Queue
#'
#' List the Condor job queue.
#'
#' @param session created by \code{ssh_connect}.
#'
#' @seealso
#' \code{\link{condor_submit}} submits a Condor job.
#'
#' \code{\link{condor_download}} downloads results from a Condor job.
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
#' @importFrom ssh ssh_exec_wait
#'
#' @export

condor_q <- function(session)
{
  ssh_exec_wait(session, "condor_q")
}
