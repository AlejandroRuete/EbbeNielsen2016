require(raster)
require(rgdal)
library(maptools)

Swe<-readShapePoly("data/Sweden Simple Sweref.shp", proj4string=CRS("+proj=utm +zone=33 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"))
GreyColors<-colorRampPalette(c("white", "black"),interpolate="spline", space="Lab")( 16 )
RedBlue<-colorRampPalette(c("blue","white", "red"),interpolate="spline", space="Lab")( 11 )
Topo<-terrain.colors(16)
Topo[16]<-"#FFFFFFFF"

Amp <- raster("data/Amp.tif")
AmpR <- raster("data/Amp richness.tif")
Buf<-raster("data/Buf.tif")
Pel<-raster("data/Pel.tif")

Bir <- raster("data/Bir.tif")
BirR <- raster("data/Bir richness.tif")
Par<-raster("data/Par.tif")
Poe<-raster("data/Poe.tif")

Pae <- raster("data/Pae.tif")
PaeR <- raster("data/Pae richness.tif")
Pap<-raster("data/Pap.tif")
Col<-raster("data/Col.tif")

Mam <- raster("data/MamLnB.tif")
MamR <- raster("data/MamLnB richness.tif")
Alc<-raster("data/Alc.tif")
Eri<-raster("data/Eri.tif")

Opi <- raster("data/Opi.tif")
OpiR <- raster("data/Opi richness.tif")
Opca<-raster("data/Opc.tif")
Lac<-raster("data/Lac.tif")

Odo <- raster("data/Odo.tif")
OdoR <- raster("data/Odo richness.tif")
Lib<-raster("data/Lib.tif")
Neh<-raster("data/Neh.tif")

Vas <- raster("data/Vas.tif")
VasR <- raster("data/Vas richness.tif")
Pan<-raster("data/Pan.tif")
Eup<-raster("data/Eup.tif")

cellwdata<-which(!is.na(Amp[]))