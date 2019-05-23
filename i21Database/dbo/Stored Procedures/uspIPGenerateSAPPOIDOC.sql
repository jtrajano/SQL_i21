CREATE PROCEDURE [dbo].[uspIPGenerateSAPPOIDOC] @ysnUpdateFeedStatusOnRead BIT = 0
AS
DECLARE @intMinSeq INT
	,@intContractFeedId INT
	,@intContractHeaderId INT
	,@intContractDetailId INT
	,@strCommodityCode NVARCHAR(100)
	,@strCommodityDesc NVARCHAR(100)
	,@strContractBasis NVARCHAR(100)
	,--INCOTERMS1
	@strContractBasisDesc NVARCHAR(500)
	,--INCOTERMS2
	@strSubLocation NVARCHAR(50)
	,--L-Plant / PLANT 
	@strCreatedBy NVARCHAR(50)
	,@strCreatedByNo NVARCHAR(50)
	,@strEntityNo NVARCHAR(100)
	,--VENDOR 
	@strTerm NVARCHAR(100)
	,--PMNTTRMS / VEND_PART 
	@strPurchasingGroup NVARCHAR(150)
	,@strContractNumber NVARCHAR(100)
	,@strERPPONumber NVARCHAR(100)
	,@intContractSeq INT
	,--PO_ITEM 
	@strItemNo NVARCHAR(100)
	,@strStorageLocation NVARCHAR(50)
	,--STGE_LOC 
	@dblQuantity NUMERIC(18, 6)
	,@strQuantityUOM NVARCHAR(50)
	,--PO_UNIT
	@dblCashPrice NUMERIC(18, 6)
	,--NET_PRICE
	@dblUnitCashPrice NUMERIC(18, 6)
	,--PRICE_UNIT 
	@dtmPlannedAvailabilityDate DATETIME
	,--DELIVERY_DATE 
	@dtmContractDate DATETIME
	,@dtmStartDate DATETIME
	,@dtmEndDate DATETIME
	,@dblBasis NUMERIC(18, 6)
	,--COND_VALUE,
	@strCurrency NVARCHAR(50)
	,--CURRENCY 
	@strPriceUOM NVARCHAR(50)
	,--COND_UNIT 
	@strRowState NVARCHAR(50)
	,@strFeedStatus NVARCHAR(50)
	,@strXml NVARCHAR(MAX)
	,@strDocType NVARCHAR(50)
	,@strPOCreateIDOCHeader NVARCHAR(MAX)
	,@strPOUpdateIDOCHeader NVARCHAR(MAX)
	,@strCompCode NVARCHAR(100)
	,@intMinRowNo INT
	,@strXmlHeaderStart NVARCHAR(MAX)
	,@strXmlHeaderEnd NVARCHAR(MAX)
	,@strHeaderState NVARCHAR(50)
	,@strContractFeedIds NVARCHAR(MAX)
	,@strERPPONumber1 NVARCHAR(100)
	,@strCertificates NVARCHAR(MAX)
	,@strOrigin NVARCHAR(100)
	,@strContractItemNo NVARCHAR(500)
	,@strItemXml NVARCHAR(MAX)
	,@strItemXXml NVARCHAR(MAX)
	,@strScheduleXml NVARCHAR(MAX)
	,@strScheduleXXml NVARCHAR(MAX)
	,@strCondXml NVARCHAR(MAX)
	,@strCondXXml NVARCHAR(MAX)
	,@strTextXml NVARCHAR(MAX)
	,@strSeq NVARCHAR(MAX)
	,@strProductType NVARCHAR(100)
	,@strVendorBatch NVARCHAR(100)
	,@str10Zeros NVARCHAR(50) = '0000000000'
	,@strProducer NVARCHAR(MAX)
	,@strLoadingPoint NVARCHAR(200)
	,@strPackingDescription NVARCHAR(50)
	,@intContractScreenId INT
	,@intTransactionId INT
	,@ysnOnceApproved BIT
DECLARE @tblOutput AS TABLE (
	intRowNo INT IDENTITY(1, 1)
	,strContractFeedIds NVARCHAR(MAX)
	,strRowState NVARCHAR(50)
	,strXml NVARCHAR(MAX)
	,strContractNo NVARCHAR(100)
	,strPONo NVARCHAR(100)
	)
DECLARE @tblHeader AS TABLE (
	intRowNo INT IDENTITY(1, 1)
	,intContractHeaderId INT
	,strCommodityCode NVARCHAR(50)
	,intContractFeedId INT
	,strSubLocation NVARCHAR(50)
	)

SELECT @strPOCreateIDOCHeader = dbo.fnIPGetSAPIDOCHeader('PO CREATE')

SELECT @strPOUpdateIDOCHeader = dbo.fnIPGetSAPIDOCHeader('PO UPDATE')

SELECT @strCompCode = dbo.[fnIPGetSAPIDOCTagValue]('GLOBAL', 'COMP_CODE')

--Get the Headers
INSERT INTO @tblHeader (
	intContractHeaderId
	,strCommodityCode
	,intContractFeedId
	,strSubLocation
	)
SELECT intContractHeaderId
	,'COFFEE' AS strCommodityCode
	,intContractFeedId
	,'' AS strSubLocation
FROM tblCTContractFeed
WHERE ISNULL(strFeedStatus, '') = ''
	AND UPPER(strCommodityCode) = 'COFFEE'

UNION ALL

SELECT DISTINCT intContractHeaderId
	,'TEA' AS strCommodityCode
	,MAX(intContractFeedId) AS intContractFeedId
	,strSubLocation
FROM tblCTContractFeed
WHERE ISNULL(strFeedStatus, '') = ''
	AND UPPER(strCommodityCode) = 'TEA'
GROUP BY intContractHeaderId
	,strSubLocation
ORDER BY intContractHeaderId

SELECT @intMinRowNo = Min(intRowNo)
FROM @tblHeader

