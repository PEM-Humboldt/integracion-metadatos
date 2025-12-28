# Roles y personas en los catalogos institucionales
Marius Bottin

## Conección base de datos

``` r
library(RPostgres)
host<-"localhost"
meta_i2d<-dbConnect(Postgres(),dbname="meta_i2d",host=host)
```

## Dataverse

``` sql
SELECT datasetversion_id,'author' AS role, NULL AS type, author_name, author_affiliation, author_identifier_scheme, author_identifier, NULL AS abbreviation, NULL AS url, NULL AS email
FROM biocultural.author a
LEFT JOIN biocultural.datasetversion dv USING (datasetversion_id)
WHERE dv.lastversion
UNION ALL
SELECT datasetversion_id,'contributor' AS role, contributor_type, contributor_name, NULL, NULL, NULL, NULL, NULL, NULL
FROM biocultural.contributor c
LEFT JOIN biocultural.datasetversion dv USING (datasetversion_id)
WHERE dv.lastversion
UNION ALL
SELECT datasetversion_id, 'depositor' AS role, NULL AS type, depositor, NULL, NULL, NULL, NULL, NULL, NULL
FROM biocultural.citation c
LEFT JOIN biocultural.datasetversion dv USING (datasetversion_id)
WHERE dv.lastversion
UNION ALL
SELECT datasetversion_id, 'producer' AS role, NULL AS type, producer_name, producer_affiliation, NULL, NULL, producer_abbreviation, producer_url, NULL
FROM biocultural.producer p
LEFT JOIN biocultural.datasetversion dv USING (datasetversion_id)
WHERE dv.lastversion
UNION ALL
SELECT datasetversion_id, 'contact' AS role, NULL AS type, dataset_contact_name, dataset_contact_affiliation, NULL, NULL, NULL, NULL, dataset_contact_email
FROM biocultural.dataset_contact dc
LEFT JOIN biocultural.datasetversion dv USING (datasetversion_id)
WHERE dv.lastversion
```

| datasetversion_id | role | type | author_name | author_affiliation | author_identifier_scheme | author_identifier | abbreviation | url | email |
|---:|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 6 | author | NA | Pachón, Luis Felipe | Contratista Instituto Humboldt | NA | NA | NA | NA | NA |
| 9 | author | NA | Instituto Humboldt | IAvH | NA | NA | NA | NA | NA |
| 13 | author | NA | Instituto Humboldt | IAvH | NA | NA | NA | NA | NA |
| 15 | author | NA | Instituto Humboldt | Programa de Ciencias Básicas de la Biodiversidad | NA | NA | NA | NA | NA |
| 17 | author | NA | Instituto Humboldt | IAvH | NA | NA | NA | NA | NA |
| 18 | author | NA | Instituto Humboldt | IAvH | NA | NA | NA | NA | NA |
| 19 | author | NA | Lizeth Paola, Ortiz Guengue | Contratista Instituto Humboldt | NA | NA | NA | NA | NA |
| 24 | author | NA | Garzón, Camilo | Investigador Instituto Humboldt | NA | NA | NA | NA | NA |
| 24 | author | NA | Hernández, María Cristina | Contratista Instituto Humboldt | NA | NA | NA | NA | NA |
| 24 | author | NA | Pérez, Diego Randolf | Investigador Instituto Humboldt | NA | NA | NA | NA | NA |

Displaying records 1 - 10

``` r
dbExecute(meta_i2d,"CREATE OR REPLACE VIEW biocultural.pers_role AS(
SELECT datasetversion_id,'author' AS role, NULL AS type, author_name AS name, author_affiliation AS affiliation, author_identifier_scheme, author_identifier, NULL AS abbreviation, NULL AS url, NULL AS email
FROM biocultural.author a
LEFT JOIN biocultural.datasetversion dv USING (datasetversion_id)
WHERE dv.lastversion
UNION ALL
SELECT datasetversion_id,'contributor' AS role, contributor_type, contributor_name, NULL, NULL, NULL, NULL, NULL, NULL
FROM biocultural.contributor c
LEFT JOIN biocultural.datasetversion dv USING (datasetversion_id)
WHERE dv.lastversion
UNION ALL
SELECT datasetversion_id, 'depositor' AS role, NULL AS type, depositor, NULL, NULL, NULL, NULL, NULL, NULL
FROM biocultural.citation c
LEFT JOIN biocultural.datasetversion dv USING (datasetversion_id)
WHERE dv.lastversion
UNION ALL
SELECT datasetversion_id, 'producer' AS role, NULL AS type, producer_name, producer_affiliation, NULL, NULL, producer_abbreviation, producer_url, NULL
FROM biocultural.producer p
LEFT JOIN biocultural.datasetversion dv USING (datasetversion_id)
WHERE dv.lastversion
UNION ALL
SELECT datasetversion_id, 'contact' AS role, NULL AS type, dataset_contact_name, dataset_contact_affiliation, NULL, NULL, NULL, NULL, dataset_contact_email
FROM biocultural.dataset_contact dc
LEFT JOIN biocultural.datasetversion dv USING (datasetversion_id)
WHERE dv.lastversion
)")
```

    [1] 0

