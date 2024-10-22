#' @name condor-package
#'
#' @aliases condor
#'
#' @title Interact with Condor from R via SSH
#'
#' @description
#' Interact with Condor from R via SSH connection. Files are first uploaded from
#' user machine to submitter machine, and the job is then submitted from the
#' submitter machine to Condor. Functions are provided to submit, list, and
#' download Condor jobs from R.
#'
#' Condor is an open source high-throughput computing software framework for
#' distributed parallelization of computationally intensive tasks.
#'
#' @details
#' \emph{Main interface:}
#' \tabular{ll}{
#'   \code{\link{condor_submit}}   \tab submit\cr
#'   \code{\link{condor_q}}        \tab list queue\cr
#'   \code{\link{condor_dir}}      \tab list directories\cr
#'   \code{\link{condor_download}} \tab download
#' }
#' \emph{Stop and remove:}
#' \tabular{ll}{
#'   \code{\link{condor_rm}}    \tab stop jobs\cr
#'   \code{\link{condor_rmdir}} \tab remove directories
#' }
#' \emph{Utilities:}
#' \tabular{ll}{
#'   \code{\link{condor_log}}         \tab show log file\cr
#'   \code{\link{dos2unix}}           \tab convert line endings\cr
#'   \code{\link{summary.condor_log}} \tab show log file summary\cr
#'   \code{\link{ssh_exec_stdout}}    \tab execute command\cr
#'   \code{\link{unix2dos}}           \tab convert line endings
#' }
#'
#' @author
#' Arni Magnusson and Nan Yao, with contributions by Jemery Day and Thomas
#' Teears.
#'
#' @references
#' \url{https://github.com/PacificCommunity/ofp-sam-condor}
#'
#' \url{https://htcondor.org}
#'
#' @seealso
#' \pkg{condor} uses the \pkg{ssh} package to connect to the Condor submitter
#' machine.

"_PACKAGE"
