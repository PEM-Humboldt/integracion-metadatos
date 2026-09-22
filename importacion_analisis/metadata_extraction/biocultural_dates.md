# Fechas en biocultural metadata
Marius Bottin

El objetivo de este documento es entender como funcionan las fechas en
biocultural. Para eso, vamos a utilizar la base de datos extraída (ver
<https://github.com/PEM-Humboldt/integracion-metadatos/blob/master/importacion_analisis/metadata_extraction/extraction.md>).

``` r
require(RPostgres)
```

    Loading required package: RPostgres

``` r
meta_i2d<-dbConnect(Postgres(),dbname='meta_i2d_v2')
```

La consulta completa para obtener las fechas es:

``` sql
SELECT dataset_id, title, createdate, globalidcreatetime, modificationtime, publicationdate,
    datasetversion_id, versionnumber::text || '.' || COALESCE(minorversionnumber::text, '0') version, versionstate, createtime,
    production_date, date_of_deposit,
    ds_description_date, 
    time_period_covered_start,time_period_covered_end,
    date_of_collection_start,date_of_collection_end

FROM biocultural.datasetversion dv
LEFT JOIN biocultural.dataset d USING (dataset_id)
LEFT JOIN biocultural.ds_description ds USING (datasetversion_id)
LEFT JOIN biocultural.citation c USING (datasetversion_id)
LEFT JOIN biocultural.time_period_covered tpc USING (datasetversion_id)
LEFT JOIN biocultural.date_of_collection doc USING (datasetversion_id)
ORDER BY dataset_id, versionnumber ASC, minorversionnumber ASC
;
```

| dataset_id | title | createdate | globalidcreatetime | modificationtime | publicationdate | datasetversion_id | version | versionstate | createtime | production_date | date_of_deposit | ds_description_date | time_period_covered_start | time_period_covered_end | date_of_collection_start | date_of_collection_end |
|---:|:---|:---|:---|:---|:---|---:|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 10 | test | 2022-12-07 03:51:16 | 2022-12-14 22:16:24 | 2022-12-14 22:16:23 | 2022-12-07 03:51:26 | 2 | 1.0 | RELEASED | 2022-12-07 03:51:16 | NA | 2022-12-06 | NA | NA | NA | 2022-10-12 | 2022-10-22 |
| 10 | 25 años de investigación socio-ecológica en el Instituto de Investigación de Recursos Biológicos Alexander von Humboldt. Año 2020 | 2022-12-07 03:51:16 | 2022-12-14 22:16:24 | 2022-12-14 22:16:23 | 2022-12-07 03:51:26 | 9 | 2.0 | RELEASED | 2022-12-14 21:42:35 | NA | 2022-12-06 | NA | NA | NA | 2020-10-01 | 2020-12-30 |
| 11 | Encuesta socioecológica para los municipio de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta) | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 3 | 1.0 | RELEASED | 2022-12-09 19:19:55 | NA | 2022-12-09 | NA | NA | NA | 2018-07-07 | 2018-07-19 |
| 11 | Encuesta socioecológica para los municipio de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta) | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 3 | 1.0 | RELEASED | 2022-12-09 19:19:55 | NA | 2022-12-09 | NA | NA | NA | 2018-02-17 | 2018-03-01 |
| 11 | Encuesta socioecológica para los municipio de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta) | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 3 | 1.0 | RELEASED | 2022-12-09 19:19:55 | NA | 2022-12-09 | NA | NA | NA | 2018-09-07 | 2018-09-20 |
| 11 | Encuesta socioecológica para los municipio de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 7 | 1.1 | RELEASED | 2022-12-14 15:15:01 | NA | 2022-12-09 | NA | NA | NA | 2018-02-17 | 2018-03-01 |
| 11 | Encuesta socioecológica para los municipio de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 7 | 1.1 | RELEASED | 2022-12-14 15:15:01 | NA | 2022-12-09 | NA | NA | NA | 2018-07-07 | 2018-07-19 |
| 11 | Encuesta socioecológica para los municipio de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 7 | 1.1 | RELEASED | 2022-12-14 15:15:01 | NA | 2022-12-09 | NA | NA | NA | 2018-09-07 | 2018-09-20 |
| 11 | Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 10 | 1.2 | RELEASED | 2022-12-15 01:07:12 | NA | 2022-12-09 | NA | NA | NA | 2018-07-07 | 2018-07-19 |
| 11 | Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 10 | 1.2 | RELEASED | 2022-12-15 01:07:12 | NA | 2022-12-09 | NA | NA | NA | 2018-02-17 | 2018-03-01 |
| 11 | Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 10 | 1.2 | RELEASED | 2022-12-15 01:07:12 | NA | 2022-12-09 | NA | NA | NA | 2018-09-07 | 2018-09-20 |
| 11 | Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 23 | 1.3 | RELEASED | 2022-12-21 02:12:50 | 2018-09-30 | 2022-12-09 | NA | NA | NA | 2018-09-07 | 2018-09-20 |
| 11 | Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 23 | 1.3 | RELEASED | 2022-12-21 02:12:50 | 2018-09-30 | 2022-12-09 | NA | NA | NA | 2018-07-07 | 2018-07-19 |
| 11 | Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 23 | 1.3 | RELEASED | 2022-12-21 02:12:50 | 2018-09-30 | 2022-12-09 | NA | NA | NA | 2018-02-17 | 2018-03-01 |
| 11 | Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 24 | 1.4 | RELEASED | 2022-12-21 02:14:29 | 2018-09-30 | 2022-12-09 | NA | NA | NA | 2018-02-17 | 2018-03-01 |
| 11 | Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 24 | 1.4 | RELEASED | 2022-12-21 02:14:29 | 2018-09-30 | 2022-12-09 | NA | NA | NA | 2018-09-07 | 2018-09-20 |
| 11 | Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 24 | 1.4 | RELEASED | 2022-12-21 02:14:29 | 2018-09-30 | 2022-12-09 | NA | NA | NA | 2018-07-07 | 2018-07-19 |
| 18 | Recopilación y sistematización de información de los procesos de formulación del Plan de Manejo de los páramos y de las estrategias de monitoreo desarrolladas por las Corporaciones Autónomas Regionales. | 2022-12-14 13:58:35 | 2022-12-14 15:12:15 | 2022-12-14 15:12:15 | 2022-12-14 14:12:52 | 4 | 1.0 | RELEASED | 2022-12-14 13:58:35 | NA | 2022-12-14 | NA | NA | NA | 2019-10-10 | 2019-10-22 |
| 18 | Recopilación y sistematización de información de los procesos de formulación del Plan de Manejo de los páramos y de las estrategias de monitoreo desarrolladas por las Corporaciones Autónomas Regionales. Año 2019 | 2022-12-14 13:58:35 | 2022-12-14 15:12:15 | 2022-12-14 15:12:15 | 2022-12-14 14:12:52 | 6 | 1.1 | RELEASED | 2022-12-14 15:11:44 | NA | 2022-12-14 | NA | NA | NA | 2019-10-10 | 2019-10-22 |
| 22 | Encuesta socioecológica sobre unidades de paisaje en el Valle de Sibundoy, Putumayo. Año 2020 | 2022-12-14 14:50:03 | 2025-01-09 07:01:20 | 2025-01-09 07:01:20 | 2022-12-14 15:10:16 | 5 | 1.0 | RELEASED | 2022-12-14 14:50:03 | NA | 2022-12-14 | NA | NA | NA | 2020-02-01 | 2020-06-30 |

