CREATE PROC [dbo].[uspRKRiskPositionInquiryBySummary]  
        @intCommodityId INTEGER,  
        @intCompanyLocationId INTEGER,  
        @intFutureMarketId INTEGER,  
        @intFutureMonthId INTEGER,  
        @intUOMId INTEGER,  
        @intDecimal INTEGER,
		@intForecastWeeklyConsumption INTEGER = null,
		@intForecastWeeklyConsumptionUOMId INTEGER = null   
AS  

DECLARE @strUnitMeasure nvarchar(50)  
DECLARE @dtmFutureMonthsDate datetime  
DECLARE @dblContractSize int  
DECLARE @ysnIncludeInventoryHedge BIT
DECLARE @strRiskView nvarchar(50) 
DECLARE @strFutureMonth  nvarchar(15) ,@dblForecastWeeklyConsumption numeric(18,6)
  
SELECT @dblContractSize= convert(int,dblContractSize) FROM tblRKFutureMarket WHERE intFutureMarketId=@intFutureMarketId  
SELECT TOP 1 @dtmFutureMonthsDate=dtmFutureMonthsDate FROM tblRKFuturesMonth WHERE intFutureMonthId=@intFutureMonthId  

SELECT top 1 @strUnitMeasure= strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId=@intUOMId  
SELECT @intUOMId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId and intUnitMeasureId=@intUOMId  
SELECT @ysnIncludeInventoryHedge = ysnIncludeInventoryHedge FROM tblRKCompanyPreference  
SELECT @strRiskView = strRiskView FROM tblRKCompanyPreference 

SELECT @intForecastWeeklyConsumptionUOMId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId and intUnitMeasureId=@intForecastWeeklyConsumptionUOMId  
SELECT @dblForecastWeeklyConsumption=isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(@intUOMId,@intForecastWeeklyConsumptionUOMId,@intForecastWeeklyConsumption),1)


DECLARE @List as Table (  
     intRowNumber int identity(1,1),
	 strGroup nvarchar(200) COLLATE Latin1_General_CI_AS,  
     Selection  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     PriceStatus  nvarchar(50) COLLATE Latin1_General_CI_AS,  
     strFutureMonth  nvarchar(20) COLLATE Latin1_General_CI_AS,  
     strAccountNumber  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     dblNoOfContract  decimal(24,10),  
     strTradeNo  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     TransactionDate  datetime,  
     TranType  nvarchar(50) COLLATE Latin1_General_CI_AS,  
     CustVendor nvarchar(50) COLLATE Latin1_General_CI_AS,       
     dblNoOfLot decimal(24,10),  
     dblQuantity decimal(24,10),
     intOrderByHeading int,
     intOrderBySubHeading int,
     intContractHeaderId int ,
     intFutOptTransactionHeaderId int       
     )  

BEGIN  
INSERT INTO @List(strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId)  
SELECT 'Outright Coverage',Selection,PriceStatus,strFutureMonth,strAccountNumber,ROUND(dblNoOfContract,@intDecimal) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId FROM(  
 
SELECT * FROM(  
  SELECT  DISTINCT CASE WHEN @strRiskView='Processor' then 'Physical position / Differential cover' ELSE 'Physical position / Basis risk' END AS Selection,
			'Priced / Outright - (Outright position)' as PriceStatus,'Previous' as strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,
 (SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, 
 CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0)end) from vyuRKGetInventoryAdjustQty aq where aq.intContractDetailId=cv.intContractDetailId) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,
  -(select dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0)end) from vyuRKGetInventoryAdjustQty aq where aq.intContractDetailId=cv.intContractDetailId)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um1.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,   
   (select dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0)end) from vyuRKGetInventoryAdjustQty aq where aq.intContractDetailId=cv.intContractDetailId) as dblQuantity   
    ,cv.intContractHeaderId,null as intFutOptTransactionHeaderId  
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=cv.intFutureMarketId and cv.intContractStatusId <> 3
  JOIN tblICCommodityUnitMeasure um1 on um1.intCommodityId=cv.intCommodityId and um1.intUnitMeasureId=ffm.intUnitMeasureId  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
           LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId   
           LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId     
  WHERE  intPricingTypeId = 1 AND cv.strContractType='Purchase'   
     AND cv.intCommodityId=@intCommodityId 
         AND cv.intCompanyLocationId= case when isnull(@intCompanyLocationId,0)=0 then cv.intCompanyLocationId else @intCompanyLocationId end
         AND cv.intFutureMarketId=@intFutureMarketId   
     AND dtmFutureMonthsDate < @dtmFutureMonthsDate   

  UNION    

  SELECT DISTINCT case when @strRiskView='Processor' then 'Physical position / Differential cover' else 'Physical position / Basis risk' end as Selection,'Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,
  (select dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0)end) from vyuRKGetInventoryAdjustQty aq where aq.intContractDetailId=cv.intContractDetailId) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,-(select dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0)end) from vyuRKGetInventoryAdjustQty aq where aq.intContractDetailId=cv.intContractDetailId)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um1.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,   
   (select dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0)end) from vyuRKGetInventoryAdjustQty aq where aq.intContractDetailId=cv.intContractDetailId) as dblQuantity  
   , cv.intContractHeaderId,null as intFutOptTransactionHeaderId  
  FROM vyuCTContractDetailView cv  
    JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=cv.intFutureMarketId and cv.intContractStatusId <> 3
     JOIN tblICCommodityUnitMeasure um1 on um1.intCommodityId=cv.intCommodityId and um1.intUnitMeasureId=ffm.intUnitMeasureId  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
               LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  
               LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1   
     AND cv.intCommodityId=@intCommodityId 
         AND cv.intCompanyLocationId= case when isnull(@intCompanyLocationId,0)=0 then cv.intCompanyLocationId else @intCompanyLocationId end
         AND cv.intFutureMarketId=@intFutureMarketId   
     and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
  
