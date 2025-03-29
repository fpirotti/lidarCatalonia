if (!require("pacman")) install.packages("pacman")
pacman::p_load( lidR, terra, sf, doParallel, foreach)


## change these two lines below
inputdir <- "input"
outputdir <- "output"

if(!dir.exists(outputdir))  dir.create(outputdir)

dtm <- terra::rast("/vsicurl/https://datacloud.icgc.cat/datacloud/met5_ETRS89/mosaic/met5_catalunya_2020.tif")

# check dtm is good
print(dtm)

## list of laz files using also subfolder
laz.files<-list.files(inputdir,
                      pattern=".*\\.laz$",
                      recursive = T,
                      full.names = T)

## test on ten files! remove [1:10] to run in all
# las <- lidR::readLAS(laz.files[[1]])

ctg  <- lidR::readLAScatalog(laz.files)

cleanCloud <- function(lasin, ws)
{
  las <- lidR::readLAS(lasin)
  if ( lidR::is.empty(las)) return(NULL)
  # do something
  # output <- las - dtm
  output <- lidR::filter_poi(las, Classification < 20L  )
  # remove the buffer of the output
  # bbox <- bbox(chunk)
  # output <- remove_buffer(output, bbox)
  return(output)

}

## here you tell lidr how to call the outputs from the next line
opt_output_files(ctg) <- file.path(outputdir, "{*}_distFromDTM")
opt_chunk_buffer(ctg) <- 0 # 10
# opt_chunk_size(ctg)   <- 100

opt    <- list(need_buffer = F,   # catalog_apply will throw an error if buffer = 0
               automerge   = F)   # catalog_apply will merge the outputs into a single object


opt_output_files(ctg) <- file.path(outputdir, "{*}_clean")
output.clean <- catalog_apply(ctg, cleanCloud, .options = opt)

ctg_clean <- lidR::readLAScatalog( unlist(output.clean))
opt_output_files(ctg_clean) <- file.path(outputdir, "{*}_classified")

mycsf01 <- csf(TRUE, 1, 1, time_step = 1)
ctg_classified <- classify_ground(ctg_clean, mycsf)


opt_output_files(ctg_classified) <- file.path(outputdir, "{*}_dtm_mycsf01")
dtm <- rasterize_terrain(ctg_classified, 1, tin())





