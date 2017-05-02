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
			@strPhone					NVARCHAR(50),
			@strFullName				NVARCHAR(100),
			@strUserName				NVARCHAR(100),
			@strLogisticsCompanyName	NVARCHAR(MAX),
			@strLogisticsPrintSignOff	NVARCHAR(MAX),
			@intCompanyLocationId		INT,
			@strPrintableRemarks		NVARCHAR(MAX),
			@strContractText			NVARCHAR(MAX),
			@strBOLInstructionText		NVARCHAR(MAX),
			@strContainerPackType		NVARCHAR(100),
			@strPackingDescription		NVARCHAR(100),
			@strUserPhoneNo				NVARCHAR(100),
			@strUserEmailId				NVARCHAR(100),
			@strContainerQtyUOM			NVARCHAR(100),
			@strPackingUOM				NVARCHAR(100)

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
    
	SELECT	@strUserName = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'strUserName' 

	SELECT	@intCompanyLocationId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intCompanyLocationId' 

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
	
	SELECT @strFullName = E.strName,
		   @strUserEmailId = ETC.strEmail,
		   @strUserPhoneNo = EPN.strPhone  FROM tblSMUserSecurity S
	JOIN tblEMEntity E ON E.intEntityId = S.intEntityUserSecurityId 
	JOIN tblEMEntityToContact EC ON EC.intEntityId = E.intEntityId
	JOIN tblEMEntity ETC ON ETC.intEntityId = EC.intEntityContactId
	JOIN tblEMEntityPhoneNumber EPN ON EPN.intEntityId = ETC.intEntityId
	WHERE strUserName = @strUserName
	
	SELECT @strLogisticsCompanyName = strLogisticsCompanyName,
		   @strLogisticsPrintSignOff = strLogisticsPrintSignOff
	FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intCompanyLocationId

	
	SELECT TOP 1 @strPrintableRemarks = CH.strPrintableRemarks
				,@strContractText = CT.strText
				,@strContainerPackType = LTRIM(ISNULL(L.intNumberOfContainers,0)) + ' ' + L.strPackingDescription
				,@strPackingDescription = L.strPackingDescription
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
			WHEN L.intPurchaseSale = 1
				THEN LD.intPContractDetailId
			ELSE LD.intSContractDetailId
			END
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblCTContractText CT ON CT.intContractTextId = CH.intContractTextId
	WHERE L.intLoadId = @intLoadId

	SELECT TOP 1 @strContainerQtyUOM = LTRIM(dbo.fnRemoveTrailingZeroes(SUM(dblQuantity))) + ' ' + strItemUOM
	FROM vyuLGLoadDetailViewSearch
	WHERE intLoadId = @intLoadId
	GROUP BY strItemUOM

	SELECT TOP 1 @strPackingUOM =  CASE UPPER(strPackingDescription)
			WHEN UPPER('Bulk')
				THEN strPackingDescription
			ELSE UM.strUnitMeasure
			END
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	WHERE L.intLoadId = @intLoadId

	SELECT @strBOLInstructionText = '- All shipment details and purchase contract details as stated above' + CHAR(13) +
								'- Gross-, Net- & Tare Weight' + CHAR(13) +
								'- In the B/L description of goods: "' + @strContainerPackType + ' container(s) equivalent to ' + @strContainerQtyUOM + ' each of clean green coffee in '+ @strPackingUOM +' for any limitation of liability purposes."'


