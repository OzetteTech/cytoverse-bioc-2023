# Purpose: to load in a cytoset. The cytoset will necessarily have multiple panels to demonstrate error messages
# when attempting to create a GatingSet

#' Load a set of fcs files as a cytoset and attach mock metadata
#'
#' @param only_TNK only return the TNK panel
#'
#' @return [flowWorkspace::cytoset()]
#' @export
#' @import flowWorkspace
#' @import dplyr
make_cytoset = function(only_TNK = FALSE){
  cache_workshop_data()
  
  fcs_files <- get_workshop_data("fcs_data/")
  fcs_files_paths <- fcs_files$rpath
  
  if(only_TNK){
    fcs_files_paths <- dplyr::filter(fcs_files, grepl(pattern = "TNK-CR1",x = rname))$rpath
  }
  
  cs <- flowWorkspace::load_cytoset_from_fcs(files = fcs_files_paths)
  
  set.seed(20230725)
  metadata <- data.frame(name = sampleNames(cs),
                         status = "Healthy",
                         Treatment = sample(x = c("Treated","Control"),
                                            size = length(cs),
                                            prob = c(0.5,0.5),replace = TRUE),
                         panel = ifelse(grepl(pattern = "TNK",x = sampleNames(cs)),"T Cell Panel","Myeloid Panel"),
                         row.names = sampleNames(cs))
  
  pData(cs) <- metadata
  
  return(cs)
}

