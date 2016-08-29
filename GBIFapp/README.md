Exploration of Ignorance Scores over Space and Time
================================================================================

This is an interactive application that exemplifies the use of the half-ignorance algorithm <abbr title="Ruete A. 2015. Displaying bias in sampling effort of data accessed from biodiversity databases using ignorance maps. Biodiversity Data Journal 3:e5361"><font color="blue">[1]</font></abbr> to map the ignorance (i.e. bias and lack of sampling effort) inherent to the observations stored in the Global biodiversity Information Facility <a href="http://www.gbif.org"> (GBIF)</a> and downloaded in any of the ways detailed in the tutorials found here.</p>

You can test it <a href="https://aleruete.shinyapps.io/GBIFapp/">here</a> or run it locally in your computer. To run it locally you will need to install <a href="http://www.r-project.org/">R</a> and install the following packages: shiny, shinythemes, leaflet, dplyr, DT, rgdal, raster, maptools, RColorBrewer.

       install.packages(c("shiny", "shinythemes", "leaflet", "dplyr", "DT", "rgdal", 
       "raster", "maptools", "RColorBrewer"))

NOTE: there are some known issues when installing the package "rgdal" on Linux. Please, refer to this blog <http://robinlovelace.net/r/2013/11/26/installing-rgdal-on-ubuntu.html>  or this blog <https://philmikejones.wordpress.com/2014/07/14/installing-rgdal-in-r-on-linux/> to solve the issue.

Execute the following script in R to run the interactive application.

       require(shiny)
       shiny::runGitHub(repo="EbbeNielsen2016", username="alejandroruete", subdir="GBIFapp")

Alternatively, download the files and run the following scripts.

       runApp("~/GBIFapp") # where ~ indicates the path of the folder.
       runApp("~/GBIFapp", display.mode = "showcase") # Use this command to see the R code

### Running the application
This example is focused on the Amphibians of Europe as the reference taxonomic group (RTG). In the first tab &quot;<b>Spatial Bias</b>&quot;  we look at the bias purely over space. Here, we also include data for <i>Rana temporaria</i> as a focal species. Plotted in black is the best estimate of the species distribution according to the <a href="http://www.iucnredlist.org/technical-documents/spatial-data">IUCN</a> in order to illustrate the spatial bias present on observations for the RTG and for a particular species. 

The O<sub>0.5</sub> parameter defines the number of observations required to decrease the ignorance score (IS) to 0.5 (see the reference above). Here, in order to easily compare among scales, this parameter is defined scale dependent, that is, relative to the minimum resolution available (O<sub>0.5</sub> = 1 @25km <=> O<sub>0.5</sub> = 16 @100km). When the <em>Observation Index</em> check-box is ticked the number of observations for the RTG is relative to the observed number of species in the same grid cell, or the maximum observed in the 3x3 or 5x5 cells neighborhood <abbr title="A different approach could be used instead to better estimate richness, if needed. Read the general description page mentioned above for more details about the use of the observation index"><font color="blue">[2]</font></abbr>.</p>

<p>From the <em>Layers</em> selector you can switch between:</p> 
<ol>
  <li>RTG Ignorance Map (0 = <i>enough</i> knowledge, 1 = complete ignorance)</li>
  <li>Species Ignorance Map</li>
  <li>Proportion of focal species observations over RTG (i.e. Population Size Index <abbr title="Jeppsson T., et al. 2010. The use of historical collections to estimate population trends: A case study using Swedish longhorn beetles (Coleoptera: Cerambycidae). Biological Conservation. 143, 1940-1950."><font color="blue">[3]</font></abbr>, the odds of observing the species in a random sample of all observed species)</li>
  <li>Count of focal species observations</li>
  <li>Species Presence-Absence Map</li>
</ol>
<p>The last layer is an example of how and where presence-absence could be inferred only from available data. Cells are colored <b><font color="green">green</font></b> when the species has been observed with an ignorance lower the  value set by the slider <em>Max Ignorance for Presence</em>. That is, if the  O<sub>0.5</sub> <i>Rana temporaria</i> is set to 1 and resolution to 100 km, then 16 observations are required per grid cell to reduce IS to 0.5. Then, if <em>Max Ignorance for Presence</em> is set to 0.5, cells where there were 16 observation of the species or more will be colored green. Else, given the assumptions, there is not enough certainty about the presence of the species. Then, the definition of presence depends on the definition of ignorance about the species. However, cells are colored <b><font color="red">red</font></b> if observations are <i>enough</i> for the RTG, but the species was not detected. Red cells get lighter the less knowledge there is about the RTG, up to a point where absences of the species are equally likely than lack of observations. Cell where ignorance is higher than 0.5 are not colored in this layer as nothing can be said about the species (or RTG) using only this data.</p>

<p>In the second tab &quot;<b>Temporal and Grouped Bias</b>&quot; only ignorance scores for the RTG are explored. The options here are similar to the previous tab. Here, however, ignorance is sliced trough time, and grouped by country at different resolutions. The aim is to explore when and where were observations collected. For agility reasons the temporal analysis is done only with 100 km grids cells. However, the resolution analysis uses always all observations. Here we can see the influence of data without a specified year of collection, summarize ignorance scores per country, rank them, and compare how does mean ignorance change at difference resolutions. In general, if observation indices are used, and the number of cells is high enough not to bias the average, average ignorance scores are similar across scales.</p>
<p>Similar summaries could be done to compare any area of interest e.g. ecoregions or biomes.</p>

<p><o:p></o:p></p>

<p>Author: Alejandro Ruete PhD, 2016<br>Department of Ecology, Swedish University of Agricultural Sciences (SLU). Uppsala, Sweden. </p>

<p>E-mail: <a href="mailto:aleruete@gmail.com">aleruete@gmail.com</a><u></u></p>

<p><i>Keywords</i>: citizen-science data, open-access biodiversity database, presence-only data, sampling effort, spatial bias, species distribution model, temporal bias</p>
