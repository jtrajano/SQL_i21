CREATE VIEW [dbo].[vyuLGDispatchOrderDetail]
AS
SELECT 
	DOD.intDispatchOrderDetailId
	,DOD.intDispatchOrderId
	,DOD.intSequence
	,DOD.intStopType
	,strStopType = CASE DOD.intStopType 
		WHEN 1 THEN 'Pick Up'
		WHEN 2 THEN 'Delivery'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,DOD.dtmStartTime
	,DOD.dtmEndTime
	,strOrderStatus = CASE DOD.intOrderStatus
		WHEN 1 THEN 'Ready'
		WHEN 2 THEN 'In Transit'
		WHEN 3 THEN 'Delivered'
		WHEN 4 THEN 'On-hold'
		WHEN 5 THEN 'Cancelled'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,DOD.strOrderNumber
	,DOD.strOrderType
	,strEntityName = CASE WHEN (DOD.strOrderType IN ('Outbound', 'Sales') AND DOD.intStopType = 1) OR (DOD.strOrderType IN ('Transfer')) THEN CL.strLocationName ELSE E.strName END
	,strLocationName = CASE WHEN (DOD.strOrderType IN ('Outbound', 'Sales') AND DOD.intStopType = 1) OR (DOD.strOrderType IN ('Transfer')) THEN CLSL.strSubLocationName ELSE EL.strLocationName END
	,DOD.strEntityContact
	,DOD.strAddress
	,DOD.strCity
	,DOD.strState
	,DOD.strCountry
	,DOD.strZipCode
	,I.strItemNo
	,strItemDescription = I.strDescription
	,DOD.dblQuantity
	,DOD.strOrderComments
	,DOD.strDeliveryComments
	,DOD.intConcurrencyId
FROM tblLGDispatchOrderDetail DOD 
LEFT JOIN tblICItem I ON I.intItemId = DOD.intItemId
LEFT JOIN tblEMEntity E ON E.intEntityId = DOD.intEntityId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = DOD.intEntityLocationId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = DOD.intCompanyLocationId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = DOD.intCompanyLocationSubLocationId