SELECT *
	,LTRIM(RTRIM(CASE 
				WHEN ISNULL(strConsigneeText, '') = ''
					THEN ''
				ELSE strConsigneeText + CHAR(13)
				END + CASE 
				WHEN ISNULL(strConsignee, '') = ''
					THEN ''
				ELSE strConsignee + CHAR(13)
				END + CASE 
				WHEN ISNULL(strConsigneeAddress, '') = ''
					THEN ''
				ELSE strConsigneeAddress + CHAR(13)
				END + CASE 
				WHEN ISNULL(strConsigneeCity, '') = ''
					THEN ''
				ELSE strConsigneeCity + CHAR(13)
				END + CASE 
				WHEN ISNULL(strConsigneeZipCode, '') = ''
					THEN ''
				ELSE strConsigneeZipCode + CHAR(13)
				END + CASE 
				WHEN ISNULL(strConsigneeCountry, '') = ''
					THEN ''
				ELSE strConsigneeCountry + CHAR(13)
				END + CASE 
				WHEN ISNULL(strConsigneeMobile, '') = ''
					THEN ''
				ELSE 'Mobile: ' + strConsigneeMobile + CHAR(13)
				END + CASE 
				WHEN ISNULL(strConsigneePhone, '') = ''
					THEN ''
				ELSE 'Phone: ' + strConsigneePhone + CHAR(13)
				END + CASE 
				WHEN ISNULL(strConsigneeFax, '') = ''
					THEN ''
				ELSE 'Fax: ' + strConsigneeFax + CHAR(13)
				END + CASE 
				WHEN ISNULL(strConsigneeMail, '') = ''
					THEN ''
				ELSE 'E-mail: ' + strConsigneeMail
				END)) strConsigneeInfo
	,LTRIM(RTRIM(CASE 
				WHEN ISNULL(strFirstNotifyText, '') = ''
					THEN ''
				ELSE strFirstNotifyText + CHAR(13)
				END + CASE 
				WHEN ISNULL(strFirstNotify, '') = ''
					THEN ''
				ELSE strFirstNotify + CHAR(13)
				END + CASE 
				WHEN ISNULL(strFirstNotifyAddress, '') = ''
					THEN ''
				ELSE strFirstNotifyAddress + CHAR(13)
				END + CASE 
				WHEN ISNULL(strFirstNotifyCity, '') = ''
					THEN ''
				ELSE strFirstNotifyCity + CHAR(13)
				END + CASE 
				WHEN ISNULL(strFirstNotifyZipCode, '') = ''
					THEN ''
				ELSE strFirstNotifyZipCode + CHAR(13)
				END + CASE 
				WHEN ISNULL(strFirstNotifyCountry, '') = ''
					THEN ''
				ELSE strFirstNotifyCountry + CHAR(13)
				END + CASE 
				WHEN ISNULL(strFirstNotifyMobile, '') = ''
					THEN ''
				ELSE 'Mobile: ' + strFirstNotifyMobile + CHAR(13)
				END + CASE 
				WHEN ISNULL(strFirstNotifyPhone, '') = ''
					THEN ''
				ELSE 'Phone: ' + strFirstNotifyPhone + CHAR(13)
				END + CASE 
				WHEN ISNULL(strFirstNotifyFax, '') = ''
					THEN ''
				ELSE 'Fax: ' + strFirstNotifyFax + CHAR(13)
				END + CASE 
				WHEN ISNULL(strFirstNotifyMail, '') = ''
					THEN ''
				ELSE 'E-mail: ' + strFirstNotifyMail
				END)) strFirstNotifyInfo
	,LTRIM(RTRIM(CASE 
				WHEN ISNULL(strSecondNotifyText, '') = ''
					THEN ''
				ELSE strSecondNotifyText + CHAR(13)
				END + CASE 
				WHEN ISNULL(strSecondNotify, '') = ''
					THEN ''
				ELSE strSecondNotify + CHAR(13)
				END + CASE 
				WHEN ISNULL(strSecondNotifyAddress, '') = ''
					THEN ''
				ELSE strSecondNotifyAddress + CHAR(13)
				END + CASE 
				WHEN ISNULL(strSecondNotifyCity, '') = ''
					THEN ''
				ELSE strSecondNotifyCity + CHAR(13)
				END + CASE 
				WHEN ISNULL(strSecondNotifyZipCode, '') = ''
					THEN ''
				ELSE strSecondNotifyZipCode + CHAR(13)
				END + CASE 
				WHEN ISNULL(strSecondNotifyCountry, '') = ''
					THEN ''
				ELSE strSecondNotifyCountry + CHAR(13)
				END + CASE 
				WHEN ISNULL(strSecondNotifyMobile, '') = ''
					THEN ''
				ELSE 'Mobile: ' + strSecondNotifyMobile + CHAR(13)
				END + CASE 
				WHEN ISNULL(strSecondNotifyPhone, '') = ''
					THEN ''
				ELSE 'Phone: ' + strSecondNotifyPhone + CHAR(13)
				END + CASE 
				WHEN ISNULL(strSecondNotifyFax, '') = ''
					THEN ''
				ELSE 'Fax: ' + strSecondNotifyFax + CHAR(13)
				END + CASE 
				WHEN ISNULL(strSecondNotifyMail, '') = ''
					THEN ''
				ELSE 'E-mail: ' + strSecondNotifyMail
				END)) strSecondNotifyInfo
	,strBOLInstructionText = @strBOLInstructionText
	,strContainerTypePackingDescription = strContainerType + ' in ' + strPackingDescription
	,strFullName = @strFullName
	,strUserPhoneNo = @strUserPhoneNo 
	,strUserEmailId = @strUserEmailId
