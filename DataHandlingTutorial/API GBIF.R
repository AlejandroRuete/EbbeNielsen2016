# install.packages("httr")
library(httr)

## http://www.gbif.org/developer/maps

#the tile is in Andorra
#resolution = 1
sample1 <- GET("http://api.gbif.org/v1/map/density/tile?x=258&y=189&z=9&type=TAXON&key=131&resolution=1&layer=OBS_NO_YEAR&layer=OBS_1900_1910&layer=OBS_1910_1920&layer=OBS_1920_1930&layer=OBS_1930_1940&layer=OBS_1940_1950&layer=OBS_1950_1960&layer=OBS_1960_1970&layer=OBS_1970_1980&layer=OBS_1980_1990&layer=OBS_1990_2000&layer=OBS_2000_2010&layer=OBS_2010_2020&layer=LIVING&palette=yellows_reds")
content(sample1)
image(content(sample1)[,,1])

#resolution = 16
sample1 <- GET("http://api.gbif.org/v1/map/density/tile?x=258&y=189&z=9&type=TAXON&key=131&resolution=16&layer=OBS_NO_YEAR&layer=OBS_1900_1910&layer=OBS_1910_1920&layer=OBS_1920_1930&layer=OBS_1930_1940&layer=OBS_1940_1950&layer=OBS_1950_1960&layer=OBS_1960_1970&layer=OBS_1970_1980&layer=OBS_1980_1990&layer=OBS_1990_2000&layer=OBS_2000_2010&layer=OBS_2010_2020&layer=LIVING&palette=yellows_reds")
content(sample1)
image(content(sample1)[,,1])


#resolution = 16
sample1 <- GET("http://api.gbif.org/v1/map/density/tile?x=32&y=23&z=6&type=TAXON&key=131&resolution=16&layer=OBS_NO_YEAR&layer=OBS_1900_1910&layer=OBS_1910_1920&layer=OBS_1920_1930&layer=OBS_1930_1940&layer=OBS_1940_1950&layer=OBS_1950_1960&layer=OBS_1960_1970&layer=OBS_1970_1980&layer=OBS_1980_1990&layer=OBS_1990_2000&layer=OBS_2000_2010&layer=OBS_2010_2020&layer=LIVING&palette=yellows_reds")
content(sample1)
image(content(sample1)[,,1])

#Years
sample1 <- GET("http://api.gbif.org/v1/map/density/tile?x=258&y=189&z=9&type=TAXON&key=131&resolution=1&layer=OBS_NO_YEAR&layer=OBS_1900_2020&layer=LIVING&palette=yellows_reds")
content(sample1)
image(content(sample1)[,,1])

### ArtData
#http://slwgeo.artdata.slu.se:8080/geoserver/web/
sample1 <- GET("http://slwgeo.artdata.slu.se:8080/geoserver/SLW/wms?service=WMS&version=1.1.0&request=GetMap&layers=SLW:OccurrencesAndTaxaCountPer10KmGridCell")
content(sample1)

library(leaflet)
leaflet() %>%
  #setView(lng=9.0,lat=47.0,zoom=12)%>%
  addTiles(
    urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
    attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
  ) %>%
  #addRasterImage(raster(content(sample1)[,,1]), project=FALSE)
  addTiles(urlTemplate = "http://api.gbif.org/v1/map/density/tile?x={x}&y={y}&z={z}&type=TAXON&key=131&resolution=8&layer=OBS_NO_YEAR&layer=OBS_1900_1910&layer=OBS_1910_1920&layer=OBS_1920_1930&layer=OBS_1930_1940&layer=OBS_1940_1950&layer=OBS_1950_1960&layer=OBS_1960_1970&layer=OBS_1970_1980&layer=OBS_1980_1990&layer=OBS_1990_2000&layer=OBS_2000_2010&layer=OBS_2010_2020&layer=LIVING&palette=yellows_reds",
          attribution = 'Data source: <a href="http://gbif.org">GBIF</a>')#%>%
  #addTiles(urlTemplate = "http://slwgeo.artdata.slu.se:8080/geoserver/SLW/wms?service=WMS&version=1.1.0&request=GetMap&layers=SLW:OccurrencesAndTaxaCountPer10KmGridCell&tile?x={x}&y={y}&z={z}")#%>%
  # addLegend(position = "bottomright", title = "Observations")

