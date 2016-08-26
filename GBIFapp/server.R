palRWB <- colorNumeric(c("blue","white", "red"), c(0,1), na.color = "transparent")
palGWR <- colorNumeric(c("red","lightpink", "green4"), c(0,1), na.color = "transparent")
colCount<-c("black", "#7FC97F", "#BEAED4", "#FDC086", "#CDCD00", "#386CB0", "#F0027F", "#BF5B17", "#666666") # Accent
#colCount<-c("black","#9F0F44", "#D53E4F", "#E76835", "#EFAD54", "#F8DF8A", "#EBEA9A", "#B7D3A3", "#72BCA5", "#2A8ABC", "#554F95")
funM<-function(x, y, ...){
  return(max(c(x,y), na.rm=T))
}

shinyServer(function(input, output, session) {
  # Return the requested dataset
  obsInput <- reactive({
    switch(input$res,
           "100" = AmpEur100,
           "50" = AmpEur50,
           "25" = AmpEur25)
  })
  richInputRaw <- reactive({
    switch(input$res,
           "100" = AmpEurR100,
           "50" = AmpEurR50,
           "25" = AmpEurR25)
  })
  richInput <- reactive({
    tmpR<-richInputRaw()
    tmp0<-tmpR
    tmp0[]<-0
    switch(input$ngb,
           "1" = tmpR,
           "3" = localFun(tmpR, tmp0, ngb=3, fun=funM),
           "5" = localFun(tmpR, tmp0, ngb=5, fun=funM))
  })
  ranaInput <- reactive({
    switch(input$res,
           "100" = Rana100,
           "50" = Rana50,
           "25" = Rana25)
  })

ignorInput <- reactive({
  withProgress(message = 'Calculating Ignorance scores',
                value = 0, {
    obs <- obsInput()
    rich <- richInput()
    if(input$index==TRUE){
      o<-obs
      o<-obs/rich
      o[which(obs[]==0)]<-0
      obs<-o
    }
    res<-as.numeric(input$res)
    obs50<-input$obs50 * (res/25)^2
    setProgress(0.1)
    ign<-calc(obs, fun=function(x){return(obs50/(x+obs50))})
    setProgress(0.25)
    return(ign)
  })
}) # end ignorInput

sppPAInput<-reactive({
  withProgress(message = 'Calculating Pseudo Absences', 
               value = 0.25, {
    spp<-ranaInput()
    res<-as.numeric(input$res)
    obs50<-input$obs50spp * (res/25)^2
    setProgress(0.26)
    spp.psabs<- calc(spp, fun=function(x){return(obs50/(x+obs50))})
    return(spp.psabs)
    setProgress(0.5)
  })
}) # end reactive sppPA

sppPropInput<-reactive({ #Populaiton size index or Odds of sampling a species
  withProgress(message = 'Calculating Proportions', 
               value = 0.5, {
                 spp <-ranaInput()
                 obs <- obsInput()
                 # rich <- richInputRaw()
                 setProgress(0.51)
                 spp.prop<- overlay(spp, obs, fun=function(x,y){return(x/y)}) # Proportion of obs of spp over the total obs count
                 spp.prop[which(spp.prop[]==Inf)]<-0 ## Inf are errors between Rana and Amp layers, where Rana is present where no Obs are registered
                 return(spp.prop)
                 setProgress(0.6)
               })
}) # end spp odds

sppOddsInput<-reactive({ #Populaiton size index or Odds of sampling a species
  withProgress(message = 'Calculating Counts', 
               value = 0.6, {
                 spp <-ranaInput()
                 obs <- obsInput()
                 # rich <- richInputRaw()
                 setProgress(0.61)
                 spp.odd<- overlay(spp, obs, fun=function(x,y){return(x/y * x)}) # How many obs of spp per total obs count
                 spp.odd[which(spp.odd[]==Inf)]<-0 ## Inf are errors between Rana and Amp layers, where Rana is present where no Obs are registered
                 return(spp.odd)
                 setProgress(0.75)
               })
}) # end spp odds

sppPAcertInput<-reactive({
  withProgress(message = 'Calculating Species Presence', 
               value = 0.75, {
    setProgress(0.76)
    spp.abs<-overlay(sppPAInput(), 1-ignorInput(), fun="prod")
    spp.abs<-calc(spp.abs, fun=function(x) ifelse(x<=0.5, -99999, 1-x)) ## How sure  that it is not there 
    spp.pres<-calc(1-sppPAInput(), fun=function(x) ifelse(x<=(1-input$prestol), -99999, 1)) ##Has it been observed more than O0.5? #
    
    zero<-calc(spp.abs, fun=function(x) x<- -99999)  
    
    setProgress(0.85)
    
    s<-stack(spp.pres, spp.abs, zero) #zero to avoid warnings()
    spp.pa<-calc(s, fun=max, na.rm=TRUE) 
    spp.pa<-calc(spp.pa, fun=function(x) ifelse(x== -99999, NA, x))
    return(spp.pa)
    setProgress(1)
  })
})

###For Temporal Tab
obsDInput <- AmpEur100
obsTempInput <- AmpEur100Stack
richTempInput <- AmpEurR100Stack

obsResInput <- reactive({
  switch(input$resD,
         "100" = AmpEur100,
         "50" = AmpEur50,
         "25" = AmpEur25)
})
richResInput <- reactive({
  switch(input$resD,
         "100" = AmpEurR100,
         "50" = AmpEurR50,
         "25" = AmpEurR25)
})

ignor100ResInput <- reactive({
  withProgress(message = 'Calculating Ignorance scores', value = 0, {
   obs <- AmpEur100
   rich <- AmpEurR100
   if(input$indexD==TRUE){
      o<-obs
      o<-obs/rich
      o[which(obs[]==0)]<-0
      obs<-o
    }
    res<-100
    obs50<-input$obs50D * (res/25)^2
    setProgress(0.5)
    ign100<-calc(obs, fun=function(x){return(obs50/(x+obs50))})
    setProgress(1)
    return(ign100)
  })
}) # end ignorResInput

ignor50ResInput <- reactive({
  withProgress(message = 'Calculating Ignorance scores', value = 0, {
    obs <- AmpEur50
    rich <- AmpEurR50
    if(input$indexD==TRUE){
      o<-obs
      o<-obs/rich
      o[which(obs[]==0)]<-0
      obs<-o
    }
    res<-50
    obs50<-input$obs50D * (res/25)^2
    setProgress(0.5)
    ign50<-calc(obs, fun=function(x){return(obs50/(x+obs50))})
    setProgress(1)
    return(ign50)
  })
}) # end ignorResInput

ignor25ResInput <- reactive({
  withProgress(message = 'Calculating Ignorance scores', value = 0, {
    obs <- AmpEur25
    rich <- AmpEurR25
    if(input$indexD==TRUE){
      o<-obs
      o<-obs/rich
      o[which(obs[]==0)]<-0
      obs<-o
    }
    res<-25
    obs50<-input$obs50D * (res/25)^2
    setProgress(0.5)
    ign25<-calc(obs, fun=function(x){return(obs50/(x+obs50))})
    setProgress(1)
    return(ign25)
  })
}) # end ignorResInput

## Which cells for 100km res
withProgress(message = 'Extracting cells', value = 0, {
  whichCellCount100 <- cellFromPolygon(AmpEur100, CountEurope)
  whichTinyRef100<-which(lengths(whichCellCount100)==0)
  for(c in  1:length(whichTinyRef100)){
    
    whichTiny100<-which(as.character(CountEuropeCnt@data[,3]) == Countries[whichTinyRef100[c]])  
    whichCellCount100[whichTinyRef100[c]]<-cellFromXY(AmpEur100, CountEuropeCnt[whichTiny100,])  
  }
  setProgress(0.33)
  whichCellCount50 <- cellFromPolygon(AmpEur50, CountEurope)
  whichTinyRef50<-which(lengths(whichCellCount50)==0)
  for(c in  1:length(whichTinyRef50)){
    whichTiny50<-which(as.character(CountEuropeCnt@data[,3]) == Countries[whichTinyRef50[c]])  
    whichCellCount50[whichTinyRef50[c]]<-cellFromXY(AmpEur50, CountEuropeCnt[whichTiny50,])  
  }
  setProgress(0.66)
  whichCellCount25 <- cellFromPolygon(AmpEur25, CountEurope)
  whichTinyRef25<-which(lengths(whichCellCount25)==0)
  for(c in  1:length(whichTinyRef25)){
    whichTiny25<-which(as.character(CountEuropeCnt@data[,3]) == Countries[whichTinyRef25[c]])  
    whichCellCount25[whichTinyRef25[c]]<-cellFromXY(AmpEur25, CountEuropeCnt[whichTiny25,])  
  }
  setProgress(1)
})

ignorATInput <- reactive({ #ignorance of all times (selected)
  withProgress(message = 'Calculating Ignorance Scores', value = 0, {
    if(input$NAplot==FALSE) wY<-c(which(Years==input$time[1]):which(Years==input$time[2]))
    if(input$NAplot==TRUE) wY<-c(1, which(Years==input$time[1]):which(Years==input$time[2]))
    RasRef<-obsDInput #Raster Reference
    
    obs <- obsTempInput[,,wY]
    obs <- apply(obs,1:2,sum, na.rm=T)
    obs <- ifelse(is.na(RasRef[]),NA,obs)
    
    #stacking over sum species is actually not the count of all species seen, is more. Therefore we compare to all times richness AmpEruR100
    rich <- AmpEurR100[] #richTempInput[,,wY]
    #rich <- apply(rich,1:2,sum, na.rm=T) stacking over sum species is actually not the count of all species seen, is more. Therefore we compare to all times richness.
    #rich <- ifelse(is.na(RasRef[]),NA,rich)
    
    setProgress(0.25)
    if(input$indexD==TRUE){
      o<-obs
      o<-obs/rich
      o[which(obs==0)]<-0
      obs<-o
    }
    res<-100
    obs50<-input$obs50D * (res/25)^2
    CI<-obs50/(obs+obs50)
    return(CI)
    setProgress(0.5)
  })
}) # end ignorInput

ignorTempInput <- reactive({
  withProgress(message = 'Calculating Ignorance Scores', value = 0.5, {
    obs <- obsTempInput
    rich <- richTempInput
    
    if(input$indexD==TRUE){
      o<-obs
      o<-obs/rich
      o[which(obs[]==0)]<-0
      obs<-o
    }
    res<-100
    obs50<-input$obs50D * (res/25)^2
    CItemp<-obs50/(obs+obs50)
    return(CItemp)
    setProgress(0.1)
  })
}) # end ignorInput


###### Interactive Map ###########################################

  # Create the map
  # project=FALSE when adding the rasters becuase they are created as epsg:3857 as expected by leafleat
  output$map <- renderLeaflet({
    input$goButton 
    
    Ign<-isolate(ignorInput())
    popup <- "<strong><i>Rana temporaria</i> distribution</strong> (IUCN)"
    
    leaflet() %>%
      addTiles() %>% #options = tileOptions()
      setView(lng = 15, lat = 60, zoom = 4) %>% 
      addRasterImage(Ign, colors = palRWB, opacity = isolate(input$alpha), project=FALSE, layerId = "L") %>%
      addPolygons(data=RanaPoly, weight = 2, col = "black", fillOpacity = 0, popup = popup) %>%
      addLegend(position = "bottomright", colors = palRWB(c(0,0.2,0.4,0.6,0.8,1)), 
                labels = c(0,0.2,0.4,0.6,0.8,1), title = "Ignorance", opacity = isolate(input$alpha))
}) ## end render map

#### Add layer
observe({
  layer <- input$layer
  proxy <- leafletProxy("map")
 
  Ign<-isolate(ignorInput())
  spp.psabs<-isolate(sppPAInput()) #pseudo absences
  spp.prop<-isolate(sppPropInput()) #odds
  spp.odds<-isolate(sppOddsInput()) #odds
  spp.pa<-isolate(sppPAcertInput()) #certain PA absences
  maxOdd<-ceiling(max(spp.odds[], na.rm=TRUE))
  palYORprop <- colorNumeric(c("white","yellow","orange", "red"), c(0,1), na.color = "transparent")
  palYOR <- colorNumeric(c("white","yellow","orange", "red"), c(0,maxOdd), na.color = "transparent")

  popup <- "<strong><i>Rana temporaria</i> distribution</strong> (IUCN)"
  
  # Remove any existing legend, and only if the legend is
  # enabled, create a new one.
  proxy %>% clearShapes()
  proxy %>% removeImage("L")
  if(layer == "RTGIgn") proxy %>% addRasterImage(Ign, colors = palRWB, opacity = input$alpha, project=FALSE, layerId = "L") %>%
    addPolygons(data=RanaPoly, weight = 2, col = "black", fillOpacity = 0, popup = popup)
  if(layer == "SppIgn") proxy %>% addRasterImage(spp.psabs, colors = palRWB, opacity = input$alpha, project=FALSE, layerId = "L") %>% 
    addPolygons(data=RanaPoly, weight = 2, col = "black", fillOpacity = 0, popup = popup)
  if(layer == "SppProp" ) proxy %>% addRasterImage(spp.prop, colors = palYORprop, opacity = input$alpha, project=FALSE, layerId = "L") %>% 
    addPolygons(data=RanaPoly, weight = 2, col = "black", fillOpacity = 0, popup = popup)
  if(layer == "SppCount" ) proxy %>% addRasterImage(spp.odds, colors = palYOR, opacity = input$alpha, project=FALSE, layerId = "L") %>% 
    addPolygons(data=RanaPoly, weight = 2, col = "black", fillOpacity = 0, popup = popup)
  if(layer == "SppPres") proxy %>% addRasterImage(spp.pa, colors = palGWR, opacity = input$alpha, project=FALSE, layerId = "L") %>%
    addPolygons(data=RanaPoly, weight = 2, col = "black", fillOpacity = 0, popup = popup)
    
})
#### Change legend
observe({
  proxy <- leafletProxy("map")
  spp.prop<-isolate(sppPropInput()) #odds
  spp.odds<-isolate(sppOddsInput()) #odds
  maxOdd<- ceiling(max(spp.odds[], na.rm=TRUE))
  palYORprop <- colorNumeric(c("white","yellow","orange", "red"), c(0,1), na.color = "transparent")
  palYOR <- colorNumeric(c("white","yellow","orange", "red"), c(0,maxOdd), na.color = "transparent")
  
  # Remove any existing legend, and only if the legend is
  # enabled, create a new one.
  proxy %>% clearControls()
  layer <- input$layer
  if(layer == "RTGIgn") proxy %>% addLegend(position = "bottomright", colors = palRWB(c(0,0.2,0.4,0.6,0.8,1)), labels = c(0,0.2,0.4,0.6,0.8,1), title = "Ignorance", opacity = input$alpha)
  if(layer == "SppIgn") proxy %>% addLegend(position = "bottomright", colors = palRWB(c(0,0.2,0.4,0.6,0.8,1)), labels = c(0,0.2,0.4,0.6,0.8,1), title = "Ignorance", opacity = input$alpha)
  if(layer == "SppProp" ) proxy %>% addLegend(position = "bottomright", colors = palYORprop(seq(0,1, by=0.25)), labels = seq(0, 1, by=0.25), title = "PSI", opacity = input$alpha)
  if(layer == "SppCount" ) proxy %>% addLegend(position = "bottomright", colors = palYOR(seq(0,maxOdd, by=round(maxOdd/6))), labels = seq(0, maxOdd, by=round(maxOdd/6)), title = "PSI", opacity = input$alpha)
  if(layer == "SppPres") proxy %>% addLegend(position = "bottomright", colors = palGWR(c(0,0.1,0.2,0.3,0.4,0.5,1)), labels = c(0,0.1,0.2,0.3,0.4,0.5,1), title = "Presence", opacity = input$alpha)
})

  ## Temporal Bias ###########################################
output$TempIgn <- renderPlot({
  ignTmp<-ignorTempInput()
  ignTmpV<-apply(ignTmp, 3, mean, na.rm = TRUE)
  ign<-ignorATInput()
  ignM<-mean(ign, na.rm = TRUE)
  
  par(mar=c(4,4,1,1), las=1, cex=1.5)
  plot(Years[-1],ignTmpV[-1], type = "l", ylim=c(0,1), xlim=c(input$time[1],input$time[2]), lwd=3,
       xlab="Year", ylab="Mean Ignorance Score")
  if(input$NAplot==TRUE) points(input$time[2]-5, ignTmpV[1])
  points(input$time[2], ignM, pch=19)
  
  chosenCount<-input$countries
  if(length(chosenCount)>0){
    whichCount<-numeric()
    withProgress(message = 'Adding country', value = 0, {
      for(c in 1:length(chosenCount)){
        whichCount[c]<-which(Countries%in%chosenCount[c])
        wC<-whichCellCount100[[whichCount[c]]]
        ignMc<-mean(ign[wC], na.rm = TRUE)
        
        igntmp<-numeric(length(Years))
        if(length(wC)<1)igntmp<-rep(0,length(Years))
        if(length(wC)==1)for(y in 1:length(Years)) igntmp[y]<-ignTmp[,,y][wC]
        if(length(wC)>1) for(y in 1:length(Years)) igntmp[y]<-mean(ignTmp[,,y][wC], na.rm = TRUE)
        lines(YearsPlot[-1],igntmp[-1], col=colCount[c+1], lwd=2)
        if(input$NAplot==TRUE) points(input$time[2]-5, igntmp[1], col=colCount[c+1])
        points(input$time[2], ignMc, pch=19, col=colCount[c+1])
        incProgress(amount=1/c)
      }
      legend(input$time[1], 0.3, legend=c("Obsesrvations w/ year = NA", "Selected years (density plots below)"), 
             title="Mean over:", title.adj = 0, col=colCount[1], pch=c(1,19),  bty="n", yjust=1.2, cex=0.8)
    })
  }# end if
})

## Country Bias ###########################################
output$DensIgn <- renderPlot({
  ign<-ignorATInput()
  ign100<-ignor100ResInput()
  ign50<-ignor50ResInput()
  ign25<-ignor25ResInput()
  
  par(mar=c(4,4,1,1), las=1, cex=1.5)
  dens<-density(ign, from=0, to=1, na.rm=TRUE)
  plot(dens$x, dens$y/max(dens$y), xlim=c(0,1), ylim=c(0,1),lwd=2, type="l",
       xlab="Ignorance Score", ylab="Relative Density", main="")
  if(100 %in% input$resPlot){
    dens<-density(ign100[], from=0, to=1, na.rm=TRUE)
    lines(dens$x, dens$y/max(dens$y), lwd=1)
  }
  if(50 %in% input$resPlot){
    dens<-density(ign50[], from=0, to=1, na.rm=TRUE)
    lines(dens$x, dens$y/max(dens$y), lwd=1, lty=2)
  }
  if(25 %in% input$resPlot){
    dens<-density(ign25[], from=0, to=1, na.rm=TRUE)
    lines(dens$x, dens$y/max(dens$y), lwd=1, lty=3)
  }
  
  chosenCount<-input$countries
  if(length(chosenCount)>0){
    for(c in 1:length(chosenCount)){
      whichCount<-which(Countries%in%chosenCount[c])
      wC<-whichCellCount100[[whichCount]]
      wC50<-whichCellCount50[[whichCount]]
      wC25<-whichCellCount25[[whichCount]]
      if(length(wC)>1){
        dens<-density(ign[wC], from=0, to=1, na.rm=TRUE)
        lines(dens$x, dens$y/max(dens$y), col=colCount[c+1], lwd=2)
        if(100 %in% input$resPlot){
          dens<-density(ign100[][wC], from=0, to=1, na.rm=TRUE)
          lines(dens$x, dens$y/max(dens$y), col=colCount[c+1], lwd=1)
        }
      }
      if(length(wC50)>1){
        if(50 %in% input$resPlot){
          dens<-density(ign50[][wC50], from=0, to=1, na.rm=TRUE)
          lines(dens$x, dens$y/max(dens$y), col=colCount[c+1], lwd=1, lty=2)
        }
      }
      if(length(wC25)>1){
        if(25 %in% input$resPlot){
          dens<-density(ign25[][wC25], from=0, to=1, na.rm=TRUE)
          lines(dens$x, dens$y/max(dens$y), col=colCount[c+1], lwd=1, lty=3)
        }
      }
    }
  } #end if length
})

output$Legend <- renderPlot({
  chosenCount<-input$countries
  if(length(chosenCount)>0){
    whichCount<-numeric()
    for(c in 1:length(chosenCount)){
      whichCount[c]<-which(Countries%in%chosenCount[c])
    }
  }else{whichCount<-numeric()}
  par(mar=c(4,1,1,1), las=1, cex=1.2)
  plot(1,1, type="n", xaxt="n", yaxt="n", bty = "n", xlab="", ylab="")
  legend("topleft", legend=c("Europe", CountriesAb[whichCount]), col=colCount[1:(length(chosenCount)+1)], 
         lwd=c(3,rep(2,length(chosenCount))),  bty = "n", ncol = 6)
  legend("topleft", legend=c("Selected Years @100km"), lwd=2, bty = "n", horiz = TRUE, inset= c(0,ifelse(length(chosenCount)<5,0.1,0.2)))
  legend("topleft", legend=c("All Years @100km","All Years @50km","All Years @25km"),
       lwd=c(1,1,1), lty = c(1,2,3),  bty = "n", horiz = TRUE, inset= c(0,ifelse(length(chosenCount)<5,0.2,0.3)))
})

## Table per country Bias ###########################################
tableIgn<-reactive({
  ignRes100<-ignor100ResInput()# is a Raster
  ignRes50<-ignor50ResInput()# is a Raster
  ignRes25<-ignor25ResInput()# is a Raster
  #ign<-ignorATInput() #is a matrix
  
  nocell100<-numeric(); nocell50<-numeric(); nocell25<-numeric()
  mean100<-numeric(); mean50<-numeric(); mean25<-numeric()
  
  for(c in 1:length(CountriesNumbers)){
    whichCount<-which(Countries%in%CountriesList[c])
    wCres100<-whichCellCount100[[whichCount]]
    wCres50<-whichCellCount50[[whichCount]]
    wCres25<-whichCellCount25[[whichCount]]
    
    nocell100[c]<-length(wCres100)
    mean100[c]<-round(mean(ignRes100[][wCres100], na.rm=TRUE), 2)
    nocell50[c]<-length(wCres50)
    mean50[c]<-round(mean(ignRes50[][wCres50], na.rm=TRUE), 2)
    nocell25[c]<-length(wCres25)
    mean25[c]<-round(mean(ignRes25[][wCres25], na.rm=TRUE),2)
  }
  tableIgn<-data.frame("Country"=CountriesListAb,
                       "No.cells @100km" = nocell100,
                       "Mean @100km " = mean100, 
                       "No.cells @50km" = nocell50,
                       "Mean @50km" = mean50,
                       "No.cells @25km" = nocell25,
                       "Mean @25km" = mean25)
  return(tableIgn)
})

output$TableIgn <- renderDataTable({
  table<-tableIgn()
  ## Container for table
  tworows = htmltools::withTags(table(
    class = 'cell-border stripe',
    thead(
      tr(
        th(rowspan = 2, 'Country'),
        th(colspan = 2, '@100 km'),
        th(colspan = 2, '@50 km'),
        th(colspan = 2, '@25 km')
      ),
      tr(
        lapply(rep(c('No. cells', 'Mean Ign'), 3), th)
      )
    )
  )) #end tworows
  
  chosenCount<-input$countries
  if(length(chosenCount)>0){
    whichCount<-numeric()
    for(c in 1:length(chosenCount)){
      whichCount[c]<-which(CountriesListAb%in%chosenCount[c])
    }
  }else{whichCount<-numeric()}
  
  datatable(table, 
            rownames = FALSE,
            container = tworows, 
            selection = list(mode = 'multiple', selected = whichCount), 
            options = list(pageLength = 20, 
                           lengthMenu = c(10, 20, 50)))
})

}) # end server function
