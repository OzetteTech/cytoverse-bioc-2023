# Analysis of flow cytometry experiments with the cytoverse

Some prefatory material about our workshop will go here.


# Developer notes

## To use the resulting image:

```sh
docker pull ghcr.io/ozettetech/cytoverse-bioc-2023:latest
docker run --network=host -e PASSWORD=<choose_a_password_for_rstudio> ghcr.io/ozettetech/cytoverse-bioc-2023:latest
```

or to make your home directory available:

```sh
docker run --network=host -e PASSWORD=<choose_a_password_for_rstudio>  -v "$HOME":/home/rstudio ghcr.io/ozettetech/cytoverse-bioc-2023:latest
```

Then point a web browser to http://localhost:8787



*NOTE*: Running docker that uses the password in plain text like above exposes the password to others in a multi-user system (like a shared workstation or compute node). In practice, consider using an environment variable instead of plain text to pass along passwords and other secrets in docker command lines.

## To view the packagedown website:

```r
pkgdown::build_site()
```

## TODO: 

1.  Create a landing site (website). This website should be listed in the `DESCRIPTION` file as the `URL`.