﻿CREATE PROCEDURE [dbo].[uspLGGetShippingInstructionReport]
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
			@strFax						NVARCHAR(50),
			@strWeb						NVARCHAR(200),
			@strFullName				NVARCHAR(100),
			@strUserName				NVARCHAR(100),
			@strLogisticsCompanyName	NVARCHAR(MAX),
			@strLogisticsPrintSignOff	NVARCHAR(MAX),
			@intCompanyLocationId		INT,
			@strContainerPackType		NVARCHAR(100),
			@strUserPhoneNo				NVARCHAR(100),
			@strUserEmailId				NVARCHAR(100),
			@strContainerQtyUOM			NVARCHAR(100),
			@strPackingUOM				NVARCHAR(100),
			@Condition					VARCHAR(8000) ,
			@intVendorCustomerLocId		INT,
			@intPSCompanyLocId			INT

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
			,@strFax = strFax
			,@strWeb = strWebSite 
	FROM tblSMCompanySetup
	
	SELECT @strFullName = E.strName,
		   @strUserEmailId = ETC.strEmail,
		   @strUserPhoneNo = EPN.strPhone  
	FROM tblSMUserSecurity S
	JOIN tblEMEntity E ON E.intEntityId = S.intEntityId
	JOIN tblEMEntityToContact EC ON EC.intEntityId = E.intEntityId
	JOIN tblEMEntity ETC ON ETC.intEntityId = EC.intEntityContactId
	JOIN tblEMEntityPhoneNumber EPN ON EPN.intEntityId = ETC.intEntityId
	WHERE S.strUserName = @strUserName
	
	SELECT @strLogisticsCompanyName = strLogisticsCompanyName,
		   @strLogisticsPrintSignOff = strLogisticsPrintSignOff
	FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intCompanyLocationId

	SELECT TOP 1 @strContainerQtyUOM = LTRIM(dbo.fnRemoveTrailingZeroes(SUM(LD.dblQuantity))) + ' ' + UOM.strUnitMeasure
	FROM tblLGLoadDetail LD
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	WHERE intLoadId = @intLoadId
	GROUP BY UOM.strUnitMeasure

	SET @Condition = '<ol>'
	SELECT @Condition = COALESCE(@Condition + '<li>', '') + CTC.strConditionName + ' - ' + LC.strConditionDescription + '</li>'
	FROM tblLGLoadCondition LC
	INNER JOIN tblCTCondition CTC ON LC.intConditionId = CTC.intConditionId
	WHERE intLoadId = @intLoadId
	SET @Condition = @Condition +'</ol>'

	IF @Condition = '<ol></ol>'
	BEGIN
		SET @Condition = NULL
	END

	SELECT
		@intVendorCustomerLocId = 
			CASE WHEN intPurchaseSale = 1 
				THEN LD.intVendorEntityLocationId ELSE
				intCustomerEntityLocationId
			END,
		@intPSCompanyLocId =
			CASE WHEN intPurchaseSale = 1 
				THEN LD.intPCompanyLocationId ELSE
				intSCompanyLocationId
			END
	FROM tblLGLoad L
	INNER JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	WHERE L.intLoadId = @intLoadId