WHILE (@intMinRowNo IS NOT NULL) --Header Loop
BEGIN
	SET @strXml = ''
	SET @strXmlHeaderStart = ''
	SET @strXmlHeaderEnd = ''
	SET @strHeaderState = ''
	SET @strContractFeedIds = NULL

	SELECT @intContractHeaderId = intContractHeaderId
		,@strSubLocation = strSubLocation
		,@intContractFeedId = intContractFeedId
		,@strCommodityCode = strCommodityCode
	FROM @tblHeader
	WHERE intRowNo = @intMinRowNo

	SELECT @intContractScreenId = intScreenId
	FROM tblSMScreen
	WHERE strNamespace = 'ContractManagement.view.Contract'

	SELECT @intTransactionId = intTransactionId
		,@ysnOnceApproved = ysnOnceApproved
	FROM tblSMTransaction
	WHERE intRecordId = @intContractHeaderId
		AND intScreenId = @intContractScreenId

	IF ISNULL(@ysnOnceApproved, 0) <> 1
	BEGIN
		DELETE
		FROM tblCTContractFeed
		WHERE intContractHeaderId = @intContractHeaderId
	END

	IF UPPER(@strCommodityCode) = 'COFFEE'
	BEGIN
		SELECT @intMinSeq = @intContractFeedId

		SELECT @strContractFeedIds = @intContractFeedId

		SELECT @strHeaderState = CASE 
				WHEN UPPER(strRowState) = 'DELETE'
					THEN 'MODIFIED'
				ELSE UPPER(strRowState)
				END
		FROM tblCTContractFeed
		WHERE intContractFeedId = @intContractFeedId
	END

	IF UPPER(@strCommodityCode) = 'TEA'
	BEGIN
		SELECT @intMinSeq = Min(intContractFeedId)
		FROM tblCTContractFeed
		WHERE intContractHeaderId = @intContractHeaderId
			AND ISNULL(strSubLocation, '') = ISNULL(@strSubLocation, '')
			AND ISNULL(strFeedStatus, '') = ''
			AND UPPER(strCommodityCode) = 'TEA'

		SELECT @strContractFeedIds = ''

		SELECT @strContractFeedIds = @strContractFeedIds + CONVERT(VARCHAR, intContractFeedId) + ','
		FROM tblCTContractFeed
		WHERE intContractHeaderId = @intContractHeaderId
			AND ISNULL(strSubLocation, '') = ISNULL(@strSubLocation, '')
			AND ISNULL(strFeedStatus, '') = ''
			AND UPPER(strCommodityCode) = 'TEA'

		IF Len(@strContractFeedIds) > 0
			SELECT @strContractFeedIds = Left(@strContractFeedIds, Len(@strContractFeedIds) - 1)

		IF ISNULL(@strSubLocation, '') = ''
		BEGIN
			SELECT TOP 1 @strERPPONumber1 = strERPPONumber
			FROM tblCTContractDetail
			WHERE intContractHeaderId = @intContractHeaderId

			IF ISNULL(@strERPPONumber1, '') <> ''
			BEGIN
				SET @strHeaderState = 'MODIFIED'

				UPDATE tblCTContractFeed
				SET strERPPONumber = @strERPPONumber1
				WHERE intContractHeaderId = @intContractHeaderId
					AND ISNULL(strFeedStatus, '') = ''
					AND UPPER(strCommodityCode) = 'TEA'
			END
			ELSE
				SET @strHeaderState = 'ADDED'
		END
		ELSE
		BEGIN
			SELECT TOP 1 @strERPPONumber1 = strERPPONumber
			FROM tblCTContractDetail
			WHERE intContractHeaderId = @intContractHeaderId
				AND intSubLocationId = (
					SELECT TOP 1 intCompanyLocationSubLocationId
					FROM tblSMCompanyLocationSubLocation
					WHERE strSubLocationName = ISNULL(@strSubLocation, '')
						AND intCompanyLocationId = (
							SELECT TOP 1 intCompanyLocationId
							FROM tblCTContractDetail
							WHERE intContractHeaderId = @intContractHeaderId
							)
					)

			IF ISNULL(@strERPPONumber1, '') <> ''
			BEGIN
				SET @strHeaderState = 'MODIFIED'

				UPDATE tblCTContractFeed
				SET strERPPONumber = @strERPPONumber1
				WHERE intContractHeaderId = @intContractHeaderId
					AND ISNULL(strSubLocation, '') = ISNULL(@strSubLocation, '')
					AND ISNULL(strFeedStatus, '') = ''
					AND UPPER(strCommodityCode) = 'TEA'
			END
			ELSE
				SET @strHeaderState = 'ADDED'
		END

		--Send Create Feed only Once
		IF UPPER(@strCommodityCode) = 'TEA'
			AND @strHeaderState = 'ADDED'
			AND (
				SELECT TOP 1 UPPER(strRowState)
				FROM tblCTContractFeed
				WHERE intContractHeaderId = @intContractHeaderId
					AND intContractFeedId < (
						SELECT MIN(intContractFeedId)
						FROM tblCTContractFeed
						WHERE intContractHeaderId = @intContractHeaderId
							AND ISNULL(strFeedStatus, '') = ''
						)
				ORDER BY intContractFeedId
				) = 'ADDED'
			GOTO NEXT_PO

		--Sub Location validation
		IF UPPER(@strCommodityCode) = 'TEA'
			AND EXISTS (
				SELECT 1
				FROM tblCTContractFeed
				WHERE intContractHeaderId = @intContractHeaderId
					AND ISNULL(strFeedStatus, '') = ''
					AND ISNULL(strSubLocation, '') = ''
				)
		BEGIN
			UPDATE tblCTContractFeed
			SET strMessage = 'Sub Location is empty.'
			WHERE intContractHeaderId = @intContractHeaderId
				AND ISNULL(strFeedStatus, '') = ''
				AND ISNULL(strSubLocation, '') = ''

			GOTO NEXT_PO
		END

		--Storage Location validation
		IF UPPER(@strCommodityCode) = 'TEA'
			AND EXISTS (
				SELECT 1
				FROM tblCTContractFeed
				WHERE intContractHeaderId = @intContractHeaderId
					AND ISNULL(strFeedStatus, '') = ''
					AND ISNULL(strStorageLocation, '') = ''
				)
		BEGIN
			UPDATE tblCTContractFeed
			SET strMessage = 'Storage Location is empty.'
			WHERE intContractHeaderId = @intContractHeaderId
				AND ISNULL(strFeedStatus, '') = ''
				AND ISNULL(strStorageLocation, '') = ''

			GOTO NEXT_PO
		END
	END

	--Donot generate Modified Idoc if PO No is not there
	IF @strHeaderState = 'MODIFIED'
		AND (
			SELECT ISNULL(strERPPONumber, '')
			FROM tblCTContractFeed
			WHERE intContractFeedId = @intMinSeq
			) = ''
		GOTO NEXT_PO

	SET @strItemXml = ''
	SET @strItemXXml = ''
	SET @strScheduleXml = ''
	SET @strScheduleXXml = ''
	SET @strCondXml = ''
	SET @strCondXXml = ''
	SET @strTextXml = ''
	SET @strSeq = ''

	WHILE (@intMinSeq IS NOT NULL) --Sequence Loop
	BEGIN
		SELECT @intContractFeedId = intContractFeedId
			,@intContractHeaderId = intContractHeaderId
			,@intContractDetailId = intContractDetailId
			,@strCommodityCode = strCommodityCode
			,@strCommodityDesc = strCommodityDesc
			,@strContractBasis = strContractBasis
			,--INCOTERMS1
			@strContractBasisDesc = strContractBasisDesc
			,--INCOTERMS2
			@strSubLocation = strSubLocation
			,--L-Plant / PLANT 
			@strCreatedBy = strCreatedBy
			,@strCreatedByNo = strSubmittedByNo
			,@strEntityNo = strVendorAccountNum
			,--VENDOR 
			@strTerm = strTermCode
			,--PMNTTRMS / VEND_PART 
			@strPurchasingGroup = strPurchasingGroup
			,@strContractNumber = strContractNumber
			,@strERPPONumber = strERPPONumber
			,@intContractSeq = intContractSeq
			,--PO_ITEM 
			@strItemNo = strItemNo
			,@strStorageLocation = strStorageLocation
			,--STGE_LOC 
			@dblQuantity = dblNetWeight
			,@strQuantityUOM = (
				SELECT TOP 1 ISNULL(strSymbol, strUnitMeasure)
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = strNetWeightUOM
				)
			,--PO_UNIT
			@dblCashPrice = dblCashPrice
			,--NET_PRICE
			@dblUnitCashPrice = dblUnitCashPrice
			,--PRICE_UNIT 
			@dtmPlannedAvailabilityDate = dtmPlannedAvailabilityDate
			,--DELIVERY_DATE 
			@dtmContractDate = dtmContractDate
			,@dtmStartDate = dtmStartDate
			,--VPER_START
			@dtmEndDate = dtmEndDate
			,--VPER_END
			@dblBasis = dblBasis
			,--COND_VALUE,
			@strCurrency = strCurrency
			,--CURRENCY 
			@strPriceUOM = (
				SELECT TOP 1 ISNULL(strSymbol, strUnitMeasure)
				FROM tblICUnitMeasure
				WHERE strUnitMeasure = strPriceUOM
				)
			,--COND_UNIT 
			@strRowState = strRowState
			,@strFeedStatus = strFeedStatus
			,@strContractItemNo = strContractItemNo
			,@strOrigin = strOrigin
			,@strProducer = strProducer
			,@strLoadingPoint = strLoadingPoint
			,@strPackingDescription = strPackingDescription
		FROM tblCTContractFeed
		WHERE intContractFeedId = @intMinSeq

		--Send Create Feed only Once
		IF UPPER(@strCommodityCode) = 'COFFEE'
			AND @strHeaderState = 'ADDED'
			AND (
				SELECT TOP 1 UPPER(strRowState)
				FROM tblCTContractFeed
				WHERE intContractDetailId = @intContractDetailId
					AND intContractFeedId < @intContractFeedId
				ORDER BY intContractFeedId
				) = 'ADDED'
			GOTO NEXT_PO

		--Sub Location validation
		IF UPPER(@strCommodityCode) = 'COFFEE'
			AND ISNULL(@strSubLocation, '') = ''
		BEGIN
			UPDATE tblCTContractFeed
			SET strMessage = 'Sub Location is empty.'
			WHERE intContractFeedId = @intContractFeedId

			GOTO NEXT_PO
		END

		--Storage Location validation
		IF UPPER(@strCommodityCode) = 'COFFEE'
			AND ISNULL(@strStorageLocation, '') = ''
		BEGIN
			UPDATE tblCTContractFeed
			SET strMessage = 'Storage Location is empty.'
			WHERE intContractFeedId = @intContractFeedId

			GOTO NEXT_PO
		END

		SET @strSeq = ISNULL(@strSeq, '') + CONVERT(VARCHAR, @intContractSeq) + ','

		--Convert price USC to USD
		IF UPPER(@strCurrency) = 'USC'
		BEGIN
			SET @strCurrency = 'USD'
			SET @dblBasis = ISNULL(@dblBasis, 0) / 100
			SET @dblCashPrice = ISNULL(@dblCashPrice, 0) / 100
		END

		SET @strProductType = ''

		SELECT TOP 1 @strProductType = ca.strDescription
		FROM tblICItem i
		JOIN tblICCommodityAttribute ca ON i.intProductTypeId = ca.intCommodityAttributeId
		WHERE ca.strType = 'ProductType'
			AND i.strItemNo = @strItemNo

		SET @strVendorBatch = ''

		SELECT @strVendorBatch = strVendorLotID
		FROM tblCTContractDetail
		WHERE intContractDetailId = @intContractDetailId

		--Find Doc Type
		IF @strContractBasis IN (
				'FCA'
				,'EXW'
				,'DDP'
				,'DAP'
				,'DDU'
				,'CPT'
				)
			SET @strDocType = 'ZHDE'

		IF @strContractBasis IN (
				'FOB'
				,'CFR'
				)
			SET @strDocType = 'ZHUB'

		IF @strSubLocation IN ('L953')
			SET @strDocType = 'ZB2B'

		IF ISNULL(@strDocType, '') = ''
			SET @strDocType = 'ZHUB'

		IF UPPER(@strHeaderState) = 'MODIFIED'
		BEGIN
			--update first entry in feed table if empty
			UPDATE tblCTContractFeed
			SET strDocType = @strDocType
			WHERE intContractFeedId = (
					SELECT TOP 1 intContractFeedId
					FROM tblCTContractFeed
					WHERE intContractDetailId = @intContractDetailId
					)
				AND ISNULL(strDocType, '') = ''

			SELECT TOP 1 @strDocType = strDocType
			FROM tblCTContractFeed
			WHERE intContractDetailId = @intContractDetailId
		END

		--update in feed table
		UPDATE tblCTContractFeed
		SET strDocType = @strDocType
		WHERE intContractFeedId = @intContractFeedId

		--Header Start Xml
		IF ISNULL(@strXmlHeaderStart, '') = ''
		BEGIN
			IF UPPER(@strHeaderState) = 'ADDED'
			BEGIN
				SET @strXmlHeaderStart = '<PORDCR103>'
				SET @strXmlHeaderStart += '<IDOC BEGIN="1">'
				--IDOC Header
				SET @strXmlHeaderStart += '<EDI_DC40 SEGMENT="1">'
				SET @strXmlHeaderStart += @strPOCreateIDOCHeader
				SET @strXmlHeaderStart += '</EDI_DC40>'
				SET @strXmlHeaderStart += '<E1PORDCR1 SEGMENT="1">'
			END

			IF UPPER(@strHeaderState) = 'MODIFIED'
			BEGIN
				SET @strXmlHeaderStart = '<PORDCH03>'
				SET @strXmlHeaderStart += '<IDOC BEGIN="1">'
				--IDOC Header
				SET @strXmlHeaderStart += '<EDI_DC40 SEGMENT="1">'
				SET @strXmlHeaderStart += @strPOUpdateIDOCHeader
				SET @strXmlHeaderStart += '</EDI_DC40>'
				SET @strXmlHeaderStart += '<E1PORDCH SEGMENT="1">'
				SET @strXmlHeaderStart += '<PURCHASEORDER>' + ISNULL(@strERPPONumber, '') + '</PURCHASEORDER>'
			END

			IF UPPER(@strHeaderState) = 'ADDED'
				OR UPPER(@strHeaderState) = 'MODIFIED'
			BEGIN
				--Header
				SET @strXmlHeaderStart += '<E1BPMEPOHEADER SEGMENT="1">'

				IF UPPER(@strHeaderState) = 'MODIFIED'
					SET @strXmlHeaderStart += '<PO_NUMBER>' + ISNULL(@strERPPONumber, '') + '</PO_NUMBER>'
				SET @strXmlHeaderStart += '<COMP_CODE>' + ISNULL(@strCompCode, '') + '</COMP_CODE>'
				SET @strXmlHeaderStart += '<DOC_TYPE>' + ISNULL(@strDocType, '') + '</DOC_TYPE>'
				SET @strXmlHeaderStart += '<CREAT_DATE>' + ISNULL(CONVERT(VARCHAR(10), @dtmContractDate, 112), '') + '</CREAT_DATE>'
				SET @strXmlHeaderStart += '<CREATED_BY>' + ISNULL(@strCreatedByNo, '') + '</CREATED_BY>'
				SET @strXmlHeaderStart += '<VENDOR>' + ISNULL(@strEntityNo, '') + '</VENDOR>'
				SET @strXmlHeaderStart += '<PMNTTRMS>' + ISNULL(@strTerm, '') + '</PMNTTRMS>'
				SET @strXmlHeaderStart += '<PURCH_ORG>' + '0380' + '</PURCH_ORG>'
				SET @strXmlHeaderStart += '<PUR_GROUP>' + ISNULL(@strPurchasingGroup, '') + '</PUR_GROUP>'
				SET @strXmlHeaderStart += '<DOC_DATE>' + ISNULL(CONVERT(VARCHAR(10), @dtmContractDate, 112), '') + '</DOC_DATE>'
				SET @strXmlHeaderStart += '<VPER_START>' + ISNULL(CONVERT(VARCHAR(10), @dtmStartDate, 112), '') + '</VPER_START>'
				SET @strXmlHeaderStart += '<VPER_END>' + ISNULL(CONVERT(VARCHAR(10), @dtmEndDate, 112), '') + '</VPER_END>'
				SET @strXmlHeaderStart += '<REF_1>' + ISNULL(@strContractNumber, '') + '</REF_1>'
				SET @strXmlHeaderStart += '<INCOTERMS1>' + dbo.fnEscapeXML(ISNULL(@strContractBasis, '')) + '</INCOTERMS1>'
				SET @strXmlHeaderStart += '<INCOTERMS2>' + dbo.fnEscapeXML(ISNULL(@strLoadingPoint, '')) + '</INCOTERMS2>'
				SET @strXmlHeaderStart += '</E1BPMEPOHEADER>'
				--HeaderX
				SET @strXmlHeaderStart += '<E1BPMEPOHEADERX SEGMENT="1">'

				IF UPPER(@strHeaderState) = 'MODIFIED'
					SET @strXmlHeaderStart += '<PO_NUMBER>' + 'X' + '</PO_NUMBER>'

				IF @strCompCode IS NOT NULL
					SET @strXmlHeaderStart += '<COMP_CODE>' + 'X' + '</COMP_CODE>'

				IF UPPER(@strHeaderState) = 'ADDED'
					AND @strDocType IS NOT NULL
					SET @strXmlHeaderStart += '<DOC_TYPE>' + 'X' + '</DOC_TYPE>'

				IF UPPER(@strHeaderState) = 'MODIFIED'
					AND (
						@strContractBasis IS NOT NULL
						OR @strSubLocation IS NOT NULL
						)
					SET @strXmlHeaderStart += '<DOC_TYPE>' + 'X' + '</DOC_TYPE>'

				IF @dtmContractDate IS NOT NULL
					SET @strXmlHeaderStart += '<CREAT_DATE>' + 'X' + '</CREAT_DATE>'

				IF @strCreatedByNo IS NOT NULL
					SET @strXmlHeaderStart += '<CREATED_BY>' + 'X' + '</CREATED_BY>'

				IF @strEntityNo IS NOT NULL
					SET @strXmlHeaderStart += '<VENDOR>' + 'X' + '</VENDOR>'

				IF @strTerm IS NOT NULL
					SET @strXmlHeaderStart += '<PMNTTRMS>' + 'X' + '</PMNTTRMS>'
				SET @strXmlHeaderStart += '<PURCH_ORG>' + 'X' + '</PURCH_ORG>'

				IF @strPurchasingGroup IS NOT NULL
					SET @strXmlHeaderStart += '<PUR_GROUP>' + 'X' + '</PUR_GROUP>'

				IF @dtmContractDate IS NOT NULL
					SET @strXmlHeaderStart += '<DOC_DATE>' + 'X' + '</DOC_DATE>'

				IF @dtmStartDate IS NOT NULL
					SET @strXmlHeaderStart += '<VPER_START>' + 'X' + '</VPER_START>'

				IF @dtmEndDate IS NOT NULL
					SET @strXmlHeaderStart += '<VPER_END>' + 'X' + '</VPER_END>'

				IF @strContractNumber IS NOT NULL
					SET @strXmlHeaderStart += '<REF_1>' + 'X' + '</REF_1>'

				IF @strContractBasis IS NOT NULL
					SET @strXmlHeaderStart += '<INCOTERMS1>' + 'X' + '</INCOTERMS1>'

				IF @strContractBasisDesc IS NOT NULL
					SET @strXmlHeaderStart += '<INCOTERMS2>' + 'X' + '</INCOTERMS2>'
				SET @strXmlHeaderStart += '</E1BPMEPOHEADERX>'
			END
		END

		--Repeat Details
		BEGIN
			--Item
			SET @strItemXml += '<E1BPMEPOITEM SEGMENT="1">'

			IF UPPER(@strCommodityCode) = 'COFFEE'
				SET @strItemXml += '<PO_ITEM>' + '0001' + '</PO_ITEM>'
			ELSE
				SET @strItemXml += '<PO_ITEM>' + ISNULL(RIGHT('0000' + CONVERT(VARCHAR, @intContractSeq), 4), '') + '</PO_ITEM>'

			IF UPPER(@strRowState) = 'DELETE'
				SET @strItemXml += '<DELETE_IND>' + 'X' + '</DELETE_IND>'

			IF UPPER(@strCommodityCode) = 'TEA'
				SET @strItemXml += '<MATERIAL>' + dbo.fnEscapeXML(ISNULL(ISNULL(@str10Zeros + @strContractItemNo, @str10Zeros + @strItemNo), '')) + '</MATERIAL>'
			ELSE
				SET @strItemXml += '<MATERIAL>' + dbo.fnEscapeXML(ISNULL(@str10Zeros + @strItemNo, '')) + '</MATERIAL>'

			SET @strItemXml += '<PLANT>' + ISNULL(@strSubLocation, '') + '</PLANT>'
			SET @strItemXml += '<STGE_LOC>' + ISNULL(@strStorageLocation, '') + '</STGE_LOC>'
			SET @strItemXml += '<TRACKINGNO>' + ISNULL(CONVERT(VARCHAR, @intContractDetailId), '') + '</TRACKINGNO>'
			SET @strItemXml += '<QUANTITY>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), @dblQuantity)), '') + '</QUANTITY>'
			SET @strItemXml += '<PO_UNIT>' + ISNULL(@strQuantityUOM, '') + '</PO_UNIT>'
			SET @strItemXml += '<ORDERPR_UN>' + ISNULL(@strPriceUOM, '') + '</ORDERPR_UN>'
			SET @strItemXml += '<NET_PRICE>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), @dblCashPrice)), '0.00') + '</NET_PRICE>'

			IF UPPER(@strCommodityCode) = 'COFFEE'
				AND @strProductType IN (
					'Washed Arabica'
					,'Unwashed Arabica'
					)
				SET @strItemXml += '<PRICE_UNIT>' + '100' + '</PRICE_UNIT>'
			ELSE IF UPPER(@strCommodityCode) = 'COFFEE'
				AND @strProductType IN ('Robusta')
				SET @strItemXml += '<PRICE_UNIT>' + '1000' + '</PRICE_UNIT>'
			ELSE
				SET @strItemXml += '<PRICE_UNIT>' + '1' + '</PRICE_UNIT>'

			IF ISNULL(@dblCashPrice, 0) = 0
				SET @strItemXml += '<FREE_ITEM>' + 'X' + '</FREE_ITEM>'
			ELSE
				SET @strItemXml += '<FREE_ITEM>' + ' ' + '</FREE_ITEM>'

			SET @strItemXml += '<CONF_CTRL>' + 'SL08' + '</CONF_CTRL>'

			IF UPPER(@strCommodityCode) = 'COFFEE'
				SET @strItemXml += '<VEND_PART>' + ISNULL(@strTerm, '') + '</VEND_PART>'
			ELSE
				SET @strItemXml += '<VEND_PART>' + '' + '</VEND_PART>'

			IF UPPER(@strCommodityCode) = 'TEA'
				SET @strItemXml += '<VENDRBATCH>' + ISNULL(@strVendorBatch, '') + '</VENDRBATCH>'
			SET @strItemXml += '<PO_PRICE>' + '1' + '</PO_PRICE>'
			SET @strItemXml += '</E1BPMEPOITEM>'
			--ItemX
			SET @strItemXXml += '<E1BPMEPOITEMX SEGMENT="1">'

			IF UPPER(@strCommodityCode) = 'COFFEE'
				SET @strItemXXml += '<PO_ITEM>' + '0001' + '</PO_ITEM>'
			ELSE
				SET @strItemXXml += '<PO_ITEM>' + ISNULL(RIGHT('0000' + CONVERT(VARCHAR, @intContractSeq), 4), '') + '</PO_ITEM>'

			SET @strItemXXml += '<PO_ITEMX>' + 'X' + '</PO_ITEMX>'

			IF UPPER(@strRowState) = 'DELETE'
				SET @strItemXXml += '<DELETE_IND>' + 'X' + '</DELETE_IND>'

			IF @strItemNo IS NOT NULL
				SET @strItemXXml += '<MATERIAL>' + 'X' + '</MATERIAL>'

			IF @strSubLocation IS NOT NULL
				SET @strItemXXml += '<PLANT>' + 'X' + '</PLANT>'

			IF @strStorageLocation IS NOT NULL
				SET @strItemXXml += '<STGE_LOC>' + 'X' + '</STGE_LOC>'
			SET @strItemXXml += '<TRACKINGNO>' + 'X' + '</TRACKINGNO>'

			IF @dblQuantity IS NOT NULL
				SET @strItemXXml += '<QUANTITY>' + 'X' + '</QUANTITY>'

			IF @strQuantityUOM IS NOT NULL
				SET @strItemXXml += '<PO_UNIT>' + 'X' + '</PO_UNIT>'

			IF @strPriceUOM IS NOT NULL
				SET @strItemXXml += '<ORDERPR_UN>' + 'X' + '</ORDERPR_UN>'

			IF @dblCashPrice IS NOT NULL
				SET @strItemXXml += '<NET_PRICE>' + 'X' + '</NET_PRICE>'
			SET @strItemXXml += '<PRICE_UNIT>' + 'X' + '</PRICE_UNIT>'
			SET @strItemXXml += '<FREE_ITEM>' + 'X' + '</FREE_ITEM>'

			IF @strDocType = 'ZHUB'
				SET @strItemXXml += '<GR_BASEDIV>' + 'X' + '</GR_BASEDIV>'
			SET @strItemXXml += '<CONF_CTRL>' + 'X' + '</CONF_CTRL>'

			IF @strTerm IS NOT NULL
				AND UPPER(@strCommodityCode) = 'COFFEE'
				SET @strItemXXml += '<VEND_PART>' + 'X' + '</VEND_PART>'
			ELSE
				SET @strItemXXml += '<VEND_PART>' + ' ' + '</VEND_PART>'

			IF UPPER(@strCommodityCode) = 'TEA'
			BEGIN
				IF ISNULL(@strVendorBatch, '') <> ''
					SET @strItemXXml += '<VENDRBATCH>' + 'X' + '</VENDRBATCH>'
				ELSE
					SET @strItemXXml += '<VENDRBATCH>' + ' ' + '</VENDRBATCH>'
			END

			SET @strItemXXml += '<PO_PRICE>' + 'X' + '</PO_PRICE>'
			SET @strItemXXml += '</E1BPMEPOITEMX>'
			--Schedule
			SET @strScheduleXml += '<E1BPMEPOSCHEDULE SEGMENT="1">'

			IF UPPER(@strCommodityCode) = 'COFFEE'
				SET @strScheduleXml += '<PO_ITEM>' + '0001' + '</PO_ITEM>'
			ELSE
				SET @strScheduleXml += '<PO_ITEM>' + ISNULL(RIGHT('0000' + CONVERT(VARCHAR, @intContractSeq), 4), '') + '</PO_ITEM>'

			SET @strScheduleXml += '<SCHED_LINE>' + '0001' + '</SCHED_LINE>'
			SET @strScheduleXml += '<DEL_DATCAT_EXT>' + '1' + '</DEL_DATCAT_EXT>'
			SET @strScheduleXml += '<DELIVERY_DATE>' + ISNULL(CONVERT(VARCHAR(10), @dtmPlannedAvailabilityDate, 104), '') + '</DELIVERY_DATE>'
			SET @strScheduleXml += '<QUANTITY>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), @dblQuantity)), '') + '</QUANTITY>'
			SET @strScheduleXml += '</E1BPMEPOSCHEDULE>'
			--ScheduleX
			SET @strScheduleXXml += '<E1BPMEPOSCHEDULX SEGMENT="1">'

			IF UPPER(@strCommodityCode) = 'COFFEE'
				SET @strScheduleXXml += '<PO_ITEM>' + '0001' + '</PO_ITEM>'
			ELSE
				SET @strScheduleXXml += '<PO_ITEM>' + ISNULL(RIGHT('0000' + CONVERT(VARCHAR, @intContractSeq), 4), '') + '</PO_ITEM>'

			SET @strScheduleXXml += '<SCHED_LINE>' + '0001' + '</SCHED_LINE>'
			SET @strScheduleXXml += '<PO_ITEMX>' + 'X' + '</PO_ITEMX>'
			SET @strScheduleXXml += '<SCHED_LINEX>' + 'X' + '</SCHED_LINEX>'
			SET @strScheduleXXml += '<DEL_DATCAT_EXT>' + 'X' + '</DEL_DATCAT_EXT>'

			IF @dtmPlannedAvailabilityDate IS NOT NULL
				SET @strScheduleXXml += '<DELIVERY_DATE>' + 'X' + '</DELIVERY_DATE>'

			IF @dblQuantity IS NOT NULL
				SET @strScheduleXXml += '<QUANTITY>' + 'X' + '</QUANTITY>'
			SET @strScheduleXXml += '</E1BPMEPOSCHEDULX>'
			--Basis Information
			SET @strCondXml += '<E1BPMEPOCOND SEGMENT="1">'

			IF UPPER(@strCommodityCode) = 'COFFEE'
				SET @strCondXml += '<ITM_NUMBER>' + '0001' + '</ITM_NUMBER>'
			ELSE
				SET @strCondXml += '<ITM_NUMBER>' + ISNULL(RIGHT('0000' + CONVERT(VARCHAR, @intContractSeq), 4), '') + '</ITM_NUMBER>'

			SET @strCondXml += '<COND_TYPE>' + 'ZDIF' + '</COND_TYPE>'
			SET @strCondXml += '<COND_VALUE>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), @dblBasis)), '') + '</COND_VALUE>'
			SET @strCondXml += '<CURRENCY>' + ISNULL(@strCurrency, '') + '</CURRENCY>'
			SET @strCondXml += '<COND_UNIT>' + ISNULL(@strPriceUOM, '') + '</COND_UNIT>'

			IF UPPER(@strCommodityCode) = 'COFFEE'
				AND @strProductType IN (
					'Washed Arabica'
					,'Unwashed Arabica'
					)
				SET @strCondXml += '<COND_P_UNT>' + '100' + '</COND_P_UNT>'
			ELSE IF UPPER(@strCommodityCode) = 'COFFEE'
				AND @strProductType IN ('Robusta')
				SET @strCondXml += '<COND_P_UNT>' + '1000' + '</COND_P_UNT>'
			ELSE
				SET @strCondXml += '<COND_P_UNT>' + '1' + '</COND_P_UNT>'

			SET @strCondXml += '<CHANGE_ID>' + 'U' + '</CHANGE_ID>'
			SET @strCondXml += '</E1BPMEPOCOND>'

			--ZPBX Information
			IF UPPER(@strHeaderState) = 'MODIFIED'
				AND ISNULL(@dblCashPrice, 0) > 0
			BEGIN
				SET @strCondXml += '<E1BPMEPOCOND SEGMENT="1">'

				IF UPPER(@strCommodityCode) = 'COFFEE'
					SET @strCondXml += '<ITM_NUMBER>' + '0001' + '</ITM_NUMBER>'
				ELSE
					SET @strCondXml += '<ITM_NUMBER>' + ISNULL(RIGHT('0000' + CONVERT(VARCHAR, @intContractSeq), 4), '') + '</ITM_NUMBER>'

				SET @strCondXml += '<COND_TYPE>' + 'ZPBX' + '</COND_TYPE>'
				SET @strCondXml += '<COND_VALUE>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), @dblCashPrice)), '0.00') + '</COND_VALUE>'
				SET @strCondXml += '<CURRENCY>' + ISNULL(@strCurrency, '') + '</CURRENCY>'
				SET @strCondXml += '<COND_UNIT>' + ISNULL(@strPriceUOM, '') + '</COND_UNIT>'

				IF UPPER(@strCommodityCode) = 'COFFEE'
					AND @strProductType IN (
						'Washed Arabica'
						,'Unwashed Arabica'
						)
					SET @strCondXml += '<COND_P_UNT>' + '100' + '</COND_P_UNT>'
				ELSE IF UPPER(@strCommodityCode) = 'COFFEE'
					AND @strProductType IN ('Robusta')
					SET @strCondXml += '<COND_P_UNT>' + '1000' + '</COND_P_UNT>'
				ELSE
					SET @strCondXml += '<COND_P_UNT>' + '1' + '</COND_P_UNT>'

				SET @strCondXml += '<CHANGE_ID>' + 'I' + '</CHANGE_ID>'
				SET @strCondXml += '</E1BPMEPOCOND>'
			END

			--Basis InformationX
			SET @strCondXXml += '<E1BPMEPOCONDX SEGMENT="1">'

			IF UPPER(@strCommodityCode) = 'COFFEE'
				SET @strCondXXml += '<ITM_NUMBER>' + '0001' + '</ITM_NUMBER>'
			ELSE
				SET @strCondXXml += '<ITM_NUMBER>' + ISNULL(RIGHT('0000' + CONVERT(VARCHAR, @intContractSeq), 4), '') + '</ITM_NUMBER>'

			SET @strCondXXml += '<ITM_NUMBERX>' + 'X' + '</ITM_NUMBERX>'
			SET @strCondXXml += '<COND_TYPE>' + 'X' + '</COND_TYPE>'

			IF @dblBasis IS NOT NULL
				SET @strCondXXml += '<COND_VALUE>' + 'X' + '</COND_VALUE>'

			IF @strCurrency IS NOT NULL
				SET @strCondXXml += '<CURRENCY>' + 'X' + '</CURRENCY>'

			IF @strPriceUOM IS NOT NULL
				SET @strCondXXml += '<COND_UNIT>' + 'X' + '</COND_UNIT>'
			SET @strCondXXml += '<COND_P_UNT>' + 'X' + '</COND_P_UNT>'
			SET @strCondXXml += '<CHANGE_ID>' + 'X' + '</CHANGE_ID>'
			SET @strCondXXml += '</E1BPMEPOCONDX>'

			--ZPBX InformationX
			IF UPPER(@strHeaderState) = 'MODIFIED'
				AND ISNULL(@dblCashPrice, 0) > 0
			BEGIN
				SET @strCondXXml += '<E1BPMEPOCONDX SEGMENT="1">'

				IF UPPER(@strCommodityCode) = 'COFFEE'
					SET @strCondXXml += '<ITM_NUMBER>' + '0001' + '</ITM_NUMBER>'
				ELSE
					SET @strCondXXml += '<ITM_NUMBER>' + ISNULL(RIGHT('0000' + CONVERT(VARCHAR, @intContractSeq), 4), '') + '</ITM_NUMBER>'

				SET @strCondXXml += '<ITM_NUMBERX>' + 'X' + '</ITM_NUMBERX>'
				SET @strCondXXml += '<COND_TYPE>' + 'X' + '</COND_TYPE>'
				SET @strCondXXml += '<COND_VALUE>' + 'X' + '</COND_VALUE>'

				IF @strCurrency IS NOT NULL
					SET @strCondXXml += '<CURRENCY>' + 'X' + '</CURRENCY>'

				IF @strPriceUOM IS NOT NULL
					SET @strCondXXml += '<COND_UNIT>' + 'X' + '</COND_UNIT>'
				SET @strCondXXml += '<COND_P_UNT>' + 'X' + '</COND_P_UNT>'
				SET @strCondXXml += '<CHANGE_ID>' + 'X' + '</CHANGE_ID>'
				SET @strCondXXml += '</E1BPMEPOCONDX>'
			END

			IF UPPER(@strCommodityCode) = 'COFFEE'
			BEGIN
				--Origin (L16)
				IF ISNULL(@strContractItemNo, '') <> ''
				BEGIN
					SET @strTextXml += '<E1BPMEPOTEXTHEADER>'
					SET @strTextXml += '<TEXT_ID>' + 'L16' + '</TEXT_ID>'
					SET @strTextXml += '<TEXT_LINE>' + dbo.fnEscapeXML(ISNULL(@strContractItemNo, '')) + '</TEXT_LINE>'
					SET @strTextXml += '</E1BPMEPOTEXTHEADER>'
				END

				--Certificate (L15)
				SELECT @strCertificates = COALESCE(@strCertificates, '') + '<E1BPMEPOTEXTHEADER>' + '<TEXT_ID>' + 'L15' + '</TEXT_ID>' + '<TEXT_LINE>' + dbo.fnEscapeXML(ISNULL(strCertificationCode, '')) + '</TEXT_LINE>' + '</E1BPMEPOTEXTHEADER>'
				FROM tblCTContractCertification cc
				JOIN tblICCertification c ON cc.intCertificationId = c.intCertificationId
				WHERE cc.intContractDetailId = @intContractDetailId

				SET @strCertificates = LTRIM(RTRIM(ISNULL(@strCertificates, '')))

				IF @strCertificates <> ''
					SET @strTextXml += ISNULL(@strCertificates, '')
				ELSE
				BEGIN --Set 0 (For No Certificate)
					SET @strTextXml += '<E1BPMEPOTEXTHEADER>'
					SET @strTextXml += '<TEXT_ID>' + 'L15' + '</TEXT_ID>'
					SET @strTextXml += '<TEXT_LINE>' + '0' + '</TEXT_LINE>'
					SET @strTextXml += '</E1BPMEPOTEXTHEADER>'
				END

				--Country of Origin (L17)
				IF ISNULL(@strOrigin, '') <> ''
				BEGIN
					SET @strTextXml += '<E1BPMEPOTEXTHEADER>'
					SET @strTextXml += '<TEXT_ID>' + 'L17' + '</TEXT_ID>'
					SET @strTextXml += '<TEXT_LINE>' + dbo.fnEscapeXML(ISNULL(@strOrigin, '')) + '</TEXT_LINE>'
					SET @strTextXml += '</E1BPMEPOTEXTHEADER>'
				END

				--Shipper (F17)
				IF ISNULL(@strProducer, '') <> ''
				BEGIN
					SET @strTextXml += '<E1BPMEPOTEXT>'
					SET @strTextXml += '<PO_ITEM>' + '0001' + '</PO_ITEM>'
					SET @strTextXml += '<TEXT_ID>' + 'F17' + '</TEXT_ID>'
					SET @strTextXml += '<TEXT_LINE>' + dbo.fnEscapeXML(ISNULL(@strProducer, '')) + '</TEXT_LINE>'
					SET @strTextXml += '</E1BPMEPOTEXT>'
				END
			END

			IF UPPER(@strCommodityCode) = 'TEA'
			BEGIN
				SET @strTextXml += '<E1BPMEPOTEXTHEADER>'
				SET @strTextXml += '<TEXT_ID>' + 'L15' + '</TEXT_ID>'
				SET @strTextXml += '<TEXT_LINE>' + 'N' + '</TEXT_LINE>'
				SET @strTextXml += '</E1BPMEPOTEXTHEADER>'

				--Country of Origin (L17)
				IF ISNULL(@strOrigin, '') <> ''
				BEGIN
					SET @strTextXml += '<E1BPMEPOTEXTHEADER>'
					SET @strTextXml += '<TEXT_ID>' + 'L17' + '</TEXT_ID>'
					SET @strTextXml += '<TEXT_LINE>' + dbo.fnEscapeXML(ISNULL(@strOrigin, '')) + '</TEXT_LINE>'
					SET @strTextXml += '</E1BPMEPOTEXTHEADER>'
				END

				--Shipper (F17)
				IF ISNULL(@strProducer, '') <> ''
				BEGIN
					SET @strTextXml += '<E1BPMEPOTEXT>'
					SET @strTextXml += '<PO_ITEM>' + ISNULL(RIGHT('0000' + CONVERT(VARCHAR, @intContractSeq), 4), '') + '</PO_ITEM>'
					SET @strTextXml += '<TEXT_ID>' + 'F17' + '</TEXT_ID>'
					SET @strTextXml += '<TEXT_LINE>' + dbo.fnEscapeXML(ISNULL(@strProducer, '')) + '</TEXT_LINE>'
					SET @strTextXml += '</E1BPMEPOTEXT>'
				END
			END
		END

		--Header End Xml
		IF ISNULL(@strXmlHeaderEnd, '') = ''
		BEGIN
			IF UPPER(@strHeaderState) = 'ADDED'
			BEGIN
				SET @strXmlHeaderEnd += '</E1PORDCR1>'
				SET @strXmlHeaderEnd += '</IDOC>'
				SET @strXmlHeaderEnd += '</PORDCR103>'
			END

			IF UPPER(@strHeaderState) = 'MODIFIED'
			BEGIN
				SET @strXmlHeaderEnd += '</E1PORDCH>'
				SET @strXmlHeaderEnd += '</IDOC>'
				SET @strXmlHeaderEnd += '</PORDCH03>'
			END
		END

		IF UPPER(@strCommodityCode) = 'COFFEE'
			SET @intMinSeq = NULL
		ELSE
			SELECT @intMinSeq = Min(intContractFeedId)
			FROM tblCTContractFeed
			WHERE intContractFeedId > @intMinSeq
				AND intContractHeaderId = @intContractHeaderId
				AND ISNULL(strSubLocation, '') = ISNULL(@strSubLocation, '')
				AND ISNULL(strFeedStatus, '') = ''
				AND UPPER(strCommodityCode) = 'TEA'
	END

	--Final Xml
	SET @strXml = @strXmlHeaderStart + @strItemXml + @strItemXXml + @strScheduleXml + @strScheduleXXml + @strCondXml + @strCondXXml + @strTextXml + @strXmlHeaderEnd

	IF @ysnUpdateFeedStatusOnRead = 1
	BEGIN
		DECLARE @strSql NVARCHAR(max) = 'Update tblCTContractFeed Set strFeedStatus=''Awt Ack'' Where intContractFeedId IN (' + @strContractFeedIds + ')'

		EXEC sp_executesql @strSql
	END

	SET @strSeq = LTRIM(RTRIM(LEFT(@strSeq, LEN(@strSeq) - 1)))

	INSERT INTO @tblOutput (
		strContractFeedIds
		,strRowState
		,strXml
		,strContractNo
		,strPONo
		)
	VALUES (
		@strContractFeedIds
		,CASE 
			WHEN UPPER(@strHeaderState) = 'ADDED'
				THEN 'CREATE'
			ELSE 'UPDATE'
			END
		,@strXml
		,ISNULL(@strContractNumber, '') + ' / ' + ISNULL(@strSeq, '')
		,ISNULL(@strERPPONumber, '')
		)

	NEXT_PO:

	SELECT @intMinRowNo = Min(intRowNo)
	FROM @tblHeader
	WHERE intRowNo > @intMinRowNo
END --End Header Loop

SELECT *
FROM @tblOutput
ORDER BY intRowNo
