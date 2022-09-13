#### LOAD PACKAGES ####
library(rvest)
library(magrittr)
library(dplyr)
library(tidyr)
library(purrr)
library(lubridate)


#### LOAD URL AND SCRAPE THE WEBSITE ####
url <- "https://www.elmundo.es/television/programacion-tv/peliculas.html"
html_data <- read_html(url)

films <- html_data %>% 
  html_nodes(".nombre-programa a") %>% 
  html_text2()

times <- html_data %>% 
  html_nodes(".hora-categoria") %>% 
  html_text2()

genre <- html_data %>% 
  html_nodes(".titulo-categoria") %>% 
  html_text2()

description <- html_data %>% 
  html_nodes(".sinopsis-programa") %>% 
  html_text2()

dates <- html_data %>% 
  html_nodes("li.programa-canal") %>% 
  html_attr("name")

## This is not the best way to scrape this content, but I haven't figure out a better way yet ##
channel <- html_data %>% 
  html_nodes(xpath = '//meta[@itemprop="name"]') %>% 
  html_attr("content")
channel <- as.data.frame(channel)
channel <- channel[seq_len(nrow(channel)) %% 2 == 0, ] 


#### CREATE THE FINAL DATAFRAME AND CLEAN IT ####
df <- as.data.frame(cbind(dates, times, channel, films, genre, description))

df_clean <- df %>% 
  filter(films != "Cine" & genre != "Cine") %>% 
  mutate(dates = ymd(substr(dates, 1, 8)),
         ) %>% 
  transmute(date_time = ymd_hm(paste(dates, times)),
            channel = channel,
            films = films, 
            genre = genre,
            description = description
            )

#### APPEND DATA DAY TO DAY TO A .CSV FILE ####
write.table(df_clean, "pelis_tv_hoy.csv", fileEncoding = "UTF-8", sep = ",", row.names = FALSE, append = TRUE, col.names = FALSE)

## Check if the appending works fine ##
prueba <- read.csv("pelis_tv_hoy.csv", fileEncoding = "UTF-8")
  


