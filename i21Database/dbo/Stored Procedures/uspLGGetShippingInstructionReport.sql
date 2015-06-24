CREATE PROCEDURE [dbo].[uspLGGetShippingInstructionReport]
		@xmlParam NVARCHAR(MAX) = NULL  
AS
BEGIN
	DECLARE @intReferenceNumber			INT,
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
    
	SELECT	@intReferenceNumber = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intReferenceNumber' 

SELECT 
		SI.intReferenceNumber,
		SI.dtmSIDate,
		SI.strBookingNumber,
		SI.dtmBookingDate,
		SI.dtmShipmentDate,
		SI.strOriginPort,
		SI.strDestinationPort,
		SLEntity.strName as strShippingLine,
		SI.strViaCity,
		THEntity.strName as strThrough,
		SI.strPackingDescription,
		SI.intNumberOfContainers,
		ContType.strContainerType,
		SI.strShippingMode,
		SI.strVessel,
		SI.strVoyageNumber,
		ForAgent.strName as strForwardingAgent,
		BLDraft.strName as strBLDraftToBeSent,
		SI.strDocPresentationType,
		CASE WHEN SI.strDocPresentationType = 'Bank' THEN Bank.strBankName WHEN SI.strDocPresentationType = 'Forwarding Agent' THEN DocPres.strName ELSE '' END as strDocPresentationVal,
		SI.dtmETAPOL,
		SI.dtmETAPOD,
		SI.dtmETSPOL,
		SI.dtmDeadlineBL,
		SI.dtmDeadlineCargo,
		SI.dtmISFFiledDate,
		SI.dtmISFReceivedDate,
		SI.strContactPerson,
		SI.strFirstNotifyText,
		SI.strSecondNotifyText,
		SI.strConsigneeText,
		CASE	WHEN SI.strFirstNotifyType = 'Customer' or SI.strFirstNotifyType = 'Forwarding Agent' THEN FirstNotify.strName
				WHEN SI.strFirstNotifyType = 'Bank' Then FirstNotifyBank.strBankName
				WHEN SI.strFirstNotifyType = 'Company' Then FirstNotifyCompany.strCompanyName
				END as strFirstNotify,
		CASE	WHEN SI.strFirstNotifyType = 'Customer' or SI.strFirstNotifyType = 'Forwarding Agent' THEN FirstNotify.strEmail
				WHEN SI.strFirstNotifyType = 'Bank' Then FirstNotifyBank.strEmail
				WHEN SI.strFirstNotifyType = 'Company' Then FirstNotifyCompany.strEmail
				END as strFirstNotifyMail,
		CASE	WHEN SI.strFirstNotifyType = 'Customer' or SI.strFirstNotifyType = 'Forwarding Agent' THEN FirstNotify.strFax
				WHEN SI.strFirstNotifyType = 'Bank' Then FirstNotifyBank.strFax
				WHEN SI.strFirstNotifyType = 'Company' Then FirstNotifyCompany.strFax
				END as strFirstNotifyFax,
		CASE	WHEN SI.strFirstNotifyType = 'Customer' or SI.strFirstNotifyType = 'Forwarding Agent' THEN FirstNotify.strMobile
				WHEN SI.strFirstNotifyType = 'Bank' Then ''
				WHEN SI.strFirstNotifyType = 'Company' Then ''
				END as strFirstNotifyMobile,
		CASE	WHEN SI.strFirstNotifyType = 'Customer' or SI.strFirstNotifyType = 'Forwarding Agent' THEN FirstNotify.strPhone
				WHEN SI.strFirstNotifyType = 'Bank' Then FirstNotifyBank.strPhone
				WHEN SI.strFirstNotifyType = 'Company' Then FirstNotifyCompany.strPhone
				END as strFirstNotifyPhone,
		CASE	WHEN SI.strFirstNotifyType = 'Customer' or SI.strFirstNotifyType = 'Forwarding Agent' THEN FNLocation.strAddress
				WHEN SI.strFirstNotifyType = 'Bank' Then FirstNotifyBank.strAddress
				WHEN SI.strFirstNotifyType = 'Company' Then FirstNotifyCompany.strAddress
				END as strFirstNotifyAddress,
		CASE	WHEN SI.strFirstNotifyType = 'Customer' or SI.strFirstNotifyType = 'Forwarding Agent' THEN FNLocation.strCity
				WHEN SI.strFirstNotifyType = 'Bank' Then FirstNotifyBank.strCity
				WHEN SI.strFirstNotifyType = 'Company' Then FirstNotifyCompany.strCity
				END as strFirstNotifyCity,
		CASE	WHEN SI.strFirstNotifyType = 'Customer' or SI.strFirstNotifyType = 'Forwarding Agent' THEN FNLocation.strCountry
				WHEN SI.strFirstNotifyType = 'Bank' Then FirstNotifyBank.strCountry
				WHEN SI.strFirstNotifyType = 'Company' Then FirstNotifyCompany.strCountry
				END as strFirstNotifyCountry,
		CASE	WHEN SI.strFirstNotifyType = 'Customer' or SI.strFirstNotifyType = 'Forwarding Agent' THEN FNLocation.strState
				WHEN SI.strFirstNotifyType = 'Bank' Then FirstNotifyBank.strState
				WHEN SI.strFirstNotifyType = 'Company' Then FirstNotifyCompany.strState
				END as strFirstNotifyState,
		CASE	WHEN SI.strFirstNotifyType = 'Customer' or SI.strFirstNotifyType = 'Forwarding Agent' THEN FNLocation.strZipCode
				WHEN SI.strFirstNotifyType = 'Bank' Then FirstNotifyBank.strZipCode
				WHEN SI.strFirstNotifyType = 'Company' Then FirstNotifyCompany.strZip
				END as strFirstNotifyZipCode,
		CASE	WHEN SI.strSecondNotifyType = 'Customer' or SI.strSecondNotifyType = 'Forwarding Agent' THEN SecondNotify.strName
				WHEN SI.strSecondNotifyType = 'Bank' Then SecondNotifyBank.strBankName
				WHEN SI.strSecondNotifyType = 'Company' Then SecondNotifyCompany.strCompanyName
				END as strSecondNotify,
		CASE	WHEN SI.strSecondNotifyType = 'Customer' or SI.strSecondNotifyType = 'Forwarding Agent' THEN SecondNotify.strEmail
				WHEN SI.strSecondNotifyType = 'Bank' Then SecondNotifyBank.strEmail
				WHEN SI.strSecondNotifyType = 'Company' Then SecondNotifyCompany.strEmail
				END as strSecondNotifyMail,
		CASE	WHEN SI.strSecondNotifyType = 'Customer' or SI.strSecondNotifyType = 'Forwarding Agent' THEN SecondNotify.strFax
				WHEN SI.strSecondNotifyType = 'Bank' Then SecondNotifyBank.strFax
				WHEN SI.strSecondNotifyType = 'Company' Then SecondNotifyCompany.strFax
				END as strSecondNotifyFax,
		CASE	WHEN SI.strSecondNotifyType = 'Customer' or SI.strSecondNotifyType = 'Forwarding Agent' THEN SecondNotify.strMobile
				WHEN SI.strSecondNotifyType = 'Bank' Then ''
				WHEN SI.strSecondNotifyType = 'Company' Then ''
				END as strSecondNotifyMobile,
		CASE	WHEN SI.strSecondNotifyType = 'Customer' or SI.strSecondNotifyType = 'Forwarding Agent' THEN SecondNotify.strPhone
				WHEN SI.strSecondNotifyType = 'Bank' Then SecondNotifyBank.strPhone
				WHEN SI.strSecondNotifyType = 'Company' Then SecondNotifyCompany.strPhone
				END as strSecondNotifyPhone,
		CASE	WHEN SI.strSecondNotifyType = 'Customer' or SI.strSecondNotifyType = 'Forwarding Agent' THEN SNLocation.strAddress
				WHEN SI.strSecondNotifyType = 'Bank' Then SecondNotifyBank.strAddress
				WHEN SI.strSecondNotifyType = 'Company' Then SecondNotifyCompany.strAddress
				END as strSecondNotifyAddress,
		CASE	WHEN SI.strSecondNotifyType = 'Customer' or SI.strSecondNotifyType = 'Forwarding Agent' THEN SNLocation.strCity
				WHEN SI.strSecondNotifyType = 'Bank' Then SecondNotifyBank.strCity
				WHEN SI.strSecondNotifyType = 'Company' Then SecondNotifyCompany.strCity
				END as strSecondNotifyCity,
		CASE	WHEN SI.strSecondNotifyType = 'Customer' or SI.strSecondNotifyType = 'Forwarding Agent' THEN SNLocation.strCountry
				WHEN SI.strSecondNotifyType = 'Bank' Then SecondNotifyBank.strCountry
				WHEN SI.strSecondNotifyType = 'Company' Then SecondNotifyCompany.strCountry
				END as strSecondNotifyCountry,
		CASE	WHEN SI.strSecondNotifyType = 'Customer' or SI.strSecondNotifyType = 'Forwarding Agent' THEN SNLocation.strState
				WHEN SI.strSecondNotifyType = 'Bank' Then SecondNotifyBank.strState
				WHEN SI.strSecondNotifyType = 'Company' Then SecondNotifyCompany.strState
				END as strSecondNotifyState,
		CASE	WHEN SI.strSecondNotifyType = 'Customer' or SI.strSecondNotifyType = 'Forwarding Agent' THEN SNLocation.strZipCode
				WHEN SI.strSecondNotifyType = 'Bank' Then SecondNotifyBank.strZipCode
				WHEN SI.strSecondNotifyType = 'Company' Then SecondNotifyCompany.strZip
				END as strSecondNotifyZipCode,
		CASE	WHEN SI.strConsigneeType = 'Customer' or SI.strConsigneeType = 'Forwarding Agent' THEN Consignee.strName
				WHEN SI.strConsigneeType = 'Bank' Then ConsigneeBank.strBankName
				WHEN SI.strConsigneeType = 'Company' Then ConsigneeCompany.strCompanyName
				END as strConsignee,
		CASE	WHEN SI.strConsigneeType = 'Customer' or SI.strConsigneeType = 'Forwarding Agent' THEN Consignee.strEmail
				WHEN SI.strConsigneeType = 'Bank' Then ConsigneeBank.strEmail
				WHEN SI.strConsigneeType = 'Company' Then ConsigneeCompany.strEmail
				END as strConsigneeMail,
		CASE	WHEN SI.strConsigneeType = 'Customer' or SI.strConsigneeType = 'Forwarding Agent' THEN Consignee.strFax
				WHEN SI.strConsigneeType = 'Bank' Then ConsigneeBank.strFax
				WHEN SI.strConsigneeType = 'Company' Then ConsigneeCompany.strFax
				END as strConsigneeFax,
		CASE	WHEN SI.strConsigneeType = 'Customer' or SI.strConsigneeType = 'Forwarding Agent' THEN Consignee.strMobile
				WHEN SI.strConsigneeType = 'Bank' Then ''
				WHEN SI.strConsigneeType = 'Company' Then ''
				END as strConsigneeMobile,
		CASE	WHEN SI.strConsigneeType = 'Customer' or SI.strConsigneeType = 'Forwarding Agent' THEN Consignee.strPhone
				WHEN SI.strConsigneeType = 'Bank' Then ConsigneeBank.strPhone
				WHEN SI.strConsigneeType = 'Company' Then ConsigneeCompany.strPhone
				END as strConsigneePhone,
		CASE	WHEN SI.strConsigneeType = 'Customer' or SI.strConsigneeType = 'Forwarding Agent' THEN CSLocation.strAddress
				WHEN SI.strConsigneeType = 'Bank' Then ConsigneeBank.strAddress
				WHEN SI.strConsigneeType = 'Company' Then ConsigneeCompany.strAddress
				END as strConsigneeAddress,
		CASE	WHEN SI.strConsigneeType = 'Customer' or SI.strConsigneeType = 'Forwarding Agent' THEN CSLocation.strCity
				WHEN SI.strConsigneeType = 'Bank' Then ConsigneeBank.strCity
				WHEN SI.strConsigneeType = 'Company' Then ConsigneeCompany.strCity
				END as strConsigneeCity,
		CASE	WHEN SI.strConsigneeType = 'Customer' or SI.strConsigneeType = 'Forwarding Agent' THEN CSLocation.strCountry
				WHEN SI.strConsigneeType = 'Bank' Then ConsigneeBank.strCountry
				WHEN SI.strConsigneeType = 'Company' Then ConsigneeCompany.strCountry
				END as strConsigneeCountry,
		CASE	WHEN SI.strConsigneeType = 'Customer' or SI.strConsigneeType = 'Forwarding Agent' THEN CSLocation.strState
				WHEN SI.strConsigneeType = 'Bank' Then ConsigneeBank.strState
				WHEN SI.strConsigneeType = 'Company' Then ConsigneeCompany.strState
				END as strConsigneeState,
		CASE	WHEN SI.strConsigneeType = 'Customer' or SI.strConsigneeType = 'Forwarding Agent' THEN CSLocation.strZipCode
				WHEN SI.strConsigneeType = 'Bank' Then ConsigneeBank.strZipCode
				WHEN SI.strConsigneeType = 'Company' Then ConsigneeCompany.strZip
				END as strConsigneeZipCode,
	SI.strMarks,
	SI.strMarkingInstructions,
	SI.strComments,
	SI.dblDemurrage,
	DemCurrency.strCurrency as strDemurrageCurrency,
	SI.dblDespatch,
	DesCurrency.strCurrency as strDespatchCurrency,
	SI.dblLoadingRate,
	SI.dblDischargeRate,
	LoadUnit.strUnitMeasure as strLoadingUnit,
	DisUnit.strUnitMeasure as strDischargeUnit,
	SI.strLoadingPerUnit,
	SI.strDischargePerUnit

