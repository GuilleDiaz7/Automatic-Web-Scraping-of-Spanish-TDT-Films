# Exploratory Data Analysis

To load the dataset from this very same GitHub repo
```R
df <- read_csv("")
```

There are 16 variables in the dataset:
1. date_time: the date an
2. channel: the channel that broadcasted it
3. sp_title: the spanish title
4. original_title: the original title
5. year: the year the film was released
6. genre: the genre (unreliable or too broad)
7. country: film's cpuntry
8. length: length in munutes
9. description: a brief sinopsys
10. director: who directed the film (sometimes more than one)
11. writer: the writer/s of the script
12. photography: the phorographer/s (in film sense)
13. music: the music composer/s
14. producer: the producer/s
15. actors: a list of actors
16. production_company: the production company/ies

Data is completely available in the top 9 variables,  but there is quite a lot of missing data in the other variables.
```R
df %>% 
  summarise(across(everything(), ~sum(is.na(.))))
```
