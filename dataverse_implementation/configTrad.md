# Manejo de archivos de configuración y traducción en Dataverse
Marius Bottin

## Leer los archivos de configuración anteriores

### Prueba de script con el bloque de metadatos “citation”

Notar: `stringi` contiene funciones que permiten trabajar con los
codigos de caracteres unicode:

``` r
raw<-readLines("../../langBundles/citation_es.properties")
head(raw)
```

    [1] "metadatablock.name=cita"                                         
    [2] "metadatablock.displayName=Metadatos de cita"                     
    [3] "metadatablock.displayFacet=Cita"                                 
    [4] "datasetfieldtype.title.title=T\\u00edtulo"                       
    [5] "datasetfieldtype.subtitle.title=Subt\\u00edtulo"                 
    [6] "datasetfieldtype.alternativeTitle.title=T\\u00edtulo alternativo"

``` r
decode<-stringi::stri_unescape_unicode(raw)
head(decode)
```

    [1] "metadatablock.name=cita"                                   
    [2] "metadatablock.displayName=Metadatos de cita"               
    [3] "metadatablock.displayFacet=Cita"                           
    [4] "datasetfieldtype.title.title=Título"                       
    [5] "datasetfieldtype.subtitle.title=Subtítulo"                 
    [6] "datasetfieldtype.alternativeTitle.title=Título alternativo"

``` r
reEncode<-stringi::stri_escape_unicode(decode)
head(reEncode)
```

    [1] "metadatablock.name=cita"                                         
    [2] "metadatablock.displayName=Metadatos de cita"                     
    [3] "metadatablock.displayFacet=Cita"                                 
    [4] "datasetfieldtype.title.title=T\\u00edtulo"                       
    [5] "datasetfieldtype.subtitle.title=Subt\\u00edtulo"                 
    [6] "datasetfieldtype.alternativeTitle.title=T\\u00edtulo alternativo"

Ahora tratamos de separar la información contenida en el archivo bruto:

``` r
raw<-raw[raw!=""]
splittedValues<-strsplit(raw,"=")
sepSVfield<-lapply(splittedValues,function(x)strsplit(x[1],"\\.")[[1]])
part<-sapply(sepSVfield,function(x)x[1])
var<-sapply(sepSVfield,function(x)x[length(x)])
value<-rep(NA,length(part))
value[part=="controlledvocabulary"]<-var[part=="controlledvocabulary"]
var[part=="controlledvocabulary"]<-NA
field<-sapply(sepSVfield,function(x) if(length(x)==3){x[2]}else{NA})
allTranslations<-data.frame(part=part, field=field, var=var, value=value, translation=sapply(splittedValues,function(x)if(length(x)==2){stringi::stri_unescape_unicode(x[2])}else{NA}))

translation_fields<-allTranslations[allTranslations$part=="datasetfieldtype",]
res<-matrix(nrow=sum(!duplicated(translation_fields$field)),ncol=3,dimnames=list(unique(translation_fields$field),c("title","watermark","description")))
addresses<-cbind(row=match(translation_fields$field,rownames(res)),col=match(translation_fields$var,colnames(res)))
res[addresses]<-translation_fields$translation
```

### Pasar a funciones

``` r
read_translation<-function(file_translation)
{
  raw<-readLines(file_translation)
  raw<-raw[raw!=""]
  splittedValues<-strsplit(raw,"=")
  sepSVfield<-lapply(splittedValues,function(x)strsplit(x[1],"\\.")[[1]])
  part<-sapply(sepSVfield,function(x)x[1])
  var<-sapply(sepSVfield,function(x)x[length(x)])
  value<-rep(NA,length(part))
  value[part=="controlledvocabulary"]<-var[part=="controlledvocabulary"]
  var[part=="controlledvocabulary"]<-NA
  field<-sapply(sepSVfield,function(x) if(length(x)==3){x[2]}else{NA})
  allTranslations<-data.frame(part=part, field=field, var=var, value=value,
      translation=sapply(splittedValues,function(x)if(length(x)==2){stringi::stri_unescape_unicode(x[2])}else{NA})
      )
  return(allTranslations)
}
extractFieldTranslations<-function(allTranslations)
{
  fieldPart<-allTranslations[allTranslations$part=="datasetfieldtype",]
  res<-matrix(nrow=sum(!duplicated(fieldPart$field)),ncol=3,dimnames=list(unique(fieldPart$field),c("title","watermark","description")))
  addresses<-cbind(row=match(fieldPart$field,rownames(res)),col=match(fieldPart$var,colnames(res)))
  res[addresses]<-fieldPart$translation
  return(res)
}
extractContVocaTranslations<-function(allTranslations)
{
  contVocaPart <- allTranslations[allTranslations$part == "controlledvocabulary",]
  res <- contVocaPart[, c("field" , "value" , "translation")]
  if(all(!duplicated(res$value)))
  {rownames(res) <- res$value}
  return(res)
}
```

