CREATE PROCEDURE [dbo].[uspLGGetCarrierShipmentSubReport]
		@xmlParam NVARCHAR(MAX) = NULL  
AS
DECLARE @intPLoadId INT
DECLARE @intPEntityId INT
DECLARE @intPEntityLocationId INT
DECLARE @intSLoadId INT
DECLARE @intSEntityId INT
DECLARE @intSEntityLocationId INT
BEGIN
	DECLARE @intLoadNumber			INT,
			@xmlDocumentId			INT 
			
	IF	LTRIM(RTRIM(@xmlParam)) = ''   
		SET @xmlParam = NULL   
      
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(50), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)  
  
	EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam  
  
	INSERT INTO @temp_xml_table  
	SELECT	*  
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
	WITH (  
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(50), 
				[to]			NVARCHAR(50),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)  
    
	SELECT	@intLoadNumber = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intLoadNumber' 

	SELECT TOP(1) @intPLoadId = LP.intLoadId, @intPEntityId = LP.intEntityId, @intPEntityLocationId = LP.intEntityLocationId FROM tblLGLoad LP where LP.intLoadNumber=@intLoadNumber and intPurchaseSale=1
	SELECT TOP(1) @intSLoadId = LS.intLoadId, @intSEntityId = LS.intEntityId, @intSEntityLocationId = LS.intEntityLocationId FROM tblLGLoad LS where LS.intLoadNumber=@intLoadNumber and intPurchaseSale=2	

	SELECT DISTINCT
		(SELECT TOP(1) C.strCompanyName FROM tblSMCompanySetup C) as strCompanyName,
		(SELECT TOP(1) C.strAddress FROM tblSMCompanySetup C) as strCompanyAddress,
		(SELECT TOP(1) C.strCountry FROM tblSMCompanySetup C) as strCompanyCountry,
		(SELECT TOP(1) C.strCity FROM tblSMCompanySetup C) as strCompanyCity,
		(SELECT TOP(1) C.strState FROM tblSMCompanySetup C) as strCompanyState,
		(SELECT TOP(1) C.strZip FROM tblSMCompanySetup C) as strCompanyZip,
		L.intLoadNumber,
		CL.strLocationName,
		CL.strAddress as strLocationAddress,
		CL.strCity as strLocationCity,
		CL.strCountry as strLocationCountry,
		CL.strZipPostalCode as strLocationZipCode,
		CL.strPhone as strLocationPhone,
		CL.strFax as strLocationFax,
		CL.strEmail as strLocationMail,
		L.intItemId,
		Item.strItemNo,
		Item.strDescription,
		L.dblQuantity,
		UOM.strUnitMeasure,
		Equipment.strEquipmentType,

		(SELECT L1.dtmScheduledDate FROM tblLGLoad L1 where L1.intLoadId = @intPLoadId) as dtmPickupDate,
		(SELECT L1.dtmScheduledDate FROM tblLGLoad L1 where L1.intLoadId = @intSLoadId) as dtmDeliveryDate,
		(SELECT L1.strCustomerReference FROM tblLGLoad L1 where L1.intLoadId = @intPLoadId) as strVendorReference,
		(SELECT L1.strCustomerReference FROM tblLGLoad L1 where L1.intLoadId = @intSLoadId)  as strCustomerReference,
		(SELECT L1.strComments FROM tblLGLoad L1 where L1.intLoadId = @intPLoadId) as strInboundComments,
		(SELECT L1.strComments FROM tblLGLoad L1 where L1.intLoadId = @intSLoadId)  as strOutboundComments,

		(SELECT E.strName FROM tblEntity E WHERE E.intEntityId = @intPEntityId) as strVendorName,
		(SELECT E.strEntityNo FROM tblEntity E WHERE E.intEntityId = @intPEntityId) as strVendorNo,
		(SELECT E.strEmail FROM tblEntity E WHERE E.intEntityId = @intPEntityId) as strVendorEmail,
		(SELECT E.strFax FROM tblEntity E WHERE E.intEntityId = @intPEntityId) as strVendorFax,
		(SELECT E.strMobile FROM tblEntity E WHERE E.intEntityId = @intPEntityId) as strVendorMobile,
		(SELECT E.strPhone FROM tblEntity E WHERE E.intEntityId = @intPEntityId) as strVendorPhone,
		
		(SELECT EL.strAddress FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intPEntityLocationId) as strVendorAddress,
		(SELECT EL.strCity  FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intPEntityLocationId) as strVendorCity,
		(SELECT EL.strCountry  FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intPEntityLocationId) as strVendorCountry,
		(SELECT EL.strState  FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intPEntityLocationId) as strVendorState,
		(SELECT EL.strZipCode  FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intPEntityLocationId) as strVendorZipCode,

		(SELECT E.strName FROM tblEntity E WHERE E.intEntityId = @intSEntityId) as strCustomerName,
		(SELECT E.strEntityNo FROM tblEntity E WHERE E.intEntityId = @intSEntityId) as strCustomerNo,
		(SELECT E.strEmail FROM tblEntity E WHERE E.intEntityId = @intSEntityId) as strCustomerEmail,
		(SELECT E.strFax FROM tblEntity E WHERE E.intEntityId = @intSEntityId) as strCustomerFax,
		(SELECT E.strMobile FROM tblEntity E WHERE E.intEntityId = @intSEntityId) as strCustomerMobile,
		(SELECT E.strPhone FROM tblEntity E WHERE E.intEntityId = @intSEntityId)as strCustomerPhone,

		(SELECT EL.strAddress FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intSEntityLocationId) as strCustomerAddress,
		(SELECT EL.strCity FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intSEntityLocationId) as strCustomerCity,
		(SELECT EL.strCountry FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intSEntityLocationId) as strCustomerCountry,
		(SELECT EL.strState FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intSEntityLocationId) as strCustomerState,
		(SELECT EL.strZipCode FROM tblEntityLocation EL WHERE EL.intEntityLocationId = @intSEntityLocationId) as strCustomerZipCode,
		
		L.intHaulerEntityId,
		Hauler.strName as strHauler,
		(SELECT EL.strAddress from tblEntityLocation EL JOIN tblEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId) as strHaulerAddress,
		(SELECT EL.strCity from tblEntityLocation EL JOIN tblEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId) as strHaulerCity,
		(SELECT EL.strCountry from tblEntityLocation EL JOIN tblEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId) as strHaulerCountry,
		(SELECT EL.strState from tblEntityLocation EL JOIN tblEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId) as strHaulerState,
		(SELECT EL.strZipCode from tblEntityLocation EL JOIN tblEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId) as strHaulerZip,
		(SELECT EL.strPhone from tblEntityLocation EL JOIN tblEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId) as strHaulerPhone

	FROM		tblLGLoad L
	JOIN		tblSMCompanyLocation	CL ON				CL.intCompanyLocationId = L.intCompanyLocationId AND L.intLoadNumber = @intLoadNumber
	JOIN		tblICItem				Item ON				Item.intItemId = L.intItemId
	JOIN		tblICUnitMeasure		UOM	ON				UOM.intUnitMeasureId = L.intUnitMeasureId
	JOIN		tblEntity				E	On				E.intEntityId = L.intEntityId
	JOIN		tblEntityLocation		EL	On				EL.intEntityLocationId = L.intEntityLocationId
	JOIN		tblEntity				Hauler	On			Hauler.intEntityId = L.intHaulerEntityId
	LEFT JOIN	tblLGEquipmentType		Equipment On		Equipment.intEquipmentTypeId = L.intEquipmentTypeId
END
