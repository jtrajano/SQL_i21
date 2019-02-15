CREATE PROC [dbo].[uspRKM2MGetClosingPrice]   
  		@intM2MBasisId INT,
		@intFutureSettlementPriceId int = null,
        @intQuantityUOMId int = null,
        @intPriceUOMId int = null,
        @intCurrencyUOMId int= null,
        @dtmTransactionDateUpTo datetime= null,
        @strRateType nvarchar(200)= null,
		@strPricingType nvarchar(50),
        @intCommodityId int=Null,
        @intLocationId int= null,
        @intMarketZoneId int= null
AS  


DECLARE @#tempInquiryTransaction TABLE (
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
							dblMarketRatio NUMERIC(24, 10), 
							dblFuturePrice NUMERIC(24, 10),
							intContractTypeId INT,
							dblAdjustedContractPrice NUMERIC(24, 10),
							dblCashPrice NUMERIC(24, 10), 
							dblMarketPrice NUMERIC(24, 10),
							dblResultBasis NUMERIC(24, 10),
							dblResultCash NUMERIC(24, 10),
							dblContractPrice NUMERIC(24, 10)
							,intQuantityUOMId INT
							,intCommodityUnitMeasureId INT
							,intPriceUOMId INT
							,intCent int
							,dtmPlannedAvailabilityDate datetime
							,dblPricedQty numeric(24,10),dblUnPricedQty numeric(24,10)
							,dblPricedAmount numeric(24,10)
							,intCompanyLocationId int
							,intMarketZoneId int 
							,strMarketZoneCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
							,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
							,dblResult NUMERIC(24, 10)
							,dblMarketFuturesResult NUMERIC(24, 10)
							,dblResultRatio NUMERIC(24, 10)
						)


INSERT INTO @#tempInquiryTransaction 
exec uspRKM2MInquiryTransaction 
	 @intM2MBasisId= @intM2MBasisId
	,@intFutureSettlementPriceId= @intFutureSettlementPriceId
	,@intQuantityUOMId= @intQuantityUOMId
	,@intPriceUOMId= @intPriceUOMId
	,@intCurrencyUOMId= @intCurrencyUOMId
	,@dtmTransactionDateUpTo= @dtmTransactionDateUpTo
	,@strRateType=@strRateType
	,@intCommodityId= @intCommodityId
	,@intLocationId= @intLocationId
	,@intMarketZoneId= @intMarketZoneId 

	DECLARE
		  @dtmPriceDate datetime
		 ,@strFutureMonthIds nvarchar(max)


	SELECT @dtmPriceDate = dtmPriceDate FROM tblRKFuturesSettlementPrice WHERE intFutureSettlementPriceId = @intFutureSettlementPriceId

	SELECT @strFutureMonthIds = COALESCE(@strFutureMonthIds+',' ,'') + ISNULL(intFutureMonthId,'') FROM(
		SELECT DISTINCT  CASE WHEN intFutureMonthId = NULL THEN '' ELSE CONVERT(NVARCHAR(50),intFutureMonthId) END as intFutureMonthId FROM @#tempInquiryTransaction
	) tbl


SELECT CONVERT(INT,intRowNum) as intRowNum,intFutureMarketId,strFutMarketName,intFutureMonthId,strFutureMonth,dblClosingPrice,intFutSettlementPriceMonthId,intConcurrencyId from (
	SELECT 
		ROW_NUMBER() OVER(ORDER BY f.intFutureMarketId DESC) AS intRowNum
		,f.intFutureMarketId
		,fm.intFutureMonthId
		,f.strFutMarketName
		,fm.strFutureMonth
		,dblClosingPrice = (SELECT TOP 1 dblLastSettle
							FROM tblRKFuturesSettlementPrice p
							INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
							WHERE p.intFutureMarketId = f.intFutureMarketId
								AND pm.intFutureMonthId = fm.intFutureMonthId
								--AND CONVERT(Nvarchar, dtmPriceDate, 111) <= CONVERT(Nvarchar, @dtmPriceDate, 111)
								AND p.strPricingType = @strPricingType
								AND p.intFutureSettlementPriceId = @intFutureSettlementPriceId
							ORDER BY dtmPriceDate DESC)
		,intFutSettlementPriceMonthId = (SELECT TOP 1 intFutSettlementPriceMonthId
							FROM tblRKFuturesSettlementPrice p
							INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
							WHERE p.intFutureMarketId = f.intFutureMarketId
								AND pm.intFutureMonthId = fm.intFutureMonthId
								--AND CONVERT(Nvarchar, dtmPriceDate, 111) <= CONVERT(Nvarchar, @dtmPriceDate, 111)
								AND p.strPricingType = @strPricingType
								AND p.intFutureSettlementPriceId = @intFutureSettlementPriceId
							ORDER BY dtmPriceDate DESC)
		,0 as intConcurrencyId  
FROM tblRKFutureMarket f  
JOIN tblRKFuturesMonth fm on f.intFutureMarketId = fm.intFutureMarketId and  fm.ysnExpired=0
join tblRKCommodityMarketMapping mm on fm.intFutureMarketId=mm.intFutureMarketId 
where mm.intCommodityId  = case when isnull(@intCommodityId,0) = 0 then mm.intCommodityId else @intCommodityId end 
and ISNULL(fm.intFutureMonthId,0) IN(select case when Item = '' then 0 else Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS end  from [dbo].[fnSplitString](@strFutureMonthIds, ',')) --added this be able to filter by zone to (RM-739)
)t where dblClosingPrice > 0
order by strFutMarketName,convert(datetime,'01 '+strFutureMonth)
