#' @rdname dos2unix
#'
#' @export

unix2dos <- function(file, force=FALSE)
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
  writeLines(txt, con, sep="\r\n")
  close(con)
}
