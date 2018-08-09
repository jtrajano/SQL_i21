CREATE PROC [dbo].[uspRKRiskPositionInquiryBySummary]  
        @intCommodityId INTEGER,  
        @intCompanyLocationId INTEGER,  
        @intFutureMarketId INTEGER,  
        @intFutureMonthId INTEGER,  
        @intUOMId INTEGER,  
        @intDecimal INTEGER,
        @intForecastWeeklyConsumption INTEGER = NULL,
        @intForecastWeeklyConsumptionUOMId INTEGER = NULL   ,
		@intBookId int = NULL, 
		@intSubBookId int = NULL,
		@strPositionBy nvarchar(100) = NULL,
		@dtmPositionAsOf datetime = NULL
AS  

DECLARE @dtmToDate DATETIME
SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmPositionAsOf, 110), 110)

--IF ISNULL(@intForecastWeeklyConsumptionUOMId,0)=0
--BEGIN
--SET @intForecastWeeklyConsumption = 1
--END
If isnull(@intForecastWeeklyConsumptionUOMId,0) = 0
BEGIN
set @intForecastWeeklyConsumptionUOMId = @intUOMId
END
  
DECLARE @strUnitMeasure nvarchar(200)  
DECLARE @dtmFutureMonthsDate datetime  
DECLARE @dblContractSize int  
DECLARE @ysnIncludeInventoryHedge BIT
DECLARE @strRiskView nvarchar(200) 
DECLARE @strFutureMonth  nvarchar(15) ,@dblForecastWeeklyConsumption numeric(24,10)
declare @strParamFutureMonth nvarchar(12)  
SELECT @dblContractSize= convert(int,dblContractSize) FROM tblRKFutureMarket WHERE intFutureMarketId=@intFutureMarketId  
SELECT TOP 1 @dtmFutureMonthsDate=dtmFutureMonthsDate,@strParamFutureMonth=strFutureMonth FROM tblRKFuturesMonth WHERE intFutureMonthId=@intFutureMonthId  

SELECT TOP 1 @strUnitMeasure= strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId=@intUOMId  
DECLARE @intoldUnitMeasureId int 
SET @intoldUnitMeasureId = @intUOMId
SELECT @intUOMId=intCommodityUnitMeasureId FROM tblICCommodityUnitMeasure where intCommodityId=@intCommodityId and intUnitMeasureId=@intUOMId  
SELECT @ysnIncludeInventoryHedge = ysnIncludeInventoryHedge FROM tblRKCompanyPreference  
SELECT @strRiskView = strRiskView FROM tblRKCompanyPreference 

DECLARE @intForecastWeeklyConsumptionUOMId1 INT
SELECT @intForecastWeeklyConsumptionUOMId1 = intCommodityUnitMeasureId from tblICCommodityUnitMeasure 
                     WHERE intCommodityId=@intCommodityId and intUnitMeasureId=@intForecastWeeklyConsumptionUOMId  

SELECT @dblForecastWeeklyConsumption=isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(@intForecastWeeklyConsumptionUOMId1,@intUOMId,@intForecastWeeklyConsumption),1)
DECLARE @ListImported as Table (    
        intRowNumber int,
     Selection  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     PriceStatus  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     strFutureMonth  nvarchar(20) COLLATE Latin1_General_CI_AS,  
     strAccountNumber  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     dblNoOfContract  decimal(24,10),  
     strTradeNo  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     TransactionDate  datetime,  
     TranType  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     CustVendor nvarchar(200) COLLATE Latin1_General_CI_AS,       
     dblNoOfLot decimal(24,10),  
     dblQuantity decimal(24,10),
     intOrderByHeading int,
     intContractHeaderId int ,
     intFutOptTransactionHeaderId int       
     )  
---Roll Cost

DECLARE @RollCost as Table (      
     strFutMarketName  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     strCommodityCode  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     strFutureMonth  nvarchar(20) COLLATE Latin1_General_CI_AS,
     intFutureMarketId int,
     intCommodityId int,
     intFutureMonthId int,
     dblNoOfLot  numeric(24,10),  
     dblQuantity  numeric(24,10),  
     dblWtAvgOpenLongPosition  numeric(24,10),
     strTradeNo  nvarchar(100) COLLATE Latin1_General_CI_AS,
     intFutOptTransactionHeaderId int
     ) 
DECLARE @dtmCurrentDate datetime 
SET @dtmCurrentDate = getdate()

