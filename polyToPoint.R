directory <- "."
fileName <- "./data/Community_Plan_SD/Community_Plan_SD.shp"

library(rgeos)
library(maptools)

setwd(directory)

#shapeFile <- readShapeSpatial(fileName)
shapeFile <- readOGR("./data/Community_Plan_SD", "Community_Plan_SD")
latlon <- "+init=epsg:4326"


data <- as(shapeFile, "data.frame")
data$polygonID <- as.numeric(rownames(data))

#extracts the coodinates and polygon IDs
polygons <- slot(shapeFile,"polygons")
coordinates <- list(latitude = numeric(0),
                          longitude = numeric(0),
                          polygonID = numeric(0),
                          plotOrder = numeric(0))

#A slow looping aproach
for(i in 1:length(polygons)){
  polygon <- polygons[[i]]
  ID <- slot(polygon, "ID")
  coords <- data.frame(slot(slot(polygon,"Polygons")[[1]],"coords"))
  coords$plotOrder <- c(1:nrow(coords))
  coordinates$latitude <- c(coordinates$latitude, coords[,1])
  coordinates$longitude <- c(coordinates$longitude, coords[,2])
  coordinates$polygonID <- c(coordinates$polygonID, rep(ID,nrow(coords)))
  coordinates$plotOrder <- c(coordinates$plotOrder, c(1:nrow(coords)))
}

# Not super clean, TODO fix this.
combinedData <- merge(data, coordinates)
combinedData <- SpatialPointsDataFrame(select(combinedData, latitude, longitude), 
                              select(combinedData, -latitude, -longitude))
# First, set the original CRS
combinedData@proj4string <- shapeFile@proj4string

# Then convert to lat/lon crs
combinedData <- spTransform(combinedData, CRS(latlon))



filename <- paste(directory, "/data/tableau_out/", "convPolygons.csv", sep = "")
write.csv(as.data.frame(combinedData), filename, row.names = FALSE)