## Ceiba

``` sql
WITH
prep1 AS(
SELECT cd_contact,STRING_AGG(DISTINCT delivery_point, '|') delivery_point
FROM ceiba.delivery_point
GROUP BY cd_contact
),
prep2 AS(
SELECT cd_creator, STRING_AGG(DISTINCT electronic_mail_address,'|') electronic_mail_address, STRING_AGG(DISTINCT position_name, '|') position_name
FROM ceiba.electronic_mail_address
FULL JOIN ceiba.position_name USING (cd_creator)
GROUP BY cd_creator
),
a AS(
SELECT cd_xml_doc,'contact' AS orig,organization_name AS affiliation, position_name AS type,  phone, electronic_mail_address AS email, online_url, given_name, sur_name, delivery_point, city, administrative_area, country, postal_code, user_id_text AS other_id, directory id_type
FROM ceiba.contact
LEFT JOIN prep1 USING (cd_contact)
UNION ALL
SELECT cd_xml_doc,'associated_party', organization_name AS affiliation, position_name AS type,  phone, electronic_mail_address AS email, online_url, given_name, sur_name, delivery_point, city, administrative_area, country, postal_code, user_id_text AS other_id, directory id_type
FROM ceiba.associated_party
UNION ALL
SELECT cd_xml_doc,'creator', organization_name AS affiliation, position_name AS type,  phone, electronic_mail_address AS email, online_url, given_name, sur_name, delivery_point, city, administrative_area, country, postal_code, user_id_text AS other_id, directory id_type
FROM ceiba.creator
LEFT JOIN prep2 USING (cd_creator)
UNION ALL
SELECT cd_xml_doc,'metadata_provider', organization_name AS affiliation, position_name AS type,  phone, electronic_mail_address AS email, online_url, given_name, sur_name, delivery_point, city, administrative_area, country, postal_code, user_id_text AS other_id, directory id_type
FROM ceiba.metadata_provider
)
SELECT a.*,p.role, p.user_id_text AS id_other, p.directory AS id_other_type 
FROM ceiba.personnel p
FULL JOIN a USING (cd_xml_doc,given_name,sur_name)
ORDER BY cd_xml_doc
```

