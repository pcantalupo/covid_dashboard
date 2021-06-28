library(tidyverse)
library(scales)
library(shiny)

s = read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/us_state_vaccinations.csv")
s = s %>% rename(Doses_Given = total_vaccinations,
                 Vaccinated = people_vaccinated,
                 Fully_Vaccinated = people_fully_vaccinated,
                 Perc_Vaccinated = people_vaccinated_per_hundred,
                 Perc_Fully_Vaccinated = people_fully_vaccinated_per_hundred)

long_num_people = s %>%
    select(date, location, Vaccinated, Fully_Vaccinated) %>%
    pivot_longer(-c(date, location)) 

long_perc_people = s %>%
    select(date, location, Perc_Vaccinated, Perc_Fully_Vaccinated) %>%
    pivot_longer(-c(date, location)) 


# loc_names = unique(s$location)
# loc_values = str_replace_all(locations, " ", "_") %>% str_to_lower()
# states = loc_values
# names(states) = loc_names   # The "names" appear as selections in the drop down select inputs
states = unique(s$location )


ui <- navbarPage(title = "COVID Vaccine Dashboard",
                 tabPanel(title = "2 states",
                          sidebarLayout(
                              sidebarPanel = sidebarPanel(
                              sliderInput("dates",
                                          "Dates:",
                                          min = as.Date("2021-01-01","%Y-%m-%d"),
                                          max = as.Date("2021-06-28","%Y-%m-%d"),
                                          value = as.Date("2021-06-01"), timeFormat="%Y-%m-%d"),
                              checkboxInput("toggleus", label = "US", value = FALSE),
                              selectInput("state1", label = "State 1", choices = states),
                              selectInput("state2", label = "State 2", choices = states)
                          ),

                              mainPanel = mainPanel(
                                  plotOutput(outputId = "totalvacs"),
                                  plotOutput(outputId = "twostate")
                              )
                          )
                 ),
                 tabPanel(title = "All states",
                          plotOutput("unif"),
                          actionButton("reunif", "Resample")
                 ),
                 tabPanel(title = "Country",
                          plotOutput("chisq"),
                          actionButton("rechisq", "Resample")
                 )
                 
)

server <- function(input, output) {

    output$totalvacs = renderPlot({
        print (input$state1)
        
        long_num_people %>% filter(location == !!input$state1) %>%
            ggplot(aes(x=date, y=value)) + geom_line(aes(color=name)) + scale_y_continuous(labels = scales::comma)
    })
}

shinyApp(server = server, ui = ui)