INSERT INTO @RollCost(strFutMarketName, strCommodityCode, strFutureMonth,intFutureMarketId,intCommodityId,intFutureMonthId,dblNoOfLot,dblQuantity,dblWtAvgOpenLongPosition,strTradeNo,intFutOptTransactionHeaderId)
SELECT strFutMarketName, strCommodityCode, strFutureMonth,intFutureMarketId,intCommodityId,intFutureMonthId,dblNoOfLot,dblQuantity,dblWtAvgOpenLongPosition,strInternalTradeNo,intFutOptTransactionHeaderId 
FROM  vyuRKRollCost 
WHERE intCommodityId=@intCommodityId and intFutureMarketId=@intFutureMarketId 
				    and isnull(intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(intBookId,0) else @intBookId end
       and isnull(intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(intSubBookId,0) else @intSubBookId end
and intLocationId=@intCompanyLocationId and CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= @dtmToDate

--To Purchase Value
     DECLARE @DemandFinal1 as Table (  
     dblQuantity  numeric(24,10),  
     intUOMId  int,    
     strPeriod  nvarchar(200),
       strItemName nvarchar(200),
       dtmPeriod datetime,
       intItemId int,
       strDescription nvarchar(200)
     )

       DECLARE @DemandQty as Table (  
     intRowNumber int identity(1,1),  
     dblQuantity  numeric(24,10),  
     intUOMId  int,  
     dtmPeriod  datetime,  
     strPeriod  nvarchar(200),
       strItemName nvarchar(200),
       intItemId int,
       strDescription nvarchar(200)
     )  

DECLARE @DemandFinal as Table (  
     intRowNumber int identity(1,1),  
     dblQuantity  numeric(24,10),  
     intUOMId  int,  
     dtmPeriod  datetime,  
     strPeriod  nvarchar(200),
       strItemName nvarchar(200),
       intItemId int,
       strDescription nvarchar(200)
     )


IF EXISTS(SELECT TOP 1 * FROM tblRKStgBlendDemand WHERE  dtmImportDate < @dtmToDate )
BEGIN
	INSERT INTO @DemandQty
	SELECT dblQuantity,d.intUOMId,CONVERT(DATETIME,'01 '+strPeriod) dtmPeriod,strPeriod,strItemName,d.intItemId,c.strDescription FROM tblRKStgBlendDemand d
	JOIN tblICItem i on i.intItemId=d.intItemId and d.dblQuantity > 0
	JOIN tblICCommodityAttribute c on c.intCommodityId = i.intCommodityId
	JOIN tblRKCommodityMarketMapping m on m.intCommodityId=c.intCommodityId and   intProductTypeId=intCommodityAttributeId
						 AND intCommodityAttributeId in (select Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS from [dbo].[fnSplitString](m.strCommodityAttributeId, ','))
	JOIN tblRKFutureMarket fm on fm.intFutureMarketId=m.intFutureMarketId
	WHERE m.intCommodityId=@intCommodityId and fm.intFutureMarketId = @intFutureMarketId 
END
ELSE

BEGIN
	INSERT INTO @DemandQty
	SELECT dblQuantity,d.intUOMId,CONVERT(DATETIME,'01 '+strPeriod) dtmPeriod,strPeriod,strItemName,d.intItemId,c.strDescription FROM tblRKArchBlendDemand d
	JOIN tblICItem i on i.intItemId=d.intItemId and d.dblQuantity > 0
	JOIN tblICCommodityAttribute c on c.intCommodityId = i.intCommodityId
	JOIN tblRKCommodityMarketMapping m on m.intCommodityId=c.intCommodityId and   intProductTypeId=intCommodityAttributeId
						 AND intCommodityAttributeId in (select Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS from [dbo].[fnSplitString](m.strCommodityAttributeId, ','))
	JOIN tblRKFutureMarket fm on fm.intFutureMarketId=m.intFutureMarketId
	WHERE m.intCommodityId=@intCommodityId and fm.intFutureMarketId = @intFutureMarketId and d.dtmImportDate = (select top 1 dtmImportDate tblRKArchBlendDemand 
																												where dtmImportDate<=@dtmToDate order by  dtmImportDate desc)
END

DECLARE @intRowNumber INT
DECLARE @dblQuantity  numeric(24,10)
DECLARE @intUOMId1  int
DECLARE @dtmPeriod1  datetime
DECLARE @strFutureMonth1 nvarchar(20)
DECLARE @strItemName nvarchar(200)
DECLARE @intItemId int
DECLARE @strDescription nvarchar(200)

SELECT @intRowNumber = min(intRowNumber) from @DemandQty
WHILE @intRowNumber >0
BEGIN
SELECT @strFutureMonth1 = null, @dtmPeriod1 = null,@intUOMId1 = null , @dtmPeriod1 = null,@strItemName = null,@intItemId = null,@strDescription = null

SELECT @dblQuantity=dblQuantity,@intUOMId1=intUOMId,@dtmPeriod1=dtmPeriod,@strItemName=strItemName,@intItemId=intItemId,@strDescription=strDescription
FROM @DemandQty WHERE intRowNumber=@intRowNumber

SELECT @strFutureMonth1=strFutureMonth FROM tblRKFuturesMonth fm
JOIN tblRKCommodityMarketMapping mm on mm.intFutureMarketId= fm.intFutureMarketId 
WHERE @dtmPeriod1=CONVERT(DATETIME,'01 '+strFutureMonth) 
AND fm.intFutureMarketId = @intFutureMarketId and mm.intCommodityId=@intCommodityId

IF @strFutureMonth1 IS NULL
              SELECT top 1 @strFutureMonth1=strFutureMonth FROM tblRKFuturesMonth fm
              JOIN tblRKCommodityMarketMapping mm on mm.intFutureMarketId= fm.intFutureMarketId 
              WHERE  CONVERT(DATETIME,'01 '+strFutureMonth) > @dtmPeriod1  
              AND fm.intFutureMarketId = @intFutureMarketId and mm.intCommodityId=@intCommodityId
              order by CONVERT(DATETIME,'01 '+strFutureMonth) 
                       
       INSERT INTO @DemandFinal1(dblQuantity,intUOMId,strPeriod,strItemName,intItemId,strDescription)
       SELECT @dblQuantity,@intUOMId1,@strFutureMonth1,@strItemName,@intItemId,@strDescription

SELECT @intRowNumber= min(intRowNumber) FROM @DemandQty WHERE intRowNumber > @intRowNumber
END

INSERT INTO @DemandFinal
SELECT sum(dblQuantity) as dblQuantity,intUOMId,CONVERT(DATETIME,'01 '+strPeriod) dtmPeriod,strPeriod,strItemName,intItemId,strDescription from  @DemandFinal1
GROUP BY intUOMId, strPeriod,strItemName,intItemId,strDescription ORDER BY CONVERT(DATETIME,'01 '+strPeriod)

-- END


DECLARE @ListFinal as Table (  
                            intRowNumber int,
                            strGroup nvarchar(250),
                            Selection  nvarchar(200) COLLATE Latin1_General_CI_AS,  
                            PriceStatus  nvarchar(200) COLLATE Latin1_General_CI_AS,  
                            strFutureMonth  nvarchar(20) COLLATE Latin1_General_CI_AS,  
                            strAccountNumber  nvarchar(200) COLLATE Latin1_General_CI_AS,  
                            dblNoOfContract  decimal(24,10),  
                            strTradeNo  nvarchar(200) COLLATE Latin1_General_CI_AS,  
                            TransactionDate  datetime,  
                            TranType  nvarchar(200) COLLATE Latin1_General_CI_AS,  
                            CustVendor nvarchar(200) COLLATE Latin1_General_CI_AS,       
                            dblNoOfLot decimal(24,10),  
                            dblQuantity decimal(24,10),
                                             intOrderByHeading int,
                            intContractHeaderId int ,
                            intFutOptTransactionHeaderId int           
     )  

DECLARE @ContractTransaction as Table (  
     strFutureMonth  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     strAccountNumber  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     dblNoOfContract  decimal(24,10), 
     strTradeNo  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     TransactionDate  datetime,  
     TranType  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     CustVendor nvarchar(200) COLLATE Latin1_General_CI_AS,       
     dblNoOfLot decimal(24,10),  
     dblQuantity decimal(24,10),
       intContractHeaderId int,  
        intFutOptTransactionHeaderId int,     
     intPricingTypeId int,
     strContractType nvarchar(200) COLLATE Latin1_General_CI_AS,
       intCommodityId int,
       intCompanyLocationId  int,
       intFutureMarketId  int,
       dtmFutureMonthsDate  datetime,
       ysnExpired  bit  )

DECLARE @PricedContractList AS TABLE (
       strFutureMonth NVARCHAR(max) COLLATE Latin1_General_CI_AS
       ,strAccountNumber NVARCHAR(max) COLLATE Latin1_General_CI_AS
       ,dblNoOfContract DECIMAL(24, 10)
       ,strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
       ,TransactionDate DATETIME
       ,TranType NVARCHAR(max) COLLATE Latin1_General_CI_AS
       ,CustVendor NVARCHAR(max) COLLATE Latin1_General_CI_AS
       ,dblNoOfLot DECIMAL(24, 10)
       ,dblQuantity DECIMAL(24, 10)
       ,intContractHeaderId INT
       ,intFutOptTransactionHeaderId INT
       ,intPricingTypeId INT
       ,strContractType NVARCHAR(max) COLLATE Latin1_General_CI_AS
       ,intCommodityId INT
       ,intCompanyLocationId INT
       ,intFutureMarketId INT
       ,dtmFutureMonthsDate DATETIME
       ,ysnExpired BIT
       ,ysnDeltaHedge BIT
       ,intContractStatusId INT
       ,dblDeltaPercent DECIMAL(24, 10)
       ,intContractDetailId INT
       ,intCommodityUnitMeasureId INT
       ,dblRatioContractSize DECIMAL(24, 10)
       ,dblRatioQty DECIMAL(24, 10)
       )

INSERT INTO @PricedContractList
SELECT fm.strFutureMonth
       ,strContractType + ' - ' + case when @strPositionBy= 'Product Type' then isnull(ca.strDescription, '') else isnull(cv.strEntityName, '') end AS strAccountNumber
       ,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, @intUOMId, CASE WHEN @ysnIncludeInventoryHedge = 0 THEN isnull(dblBalance, 0) ELSE dblDetailQuantity END) AS dblNoOfContract
       ,LEFT(strContractType, 1) + ' - ' + strContractNumber + ' - ' + convert(NVARCHAR, intContractSeq) AS strTradeNo
       ,dtmStartDate AS TransactionDate
       ,strContractType AS TranType
       ,strEntityName AS CustVendor
       ,dblNoOfLots AS dblNoOfLot
       ,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, @intUOMId, CASE WHEN @ysnIncludeInventoryHedge = 0 THEN isnull(dblBalance, 0) ELSE dblDetailQuantity END) AS dblQuantity
       ,cv.intContractHeaderId
       ,NULL AS intFutOptTransactionHeaderId
       ,intPricingTypeId
       ,cv.strContractType
       ,cv.intCommodityId
       ,cv.intCompanyLocationId
       ,cv.intFutureMarketId
       ,dtmFutureMonthsDate
       ,ysnExpired
       ,isnull(pl.ysnDeltaHedge, 0) ysnDeltaHedge
       ,intContractStatusId
       ,dblDeltaPercent,cv.intContractDetailId,um.intCommodityUnitMeasureId
