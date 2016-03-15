directory <- "."

library(rgdal) #conatins the read/writeOGR for reading shapelies and read/writeRGDAL for reading raster data
library(rgeos) # neccessary for ggplot2::fortify.sp(); serves as a replacement for gpclib
library(maptools) #Contains the overlay command
library(dplyr) # For data magic

setwd(directory)

# Lat / Lon projection string.
latlon <- "+init=epsg:4326"

gasStations <- readOGR("./data/Gas_Stations", 
                       layer = "GAS_STATIONS")

com_plan <- readOGR("./data/Community_Plan_SD", 
                    layer = "Community_Plan_SD")

# The Proj4Strings should match, but set the gas stations to match com_plan.
# TODO -- learn more about this. I'm not sure if this is correct.

# Peform the spatial join
gasStationsCPD <- over(gasStations, com_plan)

# This gives us a df with 787 rows (the amt of rows in GasStations), with
# blank rows not matching any cpd.  Let's see how many don't match

nMatches <- nrow(gasStationsCPD[complete.cases(gasStationsCPD), ])

## nMatches = 291.  Makes sense since the gas stations dataset is for the region.

# Since it's really based by rownumber, let's do a safe join of the new 
# gas station data, and the gas stations belonging in each community planning
# district.
# We can use R to filter out here the gas stations that did not match,
# but we want to do this in Tableau.
gasStations@data <- as.data.frame(bind_cols(gasStations@data, gasStationsCPD))

# Lastly, since Tableau can't read shapefiles data, 
# lets generate a csv with lat long

# First, let's adjust the coordinates to lat/long
gsDF <- spTransform(gasStations, CRS(latlon))

gsDF <- as.data.frame(gsDF) %>%
    rename(latitude = coords.x1, longitude = coords.x2)

write.csv(gsDF, file = "./data/tableau_out/gas_stations.csv")
