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
	
	SELECT @strShippingLineName = E.strName
	FROM tblLGLoad L
	JOIN tblEMEntity E ON E.intEntityId = L.intShippingLineEntityId
	JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
	WHERE LW.intLoadWarehouseId = @intLoadWarehouseId


	SELECT @strReleaseOrderText = 'Attn '+ ISNULL(@strShippingLineName,'') +' : Please release the cargo in favour of ' + @strWarehouseEntityName
	
	SELECT @strLogisticsCompanyName = strLogisticsCompanyName,
		   @strLogisticsPrintSignOff = strLogisticsPrintSignOff
	FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intCompanyLocationId

IF ISNULL(@intLoadWarehouseId,0) = 0 
	BEGIN
	SELECT *	,LTRIM(RTRIM(CASE 
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
	,LTRIM(RTRIM(CASE 
				WHEN ISNULL(strThirdNotifyText, '') = ''
					THEN ''
				ELSE strThirdNotifyText + CHAR(13)
				END + CASE 
				WHEN ISNULL(strThirdNotify, '') = ''
					THEN ''
				ELSE strThirdNotify + CHAR(13)
				END + CASE 
				WHEN ISNULL(strThirdNotifyAddress, '') = ''
					THEN ''
				ELSE strThirdNotifyAddress + CHAR(13)
				END + CASE 
				WHEN ISNULL(strThirdNotifyCity, '') = ''
					THEN ''
				ELSE strThirdNotifyCity + CHAR(13)
				END + CASE 
				WHEN ISNULL(strThirdNotifyZipCode, '') = ''
					THEN ''
				ELSE strThirdNotifyZipCode + CHAR(13)
				END + CASE 
				WHEN ISNULL(strThirdNotifyCountry, '') = ''
					THEN ''
				ELSE strThirdNotifyCountry + CHAR(13)
				END + CASE 
				WHEN ISNULL(strThirdNotifyMobile, '') = ''
					THEN ''
				ELSE 'Mobile: ' + strThirdNotifyMobile + CHAR(13)
				END + CASE 
				WHEN ISNULL(strThirdNotifyPhone, '') = ''
					THEN ''
				ELSE 'Phone: ' + strThirdNotifyPhone + CHAR(13)
				END + CASE 
				WHEN ISNULL(strThirdNotifyFax, '') = ''
					THEN ''
				ELSE 'Fax: ' + strThirdNotifyFax + CHAR(13)
				END + CASE 
				WHEN ISNULL(strThirdNotifyMail, '') = ''
					THEN ''
				ELSE 'E-mail: ' + strThirdNotifyMail
				END)) strThirdNotifyInfo FROM (
		SELECT TOP 1
				L.strLoadNumber AS strTrackingNumber,
				LW.strDeliveryNoticeNumber, 
				LW.dtmDeliveryNoticeDate,
				LW.dtmDeliveryDate,
				LW.intSubLocationId,
				L.intShippingLineEntityId,
				--SH.intTruckerEntityId,
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
				L.dtmBLDate,
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

  				Vendor.strName as strVendor,
				Vendor.strEmail as strVendorEmail,
				Vendor.strFax as strVendorFax,
				Vendor.strPhone as strVendorPhone,
				Vendor.strMobile as strVendorMobile,
				Vendor.strWebsite as strVendorWebsite,
				VLocation.strAddress as strVendorAddress,
				VLocation.strCity as strVendorCity,
				VLocation.strCountry as strVendorCountry,
				VLocation.strState as strVendorState,
				VLocation.strZipCode as strVendorZipCode,

  				Customer.strName as strCustomer,
				CustomerContactEntity.strEmail as strCustomerEmail,
				Customer.strFax as strCustomerFax,
				CustomerContactEntity.strPhone as strCustomerPhone,
				CustomerContactEntity.strMobile as strCustomerMobile,
				Customer.strWebsite as strCustomerWebsite,
				CLocation.strAddress as strCustomerAddress,
				CLocation.strCity as strCustomerCity,
				CLocation.strCountry as strCustomerCountry,
				CLocation.strState as strCustomerState,
				CLocation.strZipCode as strCustomerZipCode,

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
				SLEntity.strName + ', ' + ISNULL(SLLocation.strAddress,'') as strShippingLineWithAddress,

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
				WH.strZipCode as strWarehouseZipCode,

				WI.intWarehouseInstructionHeaderId,
				LW.intLoadWarehouseId,
				Via.strName strShipVia,
				dbo.fnSMGetCompanyLogo('Header') AS blbHeaderLogo,
				dbo.fnSMGetCompanyLogo('Footer') AS blbFooterLogo,
				@strCompanyName AS strCompanyName,
				@strCompanyAddress AS strCompanyAddress,
				@strContactName AS strCompanyContactName ,
				@strCounty AS strCompanyCounty ,
				@strCity AS strCompanyCity ,
				@strState AS strCompanyState ,
				@strZip AS strCompanyZip ,
				@strCountry AS strCompanyCountry ,
				@strPhone AS strCompanyPhone ,
				@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCityStateZip,
				CASE WHEN ISNULL(@strFullName,'') = '' THEN  @strUserName ELSE @strFullName END AS strUserFullName,
				CD.strERPPONumber AS strExternalPONumber,
				CONVERT(NVARCHAR,L.intNumberOfContainers) + ' (' + L.strPackingDescription +')' AS strNumberOfContainers,
				CType.strContainerType,
				@strLogisticsCompanyName AS strLogisticsCompanyName,
				@strLogisticsPrintSignOff AS strLogisticsPrintSignOff,
				CASE WHEN @strInstoreTo = 'Shipping Line' THEN SLETC.strName ELSE WETC.strName END AS strWarehouseContact,
				@strInstoreTo AS strInstoreTo,
				CASE WHEN @strInstoreTo = 'Shipping Line' THEN @strReleaseOrderText ELSE NULL END AS strReleaseOrderText,
				PCH.strCustomerContract AS strPCustomerContract,
				SCH.strContractNumber AS strSalesContractNumber,

				'' AS strWarehouseVendorName,
				'' AS strWarehouseVendorLocation,
				'' AS strWarehouseVendorAddress,
				'' AS strWarehouseVendorCity,
				'' AS strWarehouseVendorState,
				'' AS strWarehouseVendorZipCode,
				'' AS strWarehouseVendorCountry,
				'' AS strPhone,
				'' AS strMobile,
				'' AS strWarehouseVendorContract,
				'' AS strWarehouseVendorContactPhone,
				'' AS strWarehouseVendorContactEmail,

				'' AS  strWarehouseAddressInfo,
				'' AS  strWarehouseContractInfo,
				'' AS intContractBasisId,
				'' AS strContractBasis,
				'' AS strContractBasisDescription,
				'' AS strWeightTerms,
				'' AS strUserEmailId,
				'' AS strUserPhoneNo,
				L.strShippingMode,
				strCertificationName = (SELECT TOP 1 strCertificationName
										FROM tblICCertification CER
										JOIN tblCTContractCertification CTCER ON CTCER.intCertificationId = CER.intCertificationId
										WHERE CTCER.intContractDetailId = CD.intContractDetailId),
				dbo.fnSMGetCompanyLogo('FullHeaderLogo') AS blbFullHeaderLogo,
				dbo.fnSMGetCompanyLogo('FullFooterLogo') AS blbFullFooterLogo,
				CASE WHEN CP.ysnFullHeaderLogo = 1 THEN 'true' else 'false' END ysnFullHeaderLogo,
				ISNULL(CP.intReportLogoHeight,0) AS intReportLogoHeight,
				ISNULL(CP.intReportLogoWidth,0) AS intReportLogoWidth
				,FLNP.strText AS strFirstNotifyText
				,SLNP.strText AS strSecondNotifyText
				,TLNP.strText AS strThirdNotifyText
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
						THEN ISNULL(FNCompanyLocation.strEmail, FirstNotifyCompany.strEmail)
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
						THEN ISNULL(FNCompanyLocation.strFax, FirstNotifyCompany.strFax)
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
						THEN ISNULL(FNCompanyLocation.strPhone, FirstNotifyCompany.strPhone)
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
						THEN ISNULL(FNCompanyLocation.strAddress, FirstNotifyCompany.strAddress)
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
						THEN ISNULL(FNCompanyLocation.strCity, FirstNotifyCompany.strCity)
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
						THEN ISNULL(FNCompanyLocation.strCountry, FirstNotifyCompany.strCountry)
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
						THEN ''
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
						THEN ISNULL(FNCompanyLocation.strZipPostalCode, FirstNotifyCompany.strZip)
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
						THEN ISNULL(SNCompanyLocation.strEmail, SecondNotifyCompany.strEmail)
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
						THEN ISNULL(SNCompanyLocation.strFax, SecondNotifyCompany.strFax)
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
						THEN ISNULL(SNCompanyLocation.strPhone, SecondNotifyCompany.strPhone)
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
						THEN ISNULL(SNCompanyLocation.strAddress, SecondNotifyCompany.strAddress)
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
						THEN ISNULL(SNCompanyLocation.strCity, SecondNotifyCompany.strCity)
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
						THEN ISNULL(SNCompanyLocation.strCountry, SecondNotifyCompany.strCountry)
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
						THEN ''
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
						THEN ISNULL(SNCompanyLocation.strZipPostalCode, SecondNotifyCompany.strZip)
					WHEN 'Vendor'
						THEN ISNULL(SNLocation.strZipCode, '')
					WHEN 'Customer'
						THEN ISNULL(SNLocation.strZipCode, '')
					WHEN 'Forwarding Agent'
						THEN ISNULL(SNLocation.strZipCode, '')
					ELSE ''
					END strSecondNotifyZipCode
				,CASE TLNP.strType
					WHEN 'Bank'
						THEN ISNULL(ThirdNotifyBank.strBankName, '')
					WHEN 'Company'
						THEN ISNULL(ThirdNotifyCompany.strCompanyName, '')
					WHEN 'Vendor'
						THEN ISNULL(ThirdNotify.strName, '')
					WHEN 'Customer'
						THEN ISNULL(ThirdNotify.strName, '')
					WHEN 'Forwarding Agent'
						THEN ISNULL(ThirdNotify.strName, '')
					ELSE ''
					END strThirdNotify
				,CASE TLNP.strType
					WHEN 'Bank'
						THEN ISNULL(ThirdNotifyBank.strEmail, '')
					WHEN 'Company'
						THEN ISNULL(TNCompanyLocation.strEmail, ThirdNotifyCompany.strEmail)
					WHEN 'Vendor'
						THEN ISNULL(ThirdNotify.strEmail, '')
					WHEN 'Customer'
						THEN ISNULL(ThirdNotify.strEmail, '')
					WHEN 'Forwarding Agent'
						THEN ISNULL(ThirdNotify.strEmail, '')
					ELSE ''
					END strThirdNotifyMail
				,CASE TLNP.strType
					WHEN 'Bank'
						THEN ISNULL(ThirdNotifyBank.strFax, '')
					WHEN 'Company'
						THEN ISNULL(SNCompanyLocation.strFax, ThirdNotifyCompany.strFax)
					WHEN 'Vendor'
						THEN ISNULL(ThirdNotify.strFax, '')
					WHEN 'Customer'
						THEN ISNULL(ThirdNotify.strFax, '')
					WHEN 'Forwarding Agent'
						THEN ISNULL(ThirdNotify.strFax, '')
					ELSE ''
					END strThirdNotifyFax
				,CASE TLNP.strType
					WHEN 'Bank'
						THEN ''
					WHEN 'Company'
						THEN ''
					WHEN 'Vendor'
						THEN ISNULL(ThirdNotify.strMobile, '')
					WHEN 'Customer'
						THEN ISNULL(ThirdNotify.strMobile, '')
					WHEN 'Forwarding Agent'
						THEN ISNULL(ThirdNotify.strMobile, '')
					ELSE ''
					END strThirdNotifyMobile
				,CASE TLNP.strType
					WHEN 'Bank'
						THEN ISNULL(ThirdNotifyBank.strPhone, '')
					WHEN 'Company'
						THEN ISNULL(SNCompanyLocation.strPhone, ThirdNotifyCompany.strPhone)
					WHEN 'Vendor'
						THEN ISNULL(ThirdNotifyContactEntity.strPhone, '')
					WHEN 'Customer'
						THEN ISNULL(ThirdNotifyContactEntity.strPhone, '')
					WHEN 'Forwarding Agent'
						THEN ISNULL(ThirdNotifyContactEntity.strPhone, '')
					ELSE ''
					END strThirdNotifyPhone
				,CASE TLNP.strType
					WHEN 'Bank'
						THEN ISNULL(ThirdNotifyBank.strAddress, '')
					WHEN 'Company'
						THEN ISNULL(TNCompanyLocation.strAddress, ThirdNotifyCompany.strAddress)
					WHEN 'Vendor'
						THEN ISNULL(TNLocation.strAddress, '')
					WHEN 'Customer'
						THEN ISNULL(TNLocation.strAddress, '')
					WHEN 'Forwarding Agent'
						THEN ISNULL(TNLocation.strAddress, '')
					ELSE ''
					END strThirdNotifyAddress
				,CASE TLNP.strType
					WHEN 'Bank'
						THEN ISNULL(ThirdNotifyBank.strCity, '')
					WHEN 'Company'
						THEN ISNULL(TNCompanyLocation.strCity, ThirdNotifyCompany.strCity)
					WHEN 'Vendor'
						THEN ISNULL(TNLocation.strCity, '')
					WHEN 'Customer'
						THEN ISNULL(TNLocation.strCity, '')
					WHEN 'Forwarding Agent'
						THEN ISNULL(TNLocation.strCity, '')
					ELSE ''
					END strThirdNotifyCity
				,CASE TLNP.strType
					WHEN 'Bank'
						THEN ISNULL(ThirdNotifyBank.strCountry, '')
					WHEN 'Company'
						THEN ISNULL(TNCompanyLocation.strCountry, ThirdNotifyCompany.strCountry)
					WHEN 'Vendor'
						THEN ISNULL(TNLocation.strCountry, '')
					WHEN 'Customer'
						THEN ISNULL(TNLocation.strCountry, '')
					WHEN 'Forwarding Agent'
						THEN ISNULL(TNLocation.strCountry, '')
					ELSE ''
					END strThirdNotifyCountry
				,CASE TLNP.strType
					WHEN 'Bank'
						THEN ISNULL(ThirdNotifyBank.strState, '')
					WHEN 'Company'
						THEN ''
					WHEN 'Vendor'
						THEN ISNULL(TNLocation.strState, '')
					WHEN 'Customer'
						THEN ISNULL(TNLocation.strState, '')
					WHEN 'Forwarding Agent'
						THEN ISNULL(TNLocation.strState, '')
					ELSE ''
					END strThirdNotifyState
				,CASE TLNP.strType
					WHEN 'Bank'
						THEN ISNULL(ThirdNotifyBank.strZipCode, '')
					WHEN 'Company'
						THEN ISNULL(TNCompanyLocation.strZipPostalCode, ThirdNotifyCompany.strZip)
					WHEN 'Vendor'
						THEN ISNULL(TNLocation.strZipCode, '')
					WHEN 'Customer'
						THEN ISNULL(TNLocation.strZipCode, '')
					WHEN 'Forwarding Agent'
						THEN ISNULL(TNLocation.strZipCode, '')
					ELSE ''
					END strThirdNotifyZipCode
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
						THEN ISNULL(CNCompanyLocation.strAddress, ConsigneeNotifyCompany.strAddress)
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
						THEN ISNULL(CNCompanyLocation.strCity, ConsigneeNotifyCompany.strCity)
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
						THEN ISNULL(CNCompanyLocation.strCountry, ConsigneeNotifyCompany.strCountry)
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
						THEN ''
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
						THEN ISNULL(CNCompanyLocation.strZipPostalCode, ConsigneeNotifyCompany.strZip)
					WHEN 'Vendor'
						THEN ISNULL(CNLocation.strZipCode, '')
					WHEN 'Customer'
						THEN ISNULL(CNLocation.strZipCode, '')
					WHEN 'Forwarding Agent'
						THEN ISNULL(CNLocation.strZipCode, '')
					ELSE ''
					END strConsigneeZipCode
		FROM		tblLGLoad L
		JOIN		tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		JOIN		tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		LEFT JOIN	tblCTContractHeader PCH ON PCH.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN	tblLGContainerType CType ON CType.intContainerTypeId = L.intContainerTypeId
		LEFT JOIN	tblCTContractDetail SCD ON SCD.intContractDetailId = LD.intSContractDetailId
		LEFT JOIN	tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
		LEFT JOIN	tblEMEntity Vendor ON Vendor.intEntityId = LD.intVendorEntityId
		LEFT JOIN	[tblEMEntityLocation] VLocation ON VLocation.intEntityId = LD.intVendorEntityId and VLocation.intEntityLocationId = Vendor.intDefaultLocationId
		LEFT JOIN	tblEMEntity Customer ON Customer.intEntityId = LD.intCustomerEntityId
		LEFT JOIN	[tblEMEntityLocation] CLocation ON CLocation.intEntityId = LD.intCustomerEntityId and CLocation.ysnDefaultLocation = 1
		LEFT JOIN	tblEMEntityToContact CustomerContact ON CustomerContact.intEntityId = Customer.intEntityId
		LEFT JOIN	tblEMEntity CustomerContactEntity ON CustomerContactEntity.intEntityId = CustomerContact.intEntityContactId
		LEFT JOIN	tblEMEntity SLEntity ON SLEntity.intEntityId = L.intShippingLineEntityId
		LEFT JOIN	[tblEMEntityLocation] SLLocation ON SLLocation.intEntityId = L.intShippingLineEntityId and SLLocation.intEntityLocationId = SLEntity.intDefaultLocationId
		LEFT JOIN	tblEMEntity TerminalEntity ON TerminalEntity.intEntityId = L.intTerminalEntityId
		LEFT JOIN	[tblEMEntityLocation] TerminalLocation ON TerminalLocation.intEntityId = L.intTerminalEntityId and TerminalLocation.intEntityLocationId = TerminalEntity.intDefaultLocationId
		LEFT JOIN	tblEMEntity InsurEntity ON InsurEntity.intEntityId = L.intInsurerEntityId
		LEFT JOIN	[tblEMEntityLocation] InsurLocation ON InsurLocation.intEntityId = L.intInsurerEntityId and InsurLocation.intEntityLocationId = InsurEntity.intDefaultLocationId
		LEFT JOIN	tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
		LEFT JOIN	tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
		LEFT JOIN	tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
		LEFT JOIN	tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
		LEFT JOIN	tblEMEntity Via ON Via.intEntityId = LW .intHaulerEntityId
		LEFT JOIN	tblSMCompanyLocationSubLocation WH ON WH.intCompanyLocationSubLocationId = LW.intSubLocationId
		LEFT JOIN   tblEMEntityToContact WEC ON WEC.intEntityId = WH.intVendorId
		LEFT JOIN   tblEMEntity WETC ON WETC .intEntityId = WEC.intEntityContactId
		LEFT JOIN   tblEMEntityToContact SLEC ON SLEC.intEntityId = SLEntity.intEntityId
		LEFT JOIN   tblEMEntity SLETC ON SLETC .intEntityId = SLEC.intEntityContactId
		LEFT JOIN	tblSMCurrency InsuranceCur ON InsuranceCur.intCurrencyID = L.intInsuranceCurrencyId
		LEFT JOIN	tblLGWarehouseInstructionHeader WI ON WI.intShipmentId = L.intLoadId
		LEFT JOIN tblLGLoadNotifyParties FLNP ON L.intLoadId = FLNP.intLoadId
			AND FLNP.strNotifyOrConsignee = 'First Notify'
		LEFT JOIN tblLGLoadNotifyParties SLNP ON L.intLoadId = SLNP.intLoadId
			AND SLNP.strNotifyOrConsignee = 'Second Notify'
		LEFT JOIN tblLGLoadNotifyParties TLNP ON L.intLoadId = TLNP.intLoadId
			AND TLNP.strNotifyOrConsignee = 'Third Notify'
		LEFT JOIN tblLGLoadNotifyParties CLNP ON L.intLoadId = CLNP.intLoadId
			AND CLNP.strNotifyOrConsignee = 'Consignee'
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
				L.strLoadNumber AS strTrackingNumber,
				LW.strDeliveryNoticeNumber,
				LW.dtmDeliveryNoticeDate,
				LW.dtmDeliveryDate,
				LW.intSubLocationId,
				L.intShippingLineEntityId,
				--SH.intTruckerEntityId,
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
				L.dtmBLDate,
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

  				Vendor.strName as strVendor,
				Vendor.strEmail as strVendorEmail,
				Vendor.strFax as strVendorFax,
				Vendor.strPhone as strVendorPhone,
				Vendor.strMobile as strVendorMobile,
				Vendor.strWebsite as strVendorWebsite,
				VLocation.strAddress as strVendorAddress,
				VLocation.strCity as strVendorCity,
				VLocation.strCountry as strVendorCountry,
				VLocation.strState as strVendorState,
				VLocation.strZipCode as strVendorZipCode,

  				Customer.strName as strCustomer,
				Customer.strEmail as strCustomerEmail,
				Customer.strFax as strCustomerFax,
				Customer.strPhone as strCustomerPhone,
				Customer.strMobile as strCustomerMobile,
				Customer.strWebsite as strCustomerWebsite,
				CLocation.strAddress as strCustomerAddress,
				CLocation.strCity as strCustomerCity,
				CLocation.strCountry as strCustomerCountry,
				CLocation.strState as strCustomerState,
				CLocation.strZipCode as strCustomerZipCode,

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
				SLEntity.strName + ', ' + ISNULL(SLLocation.strAddress,'') as strShippingLineWithAddress,

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
				WH.strZipCode as strWarehouseZipCode,

				WI.intWarehouseInstructionHeaderId,
				LW.intLoadWarehouseId,
				Via.strName strShipVia,
				dbo.fnSMGetCompanyLogo('Header') AS blbHeaderLogo,
				dbo.fnSMGetCompanyLogo('Footer') AS blbFooterLogo,
				@strCompanyName AS strCompanyName,
				@strCompanyAddress AS strCompanyAddress,
				@strContactName AS strCompanyContactName ,
				@strCounty AS strCompanyCounty ,
				@strCity AS strCompanyCity ,
				@strState AS strCompanyState ,
				@strZip AS strCompanyZip ,
				@strCountry AS strCompanyCountry ,
				@strPhone AS strCompanyPhone ,
				@strCity + ', ' + @strState + ', ' + @strZip + ',' AS strCityStateZip,
				CASE WHEN ISNULL(@strFullName,'') = '' THEN  @strUserName ELSE @strFullName END AS strUserFullName,
				CD.strERPPONumber AS strExternalPONumber,
				CONVERT(NVARCHAR,L.intNumberOfContainers) + ' (' + L.strPackingDescription +')' AS strNumberOfContainers,
				CType.strContainerType,
				@strLogisticsCompanyName AS strLogisticsCompanyName,
				@strLogisticsPrintSignOff AS strLogisticsPrintSignOff,
				CASE WHEN @strInstoreTo = 'Shipping Line' THEN SLETC.strName ELSE WETC.strName END AS strWarehouseContact,
				@strInstoreTo AS strInstoreTo,
				CASE WHEN @strInstoreTo = 'Shipping Line' THEN @strReleaseOrderText ELSE NULL END AS strReleaseOrderText,
				WHVendor.strName AS strWarehouseVendorName,
				WHVendorLoc.strLocationName AS strWarehouseVendorLocation,
				WHVendorLoc.strAddress AS strWarehouseVendorAddress,
				WHVendorLoc.strCity AS strWarehouseVendorCity,
				WHVendorLoc.strState AS strWarehouseVendorState,
				WHVendorLoc.strZipCode + ' ' + WHVendorLoc.strCity AS strWarehouseVendorZipCode,
				WHVendorLoc.strCountry AS strWarehouseVendorCountry,
				WETCP.strPhone,
				WETCM.strPhone strMobile,
				WETC.strName AS strWarehouseVendorContract,
				'Phone: ' + WETCP.strPhone AS strWarehouseVendorContactPhone,
				'E-Mail: ' + WETC.strEmail AS strWarehouseVendorContactEmail,

				WHVendor.strName + CHAR(13) + 
				RTRIM(LTRIM(ISNULL(WHVendorLoc.strAddress,''))) + CHAR(13) + 
				ISNULL(WHVendorLoc.strZipCode,'') + ' ' + 
				CASE WHEN ISNULL(WHVendorLoc.strCity,'') = '' THEN '' ELSE WHVendorLoc.strCity END + CHAR(13) + 
				CASE WHEN ISNULL(WHVendorLoc.strState,'') = '' THEN '' ELSE WHVendorLoc.strState END + CHAR(13) +  
				ISNULL(WHVendorLoc.strCountry,'') strWarehouseAddressInfo,

				WETC.strName + CHAR(13) + 
				'Phone: ' + WETCP.strPhone + CHAR(13) + 
				'E-Mail: ' + WETC.strEmail strWarehouseContractInfo,
				CH.intContractBasisId,
				Basis.strContractBasis,
				Basis.strDescription AS strContractBasisDescription,
				strWeightTerms = WG.strWeightGradeDesc,
				@strUserEmailId AS strUserEmailId,
				@strUserPhoneNo AS strUserPhoneNo,
				L.strShippingMode,
				strCertificationName = (SELECT TOP 1 strCertificationName
										FROM tblICCertification CER
										JOIN tblCTContractCertification CTCER ON CTCER.intCertificationId = CER.intCertificationId
										WHERE CTCER.intContractDetailId = CD.intContractDetailId),
				dbo.fnSMGetCompanyLogo('FullHeaderLogo') AS blbFullHeaderLogo,
				dbo.fnSMGetCompanyLogo('FullFooterLogo') AS blbFullFooterLogo,
				CASE WHEN CP.ysnFullHeaderLogo = 1 THEN 'true' else 'false' END ysnFullHeaderLogo,
				ISNULL(CP.intReportLogoHeight,0) AS intReportLogoHeight,
				ISNULL(CP.intReportLogoWidth,0) AS intReportLogoWidth	 
		FROM		tblLGLoad L
		JOIN		tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		JOIN		tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN		tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN	tblLGContainerType CType ON CType.intContainerTypeId = L.intContainerTypeId
		LEFT JOIN	tblEMEntity Vendor ON Vendor.intEntityId = LD.intVendorEntityId
		LEFT JOIN	[tblEMEntityLocation] VLocation ON VLocation.intEntityId = LD.intVendorEntityId and VLocation.intEntityLocationId = Vendor.intDefaultLocationId
		LEFT JOIN	tblEMEntity Customer ON Customer.intEntityId = LD.intCustomerEntityId
		LEFT JOIN	[tblEMEntityLocation] CLocation ON CLocation.intEntityId = LD.intCustomerEntityId and CLocation.intEntityLocationId = Customer.intDefaultLocationId
		LEFT JOIN	tblEMEntity SLEntity ON SLEntity.intEntityId = L.intShippingLineEntityId
		LEFT JOIN	[tblEMEntityLocation] SLLocation ON SLLocation.intEntityId = L.intShippingLineEntityId and SLLocation.intEntityLocationId = SLEntity.intDefaultLocationId
		LEFT JOIN	tblEMEntity TerminalEntity ON TerminalEntity.intEntityId = L.intTerminalEntityId
		LEFT JOIN	[tblEMEntityLocation] TerminalLocation ON TerminalLocation.intEntityId = L.intTerminalEntityId and TerminalLocation.intEntityLocationId = TerminalEntity.intDefaultLocationId
		LEFT JOIN	tblEMEntity InsurEntity ON InsurEntity.intEntityId = L.intInsurerEntityId
		LEFT JOIN	[tblEMEntityLocation] InsurLocation ON InsurLocation.intEntityId = L.intInsurerEntityId and InsurLocation.intEntityLocationId = InsurEntity.intDefaultLocationId
		LEFT JOIN	tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
		LEFT JOIN	tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
		LEFT JOIN	tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
		LEFT JOIN	tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
		LEFT JOIN	tblEMEntity Via ON Via.intEntityId = LW .intHaulerEntityId
		LEFT JOIN	tblSMCompanyLocationSubLocation WH ON WH.intCompanyLocationSubLocationId = LW.intSubLocationId
		LEFT JOIN   tblEMEntity WHVendor ON WHVendor.intEntityId = WH.intVendorId
		LEFT JOIN	tblEMEntityLocation WHVendorLoc ON WHVendorLoc.intEntityLocationId = WHVendor.intDefaultLocationId
		LEFT JOIN   tblEMEntityToContact WEC ON WEC.intEntityId = WH.intVendorId
		LEFT JOIN   tblEMEntity WETC ON WETC .intEntityId = WEC.intEntityContactId
		LEFT JOIN	tblEMEntityPhoneNumber WETCP ON WETCP.intEntityId = WETC .intEntityId
		LEFT JOIN	tblEMEntityMobileNumber WETCM ON WETCM.intEntityId = WETC .intEntityId
		LEFT JOIN	tblEMContactDetail WETCD ON WETCD.intEntityId = WETC.intEntityId 
		LEFT JOIN	tblEMContactDetailType WETCDT ON WETCDT.intContactDetailTypeId = WETCDT.intContactDetailTypeId
				AND WETCDT.strField = 'Fax'
		LEFT JOIN   tblEMEntityToContact SLEC ON SLEC.intEntityId = SLEntity.intEntityId
		LEFT JOIN   tblEMEntity SLETC ON SLETC .intEntityId = SLEC.intEntityContactId
		LEFT JOIN	tblSMCurrency InsuranceCur ON InsuranceCur.intCurrencyID = L.intInsuranceCurrencyId
		LEFT JOIN	tblLGWarehouseInstructionHeader WI ON WI.intShipmentId = L.intLoadId
		LEFT JOIN	tblCTContractBasis Basis ON Basis.intContractBasisId = CH.intContractBasisId
		LEFT JOIN	tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
		CROSS APPLY tblLGCompanyPreference CP
		WHERE LW.intLoadWarehouseId = @intLoadWarehouseId
	END
END