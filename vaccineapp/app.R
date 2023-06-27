library(DT)
library(zoo)
library(scales)
library(tidyverse)
library(shiny)

# STATE data ############################################
s = read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/us_state_vaccinations.csv")
s = s |> rename(Doses_Given = total_vaccinations,
                 Vaccinated = people_vaccinated,
                 Fully_Vaccinated = people_fully_vaccinated,
                 Perc_Vaccinated = people_vaccinated_per_hundred,
                 Perc_Fully_Vaccinated = people_fully_vaccinated_per_hundred,
                 Boosted = total_boosters,
                 Perc_Boosted = total_boosters_per_hundred)
mindate = min(s$date)
maxdate = max(s$date)

states = unique(s$location )

long_num_people = s |>
    select(date, location, Vaccinated, Fully_Vaccinated, Boosted) |>
    group_by(location) |> 
    mutate(Vaccinated = na.approx(Vaccinated, na.rm=FALSE),
           Fully_Vaccinated = na.approx(Fully_Vaccinated, na.rm=FALSE),
           Boosted = na.approx(Boosted, na.rm = FALSE)) |>
    pivot_longer(-c(date, location), names_to="vaxType", values_to = "number") 

long_perc_people = s |>
    select(date, location, Perc_Vaccinated, Perc_Fully_Vaccinated, Perc_Boosted) |>
    group_by(location) |> 
    mutate(Perc_Vaccinated = na.approx(Perc_Vaccinated, na.rm=FALSE),
           Perc_Fully_Vaccinated = na.approx(Perc_Fully_Vaccinated, na.rm=FALSE),
           Perc_Boosted = na.approx(Perc_Boosted, na.rm = FALSE)) |>
    pivot_longer(-c(date, location), names_to = "vaxType", values_to = "percentage")


# COUNTRY data ############################################
c = read_csv("https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.csv")
c = c |> rename(Doses_Given = total_vaccinations,
                 Fully_Vaccinated = people_fully_vaccinated,
                 Perc_Fully_Vaccinated = people_fully_vaccinated_per_hundred,
                 Boosted = total_boosters,
                 Perc_Boosted = total_boosters_per_hundred)

# Country vaccine inequality
cpfv = c |> filter(!is.na(Perc_Fully_Vaccinated)) |>
    group_by(location) |>
    slice(which.max(date)) |>
    select(location, Perc_Fully_Vaccinated) |>
    arrange(-Perc_Fully_Vaccinated) |>
    ungroup()

# Datatable
vacc_by_loc = c |> select(date, location, Doses_Given, Fully_Vaccinated, Perc_Fully_Vaccinated, Boosted, Perc_Boosted) |>
    group_by(location) |> 
    slice_max(date)
#    select(-date) |>


# Shiny components (ui and server) #######################
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
                 
                
                 tabPanel(title = "Country inequality",
                    textInput("topbtmnum", label = "Number of top and bottom countries vaccination rates", value = 25),
                    plotOutput("country")
                 ),
                 
                 tabPanel(title = "Datatable",
                    DT::dataTableOutput("datatable")
                 )
)




server <- function(input, output) {
    
    # output$daterange = renderText({
    #     start = input$dates[1];  end = input$dates[2]
    #     paste0("Date range from ", start, " to ", end)
    # })
    
    output$totalvacs = renderPlot({
        # print (input$state1)
        toPlot = long_num_people |> filter(date >= input$dates[1] & date <= input$dates[2])
        title = "Number of vaccinations in "
        if (input$togglestate == TRUE) {
            toPlot = toPlot |> filter(location %in% input$state1)
            title = paste0(title, input$state1)
        } else {
            toPlot = toPlot |> filter(location == "United States")
            title = paste0(title, "United States")
        }
        toPlot |>
            ggplot(aes(x=date, y=number)) +
            geom_line(aes(color=vaxType), size = 2) +
            scale_y_continuous(labels = scales::comma) +
            theme(text=element_text(size=18)) +
            labs(title=title)
    })
    
    output$twostate = renderPlot({
        #print(input$state1)
        #print(input$state2)
        twostates = c(input$state1, input$state2)
        two = long_perc_people |> filter(date >= input$dates[1] & date <= input$dates[2]) |>
            filter(location %in% twostates) |>
            mutate(location = factor(location, levels=c(twostates))) # keep State1 same color no matter State2
        two |>
            ggplot(aes(x=date, y=percentage)) +
            geom_line(aes(color=location), size = 1) + 
            theme(text=element_text(size=18)) + 
            labs(title = paste0("Comparison of ", input$state1, " and ", input$state2),
                 y = "percent") +
            facet_wrap(~vaxType) +
            theme(axis.text.x = element_text(angle = 90))
    })
    
    
    # All States Facet Wrap plot
    # how to stop plot from updating while adding/removing states? Add submit button
    output$allstates = renderPlot({
        print(input$states)
        if (is.null(input$states)) {
            toPlot = long_perc_people |> filter(location != "United States")

        } else {
            toPlot = long_perc_people |>
                 filter(location != "United States" & location %in% input$states)
        }
        toPlot |>
            ggplot(aes(x=date, y=percentage)) +
            geom_line(aes(color=vaxType)) +
            facet_wrap(~ location) +
            theme(text=element_text(size=18)) + 
            labs(title = paste0("Comparison of vaccinations across states")) +
            theme(axis.text.x = element_text(angle = 90))
    }, height = 900)
    
    
    # Country vaccine inequality plot
    output$country = renderPlot({
        num = as.integer(input$topbtmnum)
        #if(is.na(num)) {num = 10} 
        print(num)
        btmtop = cpfv |> filter(row_number() %in% 1:num | row_number() %in% (n()-(num-1)) : n() )
        btmtop |> mutate(location = fct_reorder(location, Perc_Fully_Vaccinated)) |>
            ggplot(aes(x=location, y=Perc_Fully_Vaccinated)) +
            geom_col() +
            coord_flip() +
            theme(text=element_text(size=18)) +
            labs(title="Vaccine inequality\nShowing highest and lowest rates of vaccination")
    }, width = 750, height = 750)
    
    
    # Sortable datatable
    output$datatable = DT::renderDataTable({
        datatable(vacc_by_loc)
    })
    
}

shinyApp(server = server, ui = ui)