,dbo.fnCTConvertQuantityToTargetCommodityUOM(um2.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,ffm.dblContractSize) dblRatioContractSize
       ,dblRatioQty
FROM vyuRKRiskPositionContractDetail cv
JOIN tblRKFutureMarket ffm ON ffm.intFutureMarketId = cv.intFutureMarketId
--JOIN tblICCommodityUnitMeasure um1 ON um1.intCommodityId = cv.intCommodityId AND um1.intUnitMeasureId = ffm.intUnitMeasureId
JOIN tblICCommodityUnitMeasure um2 ON um2.intUnitMeasureId = ffm.intUnitMeasureId and um2.intCommodityId = cv.intCommodityId
JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = cv.intFutureMonthId
JOIN tblICItemUOM u ON cv.intItemUOMId = u.intItemUOMId
JOIN tblICItem ic ON ic.intItemId = cv.intItemId
LEFT JOIN tblICCommodityProductLine pl ON ic.intCommodityId = pl.intCommodityId AND ic.intProductLineId = pl.intCommodityProductLineId
LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = cv.intCommodityId AND um.intUnitMeasureId = cv.intUnitMeasureId
WHERE cv.intCommodityId = @intCommodityId AND cv.intFutureMarketId = @intFutureMarketId AND cv.intContractStatusId NOT IN (2, 3)       
       and isnull(intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(intBookId,0) else @intBookId end
       and isnull(intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(intSubBookId,0) else @intSubBookId end
	   and CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= @dtmToDate

INSERT INTO @ContractTransaction ( strFutureMonth,strAccountNumber , dblNoOfContract , strTradeNo,TransactionDate ,TranType,
CustVendor,  dblNoOfLot, dblQuantity,intContractHeaderId ,intFutOptTransactionHeaderId ,intPricingTypeId ,strContractType ,intCommodityId ,
intCompanyLocationId  ,intFutureMarketId  ,dtmFutureMonthsDate  ,ysnExpired )  

SELECT strFutureMonth,strAccountNumber , dblNoOfContract , strTradeNo,TransactionDate ,TranType,
CustVendor,  dblNoOfLot, dblQuantity,intContractHeaderId ,intFutOptTransactionHeaderId ,intPricingTypeId ,strContractType ,intCommodityId ,
intCompanyLocationId  ,intFutureMarketId  ,dtmFutureMonthsDate  ,ysnExpired
--INTO #ContractTransaction
FROM (
       SELECT strFutureMonth
              ,strAccountNumber
              ,case when intPricingTypeId=8 then  dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblRatioQty ) else dblNoOfContract end dblNoOfContract
              ,strTradeNo
              ,TransactionDate
              ,TranType
              ,CustVendor
              ,dblNoOfLot
              ,case when intPricingTypeId=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, dblNoOfLot) else dblQuantity end dblQuantity
              ,intContractHeaderId
              ,intFutOptTransactionHeaderId
              ,intPricingTypeId
              ,strContractType
              ,intCommodityId
              ,intCompanyLocationId
              ,intFutureMarketId
              ,dtmFutureMonthsDate
              ,ysnExpired
       FROM @PricedContractList cv
       WHERE cv.intPricingTypeId = 1 AND ysnDeltaHedge = 0
       
       UNION
       
       --Parcial Priced
       SELECT strFutureMonth
              ,strAccountNumber
              ,case when intPricingTypeId=8 then  dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (dblRatioQty/dblNoOfLot)* dblFixedLots) else dblFixedQty end AS dblNoOfContract
              ,strTradeNo
              ,TransactionDate
              ,TranType
              ,CustVendor
              ,dblFixedLots dblNoOfLot
              ,case when intPricingTypeId=8 then  dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (dblRatioQty/dblNoOfLot)*dblFixedLots) else dblFixedQty end dblFixedQty
              ,intContractHeaderId
              ,intFutOptTransactionHeaderId
              ,1 intPricingTypeId
              ,strContractType
              ,intCommodityId
              ,intCompanyLocationId
              ,intFutureMarketId
              ,dtmFutureMonthsDate
              ,ysnExpired          
       FROM (
              SELECT strFutureMonth
                     ,strAccountNumber
                     ,0 AS dblNoOfContract
                     ,strTradeNo
                     ,TransactionDate
                     ,TranType
                     ,CustVendor
                     ,dblNoOfLot
                     ,dblQuantity
                     ,intContractHeaderId
                     ,intFutOptTransactionHeaderId
                     ,intPricingTypeId
                     ,strContractType
                     ,intCommodityId
                     ,intCompanyLocationId
                     ,intFutureMarketId
                     ,dtmFutureMonthsDate
                     ,ysnExpired,dblRatioQty
                     ,isnull((
                                  SELECT sum(dblLotsFixed) dblNoOfLots
                                  FROM tblCTPriceFixation pf
                                  WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId
                                  ), 0) dblFixedLots
                     ,isnull((
                                  SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, sum(dblQuantity)) dblQuantity
                                  FROM tblCTPriceFixation pf
                                  JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
                                  WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId
                                  ), 0) dblFixedQty,intCommodityUnitMeasureId
                                  ,dblRatioContractSize
              FROM @PricedContractList cv
              WHERE cv.intContractStatusId <> 3 AND intPricingTypeId <> 1 AND isnull(ysnDeltaHedge, 0) =0
              ) t
       WHERE isnull(dblNoOfLot, 0) - isnull(dblFixedLots, 0) <> 0
       
       UNION
       
       --Parcial UnPriced
       SELECT strFutureMonth
              ,strAccountNumber
              ,case when intPricingTypeId=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId,
                           (((dblRatioQty/dblNoOfLot)*isnull(dblNoOfLot, 0)) - ((dblRatioQty/dblNoOfLot)*isnull(dblFixedLots, 0))) ) else dblQuantity - dblFixedQty end AS dblNoOfContract
              ,strTradeNo
              ,TransactionDate
              ,TranType
              ,CustVendor
              ,isnull(dblNoOfLot, 0) - isnull(dblFixedLots, 0) dblNoOfLot
              ,case when intPricingTypeId=8 then dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId,((dblRatioQty/dblNoOfLot)*isnull(dblNoOfLot, 0) - (dblRatioQty/dblNoOfLot)*isnull(dblFixedLots, 0))) else dblQuantity - dblFixedQty end dblQuantity
              ,intContractHeaderId
              ,intFutOptTransactionHeaderId
              ,2 intPricingTypeId
              ,strContractType
              ,intCommodityId
              ,intCompanyLocationId
              ,intFutureMarketId
              ,dtmFutureMonthsDate
              ,ysnExpired
       FROM (
              SELECT strFutureMonth
                     ,strAccountNumber
                     ,0 AS dblNoOfContract
                     ,strTradeNo
                     ,TransactionDate
                     ,strContractType AS TranType
                     ,CustVendor
                     ,dblNoOfLot
                     ,dblQuantity
                     ,cv.intContractHeaderId
                     ,NULL AS intFutOptTransactionHeaderId
                     ,cv.intPricingTypeId
                     ,cv.strContractType
                     ,cv.intCommodityId
                     ,cv.intCompanyLocationId
                     ,cv.intFutureMarketId
                     ,dtmFutureMonthsDate
                     ,ysnExpired,dblRatioQty
                     ,isnull((
                                  SELECT sum(dblLotsFixed) dblNoOfLots
                                  FROM tblCTPriceFixation pf
                                  WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId
                                  ), 0) dblFixedLots
                     ,isnull((
                                  SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, sum(pd.dblQuantity)) dblQuantity
                                  FROM tblCTPriceFixation pf
                                  JOIN tblCTPriceFixationDetail pd ON pf.intPriceFixationId = pd.intPriceFixationId
                                  WHERE pf.intContractHeaderId = cv.intContractHeaderId AND pf.intContractDetailId = cv.intContractDetailId
                                  ), 0) dblFixedQty
                     ,isnull(dblDeltaPercent,0) dblDeltaPercent,intCommodityUnitMeasureId,dblRatioContractSize
              FROM @PricedContractList cv
              WHERE cv.intContractStatusId <> 3 AND intPricingTypeId <> 1 AND isnull(ysnDeltaHedge, 0) =0
              ) t
       WHERE isnull(dblNoOfLot, 0) - isnull(dblFixedLots, 0) <> 0
       ) t1