### Aplicar a otros bloques

``` r
fields_socio<-extractFieldTranslations(read_translation("../../langBundles/socialscience_es.properties"))
fields_geospatial<-extractFieldTranslations(read_translation("../../langBundles/geospatial_es.properties"))
contVoca_socio <- extractContVocaTranslations(read_translation("../../langBundles/socialscience_es.properties"))
contVoca_geospatial <- extractContVocaTranslations(read_translation("../../langBundles/geospatial_es.properties"))
contVoca_citation <- extractContVocaTranslations(read_translation("../../langBundles/citation_es.properties"))
```

## Leer las tablas de configuaración en curso

He intentado rapidamente acceder a los archivos desde la API de google
pero parece que no está habilitada… Por ahora vamos a pasar por una
descarga en formato excel…

``` r
require(openxlsx)
```

    Loading required package: openxlsx

``` r
#wb<-loadWorkbook("../../data_metadatos_catalogos/Revisión de metadatos - Calidad - Capa Integración.xlsx")
wb<-"../../data_metadatos_catalogos/Revisión de metadatos - Calidad - Capa Integración.xlsx"
sn<-getSheetNames("../../data_metadatos_catalogos/Revisión de metadatos - Calidad - Capa Integración.xlsx")
rawCitation<-read.xlsx(wb,sheet="dvmetadatablock_citation",colNames=F)
blockPartStart<-which(rawCitation[,1]=="#metadataBlock")
fieldPartStart<-which(rawCitation[,1]=="#datasetField")
cvPartStart<-which(rawCitation[,1]=="#controlledVocabulary")
blockPartEnd<-fieldPartStart-1
fieldPartEnd<-if(length(cvPartStart)==1){cvPartStart-1}else{nrow(rawCitation)}
cvPartEnd<-nrow(rawCitation)
blockNcol<-max(which(!is.na(rawCitation[blockPartStart,])))
fieldNcol<-max(which(!is.na(rawCitation[fieldPartStart,])))
cvNcol<-max(which(!is.na(rawCitation[cvPartStart,])))
fieldPart<-read.xlsx(wb,sheet="dvmetadatablock_citation",rows=fieldPartStart:fieldPartEnd,cols=2:fieldNcol)
```

### Automatizar con funciones

``` r
read_configXl<-function(wkbook_config,sheet)
{
  rawConfig<-openxlsx::read.xlsx(wkbook_config,sheet=sheet,colNames=F)
  blockPartStart<-which(rawConfig[,1]=="#metadataBlock")
  fieldPartStart<-which(rawConfig[,1]=="#datasetField")
  cvPartStart<-which(rawConfig[,1]=="#controlledVocabulary")
  stopifnot(length(blockPartStart)==1)
  stopifnot(length(fieldPartStart)==1)
  hasContrVoc<-length(cvPartStart)==1
  blockPartEnd<-fieldPartStart-1
  fieldPartEnd<-if(hasContrVoc){cvPartStart-1}else{nrow(rawConfig)}
  blockNcol<-max(which(!is.na(rawConfig[blockPartStart,])))
  fieldNcol<-max(which(!is.na(rawConfig[fieldPartStart,])))
  blockPart<-openxlsx::read.xlsx(wkbook_config,sheet=sheet,rows=blockPartStart:blockPartEnd,cols=2:blockNcol)
  fieldPart<-openxlsx::read.xlsx(wkbook_config,sheet=sheet,rows=fieldPartStart:fieldPartEnd,cols=2:fieldNcol)
  res<-list(block=blockPart, field=fieldPart)
  if(hasContrVoc)
  {
    cvPartEnd<-nrow(rawConfig)
    cvNcol<-max(which(!is.na(rawConfig[cvPartStart,])))
    CVPart<-openxlsx::read.xlsx(wkbook_config,sheet=sheet,rows=cvPartStart:cvPartEnd,cols=2:cvNcol)
    res$contrVoc<-CVPart
  }
  return(res)
}
```

