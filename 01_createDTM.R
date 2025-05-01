if (!require("pacman")) install.packages("pacman")
pacman::p_load( lidR, terra, sf, future)

# library(future)
## change these two lines below
inputdir <- "input/plots_pilotareas_lidardata/"
outputdir <- "output/plots_pilotareas_lidardata/"

if(!dir.exists(outputdir))  dir.create(showWarnings = T, outputdir)


## list of laz files using also subfolder
laz.files<-list.files(inputdir,
                      pattern=".*\\.laz$",
                      recursive = T,
                      full.names = T)

ctg <- lidR::catalog(laz.files)


ground_dtm_fun <- function(cluster) {
  las <- readLAS(cluster)
  if (is.null(las) || npoints(las) == 0) return(NULL)

  dtm <- rasterize_terrain(las, res = 1, algorithm = tin())  # Create DTM
  return(dtm)
}

## here you tell lidr how to call the outputs from the next line
opt_chunk_size(ctg) <- 0         # in meters
opt_chunk_buffer(ctg) <- 30        # prevents edge effects
opt_output_files(ctg) <- file.path(outputdir, "DTM_{ORIGINALFILENAME}")  # output file template
opt_progress(ctg) <- TRUE
opt_merge(ctg) <- FALSE
opt_wall_to_wall(ctg) <- FALSE

plan(multissesion, workers = 10L)
tt <- catalog_apply(ctg, ground_dtm_fun)

