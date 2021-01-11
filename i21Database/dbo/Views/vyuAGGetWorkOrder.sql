CREATE VIEW [dbo].[vyuAGGetWorkOrder]
AS

(
	SELECT intWorkOrderId
	, WO.strType
	, WO.intItemId
	, ITEM.strItemNo
	, ENTITYLOCATION.intEntityLocationId
	, ENTITYLOCATION.strLocationName
	, WO.strStatus
	, WO.strOrderNumber
	, WO.intEntityCustomerId
	, CUSTOMER.strName AS strCustomerName
	, WO.intFarmFieldId
	, TERM.strTerm
	, FARMLOCATION.strLocationName AS strFarmFieldName
	, WO.dblAcres
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
	, WO.intConcurrencyId
    FROM tblAGWorkOrder WO WITH(NOLOCK)  

	LEFT JOIN (
		SELECT intItemId 
		, strItemNo
		FROM tblICItem WITH(NOLOCK)  
	) ITEM ON ITEM.intItemId = WO.intItemId
	LEFT JOIN (
		SELECT intEntityLocationId
		, strLocationName
		FROM tblEMEntityLocation WITH(NOLOCK)  
	) ENTITYLOCATION ON ENTITYLOCATION.intEntityLocationId = WO.intEntityLocationId
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
			,intEntityCustomerId
		FROM vyuARCustomerSearch WITH(NOLOCK)  
	) ORDEREDBY ON ORDEREDBY.intEntityCustomerId = WO.intOrderedById
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
) 