Now we just need to do:

``` r
citation_config <- read_configXl("../../data_metadatos_catalogos/Revisión de metadatos - Calidad - Capa Integración.xlsx", sheet = "dvmetadatablock_citation")
socio_config <- read_configXl("../../data_metadatos_catalogos/Revisión de metadatos - Calidad - Capa Integración.xlsx", sheet = "dvmetadatablock_social_science")
geospatial_config <- read_configXl("../../data_metadatos_catalogos/Revisión de metadatos - Calidad - Capa Integración.xlsx", sheet = "dvmetadatablock_geospatial")
```

## Exportación traducciones en curso (tables)

``` r
write.csv(res[fieldPart$name,],file="../../data_metadatos_catalogos/translationsFieldsCitation.csv")
write.csv(fields_socio[socio_config$field$name,],file="../../data_metadatos_catalogos/translationsFieldsSocio.csv")
write.csv(fields_geospatial[match(geospatial_config$field$name,rownames(fields_geospatial)),],file="../../data_metadatos_catalogos/translationsFieldsgeospatial.csv")
```

``` r
matchContVoca_translation_config <- function(contVoca, config)
{
  contVoca_mat<-as.matrix(cbind(contVoca$field,gsub("_"," ",contVoca$value)))
  config_mat<-as.matrix(cbind(config$contrVoc$DatasetField,tolower(config$contrVoc$Value)))
  match(split(config_mat,row(config_mat)), split(contVoca_mat,row(contVoca_mat)))
}
```

``` r
write.csv(contVoca_citation[matchContVoca_translation_config(contVoca_citation,citation_config),],file="../../data_metadatos_catalogos/translationVocabCont_citation.csv")
write.csv(contVoca_geospatial[matchContVoca_translation_config(contVoca_geospatial,geospatial_config),],file="../../data_metadatos_catalogos/translationVocabCont_geospatial.csv")
```

## En curso…

``` r
allConfigs<-lapply(sn[grep("^dvmetadatablock",sn)],FUN=function(sheet,wkbook_config){read_configXl(wkbook_config=wkbook_config,sheet)},wkbook_config=wb)
(names(allConfigs)<-sn[grep("^dvmetadatablock",sn)])
```

    [1] "dvmetadatablock_citation"        "dvmetadatablock_geospatial"     
    [3] "dvmetadatablock_institutional"   "dvmetadatablock_externalReferen"
    [5] "dvmetadatablock_geographic"      "dvmetadatablock_eml"            
    [7] "dvmetadatablock_social_science" 

Averiguar que las columnas de cada parte de los archivos de
configuración corresponden con lo esperado:

``` r
validaciones_fields<-list()
validaciones_fields$metadatablock<-list(base=c("name","dataverseAlias","displayName","blockURI"), traducción = c("traducción_displayName","traducción_name","traducción_facetName"), other=NULL)
validaciones_fields$fields<-list(base=c("name", "title", "description", "watermark", "fieldType", "displayOrder", "displayFormat", "advancedSearchField", "allowControlledVocabulary", "allowmultiples", "facetable", "displayoncreate", "required", "parent", "metadatablock_id", "termURI"),traducción=c("traducción_title","traducción_description","traducción_watermark"),other="Visible")
validaciones_fields$controlledVocabulary<-list(base=c("DatasetField","Value","identifier","displayOrder"),traducción="traducción_Value",other=NULL)

A<-lapply(validaciones_fields,unlist)

for(i in names(allConfigs))
{
extra<-setdiff(colnames(allConfigs[[i]]$block),unlist(validaciones_fields$metadatablock))
lack<-setdiff(unlist(validaciones_fields$metadatablock),colnames(allConfigs[[i]]$block))
if(length(extra)>0)
  {
    warning("En la descripción general del bloque \"", i, "\" esas variables no están reconocidas:\n",paste(extra,collapse="\n"))
}
if(length(lack))
{
  warning("En la descripción general del bloque \"", i, "\" esas variables no se encuentran:\n",paste(lack,collapse="\n"))
}

extra<-setdiff(colnames(allConfigs[[i]]$field),unlist(validaciones_fields$fields))
lack<-setdiff(unlist(validaciones_fields$fields),colnames(allConfigs[[i]]$field))
if(length(extra)>0)
  {
    warning("En la descripción de las variables del bloque \"", i, "\" esas variables no están reconocidas:\n",paste(extra,collapse="\n"))
}
if(length(lack))
{
  warning("En la descripción de las variables del bloque \"", i, "\" esas variables no se encuentran:\n",paste(lack,collapse="\n"))
}
extra<-setdiff(colnames(allConfigs[[i]]$contrVoc),unlist(validaciones_fields$controlledVocabulary))
lack<-setdiff(unlist(validaciones_fields$controlledVocabulary),colnames(allConfigs[[i]]$contrVoc))
if(length(extra)>0)
  {
    warning("En la descripción del vocabulario controlado del bloque \"", i, "\" esas variables no están reconocidas:\n",paste(extra,collapse="\n"))
}
if(length(lack))
{
  warning("En la descripción general del vocabulario controlado \"", i, "\" esas variables no se encuentran:\n",paste(lack,collapse="\n"))
}
}
```

