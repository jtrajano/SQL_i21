CREATE PROCEDURE [dbo].[uspRKM2MGetClosingPrice]
	@intM2MBasisId INT
	, @intFutureSettlementPriceId INT = NULL
	, @intQuantityUOMId INT = NULL
	, @intPriceUOMId INT = NULL
	, @intCurrencyUOMId INT = NULL
	, @dtmTransactionDateUpTo DATETIME = NULL
	, @strRateType NVARCHAR(200) = NULL
	, @strPricingType NVARCHAR(50)
	, @intCommodityId INT = NULL
	, @intLocationId INT = NULL
	, @intMarketZoneId INT = NULL

AS

BEGIN
	DECLARE @intMarkExpiredMonthPositionId INT
	DECLARE @dtmSettlemntPriceDate DATETIME
	SELECT @intMarkExpiredMonthPositionId = ISNULL(intMarkExpiredMonthPositionId, 1) FROM tblRKCompanyPreference
	SELECT @dtmSettlemntPriceDate = dtmPriceDate FROM tblRKFuturesSettlementPrice WHERE intFutureSettlementPriceId = @intFutureSettlementPriceId
	
	IF (@intMarkExpiredMonthPositionId = 2 OR @intMarkExpiredMonthPositionId = 3)
	BEGIN
		SELECT CONVERT(INT, intRowNum) as intRowNum
			, intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, dblClosingPrice
			, intConcurrencyId
			, 0 as intFutSettlementPriceMonthId
		FROM (
			SELECT ROW_NUMBER() OVER(ORDER BY f.intFutureMarketId DESC) AS intRowNum
				, f.intFutureMarketId
				, fm.intFutureMonthId
				, f.strFutMarketName
				, fm.strFutureMonth
				, dblClosingPrice = dbo.fnRKGetLatestClosingPrice(f.intFutureMarketId, fm.intFutureMonthId, @dtmSettlemntPriceDate)
				, intConcurrencyId = 0
			FROM tblRKFutureMarket f
			JOIN tblRKFuturesMonth fm ON f.intFutureMarketId = fm.intFutureMarketId AND fm.ysnExpired = 0
			JOIN tblRKCommodityMarketMapping mm ON fm.intFutureMarketId = mm.intFutureMarketId
			WHERE mm.intCommodityId = CASE WHEN ISNULL(@intCommodityId,0) = 0 THEN mm.intCommodityId ELSE @intCommodityId END
		) t
		WHERE dblClosingPrice > 0
		ORDER BY strFutMarketName
			, CONVERT(DATETIME, '01 ' + strFutureMonth)
	END
	ELSE
	BEGIN
		DECLARE @#tempInquiryTransaction TABLE (intRowNum INT
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
			, dblMarketRatio NUMERIC(24, 10)
			, dblFuturePrice NUMERIC(24, 10)
			, intContractTypeId INT
			, dblAdjustedContractPrice NUMERIC(24, 10)
			, dblCashPrice NUMERIC(24, 10)
			, dblMarketPrice NUMERIC(24, 10)
			, dblResultBasis NUMERIC(24, 10)
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
			, intCompanyLocationId INT
			, intMarketZoneId INT
			, strMarketZoneCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
			, dblResult NUMERIC(24, 10)
			, dblMarketFuturesResult NUMERIC(24, 10)
			, dblResultRatio NUMERIC(24, 10)
			, intSpreadMonthId INT
			, strSpreadMonth NVARCHAR(50)
			, dblSpreadMonthPrice NUMERIC(24, 20)
			, dblSpread NUMERIC(24, 10))
		
		INSERT INTO @#tempInquiryTransaction
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
		
		DECLARE @dtmPriceDate DATETIME
			, @strFutureMonthIds NVARCHAR(MAX)
		
		SELECT @strFutureMonthIds = COALESCE(@strFutureMonthIds + ',', '') + ISNULL(intFutureMonthId, '')
		FROM (
			SELECT DISTINCT CASE WHEN intFutureMonthId = NULL THEN '' ELSE CONVERT(NVARCHAR(50), intFutureMonthId) END AS intFutureMonthId
			FROM @#tempInquiryTransaction
		) tbl
		
		SELECT CONVERT(INT, intRowNum) AS intRowNum
			, intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, dblClosingPrice
			, intFutSettlementPriceMonthId
			, intConcurrencyId
			, ysnExpired
		FROM (
			SELECT ROW_NUMBER() OVER (ORDER BY f.intFutureMarketId DESC) AS intRowNum
				, f.intFutureMarketId
				, fm.intFutureMonthId
				, f.strFutMarketName
				, fm.strFutureMonth
				, dblClosingPrice = t.dblLastSettle
				, intFutSettlementPriceMonthId = t.intFutureMonthId
				, 0 as intConcurrencyId
				, ysnExpired
			FROM tblRKFutureMarket f
			JOIN tblRKFuturesMonth fm ON f.intFutureMarketId = fm.intFutureMarketId
			JOIN tblRKCommodityMarketMapping mm ON fm.intFutureMarketId = mm.intFutureMarketId
			JOIN (
				SELECT dblLastSettle
					, fm.intFutureMonthId
					, fm.intFutureMarketId
				FROM tblRKFuturesSettlementPrice p
				INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
				JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = CASE WHEN ISNULL(fm.ysnExpired, 0) = 0 THEN pm.intFutureMonthId
																		ELSE (SELECT TOP 1  intFutureMonthId
																			FROM tblRKFuturesMonth fm
																			WHERE ysnExpired = 0 AND fm.intFutureMarketId = p.intFutureMarketId
																				AND CONVERT(DATETIME, '01 ' + strFutureMonth) > GETDATE()
																			ORDER BY CONVERT(DATETIME,'01 '+strFutureMonth) ASC) END
				WHERE p.intFutureMarketId = fm.intFutureMarketId
					AND CONVERT(NVARCHAR, dtmPriceDate, 111) = CONVERT(NVARCHAR, @dtmSettlemntPriceDate, 111)
					AND ISNULL(p.strPricingType, @strPricingType) = @strPricingType
			) t ON t.intFutureMarketId = fm.intFutureMarketId AND t.intFutureMonthId = fm.intFutureMonthId
			WHERE mm.intCommodityId = CASE WHEN ISNULL(@intCommodityId, 0) = 0 THEN mm.intCommodityId ELSE @intCommodityId END
				AND ISNULL(fm.intFutureMonthId, 0) IN (SELECT CASE WHEN Item = '' THEN 0 ELSE LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS END
														FROM [dbo].[fnSplitString](@strFutureMonthIds, ','))
		) t WHERE dblClosingPrice > 0
		ORDER BY strFutMarketName
			, CONVERT(DATETIME, '01 ' + strFutureMonth)
	END
END