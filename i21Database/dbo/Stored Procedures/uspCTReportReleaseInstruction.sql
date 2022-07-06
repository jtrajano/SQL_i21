CREATE PROCEDURE [dbo].[uspCTReportReleaseInstruction]
	@xmlParam NVARCHAR(MAX) = NULL

AS

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX), @xmlDocumentId INT
		, @strCompanyName NVARCHAR(500)
		, @strAddress NVARCHAR(500)
		, @strCounty NVARCHAR(500)
		, @strCity NVARCHAR(500)
		, @strState NVARCHAR(500)
		, @strZip NVARCHAR(500)
		, @strCountry NVARCHAR(500)
		, @intContractDetailId INT
		, @intLaguageId INT
		, @intSrCurrentUserId INT
		, @strCurrentUser NVARCHAR(100)
		, @strMonthLabelName NVARCHAR(50) = 'Month'
		, @userSignature VARBINARY(MAX)
		, @strReportDateFormat NVARCHAR(50)
	
	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL
	
	DECLARE @temp_xml_table TABLE ([fieldname]  NVARCHAR(50)
		, condition    NVARCHAR(20)
		, [from]       NVARCHAR(50)
		, [to]         NVARCHAR(50)
		, [join]       NVARCHAR(10)
		, [begingroup] NVARCHAR(50)
		, [endgroup]   NVARCHAR(50)
		, [datatype]   NVARCHAR(50))
	
	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT
		, @xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
	WITH([fieldname] NVARCHAR(50)
		, condition NVARCHAR(20)
		, [from] NVARCHAR(50)
		, [to] NVARCHAR(50)
		, [join] NVARCHAR(10)
		, [begingroup] NVARCHAR(50)
		, [endgroup] NVARCHAR(50)
		, [datatype] NVARCHAR(50))
	
	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/dummies/filter', 2)
	WITH([fieldname] NVARCHAR(50)
		, condition NVARCHAR(20)
		, [from] NVARCHAR(50)
		, [to] NVARCHAR(50)
		, [join] NVARCHAR(10)
		, [begingroup] NVARCHAR(50)
		, [endgroup] NVARCHAR(50)
		, [datatype] NVARCHAR(50))

    SELECT @intContractDetailId = [from]
    FROM @temp_xml_table
    WHERE [fieldname] = 'intContractDetailId'

    SELECT @intLaguageId = [from]
    FROM @temp_xml_table
    WHERE [fieldname] = 'intSrLanguageId'

    SELECT @intSrCurrentUserId = [from]
    FROM @temp_xml_table
    WHERE [fieldname] = 'intSrCurrentUserId'

    SELECT @strCurrentUser = strName
    FROM tblEMEntity
    WHERE intEntityId = @intSrCurrentUserId

    SELECT TOP 1 @strReportDateFormat = strReportDateFormat FROM tblSMCompanyPreference

    SELECT @userSignature = Sig.blbDetail
    FROM tblSMSignature Sig WITH(NOLOCK)
	JOIN tblEMEntitySignature ESig ON ESig.intElectronicSignatureId = Sig.intSignatureId
	LEFT JOIN tblEMEntity ent ON ent.intEntityId = Sig.intEntityId
    WHERE Sig.intEntityId = @intSrCurrentUserId

    SELECT @strCompanyName = CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) = '' THEN NULL
								ELSE LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) END
		, @strAddress = CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strAddress)) = '' THEN NULL
							ELSE LTRIM(RTRIM(tblSMCompanySetup.strAddress)) END
		, @strCounty = CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCountry)) = '' THEN NULL
							ELSE LTRIM(RTRIM(ISNULL(rtrt9.strTranslation, tblSMCompanySetup.strCountry))) END
		, @strCity = CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCity)) = '' THEN NULL
						ELSE LTRIM(RTRIM(tblSMCompanySetup.strCity)) END
		, @strState = CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strState)) = '' THEN NULL
						ELSE LTRIM(RTRIM(tblSMCompanySetup.strState)) END
		, @strZip = CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strZip)) = '' THEN NULL
						ELSE LTRIM(RTRIM(tblSMCompanySetup.strZip)) END
		, @strCountry = CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCountry)) = '' THEN NULL
							ELSE LTRIM(RTRIM(ISNULL(rtrt9.strTranslation, tblSMCompanySetup.strCountry))) END
	FROM tblSMCompanySetup WITH(NOLOCK)
	LEFT JOIN tblSMCountry rtc9 WITH(NOLOCK) ON LOWER(RTRIM(LTRIM(rtc9.strCountry))) = LOWER(RTRIM(LTRIM(tblSMCompanySetup.strCountry)))
	LEFT JOIN tblSMScreen rts9 WITH(NOLOCK) ON rts9.strNamespace = 'i21.view.Country'
	LEFT JOIN tblSMTransaction rtt9 WITH(NOLOCK) ON rtt9.intScreenId = rts9.intScreenId AND rtt9.intRecordId = rtc9.intCountryID
	LEFT JOIN tblSMReportTranslation rtrt9 WITH(NOLOCK) ON rtrt9.intLanguageId = @intLaguageId AND rtrt9.intTransactionId = rtt9.intTransactionId AND rtrt9.strFieldName = 'Country'

    SELECT intContractHeaderId = CH.intContractHeaderId
		, intContractDetailId = CD.intContractDetailId
		, strBuyerRefNo = CASE WHEN CH.intContractTypeId = 1 THEN CH.strContractNumber
								ELSE CH.strCustomerContract END
		, strSellerRefNo = CASE WHEN CH.intContractTypeId = 2 THEN CH.strContractNumber
								ELSE CH.strCustomerContract END
		, strContractNumber = CH.strContractNumber + (CASE WHEN CH2.strContractNumber IS NULL THEN ''
														ELSE '/' + CH2.strContractNumber END)
		, strDestinationPointName = DP.strCity
		, strItemDescription = IM.strDescription
		, strQuantity = dbo.fnRemoveTrailingZeroes(CH.dblQuantity) + ' ' + UM.strUnitMeasure
		, strShipment = REPLACE(CONVERT(VARCHAR, GETDATE(), 107), LTRIM(DAY(GETDATE())) + ', ', '') + ' shipment at ' + CD.strFixationBy + '''s option'
		, strEntityAddress = LTRIM(RTRIM(EY.strEntityName)) + ', '
							+ CHAR(13) + CHAR(10) + ISNULL(LTRIM(RTRIM(EY.strEntityAddress)), '') + ', '
							+ CHAR(13) + CHAR(10) + ISNULL(LTRIM(RTRIM(EY.strEntityCity)), '')
							+ ISNULL(', ' + CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState)) END, '')
							+ ISNULL(', ' + CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END, '')
							+ ISNULL(', ' + CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END, '')
		, strBookEntityAddress = LTRIM(RTRIM(EV.strEntityName)) + ', '
								+ CHAR(13) + CHAR(10) + ISNULL(LTRIM(RTRIM(EV.strEntityAddress)), '') + ', '
								+ CHAR(13) + CHAR(10) + ISNULL(LTRIM(RTRIM(EV.strEntityCity)), '')
								+ ISNULL(', ' + CASE WHEN LTRIM(RTRIM(EV.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityState)) END, '')
								+ ISNULL(', ' + CASE WHEN LTRIM(RTRIM(EV.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityZipCode)) END, '')
								+ ISNULL(', ' + CASE WHEN LTRIM(RTRIM(EV.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityCountry)) END, '')
		, strLocationWithDate = CL.strLocationName + ', ' + CONVERT(VARCHAR, GETDATE(), 106)
		, strLocationWithOutDate = CL.strLocationName + ', '
		, dtmLocationDate = GETDATE()
		, strReportDateFormat = @strReportDateFormat
		, strCustomerContract = CH.strCustomerContract
		, strStraussText1 = '<p>Pls arrange for pre-shipment samples for the above mentioned consignment. Samples of 250 grams per lot should be drawn and sent by Courier <span style="text-decoration: underline;"><strong>21 days prior</strong></span> to shipment to the below stated address.</p>'
		, strCompanyName = @strCompanyName
		, strCurrentUser = @strCurrentUser
		, strReportTitle = (CASE WHEN POS.strPositionType = 'Shipment' THEN 'RELEASE INSTRUCTIONS'
								WHEN POS.strPositionType = 'Spot' THEN 'RELEASE INSTRUCTIONS'
								ELSE '' END)
		, strPositionLabel = (CASE WHEN POS.strPositionType = 'Shipment' THEN 'Shipment'
									WHEN POS.strPositionType = 'Spot' THEN 'Delivery'
									ELSE '' END)
		, strContractCondition2 = ISNULL(FT.strFreightTerm, '') + ISNULL(', ' + SL.strSubLocationName, '') + ISNULL(', ' + SL.strCity, '') + ISNULL(', ' + WG.strWeightGradeDesc, '')
		, strContractCondtion = ISNULL(FT.strFreightTerm, '') + ISNULL(', ' + CCC.strCity, '') + ISNULL(', ' + CCN.strCountry, '') + ISNULL(', ' + WG.strWeightGradeDesc, '')
		, strContractCondtionDeliveryDesc = (SELECT TOP 1 a.strConditionDescription
											FROM tblCTContractCondition a
											JOIN tblCTCondition b ON b.intConditionId = a.intConditionId
											WHERE a.intContractHeaderId = CH.intContractHeaderId
												AND b.strConditionName LIKE '%_DELIVERY_RELEASE_INSTRUCTION%')
		, strContractCondtionShipmentDesc = (SELECT TOP 1 a.strConditionDescription
											FROM tblCTContractCondition a
											JOIN tblCTCondition b ON b.intConditionId = a.intConditionId
											WHERE a.intContractHeaderId = CH.intContractHeaderId
												AND b.strConditionName LIKE '%_SHIPMENT_RELEASE_INSTRUCTION%')
		, strDeliveryPeriod = LEFT(DATENAME(DAY, CD.dtmStartDate), 2) + ' ' + ISNULL(dbo.fnCTGetTranslatedExpression(@strMonthLabelName, @intLaguageId, LEFT(DATENAME(MONTH, CD.dtmStartDate), 3)), LEFT(DATENAME(MONTH, CD.dtmStartDate), 3)) + ' ' + LEFT(DATENAME(YEAR, CD.dtmStartDate), 4) + ' to ' + LEFT(DATENAME(DAy, CD.dtmEndDate), 2) + ' ' + ISNULL(dbo.fnCTGetTranslatedExpression(@strMonthLabelName, @intLaguageId, LEFT(DATENAME(MONTH, CD.dtmEndDate), 3)), LEFT(DATENAME(MONTH, CD.dtmEndDate), 3)) + ' ' + LEFT(DATENAME(YEAR, CD.dtmEndDate), 4)
		, strShippingLineDescription = 'Kindly inform ' + ES.strName + ' at port of destination to release container(s) to:'
		, UserSignature = @userSignature
		, blbFooterLogo = dbo.fnSMGetCompanyLogo('Footer')
		, supplier.strName AS strSupplier
		, strUpdateAvailabilityDate = LEFT(DATENAME(DAY,  CD.dtmUpdatedAvailabilityDate), 2) + ' ' + ISNULL(dbo.fnCTGetTranslatedExpression(@strMonthLabelName, @intLaguageId, LEFT(DATENAME(MONTH,  CD.dtmUpdatedAvailabilityDate), 3)), LEFT(DATENAME(MONTH,  CD.dtmUpdatedAvailabilityDate), 3)) + ' ' + LEFT(DATENAME(YEAR, CD.dtmUpdatedAvailabilityDate), 4)
	FROM tblCTContractDetail CD
	JOIN tblCTContractHeader CH WITH(NOLOCK) ON CD.intContractHeaderId = CH.intContractHeaderId
	JOIN vyuCTEntity EY WITH(NOLOCK) ON EY.intEntityId = CH.intEntityId
		AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	JOIN tblICItem IM WITH(NOLOCK) ON IM.intItemId = CD.intItemId
	JOIN tblSMCompanyLocation CL WITH(NOLOCK) ON CL.intCompanyLocationId = CD.intCompanyLocationId
	LEFT JOIN tblCTBookVsEntity BE WITH(NOLOCK) ON BE.intBookId = CH.intBookId AND BE.intEntityId = CH.intEntityId
	LEFT JOIN vyuCTEntity EV WITH(NOLOCK) ON EV.intEntityId = BE.intEntityId AND EV.strEntityType IN ('Vendor', 'Customer')
	LEFT JOIN tblICCommodityUnitMeasure CU WITH(NOLOCK) ON CU.intCommodityUnitMeasureId = CH.intCommodityUOMId
	LEFT JOIN tblICUnitMeasure UM WITH(NOLOCK) ON UM.intUnitMeasureId = CU.intUnitMeasureId
	LEFT JOIN tblSMCity LP WITH(NOLOCK) ON LP.intCityId = CD.intLoadingPortId
	LEFT JOIN tblSMCity DP WITH(NOLOCK) ON DP.intCityId = CD.intDestinationPortId
	LEFT JOIN tblCTPosition POS WITH(NOLOCK) ON POS.intPositionId = CH.intPositionId
	LEFT JOIN tblLGAllocationDetail AD WITH(NOLOCK) ON CD.intContractDetailId = (CASE WHEN CH.intContractTypeId = 1 THEN AD.intPContractDetailId ELSE AD.intSContractDetailId END)
	LEFT JOIN tblCTContractDetail CD2 WITH(NOLOCK) ON CD2.intContractDetailId = (CASE WHEN CH.intContractTypeId = 1 THEN AD.intSContractDetailId ELSE AD.intPContractDetailId END)
	LEFT JOIN tblCTContractHeader CH2 WITH(NOLOCK) ON CH2.intContractHeaderId = CD2.intContractHeaderId
	LEFT JOIN tblSMFreightTerms FT WITH(NOLOCK) ON CH.intFreightTermId = FT.intFreightTermId
	LEFT JOIN tblSMCity CCC WITH(NOLOCK) ON CCC.intCityId = CH.intINCOLocationTypeId
	LEFT JOIN tblSMCountry CCN WITH(NOLOCK) ON CCN.intCountryID = CH.intCountryId
	LEFT JOIN tblCTWeightGrade WG WITH(NOLOCK) ON WG.intWeightGradeId = CH.intWeightId
	LEFT JOIN tblEMEntity ES WITH(NOLOCK) ON ES.intEntityId = CD.intShippingLineId
	LEFT JOIN tblEMEntity supplier WITH(NOLOCK) ON supplier.intEntityId = CH.intEntityId
	LEFT JOIN tblSMCompanyLocationSubLocation SL ON SL.intCompanyLocationSubLocationId = CH.intWarehouseId
	WHERE CD.intContractDetailId = @intContractDetailId
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR(@ErrMsg, 18, 1, 'WITH NOWAIT')
END CATCH