- averiguar que los nombres de bloques correspondan en todo el archivo
  - en la descripción de las variables (que corresponda a nombre de
    bloque)
  - que sean unicos
- averiguar que los nombres de variables correspondan en todo el archivo
  - en las variables parent
  - en el vocabulario controlado
  - que no hay repeticiones, incluído entre bloques
- averiguar que los displayOrder funcionan
  - en las variables
  - en los valores de vocabulario controlado
- Averiguar que las variables correspondan a sus tipos

### Bloques

``` r
any(duplicated(sapply(allConfigs,function(x)x$block$name)))
```

    [1] FALSE

``` r
sapply(allConfigs,function(x)is.na(x$block$name))
```

           dvmetadatablock_citation      dvmetadatablock_geospatial 
                              FALSE                           FALSE 
      dvmetadatablock_institutional dvmetadatablock_externalReferen 
                              FALSE                           FALSE 
         dvmetadatablock_geographic             dvmetadatablock_eml 
                              FALSE                           FALSE 
     dvmetadatablock_social_science 
                              FALSE 

``` r
sapply(allConfigs,function(x)any(is.na(x$field$metadatablock_id)))
```

           dvmetadatablock_citation      dvmetadatablock_geospatial 
                              FALSE                           FALSE 
      dvmetadatablock_institutional dvmetadatablock_externalReferen 
                              FALSE                           FALSE 
         dvmetadatablock_geographic             dvmetadatablock_eml 
                              FALSE                           FALSE 
     dvmetadatablock_social_science 
                              FALSE 

``` r
sapply(allConfigs,function(x)all(x$field$metadatablock_id==x$block$name))
```

           dvmetadatablock_citation      dvmetadatablock_geospatial 
                               TRUE                            TRUE 
      dvmetadatablock_institutional dvmetadatablock_externalReferen 
                               TRUE                            TRUE 
         dvmetadatablock_geographic             dvmetadatablock_eml 
                               TRUE                            TRUE 
     dvmetadatablock_social_science 
                               TRUE 

## variables

``` r
sapply(allConfigs,function(x)all(x$field$parent[!is.na(x$field$parent)] %in% x$field$name))
```

           dvmetadatablock_citation      dvmetadatablock_geospatial 
                               TRUE                            TRUE 
      dvmetadatablock_institutional dvmetadatablock_externalReferen 
                               TRUE                            TRUE 
         dvmetadatablock_geographic             dvmetadatablock_eml 
                               TRUE                            TRUE 
     dvmetadatablock_social_science 
                               TRUE 

