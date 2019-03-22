CREATE PROCEDURE [dbo].[uspRKM2MInquirySummary] 
		@intM2MBasisId int = null,
		@intFutureSettlementPriceId int = null,
		@intQuantityUOMId int = null,
		@intPriceUOMId int = null,
		@intCurrencyUOMId int= null,
		@dtmTransactionDateUpTo datetime= null,
		@strRateType nvarchar(200)= null,
		@intCommodityId int=Null,
		@intLocationId int= null,
		@intMarketZoneId int= null
AS

DECLARE @ysnIncludeBasisDifferentialsInResults BIT
DECLARE @dtmPriceDate DATETIME

SELECT @dtmPriceDate = dtmM2MBasisDate
FROM tblRKM2MBasis
WHERE intM2MBasisId = @intM2MBasisId

DECLARE @tblRow TABLE (
	RowNumber INT IDENTITY(1, 1)
	,intCommodityId INT
	)
DECLARE @tblFinalDetail TABLE (
	RowNumber INT IDENTITY(1, 1)
	,strSummary NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,intCommodityId INT
	,strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,strContractOrInventoryType NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,dblQty NUMERIC(24, 10)
	,dblTotal NUMERIC(24, 10)
	,dblFutures NUMERIC(24, 10)
	,dblBasis NUMERIC(24, 10)
	,dblCash NUMERIC(24, 10)
	)

	DECLARE @#tempSummary TABLE (
							intRowNum INT,
							intConcurrencyId INT,	
							intContractHeaderId INT,	
							intContractDetailId INT,	
							strContractOrInventoryType NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							strContractSeq NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							strEntityName NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							intEntityId INT,
							intFutureMarketId INT,
							strFutMarketName NVARCHAR(200) COLLATE Latin1_General_CI_AS,	
							intFutureMonthId INT,
							strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							dblOpenQty NUMERIC(24, 10),
							strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							intCommodityId INT,
							intItemId INT,	
							strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS,	
							strOrgin NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							strPosition NVARCHAR(200) COLLATE Latin1_General_CI_AS,		
							strPeriod NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							strPeriodTo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
							strPriOrNotPriOrParPriced NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							intPricingTypeId INT,
							strPricingType NVARCHAR(200) COLLATE Latin1_General_CI_AS,
							dblContractRatio NUMERIC(24, 10),
							dblContractBasis NUMERIC(24, 10),
							dblFutures NUMERIC(24, 10),
							dblCash NUMERIC(24, 10), 
							dblCosts NUMERIC(24, 10),
							dblMarketBasis NUMERIC(24, 10), 
							dblFuturePrice NUMERIC(24, 10),
							intContractTypeId INT,
							dblAdjustedContractPrice NUMERIC(24, 10),
							dblCashPrice NUMERIC(24, 10), 
							dblMarketPrice NUMERIC(24, 10),
							dblResultBasis NUMERIC(24, 10),
							dblMarketRatio NUMERIC(24, 10), 
							dblResultCash NUMERIC(24, 10),
							dblContractPrice NUMERIC(24, 10)
							,intQuantityUOMId INT
							,intCommodityUnitMeasureId INT
							,intPriceUOMId INT
							,intCent int
							,dtmPlannedAvailabilityDate datetime
							,dblPricedQty numeric(24,10),dblUnPricedQty numeric(24,10),dblPricedAmount numeric(24,10),
							intMarketZoneId int  ,intCompanyLocationId int
							,strMarketZoneCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
							,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
							,dblResult NUMERIC(24, 10)
							,dblMarketFuturesResult NUMERIC(24, 10)
							,dblResultRatio NUMERIC(24, 10)
						)

