#' @rdname dos2unix
#'
#' @export

unix2dos <- function(file)
{
  txt <- readLines(file)
  con <- file(file, open="wb")
  writeLines(txt, con, sep="\r\n")
  close(con)
}
