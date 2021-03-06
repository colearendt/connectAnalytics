# Module UI
  
#' @title   mod_05_usage_ui and mod_05_usage_server 
#' @description  A shiny Module to get the usage for the user defined window 
#' to show them how much their content is being used, when it is being used and 
#' who is using it. 
#'
#' @param id shiny id
#' @param input internal
#' @param output internal
#' @param session internal
#' @param r a reactiveValues object
#'
#' @rdname mod_05_usage
#'
#' @keywords internal
#' @export 
#' @importFrom shiny NS tagList 
mod_05_usage_ui <- function(id, admin = FALSE){
  ns <- NS(id)
  div_id <- ifelse(admin, "admin-tab", "content-tab")
  
  if (admin){
    by_pub_static <- tabPanel(
        title = "By Publisher",
        plotly::plotlyOutput(ns("static_usage_by_owner"))
      )
    
    by_pub_shiny <- tabPanel(
      title = "By Publisher",
      plotly::plotlyOutput(ns("shiny_usage_by_owner"))
    )
    
  } else {
    by_pub_static <- NULL
    by_pub_shiny <- NULL
  }
  
  out <- tagList(
    div(
      id = ns(div_id),
      uiOutput(ns("admin_filters"), inline = TRUE),
      fluidRow(
        shinydashboard::box(
          title = "Overall Content Usage",
          plotly::plotlyOutput(ns("usage_line_graph")),
          width = 12
        )
      ),
      fluidRow(
        shinydashboard::tabBox(
          title = "Shiny Usage",
          tabPanel(
            title = "By Date",
            plotly::plotlyOutput(ns("shiny_usage_by_date")) 
          ),
          tabPanel(
            title = "By User",
            plotly::plotlyOutput(ns("shiny_usage_by_user"))
          ),
          tabPanel(
            title = "By Content",
            plotly::plotlyOutput(ns("shiny_usage_by_content"))
          ),
          by_pub_shiny
          
        ),
        shinydashboard::tabBox(
          title = "Static Usage",
          tabPanel(
            title = "By Date",
            plotly::plotlyOutput(ns("static_usage_by_date"))
          ),
          tabPanel(
            title = "By User",
            plotly::plotlyOutput(ns("static_usage_by_user"))
          ),
          tabPanel(
            title = "By Content",
            plotly::plotlyOutput(ns("static_usage_by_content"))
          ),
          by_pub_static
        )
      ),
      fluidRow(
        shinydashboard::box(
          title = "Continuous App Usage",
          plotly::plotlyOutput(ns("app_user_count_cont"))
        ),
        shinydashboard::box(
          title = "App Runtimes",
          plotly::plotlyOutput(ns("app_run_time"))
        )
      ),
      fluidRow(
        shinydashboard::box(
          title = "Content Usage Information",
          reactable::reactableOutput(ns("full_usage_table")),
          br(),
          div(
            downloadButton(
              outputId = ns("download_usage_table"),
              label = "Download Usage Info",
              class = "btn-primary",
              width = "100%"
            ),
            style = "width:250px;margin:0 auto;"
          ),
          width = 12
        )
      ),
      fluidRow(
        shinydashboard::box(
          title = "Content Timeline",
          timevis::timevisOutput(ns("time_vis_fig")),
          width = 12
        )
      )
    )
  )
  
  if (admin){
    out <- tagList(
      shinyjs::hidden(out), 
      shinyjs::hidden(
        div(
          id = ns("admin-no-access"), 
          h3("You do not have administrator access. Please contact your system admin if this is a mistake"), 
          style = "color:red;width:500px;margin: 0 auto;"
        )
      )
    )
  }
  
  return(out)
}
    
# Module Server
    
#' @rdname mod_05_usage
#' @export
#' @keywords internal
    
