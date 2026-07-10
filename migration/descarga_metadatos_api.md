# Utilizar las API para halar y formatear metadatos
Marius Bottin

Primero, enviamos el entorno virtual a R para que reticulate permita
utilizarlo en los chunks en Python:

Importamos los paquetes python necesarios:

``` python
import requests
import dotenv
import os
import json
```

Importamos las variables de ambiente contenidas en el archivo `.env`.

``` python
dotenv.load_dotenv()
```

    True

``` python
api_token=os.getenv("BIOCULTURAL_API_TOKEN_ADMIN")
baseUrl=os.getenv("BIOCULTURAL_URL")
baseUrl
```

    'https://biocultural.humboldt.org.co'

Definimos los parámetros de la consulta a la api:

``` python
apiUrl=baseUrl+'/api/datasets/export'
metadataformat='dataverse_json'
persistentId='doi:10.21068/CTQ20N'
version='1.0'
params = {
    'exporter': metadataformat,
    'persistentId':persistentId,
    'version': version,
}

headers = {
    'X-Dataverse-key': api_token,
}
```

Enviamos la consulta

``` python
response = requests.get(apiUrl, params=params, headers=headers)
```

Interpretación de la respuesta de la API:

``` python
json_dic = response.json()
print(json.dumps(json_dic, indent=4, sort_keys=True))
```

    {
        "authority": "10.21068",
        "datasetType": "dataset",
        "datasetVersion": {
            "citation": "Fundaci\u00f3n Tropenbos Colombia, 2025, \"Mapa de actores estrat\u00e9gicos de los municipios de Solano, Cartagena del Chair\u00e1, Puerto Rico y La Monta\u00f1ita para la implementaci\u00f3n de la Zonificaci\u00f3n Ambiental Participativa\", https://doi.org/10.21068/CTQ20N, Cat\u00e1logo de Datos Socioecol\u00f3gicos, V1",
            "citationDate": "2025-12-12",
            "confidentialityDeclaration": "El Instituto Humboldt entrega los microdatos en forma anonimizada cuidando la confidencialidad y la intimidad de las fuentes en el marco de la constituci\u00f3n pol\u00edtica de Colombia (art\u00edculos 15 y 20), respeta el Habeas Data regulado en la Ley 1266 de 2008 y se acoge a la regulaci\u00f3n de censos y encuestas en los t\u00e9rminos del art\u00edculo 5 de la ley 79 de 1993: \u201clos datos no podr\u00e1n darse a conocer al p\u00fablico ni a las entidades u organismos oficiales, ni a las autoridades p\u00fablicas, sino \u00fanicamente en res\u00famenes num\u00e9ricos, que no hagan posible deducir de ellos informaci\u00f3n alguna de car\u00e1cter individual que pudiera utilizarse para fines comerciales, de tributaci\u00f3n fiscal, de investigaci\u00f3n judicial o cualquier otro diferente del propiamente estad\u00edstico\u201d.",
            "contactForAccess": "Infraestructura Institucional de Datos e Informaci\u00f3n: i2d@humboldt.org.co",
            "createTime": "2025-12-03T04:02:27Z",
            "datasetId": 281,
            "datasetPersistentId": "doi:10.21068/CTQ20N",
            "disclaimer": "El usuario de la informaci\u00f3n se compromete a: 1. Utilizar la informaci\u00f3n \u00fanicamente para los fines autorizados. 2. Respetar y hacer valer frente a terceros los derechos de propiedad de los autores. 3. No distribuir la informaci\u00f3n a terceros sin previa autorizaci\u00f3n de los autores. 4. Dar cr\u00e9ditos a los autores en todos los productos derivados del uso de la informaci\u00f3n. 5. No realizar modificaciones, ni incluir logos - s\u00edmbolos o publicidad diferente a aquella que permita identificar la fuente de la informaci\u00f3n entregada. 6. No comercializar. 7. Responder por la correcta utilizaci\u00f3n de la informaci\u00f3n. 8. Asumir la responsabilidad del uso del software empleado en los an\u00e1lisis y de los resultados obtenidos. 9. Entregar al Instituto Humboldt, copias digitales de los productos que resulten de la cartograf\u00eda entregada (cuando aplique). 10. No ceder las obligaciones adquiridas.",
            "fileAccessRequest": true,
            "files": [
                {
                    "categories": [
                        "Datos"
                    ],
                    "dataFile": {
                        "categories": [
                            "Datos"
                        ],
                        "checksum": {
                            "type": "MD5",
                            "value": "591b7136bc1e65546212685e86c16d6d"
                        },
                        "contentType": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                        "creationDate": "2025-12-12",
                        "fileAccessRequest": true,
                        "filename": "Plantilla de Actores Estrat\u00e9gicos ZAP1 Anonimizado.xlsx",
                        "filesize": 380309,
                        "friendlyType": "Hoja de c\u00e1lculo MS Excel",
                        "id": 572,
                        "md5": "591b7136bc1e65546212685e86c16d6d",
                        "persistentId": "",
                        "publicationDate": "2025-12-12",
                        "rootDataFileId": -1,
                        "storageIdentifier": "file://19b145d98ce-f77f4911a281",
                        "tabularData": false
                    },
                    "datasetVersionId": 124,
                    "label": "Plantilla de Actores Estrat\u00e9gicos ZAP1 Anonimizado.xlsx",
                    "restricted": false,
                    "version": 1
                },
                {
                    "categories": [
                        "Datos"
                    ],
                    "dataFile": {
                        "categories": [
                            "Datos"
                        ],
                        "checksum": {
                            "type": "MD5",
                            "value": "0f9d102b50b9e911171a62d4f434680c"
                        },
                        "contentType": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                        "creationDate": "2025-12-12",
                        "fileAccessRequest": true,
                        "filename": "Plantilla de Actores Estrat\u00e9gicos ZAP1.xlsx",
                        "filesize": 393573,
                        "friendlyType": "Hoja de c\u00e1lculo MS Excel",
                        "id": 571,
                        "md5": "0f9d102b50b9e911171a62d4f434680c",
                        "persistentId": "",
                        "publicationDate": "2025-12-12",
                        "rootDataFileId": -1,
                        "storageIdentifier": "file://19b145d9c09-69e719e23b76",
                        "tabularData": false
                    },
                    "datasetVersionId": 124,
                    "label": "Plantilla de Actores Estrat\u00e9gicos ZAP1.xlsx",
                    "restricted": true,
                    "version": 1
                }
            ],
            "id": 124,
            "lastUpdateTime": "2025-12-12T21:04:57Z",
            "latestVersionPublishingState": "RELEASED",
            "metadataBlocks": {
                "citation": {
                    "displayName": "Citation Metadata",
                    "fields": [
                        {
                            "multiple": false,
                            "typeClass": "primitive",
                            "typeName": "title",
                            "value": "Mapa de actores estrat\u00e9gicos de los municipios de Solano, Cartagena del Chair\u00e1, Puerto Rico y La Monta\u00f1ita para la implementaci\u00f3n de la Zonificaci\u00f3n Ambiental Participativa"
                        },
                        {
                            "multiple": true,
                            "typeClass": "compound",
                            "typeName": "author",
                            "value": [
                                {
                                    "authorAffiliation": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "authorAffiliation",
                                        "value": "Fundaci\u00f3n Tropenbos Colombia"
                                    },
                                    "authorName": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "authorName",
                                        "value": "Fundaci\u00f3n Tropenbos Colombia"
                                    }
                                }
                            ]
                        },
                        {
                            "multiple": true,
                            "typeClass": "compound",
                            "typeName": "datasetContact",
                            "value": [
                                {
                                    "datasetContactAffiliation": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "datasetContactAffiliation",
                                        "value": "Instituto de Investigaci\u00f3n de Recursos Biol\u00f3gicos Alexander von Humboldt"
                                    },
                                    "datasetContactEmail": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "datasetContactEmail",
                                        "value": "pmorales@humboldt.org.co"
                                    },
                                    "datasetContactName": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "datasetContactName",
                                        "value": "Morales Ram\u00edrez, Paola Andrea"
                                    }
                                }
                            ]
                        },
                        {
                            "multiple": true,
                            "typeClass": "compound",
                            "typeName": "dsDescription",
                            "value": [
                                {
                                    "dsDescriptionDate": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "dsDescriptionDate",
                                        "value": "2025-12-03"
                                    },
                                    "dsDescriptionValue": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "dsDescriptionValue",
                                        "value": "La matriz de actores territoriales recoge el conjunto de actores estrat\u00e9gicos que intervienen en el desarrollo de la Zonificaci\u00f3n Ambiental Participativa en cada municipio, permitiendo identificar su presencia, capacidad de incidencia y aportes al proceso. Este instrumento organiza la informaci\u00f3n sobre instituciones p\u00fablicas, organizaciones comunitarias, asociaciones campesinas, colectivos ambientales, instancias de planificaci\u00f3n, entidades educativas, organismos de control y dem\u00e1s actores que desempe\u00f1an un papel relevante en la gesti\u00f3n del territorio.\n\nLa caracterizaci\u00f3n realizada permite reconocer los roles que cada actor cumple en el contexto municipal, destacando su participaci\u00f3n en la toma de decisiones, su v\u00ednculo con el territorio, el conocimiento que aportan y el grado de coordinaci\u00f3n que mantienen con los dem\u00e1s actores involucrados. Asimismo, la matriz documenta el tipo de relaci\u00f3n que establecen con el proceso de zonificaci\u00f3n, ya sea como actores que aportan informaci\u00f3n t\u00e9cnica, como l\u00edderes comunitarios con conocimiento local, como organizaciones que promueven iniciativas ambientales, o como instancias encargadas de validaci\u00f3n institucional y seguimiento.\n\nDe esta manera, la matriz visibiliza el entramado de actores que influye en la planificaci\u00f3n del territorio, permitiendo comprender su diversidad, los diferentes intereses en juego, las oportunidades de articulaci\u00f3n y las posibles tensiones que deben ser gestionadas para avanzar en acuerdos colectivos. Esta herramienta se convierte en un insumo clave para fortalecer la gobernanza territorial, orientar el di\u00e1logo social y consolidar una participaci\u00f3n amplia y equilibrada en los procesos de ordenamiento."
                                    }
                                }
                            ]
                        },
                        {
                            "multiple": true,
                            "typeClass": "controlledVocabulary",
                            "typeName": "subject",
                            "value": [
                                "Agricultural Sciences",
                                "Earth and Environmental Sciences",
                                "Social Sciences"
                            ]
                        },
                        {
                            "multiple": true,
                            "typeClass": "compound",
                            "typeName": "keyword",
                            "value": [
                                {
                                    "keywordValue": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "keywordValue",
                                        "value": "Zonificaci\u00f3n Ambiental Participativa"
                                    }
                                }
                            ]
                        },
                        {
                            "multiple": true,
                            "typeClass": "compound",
                            "typeName": "publication",
                            "value": [
                                {
                                    "publicationCitation": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "publicationCitation",
                                        "value": "Fundaci\u00f3n Tropenbos Colombia, 2025, \"Conflictos socioambientales en los municipios de Cartagena del Chair\u00e1, La Monta\u00f1ita, Puerto Rico y Solano. A\u00f1o 2025\", https://doi.org/10.21068/9QBLLQ, Cat\u00e1logo de Datos Socioecol\u00f3gicos, V1"
                                    },
                                    "publicationIDNumber": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "publicationIDNumber",
                                        "value": "https://doi.org/10.21068/9QBLLQ"
                                    },
                                    "publicationIDType": {
                                        "multiple": false,
                                        "typeClass": "controlledVocabulary",
                                        "typeName": "publicationIDType",
                                        "value": "doi"
                                    },
                                    "publicationRelationType": {
                                        "multiple": false,
                                        "typeClass": "controlledVocabulary",
                                        "typeName": "publicationRelationType",
                                        "value": "IsSupplementTo"
                                    },
                                    "publicationURL": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "publicationURL",
                                        "value": "https://biocultural.humboldt.org.co/dataset.xhtml?persistentId=doi:10.21068/9QBLLQ"
                                    }
                                }
                            ]
                        },
                        {
                            "multiple": true,
                            "typeClass": "compound",
                            "typeName": "producer",
                            "value": [
                                {
                                    "producerAffiliation": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "producerAffiliation",
                                        "value": "Fundaci\u00f3n Tropenbos Colombia"
                                    },
                                    "producerName": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "producerName",
                                        "value": "Fundaci\u00f3n Tropenbos Colombia"
                                    }
                                }
                            ]
                        },
                        {
                            "multiple": false,
                            "typeClass": "primitive",
                            "typeName": "productionDate",
                            "value": "2025-06-01"
                        },
                        {
                            "multiple": true,
                            "typeClass": "compound",
                            "typeName": "grantNumber",
                            "value": [
                                {
                                    "grantNumberAgency": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "grantNumberAgency",
                                        "value": "Banco Interamericano de Desarrollo"
                                    },
                                    "grantNumberValue": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "grantNumberValue",
                                        "value": "22-374"
                                    }
                                }
                            ]
                        },
                        {
                            "multiple": true,
                            "typeClass": "compound",
                            "typeName": "distributor",
                            "value": [
                                {
                                    "distributorAffiliation": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "distributorAffiliation",
                                        "value": "Fundaci\u00f3n Tropenbos Colombia"
                                    },
                                    "distributorName": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "distributorName",
                                        "value": "Laura Valentina Laverde Rojas"
                                    }
                                }
                            ]
                        },
                        {
                            "multiple": false,
                            "typeClass": "primitive",
                            "typeName": "depositor",
                            "value": "Laverde Rojas, Laura Valentina"
                        },
                        {
                            "multiple": false,
                            "typeClass": "primitive",
                            "typeName": "dateOfDeposit",
                            "value": "2025-12-03"
                        },
                        {
                            "multiple": true,
                            "typeClass": "compound",
                            "typeName": "dateOfCollection",
                            "value": [
                                {
                                    "dateOfCollectionEnd": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "dateOfCollectionEnd",
                                        "value": "2025-06-30"
                                    },
                                    "dateOfCollectionStart": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "dateOfCollectionStart",
                                        "value": "2025-05-01"
                                    }
                                }
                            ]
                        },
                        {
                            "multiple": true,
                            "typeClass": "primitive",
                            "typeName": "kindOfData",
                            "value": [
                                "Mapeo de actores"
                            ]
                        }
                    ],
                    "name": "citation"
                },
                "geospatial": {
                    "displayName": "Geospatial Metadata",
                    "fields": [
                        {
                            "multiple": true,
                            "typeClass": "compound",
                            "typeName": "geographicCoverage",
                            "value": [
                                {
                                    "country": {
                                        "multiple": false,
                                        "typeClass": "controlledVocabulary",
                                        "typeName": "country",
                                        "value": "Colombia"
                                    },
                                    "otherGeographicCoverage": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "otherGeographicCoverage",
                                        "value": "Solano"
                                    },
                                    "state": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "state",
                                        "value": "Caquet\u00e1"
                                    }
                                },
                                {
                                    "country": {
                                        "multiple": false,
                                        "typeClass": "controlledVocabulary",
                                        "typeName": "country",
                                        "value": "Colombia"
                                    },
                                    "otherGeographicCoverage": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "otherGeographicCoverage",
                                        "value": "La Monta\u00f1ita"
                                    },
                                    "state": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "state",
                                        "value": "Caquet\u00e1"
                                    }
                                },
                                {
                                    "country": {
                                        "multiple": false,
                                        "typeClass": "controlledVocabulary",
                                        "typeName": "country",
                                        "value": "Colombia"
                                    },
                                    "otherGeographicCoverage": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "otherGeographicCoverage",
                                        "value": "Puerto Rico"
                                    },
                                    "state": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "state",
                                        "value": "Caquet\u00e1"
                                    }
                                },
                                {
                                    "country": {
                                        "multiple": false,
                                        "typeClass": "controlledVocabulary",
                                        "typeName": "country",
                                        "value": "Colombia"
                                    },
                                    "otherGeographicCoverage": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "otherGeographicCoverage",
                                        "value": "Cartagena del Chair\u00e1"
                                    },
                                    "state": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "state",
                                        "value": "Caquet\u00e1"
                                    }
                                }
                            ]
                        },
                        {
                            "multiple": true,
                            "typeClass": "primitive",
                            "typeName": "geographicUnit",
                            "value": [
                                "Vereda",
                                "N\u00facleo comunal"
                            ]
                        },
                        {
                            "multiple": true,
                            "typeClass": "compound",
                            "typeName": "geographicBoundingBox",
                            "value": [
                                {
                                    "eastLongitude": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "eastLongitude",
                                        "value": "-71.01947"
                                    },
                                    "northLatitude": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "northLatitude",
                                        "value": "2.843651"
                                    },
                                    "southLatitude": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "southLatitude",
                                        "value": "-0.630770"
                                    },
                                    "westLongitude": {
                                        "multiple": false,
                                        "typeClass": "primitive",
                                        "typeName": "westLongitude",
                                        "value": "-75.492295"
                                    }
                                }
                            ]
                        }
                    ],
                    "name": "geospatial"
                },
                "socialscience": {
                    "displayName": "Social Science and Humanities Metadata",
                    "fields": [
                        {
                            "multiple": true,
                            "typeClass": "primitive",
                            "typeName": "unitOfAnalysis",
                            "value": [
                                "Para la construcci\u00f3n de la matriz de actores territoriales, la unidad de an\u00e1lisis corresponde a cada actor estrat\u00e9gico identificado en el territorio, entendido como cualquier instituci\u00f3n, organizaci\u00f3n social, asociaci\u00f3n campesina, instancia comunitaria, colectivo ambiental, comit\u00e9 o liderazgo local que participa o tiene incidencia en el proceso de Zonificaci\u00f3n Ambiental Participativa. Cada actor constituye un registro individual dentro de la matriz y es caracterizado seg\u00fan su rol, nivel de participaci\u00f3n, capacidades, intereses y relaci\u00f3n con la gesti\u00f3n ambiental del municipio."
                            ]
                        },
                        {
                            "multiple": true,
                            "typeClass": "primitive",
                            "typeName": "universe",
                            "value": [
                                "El universo est\u00e1 conformado por el conjunto total de actores presentes en los municipios, incluyendo entidades p\u00fablicas del orden local, departamental y nacional, organizaciones comunitarias y campesinas, juntas de acci\u00f3n comunal, comit\u00e9s y consejos municipales, instituciones educativas, colectivos sociales y ambientales, organismos de control y otros actores relevantes reconocidos por las comunidades. Este universo representa el mapa amplio de actores que influyen en la gobernanza territorial y que, por su presencia o competencias, pueden aportar, incidir o participar en los procesos de planificaci\u00f3n ambiental."
                            ]
                        },
                        {
                            "multiple": false,
                            "typeClass": "primitive",
                            "typeName": "dataCollector",
                            "value": "Fundaci\u00f3n Tropenbos Colombia"
                        },
                        {
                            "multiple": true,
                            "typeClass": "primitive",
                            "typeName": "collectionMode",
                            "value": [
                                "La metodolog\u00eda de recolecci\u00f3n se realizo mediante grupos focales en los talleres municipales y en entrevistas.\n\nDatos cualitativos de narrativas construidas a partir de entrevistas a lideres y lideresas comunitarias para cada municipio e informaci\u00f3n secundaria."
                            ]
                        },
                        {
                            "multiple": false,
                            "typeClass": "primitive",
                            "typeName": "researchInstrument",
                            "value": "Semiestructurado"
                        },
                        {
                            "multiple": false,
                            "typeClass": "primitive",
                            "typeName": "dataCollectionSituation",
                            "value": "Los instrumentos de recolecci\u00f3n utilizados en este proceso fueron el mapa de actores y la entrevista semiestructurada. El mapa de actores permiti\u00f3 identificar de manera participativa a los diferentes actores estrat\u00e9gicos del territorio, sus relaciones, capacidades, niveles de influencia y v\u00ednculos con el proceso de Zonificaci\u00f3n Ambiental Participativa. Este instrumento se desarroll\u00f3 en espacios colectivos, donde las comunidades y organizaciones contribuyeron a ubicar actores clave y describir sus roles dentro de la din\u00e1mica territorial.  Por su parte, la entrevista semiestructurada facilit\u00f3 un acercamiento m\u00e1s profundo a la percepci\u00f3n, experiencias y criterios de los actores respecto al manejo del territorio, los procesos organizativos, las tensiones socioambientales y las oportunidades de articulaci\u00f3n institucional y comunitaria. Este instrumento combin\u00f3 preguntas orientadoras con la posibilidad de explorar aspectos emergentes, permitiendo obtener informaci\u00f3n cualitativa detallada y contextualizada."
                        },
                        {
                            "multiple": false,
                            "typeClass": "primitive",
                            "typeName": "controlOperations",
                            "value": "Se realiz\u00f3 verificaci\u00f3n de la informaci\u00f3n con las comunidades y organizaciones campesinas, control de duplicados y revisi\u00f3n de coherencia entre causas, actores e impactos. Se validaron los lugares de incidencia y se ajustaron los registros antes de integrarlos a la matriz."
                        },
                        {
                            "multiple": false,
                            "typeClass": "primitive",
                            "typeName": "cleaningOperations",
                            "value": "Se realiz\u00f3 limpieza de datos mediante la eliminaci\u00f3n de duplicados, correcci\u00f3n de inconsistencias en nombres de veredas y actores, unificaci\u00f3n de categor\u00edas, normalizaci\u00f3n de fechas y verificaci\u00f3n de campos incompletos para garantizar la calidad del registro."
                        }
                    ],
                    "name": "socialscience"
                }
            },
            "productionDate": "2025-06-01",
            "publicationDate": "2025-12-12",
            "releaseTime": "2025-12-12T21:04:57Z",
            "specialPermissions": "Los datos asociados a este recurso que se encuentran disponibles para descarga directa han sido procesados con el fin de anonimizar datos sensibles o confidenciales que pueden poner en riesgo la seguridad de los actores involucrados. Para m\u00e1s informaci\u00f3n puede contactarse con los puntos de contacto registrados en el metadato o trav\u00e9s de los correos electr\u00f3nico i2d@humboldt.org.co (investigadores del I. Humboldt) y atencionalciudadano@humboldt.org.co (usuarios externos).",
            "storageIdentifier": "file://10.21068/CTQ20N",
            "termsOfAccess": "Los archivos restringidos contienen datos sensibles y/o confidenciales. Para m\u00e1s informaci\u00f3n puede contactarse con los puntos de contacto registrados en el metadato o trav\u00e9s de los correos electr\u00f3nico i2d@humboldt.org.co (investigadores del I. Humboldt) y atencionalciudadano@humboldt.org.co (usuarios externos).",
            "termsOfUse": "- Libre a nivel interno y externo",
            "versionMinorNumber": 0,
            "versionNumber": 1,
            "versionState": "RELEASED"
        },
        "id": 281,
        "identifier": "CTQ20N",
        "metadataLanguage": "es",
        "persistentUrl": "https://doi.org/10.21068/CTQ20N",
        "protocol": "doi",
        "publicationDate": "2025-12-12",
        "publisher": "Cat\u00e1logo de Datos Socioecol\u00f3gicos",
        "separator": "/",
        "storageIdentifier": "file://10.21068/CTQ20N"
    }