WHERE dblNoOfContract <> 0 

INSERT INTO @ListFinal (intRowNumber,strGroup ,Selection , PriceStatus,strFutureMonth,  strAccountNumber,  dblNoOfContract, strTradeNo , 
TransactionDate, TranType, CustVendor,  dblNoOfLot,  dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)
SELECT
1 intRowNumber,'1.Outright Coverage','Outright Coverage' Selection,
              '1.Priced / Outright - (Outright position)' PriceStatus,'Previous' strFutureMonth,strAccountNumber,  
              case when strContractType='Purchase' then dblNoOfContract else -(abs(dblNoOfContract)) end as dblNoOfContract,
              strTradeNo,TransactionDate,TranType,CustVendor,
              case when strContractType='Purchase' then -(abs(dblNoOfLot)) else dblNoOfLot end dblNoOfLot,  
              case when strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end as dblQuantity, 
              1 intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ContractTransaction    
    WHERE intPricingTypeId =1 AND dtmFutureMonthsDate < @dtmFutureMonthsDate AND intCommodityId=@intCommodityId  
    AND intCompanyLocationId= CASE WHEN isnull(@intCompanyLocationId,0)=0 then intCompanyLocationId else @intCompanyLocationId end
    AND intFutureMarketId=@intFutureMarketId AND ISNULL(dblNoOfContract,0)<> 0 
        
