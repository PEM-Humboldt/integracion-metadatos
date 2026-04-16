
# Traducciones
Dataverse permite incluir un paquete de idiomas para la traducción de la instancia a partir de i18n de Java. 
## Configuración
Los archivos que contienen las traducciones deben ser almacenados, dentro del contenedor de Dataverse, en la ruta:
`/home/dataverse/langBundles/`

Los archivos de traducciones deben ser nombrados con el mismo nombre del bloque de metadatos (`name`) sobre el que ejecutará las traducciones y han de ser de extensión `properties`. Cada uno de estos archivos está compuesto por múltiples `message keys`, que son usados en Java i18n para construir el proyecto con el idioma deseado, en este caso, español (por esto, el nombre de los archivos contienen el sufijo `_es`). Cada bloque de metadatos debe tener su correspondiente archivo `.properties`. 

**Por ejemplo:**
Tomamos el TSV de un bloque de metadatos cualquiera:
`institutional.tsv`: 
`#metadataBlock	name	dataverseAlias	displayName <br \>
		institutional	iavh_i2d	Institutional`
		
El archivo de traducciones correspondiente debe ser llamado `institutional_es.properties`

Si un archivo de traducción es creado o editado, una vez en la ruta correspondiente del contenedor, se debe reiniciar el contenedor para que tome los cambios:

`docker restart dataverse`

## Estructura
El archivo de traducciones define traducciones tanto para los atributos del bloque de metadatos, como para sus metadatos y sus vocabularios controlados. Las traducciones deben ser escritas en Unicode. 

- Para el bloque de metadatos, se traducen los siguientes atributos:
	- Nombre (`name`)
	- Título (`displayName`)
	- Nombre para las búsquedas (`displayFacet`)
La estructura a seguir es:
`metadatablock.[campo_a_traducir]=[traducción]`

- Para cada campo, se traducen los siguientes atributos:
	- Título (`title`)
	- Descripción (`description`)
	- Marca de agua o placeholder (`watermark`)
La estructura a seguir es:
`datasetfieldtype.[nombre_atributo].[campo_a_traducir]=[traducción]`

- Para los vocabularios controlados, se traduce el campo:
	- Valor (`value`)
La estructura a seguir es:
`controlledvocabulary.[nombre_atributo].[value]=[traduccion]`

		La forma correcta de generar una traducción sobre un vocabulario controlado es, como indica la estructura, asignándola a su campo `value`, no a `identifier`. Adicionalmente, el value siempre debe escribirse en minúsculas, independientemente de si el valor del TSV contiene mayúsculas. 

		> Un archivo TSV con el siguiente vocabulario controlado:
		> 			`#controlledVocabulary DatasetField Value identifier displayOrder
		> iavhTypeOfInstitution Public Institution iavh_type_inst_public 0` 
		> 
		> 	Usa un .properties como el siguiente:
		> 		`controlledvocabulary.iavhTypeOfInstitution.public_institution=Opci\u00f3n
		> n\u00famero uno`


De manera general, cada metadato puede tener traducciones para los tres atributos, para algunos o para ninguno. Si no se desea una traducción, simplemente se debe omitir la línea en el archivo, ya que dejarla en blanco provoca que en la interfaz aparezca también en blanco. 

    metadatablock.name=Institucional
    metadatablock.displayName=Institucional
    metadatablock.displayFacet=Institucional
    datasetfieldtype.iavhInstitutionName.title=Nombre de la instituci\u00f3n
    datasetfieldtype.iavhInstitutionID.title=Identificador de la instituci\u00f3n
    datasetfieldtype.iavhTypeOfInstitution.title=Tipo de instituci\u00f3n
    datasetfieldtype.iavhInstitutionName.description=El nombre que identifica a la instituci\u00f3n
    datasetfieldtype.iavhInstitutionID.description=La instituci\u00f3n debe contar con un identificador \u00fanico
    datasetfieldtype.iavhTypeOfInstitution.description=Defina si la instituci\u00f3n es una instituci\u00f3n privada o p\u00fablica
    datasetfieldtype.iavhTypeOfInstitution.watermark=Tipo privado o p\u00fablico
    controlledvocabulary.iavhTypeOfInstitution.[public_institution]=Instituci\u00f3n p\u00fablica
    controlledvocabulary.iavhTypeOfInstitution.[private_institution]=Instituci\u00f3n privada