| cd_xml_doc | orig | affiliation | type | phone | email | online_url | given_name | sur_name | delivery_point | city | administrative_area | country | postal_code | other_id | id_type | role | id_other | id_other_type |
|---:|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 1 | creator | UNISANGIL | INVESTIGADOR PRINCIPAL | 3213492214 | jaysonsierra@unisangil.edu.co | NA | JAYSON JEFFRE | SIERRA HERNANDEZ | CALLE 3A \# 7-38 | SAN GIL | SANTANDER | CO | NA | NA | NA | NA | NA | NA |
| 1 | contact | UNISANGIL | INVESTIGADOR PRINCIPAL | 3213492214 | jaysonsierra@unisangil.edu.co | NA | JAYSON JEFFRE | SIERRA HERNANDEZ | CALLE 3A \# 7-38 | SAN GIL | SANTANDER | CO | NA | NA | NA | NA | NA | NA |
| 1 | metadata_provider | UNISANGIL | INVESTIGADOR PRINCIPAL | 3213492214 | jaysonsierra@unisangil.edu.co | NA | JAYSON JEFFRE | SIERRA HERNANDEZ | CALLE 3A \# 7-38 | SAN GIL | SANTANDER | CO | NA | NA | NA | NA | NA | NA |
| 2 | metadata_provider | GEOTEC INGENIERIA LTDA | investigadora principal | 2574469 | jfaljure@geotecingenieria.com | NA | Mery Helen Tijaro Orejuela | Tijaro Orejuela | CALLE 92 15 62 OF 301 | Bogota | Cundinamarca | CO | NA | NA | NA | NA | NA | NA |
| 2 | associated_party | GEOTEC INGENIERIA LTDA | investigadora principal | 2574469 | jfaljure@geotecingenieria.com | NA | Mery Helen Tijaro Orejuela | Tijaro Orejuela | CALLE 92 15 62 OF 301 | Bogota | Cundinamarca | CO | NA | NA | NA | NA | NA | NA |
| 2 | contact | GEOTEC INGENIERIA LTDA | investigadora principal | 2574469 | jfaljure@geotecingenieria.com | NA | Mery Helen Tijaro Orejuela | Tijaro Orejuela | CALLE 92 15 62 OF 301 | Bogota | Cundinamarca | CO | NA | NA | NA | NA | NA | NA |
| 2 | creator | GEOTEC INGENIERIA LTDA | Representante Legal | 2574469 | jfaljure@geotecingenieria.com | NA | Jose Fernando | Aljure | CALLE 92 15 62 OF 301 | Bogota | Cundinamarca | CO | NA | NA | NA | NA | NA | NA |
| 3 | creator | Bioasesores de Colombia SAS | Gerente | 4032837 | bioasesoresdecolombia@gmail.com | NA | Gilbert | Acevedo | Calle 72J \# Transv 28G-104 | Cali | Valle | CO | NA | NA | NA | NA | NA | NA |
| 3 | associated_party | Bioasesores de Colombia SAS | Bióloga consultora | 3146466599 | paula2177@hotmail.com | NA | Paula Andrea | Bonilla | Calle 72J No. Trans 28G-104 | Cali | Valle | CO | NA | NA | NA | NA | NA | NA |
| 3 | contact | Bioasesores de Colombia SAS | Directora Administrativa | 4032837 | natalialsr@yahoo.es | NA | Natalia | Santos | Calle 72J \# Transv 28G-104 | Cali | Valle | CO | NA | NA | NA | NA | NA | NA |

Displaying records 1 - 10

``` r
dbExecute(meta_i2d,"CREATE OR REPLACE VIEW ceiba.pers_role AS(
WITH
prep1 AS(
SELECT cd_contact,STRING_AGG(DISTINCT delivery_point, '|') delivery_point
FROM ceiba.delivery_point
GROUP BY cd_contact
),
prep2 AS(
SELECT cd_creator, STRING_AGG(DISTINCT electronic_mail_address,'|') electronic_mail_address, STRING_AGG(DISTINCT position_name, '|') position_name
FROM ceiba.electronic_mail_address
FULL JOIN ceiba.position_name USING (cd_creator)
GROUP BY cd_creator
),
a AS(
SELECT cd_xml_doc,'contact' AS orig,organization_name AS affiliation, position_name AS type,  phone, electronic_mail_address AS email, online_url, given_name, sur_name, delivery_point, city, administrative_area, country, postal_code, user_id_text AS other_id, directory id_type
FROM ceiba.contact
LEFT JOIN prep1 USING (cd_contact)
UNION ALL
SELECT cd_xml_doc,'associated_party', organization_name AS affiliation, position_name AS type,  phone, electronic_mail_address AS email, online_url, given_name, sur_name, delivery_point, city, administrative_area, country, postal_code, user_id_text AS other_id, directory id_type
FROM ceiba.associated_party
UNION ALL
SELECT cd_xml_doc,'creator', organization_name AS affiliation, position_name AS type,  phone, electronic_mail_address AS email, online_url, given_name, sur_name, delivery_point, city, administrative_area, country, postal_code, user_id_text AS other_id, directory id_type
FROM ceiba.creator
LEFT JOIN prep2 USING (cd_creator)
UNION ALL
SELECT cd_xml_doc,'metadata_provider', organization_name AS affiliation, position_name AS type,  phone, electronic_mail_address AS email, online_url, given_name, sur_name, delivery_point, city, administrative_area, country, postal_code, user_id_text AS other_id, directory id_type
FROM ceiba.metadata_provider
)
SELECT a.*,p.role, p.user_id_text AS id_other, p.directory AS id_other_type 
FROM ceiba.personnel p
FULL JOIN a USING (cd_xml_doc,given_name,sur_name)
ORDER BY cd_xml_doc)
")
```

    [1] 0

## Geonetwork

