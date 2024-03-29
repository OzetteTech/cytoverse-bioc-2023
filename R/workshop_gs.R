# Purpose: Run through a script to create a GatingSet

#' Transform and attach gates to TNK-CR data
#'
#' @param add_gates Should we gate the object, too?
#'
#' @return [flowWorkspace::GatingSet()]
#' @export
#' @import flowWorkspace
#' @import flowStats
make_transformed_gs = function(add_gates = FALSE) {
  cache_workshop_data()
  
  # create a cytoset
  fcs_files <- get_workshop_data("fcs_data/")
  fcs_files_TNK <-
    dplyr::filter(fcs_files, grepl(pattern = "TNK-CR1", x = rname))
  cs <-
    flowWorkspace::load_cytoset_from_fcs(files = fcs_files_TNK$rpath,
                                         pattern = "TNK-CR1")
  
  # add mock metadata
  set.seed(123)
  meta <- data.frame(
    name = stringr::str_match(fcs_files_TNK$rname, "4[^.]+"),
    status = "Healthy",
    panel = "T Cell",
    mock_treatment = rep(c("Control", "Treated"), length.out = length(cs)),
    row.names = sampleNames(cs)
  )
  pData(cs) <- meta
  
  # creating a GatingSet
  gs <- flowWorkspace::GatingSet(cs)
  sampleNames(gs) <- pData(gs)$name
  
  spill <-
    keyword(gs[[1]], "$SPILLOVER") # extract spillover matrix stored within the file
  
  compensate(gs, spill) # GatingSet will be compensated and stores the spill matrix as well
  
  recompute(gs) # update the gs
  
  t.rds <-
    dplyr::filter(get_workshop_data("/fj_wsp"),
                  # a previously defined transformation
                  grepl(pattern = "transform",
                        x = rname))$rpath
  my_trans <- readRDS(file = t.rds)
  
  # make into transformerList object
  my_trans_list <-
    flowWorkspace::transformerList(from = names(my_trans),
                                   trans = my_trans)
  
  gs <-
    flowWorkspace::transform(gs, my_trans_list) # transforms underlying data
  
  if (add_gates) {
    # calculate and add a singlet gate
    singlet_gate <-
      fsApply(gs_pop_get_data(gs), function(x) {
        # sample wise calculation using fsApply
        flowStats::gate_singlet(
          x,
          filterId = "singlet",
          # name for the gate
          wider_gate = FALSE,
          # indicate if the returned gate should be linient
          prediction_level = 0.95,
          subsample_pct = 0.5 # percent of events to sample to calculate the gate
        )
      })
    
    # add gate to the GatingSet
    gs_pop_add(gs, singlet_gate, parent = "root") # add singlet_gate to the root node
    recompute(gs) # recompute updates the gs
    
    # calculate a live gate
    ## Example of a quantile gate
    live_gate <-
      fsApply(gs_pop_get_data(gs, "singlet"), # indicating that estimation should be done on filtered data: singlet
              function(x) {
                gate <- openCyto::gate_quantile(
                  fr = x,
                  channel = "U450-A",
                  probs = 0.95,
                  filterId = "live"
                )
                
                # keep negative events
                gate@max <- gate@min
                gate@min <- -Inf
                return(gate)
              })
    
    # add live gate
    gs_pop_add(gs, parent = "singlet", gate = live_gate)
    recompute(gs)
    
    # calculate lymphocyte gate
    ## Example of using flowClust
    lymphocyte_gate <- fsApply(gs_pop_get_data(gs, "live"),
                               function(x) {
                                 openCyto::gate_flowclust_2d(
                                   fr = x,
                                   xChannel = "FSC-A",
                                   yChannel = "SSC-A",
                                   filterId = "lymphocytes",
                                   K = 1,
                                   target = c(1E5, 0.5E3)
                                 )
                               })
    # call it lymphocytes
    lymphocyte_gate <- lapply(lymphocyte_gate,
                              function(x) {
                                x@filterId <- "lymphocytes"
                                x
                              })
    
    # add lymphocyte gate
    gs_pop_add(gs, parent = "live", gate = lymphocyte_gate)
    recompute(gs)
    
    
    # add T cells gate
    ## Example of rectangleGate
    # using rectangle gate to add T cell gate
    cd3_rectanlge <- matrix(
      c(140, 205, 0, 200),
      nrow = 2,
      ncol = 2,
      byrow = F,
      dimnames = list(NULL, c("V510-A", "U570-A"))
    ) # channel names
    cd3_rectangle_gate <-
      rectangleGate(.gate = cd3_rectanlge, filterId = "CD3+ T cells")
    
    # add gate
    gs_pop_add(gs, gate = cd3_rectangle_gate, parent = "lymphocytes")
    recompute(gs)
    
    # add NKT cell gate
    ## Example of polygonGate
    # define coordinates
    nkt_poly <- matrix(
      c(115, 140,
        150, 150,
        150, 180,
        200, 180,
        200, 140),
      # coordinates
      ncol = 2,
      byrow = T,
      dimnames = list(NULL, c("R670-A", "V510-A"))
    )
    
    # convert to gate
    nkt_poly_gate <- polygonGate(nkt_poly,
                                 filterId = "NKT cells")
    # move gate and make smaller
    nkt_poly_gate <- flowCore::transform_gate(nkt_poly_gate,
                                              dx = 1,
                                              scale = c(1.05, 1.05))
    
    # add to gs
    gs_pop_add(gs, nkt_poly_gate, parent = "CD3+ T cells")
    recompute(gs)
    
    # Add non-NKT cells
    ## Example rangeGate
    
    # make a list of sample specific gates
    non_nkt <- lapply(gs,
                      function(x) {
                        ff <-
                          gh_pop_get_data(x, "CD3+ T cells") # extract data at specific node for cleaner calculation
                        flowStats::rangeGate(
                          ff,
                          stain = "R670-A",
                          filterId = "non-NKT Cells",
                          positive = FALSE,
                          alpha = 0.1
                        )
                      })
    
    non_nkt$`4002_TNK-CR1` <-
      transform_gate(non_nkt$`4002_TNK-CR1`,
                     dx = 25)
    
    # add non_nkt
    gs_pop_add(gs, non_nkt, parent = "CD3+ T cells")
    recompute(gs)
    
    # identify conventional T cells
    # Example use multiple gating tools and piping
    ## Estimate gate by sampling the gatinset
    conv_t_cell_gate <- gs |>
      gs_pop_get_data(y = "non-NKT Cells") |>
      cytoset_to_flowSet() |>
      (function(x) {
        set.seed(123)
        sample_n <- 1E3
        all_exprs <-
          fsApply(x, function(y)
            exprs(y)[sample(nrow(y), sample_n),])
        all_exprs <- flowFrame(all_exprs)
        attrs = c("min", "max")
        # identify cutpoints
        g1 <- openCyto::gate_quantile(all_exprs,
                                      channel = "B515-A",
                                      prob = 0.98)
        g1_attrs <- sapply(attrs, function(y) {
          attr(g1, y)
        })
        g2 <- openCyto::gate_quantile(all_exprs,
                                      channel = "G575-A",
                                      prob = 0.90)
        g2_attrs <- sapply(attrs, function(y) {
          attr(g2, y)
        })
        
        # get cutpoints
        g1_cutpoint <- g1_attrs[!is.infinite(g1_attrs)]
        g2_cutpoint <- g2_attrs[!is.infinite(g2_attrs)]
        
        # make rectangleGate
        qg <- rectangleGate(list(
          "B515-A" = c(g1_cutpoint,-Inf),
          "G575-A" = c(g2_cutpoint,-Inf)
        ),
        filterId = "conv_Tcells")
        
      })()
    
    # adjust gates
    conv_t_cell_gate <- flowCore::transform_gate(conv_t_cell_gate,
                                                 dx = 11,
                                                 dy = 11)
    
    # add quad gate
    gs_pop_add(gs, conv_t_cell_gate, parent = "non-NKT Cells")
    recompute(gs)
    
    # identify MAIT cells
    # add MAIT cells
    ## Example of estimation using collapsed data
    set.seed(2023)
    mait_gate_all <-
      openCyto::gate_flowclust_2d(
        fr =  flowFrame(fsApply(gs_pop_get_data(gs, "conv_Tcells"),
                                function(y) {
                                  sample_n = min(nrow(y), 1E4)
                                  exprs(y)[sample(nrow(y), sample_n),]
                                })),
        xChannel = "V710-A",
        yChannel = "G660-A",
        target = c(175, 175),
        K = 20,
        filterId = "MAIT Cells" # K indicates number of clusters to estimate
        
      )
    # fix filterId
    mait_gate_all@filterId <- "MAIT Cells"
    
    # scale gate
    mait_gate_all <- scale_gate(mait_gate_all, scale = 2)
    
    # add gate
    gs_pop_add(gs, gate = mait_gate_all, parent = "conv_Tcells")
    recompute(gs)
    
    # add not MAIT gate
    ## Example of booleanFilter
    not_mait <- booleanFilter(`!MAIT Cells`, filterId = "not_MAIT")
    
    # add boolean gate
    gs_pop_add(gs, not_mait, parent = "conv_Tcells")
    recompute(gs)
    
    # Example of how to use booleanFilter to create a polygon gate
    not_mait_gate <-
      lapply(seq(1, length(gs_pop_get_gate(gs, "MAIT Cells")), 1),
             function(x) {
               gate = gh_pop_get_gate(gs[[x]], "MAIT Cells")
               # enlarge for stringency
               gate <- scale_gate(gate, 3)
               ff <-
                 cytoframe_to_flowFrame(gh_pop_get_data(gs[[x]], "conv_Tcells"))
               fl <- flowCore::filter(ff, gate)
               idx <- which(!fl@subSet)
               set.seed(123)
               sample_n <- min(length(idx), 1E5)
               m.names <- colnames(gate@cov)
               events <-
                 exprs(ff)[idx[sample(length(idx), sample_n)], m.names]
               c.hull <- chull(events)
               polygon_mait <-
                 polygonGate(.gate = events[c(c.hull, c.hull[1]),],
                             filterId = "not_MAIT_Polygon")
             })
    names(not_mait_gate) <- sampleNames(gs)
    
    # add gate
    gs_pop_add(gs, not_mait_gate, parent = "conv_Tcells")
    recompute(gs)
    
    # add a quad gate
    cd4_cd8_quad_gate <- lapply(gs_pop_get_data(gs, "not_MAIT"),
                                function(x) {
                                  qg <- openCyto::gate_quad_tmix(x,
                                                                 channels = c("U785-A",
                                                                              "V570-A"),
                                                                 K = 2)
                                  # give readable names
                                  r.names <-
                                    c("U785-A" = "CD4", # these are human readable names
                                      "V570-A" = "CD8a")
                                  for (i in 1:length(qg)) {
                                    # iterate over each quadrant
                                    sapply(1:length(r.names), function(x) {
                                      # iterate over human readable names
                                      current.name <-
                                        attr(qg[[i]], "filterId") # keep a record of the current name
                                      attr(qg[[i]], "filterId") <<-
                                        gsub(
                                          # substitute and apply to qg
                                          pattern = names(r.names)[x],
                                          replacement = r.names[x],
                                          x = current.name
                                        )
                                    })
                                    
                                  }
                                  return(qg) # return modified gate
                                })
    # add gate
    gs_pop_add(gs, cd4_cd8_quad_gate, parent = "not_MAIT_Polygon")
    recompute(gs)
  }
  gs
}
