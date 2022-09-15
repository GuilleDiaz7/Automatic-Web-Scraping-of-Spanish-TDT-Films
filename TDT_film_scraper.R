#### LOAD PACKAGES ####
library(rvest)
library(magrittr)
library(dplyr)
library(tidyr)
library(purrr)
library(lubridate)
library(ggplot2)


#### LOAD URL AND SCRAPE THE WEBSITE ####
main_url <- "https://www.elmundo.es/television/programacion-tv/peliculas.html"
html_data <- read_html(main_url)

sp_title <- html_data %>% 
  html_nodes(".nombre-programa a") %>% 
  html_text2()

time <- html_data %>% 
  html_nodes(".hora-categoria") %>% 
  html_text2()

genre <- html_data %>% 
  html_nodes(".titulo-categoria") %>% 
  html_text2()

description <- html_data %>% 
  html_nodes(".sinopsis-programa") %>% 
  html_text2()

date <- html_data %>% 
  html_nodes("li.programa-canal") %>% 
  html_attr("name")

## This is not the best way to scrape this content, but I haven't figure out a better way yet ##
channel <- html_data %>% 
  html_nodes(xpath = '//meta[@itemprop="name"]') %>% 
  html_attr("content")
channel <- as.data.frame(channel)
channel <- channel[seq_len(nrow(channel)) %% 2 == 0, ] 

url <- html_data %>% 
  html_nodes(xpath = '//a[@itemprop="url"]') %>%
  html_attr("href")
url <- url[1:length(sp_title)]


#### CREATE THE FINAL DATAFRAME AND CLEAN IT ####
df <- as.data.frame(cbind(date, time, channel, sp_title, genre, url, description))

df_clean <- df %>% 
  filter(sp_title != "Cine" & genre != "Cine") %>% 
  mutate(date = ymd(substr(date, 1, 8)),
         ) %>%
  filter(date == Sys.Date() ) %>%
  transmute(date_time = ymd_hm(paste(date, time)),
            channel = channel,
            sp_title = sp_title, 
            genre = genre,
            url = url,
            description = description
            )


#### Perform the second part of the scraping ####
nav_results_list <- tibble(
  html_result = map(df_clean$url,
                    ~ {
                      Sys.sleep(2)
                      .x %>% 
                        read_html()
                    }),
  url = df_clean$url
  )

results_by_film_url <- tibble(url = nav_results_list$url,
                          original_title = map(nav_results_list$html_result,
                                               ~ .x %>%
                                                 html_nodes("tr:nth-child(2) .ficha-txt-descripcion") %>%
                                                 html_text2()
                                               ),
                          year = map(nav_results_list$html_result,
                                     ~ .x %>%
                                       html_nodes("tr:nth-child(4) .ficha-txt-descripcion") %>%
                                       html_text2()
                                     )
                          )

joined_tibble <- left_join(
  df_clean, results_by_film_url, by = c("url" = "url")
)

df_final <- joined_tibble %>% 
  relocate(
    year, .before = genre
  ) %>% 
  relocate(
    original_title, .after = sp_title
  ) %>% 
  select(-url) %>% 
  mutate(original_title = as.character(original_title),
         year = as.numeric(year))


#### APPEND DATA DAY TO DAY TO A .CSV FILE ####
write.table(df_final, "data/pelis_tv_hoy.csv", fileEncoding = "UTF-8", sep = ",", row.names = FALSE, col.names = FALSE, append = TRUE)
