zip_link = "http://cdn.ozetteai.com/cytoverse-data-5-july-2023.tar.xz"

.get_cache = function()
  {
    cache = tools::R_user_dir("CytoVerseBioc2023", which="cache")
    BiocFileCache::BiocFileCache(cache, ask =  interactive())
  }

#' Download and cache workshop data from CytoverseBioc2023:::zip_link
#' @param force Should we download and cache again even if it appears that data have already been downloaded?
#' @return [BiocFileCache::BiocFileCache()], invisibly
#' @export
#' @import BiocFileCache
cache_workshop_data = function(force = FALSE){
  bfc = .get_cache()
  if(nrow(bfcquery(bfc, "fcs_data"))==0 || force){
  withr::with_tempdir({
    options(timeout = max(3000, getOption("timeout")))
    utils::download.file(zip_link, "data.tar.xz")
    utils::untar("data.tar.xz")
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
  bfc = .get_cache()
  bfcquery(bfc, path)
}