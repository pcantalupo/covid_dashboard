library(tidyverse)
#library(scales)
library(shiny)

s = read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/us_state_vaccinations.csv")
s = s %>% rename(Doses_Given = total_vaccinations,
                 Vaccinated = people_vaccinated,
                 Fully_Vaccinated = people_fully_vaccinated,
                 Perc_Vaccinated = people_vaccinated_per_hundred,
                 Perc_Fully_Vaccinated = people_fully_vaccinated_per_hundred)
mindate = min(s$date)
maxdate = max(s$date)


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
                                          min = mindate,
                                          max = maxdate,
                                          value = c(mindate, maxdate),
                                          timeFormat="%Y-%m-%d"),
                              checkboxInput("togglestate", label = "Show state level data?", value = TRUE),
                              selectInput("state1", label = "State 1", choices = states, selected = "Pennsylvania"),
                              selectInput("state2", label = "State 2", choices = states, selected = "South Carolina")
                          ),

                              mainPanel = mainPanel(
                                #  textOutput(outputId = "daterange"),
                                  plotOutput(outputId = "totalvacs"),
                                  plotOutput(outputId = "twostate")
                              )
                          )
                 ),
                 tabPanel(title = "All states",
                    checkboxInput("showallstates", label = "Show all states?", value = TRUE),
                    selectInput("states",
                                  label = "Select one or more states",
                                  choices = states,
                                  selected = c("Pennsylvania", "South Carolina"), multiple = TRUE),
                      plotOutput("allstates")
                ), # tabPanel end
                tabPanel(title = "Country")
)




server <- function(input, output) {
    
    # output$daterange = renderText({
    #     start = input$dates[1];  end = input$dates[2]
    #     paste0("Date range from ", start, " to ", end)
    # })
    
    output$totalvacs = renderPlot({
        print (input$state1)
        toPlot = long_num_people %>% filter(date >= input$dates[1] & date <= input$dates[2])
        title = "Number of vaccinations in "
        if (input$togglestate == TRUE) {
            toPlot = toPlot %>% filter(location == !!input$state1)
            title = paste0(title, input$state1)
        } else {
            toPlot = toPlot %>% filter(location == "United States")
            title = paste0(title, "United States")
        }
        toPlot %>%
            ggplot(aes(x=date, y=value)) +
            geom_line(aes(color=name), size = 2) +
            scale_y_continuous(labels = scales::comma) +
            theme(text=element_text(size=18)) +
            labs(title=title)
    })
    
    output$twostate = renderPlot({
        print(input$state1)
        print(input$state2)
        two = long_perc_people %>% filter(location == !!input$state1 | location == !!input$state2)
        two %>% filter(date >= input$dates[1] & date <= input$dates[2]) %>%
            ggplot(aes(x=date, y=value)) +
            geom_line(aes(color=location, linetype=name), size = 1) + 
            theme(text=element_text(size=18)) + 
            labs(title = paste0("Comparison of ", input$state1, " and ", input$state2),
                 y = "Percent")
    })
    
    output$allstates = renderPlot({
        print(input$states)
        if (input$showallstates == TRUE) {
            toPlot = long_perc_people %>% filter(location != "United States")

        } else {
            toPlot = long_perc_people %>%
                filter(location != "United States" & location %in% input$states)
        }
        toPlot %>%
            ggplot(aes(x=date, y=value)) +
            geom_line(aes(color=name)) +
            facet_wrap(~ location) +
            theme(text=element_text(size=18)) + 
            labs(title = paste0("Comparison of vaccinations across states"),
                 y = "Percent")
    }, height = 900)
}

shinyApp(server = server, ui = ui)