``` sql
SELECT cd_xml_doc, 'responsible_party_1' AS orig, individual_name_character_string AS name, organisation_name_character_string AS organization, position_name_character_string AS position_name, ci_role_code_code_list_value AS role, city_character_string AS city, country_character_string AS country, administrative_area_character_string AS administrative_area, url, STRING_AGG(m.character_string,'|') mails, STRING_AGG(a.character_string, '|') AS adresses, STRING_AGG(p.character_string,'|') phones
FROM geonetwork.citation_ci_citation_cited_responsible_party_1
LEFT JOIN geonetwork.ci_contact_address_ci_address_electronic_mail_address_3 m USING (cd_citation_ci_citation_cited_responsible_party_1)
LEFT JOIN geonetwork.info_ci_contact_address_ci_address_delivery_point_2 a USING (cd_citation_ci_citation_cited_responsible_party_1)
LEFT JOIN geonetwork.voice p USING (cd_citation_ci_citation_cited_responsible_party_1)
GROUP BY cd_xml_doc, individual_name_character_string, organisation_name_character_string, position_name_character_string, ci_role_code_code_list_value , city_character_string , country_character_string , administrative_area_character_string, url
UNION ALL
SELECT cd_xml_doc, 'responsible_party_2' AS orig, individual_name_character_string AS name, organisation_name_character_string AS organization, position_name_character_string AS position_name, code_list_value AS role, city_character_string AS city, country_character_string AS country, NULL AS administrative_area, NULL AS url, electronic_mail_address_character_string mails, delivery_point_character_string AS adresses, voice_character_string phones
FROM geonetwork.citation_ci_citation_cited_responsible_party_2
UNION ALL
SELECT cd_xml_doc, 'contact' AS orig, individual_name_character_string AS name, organisation_name_character_string AS organization, position_name_character_string AS position_name, ci_role_code_code_list_value AS role, city_character_string AS city, country_character_string AS country, administrative_area_character_string AS administrative_area, url, STRING_AGG(m.character_string,'|') mails, delivery_point_character_string AS adresses, voice_character_string phones
FROM geonetwork.contact
LEFT JOIN geonetwork.ci_contact_address_ci_address_electronic_mail_address_1 m USING (cd_contact)
GROUP BY cd_xml_doc,individual_name_character_string , organisation_name_character_string , position_name_character_string , ci_role_code_code_list_value , city_character_string , country_character_string , administrative_area_character_string, url, delivery_point_character_string , voice_character_string 
UNION ALL
SELECT cd_xml_doc, 'distributor' AS orig, individual_name_character_string AS name, organisation_name_character_string AS organization, position_name_character_string AS position_name, ci_role_code_code_list_value AS role, city_character_string AS city, country_character_string AS country, administrative_area_character_string AS administrative_area, NULL url, electronic_mail_address_character_string AS mails, delivery_point_character_string AS adresses, voice_character_string phones
FROM geonetwork.distributor
UNION ALL
SELECT cd_xml_doc, 'point_of_contact' AS orig, individual_name_character_string AS name, organisation_name_character_string AS organization, position_name_character_string AS position_name, ci_role_code_code_list_value AS role, city_character_string AS city, country_character_string AS country, administrative_area_character_string AS administrative_area, NULL AS url, STRING_AGG(m.character_string,'|') mails, STRING_AGG(a.character_string, '|') AS adresses, voice_character_string phones
FROM geonetwork.point_of_contact
LEFT JOIN geonetwork.ci_contact_address_ci_address_electronic_mail_address_2 m USING (cd_point_of_contact)
LEFT JOIN geonetwork.info_ci_contact_address_ci_address_delivery_point_1 a USING (cd_point_of_contact)
GROUP BY cd_xml_doc,  individual_name_character_string, organisation_name_character_string , position_name_character_string, ci_role_code_code_list_value, city_character_string, country_character_string, administrative_area_character_string, voice_character_string  
```

