library(feather)

dataPath = "data.feather"

loadHealthData <- function() {
  if (!file.exists(dataPath)) {
    stop(paste("Cannot find Health data dump under", dataPath, ". Ensure",
               "that the file has been created at this path using the",
               "exporter.py script."))
  } else {
    read_feather(dataPath)
  }
}
