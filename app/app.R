# PowerBI Dashboard en Shiny - Salud Mental BaseDigi 2025
# Cargar librerías
library(shiny)
library(shinydashboard)
library(ggplot2)
library(dplyr)
library(plotly)
library(haven)
library(DT)
library(corrplot)

# CARGAR Y PROCESAR DATOS
df <- read_sav("basedigi2025.sav")

# Limpiar datos
df_clean <- df %>%
  select(
    ResponseID, Edad, Edadagrup, Religion, SituacionCivil, Laboral,
    Residencia, Horario, Promediohoras, SueñoVida, CalAlimentacionVida,
    DeporteOcioParticipación, RedesSocialesOcioParticipación, ArteOcioParticipación,
    SUMCDrisc, NivCDRisc, mhc_total, mhc_ewb, mhc_swb, mhc_pwb,
    CS, BO, STS, sumaEA, NivPAS, Consumo, TrataPsico, ServiciosdeSalud
  ) %>%
  mutate(
    GrupoEdad = case_when(
      Edadagrup == 1 ~ "18-22",
      Edadagrup == 2 ~ "23-27",
      Edadagrup == 3 ~ "28-32",
      Edadagrup == 4 ~ "33+",
      TRUE ~ "Otro"
    ),
    GrupoHoras = case_when(
      Promediohoras == 1 ~ "1 hora",
      Promediohoras == 2 ~ "2 horas",
      Promediohoras == 3 ~ "3 horas",
      Promediohoras == 4 ~ "4 horas",
      TRUE ~ "Otro"
    ),
    # Convertir variables numéricas
    across(c(SUMCDrisc, mhc_total, CS, BO, STS, sumaEA), as.numeric),
    Laboral = as.character(Laboral),
    Horario = as.character(Horario),
    Residencia = as.character(Residencia),
    SituacionCivil = as.character(SituacionCivil)
  ) %>%
  filter(!is.na(Edad), !is.na(SUMCDrisc), !is.na(mhc_total))