| cd_xml_doc | orig | name | organization | position_name | role | city | country | administrative_area | url | mails | adresses | phones |
|---:|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| 1 | responsible_party_1 | Adriana Mayorquin | Parques Nacionales Naturales De Colombia | Profesional Investigación y Monitoreo DTAO | author | Bogotá D.C. | Colombia | NA | NA | @parquesnacionales.gov.co | Cl. 74 \#11-81 | +57 1 3532400 |
| 1 | responsible_party_1 | Alvaro Cogollo | Jardín Botánico Joaquín Antonio Uribe | Director Científico | author | Medellin | Colombia | NA | NA | comunicaciones@botanicomedellin.org | Calle 73 N.51D-14 | +57 4 4445500 |
| 1 | responsible_party_1 | Ana Maria Castaño | Sociedad Antioqueña de Ornitología-SAO | Presidente Junta Directita | author | Medellin | Colombia | NA | NA | sao@sao.org.co | Cra 52 N. 73 - 298 | +57 4 211 54 61 |
| 1 | responsible_party_1 | Andrea Morales Rozo | Sociedad Antioqueña de Ornitología-SAO | Directora Ejecutiva | author | Medellin | Colombia | NA | NA | sao@sao.org.co | Cra 52 N. 73 - 298 | +57 4 211 54 61 |
| 1 | responsible_party_1 | Carolina Sanin Acevedo | Corporación Parque Explora | Jefe Biodiversidad y Conservación | author | Medellin | Colombia | NA | NA | info@parqueexplora.org | Carrera 52 Nº 73 - 75 | 57 4 516 83 00 |
| 1 | responsible_party_1 | Claudia Maria Villa Garcia | Instituto de Investigación de Recursos Biológicos Alexander von Humboldt | Coordinadora de Comunicciones | pointOfContact | Bogotá D.C. | NA | NA | NA | cmvilla@humboldt.org.co | Avenida Paseo Bolivar (Circunvalar) 16-20 Sede Venado | +57 1 3202767 |
| 1 | responsible_party_1 | Claudia Patricia Aguirre | Corporación Parque Explora | Directora Educación y Contenidos | author | Medellin | Colombia | NA | NA | info@parqueexplora.org | Carrera 52 Nº 73 - 75 | 57 4 516 83 00 |
| 1 | responsible_party_1 | Daniel Castañeda | Parques Nacionales Naturales De Colombia | Profesional Especializado DTAO | author | Bogotá D.C. | NA | NA | NA | @parquesnacionales.gov.co | Cl. 74 \#11-81 | +57 1 3532400 |
| 1 | responsible_party_1 | Esteban Alvarez | Jardín Botánico Joaquín Antonio Uribe | Director Grupo de Investigación | author | Medellin | Colombia | NA | NA | comunicaciones@botanicomedellin.org | Calle 73 N.51D-14 | +57 4 211 54 61 |
| 1 | responsible_party_1 | Luisa Fernanda Cardon Leon | Parques Nacionales Naturales De Colombia | Profesional Recurso Hídrico | author | Bogotá D.C. | Colombia | NA | NA | @parquesnacionales.gov.co | Cl. 74 \#11-81 | +57 1 3532400 |

Displaying records 1 - 10

``` r
dbExecute(meta_i2d,"CREATE OR REPLACE VIEW geonetwork.pers_role AS(
SELECT cd_xml_doc, 'responsible_party_1' AS orig, individual_name_character_string AS name, organisation_name_character_string AS organization, position_name_character_string AS position_name, ci_role_code_code_list_value AS role, city_character_string AS city, country_character_string AS country, administrative_area_character_string AS administrative_area, url, STRING_AGG(m.character_string,'|') mails, STRING_AGG(a.character_string, '|') AS adresses, STRING_AGG(p.character_string,'|') phones
FROM geonetwork.citation_ci_citation_cited_responsible_party_1
LEFT JOIN geonetwork.ci_contact_address_ci_address_electronic_mail_address_3 m USING (cd_citation_ci_citation_cited_responsible_party_1)
LEFT JOIN geonetwork.info_ci_contact_address_ci_address_delivery_point_2 a USING (cd_citation_ci_citation_cited_responsible_party_1)
LEFT JOIN geonetwork.voice p USING (cd_citation_ci_citation_cited_responsible_party_1)
GROUP BY cd_xml_doc, individual_name_character_string, organisation_name_character_string, position_name_character_string, ci_role_code_code_list_value , city_character_string , country_character_string , administrative_area_character_string, url
UNION ALL
SELECT cd_xml_doc, 'responsible_party_2' AS orig, individual_name_character_string AS name, organisation_name_character_string AS organization, position_name_character_string AS position_name, code_list_value AS role, city_character_string AS city, country_character_string AS country, NULL AS administrative_area, NULL AS url, electronic_mail_address_character_string mails, delivery_point_character_string AS adresses, voice_character_string phones
FROM geonetwork.citation_ci_citation_cited_responsible_party_2
UNION ALL
SELECT cd_xml_doc, 'contact' AS orig, individual_name_character_string AS name, organisation_name_character_string AS organization, position_name_character_string AS position_name, ci_role_code_code_list_value AS role, city_character_string AS city, country_character_string AS country, administrative_area_character_string AS administrative_area, url, STRING_AGG(m.character_string,'|') mails, delivery_point_character_string AS adresses, voice_character_string phones
FROM geonetwork.contact
LEFT JOIN geonetwork.ci_contact_address_ci_address_electronic_mail_address_1 m USING (cd_contact)
GROUP BY cd_xml_doc,individual_name_character_string , organisation_name_character_string , position_name_character_string , ci_role_code_code_list_value , city_character_string , country_character_string , administrative_area_character_string, url, delivery_point_character_string , voice_character_string 
UNION ALL
SELECT cd_xml_doc, 'distributor' AS orig, individual_name_character_string AS name, organisation_name_character_string AS organization, position_name_character_string AS position_name, ci_role_code_code_list_value AS role, city_character_string AS city, country_character_string AS country, administrative_area_character_string AS administrative_area, NULL url, electronic_mail_address_character_string AS mails, delivery_point_character_string AS adresses, voice_character_string phones
FROM geonetwork.distributor
UNION ALL
SELECT cd_xml_doc, 'point_of_contact' AS orig, individual_name_character_string AS name, organisation_name_character_string AS organization, position_name_character_string AS position_name, ci_role_code_code_list_value AS role, city_character_string AS city, country_character_string AS country, administrative_area_character_string AS administrative_area, NULL AS url, STRING_AGG(m.character_string,'|') mails, STRING_AGG(a.character_string, '|') AS adresses, voice_character_string phones
FROM geonetwork.point_of_contact
LEFT JOIN geonetwork.ci_contact_address_ci_address_electronic_mail_address_2 m USING (cd_point_of_contact)
LEFT JOIN geonetwork.info_ci_contact_address_ci_address_delivery_point_1 a USING (cd_point_of_contact)
GROUP BY cd_xml_doc,  individual_name_character_string, organisation_name_character_string , position_name_character_string, ci_role_code_code_list_value, city_character_string, country_character_string, administrative_area_character_string, voice_character_string  
)")
```

    [1] 0