INSERT INTO @ListFinal (intRowNumber,strGroup ,Selection , PriceStatus,strFutureMonth,  strAccountNumber,  dblNoOfContract, strTradeNo , 
TransactionDate, TranType, CustVendor,  dblNoOfLot,  dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)
SELECT
1 intRowNumber,'1.Outright Coverage','Outright Coverage' Selection,'1.Priced / Outright - (Outright position)' PriceStatus,strFutureMonth,strAccountNumber,  
    case when strContractType='Purchase' then dblNoOfContract else -(abs(dblNoOfContract)) end as dblNoOfContract,
       strTradeNo,TransactionDate,TranType,CustVendor,
    case when strContractType='Purchase' then -(abs(dblNoOfLot)) else dblNoOfLot end dblNoOfLot,  
    case when strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end as dblQuantity, 
       1 intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ContractTransaction    
    WHERE intPricingTypeId =1 AND dtmFutureMonthsDate >= @dtmFutureMonthsDate AND intCommodityId=@intCommodityId  
AND intCompanyLocationId= CASE WHEN isnull(@intCompanyLocationId,0)=0 then intCompanyLocationId else @intCompanyLocationId end
AND intFutureMarketId=@intFutureMarketId AND ISNULL(dblNoOfContract,0)<> 0  

INSERT INTO @ListFinal (intRowNumber,strGroup ,Selection , PriceStatus,strFutureMonth,  strAccountNumber,  dblNoOfContract, strTradeNo , 
TransactionDate, TranType, CustVendor,  dblNoOfLot,  dblQuantity,intOrderByHeading)
SELECT 1 intRowNumber,'1.Outright Coverage','Outright Coverage' Selection,'1.Priced / Outright - (Outright position)' PriceStatus,
              @strParamFutureMonth strFutureMonth,strAccountNumber,sum(dblNoOfLot) dblNoOfLot,null,getdate() TransactionDate,'Inventory' TranType,
              null, 0.0 ,sum(dblNoOfLot) dblQuantity,1
FROM (
  SELECT distinct    
  'Purchase'+' - '+isnull(c.strDescription,'') as strAccountNumber,
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,t.dblQuantity) dblNoOfLot
  FROM vyuRKGetInventoryValuation t  
   join tblICItem ic on t.intItemId=ic.intItemId 
  JOIN tblICCommodityAttribute c on c.intCommodityAttributeId=ic.intProductTypeId    
  JOIN tblRKCommodityMarketMapping m on m.intCommodityId=c.intCommodityId and m.intFutureMarketId =@intFutureMarketId and  ic.intProductTypeId=intCommodityAttributeId
                     AND intCommodityAttributeId in (SELECT LTRIM(RTRIM(Item)) COLLATE Latin1_General_CI_AS FROM [dbo].[fnSplitString](m.strCommodityAttributeId, ','))
  join tblICItemLocation il on il.intItemId=ic.intItemId
  join tblICItemUOM i on il.intItemId=i.intItemId and i.ysnStockUnit=1
  JOIN tblICCommodityUnitMeasure um on um.intCommodityId=@intCommodityId and um.intUnitMeasureId=i.intUnitMeasureId  
  JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=il.intLocationId   
  WHERE ic.intCommodityId=@intCommodityId  and m.intFutureMarketId=@intFutureMarketId 
        AND cl.intCompanyLocationId= CASE WHEN ISNULL(@intCompanyLocationId,0)=0 THEN cl.intCompanyLocationId ELSE @intCompanyLocationId END
		and convert(DATETIME, CONVERT(VARCHAR(10), t.dtmCreated, 110), 110)<=convert(datetime,@dtmToDate) 
              )t2
GROUP BY strAccountNumber

INSERT INTO @ListFinal (intRowNumber,strGroup ,Selection , PriceStatus,strFutureMonth,  strAccountNumber,  dblNoOfContract, strTradeNo , 
TransactionDate, TranType, CustVendor,  dblNoOfLot,  dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)
SELECT intRowNumber,grpname,Selection,PriceStatus,strFutureMonth,strAccountNumber,  
  dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intUOMId,dblQuantity) as dblNoOfContract,  
  strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfContract as 
  dblNoOfLot, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intUOMId,dblQuantity) dblQuantity
  ,2 intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId  from  
