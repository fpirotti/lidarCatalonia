if (!require("pacman")) install.packages("pacman")
pacman::p_load( lidR, terra, sf, doParallel, foreach)


## change these two lines below
inputdir <- "input"
outputdir <- "output"
dtm  <- file.path("Digital Terrain Model 5m 2020.tif")
if(!dir.exists(outputdir))  dir.create(outputdir)

dtm.r <- terra::rast(dtm)

# check dtm is good
print(dtm.r)

## list of laz files using also subfolder
laz.files<-list.files(inputdir,
                      pattern=".*\\.laz$",
                      recursive = T,
                      full.names = T)

## test on ten files! remove [1:10] to run in all
ctg  <- lidR::readLAScatalog(laz.files)


## here you tell lidr how to call the outputs from the next line
opt_output_files(ctg) <- file.path(outputdir, "{*}_classified")
##
classified_ctg <- classify_ground(ctg, csf())