UNION   
  
SELECT * FROM(  
  SELECT  DISTINCT case when @strRiskView='Processor' then 'Physical position / Differential cover' else 'Physical position / Basis risk' end as Selection,'Priced / Outright - (Outright position)' as PriceStatus,'Previous' as strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,
  -(select dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0)end) from vyuRKGetInventoryAdjustQty aq where aq.intContractDetailId=cv.intContractDetailId) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,  
  ((select dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0)end) from vyuRKGetInventoryAdjustQty aq where aq.intContractDetailId=cv.intContractDetailId)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um1.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)  ) as dblNoOfLot,   
   -(select dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0)end) from vyuRKGetInventoryAdjustQty aq where aq.intContractDetailId=cv.intContractDetailId) as dblQuantity  
   , cv.intContractHeaderId,null as intFutOptTransactionHeaderId  
  FROM vyuCTContractDetailView cv  
    JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=cv.intFutureMarketId and cv.intContractStatusId <> 3
     JOIN tblICCommodityUnitMeasure um1 on um1.intCommodityId=cv.intCommodityId and um1.intUnitMeasureId=ffm.intUnitMeasureId  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)  
             LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId   
             LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE  intPricingTypeId = 1 AND cv.strContractType='sale'   
     AND cv.intCommodityId=@intCommodityId 
         AND cv.intCompanyLocationId= case when isnull(@intCompanyLocationId,0)=0 then cv.intCompanyLocationId else @intCompanyLocationId end
         AND cv.intFutureMarketId=@intFutureMarketId   
     AND dtmFutureMonthsDate < @dtmFutureMonthsDate   
  UNION    
    
  SELECT DISTINCT case when @strRiskView='Processor' then 'Physical position / Differential cover' else 'Physical position / Basis risk' end as Selection,'Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,
  -(select dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0)end) from vyuRKGetInventoryAdjustQty aq where aq.intContractDetailId=cv.intContractDetailId) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,
  ((select dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0)end) from vyuRKGetInventoryAdjustQty aq where aq.intContractDetailId=cv.intContractDetailId)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um1.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)  ) as dblNoOfLot,   
  (select dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0)end) from vyuRKGetInventoryAdjustQty aq where aq.intContractDetailId=cv.intContractDetailId) as dblQuantity  
   , cv.intContractHeaderId,null as intFutOptTransactionHeaderId  
  FROM vyuCTContractDetailView cv  
    JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=cv.intFutureMarketId and cv.intContractStatusId <> 3
     JOIN tblICCommodityUnitMeasure um1 on um1.intCommodityId=cv.intCommodityId and um1.intUnitMeasureId=ffm.intUnitMeasureId  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
  LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId   
  LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId          
  WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId = 1   
     AND cv.intCommodityId=@intCommodityId 
         AND cv.intCompanyLocationId= case when isnull(@intCompanyLocationId,0)=0 then cv.intCompanyLocationId else @intCompanyLocationId end
         AND cv.intFutureMarketId=@intFutureMarketId   
     and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
