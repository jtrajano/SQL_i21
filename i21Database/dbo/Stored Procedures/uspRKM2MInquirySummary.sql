CREATE PROCEDURE uspRKM2MInquirySummary 
		@intM2MBasisId int = null,
		@intFutureSettlementPriceId int = null,
		@intQuantityUOMId int = null,
		@intPriceUOMId int = null,
		@intCurrencyUOMId int= null,
		@dtmTransactionDateUpTo datetime= null,
		@strRateType nvarchar(50)= null,
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
	,strSummary NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intCommodityId INT
	,strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,strContractOrInventoryType NVARCHAR(50) COLLATE Latin1_General_CI_AS
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
							strContractOrInventoryType NVARCHAR(50) COLLATE Latin1_General_CI_AS,
							strContractSeq NVARCHAR(50) COLLATE Latin1_General_CI_AS,
							strEntityName NVARCHAR(50) COLLATE Latin1_General_CI_AS,
							intEntityId INT,
							intFutureMarketId INT,
							strFutMarketName NVARCHAR(50) COLLATE Latin1_General_CI_AS,	
							intFutureMonthId INT,
							strFutureMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS,
							dblOpenQty NUMERIC(24, 10),
							strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS,
							intCommodityId INT,
							intItemId INT,	
							strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,	
							strOrgin NVARCHAR(50) COLLATE Latin1_General_CI_AS,
							strPosition NVARCHAR(50) COLLATE Latin1_General_CI_AS,		
							strPeriod NVARCHAR(50) COLLATE Latin1_General_CI_AS,
							strPriOrNotPriOrParPriced NVARCHAR(50) COLLATE Latin1_General_CI_AS,
							intPricingTypeId INT,
							strPricingType NVARCHAR(50) COLLATE Latin1_General_CI_AS,
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
							dblResult NUMERIC(24, 10),
							dblResultBasis NUMERIC(24, 10),
							dblMarketFuturesResult NUMERIC(24, 10),
							dblResultCash NUMERIC(24, 10),
							dblContractPrice NUMERIC(24, 10)
							,intQuantityUOMId INT
							,intCommodityUnitMeasureId INT
							,intPriceUOMId INT
							,intCent int
							,dtmPlannedAvailabilityDate datetime
						)

INSERT INTO @#tempSummary 
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
DECLARE @strDescription NVARCHAR(50)

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
				,sum((ISNULL(GrossPnL, 0) * (isnull(dbo.fnRKGetLatestClosingPrice(vp.intFutureMarketId, vp.intFutureMonthId, @dtmPriceDate), 0) - isnull(dblPrice, 0))) - isnull(dblFutCommission, 0)) pnl
			FROM vyuRKUnrealizedPnL vp
			WHERE intCommodityId = @intCommodityId1 and ysnExpired = 0
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