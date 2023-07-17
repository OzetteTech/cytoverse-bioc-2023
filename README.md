# Analysis of flow cytometry experiments with the cytoverse

The `cytoverse` is a collection of open source R based tools developed by the founders of **[Ozette Technologies](https://ozette.com)** which facilitate programmatic analysis of flow cytometry data.

A number of packages make up the `cytoverse`. [flowCore](https://bioconductor.org/packages/release/bioc/html/flowCore.html), [flowWorkspace](https://www.bioconductor.org/packages/release/bioc/html/flowWorkspace.html), [openCyto](https://bioconductor.org/packages/release/bioc/html/openCyto.html), and [ggcyto](https://www.bioconductor.org/packages/release/bioc/html/ggcyto.html) make up the core of the `cytoverse`. These packages are, by and large, powerful and sufficient to create robust and reproducible analysis workflows for flow cytometry data. Additional available packages such as `flowClust`, `flowStats`, `CytoQC`, or `CytoML` can be further utilized for niche applications including, model based clustering of flow cytometry data, QC and standardization of set of FCS files, even parsing of workspaces from FlowJo or cytobank.

# Workshop outlines

This website contains training materials that will be presented at a workshop at [Bioc2023](https://bioc2023.bioconductor.org/schedule/), on August 2nd.  After the conference, we'll add a link to videos of the workshop.

## Learning goals

The aim of this workshop is to empower flow cytometry users and analysts towards reproducible and programmatic analysis.

By the end of this workshop, the attendees will be able to

-   [Import flow cytometry data](articles/Import_fcs.html)
-   [Understand the difference between **uncompensated**, **compensated**, and **transformed** data](articles/Spillover_v2.html),
-   Identify and [generate important plots](articles/ggcyto_1-5.html) to assess the **data** and  **quality**,
-   Identify sub-populations by [manual or semi-automated gating of markers](Gating_1.html),
-   [Generate plots summarizing the expression of markers and abundance of various sub-populations](articles/Reporting_1.html)

## Prerequisites/assumptions

-   Some R knowledge,
-   Basic flow cytometry knowledge,
-   Willingness to ask questions and learn

## Data

For this workshop, we will use subset of a public data set: [FR-FCM-Z5PC](https://flowrepository.org/public_experiment_representations/5932) that can be found in **flowrepository.org**. The dataset was published in the following [paper](https://doi.org/10.1038/s41467-022-34638-2).

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
# Journey into the `cytoverse`!

Let's begin!    


# Notes on using the docker image
# Notes on using the docker image

```sh
docker run -network=host -e PASSWORD=<choose_a_password_for_rstudio> -p 8787:8787 ghcr.io/ozettetech/cytoverse-bioc-2023:latest
````

*NOTE*: Running docker that uses the password in plain text like above exposes the password to others in a multi-user system (like a shared workstation or compute node). In practice, consider using an environment variable instead of plain text to pass along passwords and other secrets in docker command lines.
