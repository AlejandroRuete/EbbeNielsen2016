library(shiny)
library(shinythemes)
# library(shinyBS)
# library(shinyjs)
library(leaflet)
library(dplyr)
library(DT)

library(sf)
library(terra)

library(RColorBrewer)
# library(scales)
# library(lattice)

YearsRng<-c(1741,2016) #because I know! range(unique(AmpEur$year), na.rm = T)
Years<-c(NA, seq(YearsRng[1],YearsRng[2]))
YearsPlot<-Years
YearsPlot[1]<-Years[2]-1

# These bundled TIFFs were generated in Web Mercator, but their legacy
# metadata only describes an unnamed Cartesian CRS. Assigning the known
# CRS repairs metadata without resampling the original grid or values.
readObservationRaster <- function(path) {
  x <- terra::rast(path)
  if (!nzchar(terra::crs(x)) || grepl("^ENGCRS", terra::crs(x))) {
    terra::crs(x) <- "EPSG:3857"
  }
  if (!isTRUE(sf::st_crs(terra::crs(x)) == sf::st_crs(3857))) {
    stop("Expected a Web Mercator raster: ", path)
  }
  x
}

AmpEur100 <- readObservationRaster("data/AmpEur100.tif")
AmpEur50 <- readObservationRaster("data/AmpEur50.tif")
AmpEur25 <- readObservationRaster("data/AmpEur25.tif")

AmpEurR100 <- readObservationRaster("data/AmpEurR100.tif")
AmpEurR50 <- readObservationRaster("data/AmpEurR50.tif")
AmpEurR25 <- readObservationRaster("data/AmpEurR25.tif")

Rana100 <- readObservationRaster("data/Rana100.tif")
Rana50 <- readObservationRaster("data/Rana50.tif")
Rana25 <- readObservationRaster("data/Rana25.tif")

# The temporal datasets are R arrays, independent of the spatial packages.
load("data/AmpEur100Stacks.rData")

RanaPoly <- sf::st_read("data/species_58734/species_58734simp.shp", quiet = TRUE)
CountEurope <- sf::st_transform(
  sf::st_read("data/countries Europe.shp", quiet = TRUE), 3857
)
CountEuropeCnt <- sf::st_transform(
  sf::st_read("data/countries Europe mean.shp", quiet = TRUE), 3857
)

# Return vectors in raster cell order, rather than terra's default matrix.
rasterValues <- function(x) terra::values(x, mat = FALSE)

countryCells <- function(x, countries, countryPoints) {
  countries <- sf::st_transform(countries, sf::st_crs(terra::crs(x)))
  countryPoints <- sf::st_transform(countryPoints, sf::st_crs(countries))
  cells <- terra::extract(
    x, terra::vect(countries), cells = TRUE,
    touches = FALSE, small = FALSE
  )
  pointNames <- as.character(countryPoints$UID)
  lapply(seq_len(nrow(countries)), function(i) {
    selected <- sort(unique(cells$cell[cells$ID == i & !is.na(cells$cell)]))
    if (!length(selected)) {
      # Preserve the original fallback to the supplied mean country point.
      point <- countryPoints[pointNames == as.character(countries$CNTRY_NAME[i]), ]
      if (nrow(point)) {
        selected <- terra::cellFromXY(x, sf::st_coordinates(point)[, 1:2, drop = FALSE])
        selected <- sort(unique(selected[!is.na(selected)]))
      }
    }
    selected
  })
}

Countries<-as.character(CountEurope$CNTRY_NAME)
CountriesAb<-Countries
CountriesAb[43]<-"Bos. & Herz."
CountriesAb[29]<-"Isle of Man"

CountriesList<-Countries[order(CountriesAb)]
CountriesListAb<-CountriesAb[order(CountriesAb)]
CountriesNumbers<-c(1:length(Countries))[order(CountriesAb)]

