# Automatic-Web-Scraping-of-Spanish-TDT-Films
This is a repository to automatise the scraping of every film shown in the Spanish public TV, using rvest and GitHub actions.

The data comes from the following website: https://www.elmundo.es/television/programacion-tv/peliculas.html

It is updated every day and gives the film title, the film genre, a brief film synopsis, the TV channel and the day and time.

In the workflows folder it is the .yaml file that calls GitHub to autoscrape the data, using a R Script.
