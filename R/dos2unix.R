#' Convert Line Endings
#'
#' Convert line endings in a text file between Dos (CRLF) and Unix (LF) format.
#'
#' @param file a filename.
#' @param force whether to proceed with the conversion when the file is not a
#'        standard text file.
#'
#' @details
#' The default value of \code{force = FALSE} is a safety feature that can avoid
#' corrupting files that are not standard text files, such as binary files. A
#' standard text file is one that can be read using \code{\link{readLines}}
#' without producing warnings.
#'
#' @return No return value, called for side effects.
#'
#' @author Arni Magnusson.
#'
#' @seealso
#' \code{\link{condor_submit}} calls \code{dos2unix} to convert the line endings
#' of shell scripts.
#'
#' \code{\link{condor-package}} gives an overview of the package.
#'
#' @examples
#' \dontrun{
#' file <- "test.txt"
#' write("123", file)
#'
#' dos2unix(file)
#' file.size(file)
#'
#' unix2dos(file)
#' file.size(file)
#'
#' file.remove(file)
#' }
#'
#' @export

dos2unix <- function(file, force=FALSE)
{
  if(!force)
  {
    owarn <- options(warn=2)  # treat warnings from readLines() as errors
    on.exit(options(owarn))
  }

  txt <- try(readLines(file), silent=TRUE)
  if(inherits(txt, "try-error"))
    stop("file is not a standard text file")

  con <- file(file, open="wb")
  writeLines(txt, con, sep="\n")
  close(con)
}
