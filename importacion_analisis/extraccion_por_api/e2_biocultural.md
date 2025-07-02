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

## Pruebas de la Api

``` r
require(httr)
```

    Loading required package: httr

``` r
require(jsonlite)
```

    Loading required package: jsonlite

``` r
require(stringi)
```

    Loading required package: stringi

``` r
require(xml2)
```

    Loading required package: xml2

``` r
baseURL<-"http://ec2-34-238-22-20.compute-1.amazonaws.com:8080"
searchApi="/api/search"
res<-GET(paste0(baseURL,searchApi,"?q=*&per_page=1000&type=dataset&metadata_fields=*"), add_headers(`X-Dataverse-key` = token_biocultural),accept_json())
datasets<-fromJSON(rawToChar(res$content),simplifyVector = F)
datasets$data$items[[1]]$citationHtml
```

    [1] "Lizeth Paola, Ortiz Guengue, 2022, \"Caracterizaci&oacute;n de sistemas socio-productivos en 6 comunidades del Resguardo Pialap&iacute; Pueblo Viejo del Pueblo Aw&aacute;, desde el enfoque de medios de vida\", <a href=\"https://doi.org/10.21068/A9S6PU\" target=\"_blank\">https://doi.org/10.21068/A9S6PU</a>, BioCultural: Cat&aacute;logo de Datos Socioecologicos, V1"

``` r
textutils::HTMLdecode(datasets$data$items[[1]]$citationHtml)
```

    [1] "Lizeth Paola, Ortiz Guengue, 2022, \"Caracterización de sistemas socio-productivos en 6 comunidades del Resguardo Pialapí Pueblo Viejo del Pueblo Awá, desde el enfoque de medios de vida\", <a href=\"https://doi.org/10.21068/A9S6PU\" target=\"_blank\">https://doi.org/10.21068/A9S6PU</a>, BioCultural: Catálogo de Datos Socioecologicos, V1"

### Estructura de las variables de metadatos extraídos por API

Describir las variables de metadatos de Biocultural (obtenidos por API)
de la misma forma que lo que se hizo para los metadatos de Ceiba y
Geonetwork nos permitiría hacer un trabajo de integración, desde bases
comparables en los 3 catálogos.

Parece que, probablemente por los elementos de la lista enviada en
`JSON` por la API que no contienen nombres de elementos, no se pueden
aplicar las funciones que se aplicaron sobre los metadatos en `XML` de
los catalogos Geonetwork y Ceiba. Por ahora, podría ser más eficiente
trabajar los metadatos y su estructura desde la base de datos en
PostgreSQL del catálogo Biocultural

Lo que se intento en R y que no funcionó fue:

``` r
source("../funcionesGenerales/analysis_metadatos_xml.R")
metaBiocultural<-datasets$data$items
names(metaBiocultural) <- sapply(metaBiocultural,function(x)x$global_id)
structMBC <- extractStructureListDocuments(metaBiocultural)
gnv_MBC <-extractStructureListDocuments(structMBC)
tables_MBC <-extractTables(metaBiocultural, structMBC, gpsAndVar = gnv_MBC)
plotGroupsAndVariables(gnv_MBC)
```