UNION
SELECT DISTINCT 'Total F&O( in ' + @strUnitMeasure + ' )' AS Selection, 'F&O' AS PriceStatus, strFutureMonth, 'F&O' AS strAccountNumber, dblNoOfContract, strTradeNo, TransactionDate, TranType, CustVendor, dblNoOfLot, dblQuantity
, intContractHeaderId,intFutOptTransactionHeaderId 
FROM (
       SELECT strFutureMonth, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (dblNoOfContract)) * @dblContractSize AS dblNoOfContract, strTradeNo, TransactionDate, TranType, CustVendor, dblNoOfLot, dblQuantity, intCommodityUnitMeasureId
       ,intContractHeaderId,intFutOptTransactionHeaderId 
       FROM (
              SELECT DISTINCT 'Terminal position ( in ' + @strUnitMeasure + ' )' AS Selection, 'Broker Account' AS PriceStatus, 
			  strFutureMonth, e.strName + '-' + strAccountNumber AS strAccountNumber, 
			  CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract) ELSE - (ft.intNoOfContract) END AS dblNoOfContract, ft.strInternalTradeNo AS strTradeNo, 
			  ft.dtmTransactionDate AS TransactionDate, strBuySell AS TranType, e.strName AS CustVendor, 
			  CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract) ELSE - (ft.intNoOfContract) END AS dblNoOfLot, 
			  CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract * @dblContractSize) ELSE - (ft.intNoOfContract * @dblContractSize) END dblQuantity, um.intCommodityUnitMeasureId
              , null as intContractHeaderId,ft.intFutOptTransactionHeaderId 
              FROM tblRKFutOptTransaction ft
              INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
              INNER JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 1
              INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
              INNER JOIN tblRKFutureMarket mar ON mar.intFutureMarketId = ft.intFutureMarketId
              LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = ft.intCommodityId AND um.intUnitMeasureId = mar.intUnitMeasureId
              WHERE ft.intCommodityId = @intCommodityId AND intLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intLocationId ELSE @intCompanyLocationId END AND ft.intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
              ) t
			  )t1
UNION
  
SELECT * FROM(  
  SELECT DISTINCT 'Total speciality delta fixed' as Selection,'Delta %' as PriceStatus,cv.strFutureMonth,    
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,  
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)*isnull(dblDeltaPercent,0)/100 as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um1.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity  
  , cv.intContractHeaderId,null as intFutOptTransactionHeaderId  
FROM vyuCTContractDetailView cv  
  JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=cv.intFutureMarketId and cv.intContractStatusId <> 3
     JOIN tblICCommodityUnitMeasure um1 on um1.intCommodityId=cv.intCommodityId and um1.intUnitMeasureId=ffm.intUnitMeasureId  
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
JOIN tblICItem ic on ic.intItemId=cv.intItemId  
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId   
AND ic.intProductLineId=pl.intCommodityProductLineId  
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1   
AND cv.intCommodityId=@intCommodityId  AND cv.intCompanyLocationId= case when isnull(@intCompanyLocationId,0)=0 then cv.intCompanyLocationId else @intCompanyLocationId end AND cv.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  )t2