``` r
if(any(sapply(allConfigs,function(x)all(x$field$parent[!is.na(x$field$parent)] %in% x$field$name))))
{
  block_pb<-which(!sapply(allConfigs,function(x)all(x$field$parent[!is.na(x$field$parent)] %in% x$field$name)))
  for(i in block_pb)
  {
    parentsDeclared<-allConfigs[[i]]$field$parent[!is.na(allConfigs[[i]]$field$parent)]
    parentNotInName <- parentsDeclared[!parentsDeclared %in% allConfigs[[i]]$field$name]
    warning("En el bloque ",names(allConfigs)[i]," las variables siguientes son parents sin que estén declaradas en los nombres:\n",paste(parentNotInName,collapse="\n"))
  }
}
sapply(allConfigs,function(x)all(x$contrVoc$DatasetField %in% x$field$name))
```

           dvmetadatablock_citation      dvmetadatablock_geospatial 
                               TRUE                            TRUE 
      dvmetadatablock_institutional dvmetadatablock_externalReferen 
                               TRUE                            TRUE 
         dvmetadatablock_geographic             dvmetadatablock_eml 
                               TRUE                            TRUE 
     dvmetadatablock_social_science 
                               TRUE 

``` r
if(any(!sapply(allConfigs,function(x)all(x$contrVoc$DatasetField %in% x$field$name))))
{
  block_pb<-which(!sapply(allConfigs,function(x)all(x$contrVoc$DatasetField %in% x$field$name)))
  for(i in block_pb)
  {
    varInContrVoc <- allConfigs[[i]]$contrVoc$DatasetField
    contrVocNotInName<-unique(varInContrVoc[!varInContrVoc %in% allConfigs[[i]]$field$name])
    warning("En el bloque ",names(allConfigs)[i]," las variables siguientes están declaradas en el vocabulario controlado sin que estén declaradas en los nombres:\n",paste("\"",contrVocNotInName,"\"",sep="",collapse="\n"))
  }
}

nameVar<-lapply(allConfigs,function(x)x$field$name)
any(duplicated(unlist(nameVar)))
```

    [1] FALSE

## DisplayOrder

``` r
block_pb<-which(!sapply(allConfigs,function(x)all(0:(nrow(x$field)-1) %in% x$field$displayOrder)))
if(length(block_pb)>0)
{warning("Por favor corregir la variable displayOrder en los bloques siguientes:\n",paste(names(allConfigs)[block_pb],collapse="\n"))}

(checkDO_contrVoc<-lapply(allConfigs,function(x)
  {
    res<-by(x$contrVoc,x$contrVoc$DatasetField,function(tab)
      {
         all(0:(nrow(tab)-1) %in% tab$displayOrder)
      })
    names(res)[!res]
  }))
```

    $dvmetadatablock_citation
    [1] "language"

    $dvmetadatablock_geospatial
    character(0)

    $dvmetadatablock_institutional
    character(0)

    $dvmetadatablock_externalReferen
    character(0)

    $dvmetadatablock_geographic
    character(0)

    $dvmetadatablock_eml
    character(0)

    $dvmetadatablock_social_science
    character(0)

``` r
df_blockPb<- data.frame(block=rep(names(checkDO_contrVoc),sapply(checkDO_contrVoc,length)),
                        varContVoc=unlist(checkDO_contrVoc))
if(nrow(df_blockPb)>0)
{
  warning("Por favor corregir la variable displayOrder en las variables de vocabulario controlado siguiente:\n",
          paste(df_blockPb$varContVoc,"(bloque",df_blockPb$block,")",collapse="\n"))
}
```

    Warning: Por favor corregir la variable displayOrder en las variables de vocabulario controlado siguiente:
    language (bloque dvmetadatablock_citation )

## Tipos de las variables descriptivas de la configuración

``` r
sapply(allConfigs$dvmetadatablock_citation$field, mode)
```

                         name                     title               description 
                  "character"               "character"               "character" 
                    watermark                 fieldType              displayOrder 
                  "character"               "character"                 "numeric" 
                displayFormat       advancedSearchField allowControlledVocabulary 
                  "character"                 "logical"                 "logical" 
               allowmultiples                 facetable           displayoncreate 
                    "logical"                 "logical"                 "logical" 
                     required                    parent          metadatablock_id 
                    "logical"               "character"               "character" 
                      termURI                   Visible          traducción_title 
                  "character"               "character"               "character" 
       traducción_description      traducción_watermark 
                  "character"               "character" 

