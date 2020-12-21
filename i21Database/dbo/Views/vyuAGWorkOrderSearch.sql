CREATE VIEW [dbo].[vyuAGWorkOrderSearch]
AS
(
	SELECT WO.intWorkOrderId
	 ,WO.strOrderNumber
	, WO.strCustomerName
	, WO.intEntityCustomerId
	, CUSTOMER.strCustomerNumber
	, WO.intOrderedById
	, WO.dtmApplyDate
	, WO.intEntityLocationId
	, LOCATION.strLocationName
	, ENTITY.strName AS 'strOrderedBy'
	, WO.strStatus
	FROM tblAGWorkOrder WO
	LEFT JOIN (
		SELECT 
		intEntityId
		,strCustomerNumber
		FROM tblARCustomer WITH(NOLOCK)  
	) CUSTOMER on CUSTOMER.intEntityId = WO.intEntityCustomerId
	LEFT JOIN (
		SELECT 
		intEntityLocationId,
		strLocationName
		FROM tblEMEntityLocation  WITH(NOLOCK)  
	) LOCATION ON LOCATION.intEntityLocationId = WO.intEntityLocationId
   LEFT JOIN (
	   SELECT 
	   intEntityId,
	   strName
	   FROM tblEMEntity WITH(NOLOCK)  
   ) ENTITY ON ENTITY.intEntityId  = WO.intOrderedById
)