# Analysis of flow cytometry experiments with the cytoverse

The `cytoverse` is a collection of open source R based tools developed by the founders of **[Ozette Technologies](https://ozette.com)** which facilitate programmatic analysis of flow cytometry data.

A number of packages make up the `cytoverse`. [flowCore](https://bioconductor.org/packages/release/bioc/html/flowCore.html), [flowWorkspace](https://www.bioconductor.org/packages/release/bioc/html/flowWorkspace.html), [openCyto](https://bioconductor.org/packages/release/bioc/html/openCyto.html), and [ggcyto](https://www.bioconductor.org/packages/release/bioc/html/ggcyto.html) make up the core of the `cytoverse`. These packages are, by and large, powerful and sufficient to create robust and reproducible analysis workflows for flow cytometry data. Additional available packages such as `flowClust`, `flowStats`, `CytoQC`, or `CytoML` can be further utilized for niche applications including, model based clustering of flow cytometry data, QC and standardization of set of FCS files, even parsing of workspaces from FlowJo or cytobank.

# Workshop outlines

[This website](https://cdn.ozetteai.com/cytoverse-bioc-2023/index.html) contains training materials that will be presented at a workshop at [Bioc2023](https://bioc2023.bioconductor.org/schedule/), on August 2nd.  If you couldn't attend the conference, don't worry, as we'll add links to videos of the workshop.
You may also explore these training materials at your own pace.

## Learning goals

The aim of this workshop is to empower flow cytometry users and analysts towards reproducible and programmatic analysis.

By the end of this workshop, the attendees will be able to

-   [Import flow cytometry data](articles/1_Import_fcs.html)
-   [Understand the difference between **uncompensated**, **compensated**, and **transformed** data](articles/2_Spillover_transformation.html),
-   Identify sub-populations by [manual or semi-automated gating of markers](articles/3_Gating_1.html),
-   [Access and extract expression matrix from a gated data](articles/4_Gating_2.html),
-   Be aware of [csv-templating of Gating](articles/5_Gating_gatingTemplate.html) to perform large-scale gating
-   Identify and [generate important plots](articles/6_ggcyto.html) to assess the **data** and  **quality**,
-   [Generate plots summarizing the expression of markers and abundance of various sub-populations](articles/7_Reporting.html)

## Workshop schedule

| Activity                                         | Time       |
|--------------------------------------------------|------------|
| Introduction and use of docker container         | 5 minutes  |
| Basics of working with FCS files                 | 15 minutes |
| Spillover, Transformation                        | 15 minutes |
| Gating Cells in the `cytoverse`                  | 40 minutes |
| Visualization using `ggcyto`                     | 10 minutes |
| Reporting                                        | 10 minutes |
| Wrap-up                                          | 10 minutes |


## Prerequisites/assumptions

-   Some R knowledge,
-   Basic flow cytometry knowledge,
-   Willingness to ask questions and learn

## Data

For this workshop, we will use subset of a public data set: [FR-FCM-Z5PC](https://flowrepository.org/public_experiment_representations/5932) that can be found in **flowrepository.org**. The dataset was published in the following [paper](https://doi.org/10.1038/s41467-022-34638-2).

---

# Journey into the `cytoverse`

What do these various packages do, and where should you look for a piece of functionality?

* [flowWorkspace](https://www.bioconductor.org/packages/release/bioc/html/flowWorkspace.html): provides core data structures and methods for use in cytometry data analysis, including compensation, transformation, and gating. 
* [flowCore](https://bioconductor.org/packages/release/bioc/html/flowCore.html): provides additional data structures and methods for use in cytometry data analysis, however in some cases has been superceded by `flowWorkspace`
* [ggcyto](https://www.bioconductor.org/packages/release/bioc/html/ggcyto.html): make plots of distributions of cells and their gates using a ggplot2-based framework
* CytoML: import and export of cytometry data to or from FlowJo, BD FACSDIVA, and Cytobank workspace formats.
* CytoQC: wrangle and standardize collections of FCS files.
* [openCyto](https://bioconductor.org/packages/release/bioc/html/openCyto.html): openCyto enables the development of reproducible automated analysis pipelines
* flowClust: implements various unsupervised clustering methods
* flowStats: enables calculation of sample-level summaries of gated populations

---

# Notes on using the docker image

```sh
docker run -network=host -e PASSWORD=<choose_a_password_for_rstudio> -p 8787:8787 ghcr.io/ozettetech/cytoverse-bioc-2023:latest
````

