CREATE PROCEDURE [dbo].[uspLGGetShippingInstructionReport]
		@xmlParam NVARCHAR(MAX) = NULL  
AS
BEGIN
	DECLARE @intLoadId			INT,
			@xmlDocumentId		INT 
	DECLARE @strCompanyName				NVARCHAR(100),
			@strCompanyAddress			NVARCHAR(100),
			@strContactName				NVARCHAR(50),
			@strCounty					NVARCHAR(25),
			@strCity					NVARCHAR(25),
			@strState					NVARCHAR(50),
			@strZip						NVARCHAR(12),
			@strCountry					NVARCHAR(25),
			@strPhone					NVARCHAR(50)
						
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
    
	SELECT	@intLoadId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intLoadId' 

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

SELECT TOP 1 L.intLoadId
	,L.dtmScheduledDate
	,L.strLoadNumber
	,L.dtmBLDate
	,L.dtmDeliveredDate
	,Vendor.strName AS strVendor
	,Customer.strName AS strCustomer
	,L.strOriginPort
	,L.strDestinationPort
	,SLEntity.strName AS strShippingLine
	,L.strServiceContractNumber
	,L.strPackingDescription
	,L.intNumberOfContainers
	,ContType.strContainerType
	,L.strShippingMode
	,L.strMVessel
	,L.strMVoyageNumber
	,ForAgent.strName AS strForwardingAgent
	,BLDraft.strName AS strBLDraftToBeSent
	,L.strDocPresentationType
	,CASE 
		WHEN L.strDocPresentationType = 'Bank'
			THEN Bank.strBankName
		WHEN L.strDocPresentationType = 'Forwarding Agent'
			THEN DocPres.strName
		ELSE ''
		END AS strDocPresentationVal
	,L.dtmETAPOL
	,L.dtmETAPOD
	,L.dtmETSPOL
	,L.dtmDeadlineBL
	,L.dtmDeadlineCargo
	,L.dtmISFFiledDate
	,L.dtmISFReceivedDate
	,FLNP.strText AS strFirstNotifyText
	,SLNP.strText AS strSecondNotifyText
	,CLNP.strText AS strConsigneeText
	,CASE FLNP.strType
		WHEN 'Bank'
			THEN FirstNotifyBank.strBankName
		WHEN 'Company'
			THEN FirstNotifyCompany.strCompanyName
		WHEN 'Vendor'
			THEN FirstNotify.strName
		END strFirstNotify
	,CASE FLNP.strType
		WHEN 'Bank'
			THEN FirstNotifyBank.strEmail
		WHEN 'Company'
			THEN FirstNotifyCompany.strEmail
		WHEN 'Vendor'
			THEN FirstNotify.strEmail
		END strFirstNotifyMail
	,CASE FLNP.strType
		WHEN 'Bank'
			THEN FirstNotifyBank.strFax
		WHEN 'Company'
			THEN FirstNotifyCompany.strFax
		WHEN 'Vendor'
			THEN FirstNotify.strFax
		END strFirstNotifyFax
	,CASE FLNP.strType
		WHEN 'Bank'
			THEN ''
		WHEN 'Company'
			THEN ''
		WHEN 'Vendor'
			THEN FirstNotify.strMobile
		END strFirstNotifyMobile
	,CASE FLNP.strType
		WHEN 'Bank'
			THEN FirstNotifyBank.strPhone
		WHEN 'Company'
			THEN FirstNotifyCompany.strPhone
		WHEN 'Vendor'
			THEN FirstNotify.strPhone
		END strFirstNotifyPhone
	,CASE FLNP.strType
		WHEN 'Bank'
			THEN FirstNotifyBank.strAddress
		WHEN 'Company'
			THEN FirstNotifyCompany.strAddress
		WHEN 'Vendor'
			THEN FNLocation.strAddress
		END strFirstNotifyAddress
	,CASE FLNP.strType
		WHEN 'Bank'
			THEN FirstNotifyBank.strCity
		WHEN 'Company'
			THEN FirstNotifyCompany.strCity
		WHEN 'Vendor'
			THEN FNLocation.strCity
		END strFirstNotifyCity
	,CASE FLNP.strType
		WHEN 'Bank'
			THEN FirstNotifyBank.strCountry
		WHEN 'Company'
			THEN FirstNotifyCompany.strCountry
		WHEN 'Vendor'
			THEN FNLocation.strCountry
		END strFirstNotifyCountry
	,CASE FLNP.strType
		WHEN 'Bank'
			THEN FirstNotifyBank.strState
		WHEN 'Company'
			THEN FirstNotifyCompany.strState
		WHEN 'Vendor'
			THEN FNLocation.strState
		END strFirstNotifyState
	,CASE FLNP.strType
		WHEN 'Bank'
			THEN FirstNotifyBank.strZipCode
		WHEN 'Company'
			THEN FirstNotifyCompany.strZip
		WHEN 'Vendor'
			THEN FNLocation.strZipCode
		END strFirstNotifyZipCode
	,CASE SLNP.strType
		WHEN 'Bank'
			THEN SecondNotifyBank.strBankName
		WHEN 'Company'
			THEN SecondNotifyCompany.strCompanyName
		WHEN 'Vendor'
			THEN SecondNotify.strName
		END strSecondNotify
	,CASE SLNP.strType
		WHEN 'Bank'
			THEN SecondNotifyBank.strEmail
		WHEN 'Company'
			THEN SecondNotifyCompany.strEmail
		WHEN 'Vendor'
			THEN SecondNotify.strEmail
		END strSecondNotifyMail
	,CASE SLNP.strType
		WHEN 'Bank'
			THEN SecondNotifyBank.strFax
		WHEN 'Company'
			THEN SecondNotifyCompany.strFax
		WHEN 'Vendor'
			THEN SecondNotify.strFax
		END strSecondNotifyFax
	,CASE SLNP.strType
		WHEN 'Bank'
			THEN ''
		WHEN 'Company'
			THEN ''
		WHEN 'Vendor'
			THEN SecondNotify.strMobile
		END strSecondNotifyMobile
	,CASE SLNP.strType
		WHEN 'Bank'
			THEN SecondNotifyBank.strPhone
		WHEN 'Company'
			THEN SecondNotifyCompany.strPhone
		WHEN 'Vendor'
			THEN SecondNotify.strPhone
		END strSecondNotifyPhone
	,CASE SLNP.strType
		WHEN 'Bank'
			THEN SecondNotifyBank.strAddress
		WHEN 'Company'
			THEN SecondNotifyCompany.strAddress
		WHEN 'Vendor'
			THEN SNLocation.strAddress
		END strSecondNotifyAddress
	,CASE SLNP.strType
		WHEN 'Bank'
			THEN SecondNotifyBank.strCity
		WHEN 'Company'
			THEN SecondNotifyCompany.strCity
		WHEN 'Vendor'
			THEN SNLocation.strCity
		END strSecondNotifyCity
	,CASE SLNP.strType
		WHEN 'Bank'
			THEN SecondNotifyBank.strCountry
		WHEN 'Company'
			THEN SecondNotifyCompany.strCountry
		WHEN 'Vendor'
			THEN SNLocation.strCountry
		END strSecondNotifyCountry
	,CASE SLNP.strType
		WHEN 'Bank'
			THEN SecondNotifyBank.strState
		WHEN 'Company'
			THEN SecondNotifyCompany.strState
		WHEN 'Vendor'
			THEN SNLocation.strState
		END strSecondNotifyState
	,CASE SLNP.strType
		WHEN 'Bank'
			THEN SecondNotifyBank.strZipCode
		WHEN 'Company'
			THEN SecondNotifyCompany.strZip
		WHEN 'Vendor'
			THEN SNLocation.strZipCode
		END strSecondNotifyZipCode
	,CASE CLNP.strType
		WHEN 'Bank'
			THEN ConsigneeNotifyBank.strBankName
		WHEN 'Company'
			THEN ConsigneeNotifyCompany.strCompanyName
		WHEN 'Vendor'
			THEN ConsigneeNotify.strName
		END strConsignee
	,CASE CLNP.strType
		WHEN 'Bank'
			THEN ConsigneeNotifyBank.strEmail
		WHEN 'Company'
			THEN ConsigneeNotifyCompany.strEmail
		WHEN 'Vendor'
			THEN ConsigneeNotify.strEmail
		END strConsigneeMail
	,CASE CLNP.strType
		WHEN 'Bank'
			THEN ConsigneeNotifyBank.strFax
		WHEN 'Company'
			THEN ConsigneeNotifyCompany.strFax
		WHEN 'Vendor'
			THEN ConsigneeNotify.strFax
		END strConsigneeFax
	,CASE CLNP.strType
		WHEN 'Bank'
			THEN ''
		WHEN 'Company'
			THEN ''
		WHEN 'Vendor'
			THEN ConsigneeNotify.strMobile
		END strConsigneeMobile
	,CASE CLNP.strType
		WHEN 'Bank'
			THEN ConsigneeNotifyBank.strPhone
		WHEN 'Company'
			THEN ConsigneeNotifyCompany.strPhone
		WHEN 'Vendor'
			THEN ConsigneeNotify.strPhone
		END strConsigneePhone
	,CASE CLNP.strType
		WHEN 'Bank'
			THEN ConsigneeNotifyBank.strAddress
		WHEN 'Company'
			THEN ConsigneeNotifyCompany.strAddress
		WHEN 'Vendor'
			THEN CNLocation.strAddress
		END strConsigneeAddress
	,CASE CLNP.strType
		WHEN 'Bank'
			THEN ConsigneeNotifyBank.strCity
		WHEN 'Company'
			THEN ConsigneeNotifyCompany.strCity
		WHEN 'Vendor'
			THEN CNLocation.strCity
		END strConsigneeCity
	,CASE CLNP.strType
		WHEN 'Bank'
			THEN ConsigneeNotifyBank.strCountry
		WHEN 'Company'
			THEN ConsigneeNotifyCompany.strCountry
		WHEN 'Vendor'
			THEN CNLocation.strCountry
		END strConsigneeCountry
	,CASE CLNP.strType
		WHEN 'Bank'
			THEN ConsigneeNotifyBank.strState
		WHEN 'Company'
			THEN ConsigneeNotifyCompany.strState
		WHEN 'Vendor'
			THEN CNLocation.strState
		END strConsigneeState
	,CASE CLNP.strType
		WHEN 'Bank'
			THEN ConsigneeNotifyBank.strZipCode
		WHEN 'Company'
			THEN ConsigneeNotifyCompany.strZip
		WHEN 'Vendor'
			THEN CNLocation.strZipCode
		END strConsigneeZipCode
	,LC.strMarks
	,L.strMarkingInstructions
	,L.strComments
	,L.dblDemurrage
	,DemCurrency.strCurrency AS strDemurrageCurrency
	,L.dblDespatch
	,DesCurrency.strCurrency AS strDespatchCurrency
	,L.dblLoadingRate
	,L.dblDischargeRate
	,LoadUnit.strUnitMeasure AS strLoadingUnit
	,DisUnit.strUnitMeasure AS strDischargeUnit
	,L.strLoadingPerUnit
	,L.strDischargePerUnit
	,dbo.fnSMGetCompanyLogo('Header') AS blbHeaderLogo
	,@strCompanyName AS strCompanyName
	,@strCompanyAddress AS strCompanyAddress
	,@strContactName AS strCompanyContactName 
	,@strCounty AS strCompanyCounty 
	,@strCity AS strCompanyCity 
	,@strState AS strCompanyState 
	,@strZip AS strCompanyZip 
	,@strCountry AS strCompanyCountry 
	,@strPhone AS strCompanyPhone 

FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
LEFT JOIN tblLGLoadContainer LC ON L.intLoadId = LC.intLoadId
LEFT JOIN tblLGLoadNotifyParties LNP ON LNP.intLoadId = L.intLoadId
LEFT JOIN tblEMEntity Vendor ON Vendor.intEntityId = LD.intVendorEntityId
LEFT JOIN tblEMEntity Customer ON Customer.intEntityId = LD.intCustomerEntityId
LEFT JOIN tblEMEntity SLEntity ON SLEntity.intEntityId = L.intShippingLineEntityId
LEFT JOIN tblLGContainerType ContType ON ContType.intContainerTypeId = L.intContainerTypeId
LEFT JOIN tblEMEntity ForAgent ON ForAgent.intEntityId = L.intForwardingAgentEntityId
LEFT JOIN tblEMEntity BLDraft ON BLDraft.intEntityId = L.intBLDraftToBeSentId
LEFT JOIN tblEMEntity DocPres ON DocPres.intEntityId = L.intDocPresentationId
LEFT JOIN tblCMBank Bank ON Bank.intBankId = L.intDocPresentationId
LEFT JOIN tblLGLoadNotifyParties FLNP ON L.intLoadId = FLNP.intLoadId AND FLNP.strNotifyOrConsignee = 'First Notify'
LEFT JOIN tblLGLoadNotifyParties SLNP ON L.intLoadId = SLNP.intLoadId AND SLNP.strNotifyOrConsignee = 'Second Notify'
LEFT JOIN tblLGLoadNotifyParties CLNP ON L.intLoadId = CLNP.intLoadId AND CLNP.strNotifyOrConsignee = 'Consignee'
LEFT JOIN tblEMEntity FirstNotify ON FirstNotify.intEntityId = FLNP.intEntityId
LEFT JOIN tblCMBank FirstNotifyBank ON FirstNotifyBank.intBankId = FLNP.intBankId
LEFT JOIN tblSMCompanySetup FirstNotifyCompany ON FirstNotifyCompany.intCompanySetupID = FLNP.intCompanySetupID
LEFT JOIN tblEMEntityLocation FNLocation ON FNLocation.intEntityLocationId = FLNP.intEntityLocationId
LEFT JOIN tblEMEntity SecondNotify ON SecondNotify.intEntityId = SLNP.intEntityId
LEFT JOIN tblCMBank SecondNotifyBank ON SecondNotifyBank.intBankId = SLNP.intBankId
LEFT JOIN tblSMCompanySetup SecondNotifyCompany ON SecondNotifyCompany.intCompanySetupID = SLNP.intCompanySetupID
LEFT JOIN tblEMEntityLocation SNLocation ON SNLocation.intEntityLocationId = SLNP.intEntityLocationId
LEFT JOIN tblEMEntity ConsigneeNotify ON ConsigneeNotify.intEntityId = CLNP.intEntityId
LEFT JOIN tblCMBank ConsigneeNotifyBank ON ConsigneeNotifyBank.intBankId = CLNP.intBankId
LEFT JOIN tblSMCompanySetup ConsigneeNotifyCompany ON ConsigneeNotifyCompany.intCompanySetupID = CLNP.intCompanySetupID
LEFT JOIN tblEMEntityLocation CNLocation ON CNLocation.intEntityLocationId = CLNP.intEntityLocationId
LEFT JOIN tblSMCurrency DemCurrency ON DemCurrency.intCurrencyID = L.intDemurrageCurrencyId
LEFT JOIN tblSMCurrency DesCurrency ON DesCurrency.intCurrencyID = L.intDespatchCurrencyId
LEFT JOIN tblICUnitMeasure LoadUnit ON LoadUnit.intUnitMeasureId = L.intLoadingUnitMeasureId
LEFT JOIN tblICUnitMeasure DisUnit ON DisUnit.intUnitMeasureId = L.intDischargeUnitMeasureId
WHERE L.intLoadId = @intLoadId
END
