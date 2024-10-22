#' Convert Line Endings
#'
#' Convert line endings in a text file between Dos (CRLF) and Unix (LF) format.
#'
#' @param file a filename.
#'
#' @return No return value, called for side effects.
#'
#' @author Arni Magnusson.
#'
#' @seealso
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

dos2unix <- function(file)
{
  txt <- readLines(file)
  con <- file(file, open="wb")
  writeLines(txt, con, sep="\n")
  close(con)
}