Displaying records 1 - 20

Como lo pueden ver, las fechas se pueden separar en varios grupos:

- fechas automaticas creadas por el sistema, para el dataset, o el
  datasetversion
- fechas de producción, deposición y metadatos
- fechas que tienen que ver con la metodología

## Fechas automaticas

``` sql
SELECT dataset_id, title, createdate, globalidcreatetime, modificationtime, publicationdate,
    datasetversion_id, versionnumber::text || '.' || COALESCE(minorversionnumber::text, '0') version, versionstate, createtime

FROM biocultural.datasetversion dv
LEFT JOIN biocultural.dataset d USING (dataset_id)
LEFT JOIN biocultural.citation c USING (datasetversion_id)
ORDER BY dataset_id, versionnumber ASC, minorversionnumber ASC
;
```

| dataset_id | title | createdate | globalidcreatetime | modificationtime | publicationdate | datasetversion_id | version | versionstate | createtime |
|---:|:---|:---|:---|:---|:---|---:|:---|:---|:---|
| 10 | test | 2022-12-07 03:51:16 | 2022-12-14 22:16:24 | 2022-12-14 22:16:23 | 2022-12-07 03:51:26 | 2 | 1.0 | RELEASED | 2022-12-07 03:51:16 |
| 10 | 25 años de investigación socio-ecológica en el Instituto de Investigación de Recursos Biológicos Alexander von Humboldt. Año 2020 | 2022-12-07 03:51:16 | 2022-12-14 22:16:24 | 2022-12-14 22:16:23 | 2022-12-07 03:51:26 | 9 | 2.0 | RELEASED | 2022-12-14 21:42:35 |
| 11 | Encuesta socioecológica para los municipio de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta) | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 3 | 1.0 | RELEASED | 2022-12-09 19:19:55 |
| 11 | Encuesta socioecológica para los municipio de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 7 | 1.1 | RELEASED | 2022-12-14 15:15:01 |
| 11 | Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 10 | 1.2 | RELEASED | 2022-12-15 01:07:12 |
| 11 | Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 23 | 1.3 | RELEASED | 2022-12-21 02:12:50 |
| 11 | Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 2022-12-09 19:19:55 | 2022-12-21 02:14:43 | 2022-12-21 02:14:43 | 2022-12-09 19:43:22 | 24 | 1.4 | RELEASED | 2022-12-21 02:14:29 |
| 18 | Recopilación y sistematización de información de los procesos de formulación del Plan de Manejo de los páramos y de las estrategias de monitoreo desarrolladas por las Corporaciones Autónomas Regionales. | 2022-12-14 13:58:35 | 2022-12-14 15:12:15 | 2022-12-14 15:12:15 | 2022-12-14 14:12:52 | 4 | 1.0 | RELEASED | 2022-12-14 13:58:35 |
| 18 | Recopilación y sistematización de información de los procesos de formulación del Plan de Manejo de los páramos y de las estrategias de monitoreo desarrolladas por las Corporaciones Autónomas Regionales. Año 2019 | 2022-12-14 13:58:35 | 2022-12-14 15:12:15 | 2022-12-14 15:12:15 | 2022-12-14 14:12:52 | 6 | 1.1 | RELEASED | 2022-12-14 15:11:44 |
| 22 | Encuesta socioecológica sobre unidades de paisaje en el Valle de Sibundoy, Putumayo. Año 2020 | 2022-12-14 14:50:03 | 2025-01-09 07:01:20 | 2025-01-09 07:01:20 | 2022-12-14 15:10:16 | 5 | 1.0 | RELEASED | 2022-12-14 14:50:03 |
| 22 | Encuesta socioecológica sobre unidades de paisaje en el Valle de Sibundoy, Putumayo. Año 2020 | 2022-12-14 14:50:03 | 2025-01-09 07:01:20 | 2025-01-09 07:01:20 | 2022-12-14 15:10:16 | 77 | 2.0 | RELEASED | 2025-01-09 06:54:55 |
| 26 | Caracterización del conflicto socioambiental en Selvas de Aliwa. Año 2020 | 2022-12-14 20:37:04 | 2025-01-09 07:31:21 | 2025-01-09 07:31:20 | 2022-12-14 20:53:17 | 8 | 1.0 | RELEASED | 2022-12-14 20:37:04 |
| 26 | Caracterización del conflicto socioambiental en Selvas de Aliwa. Año 2020 | 2022-12-14 20:37:04 | 2025-01-09 07:31:21 | 2025-01-09 07:31:20 | 2022-12-14 20:53:17 | 78 | 2.0 | RELEASED | 2025-01-09 07:28:59 |
| 34 | Encuesta estructurada componente Pesquero río Magdalena. Año 2020 | 2022-12-15 02:14:38 | 2025-01-09 07:41:52 | 2025-01-09 07:41:51 | 2022-12-15 02:32:28 | 11 | 1.0 | RELEASED | 2022-12-15 02:14:38 |
| 34 | Encuesta estructurada componente Pesquero río Magdalena. Año 2020 | 2022-12-15 02:14:38 | 2025-01-09 07:41:52 | 2025-01-09 07:41:51 | 2022-12-15 02:32:28 | 79 | 2.0 | RELEASED | 2025-01-09 07:39:18 |
| 39 | Directorio de Meliponicultores de Colombia. Censo Preliminar año 2020 | 2022-12-15 21:09:45 | 2025-01-09 08:03:28 | 2025-01-09 08:03:28 | 2022-12-15 21:37:38 | 12 | 1.0 | RELEASED | 2022-12-15 21:09:45 |
| 39 | Directorio de Meliponicultores de Colombia. Censo Preliminar año 2020 | 2022-12-15 21:09:45 | 2025-01-09 08:03:28 | 2025-01-09 08:03:28 | 2022-12-15 21:37:38 | 80 | 2.0 | RELEASED | 2025-01-09 07:55:10 |
| 42 | Extracción de Datos Documentales de Información interna del Instituto Humboldt e Insumos para el Plan Piloto para el Observatorio de Política y Biodiversidad. Año 2021 | 2022-12-16 00:00:39 | 2025-01-09 08:11:59 | 2025-01-09 08:11:58 | 2022-12-16 00:17:45 | 13 | 1.0 | RELEASED | 2022-12-16 00:00:39 |
| 46 | Identificación de posibles procesos y prácticas asociadas a gobernanza. Año 2022 | 2022-12-16 02:36:05 | 2025-01-09 08:29:48 | 2025-01-09 08:29:48 | 2022-12-16 03:26:40 | 14 | 1.0 | RELEASED | 2022-12-16 02:36:05 |
| 46 | Identificación de posibles procesos y prácticas asociadas a gobernanza. Año 2022 | 2022-12-16 02:36:05 | 2025-01-09 08:29:48 | 2025-01-09 08:29:48 | 2022-12-16 03:26:40 | 82 | 2.0 | RELEASED | 2025-01-09 08:18:20 |

