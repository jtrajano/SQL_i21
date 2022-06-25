CREATE VIEW [dbo].[vyuLGDispatchOrderDetail]
AS
SELECT 
	DOD.intDispatchOrderDetailId
	,DOD.intDispatchOrderId
	,DOD.intSequence
	,DOD.intLoadSeq
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
	,strFromEntity = CASE WHEN (DOD.intVendorId IS NOT NULL) THEN V.strName ELSE CL.strLocationName END
	,strFromLocation = CASE WHEN (DOD.intVendorId IS NOT NULL) THEN VL.strLocationName ELSE CLSL.strSubLocationName END
	,strEntityName = CASE WHEN (DOD.strOrderType IN ('Outbound', 'Sales') AND DOD.intStopType = 1) OR (DOD.strOrderType IN ('Transfer')) THEN CL.strLocationName ELSE E.strName END
	,strLocationName = CASE WHEN (DOD.strOrderType IN ('Outbound', 'Sales') AND DOD.intStopType = 1) OR (DOD.strOrderType IN ('Transfer')) THEN CLSL.strSubLocationName ELSE EL.strLocationName END
	,strSiteID = RIGHT('000'+ CAST(TMS.intSiteNumber AS NVARCHAR(4)),4) COLLATE Latin1_General_CI_AS
	,DOD.strEntityContact
	,DOD.strAddress
	,DOD.strCity
	,DOD.strState
	,DOD.strCountry
	,DOD.strZipCode
	,strItemNo = ISNULL(I.strItemNo, DOD.strItemNo)
	,strItemDescription = I.strDescription
	,DOD.dblQuantity
	,DOD.dblStandardWeight
	,DOD.strOrderComments
	,DOD.strDeliveryComments
	,DOD.intEntityShipViaId
	,DOD.intEntityShipViaTruckId 
	,DOD.intEntityShipViaTrailerId
	,DOD.intEntityShipViaCompartmentId
	,SVTC.strCompartmentNumber
	,I.intCategoryId
	,SVTC.dblCapacity
	,DOD.intConcurrencyId
FROM tblLGDispatchOrderDetail DOD 
LEFT JOIN tblICItem I ON I.intItemId = DOD.intItemId
LEFT JOIN tblEMEntity E ON E.intEntityId = DOD.intEntityId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = DOD.intEntityLocationId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = DOD.intCompanyLocationId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = DOD.intCompanyLocationSubLocationId
LEFT JOIN tblEMEntity V ON V.intEntityId = DOD.intVendorId
LEFT JOIN tblEMEntityLocation VL ON VL.intEntityLocationId = DOD.intVendorLocationId
LEFT JOIN tblSMShipViaTrailerCompartment SVTC ON SVTC.intEntityShipViaTrailerCompartmentId = DOD.intEntityShipViaCompartmentId
LEFT JOIN tblTMSite TMS ON TMS.intSiteID = DOD.intTMSiteId
