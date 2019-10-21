CREATE PROCEDURE [dbo].[uspRKM2MInquirySummary]
	@intM2MBasisId INT = NULL
	, @intFutureSettlementPriceId INT = NULL
	, @intQuantityUOMId INT = NULL
	, @intPriceUOMId INT = NULL
	, @intCurrencyUOMId INT = NULL
	, @dtmTransactionDateUpTo DATETIME = NULL
	, @strRateType NVARCHAR(200) = NULL
	, @intCommodityId INT = NULL
	, @intLocationId INT = NULL
	, @intMarketZoneId INT = NULL

AS

BEGIN
	DECLARE @ysnIncludeBasisDifferentialsInResults BIT
	DECLARE @dtmPriceDate DATETIME

	SELECT @dtmPriceDate = dtmM2MBasisDate
	FROM tblRKM2MBasis
	WHERE intM2MBasisId = @intM2MBasisId

	DECLARE @tblRow TABLE (RowNumber INT IDENTITY
		, intCommodityId INT)

	DECLARE @tblFinalDetail TABLE (RowNumber INT IDENTITY
		, strSummary NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId INT
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strContractOrInventoryType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblQty NUMERIC(24, 10)
		, dblTotal NUMERIC(24, 10)
		, dblFutures NUMERIC(24, 10)
		, dblBasis NUMERIC(24, 10)
		, dblCash NUMERIC(24, 10))
	
	DECLARE @#tempSummary TABLE (intRowNum INT
		, intConcurrencyId INT
		, intContractHeaderId INT
		, intContractDetailId INT
		, strContractOrInventoryType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strContractSeq NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strEntityName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intEntityId INT
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblOpenQty NUMERIC(24, 10)
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId INT
		, intItemId INT
		, strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strOrgin NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strPosition NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strPeriod NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strPeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strStartDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strEndDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strPriOrNotPriOrParPriced NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intPricingTypeId INT
		, strPricingType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblContractRatio NUMERIC(24, 10)
		, dblContractBasis NUMERIC(24, 10)
		, dblFutures NUMERIC(24, 10)
		, dblCash NUMERIC(24, 10)
		, dblCosts NUMERIC(24, 10)
		, dblMarketBasis NUMERIC(24, 10)
		, dblFuturePrice NUMERIC(24, 10)
		, intContractTypeId INT
		, dblAdjustedContractPrice NUMERIC(24, 10)
		, dblCashPrice NUMERIC(24, 10)
		, dblMarketPrice NUMERIC(24, 10)
		, dblResultBasis NUMERIC(24, 10)
		, dblMarketRatio NUMERIC(24, 10)
		, dblResultCash NUMERIC(24, 10)
		, dblContractPrice NUMERIC(24, 10)
		, intQuantityUOMId INT
		, intCommodityUnitMeasureId INT
		, intPriceUOMId INT
		, intCent INT
		, dtmPlannedAvailabilityDate DATETIME
		, dblPricedQty NUMERIC(24, 10)
		, dblUnPricedQty NUMERIC(24, 10)
		, dblPricedAmount NUMERIC(24, 10)
		, intMarketZoneId INT
		, intCompanyLocationId INT
		, strMarketZoneCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblResult NUMERIC(24, 10)
		, dblMarketFuturesResult NUMERIC(24, 10)
		, dblResultRatio NUMERIC(24, 10)
		, intSpreadMonthId INT
		, strSpreadMonth NVARCHAR(50)
		, dblSpreadMonthPrice NUMERIC(24, 20)
		, dblSpread NUMERIC(24, 10))
	
	INSERT INTO @#tempSummary (intRowNum
		, intConcurrencyId
		, intContractHeaderId
		, intContractDetailId
		, strContractOrInventoryType
		, strContractSeq
		, strEntityName
		, intEntityId
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, dblOpenQty
		, strCommodityCode
		, intCommodityId
		, intItemId
		, strItemNo
		, strOrgin
		, strPosition
		, strPeriod
		, strPeriodTo
		, strStartDate
		, strEndDate
		, strPriOrNotPriOrParPriced
		, intPricingTypeId
		, strPricingType
		, dblContractRatio
		, dblContractBasis
		, dblFutures
		, dblCash
		, dblCosts
		, dblMarketBasis
		, dblMarketRatio
		, dblFuturePrice
		, intContractTypeId
		, dblAdjustedContractPrice
		, dblCashPrice
		, dblMarketPrice
		, dblResultBasis
		, dblResultCash
		, dblContractPrice
		, intQuantityUOMId
		, intCommodityUnitMeasureId
		, intPriceUOMId
		, intCent
		, dtmPlannedAvailabilityDate
		, dblPricedQty
		, dblUnPricedQty
		, dblPricedAmount
		, intCompanyLocationId
		, intMarketZoneId
		, strMarketZoneCode
		, strLocationName
		, dblResult
		, dblMarketFuturesResult
		, dblResultRatio
		, intSpreadMonthId
		, strSpreadMonth
		, dblSpreadMonthPrice
		, dblSpread)
	EXEC uspRKM2MInquiryTransaction @intM2MBasisId = @intM2MBasisId
		, @intFutureSettlementPriceId = @intFutureSettlementPriceId
		, @intQuantityUOMId = @intQuantityUOMId
		, @intPriceUOMId = @intPriceUOMId
		, @intCurrencyUOMId = @intCurrencyUOMId
		, @dtmTransactionDateUpTo = @dtmTransactionDateUpTo
		, @strRateType = @strRateType
		, @intCommodityId = @intCommodityId
		, @intLocationId = @intLocationId
		, @intMarketZoneId = @intMarketZoneId
	
	INSERT INTO @tblRow (intCommodityId)
	SELECT intCommodityId
	FROM (
		SELECT DISTINCT intCommodityId
			, strCommodityCode
		FROM @#tempSummary	
		) t
	ORDER BY strCommodityCode

	DECLARE @mRowNumber INT
	DECLARE @intCommodityId1 INT
	DECLARE @strDescription NVARCHAR(200)

	SELECT @mRowNumber = MIN(RowNumber)
	FROM @tblRow

	WHILE @mRowNumber > 0
	BEGIN
		SET @intCommodityId1 = 0
		SET @strDescription = ''

		SELECT @intCommodityId1 = intCommodityId
		FROM @tblRow
		WHERE RowNumber = @mRowNumber

		SELECT @strDescription = strDescription
		FROM tblICCommodity
		WHERE intCommodityId = @intCommodityId1
		
		INSERT INTO @tblFinalDetail (strSummary
			, intCommodityId
			, strCommodityCode
			, strContractOrInventoryType
			, dblQty
			, dblTotal
			, dblFutures
			, dblBasis
			, dblCash)
		SELECT strSummary = ''
			, intCommodityId = NULL
			, strCommodityCode = @strDescription
			, strContractOrInventoryType = ''
			, dblQty = NULL
			, dblTotal = NULL
			, dblFutures = NULL
			, dblBasis = NULL
			, dblCash = NULL
		
		INSERT INTO @tblFinalDetail (strSummary
			, intCommodityId
			, strCommodityCode
			, strContractOrInventoryType
			, dblQty
			, dblTotal
			, dblFutures
			, dblBasis
			, dblCash)
		SELECT strSummary = CASE WHEN strContractOrInventoryType like 'Futures%' THEN 'Derivatives' ELSE 'Physical' END
			, intCommodityId
			, strCommodityCode = ''
			, strContractOrInventoryType
			, dblQty = SUM(ISNULL(dblOpenQty, 0))
			, dblTotal = SUM(ISNULL(dblResult, 0))
			, dblFutures = SUM(ISNULL(dblMarketFuturesResult, 0))
			, dblBasis = SUM(ISNULL(dblResultBasis, 0))
			, dblCash = SUM(ISNULL(dblResultCash, 0))
		FROM @#tempSummary s
		WHERE s.intCommodityId = @intCommodityId1
		GROUP BY intCommodityId
			, strCommodityCode
			, strContractOrInventoryType
		
		
		INSERT INTO @tblFinalDetail (strSummary
			, dblQty
			, dblTotal
			, dblFutures
			, dblBasis
			, dblCash)
		SELECT 'Total'
			, SUM(ISNULL(dblQty, 0))
			, SUM(ISNULL(dblTotal, 0))
			, SUM(ISNULL(dblFutures, 0))
			, SUM(ISNULL(dblBasis, 0))
			, SUM(ISNULL(dblCash, 0))
		FROM @tblFinalDetail
		WHERE intCommodityId = @intCommodityId1
		
		SELECT @mRowNumber = MIN(RowNumber)
		FROM @tblRow
		WHERE RowNumber > @mRowNumber
	END
	
	INSERT INTO @tblFinalDetail(strSummary
		, dblQty
		, dblTotal
		, dblFutures
		, dblBasis
		, dblCash)
	SELECT 'Total Summary'
		, SUM(ISNULL(dblQty, 0))
		, SUM(ISNULL(dblTotal, 0))
		, SUM(ISNULL(dblFutures, 0))
		, SUM(ISNULL(dblBasis, 0))
		, SUM(ISNULL(dblCash, 0))
	FROM @tblFinalDetail
	WHERE strSummary = 'Total'
	
	SELECT RowNumber
		, strSummary
		, intCommodityId
		, strCommodityCode
		, strContractOrInventoryType
		, dblQty
		, dblTotal
		, dblFutures = CONVERT(DECIMAL, dblFutures)
		, dblBasis
		, dblCash
		, intConcurrencyId = 0
	FROM @tblFinalDetail
END