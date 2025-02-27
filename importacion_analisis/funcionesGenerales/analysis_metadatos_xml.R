
extractAdressesMultiXml <- function(text_doc_xml,grep_name="^---file:(.*)---$",name_part="\\1",verbose=T)
{
  sepFiles <- grep("---file:.*---",text_doc_xml)
  if(verbose)
  {
    cat("Number of elements:",sum(sepFiles))
  }
  res<-data.frame(
    name=sub(grep_name,name_part,text_doc_xml[sepFiles]),
    beg=sepFiles+1,
    end=c(sepFiles[2:length(sepFiles)]-1,length(text_doc_xml))
  )
  pbs<-which(res$beg>res$end)
  if(length(pbs))
  {
    warning("Some xml documents appear to be empty (we will not consider them):", paste(res$name[pbs],collapse="\n"))
  }
  return(res[-pbs,])
}

navMetaList <- function(metaList,numpath)
{
  x=metaList
  for(i in numpath)
    x <- x[[i]]
  return(x)
}
nextLevelLength <- function(metaList,numpath)
{
  length(navMetaList(metaList,numpath))
}  
nextLevelNames <- function(metaList,numpath)
{
  names(navMetaList(metaList,numpath))
}

appendRepListVectorElements<-function(l,toAdd)
{
  stopifnot(length(l)==length(toAdd))
  n<-sapply(toAdd,length)
  return(mapply(append,rep(l,n),unlist(toAdd),SIMPLIFY=F))
}

childrenPath <- function(path,l)
{
  appendRepListVectorElements(path,lapply(l,function(x)1:x))
}

numRep<-function(x)
{ 
  x<-factor(x)
  un<-levels(x)
  m<-match(x,un)
  t<-table(x)
  res<-integer(length(x))
  res[order(m)]<-unlist(lapply(t,function(x)1:x))
  return(res)
}

goFurther<-c("list","XMLAttributes")
acceptableClasses<-c("list","XMLAttributes","character")
listDocument<-xml_list
extractStructureListDocuments<-function(listDocument,goFurther=c("list","XMLAttributes"))
{
#initialization
currentList<-listDocument
LEV<-0
classes<-currentClasses<-sapply(currentList,class,USE.NAMES = F)
listPath<-lapply(1:length(currentList),function(x)x)
listNames<-as.list(names(currentList))
currentW<-1:length(currentList)
#listNames<-c(listNames,appendRepListVectorElements(listNames,namesChildren))
nChildren<-sapply(currentList,length, USE.NAMES = F)
levStruct<-rep(LEV,length(currentList))
parents<-rep(0,length(currentList))
keepGoing<-currentClasses%in%goFurther
directChildren<-mapply(function(x,y,s)s+seq(y,x),A<-cumsum(nChildren[keepGoing]),c(1,A[-length(A)]+1),s=length(listPath),SIMPLIFY = F)
num_rep<-rep(NA,length(currentList))
null_val<-NULL
val<-NULL
while(sum(keepGoing)>0)
{
  LEV<-LEV+1
  parentW<-currentW
  currentW<-(max(parentW)+1):(max(parentW)+sum(nChildren[keepGoing]))
  parents<-c(parents,rep(parentW[keepGoing],nChildren[keepGoing]))
  #add Paths
  listPath<-c(listPath,childrenPath(listPath[parentW][keepGoing],nChildren[keepGoing]))
  #Add names
  finalCurrentNames<-lapply(currentList[keepGoing],names)
  ## DupliNames
  num_rep<-c(num_rep,unlist(lapply(finalCurrentNames,function(x)
  {
    res<-rep(NA,length(x))
    if(!anyDuplicated(x)){return(res)}
    dupliNames<-unique(x[duplicated(x)])
    m<-match(x,dupliNames)
    res[!is.na(m)]<-numRep(x[!is.na(m)])
    return(res)
  })))
  listNames<-c(listNames,appendRepListVectorElements(listNames[parentW][keepGoing],finalCurrentNames))
  # Change currentList
  currentList<-unlist(currentList[keepGoing],recursive=F,use.names = F)
  nChildren<-sapply(currentList,length)
  # Following classes
  currentClasses<-sapply(currentList,class)
  keepGoing<-currentClasses%in%goFurther
  ##Correcting it: when there is a name in the element, we keep going
  keepGoing[!keepGoing][!sapply(lapply(currentList[!keepGoing],names),is.null)]<-T
  nChildren[!keepGoing]<-0
  
  if(length(currentClasses))
  {classes<-c(classes,currentClasses)}
  
  levStruct<-c(levStruct,rep(LEV,length(currentList)))
  directChildren<-c(directChildren,
                    mapply(function(nC,x,y,s){
                       if(nC==0){return(NULL)}
                       if(nC==1){return(s+y)}
                       return(s+seq(y,x))
                    },nChildren,A<-cumsum(nChildren),c(1,A[-length(A)]+1),s=length(listPath),SIMPLIFY = F))
  if(any(!keepGoing))
  {
    cNull<-sapply(currentList[!keepGoing],is.null)
    null_val<-c(null_val,currentW[!keepGoing][cNull])
    val<-c(val,currentW[!keepGoing][!cNull])
  }
  stopifnot(length(unique(
    c(length(parents),length(listPath),length(listNames),length(directChildren),length(levStruct),length(classes),length(num_rep))
    ))==1)
}
return(list(levs=unique(levStruct),paths=listPath,listNames=listNames,parents=parents,directChildren=directChildren,classes=classes,val=val,null_val=null_val))
}


