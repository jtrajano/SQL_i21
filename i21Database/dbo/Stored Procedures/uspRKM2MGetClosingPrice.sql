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

declare @ysnM2MAllowExpiredMonth bit=0
DECLARE @dtmSettlemntPriceDate DATETIME 
select @ysnM2MAllowExpiredMonth=ysnM2MAllowExpiredMonth from tblRKCompanyPreference
SELECT @dtmSettlemntPriceDate=dtmPriceDate FROM tblRKFuturesSettlementPrice WHERE intFutureSettlementPriceId=@intFutureSettlementPriceId

if(@ysnM2MAllowExpiredMonth=1)
BEGIN
SELECT CONVERT(INT,intRowNum) as intRowNum,intFutureMarketId,strFutMarketName,intFutureMonthId,strFutureMonth,dblClosingPrice,intConcurrencyId,0 as intFutSettlementPriceMonthId from (
SELECT ROW_NUMBER() OVER(ORDER BY f.intFutureMarketId DESC) AS intRowNum,f.intFutureMarketId,fm.intFutureMonthId,f.strFutMarketName,fm.strFutureMonth,  
dbo.fnRKGetLatestClosingPrice(f.intFutureMarketId,fm.intFutureMonthId,@dtmSettlemntPriceDate) as dblClosingPrice,0 as intConcurrencyId  
FROM tblRKFutureMarket f  
JOIN tblRKFuturesMonth fm on f.intFutureMarketId = fm.intFutureMarketId and  fm.ysnExpired=0
join tblRKCommodityMarketMapping mm on fm.intFutureMarketId=mm.intFutureMarketId 
where mm.intCommodityId  = case when isnull(@intCommodityId,0) = 0 then mm.intCommodityId else @intCommodityId end 
)t where dblClosingPrice > 0
order by strFutMarketName,convert(datetime,'01 '+strFutureMonth)

ENd
ELSE
BEGIN

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
 dblContractPrice NUMERIC(24, 10),  
 intQuantityUOMId INT,  
 intCommodityUnitMeasureId INT,  
 intPriceUOMId INT,  
 intCent INT,  
 dtmPlannedAvailabilityDate DATETIME,  
 dblPricedQty NUMERIC(24, 10),  
 dblUnPricedQty NUMERIC(24, 10),  
 dblPricedAmount NUMERIC(24, 10),  
 intCompanyLocationId INT,  
 intMarketZoneId INT,  
 strMarketZoneCode NVARCHAR(200) COLLATE Latin1_General_CI_AS,  
 strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS,  
 dblResult NUMERIC(24, 10),  
 dblMarketFuturesResult NUMERIC(24, 10),  
 dblResultRatio NUMERIC(24, 10)  
 )  
  
INSERT INTO @#tempInquiryTransaction  
EXEC uspRKM2MInquiryTransaction @intM2MBasisId = @intM2MBasisId,  
 @intFutureSettlementPriceId = @intFutureSettlementPriceId,  
 @intQuantityUOMId = @intQuantityUOMId,  
 @intPriceUOMId = @intPriceUOMId,  
 @intCurrencyUOMId = @intCurrencyUOMId,  
 @dtmTransactionDateUpTo = @dtmTransactionDateUpTo,  
 @strRateType = @strRateType,  
 @intCommodityId = @intCommodityId,  
 @intLocationId = @intLocationId,  
 @intMarketZoneId = @intMarketZoneId  
 
DECLARE @dtmPriceDate DATETIME,  
 @strFutureMonthIds NVARCHAR(max)  
  
SELECT @strFutureMonthIds = COALESCE(@strFutureMonthIds + ',', '') + ISNULL(intFutureMonthId, '')  
FROM (  
 SELECT DISTINCT CASE WHEN intFutureMonthId = NULL THEN '' ELSE CONVERT(NVARCHAR(50), intFutureMonthId) END AS intFutureMonthId  
 FROM @#tempInquiryTransaction  
 ) tbl  
  
SELECT CONVERT(INT, intRowNum) AS intRowNum,  
 intFutureMarketId,  
 strFutMarketName,  
 intFutureMonthId,  
 strFutureMonth,  
 dblClosingPrice,  
 intFutSettlementPriceMonthId,  
 intConcurrencyId,ysnExpired
FROM (  
 SELECT ROW_NUMBER() OVER (  
   ORDER BY f.intFutureMarketId DESC  
   ) AS intRowNum,  
  f.intFutureMarketId,  
  fm.intFutureMonthId,  
  f.strFutMarketName,  
  fm.strFutureMonth,  
  dblClosingPrice =t.dblLastSettle,     
  intFutSettlementPriceMonthId =   t.intFutureMonthId,
  0 as intConcurrencyId,
  ysnExpired
 FROM tblRKFutureMarket f  
 JOIN tblRKFuturesMonth fm ON f.intFutureMarketId = fm.intFutureMarketId --and fm.ysnExpired=0  
 JOIN tblRKCommodityMarketMapping mm ON fm.intFutureMarketId = mm.intFutureMarketId  
 join (SELECT  dblLastSettle,fm.intFutureMonthId,fm.intFutureMarketId
			FROM tblRKFuturesSettlementPrice p
			INNER JOIN tblRKFutSettlementPriceMarketMap pm ON p.intFutureSettlementPriceId = pm.intFutureSettlementPriceId
			join tblRKFuturesMonth fm on fm.intFutureMonthId= case when  isnull(fm.ysnExpired,0)=0 then pm.intFutureMonthId
															  else 
															  (SELECT TOP 1  intFutureMonthId
																FROM tblRKFuturesMonth fm
																WHERE ysnExpired = 0  AND fm.intFutureMarketId = p.intFutureMarketId 
																and CONVERT(DATETIME,'01 '+strFutureMonth) > getdate()
																ORDER BY CONVERT(DATETIME,'01 '+strFutureMonth) ASC)
															  end				
			WHERE 
			p.intFutureMarketId =fm.intFutureMarketId  
				AND CONVERT(Nvarchar, dtmPriceDate, 111) = CONVERT(Nvarchar, @dtmSettlemntPriceDate, 111)
				AND isnull(p.strPricingType,@strPricingType) = @strPricingType 
			)	t on t.intFutureMarketId=fm.intFutureMarketId and t.intFutureMonthId=fm.intFutureMonthId

 WHERE mm.intCommodityId = CASE WHEN isnull(@intCommodityId, 0) = 0 THEN mm.intCommodityId ELSE @intCommodityId END AND ISNULL(fm.intFutureMonthId, 0) IN (  
   SELECT CASE WHEN Item = '' THEN 0 ELSE Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS END  
   FROM [dbo].[fnSplitString](@strFutureMonthIds, ',')  
   ) 
 ) t where dblClosingPrice > 0  
ORDER BY strFutMarketName,  
 convert(DATETIME, '01 ' + strFutureMonth)
 ENd