INSERT INTO @List(strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId )  
SELECT 'Outright Coverage',Selection,PriceStatus,strFutureMonth,strAccountNumber,sum(dblNoOfContract),strTradeNo,TransactionDate,TranType,CustVendor,sum(dblNoOfLot), sum(dblQuantity)
,intContractHeaderId,intFutOptTransactionHeaderId 
FROM(
       SELECT  CASE WHEN @strRiskView='Processor' THEN 'Outright coverage' ELSE 'Net market risk' END AS Selection,CASE WHEN @strRiskView='Processor' THEN 'Outright coverage' ELSE 'Net market risk' END as PriceStatus,strFutureMonth
                     ,case when @strRiskView='Processor' then 'Market Coverage' else 'Market Risk' end as strAccountNumber,sum(dblNoOfContract) dblNoOfContract,
                     strTradeNo, TransactionDate,TranType,CustVendor,sum(dblNoOfLot) dblNoOfLot, sum(dblQuantity)  dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId  
       FROM @List WHERE Selection=case when @strRiskView='Processor' then 'Physical position / Differential cover' else 'Physical position / Basis risk' end
                                    and PriceStatus = 'Priced / Outright - (Outright position)' 
       GROUP BY strFutureMonth,strTradeNo, TransactionDate,TranType,CustVendor,intContractHeaderId,intFutOptTransactionHeaderId  
       UNION
       SELECT  CASE WHEN @strRiskView='Processor' THEN 'Outright coverage' ELSE 'Net market risk' END AS Selection,CASE WHEN @strRiskView='Processor' THEN 'Outright coverage' ELSE 'Net market risk' END as PriceStatus,strFutureMonth
                     ,CASE WHEN @strRiskView='Processor' then 'Market Coverage' else 'Market Risk' end as strAccountNumber,sum(dblNoOfContract) dblNoOfContract,
                     strTradeNo, TransactionDate,TranType,CustVendor,sum(dblNoOfLot) dblNoOfLot, sum(dblQuantity)  dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId  
       FROM @List WHERE PriceStatus ='F&O' and Selection LIKE ('Total F&O%')
       GROUP BY strFutureMonth,strAccountNumber,strTradeNo, TransactionDate,TranType,CustVendor,intContractHeaderId,intFutOptTransactionHeaderId  
       
       UNION 
        SELECT  CASE WHEN @strRiskView='Processor' THEN 'Outright coverage' ELSE 'Net market risk' END AS Selection,CASE WHEN @strRiskView='Processor' THEN 'Outright coverage' ELSE 'Net market risk' END as PriceStatus,strFutureMonth
                     ,CASE WHEN @strRiskView='Processor' then 'Market Coverage' else 'Market Risk' end as strAccountNumber,sum(dblNoOfContract) dblNoOfContract,
                     strTradeNo, TransactionDate,TranType,CustVendor,sum(dblNoOfLot) dblNoOfLot, sum(dblQuantity)  dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId  
       FROM @List WHERE PriceStatus ='Delta %' and Selection = ('Total speciality delta fixed')
       GROUP BY strFutureMonth,strAccountNumber,strTradeNo, TransactionDate,TranType,CustVendor,intContractHeaderId,intFutOptTransactionHeaderId  
       )t 
GROUP BY Selection,PriceStatus,strAccountNumber,strFutureMonth,strTradeNo, TransactionDate,TranType,CustVendor,intContractHeaderId,intFutOptTransactionHeaderId  

-----Outright coverage (Weeks) ------------
if (@strRiskView = 'Processor')
BEGIN
	INSERT INTO @List(strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId )  
	SELECT 'Outright Coverage','Outright coverage(Weeks)' AS Selection,'Outright coverage(Weeks)' as PriceStatus,strFutureMonth,strAccountNumber,sum(dblNoOfContract)/@dblForecastWeeklyConsumption,strTradeNo,TransactionDate,TranType,CustVendor,sum(dblNoOfLot), sum(dblQuantity)
			,intContractHeaderId,intFutOptTransactionHeaderId FROM @List 
	WHERE Selection=CASE WHEN @strRiskView='Processor' THEN 'Outright coverage' ELSE 'Net market risk' END
	GROUP BY strFutureMonth,strAccountNumber,strTradeNo, TransactionDate,TranType,CustVendor,intContractHeaderId,intFutOptTransactionHeaderId  
END

--- second part
INSERT INTO @List(strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId)  
SELECT 'Futures Required',Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfLot as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId FROM(  
  
SELECT * FROM(  
  SELECT  DISTINCT case when @strRiskView='Processor' then 'Physical position / Differential cover' else 'Physical position / Basis risk' end as Selection,'Unpriced - (Balance to be Priced)' as PriceStatus,'Previous' as strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,  
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblNoOfContract,  
  LEFT(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,  
  -dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um1.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,  
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity,
  cv.intContractHeaderId,null as intFutOptTransactionHeaderId  
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=cv.intFutureMarketId and cv.intContractStatusId <> 3
  JOIN tblICCommodityUnitMeasure um1 on um1.intCommodityId=cv.intCommodityId and um1.intUnitMeasureId=ffm.intUnitMeasureId  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
  JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId AND ici.intProductLineId=pl.intCommodityProductLineId)  
  LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  
  LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId    
  WHERE intPricingTypeId <> 1 AND cv.strContractType='Purchase'  
   AND dtmFutureMonthsDate < @dtmFutureMonthsDate   
   AND cv.intCommodityId=@intCommodityId  
   AND cv.intCompanyLocationId= case when isnull(@intCompanyLocationId,0)=0 then cv.intCompanyLocationId else @intCompanyLocationId end
   AND cv.intFutureMarketId=@intFutureMarketId   
      
  UNION    
  SELECT DISTINCT case when @strRiskView='Processor' then 'Physical position / Differential cover' else 'Physical position / Basis risk' end as Selection,'Unpriced - (Balance to be Priced)' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0)
end) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,
  -dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,
  CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um1.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity,
   cv.intContractHeaderId,null as intFutOptTransactionHeaderId    
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=cv.intFutureMarketId and cv.intContractStatusId <> 3
  JOIN tblICCommodityUnitMeasure um1 on um1.intCommodityId=cv.intCommodityId and um1.intUnitMeasureId=ffm.intUnitMeasureId  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
  JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId AND ici.intProductLineId=pl.intCommodityProductLineId)   
  LEFT JOIN tblARProductType pt on pt.intProductTypeId=ic.intProductTypeId    
  LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  
  LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId <> 1   
     AND cv.intCommodityId=@intCommodityId   
        AND cv.intCompanyLocationId= case when isnull(@intCompanyLocationId,0)=0 then cv.intCompanyLocationId else @intCompanyLocationId end 
        AND cv.intFutureMarketId=@intFutureMarketId   
     AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
  
