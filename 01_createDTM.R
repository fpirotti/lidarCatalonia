if (!require("pacman")) install.packages("pacman")
pacman::p_load( lidR, terra, sf, future)

crs <- "EPSG:6708"
# library(future)
## change these two lines below
inputdir <- "input/plots_pilotareas_lidardata/"
outputdir <- "output/plots_pilotareas_lidardata/"

createDTM <- function(inputdir, outputdir, crs="EPGS:4326", limit=Inf,res=1, pattern=".*\\.la[zs]$"){

  if(!dir.exists(inputdir)) stop(inputdir, " non esiste.")
  if(!dir.exists(outputdir))  dir.create(recursive = T, outputdir)
  ## list of laz files using also subfolder
  browser()
  laz.files<-list.files(inputdir,
                        pattern=pattern,
                        recursive = T,
                        ignore.case = T,
                        full.names = T)
  if(limit != Inf){
    message("Limito a ", limit, " LAS/Z files...")
    laz.files<-laz.files[1:limit]
  }

  ctg <- lidR::catalog(laz.files)
  st_crs(ctg) <- crs

  ground_dtm_fun <- function(cluster) {
    las <- readLAS(cluster)
    if (is.null(las) || npoints(las) == 0) return(NULL)
    dtm <- rasterize_terrain(las, res = res, algorithm = tin())  # Create DTM
    return(dtm)
  }




  ## here you tell lidr how to call the outputs from the next line
  opt_chunk_size(ctg) <- 0         # in meters
  opt_chunk_buffer(ctg) <- 0        # prevents edge effects
  opt_output_files(ctg) <- file.path(outputdir, "DTM_{ORIGINALFILENAME}")  # output file template
  opt_progress(ctg) <- TRUE
  opt_merge(ctg) <- FALSE
  opt_wall_to_wall(ctg) <- FALSE
  plan(multisession, workers = as.integer(future::availableCores()/2) )
  message("Uso ", as.integer(future::availableCores()/2) , " cores")
  tt <- catalog_apply(ctg, ground_dtm_fun)
}


createDTM(inputdir, outputdir,crs = crs, pattern = ".*D459.*\\.la[zs]$")

#
# sf_polygons <- lapply(ctg$filename, function(las) {
#   h <- readLASheader(las)
#   bbox <- c(xmin = h@PHB$`Min X`, xmax = h@PHB$`Max X`,
#             ymin = h@PHB$`Min Y`, ymax = h@PHB$`Max Y`)
#   coords <- matrix(c(
#     bbox["xmin"], bbox["ymin"],
#     bbox["xmin"], bbox["ymax"],
#     bbox["xmax"], bbox["ymax"],
#     bbox["xmax"], bbox["ymin"],
#     bbox["xmin"], bbox["ymin"]
#   ), ncol = 2, byrow = TRUE)
#
#   # Convert to sf polygon
#   polygon <- st_polygon(list(coords))
#   return(polygon)
# })
#
# sf_polygons_sf <- st_sfc( sf_polygons , crs = crs)
# write_sf(sf_polygons_sf, "output/plots_pilotareas_lidardata/tiles.gpkg")
# If you'd like, convert to an sf data frame (e.g., with filenames as attribute)
# sf_polygons_df <- st_sf(filename = file_paths, geometry = sf_polygons_sf)



