library(tidyverse)
#library(scales)
library(shiny)

# STATE data ############################################
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




# COUNTRY data ############################################
c = read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.csv")
c = c %>% rename(Doses_Given = total_vaccinations,
                 Fully_Vaccinated = people_fully_vaccinated,
                 Perc_Fully_Vaccinated = people_fully_vaccinated_per_hundred)

cpfv = c %>% filter(!is.na(Perc_Fully_Vaccinated)) %>%
    group_by(location) %>%
    slice(which.max(date)) %>%
    select(location, Perc_Fully_Vaccinated) %>%
    ungroup() %>%
    arrange(-Perc_Fully_Vaccinated)



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
                                  checkboxInput("togglestate",
                                                label = "Show state level data?",
                                                value = TRUE),
                                  selectInput("state1",
                                              label = "State 1",
                                              choices = states,
                                              selected = "Pennsylvania"),
                                  selectInput("state2",
                                              label = "State 2",
                                              choices = states,
                                              selected = "South Carolina")
                              ),

                              mainPanel = mainPanel(
                                #  textOutput(outputId = "daterange"),
                                  plotOutput(outputId = "totalvacs"),
                                  plotOutput(outputId = "twostate")
                              )
                          )
                 ),
                 tabPanel(title = "All states",
                    selectInput("states",
                                  label = "Select one or more states",
                                  choices = states,
                                  #selected = c("Pennsylvania", "South Carolina"),
                                  multiple = TRUE),
                    plotOutput("allstates")
                 ), # tabPanel end
                 
                
                 tabPanel(title = "Country",
                    shiny::textInput("topbtmnum", label = "Enter number to show top and bottom Countries", value = 25),
                    plotOutput("country")
                 )
)




server <- function(input, output) {
    
    # output$daterange = renderText({
    #     start = input$dates[1];  end = input$dates[2]
    #     paste0("Date range from ", start, " to ", end)
    # })
    
    output$totalvacs = renderPlot({
        # print (input$state1)
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
    
    # how to keep State1 the same color no matter State2?
    output$twostate = renderPlot({
        #print(input$state1)
        #print(input$state2)
        two = long_perc_people %>% filter(location == !!input$state1 | location == !!input$state2)
        two %>% filter(date >= input$dates[1] & date <= input$dates[2]) %>%
            ggplot(aes(x=date, y=value)) +
            geom_line(aes(color=location, linetype=name), size = 1) + 
            theme(text=element_text(size=18)) + 
            labs(title = paste0("Comparison of ", input$state1, " and ", input$state2),
                 y = "Percent")
    })
    
    
    # All States Facet Wrap plot
    # how to stop plot from updating while adding/removing states? Add submit button
    output$allstates = renderPlot({
        print(input$states)
        if (is.null(input$states)) {
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
    
    
    output$country = renderPlot({
        num = as.integer(input$topbtmnum)
        print(num)
        btmtop = cpfv %>% filter(row_number() %in% 1:num | row_number() %in% (n()-(num-1)) : n() )
        btmtop %>% mutate(location = forcats::fct_reorder(location, Perc_Fully_Vaccinated)) %>%
            ggplot(aes(x=location, y=Perc_Fully_Vaccinated)) +
            geom_col() +
            coord_flip() +
            theme(text=element_text(size=18)) +
            labs(title="Vaccine inequality\nShowing highest and lowest rates of vaccination")
        
    }, width = 700, height = 700)
}

shinyApp(server = server, ui = ui)
