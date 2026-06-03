#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(dplyr)
library(ggplot2)
library(purrr)
library(rgl)
library(shiny)
library(tidyr)

my_colours <- c(
  "1" = "#D01556",
  "6" = "#D01556",
  "2" = "#EFDC60",
  "5" = "#EFDC60",
  "3" = "#7CCA89",
  "4" = "#7CCA89"
)

default_laenge <- 19.3
default_breite <- 9.3
default_kniestock <- 0
default_slope <- 45
default_penalty_walls <- 0
default_penalty_other <- ((5*2.6) + (3*4))

deg2rad <- function(deg) {(deg * pi) / (180)}

calc_abseite_n <- function(kniestock, slope, n) {
  if(kniestock >= n) {
    return(0)
  }
  abseite_n <- (n - kniestock)/tan(deg2rad(slope))
  return(abseite_n)
}

calc_dachhoehe <- function(slope, breite, kniestock) {
      tan(deg2rad(slope)) * breite/2 + kniestock
}

calc_area_1 <- function(abseite_1, laenge) {
  abseite_1 * laenge * 2
}

calc_area_2 <- function(abseite_1, abseite_2, laenge) {
  (abseite_2 * laenge * 2) - calc_area_1(abseite_1, laenge)
}

calc_area_3 <- function(breite, laenge, a1, a2) {
  (breite * laenge) - a1 - a2
}

calc_area_4 <- function(breite, laenge, kniestock, slope) {
  abseite2.2 <- calc_abseite_n(kniestock, slope, 2.2)
  (breite * laenge) - (laenge * abseite2.2 * 2)
}

calc_area_clean <- function(laenge, breite, kniestock, slope, penalty_other, penalty_walls) {
  abseite1 <- calc_abseite_n(kniestock, slope, 1)
  abseite2 <- calc_abseite_n(kniestock, slope, 2)
  area1 <- calc_area_1(abseite1, laenge)
  area2 <- calc_area_2(abseite1, abseite2, laenge)
  area3 <- calc_area_3(breite, laenge, area1, area2)
  area_clean <- ((0.5 * area2 + area3 - penalty_other) * (100 - penalty_walls)/100)
  return(area_clean)
}

# Define UI for application that draws a histogram
ui <- fluidPage(

  # Application title
  titlePanel("Dachgeschossflächen"),

  fluidRow(
    # sidebar
    column(
      width = 4,
      # sidebarPanel(
          numericInput("laenge", "Länge [m]", value = default_laenge),
          numericInput("breite", "Breite [m]", value = default_breite),
          sliderInput("kniestock", "Kniestock [m]", min = 0, max = 1, value = default_kniestock, step = 0.1),
          sliderInput("slope", "Dachneigung [°]", min = 20, max = 60, value = default_slope),
          numericInput("penalty_walls", "Abschlag Wände [%]", value = default_penalty_walls),
          numericInput("penalty_other", "Sonstige Abschläge [m²]", value = default_penalty_other),
      # ),
      br(),
      tableOutput("table")
    ),
    column(
      width = 8,
      tabsetPanel(
        tabPanel(
          "Ansichten",
          plotOutput("sideview"),#, width = "100%"),
          plotOutput("topview"),#, width = "100%"),
        ),
        tabPanel(
          "Größen",
          plotOutput("sizes")
        )
      )
    )
  )
)