mod_05_usage_server <- function(input, output, session, r, admin = FALSE){
  ns <- session$ns
  
  observe({
    req(r$admin)
    if (admin){
      if (!r$admin){
        shiny::hideTab(inputId = "navbar-tabs", target = "Admin")
      }
    }
  }) 

  observe({
    req(r$admin)
    
    if (admin){
      if (r$admin) {
        shinyjs::show("admin-tab")
        shinyjs::hide("admin-no-access")
      } else {
        shinyjs::hide("admin-tab")
        shinyjs::show("admin-no-access")
      }
      
    }
    
  })
  
  
  output$admin_filters <- renderUI({
    if (admin) {
      content_owners <- r$content$owner_username
      names(content_owners) <- paste(r$content$owner_first_name, r$content$owner_last_name) 
      content_owners <- unique(content_owners)
      
      content <- r$content$guid
      names(content) <- r$content$title
      
      users <- r$all_users$guid[!r$all_users$locked]
      names(users) <- paste(r$all_users$first_name[!r$all_users$locked], r$all_users$last_name[!r$all_users$locked])
      users <- c(users, "Anonymous" = "Anonymous")
      
      out <- tagList(
        fluidRow(
          column(
            width = 4,
            selectizeInput(
              inputId = ns("filter_owner"),
              label = "Exclude Content Owners",
              choices = c("Select Content Owners to Exclude" = "", content_owners),
              selected = "",
              multiple = TRUE,
              width = "100%"
            )
          ),
          column(
            width = 4,
            selectizeInput(
              inputId = ns("filter_content"),
              label = "Exclude Content",
              choices = c("Select Content Owners to Exclude" = "", content),
              selected = "",
              multiple = TRUE,
              width = "100%"
            )
          ),
          column(
            width = 4,
            selectizeInput(
              inputId = ns("filter_viewer"),
              label = "Exclude Viewers",
              choices = c("Select Content Owners to Exclude" = "", users),
              selected = "",
              multiple = TRUE,
              width = "100%"
            )
          )
        )
      )
    } else {
      
      content <- r$user_content$guid
      names(content) <- r$user_content$title
      
      users <- r$all_users$guid[!r$all_users$locked]
      names(users) <- paste(r$all_users$first_name[!r$all_users$locked], r$all_users$last_name[!r$all_users$locked])
      users <- c(users, "Anonymous" = "Anonymous")
      
      out <- tagList(
        fluidRow(
          column(
            width = 6,
            selectizeInput(
              inputId = ns("filter_content"),
              label = "Exclude Content",
              choices = c("Select Content Owners to Exclude" = "", content),
              selected = "",
              multiple = TRUE,
              width = "100%"
            )
          ),
          column(
            width = 6,
            selectizeInput(
              inputId = ns("filter_viewer"),
              label = "Exclude Viewers",
              choices = c("Select Content Owners to Exclude" = "", users),
              selected = "",
              multiple = TRUE,
              width = "100%"
            )
          )
        )
      )
    }
    
    
    
    return(out)
  })
  
  outputOptions(output, "admin_filters", suspendWhenHidden = FALSE, priority = 10)
  
  # usage data is initially queried in the mod_04_content.R module
  overall_usage <- reactive({
    if (admin){
      req(r$shiny_usage_all, r$static_usage_all, r$username, r$admin)
      shiny_usage <- r$shiny_usage_all
      static_usage <- r$static_usage_all
      
      if (!is.null(input$filter_owner)){
        if (input$filter_owner != ''){
          owner_guids <- r$content$guid[r$content$owner_username == input$filter_owner]
          shiny_usage <- dplyr::filter(shiny_usage, !content_guid %in% owner_guids)
          static_usage <- dplyr::filter(static_usage, !content_guid %in% owner_guids)
        }
      }
      
      if (!is.null(input$filter_content)){
        if (input$filter_content != ""){
          shiny_usage <- dplyr::filter(shiny_usage, !content_guid %in% input$filter_content)
          static_usage <- dplyr::filter(static_usage, !content_guid %in% input$filter_content)
        }
      }
      
      if (!is.null(input$filter_viewer)){
        if (input$filter_viewer != ""){
          
          if ("Anonymous" %in% input$filter_viewer){
            shiny_usage <- dplyr::filter(shiny_usage, !is.na(user_guid))
            static_usage <- dplyr::filter(static_usage, !is.na(user_guid))
          }
          
          shiny_usage <- dplyr::filter(shiny_usage, !user_guid %in% input$filter_viewer)
          static_usage <- dplyr::filter(static_usage, !user_guid %in% input$filter_viewer)
        }
      }
    } else {
      req(r$shiny_usage, r$static_usage, r$username)
      shiny_usage <- r$shiny_usage
      static_usage <- r$static_usage
      
      if (!is.null(input$filter_content)){
        if (input$filter_content != ""){
          shiny_usage <- dplyr::filter(shiny_usage, !content_guid %in% input$filter_content)
          static_usage <- dplyr::filter(static_usage, !content_guid %in% input$filter_content)
        }
      }
      
      if (!is.null(input$filter_viewer)){
        if (input$filter_viewer != ""){
          if ("Anonymous" %in% input$filter_viewer){
            shiny_usage <- dplyr::filter(shiny_usage, !is.na(user_guid))
            static_usage <- dplyr::filter(static_usage, !is.na(user_guid))
          }
          
          shiny_usage <- dplyr::filter(shiny_usage, !user_guid %in% input$filter_viewer)
          static_usage <- dplyr::filter(static_usage, !user_guid %in% input$filter_viewer)
        }
      }
    }
    
    out <- overall_usage_tbl(shiny_usage, static_usage, from = r$from, to = r$to)
    
    
    
    return(out)
  })
  
  # usage_shared <- crosstalk::SharedData$new(overall_usage)
  
  output$usage_line_graph <- plotly::renderPlotly({
    req(overall_usage())

    # This is defined in R/golem_utils_server.R
    overall_usage_line(overall_usage(), from = r$from, to = r$to, username = r$username, admin = admin)
  })
  
  # user_date_range <- reactive({
  #   df <- usage_shared$data(withSelection = TRUE) %>%
  #     dplyr::filter(selected_ | is.na(selected_))
  #   
  #   if (all(is.na(df$selected_))){
  #     out <- list(from = r$from, to = r$to)
  #   } else {
  #     out <- list(from = min(df$date), to = max(r$date))
  #   }
  #   
  #   return(out)
  # })


  usage_shiny <- reactive({
    if (admin){
      req(r$shiny_usage_all, r$content, r$all_users, r$admin)
      shiny_usage <- r$shiny_usage_all
      content <- r$content
    } else {
      req(r$shiny_usage, r$user_content, r$all_users)
      shiny_usage <- r$shiny_usage
      content <- r$user_content
    }
    
    # shiny_usage <- dplyr::filter(shiny_usage, started >= user_date_range()$from, started <= user_date_range()$to)


    out <- usage_info_join(shiny_usage, content, r$all_users)
    
    if (admin){
      if (!is.null(input$filter_owner)){
        if (input$filter_owner != ''){
          out <- dplyr::filter(out, !owner_username %in% input$filter_owner)
        }
      }
      
      if (!is.null(input$filter_content)){
        if (input$filter_content != ""){
          out <- dplyr::filter(out, !content_guid %in% input$filter_content)
        }
      }
      
      if (!is.null(input$filter_viewer)){
        if (input$filter_viewer != ""){
          if ("Anonymous" %in% input$filter_viewer){
            out <- dplyr::filter(out, !is.na(user_guid))
          }
          out <- dplyr::filter(out, !user_guid %in% input$filter_viewer)
        }
      }
    } else {
      if (!is.null(input$filter_content)){
        if (input$filter_content != ""){
          out <- dplyr::filter(out, !content_guid %in% input$filter_content)
        }
      }
      
      if (!is.null(input$filter_viewer)){
        if (input$filter_viewer != ""){
          if ("Anonymous" %in% input$filter_viewer){
            out <- dplyr::filter(out, !is.na(user_guid))
          }
          out <- dplyr::filter(out, !user_guid %in% input$filter_viewer)
        }
      }
    }
    
    return(out)
  })

  usage_static <- reactive({
    if (admin){
      req(r$static_usage_all, r$content, r$all_users, r$admin)
      static_usage <- r$static_usage_all
      content <- r$content
    } else {
      req(r$static_usage, r$user_content, r$all_users)
      static_usage <- r$static_usage
      content <- r$user_content
    }

    # static_usage <- dplyr::filter(static_usage, time >= user_date_range()$from, time <= user_date_range()$to)
    
    out <- usage_info_join(static_usage, content, r$all_users)
    
    if (admin){
      if (!is.null(input$filter_owner)){
        if (input$filter_owner != ''){
          out <- dplyr::filter(out, !owner_username %in% input$filter_owner)
        }
      }
      
      if (!is.null(input$filter_content)){
        if (input$filter_content != ""){
          out <- dplyr::filter(out, !content_guid %in% input$filter_content)
        }
      }
      
      if (!is.null(input$filter_viewer)){
        if (input$filter_viewer != ""){
          if ("Anonymous" %in% input$filter_viewer){
            out <- dplyr::filter(out, !is.na(user_guid))
          }
          out <- dplyr::filter(out, !user_guid %in% input$filter_viewer)
        }
      }
    } else {
      if (!is.null(input$filter_content)){
        if (input$filter_content != ""){
          out <- dplyr::filter(out, !content_guid %in% input$filter_content)
        }
      }
      
      if (!is.null(input$filter_viewer)){
        if (input$filter_viewer != ""){
          if ("Anonymous" %in% input$filter_viewer){
            out <- dplyr::filter(out, !is.na(user_guid))
          }
          out <- dplyr::filter(out, !user_guid %in% input$filter_viewer)
        }
      }
    }
    
    return(out)
  })

  output$shiny_usage_by_date <- plotly::renderPlotly({
    req(usage_shiny())
    # browser()
    usage_by_date(usage_shiny(), time_col = "started", from = r$from, to = r$to, type = "Shiny App")

  })


  output$shiny_usage_by_user <- plotly::renderPlotly({
    req(usage_shiny())

    usage_by_user(usage_shiny(), type = "Shiny App")
  })
  
  output$shiny_usage_by_content <- plotly::renderPlotly({
    req(usage_shiny())
    
    usage_by_content(usage_shiny(), type = "Shiny App")
  })
  
  output$shiny_usage_by_owner <- plotly::renderPlotly({
    req(usage_shiny())
    
    # if (!admin) return(NULL)
    usage_by_owner(usage_shiny(), type = "Shiny App")
  })
  
  observe({
    
    shinyjs::show("by-publisher")
    
  })
  
  
  outputOptions(output, "shiny_usage_by_date", suspendWhenHidden = FALSE)
  outputOptions(output, "shiny_usage_by_content", suspendWhenHidden = FALSE)
  outputOptions(output, "shiny_usage_by_user", suspendWhenHidden = FALSE)
  outputOptions(output, "shiny_usage_by_owner", suspendWhenHidden = FALSE)

  output$static_usage_by_date <- plotly::renderPlotly({
    req(usage_static())

    usage_by_date(usage_static(), time_col = "time", from = r$from, to = r$to, type = "Static Content")
  })

  output$static_usage_by_user <- plotly::renderPlotly({
    req(usage_static())

    usage_by_user(usage_static(), type = "Static Content")
  })
  
  output$static_usage_by_content <- plotly::renderPlotly({
    req(usage_static())
    
    usage_by_content(usage_static(), type = "Static Content")
  })
  
  output$static_usage_by_owner <- plotly::renderPlotly({
    req(usage_static())
    
    usage_by_owner(usage_static(), type = "Static Content")
  })
  
  outputOptions(output, "static_usage_by_date", suspendWhenHidden = FALSE)
  outputOptions(output, "static_usage_by_content", suspendWhenHidden = FALSE)
  outputOptions(output, "static_usage_by_user", suspendWhenHidden = FALSE)
  outputOptions(output, "static_usage_by_owner", suspendWhenHidden = FALSE)
  
  output$app_user_count_cont <- plotly::renderPlotly({
    req(usage_shiny())
    
    usage_shiny() %>% 
      tidyr::pivot_longer(cols = c(started, ended), names_to = "name", values_to = "datetime", values_drop_na = TRUE) %>% 
      dplyr::arrange(datetime) %>% 
      dplyr::mutate(user_count = ifelse(name == "started", 1, -1), 
                    user_count = cumsum(user_count),
                    text = glue::glue("Datetime: {format(datetime, '%b %d, %Y %H:%M:%S')}<br>User Count: {user_count}")) %>% 
      plotly::plot_ly(
        x = ~datetime,
        y = ~user_count,
        hoverinfo = "text",
        text = ~text,
        type = "scatter",
        mode = "lines",
        line = list(shape = "hv")
      ) %>% 
      plotly::layout(
        yaxis = list(title = "User Count"),
        xaxis = list(title = ""),
        title = "Continuous Shiny User Count"
      )
    
  })
  
  output$app_run_time <- plotly::renderPlotly({
    req(usage_shiny())
    
    app_run_time_tbl <- usage_shiny() %>% 
      dplyr::mutate(app_time = difftime(ended, started, units = "mins")) %>%
      dplyr::mutate(
        title = factor(title, levels = unique(title)),
        title = forcats::fct_reorder(title, app_time, .fun = mean),
        app_time = round(as.numeric(app_time), 2)
      ) 
    
    app_run_time_tbl %>% 
      plotly::plot_ly(
        x = ~app_time,
        y = ~title,
        type = "box"
      ) %>% 
      plotly::layout(
        yaxis = list(title = ""),
        xaxis = list(title = "Application Run Time (minutes)", 
                     range = c(-2, max(app_run_time_tbl$app_time) + 10)),
        title = "Distribution of Application Run Time"
      )
  })
  
  output$time_vis_fig <- timevis::renderTimevis({
    req(usage_shiny(), usage_static())
    
    usage_shiny() %>% 
      dplyr::mutate(content = title,
                    id = paste0("shiny-", id),
                    title = glue::glue("{title}", "User: {username}", "Started: {format(started, '%b %d, %Y %H:%M:%S')}", "Ended: {format(ended, '%b %d, %Y %H:%M:%S')}", .sep = "\n")) %>% 
      dplyr::select(start = started, end = ended, content, title) %>% 
      dplyr::bind_rows({
        usage_static() %>% 
          dplyr::mutate(content = title,
                        id = paste0("static-", id),
                        title = glue::glue("{title}", "User: {username}", "Time: {format(time, '%b %d, %Y %H:%M:%S')}", .sep = "\n")) %>% 
          dplyr::select(start = time, content, title)
      }) %>% 
      timevis::timevis(
        options = list(
          start = r$from,
          end = r$to,
          orientation = "both",
          selectable = "true",
          tooltip = list(
            delay = 100
          )
        )
      )
  })
  
  
  full_usage_dat <- reactive({
    req(usage_shiny(), usage_static())
    
    out <- usage_shiny() %>% 
      dplyr::mutate(content_type = "Shiny App") %>% 
      dplyr::select(content_type, title, owner_username, username, first_name, last_name, started, ended) %>% 
      dplyr::bind_rows(
        usage_static() %>% 
          dplyr::mutate(content_type = "Static Content") %>% 
          dplyr::select(content_type, title, owner_username, username, first_name, last_name, started = time) 
      ) %>% 
      dplyr::arrange(desc(started))
    
    return(out)
  })
  
  output$full_usage_table <- reactable::renderReactable({
    req(full_usage_dat())
    
   
    
    reactable::reactable(
      full_usage_dat(), 
      columns = list(
        content_type = reactable::colDef("Content Type"),
        title = reactable::colDef("Content Title"),
        owner_username = reactable::colDef("Content Owner"),
        username = reactable::colDef("Viewer Username"),
        first_name = reactable::colDef("Viewer First Name"),
        last_name = reactable::colDef("Viewer Last Name"),
        started = reactable::colDef("Time Started", cell = function(value){format(value, "%b %d, %Y %H:%M:%S")}),
        ended = reactable::colDef("Time Ended", cell = function(value){format(value, "%b %d, %Y %H:%M:%S")})
      ),
      class = "usage-table",
      filterable = TRUE,
      sortable = TRUE
    )
  })
  
  output$download_usage_table <- downloadHandler(
    filename = function(){
      paste0("connect-usage-", Sys.Date(), ".csv")
    },
    content = function(file){
      write.csv(full_usage_dat(), file, row.names = FALSE)
    }
  )
  
  outputOptions(output, "app_user_count_cont", suspendWhenHidden = FALSE)
  outputOptions(output, "app_run_time", suspendWhenHidden = FALSE)
  outputOptions(output, "time_vis_fig", suspendWhenHidden = FALSE)
  outputOptions(output, "full_usage_table", suspendWhenHidden = FALSE)
  
  
}
    
## To be copied in the UI
# mod_05_usage_ui("05_usage_ui_1")
    
## To be copied in the server
# callModule(mod_05_usage_server, "05_usage_ui_1")
 
