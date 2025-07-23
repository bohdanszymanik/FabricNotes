# too easy!

library(remotes)
install_github("yonghah/esri2sf")

library("esri2sf")
url <- "https://services1.arcgis.com/CPYspmTk3abe6d7i/arcgis/rest/services/CCTV_Viewsheds_(View_layer)/FeatureServer/0"

df <- esri2sf(url)
