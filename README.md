# Automatic Web Scraping of Spanish Public TV Films
This is a repository to automate the collection of data on films shown in Spanish public TV, named TDT. We use the R package for web scraping rvest and GitHub actions.

The data comes from the following website: https://www.elmundo.es/television/programacion-tv/peliculas.html

It is updated every day and provides the film title (both the original and the spanish version), the film genre, a brief film synopsis, the TV channel and the day and time.

In the workflows folder it is the .yaml file that calls GitHub to autoscrape the data, using a R Script.

If you want to see a report based on this data just clink the [link](https://rpubs.com/GuilleDiaz7/956062).


