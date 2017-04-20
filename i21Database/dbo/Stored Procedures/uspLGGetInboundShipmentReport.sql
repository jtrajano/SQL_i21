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
				'' AS strUserEmailId,
				'' AS strUserPhoneNo,
				L.strShippingMode,
				strCertificationName = (SELECT TOP 1 strCertificationName
										FROM tblICCertification CER
										JOIN tblCTContractCertification CTCER ON CTCER.intCertificationId = CER.intCertificationId
										WHERE CTCER.intContractDetailId = CD.intContractDetailId) 
		FROM		tblLGLoad L
		JOIN		tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		JOIN		tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
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
		LEFT JOIN   tblEMEntityToContact WEC ON WEC.intEntityId = WH.intVendorId
		LEFT JOIN   tblEMEntity WETC ON WETC .intEntityId = WEC.intEntityContactId
		LEFT JOIN   tblEMEntityToContact SLEC ON SLEC.intEntityId = SLEntity.intEntityId
		LEFT JOIN   tblEMEntity SLETC ON SLETC .intEntityId = SLEC.intEntityContactId
		LEFT JOIN	tblSMCurrency InsuranceCur ON InsuranceCur.intCurrencyID = L.intInsuranceCurrencyId
		LEFT JOIN	tblLGWarehouseInstructionHeader WI ON WI.intShipmentId = L.intLoadId
		WHERE L.strLoadNumber = @strTrackingNumber
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
				@strUserEmailId AS strUserEmailId,
				@strUserPhoneNo AS strUserPhoneNo,
				L.strShippingMode,
				strCertificationName = (SELECT TOP 1 strCertificationName
										FROM tblICCertification CER
										JOIN tblCTContractCertification CTCER ON CTCER.intCertificationId = CER.intCertificationId
										WHERE CTCER.intContractDetailId = CD.intContractDetailId) 
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
		WHERE LW.intLoadWarehouseId = @intLoadWarehouseId
	END
END