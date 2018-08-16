CREATE PROCEDURE [dbo].[uspIPGenerateSAPPOIDOC_HE] @ysnUpdateFeedStatusOnRead BIT = 0
	,@strRowState NVARCHAR(50)
AS
DECLARE @intMinSeq INT
	,@intContractFeedId INT
	,@intContractHeaderId INT
	,@intContractDetailId INT
	,@strContractBasis NVARCHAR(100)
	,@strContractBasisDesc NVARCHAR(500)
	,@strSubLocation NVARCHAR(50)
	,@strEntityNo NVARCHAR(100)
	,@strTerm NVARCHAR(100)
	,@strPurchasingGroup NVARCHAR(150)
	,@strContractNumber NVARCHAR(100)
	,@strERPPONumber NVARCHAR(100)
	,@intContractSeq INT
	,@strItemNo NVARCHAR(100)
	,@strStorageLocation NVARCHAR(50)
	,@dblQuantity NUMERIC(18, 6)
	,@strQuantityUOM NVARCHAR(50)
	,@dblCashPrice NUMERIC(18, 6)
	,@dblUnitCashPrice NUMERIC(18, 6)
	,@dtmPlannedAvailabilityDate DATETIME
	,@dtmContractDate DATETIME
	,@dtmStartDate DATETIME
	,@dtmEndDate DATETIME
	,@dblBasis NUMERIC(18, 6)
	,@strCurrency NVARCHAR(50)
	,@strPriceUOM NVARCHAR(50)
	,@strFeedStatus NVARCHAR(50)
	,@strXml NVARCHAR(MAX)
	,@strDocType NVARCHAR(50)
	,@strPOCreateIDOCHeader NVARCHAR(MAX)
	,@strPOUpdateIDOCHeader NVARCHAR(MAX)
	,@strCompCode NVARCHAR(100)
	,@intMinRowNo INT
	,@strXmlHeaderStart NVARCHAR(MAX)
	,@strXmlHeaderEnd NVARCHAR(MAX)
	,@strContractFeedIds NVARCHAR(MAX)
	,@strERPPONumber1 NVARCHAR(100)
	,@strOrigin NVARCHAR(100)
	,@strContractItemNo NVARCHAR(500)
	,@strItemXml NVARCHAR(MAX)
	,@strItemXXml NVARCHAR(MAX)
	,@strTextXml NVARCHAR(MAX)
	,@strSeq NVARCHAR(MAX)
	,@str10Zeros NVARCHAR(50) = '0000000000'
	,@strLoadingPoint NVARCHAR(200)
	,@ysnMaxPrice BIT
	,@strPrintableRemarks NVARCHAR(MAX)
	,@strSalesPerson NVARCHAR(100)
	,@intLocationId INT
	,@strLocationName NVARCHAR(50)
	,@strSAPLocation NVARCHAR(50)
DECLARE @tblIPContractItem TABLE (strContractItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS)
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
	,ysnMaxPrice BIT
	,strPrintableRemarks NVARCHAR(MAX)
	,strSalesPerson NVARCHAR(100)
	)

--SELECT @strPOCreateIDOCHeader = dbo.fnIPGetSAPIDOCHeader('PO CREATE')
--SELECT @strPOUpdateIDOCHeader = dbo.fnIPGetSAPIDOCHeader('PO UPDATE')
--SELECT @strCompCode = dbo.[fnIPGetSAPIDOCTagValue]('GLOBAL', 'COMP_CODE')
IF EXISTS (
		SELECT *
		FROM tblCTContractFeed CF
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
			AND CH.ysnMaxPrice = 1
		WHERE ISNULL(strFeedStatus, '') = ''
			AND UPPER(strRowState) IN (
				'MODIFIED'
				,'DELETE'
				)
		)