INSERT INTO @#tempSummary (intRowNum ,intConcurrencyId ,	intContractHeaderId ,	intContractDetailId ,	
strContractOrInventoryType,
strContractSeq,strEntityName,intEntityId ,intFutureMarketId ,strFutMarketName,	intFutureMonthId ,strFutureMonth,
dblOpenQty ,strCommodityCode,intCommodityId ,intItemId ,	strItemNo,	strOrgin,strPosition,		strPeriod,
strPeriodTo ,strPriOrNotPriOrParPriced,intPricingTypeId ,strPricingType,dblContractRatio ,dblContractBasis ,dblFutures ,
dblCash , dblCosts ,dblMarketBasis ,dblMarketRatio, dblFuturePrice ,intContractTypeId ,dblAdjustedContractPrice ,dblCashPrice , dblMarketPrice ,
dblResultBasis , dblResultCash ,dblContractPrice,intQuantityUOMId ,intCommodityUnitMeasureId ,intPriceUOMId 
,intCent ,dtmPlannedAvailabilityDate ,dblPricedQty ,dblUnPricedQty ,dblPricedAmount ,intCompanyLocationId ,intMarketZoneId   ,
strMarketZoneCode ,strLocationName ,dblResult ,dblMarketFuturesResult ,dblResultRatio)
EXEC uspRKM2MInquiryTransaction @intM2MBasisId= @intM2MBasisId,@intFutureSettlementPriceId= @intFutureSettlementPriceId,@intQuantityUOMId= @intQuantityUOMId,@intPriceUOMId= @intPriceUOMId,@intCurrencyUOMId= @intCurrencyUOMId,@dtmTransactionDateUpTo= @dtmTransactionDateUpTo, @strRateType=@strRateType,@intCommodityId= @intCommodityId,@intLocationId= @intLocationId,@intMarketZoneId= @intMarketZoneId 