# Exportación Excel

``` r
allContacts<-list()
allContacts$biocultural<-dbReadTable(meta_i2d,Id(schema="biocultural","pers_role"))
allContacts$ceiba<-dbReadTable(meta_i2d,Id(schema="ceiba","pers_role"))
allContacts$geonetwork<-dbReadTable(meta_i2d,Id(schema="geonetwork","pers_role"))
require(rdsTaxVal)
```

    Loading required package: rdsTaxVal

``` r
saveInExcel("../../../data_metadatos_catalogos/pers_role.xlsx",allContacts)
```

    Writing sheets: biocultural ceiba geonetwork
    into file:/home/marius/Travail/traitementDonnees/2024_metadatos_catalogos/data_metadatos_catalogos/pers_role.xlsx

``` sql
SELECT p.*, x.title_text
FROM ceiba.pers_role p
LEFT JOIN ceiba.xml_doc x USING (cd_xml_doc)
```

## Analysis

### Geonetwork

``` sql
SELECT name,count(*)
FROM geonetwork.pers_role
WHERE 
  name ~* 'administrador' OR 
  name ~* 'direc' OR 
  name ~* 'gesti' OR 
  name ~* 'superv' OR
  name ~* 'univers' OR
  name ~* 'instit' OR
  name ~* 'servic' OR
  name ~* 'nombre' OR
  name ~* 'corpor' OR
  name ~* 'i2d' OR
  name ~* 'transformando'
GROUP BY name
ORDER BY name
  
```

| name | count |
|:---|---:|
| Administrador de información geoespacial | 1 |
| Administrador de Información geoespacial | 1 |
| Administrador de la información geoespacial | 1 |
| Administrador información | 2 |
| Administrador información geoespacial | 1914 |
| Administrador Información geoespacial | 1 |
| Administrador Información Geoespacial | 19 |
| Administrador información geoespacial de la Infraestructura Institucional de Datos - I2D | 1 |
| Administrador información geoespacial (Infraestructura Institucional de Datos - I2D) | 7 |
| Corporación Autónoma Regional de Caldas (Corpocaldas) | 2 |

Displaying records 1 - 10

``` sql
SELECT name,count(*),ARRAY_AGG(DISTINCT organization) organizations,ARRAY_AGG(DISTINCT position_name) positions
FROM geonetwork.pers_role
GROUP BY name
ORDER BY count(*) DESC
```

