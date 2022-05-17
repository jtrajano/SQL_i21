CREATE PROCEDURE [dbo].[uspLGGetInboundShipmentReport]
		@xmlParam NVARCHAR(MAX) = NULL  
AS
BEGIN
	DECLARE @intTrackingNumber			INT,
			@strTrackingNumber			NVARCHAR(50),
			@intLoadWarehouseId			INT,
			@xmlDocumentId				INT 
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
			@strWebSite					NVARCHAR(500),
			@strFullName				NVARCHAR(100),
			@strUserPhoneNo				NVARCHAR(100),
			@strUserEmailId				NVARCHAR(100),
			@strUserName				NVARCHAR(100),
			@strLogisticsCompanyName	NVARCHAR(MAX),
			@strLogisticsPrintSignOff	NVARCHAR(MAX),
			@intCompanyLocationId		INT,
			@strInstoreTo				NVARCHAR(MAX),
			@strReleaseOrderText		NVARCHAR(MAX),
			@strWarehouseEntityName		NVARCHAR(MAX),
			@strShippingLineName		NVARCHAR(MAX)
			
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

	SELECT	@strTrackingNumber = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'strTrackingNumber' 

	SELECT	@intLoadWarehouseId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intLoadWarehouseId' 

	SELECT	@strUserName = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'strUserName' 
	
	SELECT	@intCompanyLocationId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intCompanyLocationId' 
	
	SELECT	@strInstoreTo = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'strInstoreTo' 

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
				,@strWebSite = strWebSite
	FROM tblSMCompanySetup

	SELECT @strFullName = E.strName,
		   @strUserEmailId = ETC.strEmail,
		   @strUserPhoneNo = EPN.strPhone  FROM tblSMUserSecurity S
	JOIN tblEMEntity E ON E.intEntityId = S.intEntityId 
	JOIN tblEMEntityToContact EC ON EC.intEntityId = E.intEntityId
	JOIN tblEMEntity ETC ON ETC.intEntityId = EC.intEntityContactId
	JOIN tblEMEntityPhoneNumber EPN ON EPN.intEntityId = ETC.intEntityId
	WHERE strUserName = @strUserName

	SELECT @strWarehouseEntityName = CASE 
			WHEN ISNULL(E.strName, '') = ''
				THEN CLSL.strSubLocationName
			ELSE E.strName
			END
	FROM tblSMCompanyLocationSubLocation CLSL
	JOIN tblEMEntity E ON E.intEntityId = CLSL.intVendorId
	LEFT JOIN tblLGLoadWarehouse LW ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
	WHERE LW.intLoadWarehouseId = @intLoadWarehouseId
	
	SELECT @strShippingLineName = CASE WHEN (ISNULL(SLLocation.strCheckPayeeName, '') <> '') THEN SLLocation.strCheckPayeeName ELSE E.strName END
	FROM tblLGLoad L
	JOIN tblEMEntity E ON E.intEntityId = L.intShippingLineEntityId
	JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
	LEFT JOIN tblEMEntityLocation SLLocation ON SLLocation.intEntityId = L.intShippingLineEntityId and SLLocation.ysnDefaultLocation = 1
	WHERE LW.intLoadWarehouseId = @intLoadWarehouseId

	SELECT @strReleaseOrderText = 'Attn '+ ISNULL(@strShippingLineName,'') +' : Please release the cargo in favour of ' + @strWarehouseEntityName
	
	SELECT @strLogisticsCompanyName = strLogisticsCompanyName,
		   @strLogisticsPrintSignOff = strLogisticsPrintSignOff
	FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intCompanyLocationId

