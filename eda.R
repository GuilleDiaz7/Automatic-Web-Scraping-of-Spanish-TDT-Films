#### EXPLORATORY DATA ANALYSIS OF THE SCRAPED DATA ####

## Some questions and... some answers later ##

#  QUESTIONS #

# 1.- How many channels are there in the dataset? And film genres?
# 2.- How many different films have been shown? Is there any repeated film?
# 3.- How many times has each film been broadcasted?

#### GOTTA CLEAN THIS MESS ####

#### EXPLORATORY DATA ANALYSIS OF THE SCRAPED DATA ####
#### BASIC CODE ####

## Clean data memory
rm(list = ls())
rm("url") # Clean a particular R object

## Remove plots
dev.off(dev.list()["RStudioGD"]) # Apply dev.off() & dev.list()

#### LOAD PACKAGES ####
library(magrittr) # Si
library(dplyr) # Si
library(tidyr)
library(purrr)
library(lubridate)
library(readr)
library(stringr)
library(stringi)


#### READ THE DATA ####
data <- read.csv("https://raw.githubusercontent.com/GuilleDiaz7/Automatic-Web-Scraping-of-Spanish-TDT-Films/main/data/pelis_tv_hoy.csv",
                 fileEncoding = 'UTF-8')

#### DATA PREPARATION ####
data <- data %>% mutate(
  genre = replace(genre, genre == "Suspense / Thriller", "Suspense"),
  genre = replace(genre, genre == "Documentales", "Documental"),
  genre = replace(genre, genre == "Ciencia ficci?n", "SyFy"),
  genre = replace(genre, genre == "Infantil/Familiar", "Infantil")
)

# Count number of distinct values in each column
data %>% map_dbl(
  n_distinct
)

# Identity duplicates
library(janitor)
data %>% get_dupes(sp_title) %>% 
  select(date_time, sp_title, channel)

# Get a list of every film shown and the number of times
# Anothe way to get duplicates
data %>% 
  group_by(sp_title) %>% 
  summarise(emisiones = n()) %>% 
  filter(emisiones > 1)

#### DATA VISUALIZATION ####
library(ggplot2) # Si

# Ordered bar plot of film genres
genre_count_img <- data %>% 
  group_by(genre) %>% 
  summarise(Count = n()) %>% 
  ggplot(aes(x = reorder(genre, (-Count)), y = Count)) +
  geom_bar(stat = 'identity', col = "darkblue", fill = "darkblue") +
  theme_classic() + 
  coord_flip() +
  xlab("") +
  ylab("")
genre_count_img
ggsave("genre_count_img.png")

# Film genres by channel
genre_by_channel_img <- data %>% 
  group_by(channel, genre) %>% 
  summarise(count = n()) %>% 
  ggplot(aes(x = count, y = channel, fill = genre)) +
  geom_col(position = "stack") +
  theme_classic()
genre_by_channel_img
ggsave("genre_by_channel_img.png")

# Film release year by channel: boxplot
boxplot_channel_years <- data %>% 
  select(channel, year) %>% 
  ggplot(aes(x = channel, y = year)) +
  geom_boxplot() +
  theme_classic() +
  coord_flip() +
  xlab("") +
  ylab("")
boxplot_channel_years
ggsave("boxplot_channel_years.png")

library(lubridate)
data_no_syn <- data %>% 
  select(1:6) %>% 
  mutate(
    weekday = wday(date_time, label = TRUE, abbr = FALSE)
  ) %>% 
  relocate(weekday, .after = date_time) 

# Total number of films by weekday
# You fucking moron this is counting the number of weekdays, but most of them are the same
data_no_syn %>% 
  group_by(weekday, as.Date(date_time)) %>% 
  summarise(total = n(),
            mean(total))



