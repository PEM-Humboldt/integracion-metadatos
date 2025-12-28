# Ejemplos de consultas en la capa de integración de metadatos
Marius Bottin

## Conexión base de datos

``` r
library(RPostgres)
host<-"localhost"
meta_i2d<-dbConnect(Postgres(),dbname="meta_i2d",host=host)
```

## Ceiba

Podemos hacer consultas complejas en un catálogo particular.

Por ejemplo, si queremos saber cuales son las extensiones DarwinCore que
se utilizaron en los conjuntos de datos que mencionan la clase aves como
cobertura taxonómica:

``` sql
SELECT m.extension, count(DISTINCT cd_xml_doc) numero_de_conjunto_datos
FROM ceiba.taxonomic_classification tclas
LEFT JOIN ceiba.taxonomic_coverage tcov USING (cd_taxonomic_coverage)
LEFT JOIN ceiba.xml_doc xd USING (cd_xml_doc)
LEFT JOIN ceiba.mapping m USING (cd_xml_doc)
WHERE taxon_rank_value='Aves'
GROUP BY m.extension
```

| extension | numero_de_conjunto_datos |
|:---|---:|
| http://data.ggbn.org/schemas/ggbn/terms/Permit | 28 |
| http://data.ggbn.org/schemas/ggbn/terms/Preservation | 1 |
| http://rs.iobis.org/obis/terms/ExtendedMeasurementOrFact | 1 |
| http://rs.tdwg.org/dwc/terms/Occurrence | 162 |
| NA | 4 |

5 records

## Multi-catálogo

Por ejemplo, si queremos saber en cuántos conjuntos de datos nuestros
colegas Carolina Castro y Diego Pérez están referenciados, en que
catálogo y que año, no importe el rol que está documentado, podemos
hacer:

``` sql
WITH a AS(
SELECT 'ceiba' AS catalog, EXTRACT('year' FROM created::date) "year",
  CASE
    WHEN (sur_name ~* 'Castro' AND given_name ~* 'Carolina') THEN 'Carolina Castro'
    WHEN (sur_name ~* 'P[eé]rez' AND given_name ~* 'Diego') THEN 'Diego Pérez'
  END AS name, cd_xml_doc AS id
FROM ceiba.pers_role
LEFT JOIN ceiba.xml_doc USING (cd_xml_doc)
WHERE (sur_name ~* 'Castro' AND given_name ~* 'Carolina') OR (sur_name ~* 'P[eé]rez' AND given_name ~* 'Diego')
UNION ALL
SELECT 'geonetwork', EXTRACT('year' FROM date_stamp_date_time::date),
CASE
  WHEN name ~* 'Castro' AND name ~* 'Carolina' THEN 'Carolina Castro'
  WHEN name ~* 'Diego' AND name ~* 'P[eé]rez' THEN 'Diego Pérez'
END, cd_xml_doc AS id
FROM geonetwork.pers_role
LEFT JOIN geonetwork.xml_doc USING(cd_xml_doc)
WHERE (name ~* 'Castro' AND name ~* 'Carolina') OR (name ~* 'Diego' AND name ~* 'P[eé]rez')
UNION ALL
SELECT 'biocultural', EXTRACT(year FROM createtime),
CASE
  WHEN name ~* 'Castro' AND name ~* 'Carolina' THEN 'Carolina Castro'
  WHEN name ~* 'Diego' AND name ~* 'P[eé]rez' THEN 'Diego Pérez'
END, dataset_id AS id
FROM biocultural.pers_role
LEFT JOIN biocultural.datasetversion dv USING (datasetversion_id)
WHERE (name ~* 'Castro' AND name ~* 'Carolina') OR (name ~* 'Diego' AND name ~* 'P[eé]rez')
)
SELECT catalog, "year", name, COUNT(DISTINCT id) numero_conjunto_datos
FROM a
GROUP BY catalog, "year", name
ORDER BY "year", COUNT(DISTINCT id)
```

| catalog     | year | name            | numero_conjunto_datos |
|:------------|-----:|:----------------|----------------------:|
| geonetwork  | 2018 | Carolina Castro |                     1 |
| geonetwork  | 2019 | Carolina Castro |                     3 |
| geonetwork  | 2020 | Carolina Castro |                     1 |
| geonetwork  | 2021 | Carolina Castro |                     1 |
| biocultural | 2022 | Diego Pérez     |                     1 |
| geonetwork  | 2023 | Carolina Castro |                     2 |
| biocultural | 2024 | Diego Pérez     |                     1 |

7 records
