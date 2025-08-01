dvAnalyseVar<-function(dvcon)
{
  analysis<-dbGetQuery(biocultural,"
  SELECT dft.id, mdb.name metadatablock, dft.name, fieldtype, allowmultiples,
    COUNT(dfv.value) FILTER (WHERE value IS NOT NULL) nb_values,
    COUNT(dfcvv.controlledvocabularyvalues_id) FILTER (WHERE dfcvv.controlledvocabularyvalues_id  IS NOT NULL) nb_controlled_values,
    dft.parentdatasetfieldtype_id,
    dft.id IN (SELECT DISTINCT parentdatasetfieldtype_id FROM datasetfieldtype WHERE parentdatasetfieldtype_id IS NOT NULL) is_parent
  FROM datasetfieldtype dft
  LEFT JOIN metadatablock mdb ON dft.metadatablock_id=mdb.id
  LEFT JOIN datasetfield df ON df.datasetfieldtype_id=dft.id
  LEFT JOIN datasetfieldvalue dfv ON dfv.datasetfield_id=df.id
  LEFT JOIN datasetfield_controlledvocabularyvalue dfcvv ON dfcvv.datasetfield_id=df.id
  GROUP BY dft.id, mdb.name, dft.name, fieldtype, allowmultiples, dft.id IN (SELECT DISTINCT parentdatasetfieldtype_id FROM datasetfieldtype WHERE parentdatasetfieldtype_id IS NOT NULL), dft.parentdatasetfieldtype_id
  ORDER BY dft.id
  ")
  analysis$is_gp<-analysis$allowmultiples | analysis$is_parent
  toKeep<-logical(nrow(analysis))
  for(i in analysis$id)
  {toKeep[analysis$id==i]<- as.logical(
    sum(colSums(analysis[analysis$id == i | analysis$parentdatasetfieldtype_id == i,
                           c("nb_values","nb_controlled_values")],na.rm = T)))}
  if(any((!is.na(analysis$parentdatasetfieldtype_id)) & analysis$allowmultiples))
  {stop("The code has been thought for cases where variables either have parent variable or accept multiple values, not both")}
  stopifnot(!nrow(analysis[(analysis$is_parent)  & (!is.na(analysis$parentdatasetfieldtype_id)),]))
  listGp<-list()
  for(i in 1:nrow(gpTab))
  {
    listGp[[gpTab$name[i]]]<-analysis[analysis$id==gpTab[i,"id"]|(!is.na(analysis$parentdatasetfieldtype_id) & analysis$parentdatasetfieldtype_id==gpTab[i,"id"]),]
  }
  analysis$var_gp<-factor(NA,levels=c("var","gp","gpvar"))
  analysis$var_gp[analysis$is_parent]<-"gp"
  analysis$var_gp[!analysis$is_parent & analysis$is_gp & rowSums(analysis[,c("nb_values","nb_controlled_values")])] <- "gpvar"
  analysis$var_gp[!analysis$is_parent & !analysis$is_gp & rowSums(analysis[,c("nb_values","nb_controlled_values")])] <- "var"
  
  analysis$gpHier <- analysis$inGp <- NA
  for (i in 1:nrow(analysis))
  {
    prepGpHier<-c("dataverse","dataset","datasetversion",analysis$metadatablock[i])
    if(analysis$var_gp[i]=="gp")
    {
      prepGpHier<-c(prepGpHier,analysis$name[i])
      analysis$inGp[i]<-analysis$id[i]
    }
    if(analysis$var_gp[i]=="gpvar")
    {
      prepGpHier<-c(prepGpHier,paste0(analysis$name[i],"_"))
      analysis$inGp[i]<-analysis$id[i]
    }
    if(!is.na(analysis$parentdatasetfieldtype_id[i]))
    {
      prepGpHier<-c(prepGpHier,analysis$name[analysis$id==analysis$parentdatasetfieldtype_id[i]])
      analysis$inGp[i]<-analysis$parentdatasetfieldtype_id[i]
    }
    if(analysis$var_gp[i]=="var"||analysis$var_gp[i]=="gpvar"){
      prepGpHier<-c(prepGpHier,analysis$name[i])
    }
    analysis$gpHier[i]<-paste(prepGpHier,collapse="/")
  }
  
  gpTab<-rbind(
    data.frame(
      id=c(1000,1001,1002,1003,1004,1005),
      name=c("dataverse","dataset","datasetversion","citation","geospatial","socialscience"),
      gpHier=c("dataverse","dataverse/dataset","dataverse/dataset/datasetversion",paste("dataverse/dataset/datasetversion",c("citation","geospatial","socialscience"),sep="/")),
      var_gp="gp",
      inGp=c(1000,1001,1002,1003,1004,1005)
    ),
    analysis[analysis$var_gp %in% c("gp", "gpvar"),c("id", "name", "gpHier", "var_gp", "inGp")]
  )
  gpTab$name[gpTab$var_gp=="gpvar"]<-paste0(gpTab$name[gpTab$var_gp=="gpvar"],"_")
  gpTab$gpHier<-sub("(^.*_).*$","\\1",gpTab$gpHier)
  gpTab$var_gp="gp"
  
  varTab<-analysis[analysis$var_gp %in% c("gpvar", "var"), c("id", "name", "gpHier", "var_gp", "inGp") ]
  addGp<-is.na(varTab$inGp)
  varTab$inGp[addGp]<-gpTab$id[match(analysis[analysis$var_gp %in% c("gpvar", "var"),"metadatablock"][addGp],gpTab$name)]
  varTab$var_gp<-"var"
  
  varTab$inGp%in%gpTab$id
  
  hierTab<-rbind(gpTab,varTab)
  if(any(hierTab$name%in%NODE_RESERVED_NAMES_CONST))
  {
    hierTab$name[hierTab$name%in%NODE_RESERVED_NAMES_CONST]<-paste0(
      hierTab$name[hierTab$name%in%NODE_RESERVED_NAMES_CONST],"_")
  }
}