Extracción de los metadatos de los catalogos
================
Marius Bottin
2025-03-05

- [1 Funciones de tratamiento de los metadatos en
  xml](#1-funciones-de-tratamiento-de-los-metadatos-en-xml)
- [2 Geonetwork](#2-geonetwork)
  - [2.1 Importación](#21-importación)
  - [2.2 XML representation and
    analyses](#22-xml-representation-and-analyses)
    - [2.2.1 Exportación de los metadatos de
      geonetwork](#221-exportación-de-los-metadatos-de-geonetwork)
- [3 Ceiba](#3-ceiba)
  - [3.1 Descripción](#31-descripción)
  - [3.2 Extracción de los metadatos](#32-extracción-de-los-metadatos)
  - [3.3 Metadatos: EML](#33-metadatos-eml)
    - [3.3.1 Exportación de los metadatos EML de
      Ceiba](#331-exportación-de-los-metadatos-eml-de-ceiba)
  - [3.4 Metadatos: Resources](#34-metadatos-resources)
    - [3.4.1 Exportación de los metadatos EML de
      Ceiba](#341-exportación-de-los-metadatos-eml-de-ceiba)

``` r
require(RPostgreSQL)
```

    ## Loading required package: RPostgreSQL

    ## Loading required package: DBI

``` r
require(dm)
```

    ## Loading required package: dm

    ## 
    ## Attaching package: 'dm'

    ## The following object is masked from 'package:stats':
    ## 
    ##     filter

``` r
require(DiagrammeRsvg)
```

    ## Loading required package: DiagrammeRsvg

``` r
require(rsvg)
```

    ## Loading required package: rsvg

    ## Linking to librsvg 2.54.4

``` r
require(png)
```

    ## Loading required package: png

``` r
knitr::opts_chunk$set(cache=F,tidy.opts = list(width.cutoff = 70),
                     tidy = TRUE,
                     max.print=50,fig.path="./Fig/extraction_metadata_",echo=T,
                     collapse=F, echo=T)
def.chunk.hook  <- knitr::knit_hooks$get("chunk")
knitr::knit_hooks$set(chunk = function(x, options) {
  x <- def.chunk.hook(x, options)
  paste0("\n \\", "footnotesize","\n\n", x, "\n\n \\normalsize\n\n")
})
```

# 1 Funciones de tratamiento de los metadatos en xml

En el archivo
[`analysis_metadatos_xml.R`](../funcionesGenerales/analysis_metadatos_xml.R),
se escribieron las funciones para manejar las estructuras complejas de
metadatos que se pueden obtener desde los archivos (o objetos) XML que
contienen los metadatos en los catálogos de Ceiba y Geonetwork.

``` r
source("../funcionesGenerales/analysis_metadatos_xml.R")
```

    ## Loading required package: data.tree

    ## Loading required package: igraph

    ## 
    ## Attaching package: 'igraph'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     decompose, spectrum

    ## The following object is masked from 'package:base':
    ## 
    ##     union

    ## Loading required package: RSQLite

    ## Loading required package: openxlsx

# 2 Geonetwork

## 2.1 Importación

Desde un archivo dump de la base de datos de geonetwork extraído
directamente en el servidor, utilizamos los comandos siguientes para
duplicar la base de datos:

``` bash
createdb geonetwork -D extra
pg_restore -d geonetwork -c --no-owner --no-acl access_dump/dump-geonetwork-202409051028.sql
```

``` r
geonetwork <- dbConnect(PostgreSQL(), dbname = "geonetwork", user = "marius")
```

``` r
dm_object <- dm_from_con(geonetwork, learn_keys = T)
```

    ## Warning: <PostgreSQLConnection> uses an old dbplyr interface
    ## ℹ Please install a newer version of the package or contact the maintainer
    ## This warning is displayed once every 8 hours.

``` r
A <- dm_object %>%
    dm_draw(view_type = "all")
A2 <- DiagrammeRsvg::export_svg(A) %>%
    charToRaw() %>%
    rsvg::rsvg_png("Fig/explor_geonetwork_structureDB.png")
knitr::include_graphics("Fig/explor_geonetwork_structureDB.png")
```

<img src="Fig/explor_geonetwork_structureDB.png" width="3380" />

## 2.2 XML representation and analyses

It seems that most of the data is in an xml form in the field `data` of
the `metadata` table.

We will need to analyse particularly this XML structure, to be able to
extract the metadata from the geonetwork.

``` r
require(XML)
```

    ## Loading required package: XML

``` r
require(data.tree)
mtdt <- dbGetQuery(geonetwork, "SELECT uuid,data FROM metadata")
```

``` r
xml_list_gn <- lapply(mtdt[-479, 2], function(x) xmlToList(xmlParse(x)))
names(xml_list_gn) <- mtdt$uuid[-479]
```

Con esas 3 grandes funciones, extraemos y analizamos los metadatos de
los juegos de datos en Geonetwork:

``` r
structGn <- extractStructureListDocuments(xml_list_gn)
gnv_gn <- groupsAndVariables(structGn)
tabs_gn <- extractTables(xml_list_gn, structGn, gpsAndVar = gnv_gn)
```

El resultado se puede representar así:

``` r
plotGroupsAndVariables(gnv_gn)
```

![](./Fig/extraction_metadata_unnamed-chunk-7-1.png)<!-- -->

### 2.2.1 Exportación de los metadatos de geonetwork

``` r
xlFile_gn <- "../../../data_metadatos_catalogos/exportMetaGeonetwork.xlsx"
sqlite_gn <- "../../../data_metadatos_catalogos/meta_geonetwork.sqlite"
dbgn <- exportSQLite(tabs_gn, sqlite_file = sqlite_gn)
exportXL(tabs_gn, file = xlFile_gn)
```

# 3 Ceiba

## 3.1 Descripción

Todos los datos de Ceiba están organizados como carpetas en el datadir
del servidor. Se maneja después con el sistema Integrated Publishing
Toolkit desarrollado por GBIF.

En cada carpeta (cada juego de datos), podemos encontrar:

- el archivo comprimido que contiene los archivos y los metadatos en
  formato DarwinCore completo.
- el archivo `eml.xml` que contiene los metadatos, y todas las versiones
  del archivo (con los nombres `eml-1.xml`, `eml-2.xml` etc)
- el archivo `publication.log` que contiene el historial de
  publicación/modificación del juego de datos
- archivos de descripción de los juegos de datos en “Rich Text Format”
  (rtf), tambien para cada versión publicada
- archivos de administración de datos y metadatos `resource.xml`
- una carpeta `sources` que contiene los datos (?)

## 3.2 Extracción de los metadatos

En ssh, accedemos al servidor de ceiba desde la red del instituto:

``` bash
ssh integracion@192.168.11.74
```

Extraemos 3 archivos:

- un archivo que tiene las direcciones de los archivos “eml.xml” y sus
  contenidos
- un archivo que contiene las direcciones de los archivos “resource.xml”
  y sus contenidos
- un catalogo de todos los archivos presentes en la carpeta de datos
  manejada por el ipt

Esos 2 archivos se pueden obtener con:

``` bash
find /home/pem/datadir/ -name eml.xml -exec bash file_and_content.sh {} \; >file_and_content_result_eml 2> errors_find_file_and_content_eml
find /home/pem/datadir/ -name resource.xml  -exec bash file_and_content.sh {} \; >file_and_content_result_resource 2> errors_find_file_and_content_resource
find /home/pem/datadir/ -type f  > result_find
```

Los archivos se pueden descargar desde la red del instituto, gracias al
applicativo scp, que funciona a través de ssh.

## 3.3 Metadatos: EML

``` r
result_find <- readLines("../../../data_metadatos_catalogos/ceiba/result_find")
meta_ceiba <- readLines("../../../data_metadatos_catalogos/ceiba/file_and_content_result_eml")
meta_ceiba <- meta_ceiba[!meta_ceiba == ""]
```

``` r
adressesXML_emlCeiba <- extractAdressesMultiXml(meta_ceiba)
```

    ## Number of elements: 1051

    ## Warning in extractAdressesMultiXml(meta_ceiba): Some xml documents appear to be
    ## empty (we will not consider
    ## them):/home/pem/datadir/resources/cacay-moriche_guaviare/eml.xml

``` r
xml_files_emlCeiba <- apply(adressesXML_emlCeiba, 1, function(a, rl) paste(rl[a[2]:a[3]],
    sep = "\n", collapse = "\n"), rl = meta_ceiba)
names(xml_files_emlCeiba) <- adressesXML_emlCeiba$name
xml_list_emlCeiba <- lapply(xml_files_emlCeiba, function(x) xmlToList(xmlParse(x)))
```

``` r
structEmlCeiba <- extractStructureListDocuments(xml_list_emlCeiba)
gnv_emlCeiba <- groupsAndVariables(structEmlCeiba)
tabs_emlCeiba <- extractTables(xml_list_emlCeiba, structEmlCeiba, gpsAndVar = gnv_emlCeiba)
```

``` r
plotGroupsAndVariables(gnv_emlCeiba)
```

![](./Fig/extraction_metadata_unnamed-chunk-12-1.png)<!-- -->

### 3.3.1 Exportación de los metadatos EML de Ceiba

``` r
xlFile_emlCeiba <- "../../../data_metadatos_catalogos/export_eml_ceiba.xlsx"
sqlite_emlCeiba <- "../../../data_metadatos_catalogos/meta_eml_ceiba.sqlite"
dbEmlCeiba <- exportSQLite(tabs_emlCeiba, sqlite_file = sqlite_emlCeiba)
exportXL(tabs_emlCeiba, file = xlFile_emlCeiba)
```

    ## Warning in wb$writeData(df = x, colNames = TRUE, sheet = sheet, startRow = startRow, : ), Tiempo atmosf ... to del Casanare. is truncated. 
    ## Number of characters exeed the limit of 32767.

## 3.4 Metadatos: Resources

``` r
resource_ceiba <- readLines("../../../data_metadatos_catalogos/ceiba/file_and_content_result_resource")
```

    ## Warning in
    ## readLines("../../../data_metadatos_catalogos/ceiba/file_and_content_result_resource"):
    ## incomplete final line found on
    ## '../../../data_metadatos_catalogos/ceiba/file_and_content_result_resource'

``` r
resource_ceiba <- resource_ceiba[!resource_ceiba == ""]
```

``` r
adressesXML_resCeiba <- extractAdressesMultiXml(resource_ceiba)
```

    ## Number of elements: 1054

``` r
xml_files_resCeiba <- apply(adressesXML_resCeiba, 1, function(a, rl) paste(rl[a[2]:a[3]],
    sep = "\n", collapse = "\n"), rl = resource_ceiba)
names(xml_files_resCeiba) <- adressesXML_resCeiba$name
xml_list_resCeiba <- lapply(xml_files_resCeiba, function(x) xmlToList(xmlParse(x)))
```

``` r
structResCeiba <- extractStructureListDocuments(xml_list_resCeiba)
gnv_resCeiba <- groupsAndVariables(structResCeiba)
tabs_resCeiba <- extractTables(xml_list_resCeiba, structResCeiba, gpsAndVar = gnv_resCeiba)
```

``` r
plotGroupsAndVariables(gnv_resCeiba)
```

![](./Fig/extraction_metadata_unnamed-chunk-17-1.png)<!-- -->

### 3.4.1 Exportación de los metadatos EML de Ceiba

``` r
xlFile_resCeiba <- "../../../data_metadatos_catalogos/export_res_ceiba.xlsx"
sqlite_resCeiba <- "../../../data_metadatos_catalogos/meta_res_ceiba.sqlite"
dbResCeiba <- exportSQLite(tabs_resCeiba, sqlite_file = sqlite_resCeiba)
exportXL(tabs_resCeiba, file = xlFile_resCeiba)
```

``` r
dbDisconnect(dbEmlCeiba)
dbDisconnect(dbResCeiba)
dbDisconnect(dbgn)
dbDisconnect(geonetwork)
```

    ## [1] TRUE