BEGIN
	DECLARE @tblCTContractFeed TABLE (
		intContractFeedId INT
		,intContractHeaderId INT
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @tblCTFinalContractFeed TABLE (
		intContractHeaderId INT
		,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)

	INSERT INTO @tblCTContractFeed (
		intContractFeedId
		,intContractHeaderId
		,strItemNo
		)
	SELECT CF.intContractFeedId
		,CH.intContractHeaderId
		,CF.strItemNo
	FROM tblCTContractFeed CF
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
		AND CH.ysnMaxPrice = 1
	WHERE ISNULL(strFeedStatus, '') = ''
		AND UPPER(strRowState) IN (
			'MODIFIED'
			,'DELETE'
			)

	INSERT INTO @tblCTFinalContractFeed (
		intContractHeaderId
		,strItemNo
		)
	SELECT DISTINCT intContractHeaderId
		,strItemNo
	FROM @tblCTContractFeed

	DELETE CF
	FROM tblCTContractFeed CF
	JOIN @tblCTContractFeed CF1 ON CF1.intContractFeedId = CF.intContractFeedId

	INSERT INTO tblCTContractFeed (
		intContractHeaderId
		,intContractDetailId
		,strCommodityCode
		,strCommodityDesc
		,strContractBasis
		,strContractBasisDesc
		,strSubLocation
		,strCreatedBy
		,strCreatedByNo
		,strEntityNo
		,strTerm
		,strPurchasingGroup
		,strContractNumber
		,strERPPONumber
		,intContractSeq
		,strItemNo
		,strStorageLocation
		,dblQuantity
		,dblCashPrice
		,strQuantityUOM
		,dtmPlannedAvailabilityDate
		,dblBasis
		,strCurrency
		,dblUnitCashPrice
		,strPriceUOM
		,strRowState
		,dtmContractDate
		,dtmStartDate
		,dtmEndDate
		,dtmFeedCreated
		,strSubmittedBy
		,strSubmittedByNo
		,strOrigin
		,dblNetWeight
		,strNetWeightUOM
		,strVendorAccountNum
		,strTermCode
		,strContractItemNo
		,strContractItemName
		,strERPItemNumber
		,strERPBatchNumber
		,strLoadingPoint
		,strPackingDescription
		)
	SELECT CF.intContractHeaderId
		,intContractDetailId
		,strCommodityCode
		,strCommodityDesc
		,strContractBasis
		,strContractBasisDesc
		,strSubLocation
		,strCreatedBy
		,strCreatedByNo
		,strEntityNo
		,strTerm
		,strPurchasingGroup
		,strContractNumber
		,strERPPONumber
		,intContractSeq
		,CF.strItemNo
		,strStorageLocation
		,dblQuantity
		,dblCashPrice
		,strQuantityUOM
		,dtmPlannedAvailabilityDate
		,dblBasis
		,strCurrency
		,dblUnitCashPrice
		,strPriceUOM
		,CASE 
			WHEN intContractStatusId = 3
				THEN 'DELETE'
			ELSE 'MODIFIED'
			END
		,dtmContractDate
		,dtmStartDate
		,dtmEndDate
		,GETDATE()
		,strSubmittedBy
		,strSubmittedByNo
		,strOrigin
		,dblNetWeight
		,strNetWeightUOM
		,strVendorAccountNum
		,strTermCode
		,strContractItemNo
		,strContractItemName
		,strERPItemNumber
		,strERPBatchNumber
		,strLoadingPoint
		,strPackingDescription
	FROM vyuCTContractFeed CF
	JOIN @tblCTFinalContractFeed CF1 ON CF1.intContractHeaderId = CF.intContractHeaderId
		AND CF1.strItemNo = CF.strItemNo
END

UPDATE CF
SET strFeedStatus = 'IGNORE'
FROM tblCTContractFeed CF
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
WHERE CH.ysnSubstituteItem = 0

UPDATE CF
SET strERPPONumber = CD.strERPPONumber
	,strRowState = 'MODIFIED'
FROM tblCTContractFeed CF
JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CF.intContractHeaderId
LEFT JOIN tblSMCompanyLocationSubLocation SL ON SL.intCompanyLocationSubLocationId = CD.intSubLocationId
WHERE CF.intContractHeaderId = @intContractHeaderId
	AND ISNULL(CF.strSubLocation, '') = ISNULL(SL.strSubLocationName, '')
	AND ISNULL(strFeedStatus, '') = ''
	AND IsNULL(CF.strERPPONumber, '') = ''
	AND CD.strERPPONumber <> ''
	AND UPPER(strRowState) = 'ADDED'

--Get the Headers
IF UPPER(@strRowState) = 'ADDED'
BEGIN
	INSERT INTO @tblHeader (
		intContractHeaderId
		,strCommodityCode
		,intContractFeedId
		,strSubLocation
		,ysnMaxPrice
		,strPrintableRemarks
		,strSalesPerson
		)
	SELECT DISTINCT CF.intContractHeaderId
		,strCommodityCode
		,MAX(intContractFeedId) AS intContractFeedId
		,strSubLocation
		,CH.ysnMaxPrice
		,CH.strPrintableRemarks
		,E.strName
	FROM tblCTContractFeed CF
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
		AND CH.ysnMaxPrice = 1
	JOIN tblEMEntity E ON E.intEntityId = CH.intSalespersonId
	WHERE ISNULL(strFeedStatus, '') = ''
		AND Upper(strRowState) = 'ADDED'
	GROUP BY CF.intContractHeaderId
		,strCommodityCode
		,strSubLocation
		,CH.ysnMaxPrice
		,CH.strPrintableRemarks
		,E.strName
	
	UNION
	
	SELECT DISTINCT CF.intContractHeaderId
		,strCommodityCode
		,intContractFeedId
		,strSubLocation
		,CH.ysnMaxPrice
		,CH.strPrintableRemarks
		,E.strName
	FROM tblCTContractFeed CF
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
		AND CH.ysnMaxPrice = 0
	JOIN tblEMEntity E ON E.intEntityId = CH.intSalespersonId
	WHERE ISNULL(strFeedStatus, '') = ''
		AND Upper(strRowState) = 'ADDED'
	ORDER BY CF.intContractHeaderId
END
ELSE
BEGIN
	INSERT INTO @tblHeader (
		intContractHeaderId
		,strCommodityCode
		,intContractFeedId
		,strSubLocation
		,ysnMaxPrice
		,strPrintableRemarks
		,strSalesPerson
		)
	SELECT DISTINCT CF.intContractHeaderId
		,strCommodityCode
		,MAX(intContractFeedId) AS intContractFeedId
		,strSubLocation
		,CH.ysnMaxPrice
		,CH.strPrintableRemarks
		,E.strName
	FROM tblCTContractFeed CF
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
		AND CH.ysnMaxPrice = 1
	JOIN tblEMEntity E ON E.intEntityId = CH.intSalespersonId
	WHERE ISNULL(strFeedStatus, '') = ''
		AND UPPER(strRowState) IN (
			'MODIFIED'
			,'DELETE'
			)
	GROUP BY CF.intContractHeaderId
		,strCommodityCode
		,strSubLocation
		,CH.ysnMaxPrice
		,CH.strPrintableRemarks
		,E.strName
	
	UNION
	
	SELECT DISTINCT CF.intContractHeaderId
		,strCommodityCode
		,intContractFeedId
		,strSubLocation
		,CH.ysnMaxPrice
		,CH.strPrintableRemarks
		,E.strName
	FROM tblCTContractFeed CF
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
		AND CH.ysnMaxPrice = 0
	JOIN tblEMEntity E ON E.intEntityId = CH.intSalespersonId
	WHERE ISNULL(strFeedStatus, '') = ''
		AND UPPER(strRowState) IN (
			'MODIFIED'
			,'DELETE'
			)
	ORDER BY CF.intContractHeaderId
END

SELECT @intMinRowNo = Min(intRowNo)
FROM @tblHeader

WHILE (@intMinRowNo IS NOT NULL) --Header Loop
BEGIN
	SET @strXml = ''
	SET @strXmlHeaderStart = ''
	SET @strXmlHeaderEnd = ''
	SET @strContractFeedIds = NULL

	SELECT @strPrintableRemarks = ''

	SELECT @strSalesPerson = ''

	SELECT @ysnMaxPrice = NULL

	SELECT @intContractHeaderId = intContractHeaderId
		,@strSubLocation = strSubLocation
		,@intContractFeedId = intContractFeedId
		,@ysnMaxPrice = ysnMaxPrice
		,@strPrintableRemarks = strPrintableRemarks
		,@strSalesPerson = strSalesPerson
	FROM @tblHeader
	WHERE intRowNo = @intMinRowNo

	IF @ysnMaxPrice = 1
	BEGIN
		SELECT @strContractItemNo = NULL

		SELECT TOP 1 @strContractItemNo = strItemNo
		FROM tblCTContractFeed
		WHERE intContractHeaderId = @intContractHeaderId
			AND ISNULL(strSubLocation, '') = ISNULL(@strSubLocation, '')
			AND ISNULL(strFeedStatus, '') = ''
		ORDER BY intContractFeedId

		SELECT @strContractFeedIds = COALESCE(CONVERT(VARCHAR, @strContractFeedIds) + ',', '') + CONVERT(VARCHAR, intContractFeedId)
		FROM tblCTContractFeed
		WHERE intContractHeaderId = @intContractHeaderId
			AND ISNULL(strSubLocation, '') = ISNULL(@strSubLocation, '')
			AND ISNULL(strFeedStatus, '') = ''
			AND strItemNo = @strContractItemNo

		INSERT INTO @tblIPContractItem
		SELECT @strContractItemNo
	END
	ELSE
	BEGIN
		SELECT @intMinSeq = @intContractFeedId

		SELECT @strContractFeedIds = @intContractFeedId

		--Send Create Feed only Once
		IF UPPER(@strRowState) = 'ADDED'
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
	END

	--Donot generate Modified Idoc if PO No is not there
	IF UPPER(@strRowState) IN (
			'MODIFIED'
			,'DELETE'
			)
		AND (
			SELECT ISNULL(strERPPONumber, '')
			FROM tblCTContractFeed
			WHERE intContractFeedId = @intMinSeq
			) = ''
		GOTO NEXT_PO

	SET @strItemXml = ''
	SET @strItemXXml = ''
	SET @strTextXml = ''
	SET @strSeq = ''

	WHILE (
			@ysnMaxPrice = 0
			AND @intMinSeq IS NOT NULL
			)
		OR (
			@ysnMaxPrice = 1
			AND @strContractItemNo IS NOT NULL
			) --Sequence Loop
	BEGIN
		IF @ysnMaxPrice = 0
		BEGIN
			SELECT @intContractFeedId = intContractFeedId
				,@intContractHeaderId = intContractHeaderId
				,@intContractDetailId = intContractDetailId
				,@strContractBasis = strContractBasis
				,@strSubLocation = strSubLocation
				,@strEntityNo = strVendorAccountNum
				,@strPurchasingGroup = strPurchasingGroup
				,@strContractNumber = strContractNumber
				,@strERPPONumber = strERPPONumber
				,@intContractSeq = intContractSeq
				,@strItemNo = strItemNo
				,@strStorageLocation = strStorageLocation
				,@dblQuantity = dblNetWeight
				,@strQuantityUOM = (
					SELECT TOP 1 ISNULL(strSymbol, strUnitMeasure)
					FROM tblICUnitMeasure
					WHERE strUnitMeasure = strNetWeightUOM
					)
				,@dblCashPrice = dblCashPrice * 100
				,@dblUnitCashPrice = dblUnitCashPrice
				,@dtmContractDate = dtmContractDate
				,@dtmStartDate = dtmStartDate
				,@dtmEndDate = dtmEndDate
				,@strCurrency = strCurrency
				,@strPriceUOM = (
					SELECT TOP 1 ISNULL(strSymbol, strUnitMeasure)
					FROM tblICUnitMeasure
					WHERE strUnitMeasure = strPriceUOM
					)
			FROM tblCTContractFeed
			WHERE intContractFeedId = @intMinSeq
		END
		ELSE
		BEGIN
			IF EXISTS (
					SELECT *
					FROM tblCTContractFeed
					WHERE intContractHeaderId = @intContractHeaderId
						AND strItemNo = @strContractItemNo
						AND IsNULL(strFeedStatus, '') = ''
						AND UPPer(strRowState) = 'MODIFIED'
					)
			BEGIN
				SELECT @intContractFeedId = MAX(intContractFeedId)
					,@intContractDetailId = MAX(intContractDetailId)
					,@strContractBasis = strContractBasis
					,@strSubLocation = strSubLocation
					,@strEntityNo = strVendorAccountNum
					,@strPurchasingGroup = strPurchasingGroup
					,@strContractNumber = strContractNumber
					,@strERPPONumber = strERPPONumber
					,@intContractSeq = Min(intContractSeq)
					,@strItemNo = strItemNo
					,@strStorageLocation = strStorageLocation
					,@dblQuantity = SUM(dblNetWeight)
					,@strQuantityUOM = (
						SELECT TOP 1 ISNULL(strSymbol, strUnitMeasure)
						FROM tblICUnitMeasure
						WHERE strUnitMeasure = strNetWeightUOM
						)
					,@dblCashPrice = SUM(dblCashPrice * 100 * dblNetWeight) / SUM(dblNetWeight)
					,@dblUnitCashPrice = SUM(dblUnitCashPrice * dblNetWeight) / SUM(dblNetWeight)
					,@dtmContractDate = dtmContractDate
					,@dtmStartDate = Min(dtmStartDate)
					,@dtmEndDate = MAX(dtmEndDate)
					,@strCurrency = strCurrency
					,@strPriceUOM = (
						SELECT TOP 1 ISNULL(strSymbol, strUnitMeasure)
						FROM tblICUnitMeasure
						WHERE strUnitMeasure = strPriceUOM
						)
				FROM tblCTContractFeed
				WHERE intContractHeaderId = @intContractHeaderId
					AND strItemNo = @strContractItemNo
					AND IsNULL(strFeedStatus, '') = ''
					AND UPPER(strRowState) <> 'DELETE'
				GROUP BY strContractBasis
					,strSubLocation
					,strVendorAccountNum
					,strPurchasingGroup
					,strContractNumber
					,strERPPONumber
					,strItemNo
					,strStorageLocation
					,strNetWeightUOM
					,dtmContractDate
					,strCurrency
					,strPriceUOM
			END
			ELSE
			BEGIN
				SELECT @intContractFeedId = MAX(intContractFeedId)
					,@intContractDetailId = MAX(intContractDetailId)
					,@strContractBasis = strContractBasis
					,@strSubLocation = strSubLocation
					,@strEntityNo = strVendorAccountNum
					,@strPurchasingGroup = strPurchasingGroup
					,@strContractNumber = strContractNumber
					,@strERPPONumber = strERPPONumber
					,@intContractSeq = Min(intContractSeq)
					,@strItemNo = strItemNo
					,@strStorageLocation = strStorageLocation
					,@dblQuantity = SUM(dblNetWeight)
					,@strQuantityUOM = (
						SELECT TOP 1 ISNULL(strSymbol, strUnitMeasure)
						FROM tblICUnitMeasure
						WHERE strUnitMeasure = strNetWeightUOM
						)
					,@dblCashPrice = SUM(dblCashPrice * 100 * dblNetWeight) / SUM(dblNetWeight)
					,@dblUnitCashPrice = SUM(dblUnitCashPrice * dblNetWeight) / SUM(dblNetWeight)
					,@dtmContractDate = dtmContractDate
					,@dtmStartDate = Min(dtmStartDate)
					,@dtmEndDate = MAX(dtmEndDate)
					,@strCurrency = strCurrency
					,@strPriceUOM = (
						SELECT TOP 1 ISNULL(strSymbol, strUnitMeasure)
						FROM tblICUnitMeasure
						WHERE strUnitMeasure = strPriceUOM
						)
				FROM tblCTContractFeed
				WHERE intContractHeaderId = @intContractHeaderId
					AND strItemNo = @strContractItemNo
					AND IsNULL(strFeedStatus, '') = ''
				GROUP BY strContractBasis
					,strSubLocation
					,strVendorAccountNum
					,strPurchasingGroup
					,strContractNumber
					,strERPPONumber
					,strItemNo
					,strStorageLocation
					,strNetWeightUOM
					,dtmContractDate
					,strCurrency
					,strPriceUOM
			END
		END

		SELECT @intLocationId = intCompanyLocationId
		FROM tblCTContractDetail
		WHERE intContractDetailId = @intContractDetailId

		SELECT @strLocationName = strLocationName
		FROM tblSMCompanyLocation
		WHERE intCompanyLocationId = @intLocationId

		SELECT @strSAPLocation = strSAPLocation
		FROM tblIPSAPLocation
		WHERE stri21Location = @strLocationName

		IF IsNULL(@strSAPLocation, '') = ''
		BEGIN
			IF @ysnMaxPrice = 0
			BEGIN
				UPDATE tblCTContractFeed
				SET strMessage = 'SAP Location is not configured in i21.'
				WHERE intContractFeedId = @intContractFeedId
					AND ISNULL(strFeedStatus, '') = ''
			END
			ELSE
			BEGIN
				UPDATE tblCTContractFeed
				SET strMessage = 'SAP Location is not configured in i21.'
				WHERE intContractHeaderId = @intContractHeaderId
					AND ISNULL(strFeedStatus, '') = ''
					AND strItemNo = @strContractItemNo
			END

			GOTO NEXT_PO
		END

		--Send Create Feed only Once
		IF UPPER(@strRowState) = 'ADDED'
			AND (
				SELECT TOP 1 UPPER(strRowState)
				FROM tblCTContractFeed
				WHERE intContractDetailId = @intContractDetailId
					AND intContractFeedId < @intContractFeedId
				ORDER BY intContractFeedId
				) = 'ADDED'
			AND @ysnMaxPrice = 0
			GOTO NEXT_PO

		SET @strSeq = ISNULL(@strSeq, '') + CONVERT(VARCHAR, @intContractSeq) + ','

		--Convert price USC to USD
		IF UPPER(@strCurrency) = 'USC'
		BEGIN
			SET @strCurrency = 'USD'
			SET @dblBasis = ISNULL(@dblBasis, 0) / 100
			SET @dblCashPrice = ISNULL(@dblCashPrice, 0) / 100
		END

		--Header Start Xml
		IF ISNULL(@strXmlHeaderStart, '') = ''
		BEGIN
			IF UPPER(@strRowState) = 'ADDED'
			BEGIN
				SET @strXmlHeaderStart = '<PURCONTRACT_CREATE01>'
				SET @strXmlHeaderStart += '<IDOC BEGIN="1">'
				--IDOC Header
				SET @strXmlHeaderStart += '<EDI_DC40 SEGMENT="1">'
				--SET @strXmlHeaderStart += @strPOCreateIDOCHeader
				SET @strXmlHeaderStart += '</EDI_DC40>'
				SET @strXmlHeaderStart += '<E1PURCONTRACT_CREATE SEGMENT="1">'
				--Header
				SET @strXmlHeaderStart += '<E1BPMEOUTHEADER SEGMENT="1">'
				SET @strXmlHeaderStart += '<COMP_CODE>' + ISNULL(@strPurchasingGroup, '') + '</COMP_CODE>'
				SET @strXmlHeaderStart += '<DOC_TYPE>' + ISNULL('ZMK', '') + '</DOC_TYPE>'
				SET @strXmlHeaderStart += '<CREAT_DATE>' + ISNULL(CONVERT(VARCHAR(10), @dtmContractDate, 112), '') + '</CREAT_DATE>'
				SET @strXmlHeaderStart += '<VENDOR>' + ISNULL(@strEntityNo, '') + '</VENDOR>'
				SET @strXmlHeaderStart += '<PURCH_ORG>' + ISNULL(@strSAPLocation, '') + '</PURCH_ORG>'
				SET @strXmlHeaderStart += '<PUR_GROUP>' + ISNULL(@strSalesPerson, '') + '</PUR_GROUP>'
				SET @strXmlHeaderStart += '<VPER_START>' + ISNULL(CONVERT(VARCHAR(10), @dtmStartDate, 112), '') + '</VPER_START>'
				SET @strXmlHeaderStart += '<VPER_END>' + ISNULL(CONVERT(VARCHAR(10), @dtmEndDate, 112), '') + '</VPER_END>'
				SET @strXmlHeaderStart += '<REF_1>' + ISNULL(@strContractNumber, '') + '</REF_1>'
				SET @strXmlHeaderStart += '<INCOTERMS1>' + dbo.fnEscapeXML(ISNULL(@strContractBasis, '')) + '</INCOTERMS1>'
				SET @strXmlHeaderStart += '<INCOTERMS2>' + dbo.fnEscapeXML(ISNULL('', '')) + '</INCOTERMS2>'
				SET @strXmlHeaderStart += '</E1BPMEOUTHEADER>'
			END
		END

		--Item
		IF UPPER(@strRowState) = 'ADDED'
		BEGIN
			SET @strItemXml += '<E1BPMEOUTITEM SEGMENT="1">'
			SET @strItemXml += '<MATERIAL>' + dbo.fnEscapeXML(ISNULL(@strItemNo, '')) + '</MATERIAL>'
			SET @strItemXml += '<PLANT>' + ISNULL(@strSubLocation, '') + '</PLANT>'
			SET @strItemXml += '<TRACKINGNO>' + ISNULL(CONVERT(VARCHAR, @intContractSeq), '') + '</TRACKINGNO>'
			SET @strItemXml += '<TARGET_QTY>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), @dblQuantity)), '') + '</TARGET_QTY>'
			SET @strItemXml += '<PO_UNIT>' + ISNULL(@strQuantityUOM, '') + '</PO_UNIT>'
			SET @strItemXml += '<ORDERPR_UN>' + ISNULL(@strPriceUOM, '') + '</ORDERPR_UN>'
			SET @strItemXml += '<NET_PRICE>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), @dblCashPrice)), '0.00') + '</NET_PRICE>'
			SET @strItemXml += '<PRICE_UNIT>' + '1' + '</PRICE_UNIT>'
			SET @strItemXml += '<TAX_CODE>' + 'S0' + '</TAX_CODE>'
			SET @strItemXml += '</E1BPMEOUTITEM>'
		END

		IF ISNULL(@strXmlHeaderStart, '') = ''
		BEGIN
			IF UPPER(@strRowState) <> 'ADDED'
			BEGIN
				SET @strXmlHeaderStart = '<PURCONTRACT_CHANGE01>'
				SET @strXmlHeaderStart += '<IDOC BEGIN="1">'
				--IDOC Header
				SET @strXmlHeaderStart += '<EDI_DC40 SEGMENT="1">'
				--SET @strXmlHeaderStart += @strPOUpdateIDOCHeader
				SET @strXmlHeaderStart += '</EDI_DC40>'
				SET @strXmlHeaderStart += '<E1PURCONTRACT_CHANGE  SEGMENT="1">'
				SET @strXmlHeaderStart += '<E1BPMEOUTHEADER SEGMENT="1">'
				SET @strXmlHeaderStart += '<VPER_START>' + ISNULL(CONVERT(VARCHAR(10), @dtmStartDate, 112), '') + '</VPER_START>'
				SET @strXmlHeaderStart += '<VPER_END>' + ISNULL(CONVERT(VARCHAR(10), @dtmEndDate, 112), '') + '</VPER_END>'
				SET @strXmlHeaderStart += '<REF_1>' + ISNULL(@strContractNumber, '') + '</REF_1>'
				SET @strXmlHeaderStart += '<INCOTERMS1>' + dbo.fnEscapeXML(ISNULL(@strContractBasis, '')) + '</INCOTERMS1>'
				SET @strXmlHeaderStart += '<INCOTERMS2>' + dbo.fnEscapeXML(ISNULL('', '')) + '</INCOTERMS2>'
				SET @strXmlHeaderStart += '</E1BPMEOUTHEADER>'
			END
		END

		IF UPPER(@strRowState) <> 'ADDED'
		BEGIN
			SET @strItemXml += '<E1BPMEOUTITEM SEGMENT="1">'

			IF NOT EXISTS (
					SELECT *
					FROM tblCTContractFeed
					WHERE intContractHeaderId = @intContractHeaderId
						AND strItemNo = @strContractItemNo
						AND IsNULL(strFeedStatus, '') = ''
						AND UPPER(strRowState) = 'MODIFIED'
					)
				AND @ysnMaxPrice = 1
			BEGIN

					SET @strItemXml += '<DELETE_IND>' + 'L' + '</DELETE_IND>'

			END

			IF NOT EXISTS (
					SELECT *
					FROM tblCTContractFeed
					WHERE intContractFeedId = @intContractFeedId
						AND IsNULL(strFeedStatus, '') = ''
						AND UPPER(strRowState) = 'MODIFIED'
					)
				AND @ysnMaxPrice = 0
			BEGIN
				IF UPPER(@strRowState) = 'DELETE'
				BEGIN
					SET @strItemXml += '<DELETE_IND>' + 'L' + '</DELETE_IND>'
				END
			END

			SET @strItemXml += '<TRACKINGNO>' + ISNULL(CONVERT(VARCHAR, @intContractSeq), '') + '</TRACKINGNO>'
			SET @strItemXml += '<TARGET_QTY>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), @dblQuantity)), '') + '</TARGET_QTY>'
			SET @strItemXml += '<NET_PRICE>' + ISNULL(LTRIM(CONVERT(NUMERIC(38, 2), @dblCashPrice)), '0.00') + '</NET_PRICE>'
			SET @strItemXml += '<TAX_CODE>' + 'S0' + '</TAX_CODE>'
			SET @strItemXml += '</E1BPMEOUTITEM>'
		END

		--Header End Xml
		IF ISNULL(@strXmlHeaderEnd, '') = ''
		BEGIN
			SET @strTextXml += '<E1BPMEOUTTEXT>'
			SET @strTextXml += '<TEXT_LINE>' + ISNULL(@strPrintableRemarks, '') + '</TEXT_LINE>'
			SET @strTextXml += '</E1BPMEOUTTEXT>'

			IF UPPER(@strRowState) = 'ADDED'
			BEGIN
				SET @strXmlHeaderEnd += '</E1PURCONTRACT_CREATE>'
				SET @strXmlHeaderEnd += '</IDOC>'
				SET @strXmlHeaderEnd += '</PURCONTRACT_CREATE01>'
			END

			IF UPPER(@strRowState) <> 'ADDED'
			BEGIN
				SET @strXmlHeaderEnd += '</E1PURCONTRACT_CHANGE >'
				SET @strXmlHeaderEnd += '</IDOC>'
				SET @strXmlHeaderEnd += '</PURCONTRACT_CHANGE01>'
			END
		END

		IF @ysnMaxPrice = 1
		BEGIN
			SELECT @strContractItemNo = NULL

			SELECT TOP 1 @strContractItemNo = strItemNo
			FROM tblCTContractFeed CF
			WHERE intContractHeaderId = @intContractHeaderId
				AND ISNULL(strSubLocation, '') = ISNULL(@strSubLocation, '')
				AND ISNULL(strFeedStatus, '') = ''
				AND NOT EXISTS (
					SELECT *
					FROM @tblIPContractItem CI
					WHERE CI.strContractItemNo = CF.strItemNo
					)
			ORDER BY 1

			INSERT INTO @tblIPContractItem
			SELECT @strContractItemNo
		END
		ELSE
		BEGIN
			SELECT @intMinSeq = NULL
		END
	END

	--Final Xml
	SET @strXml = @strXmlHeaderStart + @strItemXml + @strTextXml + @strXmlHeaderEnd

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
			WHEN UPPER(@strRowState) = 'ADDED'
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

SELECT IsNULL(strContractFeedIds, '0') AS id
	,IsNULL(strXml, '') AS strXml
	,IsNULL(strContractNo, '') AS strInfo1
	,IsNULL(strPONo, '') AS strInfo2
	,'' AS strOnFailureCallbackSql
FROM @tblOutput
ORDER BY intRowNo
