CREATE PROCEDURE [dbo].[uspCTReportBasisComponent]
	@xmlParam NVARCHAR(MAX) = NULL

AS

BEGIN
	DECLARE @intContractDetailId	NVARCHAR(MAX)
		, @xmlDocumentId			INT
		, @Vendor					NVARCHAR(900)
		, @dtmFromContractDate		DATETIME
		, @dtmToContractDate		DATETIME
		, @dtmFromStartDate			DATETIME
		, @dtmToStartDate			DATETIME
		, @dtmFromEndDate			DATETIME
		, @dtmToEndDate				DATETIME
		, @strProductType			NVARCHAR(100)
		, @strReportLogId			NVARCHAR(50)
		, @strPosition				NVARCHAR(200)
		, @EqualStartDate			DATETIME
		, @EqualEndDate				DATETIME
		, @EqualContractDate		DATETIME
		, @intQtyDec				INT
		, @intPriceDec				INT

	SELECT @intQtyDec = intQuantityDecimals, @intPriceDec = intPricingDecimals FROM tblCTCompanyPreference

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL
	
	DECLARE @temp_xml_table TABLE ([fieldname] NVARCHAR(50)
		, [condition] NVARCHAR(20)
		, [from] NVARCHAR(MAX)
		, [to] NVARCHAR(MAX)
		, [join] NVARCHAR(10)
		, [begingroup] NVARCHAR(50)
		, [endgroup] NVARCHAR(50)
		, [datatype] NVARCHAR(50))

	DECLARE @dummy_xml_table TABLE ( [fieldname]		NVARCHAR(50)
		, [condition] NVARCHAR(20)
		, [from] NVARCHAR(MAX)
		, [to] NVARCHAR(MAX)
		, [join] NVARCHAR(10)
		, [begingroup] NVARCHAR(50)
		, [endgroup] NVARCHAR(50)
		, [datatype] NVARCHAR(50))
		
	IF ISNULL(@xmlParam,'') = '' OR @xmlParam = '<?xml version="1.0" encoding="utf-16"?><xmlparam>''''</xmlparam>'
	BEGIN
		-- Return No Records
		SELECT * FROM vyuCTGetBasisComponentJDE CD
		WHERE 1 = 2
		RETURN
	END

	EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam  
  
	INSERT INTO @temp_xml_table  
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)
	WITH ([fieldname] NVARCHAR(50)
		, [condition] NVARCHAR(20)
		, [from] NVARCHAR(MAX)
		, [to] NVARCHAR(MAX)
		, [join] NVARCHAR(10)
		, [begingroup] NVARCHAR(50)
		, [endgroup] NVARCHAR(50)
		, [datatype] NVARCHAR(50))

	INSERT INTO @dummy_xml_table  
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/dummies/filter', 2)
	WITH ([fieldname] NVARCHAR(50)
		, [condition] NVARCHAR(20)
		, [from] NVARCHAR(MAX)
		, [to] NVARCHAR(MAX)
		, [join] NVARCHAR(10)
		, [begingroup] NVARCHAR(50)
		, [endgroup] NVARCHAR(50)
		, [datatype] NVARCHAR(50))
	
	SELECT @intContractDetailId = [from]
	FROM @temp_xml_table   
	WHERE [fieldname] = 'intContractDetailId'

	SELECT @dtmFromContractDate = [from]
		, @dtmToContractDate = [to]
	FROM @temp_xml_table   
	WHERE [fieldname] = 'ContractDate'
		AND	UPPER(condition) = 'BETWEEN'

	SELECT @strProductType = [from]
	FROM @temp_xml_table   
	WHERE [fieldname] = 'ProductType'
		AND	condition = 'Equal To'

	SELECT @Vendor = [from]
	FROM @temp_xml_table   
	WHERE [fieldname] = 'Vendor'
		AND	condition = 'Equal To'

	SELECT @strPosition = [from]
	FROM @temp_xml_table   
	WHERE [fieldname] = 'Position'
		AND condition = 'Equal To'

	SELECT @strReportLogId = [from]
	FROM @dummy_xml_table
	WHERE [fieldname] = 'strReportLogId'

	SELECT @dtmFromStartDate = [from]
		, @dtmToStartDate = [to]
	FROM @temp_xml_table
	WHERE [fieldname] = 'StartDate'
		AND	UPPER(condition) = 'BETWEEN'

	SELECT @dtmFromEndDate = [from]
		, @dtmToEndDate = [to]
	FROM @temp_xml_table
	WHERE [fieldname] = 'EndDate'
		AND	UPPER(condition) = 'BETWEEN'
	
	SELECT @EqualStartDate = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'StartDate'
		AND	condition = 'Equal To'
	
	SELECT @EqualEndDate = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'EndDate'
		AND	condition = 'Equal To'

	SELECT @EqualContractDate = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'ContractDate'
		AND	condition = 'Equal To'
	
	IF EXISTS(SELECT TOP 1 1 FROM tblSRReportLog WHERE strReportLogId = @strReportLogId)
	BEGIN	
		RETURN
	END

	SELECT DISTINCT strContractNumber = CH.strContractNumber + ' - ' + CAST(CD.intContractSeq AS NVARCHAR)
		, strPONumber = CD.strERPPONumber
		, CH.dtmContractDate
		, dtmStartDate = CONVERT(DATE, CD.dtmStartDate)
		, dtmEndDate = CONVERT(DATE, CD.dtmEndDate)
		, CD.dtmPlannedAvailabilityDate
		, strEntity = EN.strName
		, CH.strInternalComment
		, strItem = IT.strItemNo
		, dblQuantity = dbo.fnRemoveTrailingZeroes(ROUND(CD.dblQuantity, @intQtyDec))
		, strQtyUOM = IUOM.strUnitMeasure
		, dblNetWeight = dbo.fnRemoveTrailingZeroes(ROUND(CD.dblNetWeight, @intQtyDec))
		, strWeightUOM = WUOM.strUnitMeasure
		, strContractItem = IC.strContractItemName
		, strMarket = FMarket.strFutMarketName
		, strMonth = FMonth.strFutureMonth
		, CU.strCurrency
		, strPriceUOM = PUOM.strUnitMeasure
		, dblFutures = dbo.fnRemoveTrailingZeroes(ROUND(CD.dblFutures, @intPriceDec))
		, strProductType = PT.strDescription
		, strINCOShipTerms = ST.strFreightTerm
		, CS.strContractStatus
		, dblFinancingCost = dbo.fnRemoveTrailingZeroes(ROUND(CCTotal.dblFinancingCost, @intPriceDec))
		, dblFOB = dbo.fnRemoveTrailingZeroes(ROUND(CCTotal.dblFOB, @intPriceDec))
		, dblSustainabilityPremium = dbo.fnRemoveTrailingZeroes(ROUND(CCTotal.dblSustainabilityPremium, @intPriceDec))
		, dblFOBCAD = dbo.fnRemoveTrailingZeroes(ROUND(CCTotal.dblFOBCAD, @intPriceDec))
		, dblOtherCost = dbo.fnRemoveTrailingZeroes(ROUND(CCTotal.dblOtherCost, @intPriceDec))
		, dblBasis = dbo.fnRemoveTrailingZeroes(ROUND(CD.dblBasis, @intPriceDec))
		, dblCashPrice = dbo.fnRemoveTrailingZeroes(ROUND(CD.dblCashPrice, @intPriceDec))
	FROM tblCTContractDetail CD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblEMEntity EN ON EN.intEntityId = CH.intEntityId
	JOIN tblICItem IT ON IT.intItemId = CD.intItemId
	JOIN tblICUnitMeasure IUOM ON IUOM.intUnitMeasureId = CD.intUnitMeasureId
	JOIN tblICItemUOM WIUOM ON WIUOM.intItemUOMId = CD.intNetWeightUOMId
	JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = WIUOM.intUnitMeasureId
	JOIN tblICItemUOM PIUOM ON PIUOM.intItemUOMId = CD.intPriceItemUOMId
	JOIN tblICUnitMeasure PUOM ON PUOM.intUnitMeasureId = PIUOM.intUnitMeasureId
	JOIN tblCTContractStatus CS ON CS.intContractStatusId = CD.intContractStatusId
	LEFT JOIN (
		SELECT intContractDetailId
			, dblFinancingCost = [Financing cost]
			, dblFOB = [FOB +]
			, dblSustainabilityPremium = [Sustainability Premium]
			, dblFOBCAD = [FOB CAD]
			, dblOtherCost = [Other costs]
		FROM (
			SELECT intContractDetailId
				, strItemNo
				, dblRate
			FROM vyuCTContractCostView
			WHERE ysnBasis = 1
		) t 
		PIVOT(
			SUM(dblRate)
			FOR strItemNo IN ([Financing cost]
				, [FOB +]
				, [Sustainability Premium]
				, [FOB CAD]
				, [Other costs])
		) AS pivot_table
	) CCTotal ON CCTotal.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblICItemUOM IIUOM ON IIUOM.intItemUOMId = CD.intItemUOMId
	LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
	LEFT JOIN tblRKFutureMarket FMarket ON FMarket.intFutureMarketId = CD.intFutureMarketId
	LEFT JOIN tblRKFuturesMonth FMonth ON FMonth.intFutureMonthId = CD.intFutureMonthId
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblSMFreightTerms ST ON ST.intFreightTermId = ISNULL(CH.intFreightTermId, CD.intFreightTermId)
	LEFT JOIN tblICCommodityAttribute PT ON	PT.intCommodityAttributeId = IT.intProductTypeId AND PT.strType = 'ProductType'
	LEFT JOIN tblCTPosition PS ON PS.intPositionId = CH.intPositionId
	WHERE CD.intContractStatusId <> 3
		AND CD.dtmStartDate >= ISNULL(@dtmFromStartDate, CD.dtmStartDate) AND CD.dtmStartDate <= ISNULL(@dtmToStartDate, CD.dtmStartDate)
		AND CD.dtmEndDate >= ISNULL(@dtmFromEndDate, CD.dtmEndDate) AND CD.dtmEndDate <= ISNULL(@dtmToEndDate, CD.dtmEndDate)
		AND CH.dtmContractDate >= ISNULL(@dtmFromContractDate, CH.dtmContractDate) AND CH.dtmContractDate <= ISNULL(@dtmToContractDate, CH.dtmContractDate)
		AND CONVERT(DATE, CH.dtmContractDate) = ISNULL(@EqualContractDate, CONVERT(DATE, CH.dtmContractDate))
		AND CONVERT(DATE, CD.dtmStartDate) = ISNULL(@EqualStartDate, CONVERT(DATE, CD.dtmStartDate))
		AND CONVERT(DATE, CD.dtmEndDate) = ISNULL(@EqualEndDate, CONVERT(DATE, CD.dtmEndDate))
		AND CD.intContractDetailId = ISNULL(@intContractDetailId, CD.intContractDetailId)
		AND ISNULL(PT.strDescription, '') = ISNULL(@strProductType, ISNULL(PT.strDescription, ''))
		AND	ISNULL(PS.strPosition, '') = ISNULL(@strPosition, ISNULL(PS.strPosition, ''))
		AND	ISNULL(EN.strName, '') = ISNULL(@Vendor, ISNULL(EN.strName, ''))
	
	INSERT INTO tblSRReportLog(strReportLogId,dtmDate) VALUES(@strReportLogId ,GETDATE())
END