``` r
type_fields <- list()
type_fields$metadatablock <- c(name="character", dataverseAlias="character", displayName="character", blockURI="character", traducción_displayName="character", traducción_name="character",traducción_facetName="character")
type_fields$field <- c(name="character", title="character", description="character", watermark="character", fieldType="character", displayOrder="numeric", displayFormat="character", advancedSearchField="logical", allowControlledVocabulary="logical", allowmultiples="logical", facetable="logical", displayoncreate="logical", required="logical", parent="character", metadatablock_id="character", termURI="character", traducción_title="character", traducción_description="character", traducción_watermark="character", Visible="character")
type_fields$controlledVocabulary<-c(DatasetField="character", Value="character", identifier="character", displayOrder="numeric", traducción_Value="character")

for(i in names(allConfigs))
{
  for(j in colnames(allConfigs[[i]]$block))
  {
    if(!j %in% names(type_fields$metadatablock))
    {
      warning("En la configuración de ", i, " la variable ", j, " de la parte metadatablock no se reconoce")
    }else{
      if(mode(allConfigs[[i]]$block[[j]]) != type_fields$metadatablock[j] & !all(is.na(allConfigs[[i]]$block[[j]])) )
      {
        message("En la configuración de ", i, " la variable ", j, " de la parte metadatablock no tiene el tipo requerido. Si no hay un warning, significa que el cambio de tipo no causa problema")
        as(allConfigs[[i]]$block[[j]], type_fields$metadatablock[j])
      }
    }
  }
  for(j in colnames(allConfigs[[i]]$field))
  {
    if(!j %in% names(type_fields$field))
    {
      warning("En la configuración de ", i, " la variable ", j, " de la parte field no se reconoce")
    }else{
      if(mode(allConfigs[[i]]$field[[j]]) != type_fields$field[j] & !all(is.na(allConfigs[[i]]$field[[j]])) )
      {
        message("En la configuración de ", i, " la variable ", j, " de la parte field no tiene el tipo requerido. Si no hay un warning, significa que el cambio de tipo no causa problema")
        as(allConfigs[[i]]$field[[j]], type_fields$field[j])
      }
    }
  }
  for(j in colnames(allConfigs[[i]]$contrVoc))
  {
    if(!j %in% names(type_fields$controlledVocabulary))
    {
      warning("En la configuración de ", i, " la variable ", j, " de la parte de vocabulario controlado no se reconoce")
    }else{
      if(mode(allConfigs[[i]]$contrVoc[[j]]) != type_fields$controlledVocabulary[j] & !all(is.na(allConfigs[[i]]$contrVoc[[j]])) )
      {
        message("En la configuración de ", i, " la variable ", j, " de la parte vocabulario controlado no tiene el tipo requerido. Si no hay un warning, significa que el cambio de tipo no causa problema")
        as(allConfigs[[i]]$contrVoc[[j]], type_fields$controlledVocabulary[j])
      }
    }
  }
}
```

``` r
lapply(allConfigs,function(x)all(x$field$fieldType %in% c("none","date","email","text","textbox","string","url","int","float")))
```

    $dvmetadatablock_citation
    [1] TRUE

    $dvmetadatablock_geospatial
    [1] TRUE

    $dvmetadatablock_institutional
    [1] TRUE

    $dvmetadatablock_externalReferen
    [1] TRUE

    $dvmetadatablock_geographic
    [1] TRUE

    $dvmetadatablock_eml
    [1] TRUE

    $dvmetadatablock_social_science
    [1] TRUE

# Export formatted configuration files

