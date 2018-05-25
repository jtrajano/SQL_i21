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
				,@strCountry = isnull(rtrt9.strTranslation,tblSMCompanySetup.strCountry)
				,@strPhone = tblSMCompanySetup.strPhone
	FROM tblSMCompanySetup
	left join tblSMCountry				rtc9 on lower(rtrim(ltrim(rtc9.strCountry))) = lower(rtrim(ltrim(tblSMCompanySetup.strCountry)))
	left join tblSMScreen				rts9 on rts9.strNamespace = 'i21.view.Country'
	left join tblSMTransaction			rtt9 on rtt9.intScreenId = rts9.intScreenId and rtt9.intRecordId = rtc9.intCountryID
	left join tblSMReportTranslation	rtrt9 on rtrt9.intLanguageId = @intLaguageId and rtrt9.intTransactionId = rtt9.intTransactionId and rtrt9.strFieldName = 'Country'

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
	declare @strShipmentWeightInfo nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Shipment in'), 'Shipment in');
	declare @strReleaseOrderText1 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Attn'), 'Attn');
	declare @strReleaseOrderText2 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Please release the cargo in favour of'), 'Please release the cargo in favour of');


	SELECT @strReleaseOrderText = @strReleaseOrderText1 + ' '+ ISNULL(@strShippingLineName,'') +' : '+@strReleaseOrderText2+' ' + @strWarehouseEntityName
	
	SELECT @strLogisticsCompanyName = strLogisticsCompanyName,
		   @strLogisticsPrintSignOff = strLogisticsPrintSignOff
	FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intCompanyLocationId

	BEGIN
		SELECT TOP 1
				L.strLoadNumber AS strTrackingNumber,
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
				strScheduledDate = datename(dd, L.dtmScheduledDate) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,format(L.dtmScheduledDate, 'MMM')),format(L.dtmScheduledDate, 'MMM')) + ' ' + datename(yyyy, L.dtmScheduledDate),
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
				isnull(rtrt5.strTranslation,VLocation.strCountry) as strVendorCountry,
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
				isnull(rtrt4.strTranslation,CLocation.strCountry) as strCustomerCountry,
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
				isnull(rtrt6.strTranslation,SLLocation.strCountry) as strShippingLineCountry,
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
				isnull(rtrt7.strTranslation,TerminalLocation.strCountry) as strTerminalCountry,
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
				isnull(rtrt8.strTranslation,InsurLocation.strCountry) as strInsurerCountry,
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
				L.strShippingMode,
				strCertificationName = (SELECT TOP 1 strCertificationName
										FROM tblICCertification CER
										JOIN tblCTContractCertification CTCER ON CTCER.intCertificationId = CER.intCertificationId
										WHERE CTCER.intContractDetailId = CD.intContractDetailId),
				dbo.fnSMGetCompanyLogo('FullHeaderLogo') AS blbFullHeaderLogo,
				dbo.fnSMGetCompanyLogo('FullFooterLogo') AS blbFullFooterLogo,
				CH.strContractNumber,
				CH.strCustomerContract,
				L.strBLNumber,
				I.strItemNo,
				isnull(rtrt3.strTranslation,I.strDescription) AS strItemDescription,
				CASE WHEN CP.ysnFullHeaderLogo = 1 THEN 'true' else 'false' END ysnFullHeaderLogo,
				(SELECT SUM(dblNet) FROM tblLGLoadDetail LOD WHERE LOD.intLoadDetailId = LD.intLoadDetailId) dblLoadWeight,
				isnull(rtUMTranslation.strTranslation,UM.strUnitMeasure) strLoadWeightUOM,
				LTRIM(dbo.fnRemoveTrailingZeroes((SELECT SUM(dblNet) FROM tblLGLoadDetail LOD WHERE LOD.intLoadDetailId = LD.intLoadDetailId))) + ' ' + isnull(rtrt2.strTranslation,WUM.strUnitMeasure) + ' ' + '('+@strShipmentWeightInfo+' ' + isnull(rtrt2.strTranslation,WUM.strUnitMeasure) +')' AS strShipmentWeightInfo,
				LTRIM(dbo.fnRemoveTrailingZeroes((SELECT SUM(dblQuantity) FROM tblLGLoadDetail LOD WHERE LOD.intLoadDetailId = LD.intLoadDetailId))) + ' ' + isnull(rtUMTranslation.strTranslation,UM.strUnitMeasure) AS strShipmentQtyInfo,
				CD.dtmStartDate,
				CD.dtmEndDate,
				(SELECT STUFF((
						SELECT ', ' + LTRIM(MRK.strMarks)
						FROM (
							SELECT (strMarks ) AS strMarks
							FROM tblLGLoadContainer LOC
							WHERE LOC.intLoadId = L.intLoadId --LIKE ('%' + (v.Value) + '%')
							) MRK
						FOR XML PATH('')
						), 1, 2, '')) strMarks
		FROM		tblLGLoad L
		JOIN		tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
		JOIN		tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		JOIN		tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		JOIN		tblICItem I ON I.intItemId = CD.intItemId 

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
	
		left join tblSMScreen				rts2 on rts2.strNamespace = 'Inventory.view.InventoryUOM'
		left join tblSMTransaction			rtt2 on rtt2.intScreenId = rts2.intScreenId and rtt2.intRecordId = WUM.intUnitMeasureId
		left join tblSMReportTranslation	rtrt2 on rtrt2.intLanguageId = @intLaguageId and rtrt2.intTransactionId = rtt2.intTransactionId and rtrt2.strFieldName = 'UOM'
	
		left join tblSMScreen				rts3 on rts3.strNamespace = 'Inventory.view.Item'
		left join tblSMTransaction			rtt3 on rtt3.intScreenId = rts3.intScreenId and rtt3.intRecordId = I.intItemId
		left join tblSMReportTranslation	rtrt3 on rtrt3.intLanguageId = @intLaguageId and rtrt3.intTransactionId = rtt3.intTransactionId and rtrt3.strFieldName = 'Description'
		
		left join tblSMCountry				rtc4 on lower(rtrim(ltrim(rtc4.strCountry))) = lower(rtrim(ltrim(CLocation.strCountry)))
		left join tblSMScreen				rts4 on rts4.strNamespace = 'i21.view.Country'
		left join tblSMTransaction			rtt4 on rtt4.intScreenId = rts4.intScreenId and rtt4.intRecordId = rtc4.intCountryID
		left join tblSMReportTranslation	rtrt4 on rtrt4.intLanguageId = @intLaguageId and rtrt4.intTransactionId = rtt4.intTransactionId and rtrt4.strFieldName = 'Country'
		
		left join tblSMCountry				rtc5 on lower(rtrim(ltrim(rtc5.strCountry))) = lower(rtrim(ltrim(VLocation.strCountry)))
		left join tblSMScreen				rts5 on rts4.strNamespace = 'i21.view.Country'
		left join tblSMTransaction			rtt5 on rtt4.intScreenId = rts5.intScreenId and rtt5.intRecordId = rtc5.intCountryID
		left join tblSMReportTranslation	rtrt5 on rtrt4.intLanguageId = @intLaguageId and rtrt5.intTransactionId = rtt5.intTransactionId and rtrt5.strFieldName = 'Country'
				
		left join tblSMCountry				rtc6 on lower(rtrim(ltrim(rtc6.strCountry))) = lower(rtrim(ltrim(SLLocation.strCountry)))
		left join tblSMScreen				rts6 on rts6.strNamespace = 'i21.view.Country'
		left join tblSMTransaction			rtt6 on rtt6.intScreenId = rts6.intScreenId and rtt6.intRecordId = rtc6.intCountryID
		left join tblSMReportTranslation	rtrt6 on rtrt6.intLanguageId = @intLaguageId and rtrt6.intTransactionId = rtt6.intTransactionId and rtrt6.strFieldName = 'Country'
				
		left join tblSMCountry				rtc7 on lower(rtrim(ltrim(rtc7.strCountry))) = lower(rtrim(ltrim(TerminalLocation.strCountry)))
		left join tblSMScreen				rts7 on rts7.strNamespace = 'i21.view.Country'
		left join tblSMTransaction			rtt7 on rtt7.intScreenId = rts7.intScreenId and rtt7.intRecordId = rtc7.intCountryID
		left join tblSMReportTranslation	rtrt7 on rtrt7.intLanguageId = @intLaguageId and rtrt7.intTransactionId = rtt7.intTransactionId and rtrt7.strFieldName = 'Country'
						
		left join tblSMCountry				rtc8 on lower(rtrim(ltrim(rtc8.strCountry))) = lower(rtrim(ltrim(InsurLocation.strCountry)))
		left join tblSMScreen				rts8 on rts8.strNamespace = 'i21.view.Country'
		left join tblSMTransaction			rtt8 on rtt8.intScreenId = rts8.intScreenId and rtt8.intRecordId = rtc8.intCountryID
		left join tblSMReportTranslation	rtrt8 on rtrt8.intLanguageId = @intLaguageId and rtrt8.intTransactionId = rtt8.intTransactionId and rtrt8.strFieldName = 'Country'

		left join tblSMScreen				rtUMScreen on rtUMScreen.strNamespace = 'Inventory.view.InventoryUOM'
		left join tblSMTransaction			rtUMTransaction on rtUMTransaction.intScreenId = rtUMScreen.intScreenId and rtUMTransaction.intRecordId = WUM.intUnitMeasureId
		left join tblSMReportTranslation	rtUMTranslation on rtUMTranslation.intLanguageId = @intLaguageId and rtUMTranslation.intTransactionId = rtUMTransaction.intTransactionId and rtUMTranslation.strFieldName = 'UOM'
	
		--
		WHERE L.strLoadNumber = @strTrackingNumber
	END
END