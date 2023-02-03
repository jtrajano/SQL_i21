CREATE VIEW [dbo].[vyuLGDispatchOrder]
AS
SELECT
	DO.intDispatchOrderId
	,DO.strDispatchOrderNumber
	,DO.dtmDispatchDate
	,DO.intEntityShipViaId
	,DO.intEntityShipViaTruckId
	,DO.intEntityShipViaTrailerId
	,DO.intDriverEntityId
	,DO.intDispatchStatus
	,DO.strComments
	,DO.intConcurrencyId
	,DO.intSourceType
	,DO.intOriginType
	,DO.intVendorId
	,DO.intVendorLocationId
	,DO.intTerminalControlNumberId
	,DO.intCompanyLocationId
	,DO.intCompanyLocationSubLocationId
	,DO.intSellerId
	,strSeller = SL.strName
	,DO.intSalespersonId
	,strSalesperson = SA.strName
	,DO.strLoadRef
	,strOriginType = CASE (DO.intOriginType) 
		WHEN 1 THEN 'Location' 
		ELSE 'Terminal' END COLLATE Latin1_General_CI_AS
	,strVendor = V.strName
	,strVendorLocation = VL.strLocationName
	,strTerminalName = TCN.strName
	,strTerminalControlNumber = TCN.strTerminalControlNumber
	,strCompanyLocation = CL.strLocationName
	,strSubLocation = CLSL.strSubLocationName
	,strPickUpLocation = CASE WHEN (DO.intOriginType = 1) THEN CL.strLocationName ELSE VL.strLocationName END
	,strFromAddress = CASE WHEN (DO.intVendorId IS NOT NULL) THEN VL.strAddress 
		WHEN (CLSL.intCompanyLocationSubLocationId IS NOT NULL) THEN CLSL.strAddress 
		ELSE CL.strAddress END
	,strFromCity = CASE WHEN (DO.intVendorId IS NOT NULL) THEN VL.strCity 
		WHEN (CLSL.intCompanyLocationSubLocationId IS NOT NULL) THEN CLSL.strCity 
		ELSE CL.strCity END
	,strFromState = CASE WHEN (DO.intVendorId IS NOT NULL) THEN VL.strState 
		WHEN (CLSL.intCompanyLocationSubLocationId IS NOT NULL) THEN CLSL.strState 
		ELSE CL.strStateProvince END
	,strFromCountry = CASE WHEN (DO.intVendorId IS NOT NULL) THEN VL.strCountry  
		ELSE CL.strCountry END
	,strFromZipCode = CASE WHEN (DO.intVendorId IS NOT NULL) THEN VL.strZipCode 
		WHEN (CLSL.intCompanyLocationSubLocationId IS NOT NULL) THEN CLSL.strZipCode 
		ELSE CL.strZipPostalCode END
	,dblFromLongitude = CASE WHEN (DO.intVendorId IS NOT NULL) THEN VL.dblLongitude 
		WHEN (CLSL.intCompanyLocationSubLocationId IS NOT NULL) THEN CLSL.dblLongitude 
		ELSE CL.dblLongitude END
	,dblFromLatitude = CASE WHEN (DO.intVendorId IS NOT NULL) THEN VL.dblLatitude 
		WHEN (CLSL.intCompanyLocationSubLocationId IS NOT NULL) THEN CLSL.dblLatitude 
		ELSE CL.dblLatitude END
	,strShipVia = SV.strName
	,strDriver = DV.strName
	,strTruckNumber = SVT.strTruckNumber
	,strTrailerNumber = SVTL.strTrailerNumber
	,strTrailerDescription = SVTL.strTrailerDescription
	,strTrailerType = SVTL.strType
	,strTrailerStatus = SVTL.strTrailerStatus
	,dblMaxWeight = DO.dblMaxWeight
	,dblLoadWeight = DO.dblLoadWeight
	,strDispatchStatus = CASE (DO.intDispatchStatus) 
		WHEN 0 THEN 'Created'
		WHEN 1 THEN 'Routed'
		WHEN 2 THEN 'Scheduled'
		WHEN 3 THEN 'Dispatched'
		WHEN 4 THEN 'In Progress'
		WHEN 5 THEN 'Complete'
		WHEN 6 THEN 'Cancelled'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,strSourceType = CASE (DO.intSourceType)
		WHEN 1 THEN 'LG Loads - Outbound'
		WHEN 2 THEN 'TM Orders'
		WHEN 3 THEN 'LG Loads - Inbound'
		WHEN 4 THEN 'TM Sites'
		WHEN 5 THEN 'Entities'
		WHEN 6 THEN 'Sales/Transfer Orders'
		ELSE '' END COLLATE Latin1_General_CI_AS
FROM tblLGDispatchOrder DO
	LEFT JOIN tblEMEntity SV ON SV.intEntityId = DO.intEntityShipViaId
	LEFT JOIN tblEMEntity DV ON DV.intEntityId = DO.intDriverEntityId
	LEFT JOIN tblEMEntity SL ON SL.intEntityId = DO.intSellerId
	LEFT JOIN tblEMEntity SA ON SA.intEntityId = DO.intSalespersonId
	LEFT JOIN tblSMShipViaTruck SVT ON SVT.intEntityShipViaTruckId = DO.intEntityShipViaTruckId
	LEFT JOIN tblSMShipViaTrailer SVTL ON SVTL.intEntityShipViaTrailerId = DO.intEntityShipViaTrailerId
	LEFT JOIN tblEMEntity V ON V.intEntityId = DO.intVendorId
	LEFT JOIN tblEMEntityLocation VL ON VL.intEntityLocationId = DO.intVendorLocationId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = DO.intCompanyLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = DO.intCompanyLocationSubLocationId
	LEFT JOIN tblTRSupplyPoint SP ON SP.intEntityLocationId = VL.intEntityLocationId
	LEFT JOIN tblTFTerminalControlNumber TCN ON TCN.intTerminalControlNumberId = SP.intTerminalControlNumberId
GO