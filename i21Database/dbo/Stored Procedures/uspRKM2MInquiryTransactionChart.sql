CREATE PROCEDURE [dbo].[uspRKM2MInquiryTransactionChart]
	@intM2MBasisId INT = NULL
	, @intFutureSettlementPriceId INT = NULL
	, @intQuantityUOMId INT = NULL
	, @intPriceUOMId INT = NULL
	, @intCurrencyUOMId INT = NULL
	, @dtmTransactionDateUpTo DATETIME = NULL
	, @strRateType NVARCHAR(50) = NULL
	, @intCommodityId INT = NULL
	, @intLocationId INT = NULL
	, @intMarketZoneId INT = NULL

AS

BEGIN
	DECLARE @tblFinalDetail TABLE (intRowNum INT
		, intConcurrencyId INT
		, intContractHeaderId INT
		, intContractDetailId INT
		, strContractOrInventoryType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strContractSeq NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intEntityId INT
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, dblOpenQty NUMERIC(24, 10)
		, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intCommodityId INT
		, intItemId INT
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strOrgin NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strPosition NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strPeriod NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strPeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strStartDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strEndDate NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strPriOrNotPriOrParPriced NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intPricingTypeId INT
		, strPricingType NVARCHAR(100) COLLATE Latin1_General_CI_AS
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
	
	INSERT INTO @tblFinalDetail
	EXEC [uspRKM2MInquiryTransaction] @intM2MBasisId = @intM2MBasisId
		, @intFutureSettlementPriceId = @intFutureSettlementPriceId
		, @intQuantityUOMId = @intQuantityUOMId
		, @intPriceUOMId = @intPriceUOMId
		, @intCurrencyUOMId = @intCurrencyUOMId
		, @dtmTransactionDateUpTo = @dtmTransactionDateUpTo
		, @strRateType = @strRateType
		, @intCommodityId =@intCommodityId
		, @intLocationId = @intLocationId
		, @intMarketZoneId = @intMarketZoneId
	
	DECLARE @tblMonthFinal TABLE (intRowNum INT IDENTITY(1, 1)
		, strFutureMonth NVARCHAR(500) COLLATE Latin1_General_CI_AS
		, dblResult DECIMAL(24, 10)
		, dblResultBasis DECIMAL(24, 10)
		, dblMarketFuturesResult DECIMAL(24, 10)
		, dblResultCash DECIMAL(24, 10))
	
	SET DATEFORMAT dmy
	
	INSERT INTO @tblMonthFinal (strFutureMonth
		, dblResult
		, dblResultBasis
		, dblMarketFuturesResult
		, dblResultCash)
	SELECT strFutureMonth
		, SUM(dblResult)
		, SUM(dblResultBasis)
		, SUM(dblMarketFuturesResult)
		, SUM(dblResultCash)
	FROM (
		SELECT RIGHT(CONVERT(VARCHAR(10), CONVERT(DATETIME, '01/' + RIGHT(strPeriod, 5)), 6), 6) strFutureMonth
			, dblResult
			, dblResultBasis
			, dblMarketFuturesResult
			, dblResultCash
		FROM @tblFinalDetail
	) t
	GROUP BY strFutureMonth
	ORDER BY CONVERT(DATETIME, '01 ' + strFutureMonth) ASC
	
	SET DATEFORMAT mdy
	
	SELECT intRowNum
		, strFutureMonth
		, dblResult
		, dblResultBasis
		, dblMarketFuturesResult
		, dblResultCash
	FROM @tblMonthFinal
END