UNION   
  
SELECT * FROM(  
  SELECT  DISTINCT case when @strRiskView='Processor' then 'Physical position / Differential cover' else 'Physical position / Basis risk' end as Selection ,'Unpriced - (Balance to be Priced)' as PriceStatus,'Previous' as strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  isnull(dblBalance,0)) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,(dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um1.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)  ) as dblNoOfLot,  
  -dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, isnull(dblBalance,0)) as dblQuantity, cv.intContractHeaderId,
  null as intFutOptTransactionHeaderId  
  FROM vyuCTContractDetailView cv  
    JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=cv.intFutureMarketId and cv.intContractStatusId <> 3
     JOIN tblICCommodityUnitMeasure um1 on um1.intCommodityId=cv.intCommodityId and um1.intUnitMeasureId=ffm.intUnitMeasureId  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
      LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  
      LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE  intPricingTypeId <> 1 AND cv.strContractType='sale'   
     AND cv.intCommodityId=@intCommodityId 
         AND cv.intCompanyLocationId= case when isnull(@intCompanyLocationId,0)=0 then cv.intCompanyLocationId else @intCompanyLocationId end
         AND cv.intFutureMarketId=@intFutureMarketId   
     AND dtmFutureMonthsDate < @dtmFutureMonthsDate        
  UNION    
  SELECT DISTINCT case when @strRiskView='Processor' then 'Physical position / Differential cover' else 'Physical position / Basis risk' end as Selection,'Unpriced - (Balance to be Priced)' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, isnull(dblBalance,0)) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,(dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um1.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)  ) as dblNoOfLot,   
   dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, isnull(dblBalance,0)) as dblQuantity  ,
    cv.intContractHeaderId,null as intFutOptTransactionHeaderId  
  FROM vyuCTContractDetailView cv  
    JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=cv.intFutureMarketId and cv.intContractStatusId <> 3
     JOIN tblICCommodityUnitMeasure um1 on um1.intCommodityId=cv.intCommodityId and um1.intUnitMeasureId=ffm.intUnitMeasureId  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
        LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  
        LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE fm.ysnExpired=0 and strContractType='sale' AND intPricingTypeId <> 1   
		AND cv.intCommodityId=@intCommodityId 
		AND cv.intCompanyLocationId= case when isnull(@intCompanyLocationId,0)=0 then cv.intCompanyLocationId else @intCompanyLocationId end
		AND cv.intFutureMarketId=@intFutureMarketId   
		AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  

union
SELECT DISTINCT Selection,'F&O' as PriceStatus,strFutureMonth,'F&O' as strAccountNumber,(dblNoOfContract) as dblNoOfContract,  
  strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId   from (  
  SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,(dblNoOfContract) as dblNoOfContract,  
  strTradeNo, TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity, intContractHeaderId,intFutOptTransactionHeaderId  from  
   (  
   SELECT DISTINCT 'Terminal position ( in lots )' as Selection,'Broker Account' as PriceStatus,  
      strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,  
     ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
     case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,   
     case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity  
        , null as intContractHeaderId,ft.intFutOptTransactionHeaderId 
   FROM tblRKFutOptTransaction ft  
   JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
   JOIN tblEMEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId=1  
   JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
   WHERE  intCommodityId=@intCommodityId AND intLocationId= case when isnull(@intCompanyLocationId,0)=0 then intLocationId else @intCompanyLocationId end AND ft.intFutureMarketId=@intFutureMarketId   
   and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
   )t  )s
)T1  
)t2

if (@strRiskView = 'Processor')
BEGIN
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

