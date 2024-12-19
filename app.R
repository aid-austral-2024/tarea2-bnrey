library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(shiny)
library(bslib)
library(plotly)
library(scales)

## Carga y preparacion de los datos 

indicadores <- read_csv("datos_curados/indicadores_curados.csv", 
                        show_col_types = FALSE)

paises <- unique(indicadores$spatial_dim_es)

# Filtro data hasta la fecha actual (sacando las estimaciones a futuro)

indicadores <- indicadores %>%
  filter(time_dim <= 2024 & time_dim > 1995)


# UI
ui <- page_navbar(
  title = "Indicadores básicos, región de las Américas",
  theme = bs_theme(bootswatch = "cerulean"),
  
  # Primera pestaña - Gráfico de barras y serie temporal
  nav_panel(
    title = "Gráfico de barras y serie temporal",
    fluidPage(
      titlePanel("Gráfico de barras y serie temporal de indicadores básicos por país"),
      fluidRow(
        column(
          width = 12,
          wellPanel(
            selectInput(
              inputId = "nombre_indicador", 
              label = "Selecciona el indicador:", 
              choices = unique(indicadores$nombre_indicador),
              selected = "Mediana de edad (en años)",
              width = "100%"
            )
          )
        )
      ),
      fluidRow(
        column(
          width = 12,
          plotOutput(
            outputId = "barPlot", 
            height = "500px",
            hover = hoverOpts(
              id = "plot_hover",
              delay = 100,
              delayType = "debounce",
              nullOutside = FALSE
            )
          )
        ),
        column(
          width = 12,
          plotOutput(
            outputId = "timeSeriesPlot", 
            height = "300px"
          )
        )
      )
    )
  ),
  
  # Segunda pestaña - Comparación entre países por indicador
  nav_panel(
    title = "Tendencias",
    fluidPage(
      titlePanel("Tendencias indicadores básicos y comparación entre países"),
      
      # Tendencias
      fluidRow(
        column(
          width = 12,
          p("En este gráfico se puede ver la tendencia de los diferentes indicadores en los países de la Región.")
        )
      ),
      
      # Filtros para grafico comparativo
      fluidRow(
        column(
          width = 3,
          selectizeInput(
            inputId = "selected_countries", 
            label = "País",
            choices = NULL, # se actualizara en server
            multiple = TRUE,
            options = list(placeholder = 'Selecciona países')
          )
        ),
        column(
          width = 3,
          selectInput(
            inputId = "selected_indicator", 
            label = "Indicador",
            choices = NULL, # se actualizara en server
            selected = NULL
          )
        )
      ),
      
      # Grafico comparativo
      fluidRow(
        column(
          width = 12,
          plotlyOutput(
            outputId = "comparison_plot", 
            height = "500px"
          )
        )
      )
    )
  )
)

# Server 

