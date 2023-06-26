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
		WHEN 3 THEN 'At Location'
		WHEN 4 THEN CASE WHEN (DOD.intStopType = 1) THEN 'Loaded' ELSE 'Delivered' END
		WHEN 5 THEN 'On-hold'
		WHEN 6 THEN 'Cancelled'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,DOD.strOrderNumber
	,DOD.strOrderType
	,DOD.strPONumber
	,strTerminalName = TCN.strName
	,strTerminalControlNumber = TCN.strTerminalControlNumber
	,strFromSupplier = V.strName
	,strFromTerminal = TCN.strName
	,strFromStorageLocation = CLSL.strSubLocationName
	,strFromLocation = CL.strLocationName
	,strFromAddress = CASE WHEN (DOD.intVendorId IS NOT NULL) THEN VL.strAddress 
		WHEN (CLSL.intCompanyLocationSubLocationId IS NOT NULL) THEN CLSL.strAddress 
		ELSE CL.strAddress END
	,strFromCity = CASE WHEN (DOD.intVendorId IS NOT NULL) THEN VL.strCity 
		WHEN (CLSL.intCompanyLocationSubLocationId IS NOT NULL) THEN CLSL.strCity 
		ELSE CL.strCity END
	,strFromState = CASE WHEN (DOD.intVendorId IS NOT NULL) THEN VL.strState 
		WHEN (CLSL.intCompanyLocationSubLocationId IS NOT NULL) THEN CLSL.strState 
		ELSE CL.strStateProvince END
	,strFromCountry = CASE WHEN (DOD.intVendorId IS NOT NULL) THEN VL.strCountry  
		ELSE CL.strCountry END
	,strFromZipCode = CASE WHEN (DOD.intVendorId IS NOT NULL) THEN VL.strZipCode 
		WHEN (CLSL.intCompanyLocationSubLocationId IS NOT NULL) THEN CLSL.strZipCode 
		ELSE CL.strZipPostalCode END
	,dblFromLongitude = CASE WHEN (DOD.intVendorId IS NOT NULL) THEN VL.dblLongitude 
		WHEN (CLSL.intCompanyLocationSubLocationId IS NOT NULL) THEN CLSL.dblLongitude 
		ELSE CL.dblLongitude END
	,dblFromLatitude = CASE WHEN (DOD.intVendorId IS NOT NULL) THEN VL.dblLatitude 
		WHEN (CLSL.intCompanyLocationSubLocationId IS NOT NULL) THEN CLSL.dblLatitude 
		ELSE CL.dblLatitude END
	,strEntityName = CASE WHEN (DOD.strOrderType IN ('Outbound', 'Sales') AND DOD.intStopType = 1) OR (DOD.strOrderType IN ('Transfer')) THEN CL.strLocationName ELSE E.strName END
	,strLocationName = CASE WHEN (DOD.strOrderType IN ('Outbound', 'Sales') AND DOD.intStopType = 1) OR (DOD.strOrderType IN ('Transfer')) THEN CLSL.strSubLocationName ELSE EL.strLocationName END
	,strSiteID = RIGHT('000'+ CAST(TMS.intSiteNumber AS NVARCHAR(4)),4) COLLATE Latin1_General_CI_AS
	,intTMCustomerId = TMS.intCustomerID
	,DOD.strEntityContact
	,strAddress = DOD.strAddress
	,strCity = DOD.strCity
	,strState = DOD.strState
	,strCountry = DOD.strCountry
	,strZipCode = DOD.strZipCode
	,dblLongitude = DOD.dblLongitude
	,dblLatitude = DOD.dblLatitude
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
	,DOD.intSalespersonId
	,strSalesperson = SP.strName
	,DOD.strLoadRef
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
LEFT JOIN tblTFTerminalControlNumber TCN ON TCN.intTerminalControlNumberId = DOD.intTerminalControlNumberId
LEFT JOIN tblEMEntity SP ON SP.intEntityId = DOD.intSalespersonId