INSERT INTO @DemandQty
SELECT dblQuantity,d.intUOMId,CONVERT(DATETIME,'01 '+strPeriod) dtmPeriod,strPeriod,strItemName,d.intItemId,c.strDescription FROM tblRKStgBlendDemand d
join tblICItem i on i.intItemId=d.intItemId
JOIN tblICCommodityAttribute c on c.intCommodityId = i.intCommodityId
JOIN tblRKCommodityMarketMapping m on m.intCommodityId=c.intCommodityId and   intProductTypeId=intCommodityAttributeId
			AND intCommodityAttributeId in (select Ltrim(rtrim(Item)) Collate Latin1_General_CI_AS from [dbo].[fnSplitString](m.strCommodityAttributeId, ','))
JOIN tblRKFutureMarket fm on fm.intFutureMarketId=m.intFutureMarketId
WHERE m.intCommodityId=@intCommodityId and fm.intFutureMarketId =@intFutureMarketId

DECLARE @intRowNumber INT
DECLARE @dblQuantity  numeric(24,10)
DECLARE @intUOMId1  int
DECLARE @dtmPeriod1  datetime
DECLARE @strFutureMonth1 nvarchar(20)
declare @strItemName nvarchar(200)
declare @intItemId int
declare @strDescription nvarchar(200)

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
	--SELECT @strFutureMonth1=strFutureMonth FROM tblRKFuturesMonth where @dtmPeriod1<CONVERT(DATETIME,'01 '+strFutureMonth)

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


INSERT INTO @List(strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,dblQuantity,dblNoOfLot)  
 SELECT  DISTINCT 'Futures Required',case when @strRiskView='Processor' then 'To Purchase' else 'To Purchase' end as Selection,
 'To Purchase' as PriceStatus,strPeriod as strFutureMonth,strDescription as strAccountNumber,  
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,isnull(dblQuantity,0)) 
		/ dbo.fnCTConvertQuantityToTargetCommodityUOM(um1.intCommodityUnitMeasureId,@intUOMId,@dblContractSize) as dblNoOfLot,strItemName,dtmPeriod,
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,isnull(dblQuantity,0))  as dblQuantity,
	dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,isnull(dblQuantity,0)) 
		/ dbo.fnCTConvertQuantityToTargetCommodityUOM(um1.intCommodityUnitMeasureId,@intUOMId,@dblContractSize) as dblNoOfLot
  FROM @DemandFinal cv  
  JOIN tblICCommodityUnitMeasure um on um.intCommodityId=@intCommodityId AND um.intUnitMeasureId=cv.intUOMId
  JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=@intFutureMarketId 
  JOIN tblICCommodityUnitMeasure um1 on um1.intCommodityId=@intCommodityId and um1.intUnitMeasureId=ffm.intUnitMeasureId  
order by dtmPeriod asc

END

if (@strRiskView <> 'Processor')
BEGIN
--- Switch Position ---------
INSERT INTO @List(strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId )  
SELECT 'Futures Required',Selection,PriceStatus,strFutureMonth,strAccountNumber,(dblNoOfContract),strTradeNo,TransactionDate,TranType,CustVendor,(dblNoOfLot), (dblQuantity),intContractHeaderId,intFutOptTransactionHeaderId  
FROM(
       SELECT  CASE WHEN @strRiskView='Processor' then 'Futures required' else 'Switch position' end as Selection,case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as PriceStatus,strFutureMonth
                     ,CASE WHEN @strRiskView='Processor' then 'Futures required' else 'Switch position' end as strAccountNumber,(dblNoOfLot) dblNoOfContract,
                     strTradeNo, TransactionDate,TranType,CustVendor,(dblNoOfLot) dblNoOfLot, (dblQuantity)  dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId   
       FROM @List WHERE Selection=case when @strRiskView='Processor' then 'Physical position / Differential cover' else 'Physical position / Basis risk' end
           and PriceStatus = 'Unpriced - (Balance to be Priced)' and strAccountNumber like '%Purchase%'
       UNION
       SELECT  CASE WHEN @strRiskView='Processor' then 'Futures required' else 'Switch position' end as Selection,case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as PriceStatus,strFutureMonth
                     ,CASE WHEN @strRiskView='Processor' then 'Futures required' else 'Switch position' end as strAccountNumber,((dblNoOfLot)) dblNoOfContract,
                     strTradeNo, TransactionDate,TranType,CustVendor,((dblNoOfLot)) dblNoOfLot,  ((dblQuantity))  dblQuantity ,intContractHeaderId,intFutOptTransactionHeaderId  
       FROM @List WHERE Selection=case when @strRiskView='Processor' then 'Physical position / Differential cover' else 'Physical position / Basis risk' end
           and PriceStatus = 'Unpriced - (Balance to be Priced)'  and strAccountNumber like '%Sale%'
       UNION 
       SELECT  CASE WHEN @strRiskView='Processor' then 'Futures required' else 'Switch position' end as Selection,case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as PriceStatus,strFutureMonth
                     ,CASE WHEN @strRiskView='Processor' then 'Futures required' else 'Switch position' end as strAccountNumber,dblNoOfContract dblNoOfContract,
                     strTradeNo, TransactionDate,TranType,CustVendor,(dblNoOfLot) dblNoOfLot, (dblQuantity)  dblQuantity ,intContractHeaderId,intFutOptTransactionHeaderId  
       FROM @List WHERE PriceStatus ='F&O' and Selection ='F&O'
       )t 