Displaying records 1 - 20

| variable | version | tipo | note |
|----|----|----|----|
| createdate | No | timestamp | Es la fecha la más antigua, corresponde con el createtime de la primera version |
| globalidcreatetime | No | timestamp | Probablemente corresponde a la fecha de creación de un id, que no corresponde a un createtime de versión |
| modificationtime | No |  | Parece que corresponde al createtime de la ultima version |
| publicationdate | No | timestamp | Probablemente corresponde al createtime de la primera versión publicada |
| createtime | Sí | timestamp | referencia para la versión |

## Fechas de los metadatos

``` sql
SELECT title, dataset_id ,
    datasetversion_id, versionnumber::text || '.' || COALESCE(minorversionnumber::text, '0') version,  createtime,
    production_date, date_of_deposit,
    ds_description_date, 
    time_period_covered_start,time_period_covered_end,
    date_of_collection_start,date_of_collection_end

FROM biocultural.datasetversion dv
LEFT JOIN biocultural.dataset d USING (dataset_id)
LEFT JOIN biocultural.ds_description ds USING (datasetversion_id)
LEFT JOIN biocultural.citation c USING (datasetversion_id)
LEFT JOIN biocultural.time_period_covered tpc USING (datasetversion_id)
LEFT JOIN biocultural.date_of_collection doc USING (datasetversion_id)
ORDER BY dataset_id, versionnumber ASC, minorversionnumber ASC
;
```