server <- function(input, output) {
  
    dachhoehe <- reactive({calc_dachhoehe(input$slope, input$breite, input$kniestock)})
    abseite_1 <- reactive({calc_abseite_n(input$kniestock, input$slope, 1)})
    abseite_2 <- reactive({calc_abseite_n(input$kniestock, input$slope, 2)})
    
    area_1 <- reactive({calc_area_1(abseite_1(), input$laenge)})
    area_2 <- reactive({calc_area_2(abseite_1(), abseite_2(), input$laenge)})
    area_3 <- reactive({calc_area_3(input$breite, input$laenge, area_1(), area_2())})
    area_4 <- reactive({calc_area_4(input$breite, input$laenge, input$kniestock, input$slope)})
    
    area_total <- reactive({area_1() + area_2() + area_3()})
    area_clean <- reactive({((0.5 * area_2() + area_3() - input$penalty_other) * (100 - input$penalty_walls)/100)})
    
    output$sideview <- renderPlot({
      b <- input$breite
      d <- data.frame(
        x = c(
          0, 0, abseite_1(), abseite_1(),
          abseite_1(), abseite_1(), abseite_2(), abseite_2(),
          abseite_2(), abseite_2(), (b/2), (b/2),
          (b/2), (b/2), b - abseite_2(), b - abseite_2(),
          b - abseite_2(), b - abseite_2(), b - abseite_1(), b - abseite_1(),
          b - abseite_1(), b - abseite_1(), b, b
        ), y = c(
          input$kniestock, 0, 0, 1,
          1, 0, 0, 2,
          2, 0, 0, dachhoehe(),
          dachhoehe(), 0, 0, 2,
          2, 0, 0, 1,
          1, 0, 0, input$kniestock
        ), type = c(
          "1", "1", "1", "1",
          "2", "2", "2", "2",
          "3", "3", "3", "3",
          "4", "4", "4", "4",
          "5", "5", "5", "5",
          "6", "6", "6", "6"
        )
      )
      ggplot() +
        xlim(0, b) +
        ylim(0, b) +
        geom_polygon(data = d, mapping = aes(x=x, y=y, group = type, fill = type)) +
        scale_fill_manual(values = my_colours) +
        theme_minimal() +
        theme(legend.position="none") +
        labs(x = NULL, y = NULL)
    }, height = 400, width = 400)
    
    output$topview <- renderPlot({
      b <- input$breite
      l <- input$laenge
 
      d <- data.frame(
        x = c(
          0, 0, abseite_1(), abseite_1(),
          abseite_1(), abseite_1(), abseite_2(), abseite_2(),
          abseite_2(), abseite_2(), (b/2), (b/2),
          (b/2), (b/2), b - abseite_2(), b - abseite_2(),
          b - abseite_2(), b - abseite_2(), b - abseite_1(), b - abseite_1(),
          b - abseite_1(), b - abseite_1(), b, b
        ), y = c(
          l, 0, 0, l,
          l, 0, 0, l,
          l, 0, 0, l,
          l, 0, 0, l,
          l, 0, 0, l,
          l, 0, 0, l
        ), type = c(
          "1", "1", "1", "1",
          "2", "2", "2", "2",
          "3", "3", "3", "3",
          "4", "4", "4", "4",
          "5", "5", "5", "5",
          "6", "6", "6", "6"
        )
      )
      ggplot() +
        xlim(0, b) +
        ylim(0, l) +
        coord_fixed(ratio = 1) +
        geom_polygon(data = d, mapping = aes(x=x, y=y, group = type, fill = type)) +
        scale_fill_manual(values = my_colours) +
        theme_minimal() +
        theme(legend.position="none") +
        labs(x = NULL, y = NULL)
    }, height = 800, width = 400)
    
    output$table <- renderTable({
      data.frame(
        Name = c(
          "Dachhöhe [m]",
          "Abseite < 1m [m]",
          "Abseite < 2m [m]",
          "Fläche < 1m [m²]",
          "Fläche < 2m [m²]",
          "Fläche >= 2m [m²]",
          "Fläche >= 2.2m [m²]",
          "Fläche gesamt [m²]",
          "Fläche bereinigt [m²]"
        ),
        Wert = c(
          dachhoehe(),
          abseite_1(),
          abseite_2(),
          area_1(),
          area_2(),
          area_3(),
          area_4(),
          area_total(),
          area_clean()
        )
      )
    })
    
    output$sizes <- renderPlot({
      kniestock_vals <- 0:10 / 10
      slope_vals <- 20:60
      
      results <- expand.grid(
        kniestock = kniestock_vals,
        slope     = slope_vals
      )
      results$area_clean <- mapply(
        function(k, s) calc_area_clean(input$laenge, input$breite, k, s, input$penalty_other, input$penalty_walls),
        results$kniestock,
        results$slope
      )
      
      ggplot(results, aes(x = slope, y = area_clean, color = factor(kniestock))) +
        geom_line() +
        geom_point() +
        scale_color_brewer(palette = "RdYlBu", direction = 1) +
        labs(
          x     = "Dachneigung [°]",
          y     = "Bereinigte Fläche [m²]",
          color = "Kniestock [m]"
        ) +
        theme_minimal()
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
