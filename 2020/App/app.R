library(shiny)
library(lubridate)
library(tidyverse)


# Get Data ----

# https://covidtracking.com/data/api

# Obtain State level data
raw = read_csv("http://covidtracking.com/api/v1/states/daily.csv") # unique identifier per row is Date + State

ctdata = raw
ctdata$date = ymd(ctdata$date)

# Add Rates
ctdata = ctdata %>% mutate(ir = positive/totalTestResults, cfr = death/positive, ifr = death/totalTestResults) 

# Summarize data to obtain US data
us = ctdata %>% group_by(date) %>%
  summarize(positive = sum(positive, na.rm=T),
            death = sum(death, na.rm=T),
            totalTestResults = sum(totalTestResults, na.rm=T)) %>%
  mutate(ir = positive/totalTestResults,
         cfr = death/positive,
         ifr = death/totalTestResults)

states = sort(unique(ctdata$state))
names(states) = states
mindate=min(ctdata$date)
maxdate=max(ctdata$date)


# Build UI ----
# sbp = 
# mp =  


ui <- fluidPage(
  titlePanel("COVID19 Dashboard"),
  
  sidebarLayout(
    sidebarPanel = sidebarPanel(
      sliderInput("sliderdate", "Date range slider",
                  min = as.Date(mindate, "%Y-%m-%d"),
                  max = as.Date(maxdate, "%Y-%m-%d"),
                  value = c(as.Date(mindate, "%Y-%m-%d"), as.Date(maxdate, "%Y-%m-%d")),
                  timeFormat = "%Y-%m-%d"),
      checkboxInput("us", "US"),  # default is FALSE
      selectInput("state", "State", choices = states, selected = "PA", multiple = FALSE),
      selectInput("state2", "State2", choices = states, selected = "CA", multiple = FALSE),
      #uiOutput("county"),   # dynamically select County based on the State selected in the UI
    ),
    mainPanel = mainPanel(
      textOutput("daterange"),
      plotOutput("newcases"),
      plotOutput("rates"),
      plotOutput("twostates"),
    )
  ) # SideBarLayout
) # ui fluid page


# Server ----
server = function(input, output) {

  output$daterange = renderText({
    start = input$sliderdate[1];  end = input$sliderdate[2]
    paste0("Date range from ", start, " to ", end)
  })
  
  # New Cases Plot
  output$newcases = renderPlot({
    start = input$sliderdate[1]
    end = input$sliderdate[2]
    s1 = input$state
    
    if (input$us == FALSE) {
      ctdata %>%
        filter(state == s1, date >= start & date <= end) %>%
        mutate(newcases = replace_na(positive - lead(positive),0)) %>%
        ggplot(aes(x=date, y=newcases)) +
        geom_col() +
        labs(title=paste0("Daily change of cases in ", s1))
    } else{
      us %>% 
        mutate(newcases = replace_na(positive - lag(positive),0)) %>%
        filter(date >= start & date <= end) %>%
        ggplot(aes(x=date, y=newcases)) +   
        geom_col() +
        labs(title=paste0("Daily change of cases in US"))
    }
  })


  # Rates Plot
  output$rates = renderPlot({
    start = input$sliderdate[1]
    end = input$sliderdate[2]
    s1 = input$state

    if (input$us == FALSE) {
      ctdata %>% select(date,state,ir,cfr,ifr) %>%
        filter(state == s1, date >= start & date <= end) %>%
        gather(key = "stat", value = "rate", -date, -state) %>%
        ggplot(aes(x=date, y = rate, color = stat, linetype = stat)) +
        geom_line() +
        scale_y_continuous(labels = scales::percent) +
        labs(title = paste0(s1, " CFR, IFR and IR"))
      } else {
      us %>% 
        select(date, ir, cfr, ifr) %>%
        filter(date >= start & date <= end) %>%
        gather(key = "stat", value = "rate", -date) %>%
        ggplot(aes(x=date, y = rate, color = stat)) +
        geom_line() +
        scale_y_continuous(labels = scales::percent) +
        labs(title = paste0("US CFR, IFR and IR"))
      
    }
    
  })

  # Two State Comparison - IR Polot
  output$twostates = renderPlot({
    start = input$sliderdate[1]
    end = input$sliderdate[2]
    s1 = input$state
    s2 = input$state2
    
    ctdata %>%
      filter(date >= start & date <= end, state == s1 | state == s2) %>%
      ggplot(aes(x=date, y = ir, color = state)) +
      geom_line() + geom_point() + theme_minimal() +
      scale_y_continuous(labels = scales::percent) +
      labs(title = paste0(s1, " & ", s2, " Infection Rate (IR)"))
  })
}


# Run Shiny ----
shinyApp(ui, server = server)