INSERT INTO @tblRow (intCommodityId)
SELECT intCommodityId
FROM (
	SELECT DISTINCT intCommodityId
		,strCommodityCode
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
	
		INSERT INTO @tblFinalDetail (
		strSummary
		,intCommodityId
		,strCommodityCode
		,strContractOrInventoryType
		,dblQty
		,dblTotal
		,dblFutures
		,dblBasis
		,dblCash
		)
	
	SELECT '' strSummary
		,NULL intCommodityId
		,@strDescription AS strCommodityCode
		,'' strContractOrInventoryType
		,NULL AS dblQty
		,NULL AS dblTotal
		,NULL AS dblFutures
		,NULL AS dblBasis
		,NULL AS dblCash
	

	INSERT INTO @tblFinalDetail (
		strSummary
		,intCommodityId
		,strCommodityCode
		,strContractOrInventoryType
		,dblQty
		,dblTotal
		,dblFutures
		,dblBasis
		,dblCash
		)
	
		SELECT 'Physical' strSummary
			,intCommodityId
			,'' strCommodityCode
			,strContractOrInventoryType
			,sum(isnull(dblOpenQty, 0)) dblQty
			,sum(isnull(dblResult,0)) AS dblTotal
			,sum(isnull(dblMarketFuturesResult, 0)) AS dblFutures
			,sum(isnull(dblResultBasis, 0)) AS dblBasis
			,sum(isnull(dblResultCash, 0)) AS dblCash
		FROM @#tempSummary s
		WHERE s.intCommodityId = @intCommodityId1
		GROUP BY intCommodityId
			,strCommodityCode
			,strContractOrInventoryType	
			
			
DECLARE @UnRelaized AS TABLE (
	intFutOptTransactionId INT,
	dblGrossPnL NUMERIC(24, 10),
	dblLong NUMERIC(24, 10),
	dblShort NUMERIC(24, 10),
	dblFutCommission NUMERIC(24, 10),
	strFutMarketName NVARCHAR(100),
	strFutureMonth NVARCHAR(100),
	dtmTradeDate DATETIME,
	strInternalTradeNo NVARCHAR(100),
	strName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strBook NVARCHAR(100),
	strSubBook NVARCHAR(100),
	strSalespersonId NVARCHAR(100),
	strCommodityCode NVARCHAR(100),
	strLocationName NVARCHAR(100),
	dblLong1 INT,
	dblSell1 INT,
	dblNet INT,
	dblActual NUMERIC(24, 10),
	dblClosing NUMERIC(24, 10),
	dblPrice NUMERIC(24, 10),
	dblContractSize NUMERIC(24, 10),
	dblFutCommission1 NUMERIC(24, 10),
	dblMatchLong NUMERIC(24, 10),
	dblMatchShort NUMERIC(24, 10),
	dblNetPnL NUMERIC(24, 10),
	intFutureMarketId INT,
	intFutureMonthId INT,
	intOriginalQty INT,
	intFutOptTransactionHeaderId INT,
	strMonthOrder NVARCHAR(100),
	RowNum INT,
	intCommodityId INT,
	ysnExpired BIT,
	dblVariationMargin NUMERIC(24, 10),
	dblInitialMargin NUMERIC(24, 10),
	LongWaitedPrice NUMERIC(24, 10),
	ShortWaitedPrice NUMERIC(24, 10)
	)
	INSERT INTO @UnRelaized (
	RowNum,
	strMonthOrder,
	intFutOptTransactionId,
	dblGrossPnL,
	dblLong,
	dblShort,
	dblFutCommission,
	strFutMarketName,
	strFutureMonth,
	dtmTradeDate,
	strInternalTradeNo,
	strName,
	strAccountNumber,
	strBook,
	strSubBook,
	strSalespersonId,
	strCommodityCode,
	strLocationName,
	dblLong1,
	dblSell1,
	dblNet,
	dblActual,
	dblClosing,
	dblPrice,
	dblContractSize,
	dblFutCommission1,
	dblMatchLong,
	dblMatchShort,
	dblNetPnL,
	intFutureMarketId,
	intFutureMonthId,
	intOriginalQty,
	intFutOptTransactionHeaderId,
	intCommodityId,
	ysnExpired,
	dblVariationMargin,
	dblInitialMargin,
	LongWaitedPrice,
	ShortWaitedPrice
	)

exec uspRKUnrealizedPnL  @dtmFromDate ='01-01-1900',
		@dtmToDate = @dtmTransactionDateUpTo,
	@intCommodityId  = @intCommodityId,
	@ysnExpired =0,
	@intFutureMarketId  = NULL,
	@intEntityId  = NULL,
	@intBrokerageAccountId  = NULL,
	@intFutureMonthId  = NULL,
	@strBuySell  = NULL,
	@intBookId  = NULL,
	@intSubBookId  = NULL				
		INSERT INTO @tblFinalDetail (
		strSummary
		,intCommodityId
		,strCommodityCode
		,strContractOrInventoryType
		,dblQty
		,dblTotal
		,dblFutures
		,dblBasis
		,dblCash
		)	
		SELECT 'Derivatives' strSummary
			,intCommodityId
			,'' strCommodityCode
			,'' strContractOrInventoryType
			,NULL AS dblQty
			,pnl AS dblTotal
			,NULL AS dblFutures
			,NULL AS dblBasis
			,NULL AS dblCash
		FROM (
			SELECT DISTINCT intCommodityId
				,strCommodityCode
				,sum(dblGrossPnL) pnl
			FROM @UnRelaized 
			GROUP BY intCommodityId
				,strCommodityCode
			) t

	INSERT INTO @tblFinalDetail(strSummary,dblQty,dblTotal, dblFutures,dblBasis,dblCash)
	SELECT 'Total',sum(isnull(dblQty,0)),sum(isnull(dblTotal,0)), sum(isnull(dblFutures,0)),sum(isnull(dblBasis,0)),sum(isnull(dblCash,0)) FROM @tblFinalDetail
	WHERE intCommodityId = @intCommodityId1

	SELECT @mRowNumber = MIN(RowNumber)
	FROM @tblRow
	WHERE RowNumber > @mRowNumber
END

	INSERT INTO @tblFinalDetail(strSummary,dblQty,dblTotal, dblFutures,dblBasis,dblCash)
	SELECT 'Total Summary',sum(isnull(dblQty,0)),sum(isnull(dblTotal,0)), sum(isnull(dblFutures,0)),sum(isnull(dblBasis,0)),sum(isnull(dblCash,0)) FROM @tblFinalDetail where 
	strSummary = 'Total'
	
SELECT RowNumber,strSummary,intCommodityId,strCommodityCode,strContractOrInventoryType,dblQty,dblTotal,convert(decimal,dblFutures) as dblFutures,dblBasis,dblCash,0 as intConcurrencyId  
FROM @tblFinalDetail