FROM		tblLGShippingInstruction SI
LEFT JOIN	tblEntity SLEntity ON SLEntity.intEntityId = SI.intShippingLineEntityId
LEFT JOIN	tblEntity THEntity ON THEntity.intEntityId = SI.intThroughShippingLineEntityId
LEFT JOIN	tblLGContainerType ContType ON ContType.intContainerTypeId = SI.intContainerTypeId
LEFT JOIN	tblEntity ForAgent ON ForAgent.intEntityId = SI.intForwardingAgentEntityId
LEFT JOIN	tblEntity BLDraft ON BLDraft.intEntityId = SI.intBLDraftToBeSentId
LEFT JOIN	tblEntity DocPres ON DocPres.intEntityId = SI.intDocPresentationId
LEFT JOIN	tblCMBank Bank ON Bank.intBankId = SI.intDocPresentationId
LEFT JOIN	tblEntity FirstNotify ON FirstNotify.intEntityId = SI.intFirstNotifyId
LEFT JOIN	tblCMBank FirstNotifyBank ON FirstNotifyBank.intBankId = SI.intFirstNotifyId
LEFT JOIN	tblSMCompanySetup FirstNotifyCompany ON FirstNotifyCompany.intCompanySetupID = SI.intFirstNotifyId
LEFT JOIN	tblEntityLocation FNLocation ON FNLocation.intEntityLocationId = SI.intFirstNotifyLocationId
LEFT JOIN	tblEntity SecondNotify ON SecondNotify.intEntityId = SI.intSecondNotifyId
LEFT JOIN	tblCMBank SecondNotifyBank ON SecondNotifyBank.intBankId = SI.intSecondNotifyId
LEFT JOIN	tblSMCompanySetup SecondNotifyCompany ON SecondNotifyCompany.intCompanySetupID = SI.intSecondNotifyId
LEFT JOIN	tblEntityLocation SNLocation ON SNLocation.intEntityLocationId = SI.intSecondNotifyLocationId
LEFT JOIN	tblEntity Consignee ON Consignee.intEntityId = SI.intConsigneeId
LEFT JOIN	tblCMBank ConsigneeBank ON ConsigneeBank.intBankId = SI.intConsigneeId
LEFT JOIN	tblSMCompanySetup ConsigneeCompany ON ConsigneeCompany.intCompanySetupID = SI.intConsigneeId
LEFT JOIN	tblEntityLocation CSLocation ON CSLocation.intEntityLocationId = SI.intConsigneeLocationId
LEFT JOIN	tblSMCurrency DemCurrency ON DemCurrency.intCurrencyID = SI.intDemurrageCurrencyId
LEFT JOIN	tblSMCurrency DesCurrency ON DesCurrency.intCurrencyID = SI.intDespatchCurrencyId
LEFT JOIN	tblICUnitMeasure LoadUnit ON LoadUnit.intUnitMeasureId = SI.intLoadingUnitMeasureId
LEFT JOIN	tblICUnitMeasure DisUnit ON DisUnit.intUnitMeasureId = SI.intDischargeUnitMeasureId
WHERE SI.intReferenceNumber = @intReferenceNumber
END
