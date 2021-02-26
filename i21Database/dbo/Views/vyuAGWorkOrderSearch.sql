CREATE VIEW [dbo].[vyuAGWorkOrderSearch]
AS
(
	SELECT WO.intWorkOrderId
	 ,WO.strOrderNumber
	 ,CROP.strCrop
	 --,WO.strType AS 'strCrop'
	, FARMLOCATION.strLocationName AS 'strFarmField'
	 ,TARGET.strTargetName
	, SALESREP.strName as 'strSalesperson'
	, SPLIT.strSplitNumber
	, WO.dblAcres
	, WO.strComments
	, WO.strCustomerName
	, WO.intEntityCustomerId
	, CUSTOMER.strCustomerNumber
	, WO.intOrderedById
	, WO.dtmApplyDate
	, WO.intCompanyLocationId
	, LOCATION.strLocationName
	, ENTITY.strName AS 'strOrderedBy'
	, WO.strStatus
	, APPLICATOR.strName AS 'strApplicator'
	FROM tblAGWorkOrder WO
	LEFT JOIN (
		SELECT 
		intEntityId
		,strCustomerNumber
		FROM tblARCustomer WITH(NOLOCK)  
	) CUSTOMER on CUSTOMER.intEntityId = WO.intEntityCustomerId
	LEFT JOIN (
		SELECT 
		intCompanyLocationId,
		strLocationName
		FROM tblSMCompanyLocation  WITH(NOLOCK)  
	) LOCATION ON LOCATION.intCompanyLocationId = WO.intCompanyLocationId
   LEFT JOIN (
	   SELECT 
	   intEntityId,
	   strName
	   FROM tblEMEntity WITH(NOLOCK)  
   ) ENTITY ON ENTITY.intEntityId  = WO.intOrderedById
    LEFT JOIN (      
	  SELECT intEntityLocationId      
	   , strLocationName     
	   FROM tblEMEntityLocation WITH(NOLOCK)        
 ) FARMLOCATION ON FARMLOCATION.intEntityLocationId = WO.intFarmFieldId  
    LEFT JOIN (  
	 SELECT strTargetName,  
		 intApplicationTargetId FROM   
		 tblAGApplicationTarget WITH (NOLOCK)  
	)   TARGET ON WO.intApplicationTargetId  = TARGET.intApplicationTargetId 
 LEFT JOIN (      
	  SELECT      
	   intEntityId      
	  , strName      
	   FROM tblEMEntity WITH(NOLOCK)        
 ) SALESREP ON SALESREP.intEntityId = WO.intEntitySalesRepId  
  LEFT JOIN (      
	  SELECT      
		  intSplitId,      
		  strSplitNumber      
	 FROM tblEMEntitySplit WITH(NOLOCK)        
 ) SPLIT ON SPLIT.intSplitId = WO.intSplitId
 LEFT JOIN (
	 SELECT
	 	intCropId,
		 strCrop
	FROM tblAGCrop WITH(NOLOCK)
 ) CROP ON CROP.intCropId = WO.intCropId
 LEFT JOIN (
	SELECT 
		intEntityId,
		strName
	FROM tblEMEntity WITH(NOLOCK)
 )  APPLICATOR ON APPLICATOR.intEntityId = WO.intEntityApplicatorId
)