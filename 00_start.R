if (!require("pacman")) install.packages("pacman")
pacman::p_load( lidR, terra, sf, doParallel, foreach)


## change these two lines below
inputdir <- "C:/Users/erico.kutchartt/OneDrive - Generalitat de Catalunya/Escritorio/full10km2551"
outputdir <- "C:/Users/erico.kutchartt/OneDrive - Generalitat de Catalunya/Escritorio/full10km2551_output"
if(!dir.exists(outputdir))  dir.create(outputdir)

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






