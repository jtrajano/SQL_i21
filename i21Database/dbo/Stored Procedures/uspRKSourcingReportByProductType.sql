CREATE PROCEDURE [dbo].[uspRKSourcingReportByProductType]
	@dtmFromDate DATETIME = NULL
	, @dtmToDate DATETIME = NULL
	, @intCommodityId INT = NULL
	, @intUnitMeasureId INT = NULL
	, @ysnVendorProducer BIT = NULL
	, @intBookId INT = NULL
	, @intSubBookId INT = NULL
	, @strYear NVARCHAR(10) = NULL
	, @dtmAOPFromDate DATETIME = NULL
	, @dtmAOPToDate DATETIME = NULL
	, @intCurrencyId INT = NULL

AS

BEGIN
	DECLARE @GetStandardQty AS TABLE (intRowNum INT
		, intContractDetailId INT
		, strEntityName NVARCHAR(MAX)
		, intContractHeaderId INT
		, strContractSeq NVARCHAR(100)
		, dblQty NUMERIC(24, 10)
		, dblReturnQty NUMERIC(24, 10)
		, dblBalanceQty NUMERIC(24, 10)
		, dblNoOfLots NUMERIC(24, 10)
		, dblFuturesPrice NUMERIC(24, 10)
		, dblSettlementPrice NUMERIC(24, 10)
		, dblBasis NUMERIC(24, 10)
		, dblRatio NUMERIC(24, 10)
		, dblPrice NUMERIC(24, 10)
		, dblTotPurchased NUMERIC(24, 10)
		, strOrigin NVARCHAR(100)
		, strProductType NVARCHAR(100)
		, dblStandardRatio NUMERIC(24, 10)
		, dblStandardQty NUMERIC(24, 10)
		, intItemId INT
		, dblStandardPrice NUMERIC(24, 10)
		, dblPPVBasis NUMERIC(24, 10)
		, dblNewPPVPrice NUMERIC(24, 10)
		, dblStandardValue NUMERIC(24, 10)
		, dblPPV NUMERIC(24, 10)
		, dblPPVNew NUMERIC(24, 10)
		, strLocationName NVARCHAR(100)
		, strPricingType NVARCHAR(100)
		, strItemNo NVARCHAR(100)
		, strCurrency NVARCHAR(100)
		, strUnitMeasure NVARCHAR(100)
		, strFutureMarket NVARCHAR(100)
		, strFutureMonth NVARCHAR(100))
	
	INSERT INTO @GetStandardQty(intRowNum
		, intContractDetailId
		, strEntityName
		, intContractHeaderId
		, strContractSeq
		, dblQty
		, dblReturnQty
		, dblBalanceQty
		, dblNoOfLots
		, dblFuturesPrice
		, dblSettlementPrice
		, dblBasis
		, dblRatio
		, dblPrice
		, dblTotPurchased
		, strOrigin
		, strProductType
		, dblStandardRatio
		, dblStandardQty
		, intItemId
		, dblStandardPrice
		, dblPPVBasis
		, strLocationName
		, dblNewPPVPrice
		, dblStandardValue
		, dblPPV
		, dblPPVNew
		, strPricingType
		, strItemNo
		, strCurrency
		, strUnitMeasure
		, strFutureMarket
		, strFutureMonth)
	EXEC [uspRKSourcingReportByProductTypeDetail] @dtmFromDate = @dtmFromDate
		, @dtmToDate = @dtmToDate
		, @intCommodityId = @intCommodityId
		, @intUnitMeasureId = @intUnitMeasureId
		, @strEntityName = NULL
		, @ysnVendorProducer = @ysnVendorProducer
		, @strProductType = NULL
		, @strOrigin = NULL
		, @intBookId = @intBookId
		, @intSubBookId = @intSubBookId
		, @strYear = @strYear
		, @dtmAOPFromDate = @dtmAOPFromDate
		, @dtmAOPToDate = @dtmAOPToDate
		, @strLocationName = ''
		, @intCurrencyId = @intCurrencyId
	
	SELECT intRowNum = CAST(ROW_NUMBER() OVER (ORDER BY strName) AS INT)
		, intConcurrencyId = 1
		, *
	FROM (
		SELECT strEntityName strName
			, strLocationName
			, strOrigin
			, strProductType
			, dblQty = SUM(dblBalanceQty)
			, dblTotPurchased = SUM(dblTotPurchased)
			, dblCompanySpend = SUM(dblTotPurchased) / SUM(CASE WHEN ISNULL(SUM(dblTotPurchased), 0) = 0 THEN 1 ELSE SUM(dblTotPurchased) END) OVER () * 100
			, dblStandardQty = SUM(dblStandardQty)
		FROM @GetStandardQty
		GROUP BY strEntityName
			, strEntityName
			, strLocationName
			, strOrigin
			, strProductType
		)t
END