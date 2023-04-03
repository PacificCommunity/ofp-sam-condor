#' Summary Condor Log
#'
#' Produce a summary of a Condor log file.
#'
#' @param object an object of class \code{\link{condor_log}}.
#' @param \dots passed to \code{round}.
#'
#' @return
#' Data frame with the following columns:
#' \item{job.id}{job id.}
#' \item{status}{text indicating whether job status is submitted, executing, or
#'       finished.}
#' \item{submit.time}{date and time when job was submitted.}
#' \item{runtime}{total duration of a job.}
#' \item{disk}{disk space used by job (MB).}
#' \item{memory}{memory used by job (MB).}
#'
#' @seealso
#' \code{\link{condor_log}} shows Condor log file.
#'
#' \code{\link{condor-package}} gives an overview of the package.
#'
#' @examples
#' \dontrun{
#' session <- ssh_connect("servername")
#'
#' condor_dir()
#' condor_log()
#' summary(condor_log())
#' }
#'
#' @importFrom utils type.convert
#'
#' @export

summary.condor_log <- function(object, ...)
{
  job.id <- gsub(".*\\(([0-9]+)\\..*", "\\1", object[1])
  job.id <- type.convert(job.id, as.is=TRUE)
  if(!is.integer(job.id))
    job.id <- NA_integer_

  status <- if(any(grepl("Job terminated", object)))
              "finished"
            else if(any(grepl("Job executing", object)))
              "executing"
            else if(any(grepl("Job submitted", object)))
              "submitted"
            else
              NA_character_

  submit.time <- gsub(".*\\) (.*) Job.*", "\\1", object[1])
  if(!grepl(":", submit.time))
    submit.time <- NA_character_

  runtime <- grep("Total Remote Usage", object, value=TRUE)
  hms <- gsub(".* (.*),.*", "\\1", runtime)  # hr, min, sec
  hms <- unlist(strsplit(hms, ":"))
  days <- gsub(".*Usr ([0-9]*).*", "\\1", runtime)
  hms[1] <- 24 * as.integer(days) + as.integer(hms[1])
  runtime <- paste(hms, collapse=":")
  if(length(runtime) == 0 || runtime == "")
    runtime <- NA_character_

  disk <- grep("Disk \\(KB\\)", object, value=TRUE)
  disk <- gsub(".*: *([0-9]*) .*", "\\1", disk)
  disk <- type.convert(disk, as.is=TRUE)
  disk <- round(disk / 1024, ...)
  if(length(disk) == 0)
    disk <- NA_integer_

  memory <- grep("Memory \\(MB\\)", object, value=TRUE)
  memory <- gsub(".*: *([0-9]*) .*", "\\1", memory)
  memory <- type.convert(memory, as.is=TRUE)
  memory <- round(memory, ...)
  if(length(memory) == 0)
    memory <- NA_integer_

  data.frame(job.id=job.id, status=status, submit.time=submit.time,
             runtime=runtime, disk=disk, memory=memory)
}