server <- function(input, output, session) {
  
### --- PRIMERA PESTAÑA: Gráfico de barras y línea temporal --- ###
  
  # Reactive value para país seleccionado
  selected_country <- reactiveVal(NULL)
  
  # Reactive que contiene todos los datos
  all_data <- reactive({
    indicadores %>%
      filter(nombre_indicador == input$nombre_indicador)
  })
  
  # Reactive que contiene los datos más recientes
  filtered_data <- reactive({
    all_data() %>%
      group_by(spatial_dim_es) %>%
      filter(time_dim == max(time_dim, na.rm = TRUE)) %>%
      ungroup() %>%
      arrange(desc(numeric_value))
  })
  
  # Actualización del país seleccionado cuando se pasa el cursor sobre la barra
  observeEvent(input$plot_hover, {
    hover <- input$plot_hover
    if (is.null(hover)) {
      selected_country(NULL)
      return()
    }
    
    x_pos <- round(hover$x)
    if (x_pos >= 1 && x_pos <= nrow(filtered_data())) {
      country <- filtered_data()$spatial_dim_es[x_pos]
      selected_country(country)
    } else {
      selected_country(NULL)
    }
  })
  
  # Render del gráfico de barras
  output$barPlot <- renderPlot({
    data_recent <- filtered_data()
    valor_referencia <- mean(data_recent$numeric_value, na.rm = TRUE)
    curr_country <- selected_country()
    
    plot_data <- data_recent %>%
      mutate(
        index = seq_len(n()),
        is_highlighted = if (is.null(curr_country)) {
          FALSE
        } else {
          spatial_dim_es == curr_country
        }
      )
    
    ggplot(plot_data, 
           aes(x = factor(index),
               y = numeric_value,
               fill = is_highlighted)) +
      geom_bar(stat = "identity", width = 0.8) +
      geom_text(
        aes(label = round(numeric_value)),
        vjust = -0.5,                         
        size = 3.5, color = "black", fontface = "bold"
      ) +
      scale_x_discrete(labels = plot_data$spatial_dim_es) +
      scale_fill_manual(values = c("steelblue", "orange"), guide = "none") +
      geom_hline(yintercept = valor_referencia, color = "red", linetype = "dashed") +
      annotate("label",
               x = 1,
               y = valor_referencia,
               label = paste("Valor Regional:", round(valor_referencia, 1)),
               color = "red",
               fill = "white",
               alpha = 0.8,
               vjust = -0.5,
               hjust = 0,
               size = 4) +
      labs(title = input$nombre_indicador, x = "País", y = "Valor") +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
  })
  
  # Render del gráfico de serie temporal
  output$timeSeriesPlot <- renderPlot({
    country <- selected_country()
    validate(
      need(!is.null(country), "Pasa el cursor sobre un país para ver su evolución en el tiempo.")
    )
    
    country_data <- all_data() %>%
      filter(spatial_dim_es == country) %>%
      arrange(time_dim)
    
    validate(
      need(nrow(country_data) > 0, "No hay datos disponibles para el país seleccionado.")
    )
    
    ggplot(country_data, aes(x = time_dim, y = numeric_value)) +
      geom_line(color = "steelblue", linewidth = 1) +
      geom_point(color = "steelblue", size = 3) +
      labs(title = country,
           subtitle = paste0("Evolución temporal: ", input$nombre_indicador, 
                             " - Último dato disponible: ", max(country_data$time_dim)),
           x = "Año",
           y = "Valor") +
      theme_minimal()
  })
  
  ### --- SEGUNDA PESTAÑA: Comparación entre países por indicador --- ###
  
  # Actualización dinámica de las opciones en selectInput y selectizeInput
  observe({
    updateSelectizeInput(session, "selected_countries",
                         choices = sort(unique(indicadores$spatial_dim_es)),
                         selected = c("Argentina", "Chile", "Brasil"))
    
    updateSelectInput(session, "selected_indicator",
                      choices = sort(unique(indicadores$nombre_indicador)),
                      selected = "Razón de mortalidad materna estimada (100 000 nv)")
  })
  
  # Gráfico de comparación temporal de países
  output$comparison_plot <- renderPlotly({
    req(input$selected_countries, input$selected_indicator)
    
    # Filtrar datos
    plot_data <- indicadores %>%
      filter(
        spatial_dim_es %in% input$selected_countries,
        nombre_indicador == input$selected_indicator
      ) %>%
      group_by(spatial_dim_es, time_dim) %>%
      summarise(numeric_value = mean(numeric_value, na.rm = TRUE), .groups = 'drop') %>%
      arrange(spatial_dim_es, time_dim)
    
    # Crear el gráfico
    p <- plot_ly() %>%
      layout(
        title = input$selected_indicator,
        xaxis = list(title = "Año"),
        yaxis = list(title = "Valor"),
        showlegend = TRUE
      )
    
    # Añadir líneas por país
    colors <- RColorBrewer::brewer.pal(n = length(input$selected_countries), name = "Set1")
    for (i in seq_along(input$selected_countries)) {
      country_data <- plot_data %>%
        filter(spatial_dim_es == input$selected_countries[i])
      
      p <- p %>% add_trace(
        data = country_data,
        x = ~time_dim, y = ~numeric_value,
        type = 'scatter', mode = 'lines+markers',
        name = input$selected_countries[i],
        line = list(color = colors[i]),
        marker = list(color = colors[i])
      )
    }
    p
  })
}

shinyApp(ui = ui, server = server)
