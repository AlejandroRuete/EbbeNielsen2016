
shinyUI(navbarPage("Ignorance Explorer", id="nav", theme = shinytheme("flatly"), windowTitle="Ignorance Explorer",
  ############# MAP #########
  tabPanel("Spatial Bias",
    div(class="outer",

      tags$head(
        # tags$link(rel="shortcut icon", href="/favicon.ico"),
        # Include our custom CSS
        includeCSS("styles.css"),
        includeScript("gomap.js")
      ),

      leafletOutput("map", width="100%", height="100%"),

      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
        draggable = TRUE, top = 70, left = 50, right = "auto", bottom = "auto",
        width = 350, height = "auto",
        h3("Assumptions"),
        selectInput(inputId = "res",
                    label = h4("Grid Resolution (in km)"),
                    choices = c("100"="100",
                                "50" = "50",
                                "25" = "25"),
                    width = 200
        ),

        numericInput(inputId ="obs50",
                     label = h4("O",tags$sub("0.5"), "RTG = Class Amphibia", br(),
                                h5("Number of observations required per 25 km grid cell, that is: (res/25)",tags$sup("2"), "x O",tags$sub("0.5"))),
                     value = 1, #(res/(25))^2
                     min = 0.1,
                     max = 1000,
                     step = .1,
                     width = "100%"
        ),
        checkboxInput(inputId="index",
                      label="Observation index (N/R)",
                      value=TRUE
        ),
        # Target Species Lists
        tags$hr(),
        numericInput(inputId ="obs50spp", # for each 25km 
                     label = h4("O",tags$sub("0.5"),  em("Rana temporaria"), br(), h5("Number of observations required per 25 km grid cell")),
                     value = 1,
                     min = 0.1,
                     max = 100,
                     step = .1,
                     width = "100%"
        ),
        sliderInput(inputId ="prestol",
                    label = h4("Max Ignorance for Presence"),
                    value = 0.5,
                    min = 0.1,
                    max = 0.9,
                    step = 0.1
        ),
        # tags$hr(), 
        actionButton("goButton", "Apply Changes"),
        tags$hr(),
        h3("Plotting options"),
        selectInput(inputId = "layer",
                    label = h4("Layer"),
                    choices = c("RTG Ignorance" = "RTGIgn",
                                "Species Ignorance" = "SppIgn",
                                "Population Size Index" = "PSI", 
                                "Species Presence" = "SppPres"),
                    width = "100%"
        ),
        sliderInput(inputId ="alpha",
                    label = h4("Transparency"),
                    value = 0.8,
                    min = 0.1,
                    max = 0.9,
                    step = 0.1
        )
      ),
      tags$div(id="cite", #class='simpleDiv',
         tags$em('Ignorance Maps'), ' by Alejandro Ruete (SLU, 2016)'
      )
    )
  ),

  tabPanel("Temporal and Grouped Bias", 
    fluidRow(
      column(3,
        p("In this tab we slice ignorance trough time, and group it by country at different resolutions. The aim is to explore when and where were observations collected.
          For agility reasons the temporal analysis is done onnly with 100 km grids cells. However, the resolution analysis uses allways all observations"),
        numericInput(inputId ="obs50D",
                     label = h4("O",tags$sub("0.5"), "RTG = Class Amphibia",br(),h5("Number of observations required per 25 km grid cell")),
                     value = 1, 
                     min = .1,
                     max = 100,
                     step = .1,
                     width = "250px"
        ),
        checkboxInput(inputId="indexD",
                      label=h5("Observation index (N/R)"),
                      value=TRUE
        ),
        checkboxGroupInput(inputId="resPlot",
                           label=h4("Resolutions"),
                           choices = c("100 km" = 100,
                                       "50 km" = 50,
                                       "25 km" = 25),
                           selected = c(100,50,25), inline = TRUE, width = "100%"),
        sliderInput(inputId ="time",
                    label = h4("Years"),
                    value = c(1900,Years[length(Years)]), #c(Years[2],Years[length(Years)]),
                    min = Years[2],
                    max = Years[length(Years)],
                    step = 1, 
                    width = 400
        ),
        br(),
        p("Some observation have no data about the year they where collected. 
          In some countries they could represent a significant proportion of the data."),
        checkboxInput(inputId="NAplot",
                      label="Do you whant to include observations with year = NA?",
                      value=TRUE, width = "100%"
        ),
        selectInput("countries", 
                    label = h4("Countries"), 
                    c("Europe"="", structure(CountriesList, names=CountriesListAb)), 
                    selected=("Spain"), 
                    multiple=TRUE, 
                    width = "400px"),
        p("Remember that small countries, such as Andorra, may be smaller than the grid resolution. 
          In those cases, a single grid cell overlapping the centroid coordinates of the country is read.", 
          em("Note"), "that densities cannot be calculated from a single value.")
      ),
      column(5, 
        plotOutput("TempIgn", height = "450px"),
        plotOutput("DensIgn", height = "450px"),
        plotOutput("Legend", height = "300px")
      ),
      column(4,
        dataTableOutput("TableIgn")
      )
    )
  ),
  tabPanel("Read me", 
    fixedRow(
      column(8,
      includeHTML("data/Description.htm"),
      offset=2)
    )
  ),

  conditionalPanel("false", icon("crosshair"))
))