| title | dataset_id | datasetversion_id | version | createtime | production_date | date_of_deposit | ds_description_date | time_period_covered_start | time_period_covered_end | date_of_collection_start | date_of_collection_end |
|:---|---:|---:|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| test | 10 | 2 | 1.0 | 2022-12-07 03:51:16 | NA | 2022-12-06 | NA | NA | NA | 2022-10-12 | 2022-10-22 |
| 25 años de investigación socio-ecológica en el Instituto de Investigación de Recursos Biológicos Alexander von Humboldt. Año 2020 | 10 | 9 | 2.0 | 2022-12-14 21:42:35 | NA | 2022-12-06 | NA | NA | NA | 2020-10-01 | 2020-12-30 |
| Encuesta socioecológica para los municipio de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta) | 11 | 3 | 1.0 | 2022-12-09 19:19:55 | NA | 2022-12-09 | NA | NA | NA | 2018-07-07 | 2018-07-19 |
| Encuesta socioecológica para los municipio de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta) | 11 | 3 | 1.0 | 2022-12-09 19:19:55 | NA | 2022-12-09 | NA | NA | NA | 2018-02-17 | 2018-03-01 |
| Encuesta socioecológica para los municipio de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta) | 11 | 3 | 1.0 | 2022-12-09 19:19:55 | NA | 2022-12-09 | NA | NA | NA | 2018-09-07 | 2018-09-20 |
| Encuesta socioecológica para los municipio de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 11 | 7 | 1.1 | 2022-12-14 15:15:01 | NA | 2022-12-09 | NA | NA | NA | 2018-02-17 | 2018-03-01 |
| Encuesta socioecológica para los municipio de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 11 | 7 | 1.1 | 2022-12-14 15:15:01 | NA | 2022-12-09 | NA | NA | NA | 2018-07-07 | 2018-07-19 |
| Encuesta socioecológica para los municipio de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 11 | 7 | 1.1 | 2022-12-14 15:15:01 | NA | 2022-12-09 | NA | NA | NA | 2018-09-07 | 2018-09-20 |
| Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 11 | 10 | 1.2 | 2022-12-15 01:07:12 | NA | 2022-12-09 | NA | NA | NA | 2018-07-07 | 2018-07-19 |
| Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 11 | 10 | 1.2 | 2022-12-15 01:07:12 | NA | 2022-12-09 | NA | NA | NA | 2018-02-17 | 2018-03-01 |
| Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 11 | 10 | 1.2 | 2022-12-15 01:07:12 | NA | 2022-12-09 | NA | NA | NA | 2018-09-07 | 2018-09-20 |
| Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 11 | 23 | 1.3 | 2022-12-21 02:12:50 | 2018-09-30 | 2022-12-09 | NA | NA | NA | 2018-09-07 | 2018-09-20 |
| Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 11 | 23 | 1.3 | 2022-12-21 02:12:50 | 2018-09-30 | 2022-12-09 | NA | NA | NA | 2018-07-07 | 2018-07-19 |
| Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 11 | 23 | 1.3 | 2022-12-21 02:12:50 | 2018-09-30 | 2022-12-09 | NA | NA | NA | 2018-02-17 | 2018-03-01 |
| Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 11 | 24 | 1.4 | 2022-12-21 02:14:29 | 2018-09-30 | 2022-12-09 | NA | NA | NA | 2018-02-17 | 2018-03-01 |
| Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 11 | 24 | 1.4 | 2022-12-21 02:14:29 | 2018-09-30 | 2022-12-09 | NA | NA | NA | 2018-09-07 | 2018-09-20 |
| Encuesta socioecológica para los municipios de El Carmen de Chucurí (veredas Islanda y La Belleza); Cimitarra (veredas El Águila y Guineal) y Santa Barbara (veredas Salinas y Esparta). Año 2018 | 11 | 24 | 1.4 | 2022-12-21 02:14:29 | 2018-09-30 | 2022-12-09 | NA | NA | NA | 2018-07-07 | 2018-07-19 |
| Recopilación y sistematización de información de los procesos de formulación del Plan de Manejo de los páramos y de las estrategias de monitoreo desarrolladas por las Corporaciones Autónomas Regionales. | 18 | 4 | 1.0 | 2022-12-14 13:58:35 | NA | 2022-12-14 | NA | NA | NA | 2019-10-10 | 2019-10-22 |
| Recopilación y sistematización de información de los procesos de formulación del Plan de Manejo de los páramos y de las estrategias de monitoreo desarrolladas por las Corporaciones Autónomas Regionales. Año 2019 | 18 | 6 | 1.1 | 2022-12-14 15:11:44 | NA | 2022-12-14 | NA | NA | NA | 2019-10-10 | 2019-10-22 |
| Encuesta socioecológica sobre unidades de paisaje en el Valle de Sibundoy, Putumayo. Año 2020 | 22 | 5 | 1.0 | 2022-12-14 14:50:03 | NA | 2022-12-14 | NA | NA | NA | 2020-02-01 | 2020-06-30 |

Displaying records 1 - 20

| variable | group | formato | nivel | relaciones | comentario |
|----|----|----|----|----|----|
| productionDate | producción / deposición | texto (contiene `N/A`) | versión | Se pone a veces la fecha dateOfCollection_end, a veces ulterior |  |
| dateOfDeposit | producción / deposición | fechas limpias | dataset | usualmente ultima fecha |  |
| dsDescriptionDate | producción / deposición | texto (contiene año sin mes ni día) | versión (usualmente dataset) | Regularmente la misma fecha que productionDate |  |
| timePeriodCovered_start | metodología | fechas limpias | dataset |  | muy pocos valores |
| timePeriodCovered_end | metodología | fechas limpias | dataset | usualmente más amplio que las demás | muy pocos valores |
| dateOfCollection_start | metodología | fechas limpias | multiple in version |  |  |
| dateOfCollection_end | metodología | fechas limpias | multiple in version |  |  |
