# Extracción por API de biocultural
Marius Bottin

## Cargar las variables de ambiente

Para que el script funcione, la carpeta tiene que contener un archivo
“.env” con un api token en la forma:

> token_biocultural: xxxxxxxx-xxxxxxxxx-xxxx-xxxxxxxxxxxx

``` r
ENV<-readLines("./.env")
ENV<-ENV[!grepl("^ *#",ENV,perl=T)]
ENV<-ENV[grep("^ *(.+) *: *(.+) *$",ENV,perl=T)]
vars<-gsub("^ *(.+) *: *(.+) *$","\\1",ENV,perl = T)
values<-gsub("^ *(.+) *: *(.+) *$","\\2",ENV,perl = T)
for(i in 1:length(vars))
{
  assign(vars[i],values[i])
  cat(vars[i], "loaded!\n")
}
```

    token_biocultural loaded!