END

if (@strRiskView = 'Processor')
BEGIN
--- Switch Position ---------
INSERT INTO @List(strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId )  
SELECT 'Futures Required',Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfLot,strTradeNo,TransactionDate,TranType,CustVendor,(dblNoOfLot), (dblQuantity),intContractHeaderId,intFutOptTransactionHeaderId  
FROM(
         SELECT  CASE WHEN @strRiskView='Processor' then 'Futures required' else 'Switch position' end as Selection,case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as PriceStatus,strFutureMonth
                         ,CASE WHEN @strRiskView='Processor' then 'Futures required' else 'Switch position' end as strAccountNumber,(dblNoOfLot) dblNoOfContract,
                         strTradeNo, TransactionDate,TranType,CustVendor,(dblNoOfLot) dblNoOfLot, (dblQuantity)  dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId
						 ,0 as dblUnPricedNoOfLot,0 as dblNetNetLot   
           FROM @List WHERE Selection = 'Terminal position ( in lots )'
	   
		UNION  
	    SELECT  CASE WHEN @strRiskView='Processor' then 'Futures required' else 'Switch position' end as Selection,
					case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as PriceStatus,strFutureMonth
                     ,CASE WHEN @strRiskView='Processor' then 'Futures required' else 'Switch position' end as strAccountNumber,dblNoOfLot dblNoOfContract,
                     strTradeNo, TransactionDate,TranType,CustVendor,(dblNoOfLot) dblNoOfLot, (dblQuantity)  dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId   
					 ,abs(dblNoOfLot) dblUnPricedNoOfLot,0 as dblNetNetLot
       FROM @List WHERE Selection=case when @strRiskView='Processor' then 'Physical position / Differential cover' else 'Physical position / Basis risk' end
           and PriceStatus = 'Unpriced - (Balance to be Priced)' and strAccountNumber like '%Purchase%'

	   UNION
	      SELECT  CASE WHEN @strRiskView='Processor' then 'Futures required' else 'Switch position' end as Selection,case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as PriceStatus,strFutureMonth
	                    ,CASE WHEN @strRiskView='Processor' then 'Futures required' else 'Switch position' end as strAccountNumber,dblNoOfLot dblNoOfContract,
                        strTradeNo, TransactionDate,TranType,CustVendor,(dblNoOfLot) dblNoOfLot, (dblQuantity)  dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId
						,0 as dblUnPricedNoOfLot, dblNoOfLot dblNetNetLot   
          FROM @List WHERE Selection =  'To Purchase'	
	)t 
END
	   
END

SELECT TOP 1 @strFutureMonth=strFutureMonth FROM @List where  strFutureMonth<>'Previous' order by convert(datetime,'01 '+strFutureMonth) asc

UPDATE @List set strFutureMonth=@strFutureMonth where Selection='Switch position' and strFutureMonth='Previous'
UPDATE @List set strFutureMonth=@strFutureMonth where Selection=case when @strRiskView='Processor' THEN 'Outright coverage' ELSE 'Net market risk' END and strFutureMonth='Previous'
UPDATE @List set strFutureMonth=@strFutureMonth where Selection=case when @strRiskView='Processor' THEN 'Outright coverage(Weeks)' ELSE 'Net market risk(Weeks)' END and strFutureMonth='Previous'