SELECT *
	,strConsigneeInfo = LTRIM(RTRIM(
		CASE WHEN ISNULL(strConsignee, '') = '' THEN '' ELSE strConsignee + CHAR(13) END 
		+ CASE WHEN ISNULL(strConsigneeAddress, '') = '' THEN '' ELSE strConsigneeAddress + CHAR(13) END 
		+ CASE WHEN ISNULL(strConsigneeCity, '') = '' THEN '' ELSE strConsigneeCity + CHAR(13) END 
		+ CASE WHEN ISNULL(strConsigneeZipCode, '') = '' THEN '' ELSE strConsigneeZipCode + CHAR(13) END 
		+ CASE WHEN ISNULL(strConsigneeCountry, '') = '' THEN '' ELSE strConsigneeCountry + CHAR(13) END 
		+ CASE WHEN ISNULL(strConsigneeMobile, '') = '' THEN '' ELSE 'Mobile: ' + strConsigneeMobile + CHAR(13) END 
		+ CASE WHEN ISNULL(strConsigneePhone, '') = '' THEN '' ELSE 'Phone: ' + strConsigneePhone + CHAR(13) END 
		+ CASE WHEN ISNULL(strConsigneeFax, '') = '' THEN '' ELSE 'Fax: ' + strConsigneeFax + CHAR(13) END 
		+ CASE WHEN ISNULL(strConsigneeMail, '') = '' THEN '' ELSE 'E-mail: ' + strConsigneeMail + CHAR(13) END 
		+ CASE WHEN ISNULL(strConsigneeText, '') = '' THEN '' ELSE strConsigneeText END)) 
	,strFirstNotifyInfo = LTRIM(RTRIM(
		CASE WHEN ISNULL(strFirstNotify, '') = '' THEN '' ELSE strFirstNotify + CHAR(13) END 
		+ CASE WHEN ISNULL(strFirstNotifyAddress, '') = '' THEN '' ELSE strFirstNotifyAddress + CHAR(13) END 
		+ CASE WHEN ISNULL(strFirstNotifyCity, '') = '' THEN '' ELSE strFirstNotifyCity + CHAR(13) END 
		+ CASE WHEN ISNULL(strFirstNotifyZipCode, '') = '' THEN '' ELSE strFirstNotifyZipCode + CHAR(13) END 
		+ CASE WHEN ISNULL(strFirstNotifyCountry, '') = '' THEN '' ELSE strFirstNotifyCountry + CHAR(13) END 
		+ CASE WHEN ISNULL(strFirstNotifyMobile, '') = '' THEN '' ELSE 'Mobile: ' + strFirstNotifyMobile + CHAR(13) END 
		+ CASE WHEN ISNULL(strFirstNotifyPhone, '') = '' THEN '' ELSE 'Phone: ' + strFirstNotifyPhone + CHAR(13) END 
		+ CASE WHEN ISNULL(strFirstNotifyFax, '') = '' THEN '' ELSE 'Fax: ' + strFirstNotifyFax + CHAR(13) END 
		+ CASE WHEN ISNULL(strFirstNotifyMail, '') = '' THEN '' ELSE 'E-mail: ' + strFirstNotifyMail + CHAR(13) END 
		+ CASE WHEN ISNULL(strFirstNotifyText, '') = '' THEN '' ELSE strFirstNotifyText END)) 
	,strSecondNotifyInfo = LTRIM(RTRIM(
		CASE WHEN ISNULL(strSecondNotify, '') = '' THEN '' ELSE strSecondNotify + CHAR(13) END 
		+ CASE WHEN ISNULL(strSecondNotifyAddress, '') = '' THEN '' ELSE strSecondNotifyAddress + CHAR(13) END 
		+ CASE WHEN ISNULL(strSecondNotifyCity, '') = '' THEN '' ELSE strSecondNotifyCity + CHAR(13) END 
		+ CASE WHEN ISNULL(strSecondNotifyZipCode, '') = '' THEN '' ELSE strSecondNotifyZipCode + CHAR(13) END 
		+ CASE WHEN ISNULL(strSecondNotifyCountry, '') = '' THEN '' ELSE strSecondNotifyCountry + CHAR(13) END 
		+ CASE WHEN ISNULL(strSecondNotifyMobile, '') = '' THEN '' ELSE 'Mobile: ' + strSecondNotifyMobile + CHAR(13) END 
		+ CASE WHEN ISNULL(strSecondNotifyPhone, '') = '' THEN '' ELSE 'Phone: ' + strSecondNotifyPhone + CHAR(13) END 
		+ CASE WHEN ISNULL(strSecondNotifyFax, '') = '' THEN '' ELSE 'Fax: ' + strSecondNotifyFax + CHAR(13) END 
		+ CASE WHEN ISNULL(strSecondNotifyMail, '') = '' THEN '' ELSE 'E-mail: ' + strSecondNotifyMail + CHAR(13) END 
		+ CASE WHEN ISNULL(strSecondNotifyText, '') = '' THEN '' ELSE strSecondNotifyText END)) 
	,strThirdNotifyInfo = LTRIM(RTRIM(
		CASE WHEN ISNULL(strThirdNotify, '') = '' THEN '' ELSE strThirdNotify + CHAR(13) END 
		+ CASE WHEN ISNULL(strThirdNotifyAddress, '') = '' THEN '' ELSE strThirdNotifyAddress + CHAR(13) END 
		+ CASE WHEN ISNULL(strThirdNotifyCity, '') = '' THEN '' ELSE strThirdNotifyCity + CHAR(13) END 
		+ CASE WHEN ISNULL(strThirdNotifyZipCode, '') = '' THEN '' ELSE strThirdNotifyZipCode + CHAR(13) END 
		+ CASE WHEN ISNULL(strThirdNotifyCountry, '') = '' THEN '' ELSE strThirdNotifyCountry + CHAR(13) END 
		+ CASE WHEN ISNULL(strThirdNotifyMobile, '') = '' THEN '' ELSE 'Mobile: ' + strThirdNotifyMobile + CHAR(13) END 
		+ CASE WHEN ISNULL(strThirdNotifyPhone, '') = '' THEN '' ELSE 'Phone: ' + strThirdNotifyPhone + CHAR(13) END 
		+ CASE WHEN ISNULL(strThirdNotifyFax, '') = '' THEN '' ELSE 'Fax: ' + strThirdNotifyFax + CHAR(13) END 
		+ CASE WHEN ISNULL(strThirdNotifyMail, '') = '' THEN '' ELSE 'E-mail: ' + strThirdNotifyMail + CHAR(13) END 
		+ CASE WHEN ISNULL(strThirdNotifyText, '') = '' THEN '' ELSE strThirdNotifyText END)) 
	,strFourthNotifyInfo = LTRIM(RTRIM(
		CASE WHEN ISNULL(strFourthNotify, '') = '' THEN '' ELSE strFourthNotify + CHAR(13) END 
		+ CASE WHEN ISNULL(strFourthNotifyAddress, '') = '' THEN '' ELSE strFourthNotifyAddress + CHAR(13) END 
		+ CASE WHEN ISNULL(strFourthNotifyCity, '') = '' THEN '' ELSE strFourthNotifyCity + CHAR(13) END 
		+ CASE WHEN ISNULL(strFourthNotifyZipCode, '') = '' THEN '' ELSE strFourthNotifyZipCode + CHAR(13) END 
		+ CASE WHEN ISNULL(strFourthNotifyCountry, '') = '' THEN '' ELSE strFourthNotifyCountry + CHAR(13) END 
		+ CASE WHEN ISNULL(strFourthNotifyMobile, '') = '' THEN '' ELSE 'Mobile: ' + strFourthNotifyMobile + CHAR(13) END 
		+ CASE WHEN ISNULL(strFourthNotifyPhone, '') = '' THEN '' ELSE 'Phone: ' + strFourthNotifyPhone + CHAR(13) END 
		+ CASE WHEN ISNULL(strFourthNotifyFax, '') = '' THEN '' ELSE 'Fax: ' + strFourthNotifyFax + CHAR(13) END 
		+ CASE WHEN ISNULL(strFourthNotifyMail, '') = '' THEN '' ELSE 'E-mail: ' + strFourthNotifyMail + CHAR(13) END 
		+ CASE WHEN ISNULL(strFourthNotifyText, '') = '' THEN '' ELSE strFourthNotifyText END)) 
	,strBOLInstructionText = ISNULL(tbl.strInstructionText, '- All shipment details and purchase contract details as stated above' + CHAR(13) 
			+ '- Gross-, Net- & Tare Weight' + CHAR(13) 
			+ '- In the B/L description of goods: "' + LTRIM(ISNULL(intNumberOfContainers,0)) + ' ' + strPackingDescription + ' container(s) equivalent to ' 
			+ @strContainerQtyUOM + ' each of clean green coffee in '
			+ CASE UPPER(strPackingDescription) WHEN UPPER('Bulk') THEN strPackingDescription ELSE strItemUnitMeasure END 
			+' for any limitation of liability purposes."')
	,strContainerTypePackingDescription = strContainerType + ' in ' + strPackingDescription
	,strQuantityPackingDescription = @strContainerQtyUOM + CASE WHEN (ISNULL(@strPackingUOM, '') <> '') THEN ' in ' + @strPackingUOM ELSE '' END
	,strFullName = @strFullName
	,strUserPhoneNo = @strUserPhoneNo 
	,strUserEmailId = @strUserEmailId
	,strCompanyName = @strCompanyName
	,strCompanyAddress = @strCompanyAddress
	,strCompanyContactName = @strContactName 
	,strCompanyCounty = @strCounty 
	,strCompanyCity = @strCity 
	,strCompanyState = @strState 
	,strCompanyZip = @strZip 
	,strCompanyCountry = @strCountry 
	,strCompanyPhone = @strPhone
	,strCompanyFax = @strFax
	,strCompanyWebSite = @strWeb
	,strCityStateZip = @strCity + ', ' + @strState + ', ' + @strZip + ','
	,strCityAndDate = @strCity + ', '+ DATENAME(dd,getdate()) + ' ' + LEFT(DATENAME(MONTH,getdate()),3) + ' ' + DATENAME(yyyy,getdate())
	,strShipmentPeriod
	,strDestinationCity
	,strMarkingInstruction
	,strConditions = @Condition
