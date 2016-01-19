CREATE PROCEDURE [dbo].[uspLGGetCarrierShipmentReport]
		@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @intLoadNumber			INT,
			@xmlDocumentId			INT 
	
	DECLARE @strHaulerAddress NVARCHAR(MAX), @strHaulerCity NVARCHAR(MAX), @strHaulerCountry NVARCHAR(MAX), @strHaulerState NVARCHAR(MAX), @strHaulerZip NVARCHAR(MAX)

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

	SELECT
		@strHaulerAddress = (SELECT EL.strAddress from tblEntityLocation EL JOIN tblEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerCity = (SELECT EL.strCity from tblEntityLocation EL JOIN tblEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerCountry = (SELECT EL.strCountry from tblEntityLocation EL JOIN tblEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerState = (SELECT EL.strState from tblEntityLocation EL JOIN tblEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerZip = (SELECT EL.strZipCode from tblEntityLocation EL JOIN tblEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId)
	FROM vyuLGLoadView L WHERE L.intLoadNumber = @intLoadNumber

SELECT DISTINCT 
		(SELECT TOP(1) C.strCompanyName FROM tblSMCompanySetup C) as strCompanyName,
		(SELECT TOP(1) C.strAddress FROM tblSMCompanySetup C) as strCompanyAddress,
		(SELECT TOP(1) C.strCountry FROM tblSMCompanySetup C) as strCompanyCountry,
		(SELECT TOP(1) C.strCity FROM tblSMCompanySetup C) as strCompanyCity,
		(SELECT TOP(1) C.strState FROM tblSMCompanySetup C) as strCompanyState,
		(SELECT TOP(1) C.strZip FROM tblSMCompanySetup C) as strCompanyZip,

		L.intLoadNumber,
		L.strEquipmentType,
		L.dtmScheduledDate,
		L.strComments,
		L.strExternalLoadNumber,
		L.strCustomerReference,	
		L.strHauler,
		strHaulerFullAddress = LTRIM(RTRIM(L.strHauler)) + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(LTRIM(RTRIM(@strHaulerAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(LTRIM(RTRIM(@strHaulerCity)),'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(@strHaulerState)) = '' THEN NULL ELSE LTRIM(RTRIM(@strHaulerState)) END,'') + 
									ISNULL(' '+CASE WHEN LTRIM(RTRIM(@strHaulerZip)) = '' THEN NULL ELSE LTRIM(RTRIM(@strHaulerZip)) END,'') + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(''+CASE WHEN LTRIM(RTRIM(@strHaulerCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(@strHaulerCountry)) END,''),
		L.strDriver,
		L.dtmDispatchedDate,
		L.strDispatcher,
		L.strTrailerNo1,
		L.strTrailerNo2,
		L.strTrailerNo3,
		L.strTruckNo
	FROM vyuLGLoadView L WHERE L.intLoadNumber = @intLoadNumber
END
