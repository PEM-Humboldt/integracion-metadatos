
# Metadatos externos

Tomado de [este repositorio](https://github.com/gdcc/dataverse-external-vocab-support)

  

Dataverse soporta vocabularios y PIDs (persistent identifiers) de terceros a través de sus configuraciones y scripts específicos que manejan el cómo estos datos externos se asocian con los bloques de metadatos en Dataverse. De esta manera, es posible modificar cajas de texto plano por selectores de vocabularios específicos, los cuáles pueden ser definidos previamente o venir de un llamado a alguna API externa.

  

## Consideraciones

Según el repositorio, sólo existe soporte a partir de la versión 6.8 de Dataverse, por lo que para versiones menores podrían verse afectadas por errores inesperados.

  

## Implementación

Para lograr la implementación de este sistema, se desglosan los siguientes cuatro pasos a seguir:

1.  **Identificación del campo a mejorar**: Estos pueden venir de bloques propios o bloques ya existentes, por lo que permite una flexibilización mucho mayor sobre las reglas básicas de Dataverse, lo cuál se puede leer [en esta sección](./custom_metadata.md)

2.  **Crear un archivo de configuración y cargarlo a la configuración de Dataverse**: Es posible hacer uso de los scripts dados en [la documentación](https://github.com/gdcc/dataverse-external-vocab-support/tree/main/scripts) y modificarlos a necesidad:

- Cambiar el nombre del campo que se va a mejorar

- El script que modificará el campo

- La URL que apunta a dicho script

	Se pueden usar los [archivos de ejemplo](https://github.com/gdcc/dataverse-external-vocab-support/tree/main/examples/config/demos) para evitar errores de estructura.

  

3.  **Desplegar el o los scripts**: Según la URL que se haya establecido para apuntar al script de configuración, se debe desplegar el script allí para que sea accesible desde Dataverse. Puede ser desplegado desde un Github.io, la misma documentación **no** recomienda usar los scripts del repositorio, ya que no están siendo versionados y podrían ser modificados en el futuro.

4.  **Actualizar el esquema de Solr**: Si bien este paso puede omitirse, es requerido si se llegase a usar un script sobre algún campo que usualmente es de único valor pero haya pasado a ser multi-valor. Para actualizarlo, se puede verificar en [esta sección](./custom_metadata.md)

  

Si se desean modificar múltiples campos, es necesario agregar una sección (JSON) por cada par de campo/script en el archivo de configuración.

  

### BioCultural

BioCultural es una instancia de la versión 6.6 de Dataverse, por lo que, teóricamente, no se tendría soporte para implementar estos scripts. Sin embargo, fue posible lograr la implementación de los scripts para hacer uso de la API de ORCID y ROR para los campos `autor` y `afiliaciòn` a partir de los siguientes pasos:

1. Fue necesario descargar el archivo de configuración actual del repositorio [`authorsOrcidAndRor.json`](https://github.com/gdcc/dataverse-external-vocab-support/blob/main/examples/config/authorsOrcidAndRor.json), el cuál está hecho para conectarse a la versión 2 de la API de ROR y la versión 3.0 de la API de ORCID.

2. En la documentación, especifican los siguientes puntos para versiones de Dataverse menores a la 6.8:

```

The ROR configuration/script now use ROR's v2 API and require Dataverse 6.9+ for full functionality. For installations on earlier versions, the ROR organization name will not be added to the DataCite XML metadata. Installations on <= Dataverse v6.8 should not upgrade their CVocConf configuration (keeping the retrieval-url pointed to ROR's v1 API, avoiding fatal errors from Dataverse <=6.8 trying to parse a v2 response).

```

  

En un commit anterior, se encontró también el siguiente comentario: `Installations on <= Dataverse v6.8 [...] should delete the contents of the "retrieval-filtering" object (e.g. set "retrieval-filtering": {} ).`

Por lo que estos cambios fueron llevados a cabo en el script original:

    - Se modificó la versión 2 de ROR por la 1: `"retrieval-uri": "https://api.ror.org/v1/organizations/{0}",`

    - Se dejó vació el campo `retrieval-filtering`: `"retrieval-filtering": {}` (aunque durante las pruebas se evidenció que funcionaba incluso dejando el contenido original)

    - Aunque la documentación no lo menciona, para lograr que la selección de autores a través de ORCID funcione correctamente, es necesario también usar una versión anterior de la API de ORCID, cambiando la actual (3.0) por una anterior (2.1): `"retrieval-uri": "https://pub.orcid.org/v2.1/{0}/person",`

Puede ver el archivo de configuración final [aquí](./scripts/authorsOrcidAndRor.json). 

**Importante:** Los Logs de payara me retornaron el siguiente warning importante: `Received response code : 410 when retrieving https://api.ror.org/v1/organizations/026dk4f10 : {"errors":[{"status":"410","title":"API Version Deprecated","detail":"The v1 API has been deprecated. Please migrate to v2.","deprecated_at":"2025-12-09"}]}|#]` lo cuál corresponde con lo documentado en el repositorio.

  

3. Se cargó el archivo al contenedor de dataverse, copiandolo del host al contenedor con (previamente se creó la carpeta destino):

`docker cp authorsOrcidAndRor.json dataverse:/usr/local/dvinstall/data/external_metadata`

4. Se cargó el archivo a la tabla `setting` de postgres, vinculándolo a la configuración `:CVocConf`:

`curl -X PUT --upload-file authorsOrcidAndRor.json http://localhost:8080/api/admin/settings/:CVocConf`

5. Se realizó la reindexación a Solr para evitar posibles errores.