FROM (
	SELECT TOP 1 L.intLoadId
		,L.dtmScheduledDate
		,L.strLoadNumber
		,strLSINumber = SI.strLoadNumber
		,L.intShipmentType
		,L.intPurchaseSale
		,L.dtmBLDate
		,L.dtmDeliveredDate
		,CH.strContractNumber
		,CH.strCustomerContract
		,Item.strItemNo
		,strItemDescription = Item.strDescription
		,strItemUnitMeasure = UM.strUnitMeasure
		,strItemOrigin = CA.strDescription
		,strVendor = CASE 
			WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
				THEN DProducer.strName
			WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
				THEN Producer.strName
			ELSE Vendor.strName END
		,strVendorContact = CASE 
			WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
				THEN DPETC.strName
			WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
				THEN PETC.strName
			ELSE VETC.strName END
		,strVendorEmail = Vendor.strEmail
		,strVendorFax = Vendor.strFax
		,strVendorPhone = Vendor.strPhone
		,strVendorMobile = Vendor.strMobile
		,strVendorWebsite = Vendor.strWebsite
		,strVendorAddress = VEL.strAddress
		,strVendorCity = VEL.strCity
		,strVendorCountry = VEL.strCountry
		,strVendorState = VEL.strState
		,strVendorZipCode = VEL.strZipCode
		,strVendorCityStateZip = VEL.strCity  + ' ' + VEL.strState + ' ' + VEL.strZipCode
		,strCustomer = Customer.strName
		,strCustomerContact = CETC.strName
		,strOriginPort = ISNULL(L.strOriginPort, LoadingPort.strCity)
		,strDestinationPort = ISNULL(L.strDestinationPort, DestinationPort.strCity) 
		,strDestinationPortVatNo = (SELECT TOP 1 strVAT FROM tblSMCity WHERE strCity = L.strDestinationPort)
		,strShippingLine = CASE WHEN (ISNULL(SLEL.strCheckPayeeName, '') <> '') THEN SLEL.strCheckPayeeName ELSE SLEntity.strName END
		,L.strServiceContractNumber
		,strServiceContractOwner = SLSC.strOwner
		,SLSC.strFreightClause
		,strShipper = Shipper.strName
		,L.strPackingDescription
		,L.intNumberOfContainers
		,strNumberOfContainers = CONVERT(NVARCHAR, L.intNumberOfContainers) + ' (' + L.strPackingDescription + ')'
		,ContType.strContainerType
		,L.strShippingMode
		,L.strMVessel
		,L.strMVoyageNumber
		,L.strFVessel
		,L.strFVoyageNumber
		,strForwardingAgent = ForAgent.strName
		,strBLDraftToBeSent = BLDraft.strName
		,L.strDocPresentationType
		,strDocPresentationVal = CASE 
			WHEN L.strDocPresentationType = 'Bank' THEN Bank.strBankName
			WHEN L.strDocPresentationType = 'Forwarding Agent' THEN DocPres.strName
			ELSE '' END
		,strDocPresentationAddress = CASE
			WHEN L.strDocPresentationType = 'Bank' THEN Bank.strAddress
			WHEN L.strDocPresentationType = 'Forwarding Agent' THEN DocPresLoc.strAddress
			ELSE '' END
		,strDocPresentationCityStateZip = CASE
			WHEN L.strDocPresentationType = 'Bank' THEN Bank.strCity + ', ' + Bank.strState + ', ' + Bank.strZipCode
			WHEN L.strDocPresentationType = 'Forwarding Agent' THEN DocPresLoc.strCity + ', ' + DocPresLoc.strState + ', ' + DocPresLoc.strZipCode
			ELSE '' END
		,L.dtmETAPOL
		,L.dtmETAPOD
		,L.dtmETSPOL
		,L.dtmDeadlineBL
		,L.dtmDeadlineCargo
		,L.dtmISFFiledDate
		,L.dtmISFReceivedDate
		,L.strVessel1, L.strOriginPort1, L.strDestinationPort1, L.dtmETSPOL1, L.dtmETAPOD1
		,L.strVessel2, L.strOriginPort2, L.strDestinationPort2, L.dtmETSPOL2, L.dtmETAPOD2
		,L.strVessel3, L.strOriginPort3, L.strDestinationPort3, L.dtmETSPOL3, L.dtmETAPOD3
		,L.strVessel4, L.strOriginPort4, L.strDestinationPort4, L.dtmETSPOL4, L.dtmETAPOD4
		,strFirstNotifyText = ISNULL(FLNP.strText, '')
		,strSecondNotifyText = ISNULL(SLNP.strText, '')
		,strThirdNotifyText = ISNULL(TLNP.strText, '')
		,strFourthNotifyText = ISNULL(FtLNP.strText, '')
		,strConsigneeText = ISNULL(CLNP.strText, '')

		,strFirstNotify = ISNULL(CASE 
			WHEN FLNP.strType = 'Bank' THEN FirstNotifyBank.strBankName
			WHEN FLNP.strType = 'Company' THEN FirstNotifyCompany.strCompanyName
			ELSE FirstNotify.strName END, '')
		,strFirstNotifyMail = ISNULL(CASE 
			WHEN FLNP.strType = 'Bank' THEN FirstNotifyBank.strEmail
			WHEN FLNP.strType = 'Company' THEN ISNULL(FNCompanyLocation.strEmail, FirstNotifyCompany.strEmail)
			ELSE FirstNotify.strEmail END, '')
		,strFirstNotifyFax = ISNULL(CASE 
			WHEN FLNP.strType = 'Bank' THEN FirstNotifyBank.strFax
			WHEN FLNP.strType = 'Company' THEN ISNULL(FNCompanyLocation.strFax, FirstNotifyCompany.strFax)
			ELSE FirstNotify.strFax END, '')
		,strFirstNotifyMobile = ISNULL(CASE 
			WHEN FLNP.strType IN ('Bank', 'Company') THEN ''
			ELSE FirstNotify.strMobile END, '')
		,strFirstNotifyPhone = ISNULL(CASE 
			WHEN FLNP.strType = 'Bank' THEN FirstNotifyBank.strPhone
			WHEN FLNP.strType = 'Company' THEN ISNULL(FNCompanyLocation.strPhone, FirstNotifyCompany.strPhone)
			ELSE FirstNotifyContactEntity.strPhone END, '')
		,strFirstNotifyAddress = ISNULL(CASE 
			WHEN FLNP.strType = 'Bank' THEN FirstNotifyBank.strAddress
			WHEN FLNP.strType = 'Company' THEN ISNULL(FNCompanyLocation.strAddress, FirstNotifyCompany.strAddress)
			ELSE FNLocation.strAddress END, '')
		,strFirstNotifyCity = ISNULL(CASE 
			WHEN FLNP.strType = 'Bank' THEN FirstNotifyBank.strCity
			WHEN FLNP.strType = 'Company' THEN ISNULL(FNCompanyLocation.strCity, FirstNotifyCompany.strCity)
			ELSE FNLocation.strCity END, '')
		,strFirstNotifyCountry = ISNULL(CASE 
			WHEN FLNP.strType = 'Bank' THEN FirstNotifyBank.strCountry
			WHEN FLNP.strType = 'Company' THEN ISNULL(FNCompanyLocation.strCountry, FirstNotifyCompany.strCountry)
			ELSE FNLocation.strCountry END, '')
		,strFirstNotifyState = ISNULL(CASE 
			WHEN FLNP.strType = 'Bank' THEN FirstNotifyBank.strState
			WHEN FLNP.strType = 'Company' THEN ''
			ELSE FNLocation.strState END, '')
		,strFirstNotifyZipCode = ISNULL(CASE
			WHEN FLNP.strType = 'Bank' THEN FirstNotifyBank.strZipCode
			WHEN FLNP.strType = 'Company' THEN ISNULL(FNCompanyLocation.strZipPostalCode, FirstNotifyCompany.strZip)
			ELSE FNLocation.strZipCode END, '')

		,strSecondNotify = ISNULL(CASE 
			WHEN SLNP.strType = 'Bank' THEN SecondNotifyBank.strBankName
			WHEN SLNP.strType = 'Company' THEN SecondNotifyCompany.strCompanyName
			ELSE SecondNotify.strName END, '')
		,strSecondNotifyMail = ISNULL(CASE 
			WHEN SLNP.strType = 'Bank' THEN SecondNotifyBank.strEmail
			WHEN SLNP.strType = 'Company' THEN ISNULL(SNCompanyLocation.strEmail, SecondNotifyCompany.strEmail)
			ELSE SecondNotify.strEmail END, '')
		,strSecondNotifyFax = ISNULL(CASE 
			WHEN SLNP.strType = 'Bank' THEN SecondNotifyBank.strFax
			WHEN SLNP.strType = 'Company' THEN ISNULL(SNCompanyLocation.strFax, SecondNotifyCompany.strFax)
			ELSE SecondNotify.strFax END, '')
		,strSecondNotifyMobile = ISNULL(CASE 
			WHEN SLNP.strType IN ('Bank', 'Company') THEN ''
			ELSE SecondNotify.strMobile END, '')
		,strSecondNotifyPhone = ISNULL(CASE 
			WHEN SLNP.strType = 'Bank' THEN SecondNotifyBank.strPhone
			WHEN SLNP.strType = 'Company' THEN ISNULL(SNCompanyLocation.strPhone, SecondNotifyCompany.strPhone)
			ELSE SecondNotifyContactEntity.strPhone END, '')
		,strSecondNotifyAddress = ISNULL(CASE 
			WHEN SLNP.strType = 'Bank' THEN SecondNotifyBank.strAddress
			WHEN SLNP.strType = 'Company' THEN ISNULL(SNCompanyLocation.strAddress, SecondNotifyCompany.strAddress)
			ELSE SNLocation.strAddress END, '')
		,strSecondNotifyCity = ISNULL(CASE 
			WHEN SLNP.strType = 'Bank' THEN SecondNotifyBank.strCity
			WHEN SLNP.strType = 'Company' THEN ISNULL(SNCompanyLocation.strCity, SecondNotifyCompany.strCity)
			ELSE SNLocation.strCity END, '')
		,strSecondNotifyCountry = ISNULL(CASE 
			WHEN SLNP.strType = 'Bank' THEN SecondNotifyBank.strCountry
			WHEN SLNP.strType = 'Company' THEN ISNULL(SNCompanyLocation.strCountry, SecondNotifyCompany.strCountry)
			ELSE SNLocation.strCountry END, '')
		,strSecondNotifyState = ISNULL(CASE 
			WHEN SLNP.strType = 'Bank' THEN SecondNotifyBank.strState
			WHEN SLNP.strType = 'Company' THEN ''
			ELSE SNLocation.strState END, '')
		,strSecondNotifyZipCode = ISNULL(CASE
			WHEN SLNP.strType = 'Bank' THEN SecondNotifyBank.strZipCode
			WHEN SLNP.strType = 'Company' THEN ISNULL(SNCompanyLocation.strZipPostalCode, SecondNotifyCompany.strZip)
			ELSE SNLocation.strZipCode END, '')

		,strThirdNotify = ISNULL(CASE 
			WHEN TLNP.strType = 'Bank' THEN ThirdNotifyBank.strBankName
			WHEN TLNP.strType = 'Company' THEN ThirdNotifyCompany.strCompanyName
			ELSE ThirdNotify.strName END, '')
		,strThirdNotifyMail = ISNULL(CASE 
			WHEN TLNP.strType = 'Bank' THEN ThirdNotifyBank.strEmail
			WHEN TLNP.strType = 'Company' THEN ISNULL(TNCompanyLocation.strEmail, ThirdNotifyCompany.strEmail)
			ELSE ThirdNotify.strEmail END, '')
		,strThirdNotifyFax = ISNULL(CASE 
			WHEN TLNP.strType = 'Bank' THEN ThirdNotifyBank.strFax
			WHEN TLNP.strType = 'Company' THEN ISNULL(TNCompanyLocation.strFax, ThirdNotifyCompany.strFax)
			ELSE ThirdNotify.strFax END, '')
		,strThirdNotifyMobile = ISNULL(CASE 
			WHEN TLNP.strType IN ('Bank', 'Company') THEN ''
			ELSE ThirdNotify.strMobile END, '')
		,strThirdNotifyPhone = ISNULL(CASE 
			WHEN TLNP.strType = 'Bank' THEN ThirdNotifyBank.strPhone
			WHEN TLNP.strType = 'Company' THEN ISNULL(TNCompanyLocation.strPhone, ThirdNotifyCompany.strPhone)
			ELSE ThirdNotifyContactEntity.strPhone END, '')
		,strThirdNotifyAddress = ISNULL(CASE 
			WHEN TLNP.strType = 'Bank' THEN ThirdNotifyBank.strAddress
			WHEN TLNP.strType = 'Company' THEN ISNULL(TNCompanyLocation.strAddress, ThirdNotifyCompany.strAddress)
			ELSE TNLocation.strAddress END, '')
		,strThirdNotifyCity = ISNULL(CASE 
			WHEN TLNP.strType = 'Bank' THEN ThirdNotifyBank.strCity
			WHEN TLNP.strType = 'Company' THEN ISNULL(TNCompanyLocation.strCity, ThirdNotifyCompany.strCity)
			ELSE TNLocation.strCity END, '')
		,strThirdNotifyCountry = ISNULL(CASE 
			WHEN TLNP.strType = 'Bank' THEN ThirdNotifyBank.strCountry
			WHEN TLNP.strType = 'Company' THEN ISNULL(TNCompanyLocation.strCountry, ThirdNotifyCompany.strCountry)
			ELSE TNLocation.strCountry END, '')
		,strThirdNotifyState = ISNULL(CASE 
			WHEN TLNP.strType = 'Bank' THEN ThirdNotifyBank.strState
			WHEN TLNP.strType = 'Company' THEN ''
			ELSE TNLocation.strState END, '')
		,strThirdNotifyZipCode = ISNULL(CASE
			WHEN TLNP.strType = 'Bank' THEN ThirdNotifyBank.strZipCode
			WHEN TLNP.strType = 'Company' THEN ISNULL(TNCompanyLocation.strZipPostalCode, ThirdNotifyCompany.strZip)
			ELSE TNLocation.strZipCode END, '')

		,strFourthNotify = ISNULL(CASE 
			WHEN FtLNP.strType = 'Bank' THEN FourthNotifyBank.strBankName
			WHEN FtLNP.strType = 'Company' THEN FourthNotifyCompany.strCompanyName
			ELSE FourthNotify.strName END, '')
		,strFourthNotifyMail = ISNULL(CASE 
			WHEN FtLNP.strType = 'Bank' THEN FourthNotifyBank.strEmail
			WHEN FtLNP.strType = 'Company' THEN ISNULL(FtNCompanyLocation.strEmail, FourthNotifyCompany.strEmail)
			ELSE FourthNotify.strEmail END, '')
		,strFourthNotifyFax = ISNULL(CASE 
			WHEN FtLNP.strType = 'Bank' THEN FourthNotifyBank.strFax
			WHEN FtLNP.strType = 'Company' THEN ISNULL(FtNCompanyLocation.strFax, FourthNotifyCompany.strFax)
			ELSE FourthNotify.strFax END, '')
		,strFourthNotifyMobile = ISNULL(CASE 
			WHEN FtLNP.strType IN ('Bank', 'Company') THEN ''
			ELSE FourthNotify.strMobile END, '')
		,strFourthNotifyPhone = ISNULL(CASE 
			WHEN FtLNP.strType = 'Bank' THEN FourthNotifyBank.strPhone
			WHEN FtLNP.strType = 'Company' THEN ISNULL(FtNCompanyLocation.strPhone, FourthNotifyCompany.strPhone)
			ELSE FourthNotifyContactEntity.strPhone END, '')
		,strFourthNotifyAddress = ISNULL(CASE 
			WHEN FtLNP.strType = 'Bank' THEN FourthNotifyBank.strAddress
			WHEN FtLNP.strType = 'Company' THEN ISNULL(FtNCompanyLocation.strAddress, FourthNotifyCompany.strAddress)
			ELSE FtNLocation.strAddress END, '')
		,strFourthNotifyCity = ISNULL(CASE 
			WHEN FtLNP.strType = 'Bank' THEN FourthNotifyBank.strCity
			WHEN FtLNP.strType = 'Company' THEN ISNULL(FtNCompanyLocation.strCity, FourthNotifyCompany.strCity)
			ELSE FtNLocation.strCity END, '')
		,strFourthNotifyCountry = ISNULL(CASE 
			WHEN FtLNP.strType = 'Bank' THEN FourthNotifyBank.strCountry
			WHEN FtLNP.strType = 'Company' THEN ISNULL(FtNCompanyLocation.strCountry, FourthNotifyCompany.strCountry)
			ELSE FtNLocation.strCountry END, '')
		,strFourthNotifyState = ISNULL(CASE 
			WHEN FtLNP.strType = 'Bank' THEN FourthNotifyBank.strState
			WHEN FtLNP.strType = 'Company' THEN ''
			ELSE FtNLocation.strState END, '')
		,strFourthNotifyZipCode = ISNULL(CASE
			WHEN FtLNP.strType = 'Bank' THEN FourthNotifyBank.strZipCode
			WHEN FtLNP.strType = 'Company' THEN ISNULL(FtNCompanyLocation.strZipPostalCode, FourthNotifyCompany.strZip)
			ELSE FtNLocation.strZipCode END, '')

		,strConsignee = ISNULL(CASE 
			WHEN CLNP.strType = 'Bank' THEN ConsigneeNotifyBank.strBankName
			WHEN CLNP.strType = 'Company' THEN ConsigneeNotifyCompany.strCompanyName
			ELSE ConsigneeNotify.strName END, '')
		,strConsigneeMail = ISNULL(CASE 
			WHEN CLNP.strType = 'Bank' THEN ConsigneeNotifyBank.strEmail
			WHEN CLNP.strType = 'Company' THEN ISNULL(CNCompanyLocation.strEmail, ConsigneeNotifyCompany.strEmail)
			ELSE ConsigneeNotify.strEmail END, '')
		,strConsigneeFax = ISNULL(CASE 
			WHEN CLNP.strType = 'Bank' THEN ConsigneeNotifyBank.strFax
			WHEN CLNP.strType = 'Company' THEN ISNULL(CNCompanyLocation.strFax, ConsigneeNotifyCompany.strFax)
			ELSE ConsigneeNotify.strFax END, '')
		,strConsigneeMobile = ISNULL(CASE 
			WHEN CLNP.strType IN ('Bank', 'Company') THEN ''
			ELSE ConsigneeNotify.strMobile END, '')
		,strConsigneePhone = ISNULL(CASE 
			WHEN CLNP.strType = 'Bank' THEN ConsigneeNotifyBank.strPhone
			WHEN CLNP.strType = 'Company' THEN ISNULL(CNCompanyLocation.strPhone, ConsigneeNotifyCompany.strPhone)
			ELSE ConsigneeNotifyContactEntity.strPhone END, '')
		,strConsigneeAddress = ISNULL(CASE 
			WHEN CLNP.strType = 'Bank' THEN ConsigneeNotifyBank.strAddress
			WHEN CLNP.strType = 'Company' THEN ISNULL(CNCompanyLocation.strAddress, ConsigneeNotifyCompany.strAddress)
			ELSE CNLocation.strAddress END, '')
		,strConsigneeCity = ISNULL(CASE 
			WHEN CLNP.strType = 'Bank' THEN ConsigneeNotifyBank.strCity
			WHEN CLNP.strType = 'Company' THEN ISNULL(CNCompanyLocation.strCity, ConsigneeNotifyCompany.strCity)
			ELSE CNLocation.strCity END, '')
		,strConsigneeCountry = ISNULL(CASE 
			WHEN CLNP.strType = 'Bank' THEN ConsigneeNotifyBank.strCountry
			WHEN CLNP.strType = 'Company' THEN ISNULL(CNCompanyLocation.strCountry, ConsigneeNotifyCompany.strCountry)
			ELSE CNLocation.strCountry END, '')
		,strConsigneeState = ISNULL(CASE 
			WHEN CLNP.strType = 'Bank' THEN ConsigneeNotifyBank.strState
			WHEN CLNP.strType = 'Company' THEN ''
			ELSE CNLocation.strState END, '')
		,strConsigneeZipCode = ISNULL(CASE
			WHEN CLNP.strType = 'Bank' THEN ConsigneeNotifyBank.strZipCode
			WHEN CLNP.strType = 'Company' THEN ISNULL(CNCompanyLocation.strZipPostalCode, ConsigneeNotifyCompany.strZip)
			ELSE CNLocation.strZipCode END, '')

		,LC.strMarks
		,L.strMarkingInstructions
		,strComments = L.strComments + CHAR(13) + CHAR(13)
		,L.dblDemurrage
		,strDemurrageCurrency = DemCurrency.strCurrency
		,L.dblDespatch
		,strDespatchCurrency = DesCurrency.strCurrency
		,L.dblLoadingRate
		,L.dblDischargeRate
		,strLoadingUnit = LoadUnit.strUnitMeasure
		,strDischargeUnit = DisUnit.strUnitMeasure
		,L.strLoadingPerUnit
		,L.strDischargePerUnit
		,blbHeaderLogo = LOGO.blbHeaderLogo
		,blbFooterLogo = LOGO.blbFooterLogo
		,LOGO.strHeaderLogoType
		,LOGO.strFooterLogoType
		,strShippingInstructionStandardText = (SELECT TOP 1 strShippingInstructionText FROM tblLGCompanyPreference)
		,strContractText = (SELECT TOP 1 strInboundText FROM tblSMCity WHERE strCity = L.strDestinationPort)
		,L.strDestinationCity
		,CD.strERPPONumber
		,CB.strContractBasis
		,CB.strDescription AS strContractBasisDescription
		,blbFullHeaderLogo = dbo.fnSMGetCompanyLogo('FullHeaderLogo')
		,blbFullFooterLogo = dbo.fnSMGetCompanyLogo('FullFooterLogo')
		,ysnFullHeaderLogo = CASE WHEN CP.ysnFullHeaderLogo = 1 THEN 'true' else 'false' end
		,intReportLogoHeight = ISNULL(CP.intReportLogoHeight,0)
		,intReportLogoWidth = ISNULL(CP.intReportLogoWidth,0)			
		,strShipmentPeriod = UPPER(CONVERT(NVARCHAR,CD.dtmStartDate,106)) + ' - ' + UPPER(CONVERT(NVARCHAR,CD.dtmEndDate,106))
		,strMarkingInstruction = L.strMarks
		,strPositionInfo = DATENAME(mm, CD.dtmEndDate) + ' / ' + CAST(DATEPART(yy, CD.dtmEndDate) AS NVARCHAR(10)) + ' ' + POS.strPosition
		,strInstructionText = CASE
			WHEN ISNULL(L.strBOLInstructions, '') != '' 
				THEN L.strBOLInstructions
			WHEN ISNULL(CP.strBOLText, '') != ''
				THEN CP.strBOLText 
			END
		,firstAltShipping.strShippingLine AS strFirstAltShippingLine
		,firstAltShipping.strServiceContractNumber AS strFirstAltSrvContractNo
		,secondAltShipping.strShippingLine AS strSecondAltShippingLine
		,secondAltShipping.strServiceContractNumber AS strSecondAltSrvContractNo
		,strItemRemarks.strRemarks AS strItemRemarks
		,strEntityRemarks.strRemarks AS strEntityRemarks
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblICItem Item ON Item.intItemId = LD.intItemId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE WHEN L.intPurchaseSale = 1 THEN intPContractDetailId ELSE intSContractDetailId END
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblLGLoad SI ON SI.intLoadId = L.intLoadShippingInstructionId
	LEFT JOIN tblEMEntity Producer ON Producer.intEntityId = CH.intProducerId
	LEFT JOIN tblEMEntityToContact PEC ON PEC.intEntityId = Producer.intEntityId
	LEFT JOIN tblEMEntity PETC ON PETC.intEntityId = PEC.intEntityContactId
	LEFT JOIN tblEMEntity DProducer ON DProducer.intEntityId = CD.intProducerId
	LEFT JOIN tblEMEntityToContact DPEC ON DPEC.intEntityId = DProducer.intEntityId
	LEFT JOIN tblEMEntity DPETC ON DPETC.intEntityId = DPEC.intEntityContactId
	LEFT JOIN tblLGLoadContainer LC ON L.intLoadId = LC.intLoadId
	LEFT JOIN tblLGLoadNotifyParties LNP ON LNP.intLoadId = L.intLoadId
	LEFT JOIN tblEMEntity Vendor ON Vendor.intEntityId = LD.intVendorEntityId
	LEFT JOIN tblEMEntityLocation VEL ON VEL.intEntityId = Vendor.intEntityId AND VEL.ysnDefaultLocation = 1
	LEFT JOIN tblEMEntityToContact VEC ON VEC.intEntityId = Vendor.intEntityId
	LEFT JOIN tblEMEntity VETC ON VETC.intEntityId = VEC.intEntityContactId
	LEFT JOIN tblEMEntity Customer ON Customer.intEntityId = LD.intCustomerEntityId
	LEFT JOIN tblEMEntityToContact CEC ON CEC.intEntityId = Customer.intEntityId
	LEFT JOIN tblEMEntity CETC ON CETC.intEntityId = CEC.intEntityContactId
	LEFT JOIN tblEMEntity SLEntity ON SLEntity.intEntityId = L.intShippingLineEntityId
	LEFT JOIN tblEMEntityLocation SLEL ON SLEL.intEntityId = SLEntity.intEntityId AND SLEL.ysnDefaultLocation = 1
	LEFT JOIN tblLGContainerType ContType ON ContType.intContainerTypeId = L.intContainerTypeId
	LEFT JOIN tblEMEntity ForAgent ON ForAgent.intEntityId = L.intForwardingAgentEntityId
	LEFT JOIN tblEMEntity BLDraft ON BLDraft.intEntityId = L.intBLDraftToBeSentId
	LEFT JOIN tblEMEntity DocPres ON DocPres.intEntityId = L.intDocPresentationId
	LEFT JOIN tblEMEntityLocation DocPresLoc ON DocPres.intEntityId = DocPresLoc.intEntityId AND DocPresLoc.ysnDefaultLocation = 1
	LEFT JOIN tblEMEntity Shipper ON Shipper.intEntityId = CD.intShipperId
	LEFT JOIN tblCMBank Bank ON Bank.intBankId = L.intDocPresentationId
	LEFT JOIN tblLGLoadNotifyParties FLNP ON L.intLoadId = FLNP.intLoadId AND FLNP.strNotifyOrConsignee = 'First Notify'
	LEFT JOIN tblLGLoadNotifyParties SLNP ON L.intLoadId = SLNP.intLoadId AND SLNP.strNotifyOrConsignee = 'Second Notify'
	LEFT JOIN tblLGLoadNotifyParties TLNP ON L.intLoadId = TLNP.intLoadId AND TLNP.strNotifyOrConsignee = 'Third Notify'
	LEFT JOIN tblLGLoadNotifyParties FtLNP ON L.intLoadId = FtLNP.intLoadId AND FtLNP.strNotifyOrConsignee = 'Fourth Notify'
	LEFT JOIN tblLGLoadNotifyParties CLNP ON L.intLoadId = CLNP.intLoadId AND CLNP.strNotifyOrConsignee = 'Consignee'

	LEFT JOIN tblEMEntity FirstNotify ON FirstNotify.intEntityId = FLNP.intEntityId
	LEFT JOIN tblEMEntityToContact FirstNotifyContact ON FirstNotifyContact.intEntityId = FirstNotify.intEntityId
	LEFT JOIN tblEMEntity FirstNotifyContactEntity ON FirstNotifyContactEntity.intEntityId = FirstNotifyContact.intEntityContactId
	LEFT JOIN tblCMBank FirstNotifyBank ON FirstNotifyBank.intBankId = FLNP.intBankId
	LEFT JOIN tblSMCompanySetup FirstNotifyCompany ON FirstNotifyCompany.intCompanySetupID = FLNP.intCompanySetupID
	LEFT JOIN tblSMCompanyLocation FNCompanyLocation ON FNCompanyLocation.intCompanyLocationId = FLNP.intCompanyLocationId
	LEFT JOIN tblEMEntityLocation FNLocation ON FNLocation.intEntityLocationId = FLNP.intEntityLocationId

	LEFT JOIN tblEMEntity SecondNotify ON SecondNotify.intEntityId = SLNP.intEntityId
	LEFT JOIN tblEMEntityToContact SecondNotifyContact ON SecondNotifyContact.intEntityId = SecondNotify.intEntityId
	LEFT JOIN tblEMEntity SecondNotifyContactEntity ON SecondNotifyContactEntity.intEntityId = SecondNotifyContact.intEntityContactId
	LEFT JOIN tblCMBank SecondNotifyBank ON SecondNotifyBank.intBankId = SLNP.intBankId
	LEFT JOIN tblSMCompanySetup SecondNotifyCompany ON SecondNotifyCompany.intCompanySetupID = SLNP.intCompanySetupID
	LEFT JOIN tblSMCompanyLocation SNCompanyLocation ON SNCompanyLocation.intCompanyLocationId = SLNP.intCompanyLocationId
	LEFT JOIN tblEMEntityLocation SNLocation ON SNLocation.intEntityLocationId = SLNP.intEntityLocationId

	LEFT JOIN tblEMEntity ThirdNotify ON ThirdNotify.intEntityId = TLNP.intEntityId
	LEFT JOIN tblEMEntityToContact ThirdNotifyContact ON ThirdNotifyContact.intEntityId = ThirdNotify.intEntityId
	LEFT JOIN tblEMEntity ThirdNotifyContactEntity ON ThirdNotifyContactEntity.intEntityId = ThirdNotifyContact.intEntityContactId
	LEFT JOIN tblCMBank ThirdNotifyBank ON ThirdNotifyBank.intBankId = TLNP.intBankId
	LEFT JOIN tblSMCompanySetup ThirdNotifyCompany ON ThirdNotifyCompany.intCompanySetupID = TLNP.intCompanySetupID
	LEFT JOIN tblSMCompanyLocation TNCompanyLocation ON TNCompanyLocation.intCompanyLocationId = TLNP.intCompanyLocationId
	LEFT JOIN tblEMEntityLocation TNLocation ON TNLocation.intEntityLocationId = TLNP.intEntityLocationId	

	LEFT JOIN tblEMEntity FourthNotify ON FourthNotify.intEntityId = FtLNP.intEntityId
	LEFT JOIN tblEMEntityToContact FourthNotifyContact ON FourthNotifyContact.intEntityId = FourthNotify.intEntityId
	LEFT JOIN tblEMEntity FourthNotifyContactEntity ON FourthNotifyContactEntity.intEntityId = FourthNotifyContact.intEntityContactId
	LEFT JOIN tblCMBank FourthNotifyBank ON FourthNotifyBank.intBankId = FtLNP.intBankId
	LEFT JOIN tblSMCompanySetup FourthNotifyCompany ON FourthNotifyCompany.intCompanySetupID = FtLNP.intCompanySetupID
	LEFT JOIN tblSMCompanyLocation FtNCompanyLocation ON FtNCompanyLocation.intCompanyLocationId = FtLNP.intCompanyLocationId
	LEFT JOIN tblEMEntityLocation FtNLocation ON FtNLocation.intEntityLocationId = FtLNP.intEntityLocationId	

	LEFT JOIN tblEMEntity ConsigneeNotify ON ConsigneeNotify.intEntityId = CLNP.intEntityId
	LEFT JOIN tblEMEntityToContact ConsigneeNotifyContact ON ConsigneeNotifyContact.intEntityId = ConsigneeNotify.intEntityId
	LEFT JOIN tblEMEntity ConsigneeNotifyContactEntity ON ConsigneeNotifyContactEntity.intEntityId = ConsigneeNotifyContact.intEntityContactId
	LEFT JOIN tblCMBank ConsigneeNotifyBank ON ConsigneeNotifyBank.intBankId = CLNP.intBankId
	LEFT JOIN tblSMCompanySetup ConsigneeNotifyCompany ON ConsigneeNotifyCompany.intCompanySetupID = CLNP.intCompanySetupID
	LEFT JOIN tblSMCompanyLocation CNCompanyLocation ON CNCompanyLocation.intCompanyLocationId = CLNP.intCompanyLocationId
	LEFT JOIN tblEMEntityLocation CNLocation ON CNLocation.intEntityLocationId = CLNP.intEntityLocationId
	LEFT JOIN tblSMCurrency DemCurrency ON DemCurrency.intCurrencyID = L.intDemurrageCurrencyId
	LEFT JOIN tblSMCurrency DesCurrency ON DesCurrency.intCurrencyID = L.intDespatchCurrencyId
	LEFT JOIN tblICUnitMeasure LoadUnit ON LoadUnit.intUnitMeasureId = L.intLoadingUnitMeasureId
	LEFT JOIN tblICUnitMeasure DisUnit ON DisUnit.intUnitMeasureId = L.intDischargeUnitMeasureId
	LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblSMCity LoadingPort ON LoadingPort.intCityId = CD.intLoadingPortId AND LoadingPort.ysnPort = 1
	LEFT JOIN tblSMCity DestinationPort ON DestinationPort.intCityId = CD.intLoadingPortId AND DestinationPort.ysnPort = 1
	LEFT JOIN tblCTPosition POS ON POS.intPositionId = CH.intPositionId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = Item.intOriginId

	LEFT JOIN vyuLGLoadShippingLineRank firstAltShipping ON L.intLoadId = firstAltShipping.intLoadId AND firstAltShipping.intRank = 2
	LEFT JOIN vyuLGLoadShippingLineRank secondAltShipping ON L.intLoadId = secondAltShipping.intLoadId AND secondAltShipping.intRank = 3

	
	LEFT JOIN tblLGReportRemark strItemRemarks ON 
		strItemRemarks.intValueId = LD.intItemId 
		AND ISNULL(strItemRemarks.intLocationId, 1) = ISNULL(@intPSCompanyLocId,1)
		AND strItemRemarks.strType = 'Item'

	LEFT JOIN tblLGReportRemark strEntityRemarks ON 
		strEntityRemarks.intValueId = LD.intVendorEntityId
		AND ISNULL(strEntityRemarks.intLocationId, 1) = ISNULL(@intVendorCustomerLocId,1)
		AND strEntityRemarks.strType = 'Entity'

	CROSS APPLY tblLGCompanyPreference CP
	OUTER APPLY (SELECT TOP 1 strOwner, strFreightClause FROM tblLGShippingLineServiceContractDetail SLSCD
			 INNER JOIN tblLGShippingLineServiceContract SLSC ON SLSCD.intShippingLineServiceContractId = SLSC.intShippingLineServiceContractId
			 WHERE SLSC.intEntityId = L.intShippingLineEntityId AND SLSCD.strServiceContractNumber = L.strServiceContractNumber) SLSC
	
	OUTER APPLY (
		SELECT TOP 1
			[blbLogo] = imgLogo
		FROM tblSMLogoPreference
		WHERE (ysnAllOtherReports = 1 OR ysnDefault = 1)
			AND intCompanyLocationId = CD.intCompanyLocationId
		ORDER BY (CASE WHEN ysnDefault = 1 THEN 1 ELSE 0 END) DESC
	) CLLH
	OUTER APPLY (
		SELECT TOP 1 [blbLogo] = imgLogo
		FROM tblSMLogoPreferenceFooter
		WHERE (ysnAllOtherReports = 1 OR ysnDefault = 1)
			AND intCompanyLocationId = CD.intCompanyLocationId
		ORDER BY (CASE WHEN ysnDefault = 1 THEN 1 ELSE 0 END) DESC
	) CLLF
	OUTER APPLY (
		SELECT
			blbHeaderLogo = ISNULL(CLLH.blbLogo, dbo.fnSMGetCompanyLogo('Header'))
			,blbFooterLogo = ISNULL(CLLF.blbLogo, dbo.fnSMGetCompanyLogo('Footer'))
			,strHeaderLogoType = CASE WHEN CLLH.blbLogo IS NOT NULL THEN 'Logo' ELSE 'Attachment' END
			,strFooterLogoType = CASE WHEN CLLF.blbLogo IS NOT NULL THEN 'Logo' ELSE 'Attachment' END
	) LOGO

	WHERE L.intLoadId = @intLoadId
	) tbl
END