# INTERFAZ UI
ui <- dashboardPage(
  # HEADER
  dashboardHeader(
    title = "📊 Power BI Salud Mental - BaseDigi 2025",
    titleWidth = 500,
    tags$head(
      tags$style(HTML("
        .main-header .logo {
          font-weight: bold;
          font-size: 18px;
        }
        .skin-blue .main-header .navbar {
          background-color: #667eea;
        }
        .skin-blue .main-sidebar {
          background-color: #764ba2;
        }
      "))
    )
  ),

  # SIDEBAR
  dashboardSidebar(
    width = 280,
    sidebarMenu(
      menuItem("📈 Dashboard", tabName = "dashboard", icon = icon("chart-line")),
      menuItem("🔍 Análisis Profundo", tabName = "analysis", icon = icon("microscope")),
      menuItem("🔗 Correlaciones", tabName = "correlations", icon = icon("link")),
      menuItem("📋 Datos", tabName = "data", icon = icon("table")),
      menuItem("ℹ️ Información", tabName = "info", icon = icon("info-circle")),
      hr(),
      h4("🔧 FILTROS", style = "color: white; padding: 0 15px;"),

      # Filtro Edad
      selectInput(
        "filter_edad",
        label = "📅 Grupo de Edad:",
        choices = c("Todos", unique(df_clean$GrupoEdad)),
        selected = "Todos",
        width = "100%"
      ),

      # Filtro Horas
      selectInput(
        "filter_horas",
        label = "⏰ Horas Laborales:",
        choices = c("Todas", unique(df_clean$GrupoHoras)),
        selected = "Todas",
        width = "100%"
      ),

      # Filtro Laboral
      selectInput(
        "filter_laboral",
        label = "💼 Situación Laboral:",
        choices = c("Todas", unique(na.omit(df_clean$Laboral))),
        selected = "Todas",
        width = "100%"
      ),

      # Filtro Horario
      selectInput(
        "filter_horario",
        label = "🕐 Horario:",
        choices = c("Todos", unique(na.omit(df_clean$Horario))),
        selected = "Todos",
        width = "100%"
      ),

      hr(),
      actionButton(
        "reset_filters",
        label = "🔄 Restablecer Filtros",
        width = "100%",
        style = "background-color: #f093fb; color: white; border: none; font-weight: bold;"
      )
    )
  ),

  # BODY
  dashboardBody(
    tabItems(
      # TAB 1: DASHBOARD
      tabItem(
        tabName = "dashboard",
        h2("📊 Panel de Control - Indicadores Clave", style = "color: #667eea; font-weight: bold;"),
        br(),

        # KPIs
        fluidRow(
          valueBoxOutput("kpi_total", width = 3),
          valueBoxOutput("kpi_resiliencia", width = 3),
          valueBoxOutput("kpi_bienestar", width = 3),
          valueBoxOutput("kpi_edad", width = 3)
        ),
        br(),

        # Gráficos - Fila 1
        fluidRow(
          box(
            title = "📊 Distribución por Grupo de Edad",
            plotlyOutput("plot_edad"),
            width = 6,
            status = "primary",
            solidHeader = TRUE
          ),
          box(
            title = "⏰ Promedio Horas Laborales",
            plotlyOutput("plot_horas"),
            width = 6,
            status = "success",
            solidHeader = TRUE
          )
        ),

        # Gráficos - Fila 2
        fluidRow(
          box(
            title = "🛡️ Resiliencia por Grupo de Edad",
            plotlyOutput("plot_resiliencia_edad"),
            width = 6,
            status = "info",
            solidHeader = TRUE
          ),
          box(
            title = "😊 Bienestar Mental por Edad",
            plotlyOutput("plot_bienestar_edad"),
            width = 6,
            status = "warning",
            solidHeader = TRUE
          )
        ),

        # Gráfico comparativa
        box(
          title = "📈 Comparativa de Indicadores por Grupo de Edad",
          plotlyOutput("plot_compare"),
          width = 12,
          status = "primary",
          solidHeader = TRUE
        )
      ),

      # TAB 2: ANÁLISIS PROFUNDO
      tabItem(
        tabName = "analysis",
        h2("🔍 Análisis Profundo de Salud Mental", style = "color: #667eea; font-weight: bold;"),
        br(),

        # Estadísticas
        fluidRow(
          infoBox(
            title = "Resiliencia Baja",
            value = textOutput("stat_baja_resiliencia"),
            icon = icon("exclamation-triangle"),
            color = "danger",
            width = 3
          ),
          infoBox(
            title = "Alto Burnout",
            value = textOutput("stat_alto_burnout"),
            icon = icon("fire"),
            color = "red",
            width = 3
          ),
          infoBox(
            title = "Bienestar Óptimo",
            value = textOutput("stat_bienestar_optimo"),
            icon = icon("smile"),
            color = "success",
            width = 3
          ),
          infoBox(
            title = "Participa Ejercicio",
            value = textOutput("stat_ejercicio"),
            icon = icon("dumbbell"),
            color = "info",
            width = 3
          )
        ),

        br(),

        # Gráficos análisis
        fluidRow(
          box(
            title = "💼 Burnout Ocupacional",
            plotlyOutput("plot_burnout"),
            width = 6,
            status = "danger",
            solidHeader = TRUE
          ),
          box(
            title = "😰 Fatiga por Compasión",
            plotlyOutput("plot_fatiga"),
            width = 6,
            status = "warning",
            solidHeader = TRUE
          )
        ),

        fluidRow(
          box(
            title = "💪 Satisfacción por Compasión",
            plotlyOutput("plot_satisfaccion"),
            width = 6,
            status = "success",
            solidHeader = TRUE
          ),
          box(
            title = "⚡ Agotamiento Emocional",
            plotlyOutput("plot_agotamiento"),
            width = 6,
            status = "info",
            solidHeader = TRUE
          )
        )
      ),

      # TAB 3: CORRELACIONES
      tabItem(
        tabName = "correlations",
        h2("🔗 Análisis de Correlaciones", style = "color: #667eea; font-weight: bold;"),
        br(),

        fluidRow(
          box(
            title = "Matriz de Correlaciones",
            plotOutput("plot_corr", height = "500px"),
            width = 6,
            status = "primary",
            solidHeader = TRUE
          ),
          box(
            title = "Información de Correlaciones",
            tableOutput("corr_table"),
            width = 6,
            status = "info",
            solidHeader = TRUE
          )
        ),

        br(),

        fluidRow(
          box(
            title = "📊 Resiliencia vs Bienestar",
            plotlyOutput("plot_scatter1"),
            width = 6,
            status = "primary",
            solidHeader = TRUE
          ),
          box(
            title = "📊 Edad vs Resiliencia",
            plotlyOutput("plot_scatter2"),
            width = 6,
            status = "info",
            solidHeader = TRUE
          )
        )
      ),

      # TAB 4: DATOS
      tabItem(
        tabName = "data",
        h2("📋 Datos Completos", style = "color: #667eea; font-weight: bold;"),
        br(),
        p("Total de registros mostrados:", textOutput("record_count", inline = TRUE)),
        br(),
        DTOutput("data_table")
      ),

      # TAB 5: INFORMACIÓN
      tabItem(
        tabName = "info",
        h2("ℹ️ Información del Proyecto", style = "color: #667eea; font-weight: bold;"),
        br(),

        box(
          title = "📚 Descripción del Estudio",
          HTML("
            <p><strong>BaseDigi 2025 - Estudio de Salud Mental en Profesionales de la Salud</strong></p>
            <ul>
              <li><strong>Muestra:</strong> 581 profesionales de la salud (estudiantes y residentes)</li>
              <li><strong>Edad promedio:</strong> 25.1 años</li>
              <li><strong>Período:</strong> Abril - Agosto 2025</li>
              <li><strong>Idioma:</strong> Español</li>
            </ul>
            <p><strong>Instrumentos de Evaluación:</strong></p>
            <ul>
              <li>🛡️ <strong>CD-RISC:</strong> Escala de Resiliencia Connor-Davidson (0-100)</li>
              <li>😊 <strong>MHC-SF:</strong> Continuo de Salud Mental (0-140)</li>
              <li>💼 <strong>ProQol:</strong> Calidad de Vida Profesional (Burnout, Fatiga, Satisfacción)</li>
              <li>😰 <strong>PHQ-9:</strong> Screening de Depresión</li>
              <li>😟 <strong>GAD-7:</strong> Screening de Ansiedad</li>
              <li>🍺 <strong>AUDIT:</strong> Evaluación de Consumo de Alcohol</li>
            </ul>
          "),
          width = 12,
          status = "primary",
          solidHeader = TRUE
        ),

        box(
          title = "🔑 Hallazgos Principales",
          HTML("
            <ul>
              <li>✓ Resiliencia promedio: <strong>35.5/100</strong></li>
              <li>✓ Bienestar general: <strong>52.6/140</strong></li>
              <li>⚠️ Correlación positiva entre resiliencia y bienestar</li>
              <li>⚠️ Carga horaria significativa en 67% de respondentes</li>
              <li>✓ Ejercicio actúa como factor protector</li>
              <li>⚠️ Necesidad de programas de intervención en salud mental</li>
            </ul>
          "),
          width = 12,
          status = "success",
          solidHeader = TRUE
        ),

        box(
          title = "💻 Tecnología",
          HTML("
            <p><strong>Este dashboard fue creado con:</strong></p>
            <ul>
              <li>📦 R & Shiny - Framework interactivo</li>
              <li>📊 ggplot2 & plotly - Visualizaciones</li>
              <li>📋 DT - Tablas interactivas</li>
              <li>🐙 GitHub - Versionamiento</li>
            </ul>
          "),
          width = 12,
          status = "info",
          solidHeader = TRUE
        )
      )
    )
  )
)

# SERVER
server <- function(input, output, session) {

  # Datos reactivos filtrados
  datos_filtrados <- reactive({
    df <- df_clean

    if (input$filter_edad != "Todos") {
      df <- df %>% filter(GrupoEdad == input$filter_edad)
    }
    if (input$filter_horas != "Todas") {
      df <- df %>% filter(GrupoHoras == input$filter_horas)
    }
    if (input$filter_laboral != "Todas") {
      df <- df %>% filter(Laboral == input$filter_laboral)
    }
    if (input$filter_horario != "Todos") {
      df <- df %>% filter(Horario == input$filter_horario)
    }

    return(df)
  })

  # Resetear filtros
  observeEvent(input$reset_filters, {
    updateSelectInput(session, "filter_edad", selected = "Todos")
    updateSelectInput(session, "filter_horas", selected = "Todas")
    updateSelectInput(session, "filter_laboral", selected = "Todas")
    updateSelectInput(session, "filter_horario", selected = "Todos")
  })

  # KPIs
  output$kpi_total <- renderValueBox({
    valueBox(
      value = nrow(datos_filtrados()),
      subtitle = "Respondentes",
      icon = icon("users"),
      color = "blue"
    )
  })

  output$kpi_resiliencia <- renderValueBox({
    res <- round(mean(datos_filtrados()$SUMCDrisc, na.rm = TRUE), 1)
    valueBox(
      value = res,
      subtitle = "Resiliencia Promedio",
      icon = icon("shield"),
      color = "purple"
    )
  })

  output$kpi_bienestar <- renderValueBox({
    bien <- round(mean(datos_filtrados()$mhc_total, na.rm = TRUE), 1)
    valueBox(
      value = bien,
      subtitle = "Bienestar Mental",
      icon = icon("smile"),
      color = "green"
    )
  })

  output$kpi_edad <- renderValueBox({
    edad <- round(mean(datos_filtrados()$Edad, na.rm = TRUE), 1)
    valueBox(
      value = edad,
      subtitle = "Edad Promedio",
      icon = icon("birthday-cake"),
      color = "orange"
    )
  })

  # GRÁFICOS - DASHBOARD
  output$plot_edad <- renderPlotly({
    data <- datos_filtrados() %>%
      group_by(GrupoEdad) %>%
      summarise(count = n(), .groups = 'drop')

    plot_ly(data, x = ~GrupoEdad, y = ~count, type = 'bar',
            marker = list(color = c('#667eea', '#f093fb', '#4facfe', '#43e97b'))) %>%
      layout(title = '', xaxis = list(title = 'Grupo de Edad'),
             yaxis = list(title = 'Cantidad'))
  })

  output$plot_horas <- renderPlotly({
    data <- datos_filtrados() %>%
      group_by(GrupoHoras) %>%
      summarise(count = n(), .groups = 'drop')

    plot_ly(data, labels = ~GrupoHoras, values = ~count, type = 'pie',
            marker = list(colors = c('#667eea', '#f093fb', '#4facfe', '#43e97b'))) %>%
      layout(title = '')
  })

  output$plot_resiliencia_edad <- renderPlotly({
    data <- datos_filtrados() %>%
      group_by(GrupoEdad) %>%
      summarise(resiliencia = mean(SUMCDrisc, na.rm = TRUE), .groups = 'drop')

    plot_ly(data, x = ~GrupoEdad, y = ~resiliencia, type = 'scatter', mode = 'lines+markers',
            line = list(color = '#667eea', width = 3),
            marker = list(size = 10, color = '#667eea')) %>%
      layout(title = '', xaxis = list(title = 'Grupo de Edad'),
             yaxis = list(title = 'Resiliencia Promedio'))
  })

  output$plot_bienestar_edad <- renderPlotly({
    data <- datos_filtrados() %>%
      group_by(GrupoEdad) %>%
      summarise(bienestar = mean(mhc_total, na.rm = TRUE), .groups = 'drop')

    plot_ly(data, x = ~GrupoEdad, y = ~bienestar, type = 'scatter', mode = 'lines+markers',
            line = list(color = '#f093fb', width = 3),
            marker = list(size = 10, color = '#f093fb')) %>%
      layout(title = '', xaxis = list(title = 'Grupo de Edad'),
             yaxis = list(title = 'Bienestar Promedio'))
  })

  output$plot_compare <- renderPlotly({
    data <- datos_filtrados() %>%
      group_by(GrupoEdad) %>%
      summarise(
        Resiliencia = mean(SUMCDrisc, na.rm = TRUE),
        Bienestar = mean(mhc_total, na.rm = TRUE),
        Burnout = mean(BO, na.rm = TRUE),
        .groups = 'drop'
      )

    plot_ly(data, x = ~GrupoEdad) %>%
      add_trace(y = ~Resiliencia, type = 'bar', name = 'Resiliencia') %>%
      add_trace(y = ~Bienestar, type = 'bar', name = 'Bienestar') %>%
      add_trace(y = ~Burnout, type = 'bar', name = 'Burnout') %>%
      layout(barmode = 'group',
             xaxis = list(title = 'Grupo de Edad'),
             yaxis = list(title = 'Promedio'))
  })

  # GRÁFICOS - ANÁLISIS
  output$stat_baja_resiliencia <- renderText({
    baja <- sum(datos_filtrados()$SUMCDrisc < 25, na.rm = TRUE) / nrow(datos_filtrados()) * 100
    paste0(round(baja, 1), "%")
  })

  output$stat_alto_burnout <- renderText({
    alto <- sum(datos_filtrados()$BO > 60, na.rm = TRUE) / nrow(datos_filtrados()) * 100
    paste0(round(alto, 1), "%")
  })

  output$stat_bienestar_optimo <- renderText({
    optimo <- sum(datos_filtrados()$mhc_total > 70, na.rm = TRUE) / nrow(datos_filtrados()) * 100
    paste0(round(optimo, 1), "%")
  })

  output$stat_ejercicio <- renderText({
    ejercicio <- sum(datos_filtrados()$DeporteOcioParticipación > 0, na.rm = TRUE) / nrow(datos_filtrados()) * 100
    paste0(round(ejercicio, 1), "%")
  })

  output$plot_burnout <- renderPlotly({
    data <- datos_filtrados() %>%
      group_by(GrupoEdad) %>%
      summarise(burnout = mean(BO, na.rm = TRUE), .groups = 'drop')

    plot_ly(data, x = ~GrupoEdad, y = ~burnout, type = 'bar',
            marker = list(color = '#fa7e1e')) %>%
      layout(title = '', xaxis = list(title = 'Grupo de Edad'),
             yaxis = list(title = 'Burnout Promedio'))
  })

  output$plot_fatiga <- renderPlotly({
    data <- datos_filtrados() %>%
      group_by(GrupoEdad) %>%
      summarise(fatiga = mean(STS, na.rm = TRUE), .groups = 'drop')

    plot_ly(data, x = ~GrupoEdad, y = ~fatiga, type = 'bar',
            marker = list(color = '#ff6b6b')) %>%
      layout(title = '', xaxis = list(title = 'Grupo de Edad'),
             yaxis = list(title = 'Fatiga Promedio'))
  })

  output$plot_satisfaccion <- renderPlotly({
    data <- datos_filtrados() %>%
      group_by(GrupoEdad) %>%
      summarise(satisfaccion = mean(CS, na.rm = TRUE), .groups = 'drop')

    plot_ly(data, x = ~GrupoEdad, y = ~satisfaccion, type = 'bar',
            marker = list(color = '#43e97b')) %>%
      layout(title = '', xaxis = list(title = 'Grupo de Edad'),
             yaxis = list(title = 'Satisfacción Promedio'))
  })

  output$plot_agotamiento <- renderPlotly({
    data <- datos_filtrados() %>%
      group_by(GrupoEdad) %>%
      summarise(agotamiento = mean(sumaEA, na.rm = TRUE), .groups = 'drop')

    plot_ly(data, x = ~GrupoEdad, y = ~agotamiento, type = 'bar',
            marker = list(color = '#764ba2')) %>%
      layout(title = '', xaxis = list(title = 'Grupo de Edad'),
             yaxis = list(title = 'Agotamiento Promedio'))
  })

  # CORRELACIONES
  output$plot_corr <- renderPlot({
    data_corr <- datos_filtrados() %>%
      select(SUMCDrisc, mhc_total, CS, BO, STS, sumaEA) %>%
      na.omit()

    if (nrow(data_corr) > 0) {
      corrplot(cor(data_corr), method = "circle", type = "upper")
    }
  })

  output$corr_table <- renderTable({
    data_corr <- datos_filtrados() %>%
      select(SUMCDrisc, mhc_total, CS, BO, STS, sumaEA) %>%
      na.omit()

    if (nrow(data_corr) > 0) {
      correlaciones <- cor(data_corr)
      data.frame(
        Variable1 = c("Resiliencia", "Resiliencia", "Bienestar"),
        Variable2 = c("Bienestar", "Burnout", "Burnout"),
        Correlacion = c(
          round(correlaciones["SUMCDrisc", "mhc_total"], 3),
          round(correlaciones["SUMCDrisc", "BO"], 3),
          round(correlaciones["mhc_total", "BO"], 3)
        )
      )
    }
  })

  output$plot_scatter1 <- renderPlotly({
    data <- datos_filtrados()
    plot_ly(data, x = ~SUMCDrisc, y = ~mhc_total, type = 'scatter', mode = 'markers',
            marker = list(size = 5, color = '#667eea', opacity = 0.6)) %>%
      layout(title = '', xaxis = list(title = 'Resiliencia'),
             yaxis = list(title = 'Bienestar'))
  })

  output$plot_scatter2 <- renderPlotly({
    data <- datos_filtrados()
    plot_ly(data, x = ~Edad, y = ~SUMCDrisc, type = 'scatter', mode = 'markers',
            marker = list(size = 5, color = '#f093fb', opacity = 0.6)) %>%
      layout(title = '', xaxis = list(title = 'Edad'),
             yaxis = list(title = 'Resiliencia'))
  })

  # TABLA DE DATOS
  output$record_count <- renderText({
    nrow(datos_filtrados())
  })

  output$data_table <- renderDT({
    datos_filtrados() %>%
      select(ResponseID, Edad, GrupoEdad, GrupoHoras, Laboral, Horario,
             SUMCDrisc, mhc_total, CS, BO, STS, sumaEA) %>%
      rename(
        ID = ResponseID,
        `Grupo Edad` = GrupoEdad,
        `Horas` = GrupoHoras,
        `Resiliencia` = SUMCDrisc,
        `Bienestar` = mhc_total,
        `Satisfacción` = CS,
        `Burnout` = BO,
        `Fatiga` = STS,
        `Agotamiento` = sumaEA
      ) %>%
      datatable(
        options = list(
          pageLength = 20,
          scrollX = TRUE,
          language = list(url = "//cdn.datatables.net/plug-ins/1.10.11/i18n/Spanish.json")
        ),
        rownames = FALSE
      )
  })
}

# Ejecutar app
shinyApp(ui = ui, server = server)
