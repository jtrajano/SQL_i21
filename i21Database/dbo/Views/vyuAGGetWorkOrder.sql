CREATE VIEW [dbo].[vyuAGGetWorkOrder]
AS

(
	SELECT intWorkOrderId
	, WO.intApplicationTypeId,
	, TYPE.strType
	, WO.intCropId
	, CROP.strCrop
	, COMPANYLOCATION.intCompanyLocationId
	, COMPANYLOCATION.strLocationName
	, WO.strStatus
	, WO.strOrderNumber
	, WO.intEntityCustomerId
	, CUSTOMER.strName AS strCustomerName
	, WO.intFarmFieldId
	, WO.intTermId
	, TERM.strTerm
	, FARMLOCATION.strLocationName AS strFarmFieldName
	, WO.dblAcres
	, WO.dtmCreatedDate
	, WO.dtmApplyDate
	, WO.dtmDueDate
	, strApplicatorLicenseNumber
	, WO.intOrderedById
	, ORDEREDBY.strName  AS strOrderedBy
	, WO.intEntitySalesRepId
	, ENTITY.strName AS strSalesPersonName
	, WO.intSplitId
	, SPLIT.strSplitNumber
	, WO.strComments
	,WO.strFarmDescription
	, WO.dtmStartDate
	, WO.dtmEndDate
	, WO.dtmStartTime
	, WO.dtmEndTime
	, WO.dblApplicationRate
	, WO.strSeason
	, WO.strWindDirection
	, WO.dblWindSpeed
	, WO.strWindSpeedUOM
	, WO.dblTemperature
	, WO.strSoilCondition
	, WO.dblAppliedAcres
	, WO.strTemperatureUOM
	, WO.intApplicationTargetId
	, TARGET.strTargetName
	, WO.ysnShipped
	, WO.ysnFinalized
	, WO.intConcurrencyId
    FROM tblAGWorkOrder WO WITH(NOLOCK)  

	LEFT JOIN (
		SELECT intCropId 
		, strCrop
		FROM tblAGCrop WITH(NOLOCK)  
	) CROP ON CROP.intCropId = WO.intCropId
	LEFT JOIN (
		SELECT intCompanyLocationId
		, strLocationName
		FROM tblSMCompanyLocation WITH(NOLOCK)  
	) COMPANYLOCATION ON COMPANYLOCATION.intCompanyLocationId = WO.intCompanyLocationId
	LEFT JOIN (
		SELECT  
			strName
			,intEntityCustomerId
		FROM vyuARCustomerSearch WITH(NOLOCK)  
	) CUSTOMER ON CUSTOMER.intEntityCustomerId  = WO.intEntityCustomerId
	LEFT JOIN (
		SELECT intEntityLocationId
			, strLocationName
			FROM tblEMEntityLocation WITH(NOLOCK)  
	) FARMLOCATION ON FARMLOCATION.intEntityLocationId = WO.intFarmFieldId
	LEFT JOIN (
		SELECT  
			strName
			,intEntityId
		FROM tblEMEntity WITH(NOLOCK)  
	) ORDEREDBY ON ORDEREDBY.intEntityId = WO.intOrderedById
	LEFT JOIN (
		SELECT
		 intEntityId
		, strName
		 FROM tblEMEntity WITH(NOLOCK)  
	) ENTITY ON ENTITY.intEntityId = WO.intEntitySalesRepId
	LEFT JOIN (
	 SELECT
	 intSplitId,
	 strSplitNumber
	 FROM tblEMEntitySplit WITH(NOLOCK)  
	) SPLIT ON SPLIT.intSplitId = WO.intSplitId
	LEFT JOIN (
	SELECT intTermID
		 , strTerm 
	FROM tblSMTerm WITH (NOLOCK)
) TERM ON WO.intTermId = TERM.intTermID
LEFT JOIN (
	SELECT strTargetName,
	intApplicationTargetId FROM 
	tblAGApplicationTarget WITH (NOLOCK)
)   TARGET ON WO.intApplicationTargetId  = TARGET.intApplicationTargetId
LEFT JOIN (
	SELECT intApplicationTypeId,
		strType
		FROM tblAGApplicationType WITH (NOLOCK)
) TYPE ON TYPE.intApplicationTypeId = WO.intApplicationTypeId
) 