``` r
format1val<-function(x){if(is.na(x)){return("")};return(stringi::stri_escape_unicode(x))}
formatValue<-function(x)
{
  res<-character(length(x))
  res[is.na(x)]<-""
  res[!is.na(x)]<-stringi::stri_escape_unicode(x[!is.na(x)])
  return(res)
}
formatRef<-function(x)
{tolower(gsub(" ","_",x))}
exportConfigFiles <- function(allConfigs, exportDir, fieldList, overwriteDir=T)
{
  if(dir.exists(exportDir))
  {
    if(overwriteDir)
    {
      unlink(exportDir, recursive = TRUE)
    }else{
      stop("La carpeta", exportDir, "ya existe y el parametro overwriteDir no es verdadero")
    }
  }
  dir.create(exportDir)
  dir.create(paste(exportDir,"langBundle",sep="/"))
  dir.create(paste(exportDir,"metadata_tsv",sep="/"))
  
  allConfigs_base <- lapply(allConfigs,function(x)x)
  allConfigs_base <- lapply(allConfigs,function(x, f)
  {
    res<-list()
    res$block <- x$block[,colnames(x$block)[colnames(x$block) %in% f$metadatablock$base]]
    res$field <- x$field[,colnames(x$field)[colnames(x$field) %in% f$field$base]]
    res$contrVoc <- x$contrVoc[,colnames(x$contrVoc)[colnames(x$contrVoc) %in% f$controlledVocabulary$base]]
    return(res)
  }, f=fieldList)
  blockNames<-sapply(allConfigs, function(x)x$block$name)
  for(i in 1:length(allConfigs))
  {
    fileName<-paste(exportDir,"metadata_tsv",paste0(blockNames[i],".tsv"),sep="/")
    cat(paste(c("#metadataBlock", colnames(allConfigs_base[[i]]$block)), collapse="\t"),file=fileName)
    cat("\n",file=fileName,append=T)
    write.table(data.frame(`metadatablock`=NA, allConfigs_base[[i]]$block), file=fileName, quote=F, sep="\t", na = "",col.names=F, append=T,row.names = F)
    cat(paste(c("#datasetField", colnames(allConfigs_base[[i]]$field)), collapse="\t"),file=fileName,append=T)
    cat("\n",file=fileName,append=T)
    write.table(data.frame(`datasetField`=NA, allConfigs_base[[i]]$field), file=fileName, quote=F, sep="\t", na = "",col.names=F, append=T,row.names = F)
    cat(paste(c("#controlledVocabulary", colnames(allConfigs_base[[i]]$contrVoc)), collapse="\t"),file=fileName,append=T)
    cat("\n",file=fileName,append=T)
    write.table(data.frame(`datasetField`=NA, allConfigs_base[[i]]$contrVoc), file=fileName, quote=F, sep="\t", na = "",col.names=F, append=T,row.names = F)
  }
  for(i in 1:length(allConfigs))
  {
    fileName<-paste(exportDir,"langBundle",paste0(blockNames[i],"_es.properties"),sep="/")
    cat(fileName,"\n")
    cat("metadatablock.name=",format1val(allConfigs[[i]]$block$traducción_name),"\n",sep="",file=fileName)
    cat("metadatablock.displayName=",format1val(allConfigs[[i]]$block$traducción_displayName),"\n",sep="",file=fileName, append=T)
    cat("metadatablock.displayFacet=",format1val(allConfigs[[i]]$block$traducción_facetName),"\n",sep="",file=fileName, append=T)
    cat(paste("datasetfieldtype.",allConfigs[[i]]$field$name,".title=",formatValue(allConfigs[[i]]$field$traducción_title),sep="",collapse="\n"),"\n",file=fileName,append=T)
    cat(paste("datasetfieldtype.",allConfigs[[i]]$field$name,".description=",formatValue(allConfigs[[i]]$field$traducción_description),sep="",collapse="\n"),"\n",file=fileName,append=T)
    cat(paste("datasetfieldtype.",allConfigs[[i]]$field$name,".watermark=",formatValue(allConfigs[[i]]$field$traducción_watermark),sep="",collapse="\n"),"\n",file=fileName,append=T)
    if(nrow(allConfigs[[i]]$contrVoc)>0)
    {
      cat(paste("controlledvocabulary.",allConfigs[[i]]$contrVoc$DatasetField,".",formatRef(allConfigs[[i]]$contrVoc$Value),"=",formatValue(allConfigs[[i]]$contrVoc$traducción_Value),sep="",collapse="\n"),file=fileName,append=T)
    }
  }
}
exportConfigFiles(allConfigs = allConfigs, exportDir = "../../data_metadatos_catalogos/exportConfig/", fieldList=validaciones_fields)
```

    ../../data_metadatos_catalogos/exportConfig//langBundle/citation_es.properties 
    ../../data_metadatos_catalogos/exportConfig//langBundle/geospatial_es.properties 
    ../../data_metadatos_catalogos/exportConfig//langBundle/institutional_es.properties 
    ../../data_metadatos_catalogos/exportConfig//langBundle/externalReferences_es.properties 
    ../../data_metadatos_catalogos/exportConfig//langBundle/geographic_es.properties 
    ../../data_metadatos_catalogos/exportConfig//langBundle/emldn_es.properties 
    ../../data_metadatos_catalogos/exportConfig//langBundle/socialscience_es.properties 
