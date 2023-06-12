# Analysis of flow cytometry experiments with the cytoverse

Some prefatory material about our workshop will go here.



## TODO: 

1.  Creating a landing site of their choosing for their workshops (a website). This website should be listed in the `DESCRIPTION` file as the `URL`.


## To use the resulting image:

```sh
docker run -e PASSWORD=<choose_a_password_for_rstudio> -p 8787:8787 ghcr.io/ozettetech/cytoverse-bioc-2023:latest
````

*NOTE*: Running docker that uses the password in plain text like above exposes the password to others in a multi-user system (like a shared workstation or compute node). In practice, consider using an environment variable instead of plain text to pass along passwords and other secrets in docker command lines.
