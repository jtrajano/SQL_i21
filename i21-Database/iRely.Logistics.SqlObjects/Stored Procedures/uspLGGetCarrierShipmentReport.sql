CREATE PROCEDURE [dbo].[uspLGGetCarrierShipmentReport]
		@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @strLoadNumber			NVARCHAR(MAX),
			@xmlDocumentId			INT 
	DECLARE @strCompanyName			NVARCHAR(100),
			@strCompanyAddress		NVARCHAR(100),
			@strContactName			NVARCHAR(50),
			@strCounty				NVARCHAR(25),
			@strCity				NVARCHAR(25),
			@strState				NVARCHAR(50),
			@strZip					NVARCHAR(12),
			@strCountry				NVARCHAR(25),
			@strPhone				NVARCHAR(50)
	
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
    
	SELECT	@strLoadNumber = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'strLoadNumber' 

	SELECT TOP 1 @strCompanyName = strCompanyName
		,@strCompanyAddress = strAddress
		,@strContactName = strContactName
		,@strCounty = strCounty
		,@strCity = strCity
		,@strState = strState
		,@strZip = strZip
		,@strCountry = strCountry
		,@strPhone = strPhone
	FROM tblSMCompanySetup

	SELECT
		@strHaulerAddress = (SELECT EL.strAddress from tblEMEntityLocation EL JOIN tblEMEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerCity = (SELECT EL.strCity from tblEMEntityLocation EL JOIN tblEMEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerCountry = (SELECT EL.strCountry from tblEMEntityLocation EL JOIN tblEMEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerState = (SELECT EL.strState from tblEMEntityLocation EL JOIN tblEMEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId),
		@strHaulerZip = (SELECT EL.strZipCode from tblEMEntityLocation EL JOIN tblEMEntity E On E.intDefaultLocationId = EL.intEntityLocationId Where EL.intEntityId=L.intHaulerEntityId)
	FROM vyuLGLoadDetailView L WHERE L.[strLoadNumber] = @strLoadNumber

SELECT DISTINCT 
		L.[strLoadNumber],
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
		L.strTruckNo,
		strCarrierShipmentStandardText = (SELECT TOP 1 strCarrierShipmentStandardText FROM tblLGCompanyPreference),
		@strCompanyName AS strCompanyName,
		@strCompanyAddress AS strCompanyAddress,
		@strContactName AS strCompanyContactName ,
		@strCounty AS strCompanyCounty ,
		@strCity AS strCompanyCity ,
		@strState AS strCompanyState ,
		@strZip AS strCompanyZip ,
		@strCountry AS strCompanyCountry ,
		@strPhone AS strCompanyPhone,
		@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCityStateZip
	FROM vyuLGLoadDetailView L WHERE L.[strLoadNumber] = @strLoadNumber
END