IF ISNULL(@intLoadWarehouseId,0) = 0 
	BEGIN
	SELECT *	
		,strConsigneeInfo = LTRIM(RTRIM(
			CASE WHEN ISNULL(strConsigneeText, '') = '' THEN '' ELSE strConsigneeText + CHAR(13) END 
			+ CASE WHEN ISNULL(strConsignee, '') = '' THEN '' ELSE strConsignee + CHAR(13) END 
			+ CASE WHEN ISNULL(strConsigneeAddress, '') = '' THEN '' ELSE strConsigneeAddress + CHAR(13) END 
			+ CASE WHEN ISNULL(strConsigneeCity, '') = '' THEN '' ELSE strConsigneeCity + CHAR(13) END 
			+ CASE WHEN ISNULL(strConsigneeZipCode, '') = '' THEN '' ELSE strConsigneeZipCode + CHAR(13) END 
			+ CASE WHEN ISNULL(strConsigneeCountry, '') = '' THEN '' ELSE strConsigneeCountry + CHAR(13) END 
			+ CASE WHEN ISNULL(strConsigneeMobile, '') = '' THEN '' ELSE 'Mobile: ' + strConsigneeMobile + CHAR(13) END 
			+ CASE WHEN ISNULL(strConsigneePhone, '') = '' THEN '' ELSE 'Phone: ' + strConsigneePhone + CHAR(13) END 
			+ CASE WHEN ISNULL(strConsigneeFax, '') = '' THEN '' ELSE 'Fax: ' + strConsigneeFax + CHAR(13) END 
			+ CASE WHEN ISNULL(strConsigneeMail, '') = '' THEN '' ELSE 'E-mail: ' + strConsigneeMail END))
		,strFirstNotifyInfo = LTRIM(RTRIM(
			CASE WHEN ISNULL(strFirstNotifyText, '') = '' THEN '' ELSE strFirstNotifyText + CHAR(13) END 
			+ CASE WHEN ISNULL(strFirstNotify, '') = '' THEN '' ELSE strFirstNotify + CHAR(13) END 
			+ CASE WHEN ISNULL(strFirstNotifyAddress, '') = '' THEN '' ELSE strFirstNotifyAddress + CHAR(13) END 
			+ CASE WHEN ISNULL(strFirstNotifyCity, '') = '' THEN '' ELSE strFirstNotifyCity + CHAR(13) END 
			+ CASE WHEN ISNULL(strFirstNotifyZipCode, '') = '' THEN '' ELSE strFirstNotifyZipCode + CHAR(13) END 
			+ CASE WHEN ISNULL(strFirstNotifyCountry, '') = '' THEN '' ELSE strFirstNotifyCountry + CHAR(13) END 
			+ CASE WHEN ISNULL(strFirstNotifyMobile, '') = '' THEN '' ELSE 'Mobile: ' + strFirstNotifyMobile + CHAR(13) END 
			+ CASE WHEN ISNULL(strFirstNotifyPhone, '') = '' THEN '' ELSE 'Phone: ' + strFirstNotifyPhone + CHAR(13) END 
			+ CASE WHEN ISNULL(strFirstNotifyFax, '') = '' THEN '' ELSE 'Fax: ' + strFirstNotifyFax + CHAR(13) END 
			+ CASE WHEN ISNULL(strFirstNotifyMail, '') = '' THEN '' ELSE 'E-mail: ' + strFirstNotifyMail END))
		,strSecondNotifyInfo = LTRIM(RTRIM(
			CASE WHEN ISNULL(strSecondNotifyText, '') = '' THEN '' ELSE strSecondNotifyText + CHAR(13) END 
			+ CASE WHEN ISNULL(strSecondNotify, '') = '' THEN '' ELSE strSecondNotify + CHAR(13) END 
			+ CASE WHEN ISNULL(strSecondNotifyAddress, '') = '' THEN '' ELSE strSecondNotifyAddress + CHAR(13) END 
			+ CASE WHEN ISNULL(strSecondNotifyCity, '') = '' THEN '' ELSE strSecondNotifyCity + CHAR(13) END 
			+ CASE WHEN ISNULL(strSecondNotifyZipCode, '') = '' THEN '' ELSE strSecondNotifyZipCode + CHAR(13) END 
			+ CASE WHEN ISNULL(strSecondNotifyCountry, '') = '' THEN '' ELSE strSecondNotifyCountry + CHAR(13) END 
			+ CASE WHEN ISNULL(strSecondNotifyMobile, '') = '' THEN '' ELSE 'Mobile: ' + strSecondNotifyMobile + CHAR(13) END 
			+ CASE WHEN ISNULL(strSecondNotifyPhone, '') = '' THEN '' ELSE 'Phone: ' + strSecondNotifyPhone + CHAR(13) END 
			+ CASE WHEN ISNULL(strSecondNotifyFax, '') = '' THEN '' ELSE 'Fax: ' + strSecondNotifyFax + CHAR(13) END 
			+ CASE WHEN ISNULL(strSecondNotifyMail, '') = '' THEN '' ELSE 'E-mail: ' + strSecondNotifyMail END))
		,strThirdNotifyInfo = LTRIM(RTRIM(
			CASE WHEN ISNULL(strThirdNotifyText, '') = '' THEN '' ELSE strThirdNotifyText + CHAR(13) END 
			+ CASE WHEN ISNULL(strThirdNotify, '') = '' THEN '' ELSE strThirdNotify + CHAR(13) END 
			+ CASE WHEN ISNULL(strThirdNotifyAddress, '') = '' THEN '' ELSE strThirdNotifyAddress + CHAR(13) END 
			+ CASE WHEN ISNULL(strThirdNotifyCity, '') = '' THEN '' ELSE strThirdNotifyCity + CHAR(13) END 
			+ CASE WHEN ISNULL(strThirdNotifyZipCode, '') = '' THEN '' ELSE strThirdNotifyZipCode + CHAR(13) END 
			+ CASE WHEN ISNULL(strThirdNotifyCountry, '') = '' THEN '' ELSE strThirdNotifyCountry + CHAR(13) END 
			+ CASE WHEN ISNULL(strThirdNotifyMobile, '') = '' THEN '' ELSE 'Mobile: ' + strThirdNotifyMobile + CHAR(13) END 
			+ CASE WHEN ISNULL(strThirdNotifyPhone, '') = '' THEN '' ELSE 'Phone: ' + strThirdNotifyPhone + CHAR(13) END 
			+ CASE WHEN ISNULL(strThirdNotifyFax, '') = '' THEN '' ELSE 'Fax: ' + strThirdNotifyFax + CHAR(13) END 
			+ CASE WHEN ISNULL(strThirdNotifyMail, '') = '' THEN '' ELSE 'E-mail: ' + strThirdNotifyMail END))
	FROM (
		SELECT TOP 1
			strTrackingNumber = L.strLoadNumber,
			L.intPurchaseSale,
			LW.strDeliveryNoticeNumber, 
			LW.dtmDeliveryNoticeDate,
			LW.dtmDeliveryDate,
			LW.intSubLocationId,
			L.intShippingLineEntityId,
			LW.dtmPickupDate,
			LW.dtmLastFreeDate,
			LW.dtmEmptyContainerReturn,
			LW.dtmStrippingReportReceivedDate,
			LW.dtmSampleAuthorizedDate,
			LW.strStrippingReportComments,
			LW.strFreightComments,
			LW.strSampleComments,
			LW.strOtherComments,
			strOriginCountry = PCountry.strCountry,
			L.strOriginPort,
			L.strDestinationPort,
			L.strDestinationCity,
			dtmBLDate = LW.dtmDeliveryDate,
			L.strBLNumber,
			L.dtmScheduledDate,
			L.dtmETAPOL,
			L.dtmETAPOD,
			L.dtmETSPOL,
			strMVessel = CASE WHEN ISNULL(L.strMVessel, '') = '' THEN L.strVessel1 ELSE L.strMVessel END,
			L.strFVessel,
			L.strMVoyageNumber,
			L.strFVoyageNumber,
			L.strComments,
			ysnHasTransshipment = CAST(CASE WHEN ISNULL(L.strVessel1, '') <> '' AND ISNULL(L.strVessel2, '') <> '' THEN 1 ELSE 0 END AS BIT),
			L.strVessel1, L.dtmETAPOD1, L.dtmETSPOL1, L.strOriginPort1, L.strDestinationPort1,
			L.strVessel2, L.dtmETAPOD2, L.dtmETSPOL2, L.strOriginPort2, L.strDestinationPort2,
			L.strVessel3, L.dtmETAPOD3, L.dtmETSPOL3, L.strOriginPort3, L.strDestinationPort3,
			L.strVessel4, L.dtmETAPOD4, L.dtmETSPOL4, L.strOriginPort4, L.strDestinationPort4,
			L.dblInsuranceValue,
			L.intInsuranceCurrencyId,
			InsuranceCur.strCurrency,

  			strVendor = Vendor.strName,
			strVendorEmail = Vendor.strEmail,
			strVendorFax = Vendor.strFax,
			strVendorPhone = Vendor.strPhone,
			strVendorMobile = Vendor.strMobile,
			strVendorWebsite = Vendor.strWebsite,
			strVendorAddress = VLocation.strAddress,
			strVendorCity = VLocation.strCity,
			strVendorCountry = VLocation.strCountry,
			strVendorState = VLocation.strState,
			strVendorZipCode = VLocation.strZipCode,

  			strCustomer = Customer.strName,
			strCustomerEmail = CustomerContactEntity.strEmail,
			strCustomerFax = Customer.strFax,
			strCustomerPhone = CustomerContactEntity.strPhone,
			strCustomerMobile = CustomerContactEntity.strMobile,
			strCustomerWebsite = Customer.strWebsite,
			strCustomerAddress = CLocation.strAddress,
			strCustomerCity = CLocation.strCity,
			strCustomerCountry = CLocation.strCountry,
			strCustomerState = CLocation.strState,
			strCustomerZipCode = CLocation.strZipCode,

  			strShippingLine = CASE WHEN (ISNULL(SLLocation.strCheckPayeeName, '') <> '') THEN SLLocation.strCheckPayeeName ELSE SLEntity.strName END,
			strShippingLineEmail = SLEntity.strEmail,
			strShippingLineFax = SLEntity.strFax,
			strShippingLinePhone = SLEntity.strPhone,
			strShippingLineMobile = SLEntity.strMobile,
			strShippingLineWebsite = SLEntity.strWebsite,
			strShippingLineAddress = SLLocation.strAddress,
			strShippingLineCity = SLLocation.strCity,
			strShippingLineCountry = SLLocation.strCountry,
			strShippingLineState = SLLocation.strState,
			strShippingLineZipCode = SLLocation.strZipCode,
			strShippingLineWithAddress = CASE WHEN (ISNULL(SLLocation.strCheckPayeeName, '') <> '') THEN SLLocation.strCheckPayeeName ELSE SLEntity.strName END + ', ' + ISNULL(SLLocation.strAddress,''),

			strTerminal = TerminalEntity.strName,
			strTerminalEmail = TerminalEntity.strEmail,
			strTerminalFax = TerminalEntity.strFax,
			strTerminalPhone = TerminalEntity.strPhone,
			strTerminalMobile = TerminalEntity.strMobile,
			strTerminalWebsite = TerminalEntity.strWebsite,
			strTerminalAddress = TerminalLocation.strAddress,
			strTerminalCity = TerminalLocation.strCity,
			strTerminalCountry = TerminalLocation.strCountry,
			strTerminalState = TerminalLocation.strState,
			strTerminalZipCode = TerminalLocation.strZipCode,

			strInsurer = InsurEntity.strName,
			strInsurerEmail = InsurEntity.strEmail,
			strInsurerFax = InsurEntity.strFax,
			strInsurerPhone = InsurEntity.strPhone,
			strInsurerMobile = InsurEntity.strMobile,
			strInsurerWebsite = InsurEntity.strWebsite,
			strInsurerAddress = InsurLocation.strAddress,
			strInsurerCity = InsurLocation.strCity,
			strInsurerCountry = InsurLocation.strCountry,
			strInsurerState = InsurLocation.strState,
			strInsurerZipCode = InsurLocation.strZipCode,

			strShipper = Shipper.strName,
			strShipperEmail = Shipper.strEmail,
			strShipperFax = Shipper.strFax,
			strShipperPhone = Shipper.strPhone,
			strShipperMobile = Shipper.strMobile,
			strShipperWebsite = Shipper.strWebsite,
			strShipperAddress = SpLocation.strAddress,
			strShipperCity = SpLocation.strCity,
			strShipperCountry = SpLocation.strCountry,
			strShipperState = SpLocation.strState,
			strShipperZipCode = SpLocation.strZipCode,

			strWarehouse = WH.strSubLocationName,
			strWarehouseDescription = WH.strSubLocationDescription,
			strWarehouseAddress = WH.strAddress,
			strWarehouseCity = WH.strCity,
			strWarehouseClassification = WH.strClassification,
			strWarehouseState = WH.strState,
			strWarehouseZipCode = WH.strZipCode,
			strInStoreLetter = CP.strReleaseOrderText,

			WI.intWarehouseInstructionHeaderId,
			LW.intLoadWarehouseId,
			Via.strName strShipVia,
			blbHeaderLogo = dbo.fnSMGetCompanyLogo('Header'),
			blbFooterLogo = dbo.fnSMGetCompanyLogo('Footer'),
			strCompanyName = @strCompanyName,
			strCompanyAddress = @strCompanyAddress,
			strCompanyContactName = @strContactName,
			strCompanyCounty = @strCounty,
			strCompanyCity = @strCity,
			strCompanyState = @strState,
			strCompanyZip = @strZip,
			strCompanyCountry = @strCountry,
			strCompanyPhone = @strPhone,
			strCompanyFax = @strFax,
			strCompanyWebSite = @strWebSite,
			strCityStateZip = @strCity + ', ' + @strState + ', ' + @strZip + ',',
			strUserFullName = CASE WHEN ISNULL(@strFullName,'') = '' THEN  @strUserName ELSE @strFullName END,
			strExternalPONumber = CD.strERPPONumber,
			strNumberOfContainers = CONVERT(NVARCHAR,L.intNumberOfContainers) + ' (' + L.strPackingDescription +')',
			CType.strContainerType,
			strLogisticsCompanyName = @strLogisticsCompanyName,
			strLogisticsPrintSignOff = @strLogisticsPrintSignOff,
			strWarehouseContact = CASE WHEN @strInstoreTo = 'Shipping Line' THEN SLETC.strName ELSE WETC.strName END,
			strInstoreTo = @strInstoreTo,
			strReleaseOrderText = CASE WHEN @strInstoreTo = 'Shipping Line' THEN @strReleaseOrderText ELSE NULL END,
			strDefaultReleaseOrderText = CP.strReleaseOrderText,
			strPCustomerContract = PCH.strCustomerContract,
			strSalesContractNumber = SCH.strContractNumber,
			intSalesContractSeq = SCD.intContractSeq,

			strWarehouseVendorName = '', 
			strWarehouseVendorLocation = '', 
			strWarehouseVendorAddress = '', 
			strWarehouseVendorCity = '', 
			strWarehouseVendorState = '', 
			strWarehouseVendorZipCode = '', 
			strWarehouseVendorCountry = '', 
			strPhone = '', 
			strMobile = '', 
			strWarehouseVendorContract = '', 
			strWarehouseVendorContactPhone = '', 
			strWarehouseVendorContactEmail = '', 

			strWarehouseAddressInfo = '',
			strWarehouseContractInfo = '',
			intContractBasisId = CASE WHEN (ISNULL(PL.intSContractDetailId, LD.intSContractDetailId) IS NOT NULL) THEN SCH.intFreightTermId ELSE NULL END,
			strContractBasis = CASE WHEN (ISNULL(PL.intSContractDetailId, LD.intSContractDetailId) IS NOT NULL) THEN SCB.strContractBasis ELSE '' END,
			strContractBasisDescription = CASE WHEN (ISNULL(PL.intSContractDetailId, LD.intSContractDetailId) IS NOT NULL) THEN SCB.strDescription ELSE '' END,
			strWeightTerms = '',
			strUserEmailId = '',
			strUserPhoneNo = '',
			L.strShippingMode,
			strPickLotNumber = ISNULL(PL.strPickLotNumber, ''),
			PL.strPickComments,
			strCertificationName = (SELECT TOP 1 strCertificationName
									FROM tblICCertification CER
									JOIN tblCTContractCertification CTCER ON CTCER.intCertificationId = CER.intCertificationId
									WHERE CTCER.intContractDetailId = CD.intContractDetailId),
			blbFullHeaderLogo = dbo.fnSMGetCompanyLogo('FullHeaderLogo'),
			blbFullFooterLogo = dbo.fnSMGetCompanyLogo('FullFooterLogo'),
			ysnFullHeaderLogo = CASE WHEN CP.ysnFullHeaderLogo = 1 THEN 'true' else 'false' END,
			intReportLogoHeight = ISNULL(CP.intReportLogoHeight,0),
			intReportLogoWidth = ISNULL(CP.intReportLogoWidth,0),
			strFirstNotifyText = FLNP.strText,
			strSecondNotifyText = SLNP.strText,
			strThirdNotifyText = TLNP.strText,
			strConsigneeText = ISNULL(CLNP.strText, ''),

			strFirstNotify = CASE 
				WHEN FLNP.strType = 'Bank' THEN ISNULL(FirstNotifyBank.strBankName, '')
				WHEN FLNP.strType = 'Company' THEN ISNULL(FirstNotifyCompany.strCompanyName, '')
				WHEN FLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(FirstNotify.strName, '')
				ELSE '' END,
			strFirstNotifyMail = CASE 
				WHEN FLNP.strType = 'Bank' THEN ISNULL(FirstNotifyBank.strEmail, '')
				WHEN FLNP.strType = 'Company' THEN ISNULL(FNCompanyLocation.strEmail, FirstNotifyCompany.strEmail)
				WHEN FLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(FirstNotify.strEmail, '')
				ELSE '' END,
			strFirstNotifyFax = CASE 
				WHEN FLNP.strType = 'Bank' THEN ISNULL(FirstNotifyBank.strFax, '')
				WHEN FLNP.strType = 'Company' THEN ISNULL(FNCompanyLocation.strFax, FirstNotifyCompany.strFax)
				WHEN FLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(FirstNotify.strFax, '')
				ELSE '' END,
			strFirstNotifyMobile = CASE 
				WHEN FLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(FirstNotify.strMobile, '')
				ELSE '' END,
			strFirstNotifyPhone = CASE
				WHEN FLNP.strType = 'Bank' THEN ISNULL(FirstNotifyBank.strPhone, '')
				WHEN FLNP.strType = 'Company' THEN ISNULL(FNCompanyLocation.strPhone, FirstNotifyCompany.strPhone)
				WHEN FLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(FirstNotifyContactEntity.strPhone, '')
				ELSE '' END,
			strFirstNotifyAddress = CASE 
				WHEN FLNP.strType = 'Bank' THEN ISNULL(FirstNotifyBank.strAddress, '')
				WHEN FLNP.strType = 'Company' THEN ISNULL(FNCompanyLocation.strAddress, FirstNotifyCompany.strAddress)
				WHEN FLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(FNLocation.strAddress, '')
				ELSE '' END,
			strFirstNotifyCity = CASE 
				WHEN FLNP.strType = 'Bank' THEN ISNULL(FirstNotifyBank.strCity, '')
				WHEN FLNP.strType = 'Company' THEN ISNULL(FNCompanyLocation.strCity, FirstNotifyCompany.strCity)
				WHEN FLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(FNLocation.strCity, '')
				ELSE '' END,
			strFirstNotifyCountry = CASE 
				WHEN FLNP.strType = 'Bank' THEN ISNULL(FirstNotifyBank.strCountry, '')
				WHEN FLNP.strType = 'Company' THEN ISNULL(FNCompanyLocation.strCountry, FirstNotifyCompany.strCountry)
				WHEN FLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(FNLocation.strCountry, '')
				ELSE '' END,
			strFirstNotifyState = CASE
				WHEN FLNP.strType = 'Bank' THEN ISNULL(FirstNotifyBank.strState, '')
				WHEN FLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(FNLocation.strState, '')
				ELSE '' END,
			strFirstNotifyZipCode = CASE
				WHEN FLNP.strType = 'Bank' THEN ISNULL(FirstNotifyBank.strZipCode, '')
				WHEN FLNP.strType = 'Company' THEN ISNULL(FNCompanyLocation.strZipPostalCode, FirstNotifyCompany.strZip)
				WHEN FLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(FNLocation.strZipCode, '')
				ELSE '' END,

			strSecondNotify = CASE 
				WHEN SLNP.strType = 'Bank' THEN ISNULL(SecondNotifyBank.strBankName, '')
				WHEN SLNP.strType = 'Company' THEN ISNULL(SecondNotifyCompany.strCompanyName, '')
				WHEN SLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(SecondNotify.strName, '')
				ELSE '' END,
			strSecondNotifyMail = CASE 
				WHEN SLNP.strType = 'Bank' THEN ISNULL(SecondNotifyBank.strEmail, '')
				WHEN SLNP.strType = 'Company' THEN ISNULL(SNCompanyLocation.strEmail, SecondNotifyCompany.strEmail)
				WHEN SLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(SecondNotify.strEmail, '')
				ELSE '' END,
			strSecondNotifyFax = CASE 
				WHEN SLNP.strType = 'Bank' THEN ISNULL(SecondNotifyBank.strFax, '')
				WHEN SLNP.strType = 'Company' THEN ISNULL(SNCompanyLocation.strFax, SecondNotifyCompany.strFax)
				WHEN SLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(SecondNotify.strFax, '')
				ELSE '' END,
			strSecondNotifyMobile = CASE 
				WHEN SLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(SecondNotify.strMobile, '')
				ELSE '' END,
			strSecondNotifyPhone = CASE
				WHEN SLNP.strType = 'Bank' THEN ISNULL(SecondNotifyBank.strPhone, '')
				WHEN SLNP.strType = 'Company' THEN ISNULL(SNCompanyLocation.strPhone, SecondNotifyCompany.strPhone)
				WHEN SLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(SecondNotifyContactEntity.strPhone, '')
				ELSE '' END,
			strSecondNotifyAddress = CASE 
				WHEN SLNP.strType = 'Bank' THEN ISNULL(SecondNotifyBank.strAddress, '')
				WHEN SLNP.strType = 'Company' THEN ISNULL(SNCompanyLocation.strAddress, SecondNotifyCompany.strAddress)
				WHEN SLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(SNLocation.strAddress, '')
				ELSE '' END,
			strSecondNotifyCity = CASE 
				WHEN SLNP.strType = 'Bank' THEN ISNULL(SecondNotifyBank.strCity, '')
				WHEN SLNP.strType = 'Company' THEN ISNULL(SNCompanyLocation.strCity, SecondNotifyCompany.strCity)
				WHEN SLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(SNLocation.strCity, '')
				ELSE '' END,
			strSecondNotifyCountry = CASE 
				WHEN SLNP.strType = 'Bank' THEN ISNULL(SecondNotifyBank.strCountry, '')
				WHEN SLNP.strType = 'Company' THEN ISNULL(SNCompanyLocation.strCountry, SecondNotifyCompany.strCountry)
				WHEN SLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(SNLocation.strCountry, '')
				ELSE '' END,
			strSecondNotifyState = CASE
				WHEN SLNP.strType = 'Bank' THEN ISNULL(SecondNotifyBank.strState, '')
				WHEN SLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(SNLocation.strState, '')
				ELSE '' END,
			strSecondNotifyZipCode = CASE
				WHEN SLNP.strType = 'Bank' THEN ISNULL(SecondNotifyBank.strZipCode, '')
				WHEN SLNP.strType = 'Company' THEN ISNULL(SNCompanyLocation.strZipPostalCode, SecondNotifyCompany.strZip)
				WHEN SLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(SNLocation.strZipCode, '')
				ELSE '' END,

			strThirdNotify = CASE 
				WHEN TLNP.strType = 'Bank' THEN ISNULL(ThirdNotifyBank.strBankName, '')
				WHEN TLNP.strType = 'Company' THEN ISNULL(ThirdNotifyCompany.strCompanyName, '')
				WHEN TLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(ThirdNotify.strName, '')
				ELSE '' END,
			strThirdNotifyMail = CASE 
				WHEN TLNP.strType = 'Bank' THEN ISNULL(ThirdNotifyBank.strEmail, '')
				WHEN TLNP.strType = 'Company' THEN ISNULL(TNCompanyLocation.strEmail, ThirdNotifyCompany.strEmail)
				WHEN TLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(ThirdNotify.strEmail, '')
				ELSE '' END,
			strThirdNotifyFax = CASE 
				WHEN TLNP.strType = 'Bank' THEN ISNULL(ThirdNotifyBank.strFax, '')
				WHEN TLNP.strType = 'Company' THEN ISNULL(TNCompanyLocation.strFax, ThirdNotifyCompany.strFax)
				WHEN TLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(ThirdNotify.strFax, '')
				ELSE '' END,
			strThirdNotifyMobile = CASE 
				WHEN TLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(ThirdNotify.strMobile, '')
				ELSE '' END,
			strThirdNotifyPhone = CASE
				WHEN TLNP.strType = 'Bank' THEN ISNULL(ThirdNotifyBank.strPhone, '')
				WHEN TLNP.strType = 'Company' THEN ISNULL(TNCompanyLocation.strPhone, ThirdNotifyCompany.strPhone)
				WHEN TLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(ThirdNotifyContactEntity.strPhone, '')
				ELSE '' END,
			strThirdNotifyAddress = CASE 
				WHEN TLNP.strType = 'Bank' THEN ISNULL(ThirdNotifyBank.strAddress, '')
				WHEN TLNP.strType = 'Company' THEN ISNULL(TNCompanyLocation.strAddress, ThirdNotifyCompany.strAddress)
				WHEN TLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(TNLocation.strAddress, '')
				ELSE '' END,
			strThirdNotifyCity = CASE 
				WHEN TLNP.strType = 'Bank' THEN ISNULL(ThirdNotifyBank.strCity, '')
				WHEN TLNP.strType = 'Company' THEN ISNULL(TNCompanyLocation.strCity, ThirdNotifyCompany.strCity)
				WHEN TLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(TNLocation.strCity, '')
				ELSE '' END,
			strThirdNotifyCountry = CASE 
				WHEN TLNP.strType = 'Bank' THEN ISNULL(ThirdNotifyBank.strCountry, '')
				WHEN TLNP.strType = 'Company' THEN ISNULL(TNCompanyLocation.strCountry, ThirdNotifyCompany.strCountry)
				WHEN TLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(TNLocation.strCountry, '')
				ELSE '' END,
			strThirdNotifyState = CASE
				WHEN TLNP.strType = 'Bank' THEN ISNULL(ThirdNotifyBank.strState, '')
				WHEN TLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(TNLocation.strState, '')
				ELSE '' END,
			strThirdNotifyZipCode = CASE
				WHEN TLNP.strType = 'Bank' THEN ISNULL(ThirdNotifyBank.strZipCode, '')
				WHEN TLNP.strType = 'Company' THEN ISNULL(TNCompanyLocation.strZipPostalCode, ThirdNotifyCompany.strZip)
				WHEN TLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(TNLocation.strZipCode, '')
				ELSE '' END,

			strConsignee = CASE 
				WHEN CLNP.strType = 'Bank' THEN ISNULL(ConsigneeNotifyBank.strBankName, '')
				WHEN CLNP.strType = 'Company' THEN ISNULL(ConsigneeNotifyCompany.strCompanyName, '')
				WHEN CLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(ConsigneeNotify.strName, '')
				ELSE '' END,
			strConsigneeMail = CASE 
				WHEN CLNP.strType = 'Bank' THEN ISNULL(ConsigneeNotifyBank.strEmail, '')
				WHEN CLNP.strType = 'Company' THEN ISNULL(CNCompanyLocation.strEmail, ConsigneeNotifyCompany.strEmail)
				WHEN CLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(ConsigneeNotify.strEmail, '')
				ELSE '' END,
			strConsigneeFax = CASE 
				WHEN CLNP.strType = 'Bank' THEN ISNULL(ConsigneeNotifyBank.strFax, '')
				WHEN CLNP.strType = 'Company' THEN ISNULL(CNCompanyLocation.strFax, ConsigneeNotifyCompany.strFax)
				WHEN CLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(ConsigneeNotify.strFax, '')
				ELSE '' END,
			strConsigneeMobile = CASE 
				WHEN CLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(ConsigneeNotify.strMobile, '')
				ELSE '' END,
			strConsigneePhone = CASE
				WHEN CLNP.strType = 'Bank' THEN ISNULL(ConsigneeNotifyBank.strPhone, '')
				WHEN CLNP.strType = 'Company' THEN ISNULL(CNCompanyLocation.strPhone, ConsigneeNotifyCompany.strPhone)
				WHEN CLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(ConsigneeNotifyContactEntity.strPhone, '')
				ELSE '' END,
			strConsigneeAddress = CASE 
				WHEN CLNP.strType = 'Bank' THEN ISNULL(ConsigneeNotifyBank.strAddress, '')
				WHEN CLNP.strType = 'Company' THEN ISNULL(CNCompanyLocation.strAddress, ConsigneeNotifyCompany.strAddress)
				WHEN CLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(CNLocation.strAddress, '')
				ELSE '' END,
			strConsigneeCity = CASE 
				WHEN CLNP.strType = 'Bank' THEN ISNULL(ConsigneeNotifyBank.strCity, '')
				WHEN CLNP.strType = 'Company' THEN ISNULL(CNCompanyLocation.strCity, ConsigneeNotifyCompany.strCity)
				WHEN CLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(CNLocation.strCity, '')
				ELSE '' END,
			strConsigneeCountry = CASE 
				WHEN CLNP.strType = 'Bank' THEN ISNULL(ConsigneeNotifyBank.strCountry, '')
				WHEN CLNP.strType = 'Company' THEN ISNULL(CNCompanyLocation.strCountry, ConsigneeNotifyCompany.strCountry)
				WHEN CLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(CNLocation.strCountry, '')
				ELSE '' END,
			strConsigneeState = CASE
				WHEN CLNP.strType = 'Bank' THEN ISNULL(ConsigneeNotifyBank.strState, '')
				WHEN CLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(CNLocation.strState, '')
				ELSE '' END,
			strConsigneeZipCode = CASE
				WHEN CLNP.strType = 'Bank' THEN ISNULL(ConsigneeNotifyBank.strZipCode, '')
				WHEN CLNP.strType = 'Company' THEN ISNULL(CNCompanyLocation.strZipPostalCode, ConsigneeNotifyCompany.strZip)
				WHEN CLNP.strType IN ('Vendor', 'Customer', 'Forwarding Agent') THEN ISNULL(CNLocation.strZipCode, '')
				ELSE '' END
		FROM tblLGLoad L
		JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE WHEN (L.intPurchaseSale = 2) THEN LD.intSContractDetailId ELSE LD.intPContractDetailId END
		LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
		LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
		LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
		LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId AND LW.intLoadWarehouseId = ISNULL(LWC.intLoadWarehouseId, LW.intLoadWarehouseId)
		LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN tblLGContainerType CType ON CType.intContainerTypeId = L.intContainerTypeId
		OUTER APPLY 
			(SELECT TOP 1 strPickComments = PLH.strComments, PLH.strPickLotNumber, ALD.intSContractDetailId, ACH.intEntityId
				FROM tblLGPickLotDetail PLD 
				LEFT JOIN tblLGPickLotHeader PLH ON PLH.intPickLotHeaderId = PLD.intPickLotHeaderId
				LEFT JOIN tblLGAllocationDetail ALD ON ALD.intAllocationDetailId = PLD.intAllocationDetailId
				LEFT JOIN tblCTContractDetail ACD ON ACD.intContractDetailId = ALD.intSContractDetailId
				LEFT JOIN tblCTContractHeader ACH ON ACH.intContractHeaderId = ACD.intContractHeaderId
				WHERE PLD.intContainerId = LC.intLoadContainerId) PL
		LEFT JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = CASE WHEN L.intPurchaseSale = 1 THEN PL.intSContractDetailId ELSE LD.intSContractDetailId END
		LEFT JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
		LEFT JOIN tblSMFreightTerms SCB ON SCB.intFreightTermId = SCH.intFreightTermId
		LEFT JOIN tblSMCity PCity ON PCity.intCityId = PCH.intINCOLocationTypeId
		LEFT JOIN tblSMCountry PCountry ON PCountry.intCountryID = PCity.intCountryId
		LEFT JOIN tblEMEntity Vendor ON Vendor.intEntityId = LD.intVendorEntityId
		LEFT JOIN [tblEMEntityLocation] VLocation ON VLocation.intEntityId = LD.intVendorEntityId and VLocation.intEntityLocationId = Vendor.intDefaultLocationId
		LEFT JOIN tblEMEntity Customer ON Customer.intEntityId = SCH.intEntityId
		LEFT JOIN [tblEMEntityLocation] CLocation ON CLocation.intEntityId = SCH.intEntityId and CLocation.ysnDefaultLocation = 1
		LEFT JOIN tblEMEntityToContact CustomerContact ON CustomerContact.intEntityId = Customer.intEntityId
		LEFT JOIN tblEMEntity CustomerContactEntity ON CustomerContactEntity.intEntityId = CustomerContact.intEntityContactId
		LEFT JOIN tblEMEntity SLEntity ON SLEntity.intEntityId = L.intShippingLineEntityId
		LEFT JOIN [tblEMEntityLocation] SLLocation ON SLLocation.intEntityId = L.intShippingLineEntityId and SLLocation.ysnDefaultLocation = 1
		LEFT JOIN tblEMEntity TerminalEntity ON TerminalEntity.intEntityId = L.intTerminalEntityId
	
		LEFT JOIN [tblEMEntityLocation] TerminalLocation ON TerminalLocation.intEntityId = L.intTerminalEntityId and TerminalLocation.ysnDefaultLocation = 1
		LEFT JOIN tblEMEntity InsurEntity ON InsurEntity.intEntityId = L.intInsurerEntityId
		LEFT JOIN [tblEMEntityLocation] InsurLocation ON InsurLocation.intEntityId = L.intInsurerEntityId and InsurLocation.ysnDefaultLocation = 1	
		LEFT JOIN tblEMEntity Shipper ON Shipper.intEntityId = CD.intShipperId
		LEFT JOIN [tblEMEntityLocation] SpLocation ON SpLocation.intEntityId = Shipper.intEntityId and SpLocation.ysnDefaultLocation = 1
		
		LEFT JOIN tblEMEntity Via ON Via.intEntityId = LW .intHaulerEntityId
		LEFT JOIN tblSMCompanyLocationSubLocation WH ON WH.intCompanyLocationSubLocationId = LW.intSubLocationId
		LEFT JOIN tblEMEntityToContact WEC ON WEC.intEntityId = WH.intVendorId
		LEFT JOIN tblEMEntity WETC ON WETC .intEntityId = WEC.intEntityContactId
		LEFT JOIN tblEMEntityToContact SLEC ON SLEC.intEntityId = SLEntity.intEntityId
		LEFT JOIN tblEMEntity SLETC ON SLETC .intEntityId = SLEC.intEntityContactId
		LEFT JOIN tblSMCurrency InsuranceCur ON InsuranceCur.intCurrencyID = L.intInsuranceCurrencyId
		LEFT JOIN tblLGWarehouseInstructionHeader WI ON WI.intShipmentId = L.intLoadId
		LEFT JOIN tblLGLoadNotifyParties FLNP ON L.intLoadId = FLNP.intLoadId AND FLNP.strNotifyOrConsignee = 'First Notify'
		LEFT JOIN tblLGLoadNotifyParties SLNP ON L.intLoadId = SLNP.intLoadId AND SLNP.strNotifyOrConsignee = 'Second Notify'
		LEFT JOIN tblLGLoadNotifyParties TLNP ON L.intLoadId = TLNP.intLoadId AND TLNP.strNotifyOrConsignee = 'Third Notify'
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
		LEFT JOIN tblEMEntity ConsigneeNotify ON ConsigneeNotify.intEntityId = CLNP.intEntityId
		LEFT JOIN tblEMEntityToContact ConsigneeNotifyContact ON ConsigneeNotifyContact.intEntityId = ConsigneeNotify.intEntityId
		LEFT JOIN tblEMEntity ConsigneeNotifyContactEntity ON ConsigneeNotifyContactEntity.intEntityId = ConsigneeNotifyContact.intEntityContactId
		LEFT JOIN tblCMBank ConsigneeNotifyBank ON ConsigneeNotifyBank.intBankId = CLNP.intBankId
		LEFT JOIN tblSMCompanySetup ConsigneeNotifyCompany ON ConsigneeNotifyCompany.intCompanySetupID = CLNP.intCompanySetupID
		LEFT JOIN tblSMCompanyLocation CNCompanyLocation ON CNCompanyLocation.intCompanyLocationId = CLNP.intCompanyLocationId
		LEFT JOIN tblEMEntityLocation CNLocation ON CNLocation.intEntityLocationId = CLNP.intEntityLocationId
		CROSS APPLY tblLGCompanyPreference CP
		WHERE L.strLoadNumber = @strTrackingNumber) tbl
	END
	ELSE
	BEGIN
		SELECT TOP 1			
			strTrackingNumber = L.strLoadNumber,
			L.intPurchaseSale,
			LW.strDeliveryNoticeNumber,
			LW.dtmDeliveryNoticeDate,
			LW.dtmDeliveryDate,
			LW.intSubLocationId,
			L.intShippingLineEntityId,
			LW.dtmPickupDate,
			LW.dtmLastFreeDate,
			LW.dtmStrippingReportReceivedDate,
			LW.dtmSampleAuthorizedDate,
			LW.strStrippingReportComments,
			LW.strFreightComments,
			LW.strSampleComments,
			LW.strOtherComments,
			L.strOriginPort,
			L.strDestinationPort,
			L.strDestinationCity,
			dtmBLDate = LW.dtmDeliveryDate,
			L.strBLNumber,
			L.dtmScheduledDate,
			L.dtmETAPOL,
			L.dtmETAPOD,
			L.dtmETSPOL,
			L.strMVessel,
			L.strFVessel,
			L.strMVoyageNumber,
			L.strFVoyageNumber,
			L.dblInsuranceValue,
			L.intInsuranceCurrencyId,
			InsuranceCur.strCurrency,

			strVendor = Vendor.strName,
			strVendorEmail = Vendor.strEmail,
			strVendorFax = Vendor.strFax,
			strVendorPhone = Vendor.strPhone,
			strVendorMobile = Vendor.strMobile,
			strVendorWebsite = Vendor.strWebsite,
			strVendorAddress = VLocation.strAddress,
			strVendorCity = VLocation.strCity,
			strVendorCountry = VLocation.strCountry,
			strVendorState = VLocation.strState,
			strVendorZipCode = VLocation.strZipCode,

			strCustomer = Customer.strName,
			strCustomerEmail = Customer.strEmail,
			strCustomerFax = Customer.strFax,
			strCustomerPhone = Customer.strPhone,
			strCustomerMobile = Customer.strMobile,
			strCustomerWebsite = Customer.strWebsite,
			strCustomerAddress = CLocation.strAddress,
			strCustomerCity = CLocation.strCity,
			strCustomerCountry = CLocation.strCountry,
			strCustomerState = CLocation.strState,
			strCustomerZipCode = CLocation.strZipCode,

			strShippingLine = SLEntity.strName,
			strShippingLineEmail = SLEntity.strEmail,
			strShippingLineFax = SLEntity.strFax,
			strShippingLinePhone = SLEntity.strPhone,
			strShippingLineMobile = SLEntity.strMobile,
			strShippingLineWebsite = SLEntity.strWebsite,
			strShippingLineAddress = SLLocation.strAddress,
			strShippingLineCity = SLLocation.strCity,
			strShippingLineCountry = SLLocation.strCountry,
			strShippingLineState = SLLocation.strState,
			strShippingLineZipCode = SLLocation.strZipCode,
			strShippingLineWithAddress = SLEntity.strName + ', ' + ISNULL(SLLocation.strAddress,''),

			strTerminal = TerminalEntity.strName,
			strTerminalEmail = TerminalEntity.strEmail,
			strTerminalFax = TerminalEntity.strFax,
			strTerminalPhone = TerminalEntity.strPhone,
			strTerminalMobile = TerminalEntity.strMobile,
			strTerminalWebsite = TerminalEntity.strWebsite,
			strTerminalAddress = TerminalLocation.strAddress,
			strTerminalCity = TerminalLocation.strCity,
			strTerminalCountry = TerminalLocation.strCountry,
			strTerminalState = TerminalLocation.strState,
			strTerminalZipCode = TerminalLocation.strZipCode,

			strInsurer = InsurEntity.strName,
			strInsurerEmail = InsurEntity.strEmail,
			strInsurerFax = InsurEntity.strFax,
			strInsurerPhone = InsurEntity.strPhone,
			strInsurerMobile = InsurEntity.strMobile,
			strInsurerWebsite = InsurEntity.strWebsite,
			strInsurerAddress = InsurLocation.strAddress,
			strInsurerCity = InsurLocation.strCity,
			strInsurerCountry = InsurLocation.strCountry,
			strInsurerState = InsurLocation.strState,
			strInsurerZipCode = InsurLocation.strZipCode,

			strWarehouse = WH.strSubLocationName,
			strWarehouseDescription = WH.strSubLocationDescription,
			strWarehouseAddress = WH.strAddress,
			strWarehouseCity = WH.strCity,
			strWarehouseClassification = WH.strClassification,
			strWarehouseState = WH.strState,
			strWarehouseZipCode = WH.strZipCode,
			strInStoreLetter = CP.strReleaseOrderText,

			WI.intWarehouseInstructionHeaderId,
			LW.intLoadWarehouseId,
			Via.strName strShipVia,
			blbHeaderLogo = dbo.fnSMGetCompanyLogo('Header'),
			blbFooterLogo = dbo.fnSMGetCompanyLogo('Footer'),
			strCompanyName = @strCompanyName,
			strCompanyAddress = @strCompanyAddress,
			strCompanyContactName = @strContactName,
			strCompanyCounty = @strCounty,
			strCompanyCity = @strCity,
			strCompanyState = @strState,
			strCompanyZip = @strZip,
			strCompanyCountry = @strCountry,
			strCompanyPhone = @strPhone,
			strCompanyFax = @strFax,
			strCompanyWebSite = @strWebSite,
			strCityStateZip = @strCity + ', ' + @strState + ', ' + @strZip + ',',
			strUserFullName = CASE WHEN ISNULL(@strFullName,'') = '' THEN  @strUserName ELSE @strFullName END,
			strExternalPONumber = CD.strERPPONumber,
			strNumberOfContainers = CONVERT(NVARCHAR,L.intNumberOfContainers) + ' (' + L.strPackingDescription +')',
			CType.strContainerType,
			strLogisticsCompanyName = @strLogisticsCompanyName,
			strLogisticsPrintSignOff = @strLogisticsPrintSignOff,
			strWarehouseContact = CASE WHEN @strInstoreTo = 'Shipping Line' THEN SLETC.strName ELSE WETC.strName END,
			strInstoreTo = @strInstoreTo,
			strReleaseOrderText = CASE WHEN @strInstoreTo = 'Shipping Line' THEN @strReleaseOrderText ELSE NULL END,
			strDefaultReleaseOrderText = CP.strReleaseOrderText,
			strWarehouseVendorName = WHVendor.strName,
			strWarehouseVendorLocation = WHVendorLoc.strLocationName,
			strWarehouseVendorAddress = WHVendorLoc.strAddress,
			strWarehouseVendorCity = WHVendorLoc.strCity,
			strWarehouseVendorState = WHVendorLoc.strState,
			strWarehouseVendorZipCode = WHVendorLoc.strZipCode + ' ' + WHVendorLoc.strCity,
			strWarehouseVendorCountry = WHVendorLoc.strCountry,
			WETCP.strPhone,
			strMobile = WETCM.strPhone,
			strWarehouseVendorContract = WETC.strName,
			strWarehouseVendorContactPhone = 'Phone: ' + WETCP.strPhone,
			strWarehouseVendorContactEmail = 'E-Mail: ' + WETC.strEmail,
			strWarehouseAddressInfo = WHVendor.strName + CHAR(13) 
				+ RTRIM(LTRIM(ISNULL(WHVendorLoc.strAddress,''))) + CHAR(13) 
				+ ISNULL(WHVendorLoc.strZipCode,'') + ' ' 
				+ CASE WHEN ISNULL(WHVendorLoc.strCity,'') = '' THEN '' ELSE WHVendorLoc.strCity END + CHAR(13) 
				+ CASE WHEN ISNULL(WHVendorLoc.strState,'') = '' THEN '' ELSE WHVendorLoc.strState END + CHAR(13) 
				+ ISNULL(WHVendorLoc.strCountry,''),
			strWarehouseContractInfo = WETC.strName + CHAR(13) + 'Phone: ' + WETCP.strPhone + CHAR(13) + 'E-Mail: ' + WETC.strEmail,
			intContractBasisId = CH.intFreightTermId,
			Basis.strContractBasis,
			strContractBasisDescription = Basis.strDescription,
			strWeightTerms = WG.strWeightGradeDesc,
			strUserEmailId = @strUserEmailId,
			strUserPhoneNo = @strUserPhoneNo,
			L.strShippingMode,
			strCertificationName = (SELECT TOP 1 strCertificationName
									FROM tblICCertification CER
									JOIN tblCTContractCertification CTCER ON CTCER.intCertificationId = CER.intCertificationId
									WHERE CTCER.intContractDetailId = CD.intContractDetailId),
			blbFullHeaderLogo = dbo.fnSMGetCompanyLogo('FullHeaderLogo'),
			blbFullFooterLogo = dbo.fnSMGetCompanyLogo('FullFooterLogo'),
			ysnFullHeaderLogo = CASE WHEN CP.ysnFullHeaderLogo = 1 THEN 'true' else 'false' END,
			intReportLogoHeight = ISNULL(CP.intReportLogoHeight,0),
			intReportLogoWidth = ISNULL(CP.intReportLogoWidth,0)	 
		FROM		tblLGLoad L
		JOIN		tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		JOIN		tblCTContractDetail CD ON CD.intContractDetailId = CASE WHEN(L.intPurchaseSale = 2) THEN LD.intSContractDetailId ELSE LD.intPContractDetailId END
		JOIN		tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN	tblLGContainerType CType ON CType.intContainerTypeId = L.intContainerTypeId
		LEFT JOIN	tblEMEntity Vendor ON Vendor.intEntityId = LD.intVendorEntityId
		LEFT JOIN	[tblEMEntityLocation] VLocation ON VLocation.intEntityId = LD.intVendorEntityId and VLocation.ysnDefaultLocation = 1
		LEFT JOIN	tblEMEntity Customer ON Customer.intEntityId = LD.intCustomerEntityId
		LEFT JOIN	[tblEMEntityLocation] CLocation ON CLocation.intEntityId = LD.intCustomerEntityId and CLocation.ysnDefaultLocation = 1
		LEFT JOIN	tblEMEntity SLEntity ON SLEntity.intEntityId = L.intShippingLineEntityId
		LEFT JOIN	[tblEMEntityLocation] SLLocation ON SLLocation.intEntityId = L.intShippingLineEntityId and SLLocation.ysnDefaultLocation = 1
		LEFT JOIN	tblEMEntity TerminalEntity ON TerminalEntity.intEntityId = L.intTerminalEntityId
		LEFT JOIN	[tblEMEntityLocation] TerminalLocation ON TerminalLocation.intEntityId = L.intTerminalEntityId and TerminalLocation.ysnDefaultLocation = 1
		LEFT JOIN	tblEMEntity InsurEntity ON InsurEntity.intEntityId = L.intInsurerEntityId
		LEFT JOIN	[tblEMEntityLocation] InsurLocation ON InsurLocation.intEntityId = L.intInsurerEntityId and InsurLocation.ysnDefaultLocation = 1
		LEFT JOIN	tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
		LEFT JOIN	tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
		LEFT JOIN	tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
		LEFT JOIN	tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
		LEFT JOIN	tblEMEntity Via ON Via.intEntityId = LW .intHaulerEntityId
		LEFT JOIN	tblSMCompanyLocationSubLocation WH ON WH.intCompanyLocationSubLocationId = LW.intSubLocationId
		LEFT JOIN   tblEMEntity WHVendor ON WHVendor.intEntityId = WH.intVendorId
		LEFT JOIN	tblEMEntityLocation WHVendorLoc ON WHVendorLoc.intEntityId = WHVendor.intEntityId and WHVendorLoc.ysnDefaultLocation = 1
		LEFT JOIN   tblEMEntityToContact WEC ON WEC.intEntityId = WH.intVendorId
		LEFT JOIN   tblEMEntity WETC ON WETC .intEntityId = WEC.intEntityContactId
		LEFT JOIN	tblEMEntityPhoneNumber WETCP ON WETCP.intEntityId = WETC .intEntityId
		LEFT JOIN	tblEMEntityMobileNumber WETCM ON WETCM.intEntityId = WETC .intEntityId
		LEFT JOIN	tblEMContactDetail WETCD ON WETCD.intEntityId = WETC.intEntityId 
		LEFT JOIN	tblEMContactDetailType WETCDT ON WETCDT.intContactDetailTypeId = WETCDT.intContactDetailTypeId AND WETCDT.strField = 'Fax'
		LEFT JOIN   tblEMEntityToContact SLEC ON SLEC.intEntityId = SLEntity.intEntityId
		LEFT JOIN   tblEMEntity SLETC ON SLETC .intEntityId = SLEC.intEntityContactId
		LEFT JOIN	tblSMCurrency InsuranceCur ON InsuranceCur.intCurrencyID = L.intInsuranceCurrencyId
		LEFT JOIN	tblLGWarehouseInstructionHeader WI ON WI.intShipmentId = L.intLoadId
		LEFT JOIN	tblSMFreightTerms Basis ON Basis.intFreightTermId = CH.intFreightTermId
		LEFT JOIN	tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
		CROSS APPLY tblLGCompanyPreference CP
		WHERE LW.intLoadWarehouseId = @intLoadWarehouseId
	END
END