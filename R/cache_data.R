bfc = BiocFileCache::BiocFileCache(ask = FALSE)
zip_link = "https://figshare.com/ndownloader/files/41233761?private_link=5d52dfbf8481d1cfffc8"

#' Download and cache workshop data from CytoverseBioc2023:::zip_link
#' @param force Should we download and cache again even if it appears that data have already been downloaded?
#' @return [BiocFileCache::BiocFileCache()], invisibly
#' @export
#' @import BiocFileCache
cache_workshop_data = function(force = FALSE){
  if(nrow(bfcquery(bfc, "fcs_data"))==0 || force){
  withr::with_tempdir({
    options(timeout = max(3000, getOption("timeout")))
    utils::download.file(zip_link, "data.zip")
    utils::unzip("data.zip")
    data_files = list.files("data", recursive = TRUE, full.names = TRUE)
    for(f in data_files){
      bfcadd(bfc, f)
    }
  })
  }
  invisible(bfc)
}

#' @export
#' @describeIn cache_workshop_data return a `data.frame` with `rpath` pointing to the location of files whose paths match `path`
#' @param path `character` giving a path to file(s) in the original tarball
get_workshop_data = function(path){
  bfcquery(bfc, path)
}