FROM (
	SELECT TOP 1 L.intLoadId
		,L.dtmScheduledDate
		,L.strLoadNumber
		,L.dtmBLDate
		,L.dtmDeliveredDate
		,CASE 
			WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
				THEN DProducer.strName
			ELSE CASE 
					WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
						THEN Producer.strName
					ELSE Vendor.strName
					END
			END AS strVendor
		,CASE 
			WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
				THEN DPETC.strName
			ELSE CASE 
					WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
						THEN PETC.strName
					ELSE VETC.strName
					END
			END AS strVendorContact
		,Customer.strName AS strCustomer
		,CETC.strName AS strCustomerContact
		,L.strOriginPort
		,L.strDestinationPort
		,(
			SELECT TOP 1 strVAT
			FROM tblSMCity
			WHERE strCity = L.strDestinationPort
			) AS strDestinationPortVatNo
		,SLEntity.strName AS strShippingLine
		,L.strServiceContractNumber
		,L.strPackingDescription
		,L.intNumberOfContainers
		,CONVERT(NVARCHAR, L.intNumberOfContainers) + ' (' + L.strPackingDescription + ')' AS strNumberOfContainers
		,ContType.strContainerType
		,L.strShippingMode
		,L.strMVessel
		,L.strMVoyageNumber
		,L.strFVessel
		,L.strFVoyageNumber
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
		,ISNULL(CLNP.strText, '') AS strConsigneeText
		,CASE FLNP.strType
			WHEN 'Bank'
				THEN ISNULL(FirstNotifyBank.strBankName, '')
			WHEN 'Company'
				THEN ISNULL(FirstNotifyCompany.strCompanyName, '')
			WHEN 'Vendor'
				THEN ISNULL(FirstNotify.strName, '')
			WHEN 'Customer'
				THEN ISNULL(FirstNotify.strName, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(FirstNotify.strName, '')
			ELSE ''
			END strFirstNotify
		,CASE FLNP.strType
			WHEN 'Bank'
				THEN ISNULL(FirstNotifyBank.strEmail, '')
			WHEN 'Company'
				THEN ISNULL(FirstNotifyCompany.strEmail, '')
			WHEN 'Vendor'
				THEN ISNULL(FirstNotify.strEmail, '')
			WHEN 'Customer'
				THEN ISNULL(FirstNotify.strEmail, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(FirstNotify.strEmail, '')
			ELSE ''
			END strFirstNotifyMail
		,CASE FLNP.strType
			WHEN 'Bank'
				THEN ISNULL(FirstNotifyBank.strFax, '')
			WHEN 'Company'
				THEN ISNULL(FirstNotifyCompany.strFax, '')
			WHEN 'Vendor'
				THEN ISNULL(FirstNotify.strFax, '')
			WHEN 'Customer'
				THEN ISNULL(FirstNotify.strFax, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(FirstNotify.strFax, '')
			ELSE ''
			END strFirstNotifyFax
		,CASE FLNP.strType
			WHEN 'Bank'
				THEN ''
			WHEN 'Company'
				THEN ''
			WHEN 'Vendor'
				THEN ISNULL(FirstNotify.strMobile, '')
			WHEN 'Customer'
				THEN ISNULL(FirstNotify.strMobile, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(FirstNotify.strMobile, '')
			ELSE ''
			END strFirstNotifyMobile
		,CASE FLNP.strType
			WHEN 'Bank'
				THEN ISNULL(FirstNotifyBank.strPhone, '')
			WHEN 'Company'
				THEN ISNULL(FirstNotifyCompany.strPhone, '')
			WHEN 'Vendor'
				THEN ISNULL(FirstNotifyContactEntity.strPhone, '')
			WHEN 'Customer'
				THEN ISNULL(FirstNotifyContactEntity.strPhone, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(FirstNotifyContactEntity.strPhone, '')
			ELSE ''
			END strFirstNotifyPhone
		,CASE FLNP.strType
			WHEN 'Bank'
				THEN ISNULL(FirstNotifyBank.strAddress, '')
			WHEN 'Company'
				THEN ISNULL(FirstNotifyCompany.strAddress, '')
			WHEN 'Vendor'
				THEN ISNULL(FNLocation.strAddress, '')
			WHEN 'Customer'
				THEN ISNULL(FNLocation.strAddress, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(FNLocation.strAddress, '')
			ELSE ''
			END strFirstNotifyAddress
		,CASE FLNP.strType
			WHEN 'Bank'
				THEN ISNULL(FirstNotifyBank.strCity, '')
			WHEN 'Company'
				THEN ISNULL(FirstNotifyCompany.strCity, '')
			WHEN 'Vendor'
				THEN ISNULL(FNLocation.strCity, '')
			WHEN 'Customer'
				THEN ISNULL(FNLocation.strCity, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(FNLocation.strCity, '')
			ELSE ''
			END strFirstNotifyCity
		,CASE FLNP.strType
			WHEN 'Bank'
				THEN ISNULL(FirstNotifyBank.strCountry, '')
			WHEN 'Company'
				THEN ISNULL(FirstNotifyCompany.strCountry, '')
			WHEN 'Vendor'
				THEN ISNULL(FNLocation.strCountry, '')
			WHEN 'Customer'
				THEN ISNULL(FNLocation.strCountry, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(FNLocation.strCountry, '')
			ELSE ''
			END strFirstNotifyCountry
		,CASE FLNP.strType
			WHEN 'Bank'
				THEN ISNULL(FirstNotifyBank.strState, '')
			WHEN 'Company'
				THEN ISNULL(FirstNotifyCompany.strState, '')
			WHEN 'Vendor'
				THEN ISNULL(FNLocation.strState, '')
			WHEN 'Customer'
				THEN ISNULL(FNLocation.strState, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(FNLocation.strState, '')
			ELSE ''
			END strFirstNotifyState
		,CASE FLNP.strType
			WHEN 'Bank'
				THEN ISNULL(FirstNotifyBank.strZipCode, '')
			WHEN 'Company'
				THEN ISNULL(FirstNotifyCompany.strZip, '')
			WHEN 'Vendor'
				THEN ISNULL(FNLocation.strZipCode, '')
			WHEN 'Customer'
				THEN ISNULL(FNLocation.strZipCode, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(FNLocation.strZipCode, '')
			ELSE ''
			END strFirstNotifyZipCode
		,CASE SLNP.strType
			WHEN 'Bank'
				THEN ISNULL(SecondNotifyBank.strBankName, '')
			WHEN 'Company'
				THEN ISNULL(SecondNotifyCompany.strCompanyName, '')
			WHEN 'Vendor'
				THEN ISNULL(SecondNotify.strName, '')
			WHEN 'Customer'
				THEN ISNULL(SecondNotify.strName, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(SecondNotify.strName, '')
			ELSE ''
			END strSecondNotify
		,CASE SLNP.strType
			WHEN 'Bank'
				THEN ISNULL(SecondNotifyBank.strEmail, '')
			WHEN 'Company'
				THEN ISNULL(SecondNotifyCompany.strEmail, '')
			WHEN 'Vendor'
				THEN ISNULL(SecondNotify.strEmail, '')
			WHEN 'Customer'
				THEN ISNULL(SecondNotify.strEmail, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(SecondNotify.strEmail, '')
			ELSE ''
			END strSecondNotifyMail
		,CASE SLNP.strType
			WHEN 'Bank'
				THEN ISNULL(SecondNotifyBank.strFax, '')
			WHEN 'Company'
				THEN ISNULL(SecondNotifyCompany.strFax, '')
			WHEN 'Vendor'
				THEN ISNULL(SecondNotify.strFax, '')
			WHEN 'Customer'
				THEN ISNULL(SecondNotify.strFax, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(SecondNotify.strFax, '')
			ELSE ''
			END strSecondNotifyFax
		,CASE SLNP.strType
			WHEN 'Bank'
				THEN ''
			WHEN 'Company'
				THEN ''
			WHEN 'Vendor'
				THEN ISNULL(SecondNotify.strMobile, '')
			WHEN 'Customer'
				THEN ISNULL(SecondNotify.strMobile, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(SecondNotify.strMobile, '')
			ELSE ''
			END strSecondNotifyMobile
		,CASE SLNP.strType
			WHEN 'Bank'
				THEN ISNULL(SecondNotifyBank.strPhone, '')
			WHEN 'Company'
				THEN ISNULL(SecondNotifyCompany.strPhone, '')
			WHEN 'Vendor'
				THEN ISNULL(SecondNotifyContactEntity.strPhone, '')
			WHEN 'Customer'
				THEN ISNULL(SecondNotifyContactEntity.strPhone, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(SecondNotifyContactEntity.strPhone, '')
			ELSE ''
			END strSecondNotifyPhone
		,CASE SLNP.strType
			WHEN 'Bank'
				THEN ISNULL(SecondNotifyBank.strAddress, '')
			WHEN 'Company'
				THEN ISNULL(SecondNotifyCompany.strAddress, '')
			WHEN 'Vendor'
				THEN ISNULL(SNLocation.strAddress, '')
			WHEN 'Customer'
				THEN ISNULL(SNLocation.strAddress, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(SNLocation.strAddress, '')
			ELSE ''
			END strSecondNotifyAddress
		,CASE SLNP.strType
			WHEN 'Bank'
				THEN ISNULL(SecondNotifyBank.strCity, '')
			WHEN 'Company'
				THEN ISNULL(SecondNotifyCompany.strCity, '')
			WHEN 'Vendor'
				THEN ISNULL(SNLocation.strCity, '')
			WHEN 'Customer'
				THEN ISNULL(SNLocation.strCity, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(SNLocation.strCity, '')
			ELSE ''
			END strSecondNotifyCity
		,CASE SLNP.strType
			WHEN 'Bank'
				THEN ISNULL(SecondNotifyBank.strCountry, '')
			WHEN 'Company'
				THEN ISNULL(SecondNotifyCompany.strCountry, '')
			WHEN 'Vendor'
				THEN ISNULL(SNLocation.strCountry, '')
			WHEN 'Customer'
				THEN ISNULL(SNLocation.strCountry, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(SNLocation.strCountry, '')
			ELSE ''
			END strSecondNotifyCountry
		,CASE SLNP.strType
			WHEN 'Bank'
				THEN ISNULL(SecondNotifyBank.strState, '')
			WHEN 'Company'
				THEN ISNULL(SecondNotifyCompany.strState, '')
			WHEN 'Vendor'
				THEN ISNULL(SNLocation.strState, '')
			WHEN 'Customer'
				THEN ISNULL(SNLocation.strState, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(SNLocation.strState, '')
			ELSE ''
			END strSecondNotifyState
		,CASE SLNP.strType
			WHEN 'Bank'
				THEN ISNULL(SecondNotifyBank.strZipCode, '')
			WHEN 'Company'
				THEN ISNULL(SecondNotifyCompany.strZip, '')
			WHEN 'Vendor'
				THEN ISNULL(SNLocation.strZipCode, '')
			WHEN 'Customer'
				THEN ISNULL(SNLocation.strZipCode, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(SNLocation.strZipCode, '')
			ELSE ''
			END strSecondNotifyZipCode
		,CASE CLNP.strType
			WHEN 'Bank'
				THEN ISNULL(ConsigneeNotifyBank.strBankName, '')
			WHEN 'Company'
				THEN ISNULL(ConsigneeNotifyCompany.strCompanyName, '')
			WHEN 'Vendor'
				THEN ISNULL(ConsigneeNotify.strName, '')
			WHEN 'Customer'
				THEN ISNULL(ConsigneeNotify.strName, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(ConsigneeNotify.strName, '')
			ELSE ''
			END strConsignee
		,CASE CLNP.strType
			WHEN 'Bank'
				THEN ISNULL(ConsigneeNotifyBank.strEmail, '')
			WHEN 'Company'
				THEN ISNULL(ConsigneeNotifyCompany.strEmail, '')
			WHEN 'Vendor'
				THEN ISNULL(ConsigneeNotify.strEmail, '')
			WHEN 'Customer'
				THEN ISNULL(ConsigneeNotify.strEmail, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(ConsigneeNotify.strEmail, '')
			ELSE ''
			END strConsigneeMail
		,CASE CLNP.strType
			WHEN 'Bank'
				THEN ISNULL(ConsigneeNotifyBank.strFax, '')
			WHEN 'Company'
				THEN ISNULL(ConsigneeNotifyCompany.strFax, '')
			WHEN 'Vendor'
				THEN ISNULL(ConsigneeNotify.strFax, '')
			WHEN 'Customer'
				THEN ISNULL(ConsigneeNotify.strFax, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(ConsigneeNotify.strFax, '')
			ELSE ''
			END strConsigneeFax
		,CASE CLNP.strType
			WHEN 'Bank'
				THEN ''
			WHEN 'Company'
				THEN ''
			WHEN 'Vendor'
				THEN ISNULL(ConsigneeNotify.strMobile, '')
			WHEN 'Customer'
				THEN ISNULL(ConsigneeNotify.strMobile, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(ConsigneeNotify.strMobile, '')
			ELSE ''
			END strConsigneeMobile
		,CASE CLNP.strType
			WHEN 'Bank'
				THEN ISNULL(ConsigneeNotifyBank.strPhone, '')
			WHEN 'Company'
				THEN ISNULL(ConsigneeNotifyCompany.strPhone, '')
			WHEN 'Vendor'
				THEN ISNULL(ConsigneeNotifyContactEntity.strPhone, '')
			WHEN 'Customer'
				THEN ISNULL(ConsigneeNotifyContactEntity.strPhone, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(ConsigneeNotifyContactEntity.strPhone, '')
			ELSE ''
			END strConsigneePhone
		,CASE CLNP.strType
			WHEN 'Bank'
				THEN ISNULL(ConsigneeNotifyBank.strAddress, '')
			WHEN 'Company'
				THEN ISNULL(ConsigneeNotifyCompany.strAddress, '')
			WHEN 'Vendor'
				THEN ISNULL(CNLocation.strAddress, '')
			WHEN 'Customer'
				THEN ISNULL(CNLocation.strAddress, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(CNLocation.strAddress, '')
			ELSE ''
			END strConsigneeAddress
		,CASE CLNP.strType
			WHEN 'Bank'
				THEN ISNULL(ConsigneeNotifyBank.strCity, '')
			WHEN 'Company'
				THEN ISNULL(ConsigneeNotifyCompany.strCity, '')
			WHEN 'Vendor'
				THEN ISNULL(CNLocation.strCity, '')
			WHEN 'Customer'
				THEN ISNULL(CNLocation.strCity, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(CNLocation.strCity, '')
			ELSE ''
			END strConsigneeCity
		,CASE CLNP.strType
			WHEN 'Bank'
				THEN ISNULL(ConsigneeNotifyBank.strCountry, '')
			WHEN 'Company'
				THEN ISNULL(ConsigneeNotifyCompany.strCountry, '')
			WHEN 'Vendor'
				THEN ISNULL(CNLocation.strCountry, '')
			WHEN 'Customer'
				THEN ISNULL(CNLocation.strCountry, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(CNLocation.strCountry, '')
			ELSE ''
			END strConsigneeCountry
		,CASE CLNP.strType
			WHEN 'Bank'
				THEN ISNULL(ConsigneeNotifyBank.strState, '')
			WHEN 'Company'
				THEN ISNULL(ConsigneeNotifyCompany.strState, '')
			WHEN 'Vendor'
				THEN ISNULL(CNLocation.strState, '')
			WHEN 'Customer'
				THEN ISNULL(CNLocation.strState, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(CNLocation.strState, '')
			ELSE ''
			END strConsigneeState
		,CASE CLNP.strType
			WHEN 'Bank'
				THEN ISNULL(ConsigneeNotifyBank.strZipCode, '')
			WHEN 'Company'
				THEN ISNULL(ConsigneeNotifyCompany.strZip, '')
			WHEN 'Vendor'
				THEN ISNULL(CNLocation.strZipCode, '')
			WHEN 'Customer'
				THEN ISNULL(CNLocation.strZipCode, '')
			WHEN 'Forwarding Agent'
				THEN ISNULL(CNLocation.strZipCode, '')
			ELSE ''
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
		,dbo.fnSMGetCompanyLogo('Footer') AS blbFooterLogo
		,strShippingInstructionStandardText = (
			SELECT TOP 1 strShippingInstructionText
			FROM tblLGCompanyPreference
			)
		,(
			SELECT TOP 1 strInboundText
			FROM tblSMCity
			WHERE strCity = L.strDestinationPort
			) AS strContractText
		,CD.strERPPONumber
		,Basis.strContractBasis
		,Basis.strDescription AS strContractBasisDescription
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
			WHEN L.intPurchaseSale = 1
				THEN intPContractDetailId
			ELSE intSContractDetailId
			END
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblEMEntity Producer ON Producer.intEntityId = CH.intProducerId
	LEFT JOIN tblEMEntityToContact PEC ON PEC.intEntityId = Producer.intEntityId
	LEFT JOIN tblEMEntity PETC ON PETC.intEntityId = PEC.intEntityContactId
	LEFT JOIN tblEMEntity DProducer ON DProducer.intEntityId = CD.intProducerId
	LEFT JOIN tblEMEntityToContact DPEC ON DPEC.intEntityId = DProducer.intEntityId
	LEFT JOIN tblEMEntity DPETC ON DPETC.intEntityId = DPEC.intEntityContactId
	LEFT JOIN tblLGLoadContainer LC ON L.intLoadId = LC.intLoadId
	LEFT JOIN tblLGLoadNotifyParties LNP ON LNP.intLoadId = L.intLoadId
	LEFT JOIN tblEMEntity Vendor ON Vendor.intEntityId = LD.intVendorEntityId
	LEFT JOIN tblEMEntityToContact VEC ON VEC.intEntityId = Vendor.intEntityId
	LEFT JOIN tblEMEntity VETC ON VETC.intEntityId = VEC.intEntityContactId
	LEFT JOIN tblEMEntity Customer ON Customer.intEntityId = LD.intCustomerEntityId
	LEFT JOIN tblEMEntityToContact CEC ON CEC.intEntityId = Customer.intEntityId
	LEFT JOIN tblEMEntity CETC ON CETC.intEntityId = CEC.intEntityContactId
	LEFT JOIN tblEMEntity SLEntity ON SLEntity.intEntityId = L.intShippingLineEntityId
	LEFT JOIN tblLGContainerType ContType ON ContType.intContainerTypeId = L.intContainerTypeId
	LEFT JOIN tblEMEntity ForAgent ON ForAgent.intEntityId = L.intForwardingAgentEntityId
	LEFT JOIN tblEMEntity BLDraft ON BLDraft.intEntityId = L.intBLDraftToBeSentId
	LEFT JOIN tblEMEntity DocPres ON DocPres.intEntityId = L.intDocPresentationId
	LEFT JOIN tblCMBank Bank ON Bank.intBankId = L.intDocPresentationId
	LEFT JOIN tblLGLoadNotifyParties FLNP ON L.intLoadId = FLNP.intLoadId
		AND FLNP.strNotifyOrConsignee = 'First Notify'
	LEFT JOIN tblLGLoadNotifyParties SLNP ON L.intLoadId = SLNP.intLoadId
		AND SLNP.strNotifyOrConsignee = 'Second Notify'
	LEFT JOIN tblLGLoadNotifyParties CLNP ON L.intLoadId = CLNP.intLoadId
		AND CLNP.strNotifyOrConsignee = 'Consignee'
	LEFT JOIN tblEMEntity FirstNotify ON FirstNotify.intEntityId = FLNP.intEntityId
	LEFT JOIN tblEMEntityToContact FirstNotifyContact ON FirstNotifyContact.intEntityId = FirstNotify.intEntityId
	LEFT JOIN tblEMEntity FirstNotifyContactEntity ON FirstNotifyContactEntity.intEntityId = FirstNotifyContact.intEntityContactId
	LEFT JOIN tblCMBank FirstNotifyBank ON FirstNotifyBank.intBankId = FLNP.intBankId
	LEFT JOIN tblSMCompanySetup FirstNotifyCompany ON FirstNotifyCompany.intCompanySetupID = FLNP.intCompanySetupID
	LEFT JOIN tblEMEntityLocation FNLocation ON FNLocation.intEntityLocationId = FLNP.intEntityLocationId
	LEFT JOIN tblEMEntity SecondNotify ON SecondNotify.intEntityId = SLNP.intEntityId
	LEFT JOIN tblEMEntityToContact SecondNotifyContact ON SecondNotifyContact.intEntityId = SecondNotify.intEntityId
	LEFT JOIN tblEMEntity SecondNotifyContactEntity ON SecondNotifyContactEntity.intEntityId = SecondNotifyContact.intEntityContactId
	LEFT JOIN tblCMBank SecondNotifyBank ON SecondNotifyBank.intBankId = SLNP.intBankId
	LEFT JOIN tblSMCompanySetup SecondNotifyCompany ON SecondNotifyCompany.intCompanySetupID = SLNP.intCompanySetupID
	LEFT JOIN tblEMEntityLocation SNLocation ON SNLocation.intEntityLocationId = SLNP.intEntityLocationId
	LEFT JOIN tblEMEntity ConsigneeNotify ON ConsigneeNotify.intEntityId = CLNP.intEntityId
	LEFT JOIN tblEMEntityToContact ConsigneeNotifyContact ON ConsigneeNotifyContact.intEntityId = ConsigneeNotify.intEntityId
	LEFT JOIN tblEMEntity ConsigneeNotifyContactEntity ON ConsigneeNotifyContactEntity.intEntityId = ConsigneeNotifyContact.intEntityContactId
	LEFT JOIN tblCMBank ConsigneeNotifyBank ON ConsigneeNotifyBank.intBankId = CLNP.intBankId
	LEFT JOIN tblSMCompanySetup ConsigneeNotifyCompany ON ConsigneeNotifyCompany.intCompanySetupID = CLNP.intCompanySetupID
	LEFT JOIN tblEMEntityLocation CNLocation ON CNLocation.intEntityLocationId = CLNP.intEntityLocationId
	LEFT JOIN tblSMCurrency DemCurrency ON DemCurrency.intCurrencyID = L.intDemurrageCurrencyId
	LEFT JOIN tblSMCurrency DesCurrency ON DesCurrency.intCurrencyID = L.intDespatchCurrencyId
	LEFT JOIN tblICUnitMeasure LoadUnit ON LoadUnit.intUnitMeasureId = L.intLoadingUnitMeasureId
	LEFT JOIN tblICUnitMeasure DisUnit ON DisUnit.intUnitMeasureId = L.intDischargeUnitMeasureId
	LEFT JOIN tblCTContractBasis Basis ON Basis.intContractBasisId = CH.intContractBasisId
	WHERE L.intLoadId = @intLoadId
	) tbl
END