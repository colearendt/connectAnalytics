#' Run the Shiny Application
#'
#' @param host the host server for the RStudio Connect to be connected to. 
#' Defaults to the environment variable "CONNECT_SERVER"
#' @param api_key a valid RStudio Connect API key. Defaults to the environment
#' variable "CONNECT_API_KEY"
#' @param user the desired user to log in as. If NULL (default) it will default
#' to the session$user (recommended)
#' @param switch_user logical; if TRUE a button appears in the navbar that will 
#' allow users to switch which connect user analytics data they are looking at. 
#' This could be useful if your company wants to allow users to see how others are
#' performing. 
#' @param favicon path to a favicon icon to be used for your application
#' @param title the title of the application to be shown in the dashboard header
#' @param window_title the title of the application to be shown in the browser tab. 
#' If NULL (default) the title value will be used
#' @param header_width Set the width of the header for the shiny application. This is
#' useful in case the title specified is too long for the default width
#' @param ... additional options to be passed to `golem_opts`
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
#' @importFrom graphics text title
#' @importFrom stats time
connectAnalytics <- function(..., host = Sys.getenv("CONNECT_SERVER"), 
                             api_key = Sys.getenv("CONNECT_API_KEY"),
                             user = NULL, switch_user = TRUE, favicon = NULL,
                             title = "connectAnalytics", window_title = NULL, 
                             header_width = 230) {
  golem::with_golem_options(
    app = shiny::shinyApp(ui = ca_ui, server = ca_server), 
    golem_opts = list(host = host, api_key = api_key, user = user, switch_user = switch_user, favicon = favicon,
                      title = title, window_title = window_title, header_width = header_width, ...)
  )
}

