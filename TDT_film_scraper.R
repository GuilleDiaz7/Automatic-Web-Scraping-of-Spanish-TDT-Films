#### LOAD PACKAGES ####
library(rvest)
library(magrittr)
library(dplyr)
library(tidyr)
library(purrr)
library(lubridate)
library(readr)


#### LOAD URL AND SCRAPE THE WEBSITE ####
html_data <- read_html("https://www.elmundo.es/television/programacion-tv/peliculas.html")

df <- tibble(date = html_data %>% 
               html_nodes("li.programa-canal") %>% 
               html_attr("name"),
             time = html_data %>% 
               html_nodes(".hora-categoria") %>% 
               html_text2(),
             channel = html_data %>% 
               html_nodes(".programa-celda-1 div meta") %>% 
               html_attr("content"),
             sp_title = html_data %>% 
               html_nodes(".nombre-programa a") %>% 
               html_text2(), 
             genre = html_data %>% 
               html_nodes(".titulo-categoria") %>% 
               html_text2(),
             description = html_data %>% 
               html_nodes(".sinopsis-programa") %>% 
               html_text2(),
             url = html_data %>% 
               html_nodes(".nombre-programa a") %>%
               html_attr("href")
             )

df_clean <- df %>% 
  filter(sp_title != "Cine" & genre != "Cine") %>% 
  mutate(date = ymd(substr(date, 1, 8)),
  ) %>%
  filter(date == Sys.Date() ) %>%
  transmute(date_time = ymd_hm(paste(date, time)),
            channel = channel,
            sp_title = sp_title, 
            genre = genre,
            description = description,
            url = url
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
                              casillas = map(nav_results_list$html_result,
                                             ~ .x %>%
                                               html_nodes(".ficha-txt") %>%
                                               html_text2()
                              ),
                              datos = map(nav_results_list$html_result,
                                          ~ .x %>%
                                            html_nodes(".ficha-txt-descripcion") %>%
                                            html_text2()
                              )
)

results_by_film_url <- results_by_film_url %>%
  mutate(row = row_number()) %>% 
  unnest(c(casillas, datos)) %>% 
  mutate(datos = ifelse(datos == "", NA, datos)) %>% 
  pivot_wider(names_from = casillas, values_from = datos) %>% 
  select(-row) %>%
  select(-c("SINOPSIS", "Título:"))

df_final <- df_clean %>%
  left_join(results_by_film_url) %>% 
  select(-url) %>% 
  mutate(`Año:` = as.integer(`Año:`),
         `Duración:` = as.integer(parse_number(`Duración:`))) %>% 
  dplyr:: rename(
    actors = "Intérprete:",
    country = "País:",
    director = "Director:",
    length = "Duración:",
    music = "Música:",
    original_title = "Título original:",
    photography = "Director de fotografía:", 
    producer = "Producción:",
    production_company = "Productora:",
    writer = "Guión:",
    year = "Año:"
  ) %>% 
  relocate(
    original_title, .after = sp_title
  ) %>% 
  relocate(
    year, .before = genre
  ) %>% 
  relocate(
    c("country", "length"), .before = description
  ) %>% 
  relocate(
    director, .before = writer
  ) %>% 
  relocate(
    c("photography", "music", "producer", "production_company"), .before = actors
  )

#### APPEND DATA DAY TO DAY TO A .CSV FILE ####
# write.table(df_final, "data/pelis_tv_hoy.csv", fileEncoding = "UTF-8", sep = ",", row.names = FALSE, col.names = FALSE, append = TRUE)
write.table(df_final, "data/pelis_tv_hoy_.csv", fileEncoding = "UTF-8", sep = ",", row.names = FALSE, col.names = TRUE)


#### LOAD URL AND SCRAPE THE WEBSITE ####
html_data <- read_html("https://www.elmundo.es/television/programacion-tv/be-mad.html")

df <- tibble(date = html_data %>% 
               html_nodes("li.programa-canal") %>% 
               html_attr("name"),
             time = html_data %>% 
               html_nodes(".hora-categoria") %>% 
               html_text2(),
             channel = "Be Mad",
             sp_title = html_data %>% 
               html_nodes(".nombre-programa a") %>% 
               html_text2(), 
             genre = html_data %>% 
               html_nodes(".titulo-categoria") %>% 
               html_text2(),
             description = html_data %>% 
               html_nodes(".sinopsis-programa") %>% 
               html_text2(),
             url = html_data %>% 
               html_nodes(".nombre-programa a") %>%
               html_attr("href")
            )

df_clean <- df %>% 
  filter(sp_title != "Cine" & genre != "Cine") %>% 
  mutate(date = ymd(substr(date, 1, 8)),
  ) %>%
  filter(date == Sys.Date() ) %>%
  transmute(date_time = ymd_hm(paste(date, time)),
            channel = channel,
            sp_title = sp_title, 
            genre = genre,
            description = description,
            url = url
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
                              casillas = map(nav_results_list$html_result,
                                             ~ .x %>%
                                               html_nodes(".ficha-txt") %>%
                                               html_text2()
                              ),
                              datos = map(nav_results_list$html_result,
                                          ~ .x %>%
                                            html_nodes(".ficha-txt-descripcion") %>%
                                            html_text2()
                              )
)


results_by_film_url <- results_by_film_url %>%
  mutate(row = row_number()) %>% 
  unnest(c(casillas, datos)) %>%
  mutate(datos = ifelse(datos == "", NA, datos)) %>%
  pivot_wider(names_from = casillas, values_from = datos) %>% 
  select(-row) %>% 
  select(-c("SINOPSIS", "Título:"))

df_final <- df_clean %>% 
  left_join(results_by_film_url) %>% 
  distinct() %>% 
  select(-c("url", "Presentador:")) %>% 
  mutate(`Año:` = as.integer(`Año:`),
         `Duración:` = as.integer(parse_number(`Duración:`))) %>% 
  dplyr:: rename(
    actors = "Intérprete:",
    country = "País:",
    director = "Director:",
    length = "Duración:",
    music = "Música:",
    original_title = "Título original:",
    photography = "Director de fotografía:", 
    producer = "Producción:",
    production_company = "Productora:",
    writer = "Guión:",
    year = "Año:"
  ) %>% 
  relocate(
    original_title, .after = sp_title
  ) %>% 
  relocate(
    year, .before = genre
  ) %>% 
  relocate(
    c("country", "length"), .before = description
  ) %>% 
  relocate(
    director, .before = writer
  ) %>% 
  relocate(
    c("photography", "music", "producer", "production_company"), .before = actors
  )

# write.table(df_final, "data/pelis_tv_hoy.csv", fileEncoding = "UTF-8", sep = ",", row.names = FALSE, col.names = FALSE, append = TRUE)
write.table(df_final, "data/pelis_tv_hoy_.csv", fileEncoding = "UTF-8", sep = ",", row.names = FALSE, col.names = TRUE)
