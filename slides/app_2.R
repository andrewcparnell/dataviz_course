library(shiny)
library(ggplot2)

# Define UI
ui <- shinyUI(fluidPage(

  selectInput(inputId = "n_breaks",
              label = "Number of bins in histogram (approximate):",
              choices = c(10, 20, 35, 50),
              selected = 20),

  checkboxInput(inputId = "individual_obs",
                label = strong("Show individual observations"),
                value = FALSE),

  checkboxInput(inputId = "density",
                label = strong("Show density estimate"),
                value = FALSE),

  plotOutput(outputId = "main_plot", height = "300px"),

  # Display this only if the density is shown
  conditionalPanel(condition = "input.density == true",
                   sliderInput(inputId = "bw_adjust",
                               label = "Bandwidth adjustment:",
                               min = 0.2, max = 2, value = 1, step = 0.2)
  )

))


# Define server
server <- shinyServer(function(input, output) {

  output$main_plot <- renderPlot({
    
    p <- ggplot(faithful, aes(x = eruptions,
                              y = after_stat(density))) + 
      geom_histogram(bins = as.numeric(input$n_breaks)) + 
      labs(x = 'Duration (minutes)',
           main = "Geyser eruption duration")
    print(p)
       
    # hist(faithful$eruptions,
    #      probability = TRUE,
    #      breaks = as.numeric(input$n_breaks),
    #      xlab = "Duration (minutes)",
    #      main = "Geyser eruption duration")

    if (input$individual_obs) {
      print(p + geom_rug())
    }
    
    if (input$density) {
      dens <- density(faithful$eruptions,
                      adjust = input$bw_adjust,
                      n = nrow(faithful))
      df <- data.frame(x = dens$x,
                       y = dens$y)
      print(p + geom_line(data = df, 
                          aes(x = x,y = y)))
      # lines(dens, col = "blue")
    }

  })
})

# Run the application
shinyApp(ui = ui, server = server)