| name | count | organizations | positions |
|:---|---:|:---|:---|
| Administrador información geoespacial | 1914 | {“Administrador información geoespacial”,“Instituto de Hidrología Meteorología y Estudios Ambientales IDEAM - Instituto de Investigación de Recursos Biológicos Alexander von Humboldt”,“instituto de Investigación de Recursos Biológicos Alexander von Humboldt”,“Instituto de Investigación de Recursos Biológicos Alexander von Humboldt”,“Instituto de Investigación de Recursos Biológicos Alexander Von Humboldt”,“Instituto de Investigación de Recursos Biológicos Alexander von Humboldt IAvH”,“Instituto de Investigaciones de Recursos Biológicos Alexander Von Humboldt”} | {Contratista,“Infraestructura Institucional de Datos - I2D”,“Infraestructura Institucional de Datos-I2D”,“Insfraestructura Institucional de Datos I2D”,NULL} |
| Infraestructura Institucional de Datos | 88 | {“Instituto de Investigación de Recursos Biológicos Alexander von Humboldt”} | {“Infraestructura Institucional de Datos - I2D”} |
| NA | 87 | {“Administrador información geoespacial”,“Corporación Autónoma Regional de Caldas - Corpocaldas”,“Corporación Autónoma Regional de la Frontera Nororiental - Corponor”,“Corporación Autónoma Regional del Cauca - CRC”,“Corporación Autónoma Regional del Cesar - Corpocesar”,“Corporación Autónoma Regional del Magdalena - Corpamag”,“Corporación Autónoma Regional Del Quindío - CRQ”,“Corporación Autónoma Regional del Tolima - Cortolima”,“Corporación Autónoma Regional del Valle del Cauca”,“Corporación Autónoma Regional del Valle del Cauca - CVC”,“Corporación Autónoma Regional de Santander - CAS”,“Corporación para el Desarrollo Sostenible del Urabá - Corpourabá”,“Fundacion Biocolombia”,“Fundación Biocolombia”,“Fundación Ecológica Las Mellizas”,“Fundación Pro-Sierra Nevada de Santa Marta”,“Instituto de Hidrología, Meteorología y Estudios Ambientales - IDEAM”,“Instituto de Hidrología, Meteorología y Estudios Ambientales - IDEAM”,“Instituto de Hidrología, Meteorología y Estudios Ambientales - IDEAM, Subdireccion de Hidrologia Grupo de Modelacion”,“Instituto de Investigación de Recursos Biológicos Alexander von Humboldt”,NULL} | {Contrastista,Contratista,“Infraestructura Institucional de Datos - I2D”,“Instituto de Investigación de Recursos Biológicos Alexander von Humboldt”,“Investigador asistente II”,“Programa GIC”,NULL} |
| Peña Ocampo, William | 66 | {“Instituto de Investigación de Recursos Biológicos Alexander von Humboldt”} | {“Infraestructura Institucional de Datos - I2D”} |
| Paola Avilán Rey | 63 | {“Instituto de Investigación de Recursos Biológicos Alexander von Humboldt”} | {Supervisor,NULL} |
| Andrés Felipe Carvajal Vanegas | 62 | {“Instituto de Investigación de Recursos Biológicos Alexander von Humboldt”} | {Contratista,“Seleccionar entre el rol de Investigador o Contratista”} |
| William Alexander Peña Ocampo | 47 | {“Instituto de Investigación de Recursos Biológicos Alexander von Humboldt”} | {“Infraestructura Institucional de Datos-I2D”,Investigador,“Investigador asistente II”,“Seleccionar entre el rol de Investigador o Contratista”} |
| Carlos Pedraza | 42 | {“Instituto de Investigación de Recursos Biológicos Alexander von Humboldt”,NULL} | {Contratista,“Grupo Técnico”,NULL} |
| Dolors Armenteras | 33 | {“Instituto de Investigación de Recursos Biológicos Alexander von Humboldt”} | {“Comité operativo proyecto”,“Coordinadora Nacional”} |
| Edwin Tamayo | 33 | {“Edwin Tamayo”,“Instituto de Investigación de Recursos Biológicos Alexander von Humboldt”} | {Contratista,“Infraestructura Institucional de Datos - I2D”,NULL} |

Displaying records 1 - 10

### Biocultural

``` sql
SELECT name, count(*), ARRAY_AGG(DISTINCT affiliation)
FROM biocultural.pers_role
GROUP BY name
ORDER BY count(*) DESC
```

