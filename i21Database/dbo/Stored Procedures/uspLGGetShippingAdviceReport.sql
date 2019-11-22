CREATE PROCEDURE [dbo].[uspLGGetShippingAdviceReport]
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
			@strShippingLineName		NVARCHAR(MAX),
			@intLaguageId			INT,
			@strExpressionLabelName	NVARCHAR(50) = 'Expression',
			@strMonthLabelName		NVARCHAR(50) = 'Month'
			
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

	INSERT INTO @temp_xml_table
	SELECT	*  
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/dummies/filter', 2)  
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
    
	SELECT	@intLaguageId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intSrLanguageId'

	SELECT TOP 1 @strCompanyName = tblSMCompanySetup.strCompanyName
				,@strCompanyAddress = tblSMCompanySetup.strAddress
				,@strContactName = tblSMCompanySetup.strContactName
				,@strCounty = tblSMCompanySetup.strCounty
				,@strCity = tblSMCompanySetup.strCity
				,@strState = tblSMCompanySetup.strState
				,@strZip = tblSMCompanySetup.strZip
				,@strCountry = ISNULL(rtrt9.strTranslation,tblSMCompanySetup.strCountry)
				,@strPhone = tblSMCompanySetup.strPhone
	FROM tblSMCompanySetup
	LEFT JOIN tblSMCountry				rtc9 ON LOWER(RTRIM(LTRIM(rtc9.strCountry))) = LOWER(RTRIM(LTRIM(tblSMCompanySetup.strCountry)))
	LEFT JOIN tblSMScreen				rts9 ON rts9.strNamespace = 'i21.view.Country'
	LEFT JOIN tblSMTransaction			rtt9 ON rtt9.intScreenId = rts9.intScreenId and rtt9.intRecordId = rtc9.intCountryID
	LEFT JOIN tblSMReportTranslation	rtrt9 ON rtrt9.intLanguageId = @intLaguageId and rtrt9.intTransactionId = rtt9.intTransactionId and rtrt9.strFieldName = 'Country'

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

	/*Declared variables for translating expression*/
	declare @strShipmentQtyInfo nvarchar(500) = ISNULL(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Shipment in'), 'Shipment in');
	declare @strReleaseOrderText1 nvarchar(500) = ISNULL(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Attn'), 'Attn');
	declare @strReleaseOrderText2 nvarchar(500) = ISNULL(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Please release the cargo in favour of'), 'Please release the cargo in favour of');


	SELECT @strReleaseOrderText = @strReleaseOrderText1 + ' '+ ISNULL(@strShippingLineName,'') +' : '+@strReleaseOrderText2+' ' + @strWarehouseEntityName
	
	SELECT @strLogisticsCompanyName = strLogisticsCompanyName,
		   @strLogisticsPrintSignOff = strLogisticsPrintSignOff
	FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intCompanyLocationId

	BEGIN
		SELECT TOP 1
				strTrackingNumber = L.strLoadNumber,
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
				L.dtmBLDate,
				L.dtmScheduledDate,
				strScheduledDate = DATENAME(dd, L.dtmScheduledDate) + ' ' + ISNULL(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,L.dtmScheduledDate),3)),LEFT(DATENAME(MONTH,L.dtmScheduledDate),3)) + ' ' + DATENAME(yyyy, L.dtmScheduledDate),
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
				strVendorCountry = ISNULL(rtrt5.strTranslation,VLocation.strCountry),
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
				strCustomerCountry = ISNULL(rtrt4.strTranslation,CLocation.strCountry),
				strCustomerState = CLocation.strState,
				strCustomerZipCode = CLocation.strZipCode,
				strCustomerCityStateZip = CLocation.strCity + ', ' + CLocation.strState + ', ' + CLocation.strZipCode + ',',

  				strShippingLine = SLEntity.strName,
				strShippingLineEmail = SLEntity.strEmail,
				strShippingLineFax = SLEntity.strFax,
				strShippingLinePhone = SLEntity.strPhone,
				strShippingLineMobile = SLEntity.strMobile,
				strShippingLineWebsite = SLEntity.strWebsite,
				strShippingLineAddress = SLLocation.strAddress,
				strShippingLineCity = SLLocation.strCity,
				strShippingLineCountry = ISNULL(rtrt6.strTranslation,SLLocation.strCountry),
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
				strTerminalCountry = ISNULL(rtrt7.strTranslation,TerminalLocation.strCountry),
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
				strInsurerCountry = ISNULL(rtrt8.strTranslation,InsurLocation.strCountry),
				strInsurerState = InsurLocation.strState,
				strInsurerZipCode = InsurLocation.strZipCode,

				strWarehouse = WH.strSubLocationName,
				strWarehouseDescription = WH.strSubLocationDescription,
				strWarehouseAddress = WH.strAddress,
				strWarehouseCity = WH.strCity,
				strWarehouseClassification = WH.strClassification,
				strWarehouseState = WH.strState,
				strWarehouseZipCode = WH.strZipCode,

				WI.intWarehouseInstructionHeaderId,
				LW.intLoadWarehouseId,
				Via.strName strShipVia,
				blbHeaderLogo = dbo.fnSMGetCompanyLogo('Header'),
				blbFooterLogo = dbo.fnSMGetCompanyLogo('Footer'),
				intReportLogoHeight = ISNULL(CP.intReportLogoHeight,0),
				intReportLogoWidth = ISNULL(CP.intReportLogoWidth,0),

				strCompanyName = @strCompanyName,
				strCompanyAddress = @strCompanyAddress,
				strCompanyContactName = @strContactName ,
				strCompanyCounty = @strCounty ,
				strCompanyCity = @strCity ,
				strCompanyState = @strState ,
				strCompanyZip = @strZip ,
				strCompanyCountry = @strCountry ,
				strCompanyPhone = @strPhone ,
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
				L.strShippingMode,
				strCertificationName = (SELECT TOP 1 strCertificationName
										FROM tblICCertification CER
										JOIN tblCTContractCertification CTCER ON CTCER.intCertificationId = CER.intCertificationId
										WHERE CTCER.intContractDetailId = CD.intContractDetailId),
				blbFullHeaderLogo = dbo.fnSMGetCompanyLogo('FullHeaderLogo'),
				blbFullFooterLogo = dbo.fnSMGetCompanyLogo('FullFooterLogo'),
				CH.strContractNumber,
				CH.strCustomerContract,
				L.strBLNumber,
				I.strItemNo,
				strItemDescription = ISNULL(rtrt3.strTranslation,I.strDescription),
				ysnFullHeaderLogo = CASE WHEN CP.ysnFullHeaderLogo = 1 THEN 'true' ELSE 'false' END,
				dblLoadWeight = LDT.dblNet,
				strLoadWeightUOM = ISNULL(rtUMTranslation.strTranslation,UM.strUnitMeasure),
				strShipmentWeightInfo = LTRIM(dbo.fnRemoveTrailingZeroes(LDT.dblNet)) + ' ' + ISNULL(rtrt2.strTranslation,WUM.strUnitMeasure),
				strShipmentQtyInfo = LTRIM(dbo.fnRemoveTrailingZeroes(LDT.dblQuantity)) + ' ' + ISNULL(rtUMTranslation.strTranslation,UM.strUnitMeasure) + ' ' + '('+@strShipmentQtyInfo+' ' + ISNULL(rtUMTranslation.strTranslation,UM.strUnitMeasure) +')',
				CD.dtmStartDate,
				CD.dtmEndDate,
				strStartDate = DATENAME(dd, CD.dtmStartDate) + '-' + ISNULL(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,CD.dtmStartDate),3)),LEFT(DATENAME(MONTH,CD.dtmStartDate),3)) + '-' + DATENAME(yyyy, CD.dtmStartDate),
				strEndDate = DATENAME(dd, CD.dtmEndDate) + '-' + ISNULL(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,CD.dtmEndDate),3)),LEFT(DATENAME(MONTH,CD.dtmEndDate),3)) + '-' + DATENAME(yyyy, CD.dtmEndDate),
				strStartToEndDate = DATENAME(dd, CD.dtmStartDate) + '-' + ISNULL(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,CD.dtmStartDate),3)),LEFT(DATENAME(MONTH,CD.dtmStartDate),3)) + '-' + DATENAME(yyyy, CD.dtmStartDate) + ' - ' + DATENAME(dd, CD.dtmEndDate) + '-' + ISNULL(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,CD.dtmEndDate),3)),LEFT(DATENAME(MONTH,CD.dtmEndDate),3)) + '-' + DATENAME(yyyy, CD.dtmEndDate),
				strMarks = (SELECT STUFF((
						SELECT ', ' + LTRIM(MRK.strMarks)
						FROM (
							SELECT (strMarks ) AS strMarks
							FROM tblLGLoadContainer LOC
							WHERE LOC.intLoadId = L.intLoadId
							) MRK
						FOR XML PATH('')
						), 1, 2, ''))
		FROM	tblLGLoad L
		INNER JOIN	tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		INNER JOIN	tblCTContractDetail CD ON CD.intContractDetailId = CASE WHEN L.intPurchaseSale = 1 THEN LD.intPContractDetailId ELSE LD.intSContractDetailId END
		INNER JOIN	tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		INNER JOIN	tblICItem I ON I.intItemId = CD.intItemId 
		
		OUTER APPLY (SELECT dblNet = SUM(dblNet), dblQuantity = SUM(dblQuantity) FROM tblLGLoadDetail LOD WHERE LOD.intLoadDetailId = LD.intLoadDetailId) LDT
		LEFT JOIN	tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
		LEFT JOIN	tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
		LEFT JOIN	tblICItemUOM WU ON WU.intItemUOMId = LD.intWeightItemUOMId
		LEFT JOIN	tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WU.intUnitMeasureId
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
		CROSS APPLY tblLGCompanyPreference CP
	
		LEFT JOIN tblSMScreen				rts2 ON rts2.strNamespace = 'Inventory.view.ReportTranslation'
		LEFT JOIN tblSMTransaction			rtt2 ON rtt2.intScreenId = rts2.intScreenId and rtt2.intRecordId = WUM.intUnitMeasureId
		LEFT JOIN tblSMReportTranslation	rtrt2 ON rtrt2.intLanguageId = @intLaguageId and rtrt2.intTransactionId = rtt2.intTransactionId and rtrt2.strFieldName = 'Name'
	
		LEFT JOIN tblSMScreen				rts3 ON rts3.strNamespace = 'Inventory.view.Item'
		LEFT JOIN tblSMTransaction			rtt3 ON rtt3.intScreenId = rts3.intScreenId and rtt3.intRecordId = I.intItemId
		LEFT JOIN tblSMReportTranslation	rtrt3 ON rtrt3.intLanguageId = @intLaguageId and rtrt3.intTransactionId = rtt3.intTransactionId and rtrt3.strFieldName = 'Description'
		
		LEFT JOIN tblSMCountry				rtc4 ON LOWER(RTRIM(LTRIM(rtc4.strCountry))) = LOWER(RTRIM(LTRIM(CLocation.strCountry)))
		LEFT JOIN tblSMScreen				rts4 ON rts4.strNamespace = 'i21.view.Country'
		LEFT JOIN tblSMTransaction			rtt4 ON rtt4.intScreenId = rts4.intScreenId and rtt4.intRecordId = rtc4.intCountryID
		LEFT JOIN tblSMReportTranslation	rtrt4 ON rtrt4.intLanguageId = @intLaguageId and rtrt4.intTransactionId = rtt4.intTransactionId and rtrt4.strFieldName = 'Country'
		
		LEFT JOIN tblSMCountry				rtc5 ON LOWER(RTRIM(LTRIM(rtc5.strCountry))) = LOWER(RTRIM(LTRIM(VLocation.strCountry)))
		LEFT JOIN tblSMScreen				rts5 ON rts4.strNamespace = 'i21.view.Country'
		LEFT JOIN tblSMTransaction			rtt5 ON rtt4.intScreenId = rts5.intScreenId and rtt5.intRecordId = rtc5.intCountryID
		LEFT JOIN tblSMReportTranslation	rtrt5 ON rtrt4.intLanguageId = @intLaguageId and rtrt5.intTransactionId = rtt5.intTransactionId and rtrt5.strFieldName = 'Country'
				
		LEFT JOIN tblSMCountry				rtc6 ON LOWER(RTRIM(LTRIM(rtc6.strCountry))) = LOWER(RTRIM(LTRIM(SLLocation.strCountry)))
		LEFT JOIN tblSMScreen				rts6 ON rts6.strNamespace = 'i21.view.Country'
		LEFT JOIN tblSMTransaction			rtt6 ON rtt6.intScreenId = rts6.intScreenId and rtt6.intRecordId = rtc6.intCountryID
		LEFT JOIN tblSMReportTranslation	rtrt6 ON rtrt6.intLanguageId = @intLaguageId and rtrt6.intTransactionId = rtt6.intTransactionId and rtrt6.strFieldName = 'Country'
				
		LEFT JOIN tblSMCountry				rtc7 ON LOWER(RTRIM(LTRIM(rtc7.strCountry))) = LOWER(RTRIM(LTRIM(TerminalLocation.strCountry)))
		LEFT JOIN tblSMScreen				rts7 ON rts7.strNamespace = 'i21.view.Country'
		LEFT JOIN tblSMTransaction			rtt7 ON rtt7.intScreenId = rts7.intScreenId and rtt7.intRecordId = rtc7.intCountryID
		LEFT JOIN tblSMReportTranslation	rtrt7 ON rtrt7.intLanguageId = @intLaguageId and rtrt7.intTransactionId = rtt7.intTransactionId and rtrt7.strFieldName = 'Country'
						
		LEFT JOIN tblSMCountry				rtc8 ON LOWER(RTRIM(LTRIM(rtc8.strCountry))) = LOWER(RTRIM(LTRIM(InsurLocation.strCountry)))
		LEFT JOIN tblSMScreen				rts8 ON rts8.strNamespace = 'i21.view.Country'
		LEFT JOIN tblSMTransaction			rtt8 ON rtt8.intScreenId = rts8.intScreenId and rtt8.intRecordId = rtc8.intCountryID
		LEFT JOIN tblSMReportTranslation	rtrt8 ON rtrt8.intLanguageId = @intLaguageId and rtrt8.intTransactionId = rtt8.intTransactionId and rtrt8.strFieldName = 'Country'

		LEFT JOIN tblSMScreen				rtUMScreen ON rtUMScreen.strNamespace = 'Inventory.view.ReportTranslation'
		LEFT JOIN tblSMTransaction			rtUMTransaction ON rtUMTransaction.intScreenId = rtUMScreen.intScreenId and rtUMTransaction.intRecordId = UM.intUnitMeasureId
		LEFT JOIN tblSMReportTranslation	rtUMTranslation ON rtUMTranslation.intLanguageId = @intLaguageId and rtUMTranslation.intTransactionId = rtUMTransaction.intTransactionId and rtUMTranslation.strFieldName = 'Name'
	
		WHERE L.strLoadNumber = @strTrackingNumber
	END
END