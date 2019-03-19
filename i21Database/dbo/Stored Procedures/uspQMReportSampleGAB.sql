-- Exec uspQMReportSampleGAB '<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intSampleId</fieldname><condition>EQUAL TO</condition><from>37</from><join /><begingroup /><endgroup /><datatype>Int32</datatype></filter></filters></xmlparam>'
CREATE PROCEDURE uspQMReportSampleGAB @xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intSampleId INT
		,@xmlDocumentId INT
	DECLARE @strCompanyName NVARCHAR(100)
		,@strCompanyAddress NVARCHAR(100)
		,@strCity NVARCHAR(25)
		,@strState NVARCHAR(50)
		,@strZip NVARCHAR(12)
		,@strCountry NVARCHAR(25)
		,@intReportLogoHeight INT
		,@intReportLogoWidth INT
		,@intAttributeId INT
		,@intLanguageId INT
		,@strMonthLabelName NVARCHAR(50) = 'Month'
		,@strSampleLabelName NVARCHAR(50) = 'SampleGab'
		,@dtmSampleReceivedDate DATETIME

	SELECT @intReportLogoHeight = intReportLogoHeight
		,@intReportLogoWidth = intReportLogoWidth
	FROM tblLGCompanyPreference WITH (NOLOCK)

	SELECT @intAttributeId = intAttributeId
	FROM tblQMAttribute WITH (NOLOCK)
	WHERE strAttributeName = 'Sample For'

	DECLARE @temp_xml_table TABLE (
		[fieldname] NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT
		,@xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH (
			[fieldname] NVARCHAR(50)
			,condition NVARCHAR(20)
			,[from] NVARCHAR(50)
			,[to] NVARCHAR(50)
			,[join] NVARCHAR(10)
			,[begingroup] NVARCHAR(50)
			,[endgroup] NVARCHAR(50)
			,[datatype] NVARCHAR(50)
			)

	SELECT @intSampleId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intSampleId'

	SELECT @intLanguageId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intSrLanguageId'

	SELECT @strCompanyName = CASE 
			WHEN LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) = ''
				THEN NULL
			ELSE LTRIM(RTRIM(tblSMCompanySetup.strCompanyName))
			END
		,@strCompanyAddress = CASE 
			WHEN LTRIM(RTRIM(tblSMCompanySetup.strAddress)) = ''
				THEN NULL
			ELSE LTRIM(RTRIM(tblSMCompanySetup.strAddress))
			END
		,@strCity = CASE 
			WHEN LTRIM(RTRIM(tblSMCompanySetup.strCity)) = ''
				THEN NULL
			ELSE LTRIM(RTRIM(tblSMCompanySetup.strCity))
			END
		,@strState = CASE 
			WHEN LTRIM(RTRIM(tblSMCompanySetup.strState)) = ''
				THEN NULL
			ELSE LTRIM(RTRIM(tblSMCompanySetup.strState))
			END
		,@strZip = CASE 
			WHEN LTRIM(RTRIM(tblSMCompanySetup.strZip)) = ''
				THEN NULL
			ELSE LTRIM(RTRIM(tblSMCompanySetup.strZip))
			END
		,@strCountry = CASE 
			WHEN LTRIM(RTRIM(tblSMCompanySetup.strCountry)) = ''
				THEN NULL
			ELSE LTRIM(RTRIM(isnull(rtrt9.strTranslation, tblSMCompanySetup.strCountry)))
			END
	FROM tblSMCompanySetup WITH (NOLOCK)
	LEFT JOIN tblSMCountry rtc9 WITH (NOLOCK) ON lower(rtrim(ltrim(rtc9.strCountry))) = lower(rtrim(ltrim(tblSMCompanySetup.strCountry)))
	LEFT JOIN tblSMScreen rts9 WITH (NOLOCK) ON rts9.strNamespace = 'i21.view.Country'
	LEFT JOIN tblSMTransaction rtt9 WITH (NOLOCK) ON rtt9.intScreenId = rts9.intScreenId
		AND rtt9.intRecordId = rtc9.intCountryID
	LEFT JOIN tblSMReportTranslation rtrt9 WITH (NOLOCK) ON rtrt9.intLanguageId = @intLanguageId
		AND rtrt9.intTransactionId = rtt9.intTransactionId
		AND rtrt9.strFieldName = 'Country'

	/*Declared variables for translating expression*/
	DECLARE @rtSample NVARCHAR(500) = isnull(dbo.fnCTGetTranslatedExpression(@strSampleLabelName, @intLanguageId, 'SAMPLE'), 'SAMPLE');
	DECLARE @rtRef NVARCHAR(500) = isnull(dbo.fnCTGetTranslatedExpression(@strSampleLabelName, @intLanguageId, ' Ref. '), ' Ref. ');
	DECLARE @strFW NVARCHAR(500)
		,@strFWRef NVARCHAR(500)
		,@strWH NVARCHAR(500)
		,@strWHRef NVARCHAR(500)
		,@strFWBlock NVARCHAR(500)
		,@strWHBlock NVARCHAR(500)
		,@strSampleRef NVARCHAR(500) = ''
		,--FW Agent + 'Ref.' + Fw Agent Ref + ' / ' + Warehouse + 'Ref.' + Warehouse Ref
		@strCourier NVARCHAR(500)
		,@strCourierRef NVARCHAR(500)
		,@strSentByCourier NVARCHAR(500) = ''
		,--Courier + ' - ' + Courier Ref
		@strBroker NVARCHAR(500)
		,@strBrokerRef NVARCHAR(500)
		,@strAgent NVARCHAR(500) = ''

	SELECT @strFW = E1.strName
		,@strFWRef = S.strForwardingAgentRef
		,@strWH = CS.strSubLocationName
		,@strWHRef = S.strRefNo
		,@strCourier = S.strCourier
		,@strCourierRef = S.strCourierRef
		,@dtmSampleReceivedDate = DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), S.dtmSampleReceivedDate)
	FROM tblQMSample S
	LEFT JOIN tblEMEntity E1 ON E1.intEntityId = S.intForwardingAgentId
	LEFT JOIN tblSMCompanyLocationSubLocation CS ON CS.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
	WHERE S.intSampleId = @intSampleId

	IF ISNULL(@strFWRef, '') <> ''
		SELECT @strFWBlock = ISNULL(@strFW, '') + @rtRef + @strFWRef
	ELSE
		SELECT @strFWBlock = ISNULL(@strFW, '')

	IF ISNULL(@strWHRef, '') <> ''
		SELECT @strWHBlock = ISNULL(@strWH, '') + @rtRef + @strWHRef
	ELSE
		SELECT @strWHBlock = ISNULL(@strWH, '')

	IF ISNULL(@strFWBlock, '') <> ''
		AND ISNULL(@strWHBlock, '') <> ''
		SELECT @strSampleRef = ISNULL(@strFWBlock, '') + ' / ' + @strWHBlock
	ELSE IF ISNULL(@strFWBlock, '') <> ''
		SELECT @strSampleRef = ISNULL(@strFWBlock, '')
	ELSE
		SELECT @strSampleRef = ISNULL(@strWHBlock, '')

	IF ISNULL(@strCourier, '') <> ''
		AND ISNULL(@strCourierRef, '') <> ''
		SELECT @strSentByCourier = ISNULL(@strCourier, '') + ' - ' + @strCourierRef
	ELSE IF ISNULL(@strCourier, '') <> ''
		SELECT @strSentByCourier = ISNULL(@strCourier, '')
	ELSE
		SELECT @strSentByCourier = ISNULL(@strCourierRef, '')

	SELECT TOP 1 @strBroker = E.strName
		,@strBrokerRef = CC.strReference
	FROM tblQMSample S
	LEFT JOIN tblCTContractCost CC ON CC.intContractDetailId = S.intContractDetailId
		AND CC.strPaidBy = 'Broker'
	LEFT JOIN tblEMEntity E ON E.intEntityId = CC.intVendorId
	WHERE S.intSampleId = @intSampleId
	ORDER BY CC.intContractCostId

	IF ISNULL(@strBroker, '') <> ''
		AND ISNULL(@strBrokerRef, '') <> ''
		SELECT @strAgent = ISNULL(@strBroker, '') + @rtRef + @strBrokerRef
	ELSE IF ISNULL(@strBroker, '') <> ''
		SELECT @strAgent = ISNULL(@strBroker, '')
	ELSE IF ISNULL(@strBrokerRef, '') <> ''
		SELECT @strAgent = @rtRef + ISNULL(@strBrokerRef, '')

	SELECT S.intSampleId
		,@strCompanyName AS strCompanyName
		,@strCompanyAddress AS strCompanyAddress
		,@strCity + ', ' + @strState + ', ' + @strZip AS strCityStateZip
		,@strCountry AS strCompanyCountry
		,ISNULL(@intReportLogoHeight, 0) AS intReportLogoHeight
		,ISNULL(@intReportLogoWidth, 0) AS intReportLogoWidth
		,(
			LTRIM(RTRIM(E.strEntityName)) + ', ' + CHAR(13) + CHAR(10) + ISNULL(LTRIM(RTRIM(E.strEntityAddress)), '') + ', ' + CHAR(13) + CHAR(10) + ISNULL(LTRIM(RTRIM(E.strEntityCity)), '') + ISNULL(', ' + CASE 
					WHEN LTRIM(RTRIM(E.strEntityState)) = ''
						THEN NULL
					ELSE LTRIM(RTRIM(E.strEntityState))
					END, '') + ISNULL(', ' + CASE 
					WHEN LTRIM(RTRIM(E.strEntityZipCode)) = ''
						THEN NULL
					ELSE LTRIM(RTRIM(E.strEntityZipCode))
					END, '') + ISNULL(', ' + CASE 
					WHEN LTRIM(RTRIM(E.strEntityCountry)) = ''
						THEN NULL
					ELSE LTRIM(RTRIM(dbo.fnCTGetTranslation('i21.view.Country', rtc10.intCountryID, @intLanguageId, 'Country', rtc10.strCountry)))
					END, '')
			) AS strOtherPartyAddress
		,ISNULL(@strCity + ', ', '') + LEFT(DATENAME(DAY, @dtmSampleReceivedDate), 2) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName, @intLanguageId, DATENAME(MONTH, @dtmSampleReceivedDate)), DATENAME(MONTH, @dtmSampleReceivedDate)) + ' ' + LEFT(DATENAME(YEAR, @dtmSampleReceivedDate), 4) AS strCompanyCityAndDate
		,@rtSample + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strSampleLabelName, @intLanguageId, SD.strAttributeValue), SD.strAttributeValue) AS strTitleText
		,S.strSampleNumber
		,dbo.fnCTGetTranslation('Quality.view.SampleType', ST.intSampleTypeId, @intLanguageId, 'Sample Type', ST.strSampleTypeName) AS strSampleTypeName
		,@strSampleRef AS strSampleRef
		,ISNULL(CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq), '') AS strContractNumber
		,dbo.fnRemoveTrailingZeroes(ISNULL(S.dblRepresentingQty, 0)) + ' / ' + dbo.fnCTGetTranslation('Inventory.view.ReportTranslation', UM1.intUnitMeasureId, @intLanguageId, 'Name', UM1.strUnitMeasure) AS strRepresentingQtyUOM
		,dbo.fnCTGetTranslation('Inventory.view.Item', I.intItemId, @intLanguageId, 'Description', I.strDescription) + CASE 
			WHEN ISNULL(CD.strItemSpecification, '') = ''
				THEN ''
			ELSE ', ' + CD.strItemSpecification
			END AS strItemDescWithSpec
		,LEFT(DATENAME(DAY, CD.dtmStartDate), 2) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName, @intLanguageId, DATENAME(MONTH, CD.dtmStartDate)), DATENAME(MONTH, CD.dtmStartDate)) + ' ' + LEFT(DATENAME(YEAR, CD.dtmStartDate), 4) + ' - ' + LEFT(DATENAME(DAy, CD.dtmEndDate), 2) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName, @intLanguageId, DATENAME(MONTH, CD.dtmEndDate)), DATENAME(MONTH, CD.dtmEndDate)) + ' ' + LEFT(DATENAME(YEAR, CD.dtmEndDate), 4) AS strStartAndEndDate
		,@strAgent AS strAgent
		,(
			CASE 
				WHEN S.strSentBy = 'Self'
					THEN CL1.strLocationName
				ELSE E2.strName
				END
			) AS strSentByParty
		,@strSentByCourier AS strSentByCourier
		,S.strComment AS strRemarks
	FROM tblQMSample S
	JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
		AND S.intSampleId = @intSampleId
	JOIN tblICItem I ON I.intItemId = S.intItemId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = S.intContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN vyuCTEntity E ON E.intEntityId = S.intEntityId
	LEFT JOIN tblSMCountry rtc10 ON lower(rtrim(ltrim(rtc10.strCountry))) = lower(rtrim(ltrim(E.strEntityCountry)))
	LEFT JOIN tblQMSampleDetail SD ON SD.intSampleId = S.intSampleId
		AND SD.intAttributeId = ISNULL(@intAttributeId, 0)
	LEFT JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = S.intRepresentingUOMId
	LEFT JOIN tblEMEntity E2 ON E2.intEntityId = S.intSentById
	LEFT JOIN tblSMCompanyLocation CL1 ON CL1.intCompanyLocationId = S.intSentById
END TRY

BEGIN CATCH
	SET @ErrMsg = 'uspQMReportSampleGAB - ' + ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,18
			,1
			,'WITH NOWAIT'
			)
END CATCH