(  
SELECT DISTINCT 2 intRowNumber,'1.Outright Coverage' grpname,'Outright Coverage' Selection,'2.Terminal Position' PriceStatus, 
  strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,
  intOpenContract as dblNoOfContract,  
  ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
  intOpenContract*@dblContractSize dblQuantity,um.intCommodityUnitMeasureId  
  , null as intContractHeaderId,ft.intFutOptTransactionHeaderId 
FROM vyuRKGetOpenContract tc
JOIN tblRKFutOptTransaction ft  on tc.intFutOptTransactionId=ft.intFutOptTransactionId
JOIN tblRKFutureMarket mar on mar.intFutureMarketId=ft.intFutureMarketId and ft.strStatus='Filled'
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  and ft.intInstrumentTypeId = 1  and ft.intCommodityId=@intCommodityId 
                                                       and ft.intFutureMarketId=@intFutureMarketId
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
JOIN tblEMEntity e on e.intEntityId=ft.intEntityId 
JOIN tblICCommodityUnitMeasure um on um.intCommodityId=ft.intCommodityId and um.intUnitMeasureId=mar.intUnitMeasureId
WHERE  ft.intCommodityId=@intCommodityId AND ft.intFutureMarketId=@intFutureMarketId   
AND intLocationId= case when isnull(@intCompanyLocationId,0)=0 then intLocationId else @intCompanyLocationId end 
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate    
AND isnull(intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(intBookId,0) else @intBookId end
AND isnull(intSubBookId,0)= case when isnull(@intSubBookId,0)=0 then isnull(intSubBookId,0) else @intSubBookId end
and CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110) <= @dtmToDate
)t 
INSERT INTO @ListFinal (intRowNumber,strGroup ,Selection , PriceStatus,strFutureMonth,  strAccountNumber,  dblNoOfContract, strTradeNo , 
TransactionDate, TranType, CustVendor,  dblNoOfLot,  dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)

SELECT 4 intRowNumber,'1.Outright Coverage','Market coverage'  Selection,
       '3.Market coverage' PriceStatus,strFutureMonth,'Market Coverage' strAccountNumber,  
    CONVERT(DOUBLE PRECISION,isnull(dblNoOfContract,0.0)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,4,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListFinal where intRowNumber in(1,2) and strFutureMonth <> 'Previous' 
 UNION
SELECT 4 intRowNumber,'1.Outright Coverage','Market coverage'  Selection,
       '3.Market coverage' PriceStatus,@strParamFutureMonth,'Market Coverage' strAccountNumber,  
    CONVERT(DOUBLE PRECISION,isnull(dblNoOfContract,0.0)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,4,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListFinal where intRowNumber in(1)  and strFutureMonth = 'Previous' 

if (isnull(@intForecastWeeklyConsumption,0) <> 0)
BEGIN
INSERT INTO @ListFinal (intRowNumber,strGroup ,Selection , PriceStatus,strFutureMonth,  strAccountNumber,  dblNoOfContract, strTradeNo , 
TransactionDate, TranType, CustVendor,  dblNoOfLot,  dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)
SELECT
5 intRowNumber,'1.Outright Coverage','Market Coverage' Selection,'4.Market Coverage(Weeks)' PriceStatus,strFutureMonth,strAccountNumber,  
    case when isnull(@dblForecastWeeklyConsumption,0)=0 then 0 else 
	CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal))/@dblForecastWeeklyConsumption end as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,5,intContractHeaderId,intFutOptTransactionHeaderId    FROM @ListFinal WHERE intRowNumber in(4)
END
---- Futures Required

INSERT INTO @ListFinal (intRowNumber,strGroup ,Selection , PriceStatus,strFutureMonth,  strAccountNumber,  dblNoOfContract, strTradeNo , 
TransactionDate, TranType, CustVendor,  dblNoOfLot,  dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)

SELECT intRowNumber,strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,ROUND(dblNoOfContract,@intDecimal) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,
              dblNoOfLot, dblQuantity,6,intContractHeaderId,intFutOptTransactionHeaderId FROM(  
  
  SELECT  DISTINCT 6 intRowNumber,'2.Futures Required' strGroup,'Futures Required' Selection,'1.Unpriced - (Balance to be Priced)' PriceStatus,
  'Previous' as strFutureMonth, strAccountNumber, abs(case when strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end)  as dblNoOfContract,
  strTradeNo, TransactionDate,  TranType, CustVendor,  
  case when strContractType='Purchase' then -(abs(dblNoOfLot)) else dblNoOfLot end dblNoOfLot,  
  case when strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end as dblQuantity, 
  intContractHeaderId,
  NULL as intFutOptTransactionHeaderId  
  FROM @ContractTransaction 
  WHERE ysnExpired=0 and intPricingTypeId <> 1 AND dtmFutureMonthsDate < @dtmFutureMonthsDate AND intCommodityId=@intCommodityId  
   AND intCompanyLocationId= CASE WHEN isnull(@intCompanyLocationId,0)=0 then intCompanyLocationId else @intCompanyLocationId end
   AND intFutureMarketId=@intFutureMarketId   
      
  UNION    
  SELECT DISTINCT 6 intRowNumber,'2.Futures Required' strGroup,'Futures Required' Selection,'1.Unpriced - (Balance to be Priced)' PriceStatus,
  strFutureMonth,  
  strAccountNumber,  
  abs(case when strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end)  as dblNoOfContract,  
  strTradeNo, 
  TransactionDate,  
  TranType, 
  CustVendor,  
  case when strContractType='Purchase' then -(abs(dblNoOfLot)) else dblNoOfLot end dblNoOfLot,  
  case when strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end as dblQuantity, 
  intContractHeaderId,
  null as intFutOptTransactionHeaderId    
  FROM @ContractTransaction 
  WHERE ysnExpired=0 AND intPricingTypeId <> 1   
     AND intCommodityId=@intCommodityId AND intCompanyLocationId= CASE WHEN ISNULL(@intCompanyLocationId,0)=0 THEN intCompanyLocationId ELSE @intCompanyLocationId end 
     AND intFutureMarketId=@intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1 

INSERT INTO @ListFinal (intRowNumber,strGroup ,Selection , PriceStatus,strFutureMonth,  strAccountNumber,  dblNoOfContract, strTradeNo , 
TransactionDate, TranType, CustVendor,  dblNoOfLot,  dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)    

SELECT  DISTINCT 7 intRowNumber,'2.Futures Required','Futures Required' as Selection,'2.To Purchase' as PriceStatus,'Previous' as strFutureMonth,strDescription as strAccountNumber,
  dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,u.intUnitMeasureId,@intoldUnitMeasureId,isnull(dblQuantity,0)) as dblNoOfContract,strItemName,dtmPeriod,null,null,
    round(dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,u.intUnitMeasureId,@intoldUnitMeasureId,isnull(dblQuantity,0)) 
              / dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,u.intUnitMeasureId,@intoldUnitMeasureId,@dblContractSize),0) as dblNoOfLot  ,
dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,u.intUnitMeasureId,@intoldUnitMeasureId,isnull(dblQuantity,0))as dblQuantity,8,null,null
  FROM @DemandFinal cv  
  JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=@intFutureMarketId and  CONVERT(DATETIME,'01 '+strPeriod)< @dtmFutureMonthsDate 
  JOIN tblICCommodityUnitMeasure um1 on um1.intCommodityId=@intCommodityId and um1.intUnitMeasureId=ffm.intUnitMeasureId
   JOIN tblICItemUOM u on cv.intUOMId=u.intItemUOMId  
ORDER BY dtmPeriod ASC

INSERT INTO @ListFinal (intRowNumber,strGroup ,Selection , PriceStatus,strFutureMonth,  strAccountNumber,  dblNoOfContract, strTradeNo , 
TransactionDate, TranType, CustVendor,  dblNoOfLot,  dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)    

SELECT  DISTINCT 7 intRowNumber,'2.Futures Required','Futures Required' as Selection,'2.To Purchase' as PriceStatus,strPeriod as strFutureMonth,strDescription as strAccountNumber,
  dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,u.intUnitMeasureId,@intoldUnitMeasureId,isnull(dblQuantity,0)) as dblNoOfContract,strItemName,dtmPeriod,null,null,
    round(dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,u.intUnitMeasureId,@intoldUnitMeasureId,isnull(dblQuantity,0)) 
              / dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,u.intUnitMeasureId,@intoldUnitMeasureId,@dblContractSize),0) as dblNoOfLot  ,
dbo.fnCTConvertQtyToTargetCommodityUOM(@intCommodityId,u.intUnitMeasureId,@intoldUnitMeasureId,isnull(dblQuantity,0))as dblQuantity,8,null,null
  FROM @DemandFinal cv  
  JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=@intFutureMarketId and  CONVERT(DATETIME,'01 '+strPeriod)>= @dtmFutureMonthsDate 
  JOIN tblICCommodityUnitMeasure um1 on um1.intCommodityId=@intCommodityId and um1.intUnitMeasureId=ffm.intUnitMeasureId
   JOIN tblICItemUOM u on cv.intUOMId=u.intItemUOMId  
ORDER BY dtmPeriod ASC

INSERT INTO @ListFinal (intRowNumber,strGroup ,Selection , PriceStatus,strFutureMonth,  strAccountNumber,  dblNoOfContract, strTradeNo , 
TransactionDate, TranType, CustVendor,  dblNoOfLot,  dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)

SELECT
8 intRowNumber,'2.Futures Required','Futures Required' Selection,'3.Terminal position' PriceStatus,strFutureMonth,strAccountNumber,  
dblNoOfContract as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
dblQuantity,7,intContractHeaderId,intFutOptTransactionHeaderId  FROM @ListFinal WHERE intRowNumber in(2)




INSERT INTO @ListFinal (intRowNumber,strGroup ,Selection , PriceStatus,strFutureMonth,  strAccountNumber,  dblNoOfContract, dblNoOfLot,  dblQuantity,intOrderByHeading)
SELECT 9 intRowNumber,'2.Futures Required','Futures Required' Selection,'4.Net Position' PriceStatus,strFutureMonth,'Net Position',sum(dblNoOfContract),sum(dblNoOfLot),sum(dblQuantity),9 intOrderByHeading  
FROM(
SELECT @strParamFutureMonth strFutureMonth,strAccountNumber, -abs(dblQuantity) as dblNoOfContract,dblNoOfLot, dblQuantity  FROM @ListFinal WHERE intRowNumber in(7) and strFutureMonth = 'Previous'

UNION ALL

SELECT strFutureMonth,strAccountNumber, -abs(dblQuantity) as dblNoOfContract,dblNoOfLot, dblQuantity FROM @ListFinal WHERE intRowNumber in(6) and strFutureMonth <> 'Previous'

UNION ALL

SELECT @strParamFutureMonth,strAccountNumber, abs(dblQuantity) as dblNoOfContract,dblNoOfLot, dblQuantity FROM @ListFinal WHERE intRowNumber in(6) and strFutureMonth = 'Previous'

UNION ALL

SELECT strFutureMonth,strAccountNumber,dblQuantity as dblNoOfContract,dblNoOfLot, dblQuantity FROM @ListFinal WHERE intRowNumber in(2) 

UNION ALL

SELECT strFutureMonth,strAccountNumber,-abs(dblQuantity) as dblNoOfContract,dblNoOfLot,dblQuantity FROM @ListFinal WHERE intRowNumber in(7) and strFutureMonth <> 'Previous' 
)t group by strFutureMonth



INSERT INTO @ListFinal (intRowNumber,strGroup ,Selection , PriceStatus,strFutureMonth,  strAccountNumber,  dblNoOfContract, strTradeNo , 
TransactionDate, TranType, CustVendor,  dblNoOfLot,  dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)

SELECT 10 intRowNumber,'2.Futures Required',Selection,PriceStatus,strFutureMonth,strAccountNumber,(dblQuantity)/sum(dblNoOfLot) over(PARTITION by strFutureMonth) as dblNoOfContract,
strTradeNo,getdate() TransactionDate,null,null,dblNoOfLot, dblQuantity,10,null,intFutOptTransactionHeaderId FROM  
(  
SELECT DISTINCT 'Futures Required' as Selection,'5.Avg Long Price' as PriceStatus,  
  ft.strFutureMonth, 'Avg Long Price' as strAccountNumber,
   dblWtAvgOpenLongPosition as dblNoOfContract,dblNoOfLot,dblQuantity*dblNoOfLot dblQuantity,strTradeNo,intFutOptTransactionHeaderId
FROM @RollCost ft
WHERE  ft.intCommodityId=@intCommodityId and intFutureMarketId=@intFutureMarketId
 and CONVERT(DATETIME,'01 '+ ft.strFutureMonth) >= CONVERT(DATETIME,'01 '+ @strParamFutureMonth))t  
 
