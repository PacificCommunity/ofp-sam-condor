#' Execute and Capture Standard Output
#'
#' Call \code{ssh_exec_internal} and convert the standard output to characters.
#'
#' @param command command or script to execute.
#' @param session optional object of class \code{ssh_connect}.
#' @param \dots passed to \code{\link[ssh]{ssh_exec_internal}}.
#'
#' @details
#' The default value of \code{session = NULL} looks for a \code{session} object
#' in the user workspace. This allows the user to run Condor functions without
#' explicitly specifying the \code{session}.
#'
#' @return A \code{"character"} vector containing the standard output.
#'
#' @author Arni Magnusson.
#'
#' @seealso
#' \code{\link[ssh]{ssh_exec_wait}} runs a command or script and shows the
#' standard output in the R console, while returning the exit status.
#'
#' \code{\link[ssh]{ssh_exec_internal}} runs a command or script and buffers the
#' standard output into a raw vector.
#'
#' \code{\link{condor-package}} gives an overview of the package.
#'
#' @examples
#' \dontrun{
#' session <- ssh_connect("servername")
#'
#' ssh_exec_wait(session, "ls")             # returns 0
#' ssh_exec_internal(session, "ls")$stdout  # returns a raw vector
#' ssh_exec_stdout("ls")                    # returns directory names
#' }
#'
#' @importFrom ssh ssh_exec_internal
#'
#' @export

ssh_exec_stdout <- function(command, session=NULL, ...)
{
  # Look for user session
  if(is.null(session))
    session <- get("session", pos=.GlobalEnv, inherits=FALSE)

  stdout <- ssh_exec_internal(session, command, ...)$stdout
  stdout <- unlist(strsplit(rawToChar(stdout), "\\n"))

  stdout
}