IF NOT EXISTS ( SELECT *
       FROM tblRKFutOptTransaction ft  
       JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
       JOIN tblEMEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId=2  
       JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
       WHERE  intCommodityId=@intCommodityId AND intLocationId= case when isnull(@intCompanyLocationId,0)=0 then intLocationId else @intCompanyLocationId end AND ft.intFutureMarketId=@intFutureMarketId   
       and dtmFutureMonthsDate >= @dtmFutureMonthsDate 
       and intFutOptTransactionId not in(select intFutOptTransactionId from tblRKOptionsPnSExercisedAssigned) 
       and intFutOptTransactionId not in(select intFutOptTransactionId from tblRKOptionsPnSExpired))
       BEGIN
              DELETE FROM @List where Selection like '%F&O%'
       END
	    
	   --select * from @List where PriceStatus like '%Net Net%'

--update @List set intOrderByHeading=1 WHERE Selection in ('Physical position / Differential cover','Physical position / Basis risk')
--update @List set intOrderByHeading=2 WHERE Selection = 'Specialities & Low grades'
--update @List set intOrderByHeading=3 WHERE Selection = 'Total speciality delta fixed'
--update @List set intOrderByHeading=4 WHERE Selection = 'Terminal position ( in lots )'
--update @List set intOrderByHeading=5 WHERE Selection like ('%Terminal position (b.%')
--update @List set intOrderByHeading=6 WHERE Selection = 'Delta options'
--update @List set intOrderByHeading=7 WHERE Selection = 'F&O'
--update @List set intOrderByHeading=8 WHERE Selection like ('%Total F&O( in%')
--update @List set intOrderByHeading=9 WHERE Selection in('Outright coverage','Net market risk')
--update @List set intOrderByHeading=10 WHERE Selection in('Outright coverage(Weeks)','Net market risk(Weeks)')
--update @List set intOrderByHeading=11 WHERE Selection = 'To Purchase'
--update @List set intOrderByHeading=12 WHERE Selection in('Switch position','Futures required')

DECLARE @ListFinal as Table (  
     intRowNumber1 int identity(1,1),  
	 intRowNumber int,
	 strGroup nvarchar(200) COLLATE Latin1_General_CI_AS,
     Selection  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     PriceStatus  nvarchar(50) COLLATE Latin1_General_CI_AS,  
     strFutureMonth  nvarchar(20) COLLATE Latin1_General_CI_AS,  
     strAccountNumber  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     dblNoOfContract  decimal(24,10),  
     strTradeNo  nvarchar(200) COLLATE Latin1_General_CI_AS,  
     TransactionDate  datetime,  
     TranType  nvarchar(50) COLLATE Latin1_General_CI_AS,  
     CustVendor nvarchar(50) COLLATE Latin1_General_CI_AS,       
     dblNoOfLot decimal(24,10),  
     dblQuantity decimal(24,10),
     intOrderByHeading int,
     intContractHeaderId int ,
     intFutOptTransactionHeaderId int       
     )  

INSERT INTO @ListFinal
SELECT
intRowNumber,strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
	dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @List    
    WHERE PriceStatus='Priced / Outright - (Outright position)'
 ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC

INSERT INTO @ListFinal
SELECT
intRowNumber,strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
	dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @List    
    WHERE Selection='Total F&O( in ' + @strUnitMeasure + ' )'  and  PriceStatus= 'F&O'
 ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC

INSERT INTO @ListFinal
SELECT
intRowNumber,strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
	dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @List    
    WHERE Selection=CASE WHEN @strRiskView='Processor' THEN 'Outright coverage' ELSE 'Net market risk' END 
		and PriceStatus = CASE WHEN @strRiskView='Processor' THEN 'Outright coverage' ELSE 'Net market risk' END
 ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC

INSERT INTO @ListFinal
SELECT
intRowNumber,strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
	dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @List    
    WHERE PriceStatus='Outright coverage(Weeks)'
 ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC

INSERT INTO @ListFinal
SELECT
intRowNumber,strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
	dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @List    
    WHERE PriceStatus='Unpriced - (Balance to be Priced)'
 ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC

INSERT INTO @ListFinal
SELECT
intRowNumber,strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
	dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @List    
    WHERE Selection='Terminal position ( in lots )' and PriceStatus='F&O'
 ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC

INSERT INTO @ListFinal
SELECT
intRowNumber,strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
	dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @List    
    WHERE PriceStatus='To Purchase'
 ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC

INSERT INTO @ListFinal
SELECT
intRowNumber,strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
	dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @List    
    WHERE PriceStatus=case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end 
 ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC
 select intRowNumber,strGroup,Selection,PriceStatus,strFutureMonth,strAccountNumber, CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
	dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId  from @ListFinal 