INSERT INTO @ListFinal (intRowNumber,strGroup ,Selection , PriceStatus,strFutureMonth,  strAccountNumber,  dblNoOfContract, strTradeNo , 
TransactionDate, TranType, CustVendor,  dblNoOfLot,  dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)
SELECT 11 ,strGroup,Selection ,  
                            PriceStatus  ,  
                            'Total' ,  
                            strAccountNumber ,  
                            dblNoOfContract,  
                            strTradeNo,  
                            TransactionDate  ,  
                            TranType,  
                            CustVendor,       
                            dblNoOfLot ,  
                            dblQuantity ,
                           intOrderByHeading ,
                           intContractHeaderId ,
                           intFutOptTransactionHeaderId  from @ListFinal where strAccountNumber<> 'Avg Long Price'
                                             ORDER BY intRowNumber, CASE WHEN  strFutureMonth not in('Previous','Total') THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC

INSERT INTO @ListFinal (intRowNumber,strGroup ,Selection , PriceStatus,strFutureMonth,  strAccountNumber,  dblNoOfContract, strTradeNo , 
TransactionDate, TranType, CustVendor,  dblNoOfLot,  dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)

SELECT 11 intRowNumber,strGroup,Selection ,  
            PriceStatus  ,  
            'Total' strFutureMonth,  
            strAccountNumber ,  
            sum(dblQuantity)/sum(dblNoOfLot) dblNoOfContract,  
            '' strTradeNo,  
            '' TransactionDate  ,  
            '' TranType,  
            '' CustVendor,       
            sum(dblNoOfLot) dblNoOfLot ,  
            sum(dblQuantity) dblQuantity ,
            null intOrderByHeading ,
            null intContractHeaderId ,
             null intFutOptTransactionHeaderId  from @ListFinal where strAccountNumber = 'Avg Long Price'               
              
       GROUP BY strGroup,Selection,PriceStatus,strAccountNumber
       

DECLARE @MonthOrder as Table (  
     intRowNumber1 int identity(1,1),  
     intRowNumber int,
       strGroup  nvarchar(200) COLLATE Latin1_General_CI_AS, 
     Selection  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     PriceStatus  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     strFutureMonth  nvarchar(20) COLLATE Latin1_General_CI_AS,  
     strAccountNumber  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     dblNoOfContract  decimal(24,10),  
     strTradeNo  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     TransactionDate  datetime,  
     TranType  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     CustVendor nvarchar(200) COLLATE Latin1_General_CI_AS,       
     dblNoOfLot decimal(24,10),  
     dblQuantity decimal(24,10),
     intOrderByHeading int,
     intContractHeaderId int ,
     intFutOptTransactionHeaderId int       
     )               

declare @strAccountNumber nvarchar(max)
select top 1 @strAccountNumber=strAccountNumber  from @ListFinal where  strGroup='1.Outright Coverage' and PriceStatus='1.Priced / Outright - (Outright position)' order by intRowNumber


INSERT INTO @MonthOrder (intRowNumber,strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate ,  
                                           TranType,CustVendor,dblNoOfLot,dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)
SELECT DISTINCT 0,'1.Outright Coverage',
'Outright Coverage'  ,
'1.Priced / Outright - (Outright position)',strFutureMonth, @strAccountNumber,
NULL, NULL, GETDATE(), NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM @ListFinal  WHERE strFutureMonth
NOT IN (SELECT DISTINCT strFutureMonth FROM @ListFinal 
		WHERE strGroup = '1.Outright Coverage' and PriceStatus in('1.Priced / Outright - (Outright position)'))

INSERT INTO @MonthOrder  (intRowNumber,strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate ,  
                                           TranType,CustVendor,dblNoOfLot,dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)
SELECT intRowNumber ,strGroup,Selection ,PriceStatus  , strFutureMonth , strAccountNumber , CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)),  
strTradeNo,  TransactionDate  , TranType, CustVendor,  dblNoOfLot ,  dblQuantity ,intOrderByHeading ,intContractHeaderId ,intFutOptTransactionHeaderId  
FROM @ListFinal where strFutureMonth='Previous' and dblNoOfContract<>0

INSERT INTO @MonthOrder  (intRowNumber,strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate ,  
                                           TranType,CustVendor,dblNoOfLot,dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)
SELECT intRowNumber ,strGroup,Selection ,PriceStatus  , strFutureMonth , strAccountNumber , CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)),  
strTradeNo,  TransactionDate  , TranType, CustVendor,  dblNoOfLot ,  dblQuantity ,intOrderByHeading ,intContractHeaderId ,intFutOptTransactionHeaderId  
FROM @ListFinal where strFutureMonth NOT IN('Previous','Total')and dblNoOfContract<>0
ORDER BY intRowNumber,PriceStatus,CONVERT(DATETIME,'01 '+strFutureMonth) ASC

INSERT INTO @MonthOrder  (intRowNumber,strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate ,  
                                           TranType,CustVendor,dblNoOfLot,dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId)
SELECT intRowNumber ,strGroup,Selection ,PriceStatus  , strFutureMonth , strAccountNumber , CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)),  
strTradeNo,  TransactionDate  , TranType, CustVendor,  dblNoOfLot ,  dblQuantity ,intOrderByHeading ,intContractHeaderId ,intFutOptTransactionHeaderId  
FROM @ListFinal where strFutureMonth='Total' and dblNoOfContract<>0

select row_number() over(order by intRowNumber) intRowNumFinal ,intRowNumber ,strGroup,Selection ,  
            PriceStatus  ,  
            strFutureMonth ,  
            strAccountNumber ,  
            case when CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal))=0 then null else CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) end  dblNoOfContract,  
            strTradeNo,  
            TransactionDate  ,  
            TranType,  
            CustVendor,       
            dblNoOfLot ,  
            dblQuantity ,
            intOrderByHeading ,
            intContractHeaderId ,
            intFutOptTransactionHeaderId from @MonthOrder --order by intRowNumber
ORDER BY strGroup,PriceStatus,
CASE WHEN  strFutureMonth ='Previous' THEN '01/01/1900' 
  WHEN  strFutureMonth ='Total' THEN '01/01/9999'
else CONVERT(DATETIME,'01 '+strFutureMonth) END
