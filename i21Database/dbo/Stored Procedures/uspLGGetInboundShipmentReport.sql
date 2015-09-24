CREATE PROCEDURE [dbo].[uspLGGetInboundShipmentReport]
		@xmlParam NVARCHAR(MAX) = NULL  
AS
BEGIN
	DECLARE @intTrackingNumber			INT,
			@xmlDocumentId				INT 
			
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
    
	SELECT	@intTrackingNumber = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intTrackingNumber' 

SELECT 
		SH.intTrackingNumber,
		SH.intDeliveryNoticeNumber,
		SH.dtmDeliveryNoticeDate,
		SH.dtmDeliveryDate,
		SH.intSubLocationId,
		SH.intShippingLineEntityId,
		SH.intTruckerEntityId,
		SH.dtmPickupDate,
		SH.dtmLastFreeDate,
		SH.dtmStrippingReportReceivedDate,
		SH.dtmSampleAuthorizedDate,
		SH.strStrippingReportComments,
		SH.strFreightComments,
		SH.strSampleComments,
		SH.strOtherComments,
		SH.strOriginPort,
		SH.strDestinationPort,
		SH.strDestinationCity,
		SH.dtmETAPOL,
		SH.dtmETAPOD,
		SH.dtmETSPOL,
		SH.strMVessel,
		SH.strFVessel,
		SH.strMVoyageNumber,
		SH.strFVoyageNumber,
		SH.dblInsuranceValue,
		SH.intInsuranceCurrencyId,
		InsuranceCur.strCurrency,

  		SLEntity.strName as strShippingLine,
		SLEntity.strEmail as strShippingLineEmail,
		SLEntity.strFax as strShippingLineFax,
		SLEntity.strPhone as strShippingLinePhone,
		SLEntity.strMobile as strShippingLineMobile,
		SLEntity.strWebsite as strShippingLineWebsite,
		SLLocation.strAddress as strShippingLineAddress,
		SLLocation.strCity as strShippingLineCity,
		SLLocation.strCountry as strShippingLineCountry,
		SLLocation.strState as strShippingLineState,
		SLLocation.strZipCode as strShippingLineZipCode,

		TREntity.strName as strTrucker,
		TREntity.strEmail as strTruckerEmail,
		TREntity.strFax as strTruckerFax,
		TREntity.strPhone as strTruckerPhone,
		TREntity.strMobile as strTruckerMobile,
		TREntity.strWebsite as strTruckerWebsite,
		TRLocation.strAddress as strTruckerAddress,
		TRLocation.strCity as strTruckerCity,
		TRLocation.strCountry as strTruckerCountry,
		TRLocation.strState as strTruckerState,
		TRLocation.strZipCode as strTruckerZipCode,

		TerminalEntity.strName as strTerminal,
		TerminalEntity.strEmail as strTerminalEmail,
		TerminalEntity.strFax as strTerminalFax,
		TerminalEntity.strPhone as strTerminalPhone,
		TerminalEntity.strMobile as strTerminalMobile,
		TerminalEntity.strWebsite as strTerminalWebsite,
		TerminalLocation.strAddress as strTerminalAddress,
		TerminalLocation.strCity as strTerminalCity,
		TerminalLocation.strCountry as strTerminalCountry,
		TerminalLocation.strState as strTerminalState,
		TerminalLocation.strZipCode as strTerminalZipCode,

		InsurEntity.strName as strInsurer,
		InsurEntity.strEmail as strInsurerEmail,
		InsurEntity.strFax as strInsurerFax,
		InsurEntity.strPhone as strInsurerPhone,
		InsurEntity.strMobile as strInsurerMobile,
		InsurEntity.strWebsite as strInsurerWebsite,
		InsurLocation.strAddress as strInsurerAddress,
		InsurLocation.strCity as strInsurerCity,
		InsurLocation.strCountry as strInsurerCountry,
		InsurLocation.strState as strInsurerState,
		InsurLocation.strZipCode as strInsurerZipCode,

		WH.strSubLocationName as strWarehouse,
		WH.strSubLocationDescription as strWarehouseDescription,
		WH.strAddress as strWarehouseAddress,
		WH.strCity as strWarehouseCity,
		WH.strClassification as strWarehouseClassification,
		WH.strState as strWarehouseState,
		WH.strZipCode as strWarehouseZipCode

FROM		tblLGShipment SH
LEFT JOIN	tblEntity SLEntity ON SLEntity.intEntityId = SH.intShippingLineEntityId
LEFT JOIN	tblEntityLocation SLLocation ON SLLocation.intEntityId = SH.intShippingLineEntityId and SLLocation.intEntityLocationId = SLEntity.intDefaultLocationId
LEFT JOIN	tblEntity TREntity ON TREntity.intEntityId = SH.intTruckerEntityId
LEFT JOIN	tblEntityLocation TRLocation ON TRLocation.intEntityId = SH.intTruckerEntityId and TRLocation.intEntityLocationId = TREntity.intDefaultLocationId
LEFT JOIN	tblEntity TerminalEntity ON TerminalEntity.intEntityId = SH.intTerminalEntityId
LEFT JOIN	tblEntityLocation TerminalLocation ON TerminalLocation.intEntityId = SH.intTerminalEntityId and TerminalLocation.intEntityLocationId = TerminalEntity.intDefaultLocationId
LEFT JOIN	tblEntity InsurEntity ON InsurEntity.intEntityId = SH.intInsurerEntityId
LEFT JOIN	tblEntityLocation InsurLocation ON InsurLocation.intEntityId = SH.intInsurerEntityId and InsurLocation.intEntityLocationId = InsurEntity.intDefaultLocationId
LEFT JOIN	tblSMCompanyLocationSubLocation WH ON WH.intCompanyLocationSubLocationId = SH.intSubLocationId
LEFT JOIN	tblSMCurrency InsuranceCur ON InsuranceCur.intCurrencyID = SH.intInsuranceCurrencyId
WHERE SH.intTrackingNumber = @intTrackingNumber
END
