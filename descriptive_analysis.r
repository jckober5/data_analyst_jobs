### Read in the Necessary Packages
library(RMySQL)
library(ggplot2)
library(plotly)
library(scales)
options(scipen=999)

### Bring in the Data Successfully
mysqlconnection <- dbConnect(RMySQL::MySQL(),
                             dbname='external_data',
                             host='..........',
                             port=3306,
                             user='.....',
                             password='.......!')

df <- dbReadTable(mysqlconnection, 'vw_google_job_data_skills')

#create percentage of demand
df$Percentage_Requested <- round(df$requests/df$postings,2)

#filter to only R, Python, and SQL
lang <- subset(df,df$skill == 'R' 
               | df$skill == 'Python'
               | df$skill == 'SQL')
# Plot R vs Python vs SQL
ggplotly(ggplot(data = lang, aes(x = skill, y = Percentage_Requested), fill = 'gold') +
           geom_bar(stat = "identity", color = "#000000", fill = 'gold', alpha = .4, width = .75, show.legend = FALSE) +
           coord_flip() + 
           theme(panel.background = element_rect(fill = "#202123"),
                 plot.background = element_rect(fill = "#202123"),
                 title = element_text(colour = '#ffffff')) +
           ggtitle("Percentage of Job Postings Requesting Coding Skills")
)

#filter to only Tableau, Power BI, Looker
viz <- subset(df,df$skill == 'Tableau' 
              | df$skill == 'Power BI'
              | df$skill == 'Looker')
# Plot Tableau vs Power BI vs Looker
ggplotly(ggplot(data = viz, aes(x = skill, y = Percentage_Requested), fill = 'gold') +
           geom_bar(stat = "identity", color = "#000000", fill = 'gold', alpha = .4, width = .75, show.legend = FALSE) +
           coord_flip() + 
           theme(panel.background = element_rect(fill = "#202123"),
                 plot.background = element_rect(fill = "#202123"),
                 title = element_text(colour = '#ffffff')) +
           ggtitle("Percentage of Job Postings Requesting Visualization Skills")
)

# Find what percentage of Senior analyst postings require education levels
postings <- dbReadTable(mysqlconnection, 'vw_google_job_data')
senior_postings <- subset(postings,postings$senior_position == 1)

degree_required <- data.frame(Education_Level = ifelse
                              (senior_postings$master_degree_required == 1,
                                'Master Degree',ifelse
                                (senior_postings$bachelor_degree_required == 1, 
                                  'Bachelor Degree', "Degree not Specified"
                                )
                              )
                              , Postings = rep(1, nrow(senior_postings))
)
degree_required <- aggregate(Postings ~ Education_Level, data = degree_required, 
                             sum)
colors <- c('rgb(90,117,98)', 'rgb(123,145,129)', 'rgb(75,92,107)', 'rgb(224,164,156)', 'rgb(235,194,189)', 'rgb(251,244,232)',
            'rgb(216,215,215)',
            'rgb(131,181,108)',
            'rgb(156,196,137)',
            'rgb(181,211,167)',
            'rgb(205,225,196)',
            'rgb(230,240,226)')

degree.pie <- plot_ly(degree_required, labels = ~Education_Level, values = 
                        ~Postings, type = 'pie',
                      textposition = 'inside',
                      textinfo = 'label+percent',
                      #insidetextfont = list(color = '#FFFFFF'),
                      hoverinfo = 'text',
                      text = ~paste(Education_Level, 'Postings'),
                      marker = list(colors = colors,
                                    line = list(color = '#FFFFFF', width = 1)),
                      #The 'pull' attribute can also be used to create space between the sectors
                      showlegend = FALSE)
degree.pie <- degree.pie %>% layout(title = 'Distribution of Education Levels Required for a Senior Position',
                                    xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                                    yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE)) %>%
  layout(plot_bgcolor='transparent') %>% 
  layout(paper_bgcolor='transparent')

degree.pie



# Find what percentage of Senior analyst postings require how many years of experience
exp_required <- data.frame(Experience_Years = senior_postings$years_of_experience 
                           , Postings = rep(1, nrow(senior_postings))
)
exp_required <- aggregate(Postings ~ Experience_Years, data = exp_required, 
                          sum)

exp.pie <- plot_ly(exp_required, labels = ~Experience_Years, values = 
                     ~Postings, type = 'pie',
                   textposition = 'inside',
                   textinfo = 'label+percent',
                   #insidetextfont = list(color = '#FFFFFF'),
                   hoverinfo = 'text',
                   text = ~paste(Experience_Years, 'Years of Experience'),
                   marker = list(colors = colors,
                                 line = list(color = '#FFFFFF', width = 1)),
                   #The 'pull' attribute can also be used to create space between the sectors
                   showlegend = FALSE)
exp.pie <- exp.pie %>% layout(title = 'Distribution of Years of Experience Required for a Senior Position',
                              xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
                              yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE)) %>%
  layout(plot_bgcolor='transparent') %>% 
  layout(paper_bgcolor='transparent')

exp.pie


# Find what percentage of Senior analyst postings require those skills we've shown previously as important
r <-aggregate(r ~ senior_position, data = senior_postings, sum)
python <- aggregate(python ~ senior_position, data = senior_postings, sum)
sql <-aggregate(sql_skills ~ senior_position, data = senior_postings, sum)
tableau <-aggregate(tableau ~ senior_position, data = senior_postings, sum)
power_bi <- aggregate(power_bi ~ senior_position, data = senior_postings, sum)
looker <- aggregate(looker ~ senior_position, data = senior_postings, sum)

senior_skills <- data.frame(Skills = c('R','Python','SQL','Tableau','Power BI', 'Looker')
                            , Postings = c(r$r[1],python$python[1],sql$sql_skills[1],tableau$tableau[1],power_bi$power_bi[1],looker$looker[1])
                            , Total_Postings = rep(nrow(senior_postings),6)
)
senior_skills$Percentage_Requested <- round(senior_skills$Postings/senior_skills$Total_Postings,2)

ggplotly(ggplot(data = senior_skills, aes(x = Skills, y = Percentage_Requested), fill = 'gold') +
           geom_bar(stat = "identity", color = "#000000", fill = 'gold', alpha = .4, width = .75, show.legend = FALSE) +
           coord_flip() + 
           theme(panel.background = element_rect(fill = "#202123"),
                 plot.background = element_rect(fill = "#202123"),
                 title = element_text(colour = '#ffffff')) +
           ggtitle("Percentage of Senior Job Postings Requesting Skills")
)