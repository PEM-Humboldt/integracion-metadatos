
# Hallazgos y errores en BioCultural
Se han reportado algunos errores e inconsistencias en la instancia de Dataverse del Instituto (BioCultural). Para replicar los errores, se corrió una instancia dockerizada local de BioCultural siguiendo las indicaciones del [repositorio interno de Gitlab](http://192.168.11.78/pem/BioCultural/blob/master/dataverse-docker/README.md). A continuación, se desglosan los hallazgos, las razones detrás de los mismos y las soluciones propuestas. 
## Idiomas
BioCultural incluye un paquete de idioma, el cuál es cargado al proyecto en la línea 64 del archivo `dataverse-restore.sh`, encontrado en el [repositorio de GitLab](http://192.168.11.78/pem/BioCultural). Estos archivos son almacenados en la ruta `/home/dataverse/langBundles` del contenedor de dataverse, y pueden ser inspeccionados así:

`docker exec -it dataverse bash`
`cd /home/dataverse/langBundles`

En el repositorio original de [Dataverse](https://github.com/IQSS/dataverse), los archivos se encuentran en la ruta `/src/main/java/propertyFiles` y son 26 elementos, mientras que en el proyecto BioCultural se cuenta con sólo 11 archivos. El hecho de que no se tengan todos los archivos no es la causa directa de los problemas de traducciones, aunque sí hay algunas coincidencias, las cuales se describirán más adelante en la tabla de hallazgos. 

### Hallazgos

Para entender en dónde están los problemas de traducciones, el primer paso fue inspeccionar mi instancia local de BioCultural desde el navegador. Logueada como un usuario normal, no pude encontrar fragmentos en inglés o en otro idioma que me guiaran a cuál era el problema descrito. Al loguearme como administrador, inspeccioné las funciones para añadir un nuevo dataset y un nuevo dataverse, en dónde sí hallé traducciones inconclusas.

Dentro de la carpeta `langBundles` para encontrar estas traducciones fallidas. Los hallazgos fueron los siguientes:

| Ruta | Nombre del item | Archivo | Problema |
|--|--|--|--|
| Añadir Datos > Nuevo dataverse | Relation Type | citation_es.properties | No se tiene traducción |
| Añadir Datos > Nuevo dataverse | Tooltip de ‘Relation Type’ | citation_es.properties | No se tiene traducción |
| Añadir Datos > Nuevo Dataset (También en “Búsqueda Avanzada”) | Descripción de ‘Relation Type’ | citation_es.properties | No se tiene traducción |
| Añadir Datos > Nuevo Dataset (También en “Búsqueda Avanzada”) | Todos los ítems de ‘Relation Type’ | citation_es.properties | No se tiene traducción |
| Añadir Datos > Nuevo Dataverse | 3D Object Metadata | 3dobjects.properties | Archivo no existe (*Dataverse usa el archivo default) |
| Añadir Datos > Nuevo Dataverse | Todos los ítems de ‘3D Object Metadata’ | 3dobjects.properties | Archivo no existe (*Dataverse usa el archivo default) |
| Añadir Datos > Nuevo Dataverse | Navegar > Buscar facetas | 3dobjects.properties | Archivo no existe (*Dataverse usa el archivo default) |
| Añadir Datos > Nuevo Dataverse | Navegar > Buscar facetas: | 3dobjects.properties | Archivo no existe (*Dataverse usa el archivo default) |
| Añadir Datos > Nuevo Dataverse | Navegar > Buscar facetas: | 3dobjects.properties | Las llaves no existen |
| Editar Metadatos (En un dataset) -> Metadatos geoespaciales | Rectángulo envolvente geográfico | Geospatial.properties | Los nombres de las llaves están truncados (nombrados como Latitude y deben ser Longitude) |
| Menú de búsqueda de la página principal | Campos de búsqueda estáticos | StaticSearchFields.properties | Archivo no existe (*Dataverse usa el archivo default) |

Adicionalmente, en el archivo biomedical.properties (que como menciono en la tabla, tiene algunas llaves faltantes), reconocí las siguientes llaves duplicadas:

- `datasetfieldtype.studyAssayOtherOrganism.description`
- `datasetfieldtype.studyAssayMeasurementType.description`

- `datasetfieldtype.studyAssayOtherMeasurmentType.description`

- `datasetfieldtype.studyAssayTechnologyType.description`

- `datasetfieldtype.studyAssayPlatform.description`

- `datasetfieldtype.studyAssayCellType.description`

  
Además, existen algunas llaves con descripción pero no tiene su correspondiente título:

- `studyAssayOtherPlatform`

- `studyAssayOtherTechnologyType`

(Sin embargo estos metadatos no parecen estar siendo usados, y por lo tanto, tenerlos incompletos es irrelevante.)

Adicionalmente, hay muchas más llaves que no están traducidas, pero no logré encontrarlas desde el navegador, por lo que puede ser que simplemente no se haga uso de ellas y su traducción no haga falta.

Por otro lado, toda la homepage está en inglés, sin embargo, esto ya no tiene que ver con las traducciones sino con el archivo `html` usado como `homepage`, el cuál es un tema que se tocará en una sección siguiente.

### Soluciones propuestas
Para solucionar los problemas de las traducciones, realicé pruebas con dos métodos diferentes:

**Solución #1:** Editar los archivos `.properties` desde dentro del contenedor

1. Ingresar al contenedor de dataverse
2. Ingresar a la ruta `/home/dataverse/langBundles`
3. Ingresar al archivo que se desee modificar. Guardar y salir.
4. Salir del contenedor y reiniciar.

Esta solución es rápida y directa, sin embargo para buscar líneas específicas rápidamente o para tener mayor control sobre la edición de los archivos, se propone la solución dos.

**Solución #2:** Editar los archivos desde un IDE en la máquina host y copiarlos de regreso al contenedor.

1. Copiar el `.properties` del contenedor al host:
	`docker cp dataverse:/home/dataverse/langBundles/file_es.properties <ruta_host>`
2. Editar el `.properties` y guardar los cambio.s
3. Copiar de regreso al contenedor:
	`docker cp <ruta_host>/file_es.properties dataverse:/home/dataverse/langBundles`
4. Reiniciar el contenedor.

Otro tema que es importante destacar, es que al momento de crear un dataverso, el administrador puede decidir el idioma con el que se espera que se carguen los metadatos. Los usuarios que posteriormente creen otros dataversos o datasets dentro de este, deben seguir este lineamiento, pues la aplicación de Dataverse no puede validar el idioma del metadato antes de guardarlo. La importancia de seguir este lineamiento, reside en principalmente mantener la consistencia, ya que Dataverse no traduciría automáticamente estos atributos, si es que así equivocadamente se cree. Aunque no encontré un ejemplo específico de este caso, podría ser un factor a evaluar en caso de hallar más traducciones fallidas.

## Personalización de homepage
### Funcionamiento
Dataverse permite la personalización del homepage a partir de un HTML, que puede ser modificado. Este archivo es cargado en la restauración de BioCultural (archivo `dataverse-restore.sh`, línea 66, encontrado en el [repositorio interno de Gitlab](http://192.168.11.78/pem/BioCultural/blob/master/dataverse-docker/README.md)) y es almacenado por defecto dentro del contenedor de Dataverse en la ruta `/var/www/dataverse/branding.`

En esta ruta, se tienen los 3 archivos bases que da Dataverse:

- `custom-homepage-basic.html`
- `custom-homepage-dynamic.html`
- `harvard-dataverse-homepage-html`

Pudiendo ser descargadas directamente así:
**Plantilla estática**

`sudo wget https://guides.dataverse.org/en/latest/_downloads/0f28d7fe1a9937d9ef47ae3f8b51403e/custom-homepage.html -P /var/www/dataverse/branding/`

**Plantilla dinámica**

`sudo wget https://guides.dataverse.org/en/latest/_downloads/2268ac78e48fc4abe8db59caf7427827/custom-homepage-dynamic.html -P /var/www/dataverse/branding/`

Sin embargo, dataverse renderiza el HTML que se haya especificado en la base de datos, lo cual se puede validar haciendo un query desde el contenedor de postgres:

`SELECT * FROM setting WHERE name = ‘:HomePageCustomizationPage’`

Que para BioCultural se obtiene la plantilla `custom-homepage-dynamic.html`, la cuál permite una personalización más completa a diferencia de la plantilla estática. Si se deseara cambiar la plantilla referenciada, puede hacerse con el siguiente comando:

`sudo wget https://guides.dataverse.org/en/latest/_downloads/0f28d7fe1a9937d9ef47ae3f8b51403e/custom-homepage.html -P /var/www/dataverse/branding/`

O bien, se puede también usar como base el homepage del repositorio del github de Harvard (https://github.com/IQSS/dataverse.harvard.edu).

## Personalización 

Un administrador podría modificar el archivo que llama la base de datos, y por lo tanto, alterar la homepage. Sin embargo, para personalizarla o modificarla, se debe editar directamente el `.html`  ingresando a la ruta `/var/www/dataverse/branding`, modificando el archivo y guardando los cambios; o desde un IDE, copiando el archivo al host y luego de regreso al contenedor siguiendo los comandos descritos en la sección anterior.

También es posible desarrollar el `homepage` desde un nuevo archivo, pero se debe modificar el valor de la tabla `setting` del Postgres para que apunte a este nuevo HTML.

Es posible realizar una personalización completa del homepage de Dataverse:

-   Personalización de nombre de la organización
-   Personalización del header
-   Personalización de footer
-   Configuración del CSS

Es decir, que no sólo es posible personalizar el contenido, sino que se puede agregar un header y un footer personalizable, que se presentará junto al header y footer propio de dataverse. Adicionalmente, es posible agregar e instalar un stylesheet propio.

#### Secciones personalizables

#### API de métricas
[Documentación]([https://guides.dataverse.org/en/6.6/api/metrics.html](https://guides.dataverse.org/en/6.6/api/metrics.html)).

Las plantillas del homepage pueden hacer llamados a la API de métricas `/api/info/metrics`, responsables de los conteos mostrados (e.g. 49 datasets, 637 downloads). En caso de que se quiera crear un HTML nuevo o modificar los conteos mostrados, se debe tener en cuenta la estructura HTML/JavaScript del archivo que permite esta comunicación.


##### Registros
La API cuenta con endpoints para acceder al número de datasets, dataversos y descargas, de registros históricos, desde un mes en específico o en los últimos X días. Por ejemplo:

 Nota: `$type` podrá ser cualquiera de: dataverses, datasets, files, downloads o accounts

1.  Histórico de datasets
    `curl https://$SERVER/api/info/metrics/$type`
    
	Por ejemplo:
	`curl http://192.168.11.48/api/info/metrics/datasets` 

2.  Histórico de descargas
    `curl https://$SERVER/api/info/metrics/$type`
    
	Por ejemplo:
	`curl http://192.168.11.48/api/info/metrics/downloads`
  

3.  Archivos disponibles hasta una fecha específica
	`curl https://$SERVER/api/info/metrics/$type/toMonth/$YYYY-DD`

	Por ejemplo:
	`curl http://192.168.11.48/api/info/metrics/files/toMonth/2025-10`

4.  Conteo de objetos en los últimos X días
    `curl https://$SERVER/api/info/metrics/$type/pastDays/$days`

	Por ejemplo: El número de datasets en los últimos 30 días
	`curl http://192.168.11.48/api/info/metrics/datasets/pastDays/30`

Existen más métricas, se pueden verificar aquí: [https://guides.dataverse.org/en/6.6/api/metrics.html](https://guides.dataverse.org/en/6.6/api/metrics.html)

Las métricas pueden ser retornadas en formato JSON o el formato CSV:
- Para JSON:
	
	`curl -H 'Accept:text/csv' https://demo.dataverse.org/api/info/metrics/downloads/monthly`

- Para CSV (Formato por defecto):
`curl https://demo.dataverse.org/api/info/metrics/downloads/monthly`

##### Filtrados
La API cuenta con endpoints para filtrar y buscar información.
1.  Definir de qué colección se debe recolectar la métrica:
    `curl http://192.168.11.48/api/info/metrics/datasets/?parentAlias=iavh_i2d`

2.  Se especifica si se debe buscar información local, remota o ambas:
	`curl http://192.168.11.48/api/info/metrics/datasets/?dataLocation=local`
	`curl http://192.168.11.48/api/info/metrics/datasets/?dataLocation=remote`

3.  Según lo que se desee filtrar, hay diferentes endpoint, los cuales están listados [aquí.](https://guides.dataverse.org/en/6.6/api/metrics.html)

4. Para la visualización de descargas de archivos [Getting File Download Count](https://guides.dataverse.org/en/6.6/api/native-api.html#file-download-count)

Por ejemplo, tomando la instancia de Dataverse de la [U. del Rosario](https://research-data.urosario.edu.co/), se podrían aplicar endpoints como los siguientes:
 - Para retornar el conteo de dataversos y datasets que son de la categoría de Ingeniería:
 `curl -s "http://localhost:8080/api/search?q=*&fq=subject_ss:Engineering&per_page=1"`
 
- Para retornar sólo el conteo de datasets de la categoría de Ingeniería:
`curl -s "http://localhost:8080/api/search?q=*&type=dataset&fq=subject_ss:Engineering"`

- Lo siguiente retornaría los resultados anteriores como un HTML:
`curl "http://localhost:8080/dataverse/iavh_i2d?q=&fq0=subject_ss%3A"Engineering"&types=datasets"`

# Estructura de datos
Las funciones de crear, editar o eliminar dataversos y datasets, son posibles según los permisos otorgados a cada usuario. Estos permisos se pueden definir según el rol de cada usuario o grupos de usuarios:

-   Un usuario con permisos puede crear una nueva colección o dataverse, así mismo puede editar estas colecciones, personalizar los metadatos o agregar plantillas para proveer instrucciones personalizadas a los demás usuarios. También puede eliminar el dataverse, siempre y cuando no esté publicado y no tenga datasets en borrador. Todo esto se puede hacer directamente desde la UI, pero si se quisiera agregar metadatos totalmente nuevos, que no estén en disponibilidad desde la UI, se tendría que hacer internamente.
    
-   Cualquier usuario con permisos puede agregar un dataset a un dataverse, así como puedo agregar, editar o eliminar archivos del dataset, restringir accesos o editar/eliminar metadata. Para la carga de archivos, cada dataverse puede ofrecer múltiples métodos según la configuración dada por un administrador, por lo que cada usuario, según su rol, puede tener diferentes alcances en la personalización de datasets.

Para entender mejor la estructura de permisos en BioCultural, ingresé al contenedor de dataverse, y dentro verifiqué el endpoint `/api/admin/roles`

`docker exec -it dataverse bash`
`curl http://localhost:8080/api/admin/roles`

Con esto, es fácil identificar los permisos de cada usuario:

Nombre | Permisos | Descripción | Id  
--- | --- | --- | ---
Administrador | AddDataverse, AddDataset, ViewUnpublishedDataverse, ViewUnpublishedDataset, DownloadFile, EditDataverse, EditDataset, ManageDataversePermissions, ManageDatasetPermissions, ManageFilePermissions, PublishDataverse, PublishDataset, DeleteDataverse, DeleteDatasetDraft | Persona que tiene todos los permisos para dataverses, datasets y ficheros, incluyendo aprobar peticiones para datos restringidos | 1
FileDownloader | DownloadFile | Descargador de ficheros | 2
Creador de Dataverses + Datasets | AddDataverse, AddDataset | Persona que puede añadir subdataverses y datasets dentro de un dataverse. | 3
Creador de dataverses | AddDataverse | Persona que puede añadir subdataverses dentro de un dataverse. | 4
Creador de datasets | AddDataset | Persona que puede añadir datasets a un dataverse. | 5
Colaborador | ViewUnpublishedDataset, DownloadFile, EditDataset, DeleteDatasetDraft  | Para los datasets, persona que puede editar las licencias, los condiciones de uso y enviarlos para su revisión. | 6
Conservador/Revisor | AddDataverse, AddDataset, ViewUnpublishedDataverse, ViewUnpublishedDataset, DownloadFile, EditDataset, ManageDatasetPermissions, ManageFilePermissions, PublishDataset, DeleteDatasetDraft | Para los datasets, una persona que puede editar licencias, condiciones de uso, editar permisos y publicar los datasets | 7
Miembro | ViewUnpublishedDataverse, ViewUnpublishedDataset, DownloadFile | Persona que puede ver dataverses y datasets sin publicar. | 8