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
		SELECT strSummary = 'Physical'
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
		
		DECLARE @UnRelaized AS TABLE (intFutOptTransactionId INT
			, dblGrossPnL NUMERIC(24, 10)
			, dblLong NUMERIC(24, 10)
			, dblShort NUMERIC(24, 10)
			, dblFutCommission NUMERIC(24, 10)
			, strFutMarketName NVARCHAR(100)
			, strFutureMonth NVARCHAR(100)
			, dtmTradeDate DATETIME
			, strInternalTradeNo NVARCHAR(100)
			, strName NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strBook NVARCHAR(100)
			, strSubBook NVARCHAR(100)
			, strSalespersonId NVARCHAR(100)
			, strCommodityCode NVARCHAR(100)
			, strLocationName NVARCHAR(100)
			, dblLong1 INT
			, dblSell1 INT
			, dblNet INT
			, dblActual NUMERIC(24, 10)
			, dblClosing NUMERIC(24, 10)
			, dblPrice NUMERIC(24, 10)
			, dblContractSize NUMERIC(24, 10)
			, dblFutCommission1 NUMERIC(24, 10)
			, dblMatchLong NUMERIC(24, 10)
			, dblMatchShort NUMERIC(24, 10)
			, dblNetPnL NUMERIC(24, 10)
			, intFutureMarketId INT
			, intFutureMonthId INT
			, intOriginalQty INT
			, intFutOptTransactionHeaderId INT
			, strMonthOrder NVARCHAR(100)
			, RowNum INT
			, intCommodityId INT
			, ysnExpired BIT
			, dblVariationMargin NUMERIC(24, 10)
			, dblInitialMargin NUMERIC(24, 10)
			, LongWaitedPrice NUMERIC(24, 10)
			, ShortWaitedPrice NUMERIC(24, 10)
			, intSelectedInstrumentTypeId INT)
		INSERT INTO @UnRelaized (RowNum
			, strMonthOrder
			, intFutOptTransactionId
			, dblGrossPnL
			, dblLong
			, dblShort
			, dblFutCommission
			, strFutMarketName
			, strFutureMonth
			, dtmTradeDate
			, strInternalTradeNo
			, strName
			, strAccountNumber
			, strBook
			, strSubBook
			, strSalespersonId
			, strCommodityCode
			, strLocationName
			, dblLong1
			, dblSell1
			, dblNet
			, dblActual
			, dblClosing
			, dblPrice
			, dblContractSize
			, dblFutCommission1
			, dblMatchLong
			, dblMatchShort
			, dblNetPnL
			, intFutureMarketId
			, intFutureMonthId
			, intOriginalQty
			, intFutOptTransactionHeaderId
			, intCommodityId
			, ysnExpired
			, dblVariationMargin
			, dblInitialMargin
			, LongWaitedPrice
			, ShortWaitedPrice
			, intSelectedInstrumentTypeId)
		
		EXEC uspRKUnrealizedPnL @dtmFromDate ='01-01-1900'
			, @dtmToDate = @dtmTransactionDateUpTo
			, @intCommodityId = @intCommodityId
			, @ysnExpired = 0
			, @intFutureMarketId = NULL
			, @intEntityId = NULL
			, @intBrokerageAccountId = NULL
			, @intFutureMonthId = NULL
			, @strBuySell = NULL
			, @intBookId = NULL
			, @intSubBookId = NULL
		
		INSERT INTO @tblFinalDetail (strSummary
			, intCommodityId
			, strCommodityCode
			, strContractOrInventoryType
			, dblQty
			, dblTotal
			, dblFutures
			, dblBasis
			, dblCash)
		SELECT strSummary = 'Derivatives'
			, intCommodityId
			, strCommodityCode = ''
			, strContractOrInventoryType = ''
			, dblQty = NULL
			, dblTotal = pnl
			, dblFutures = NULL
			, dblBasis = NULL
			, dblCash = NULL
		FROM (
			SELECT DISTINCT intCommodityId
				, strCommodityCode
				, pnl = SUM(dblGrossPnL)
			FROM @UnRelaized
			GROUP BY intCommodityId
				, strCommodityCode
		) t
		
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