| name | count | array_agg |
|:---|---:|:---|
| Admin, Dataverse | 16 | {NULL} |
| Santamaria, Andres | 12 | {Contratista,NULL} |
| Pastas, Emmerson | 9 | {“Instituto Alexander von Humboldt”,“Instituto Humboldt”,NULL} |
| Instituto Humboldt | 9 | {IAvH,“Línea de investigación en Gobernanza y Equidad, Programa de Ciencias Sociales y Saberes de la Biodiversidad”,“Programa de Ciencias Básicas de la Biodiversidad”} |
| Instituto de Investigación de Recursos Biológicos Alexander von Humboldt | 7 | {IAvH,“Instituto de Investigación de Recursos Biológicos Alexander von Humboldt”} |
| Sarmiento García, Martha Liliana | 4 | {“Contratista IAvH”,“Instituto de Investigación de Recursos Biológicos Alexander von Humboldt”,NULL} |
| Patiño Grajales, Cristian Felipe | 4 | {IAvH,NULL} |
| María Claudia Torres Romero | 3 | {“Instituto de Investigación de Recursos Biológicos Alexander von Humboldt”,“Investigador adjunto”} |
| Alvarez Parales, Juan Felipe Dcaprio | 3 | {“Contratista Instituto de Investigación de Recursos Biológicos Alexander von Humboldt”,NULL} |
| Herrera Bustos, Angela María | 3 | {“Instituto de Investigación de Recursos Biológicos Alexander von Humboldt”,NULL} |

Displaying records 1 - 10

### Ceiba

``` sql
SELECT given_name, sur_name, count(*), ARRAY_AGG(DISTINCT affiliation) affiliations, ARRAY_AGG(DISTINCT role) roles
FROM ceiba.pers_role
GROUP BY given_name, sur_name
ORDER BY count(*) DESC
```

| given_name | sur_name | count | affiliations | roles |
|:---|:---|---:|:---|:---|
| NA | NA | 2242 | {“Asociación Colombiana de Herpetología (ACH)”,“CAF Proambiente LTDA”,“Colección entomológica Forestal”,“Contreebute SAS”,CORANTIOQUIA,“Corporación Centro de Investigación en Palma de Aceite CENIPALMA”,“Frontera Energy Colombia Corp. Sucursal Colombia”,“Fundación para la investigación del Cauca”,“Municipio de Medellín”,“Transportadora de Gas Internacional S.A. E.S.P.”,“Transportadora de Gas Internacional S.A. ESP”,“Universidad del Valle”,NULL} | {author,contentProvider,curator,custodianSteward,distributor,editor,metadataProvider,originator,owner,pointOfContact,principalInvestigator,processor,publisher,reviewer,user,NULL} |
| Juliana | Cardona-Duque | 325 | {“Universidad CES”} | {author,curator,pointOfContact,principalInvestigator,NULL} |
| NA | Apellido | 212 | {Organización} | {NULL} |
| Laura María | Ramírez Hernández | 169 | {“Inerco Consultoría Colombia”,“INERCO Consultoría Colombia”} | {metadataProvider,principalInvestigator,NULL} |
| Ricardo | Restrepo | 160 | {“VCR Ingeniería Ambiental SAS”} | {author,contentProvider,metadataProvider,owner,principalInvestigator,publisher,NULL} |
| Lizette Irene | Quan Young | 158 | {354743,“Universidad CES”,“Universidad CES, Facultad de Ciencias y Biotecnología”} | {author,contentProvider,curator,custodianSteward,metadataProvider,owner,principalInvestigator,NULL} |
| Juan Camilo | Arredondo Salgar | 146 | {“Universidad CES”,“Universidad de Medellín”} | {author,metadataProvider,principalInvestigator,NULL} |
| SGS | S.A.S | 144 | {“SGS Colombia S.A.S”} | {user,NULL} |
| Universidad Nacional | de Colombia | 142 | {“de Biología”,“de Colombia”,“Facultad de Ciencias Agraciass”,“Museo Micológico-MMUNM”,UN,Unal,UNAL,“UNAL, sede Medellín”,Universidad,“Universidad Nacional”,“UNIVERSIDAD NACIONAL”,“Universidad Nacional de Colombia”,“UNIVERSIDAD NACIONAL DE COLOMBIA”,“UNIVERSIDAD NACIONAL DE COLOMBIA SEDE AMAZONIA”,“Universidad Nacional de Colombia sede Medellín”,“Universidad Nacional de Colombia, sede Medellín”,“Universidad Nacional de Colombia Sede Orinoquía”,“Universidad Nacional de Colomia”,“Universidad Nacional, Facultad de Ciencias Agrarias”,“Universodad Nacional de Colombia”,NULL} | {principalInvestigator,user,NULL} |
| Maria Fernanda | Sierra López | 138 | {“Alternativa Ambiental”,“Alternativa Ambiental S.A.S”,“Alternativa Ambiental S.A.S.”,“AM - Alternativa Ambiental S.A.S.”} | {author,metadataProvider,publisher,NULL} |

Displaying records 1 - 10

``` r
dbDisconnect(meta_i2d)
```
