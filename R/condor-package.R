#' @docType package
#'
#' @name condor-package
#'
#' @aliases condor
#'
#' @title Interact with Condor from R
#'
#' @description
#' Tools that support submitting, listing, and downloading Condor jobs from R.
#'
#' @details
#' \emph{Main interface:}
#' \tabular{ll}{
#'   \code{\link{condor_submit}}   \tab submit\cr
#'   \code{\link{condor_q}}        \tab list queue\cr
#'   \code{\link{condor_dir}}      \tab list directories\cr
#'   \code{\link{condor_download}} \tab download
#' }
#' \emph{Utilities:}
#' \tabular{ll}{
#'   \code{\link{condor_log}}         \tab show log file\cr
#'   \code{\link{summary.condor_log}} \tab show log file summary\cr
#'   \code{\link{ssh_exec_stdout}}    \tab execute command
#' }
#'
#' @author Arni Magnusson with contributions by Jemery Day.
#'
#' @references
#' \url{https://github.com/PacificCommunity/ofp-sam-condor}
#'
#' @seealso
#' \pkg{condor} uses the \pkg{ssh} package to connect to the Condor submitter
#' machine.

NA
