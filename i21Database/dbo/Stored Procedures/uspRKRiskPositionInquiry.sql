CREATE PROC [dbo].[uspRKRiskPositionInquiry]  
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
declare @strParamFutureMonth nvarchar(12)  
SELECT @dblContractSize= convert(int,dblContractSize) FROM tblRKFutureMarket WHERE intFutureMarketId=@intFutureMarketId  
SELECT TOP 1 @dtmFutureMonthsDate=dtmFutureMonthsDate,@strParamFutureMonth=strFutureMonth FROM tblRKFuturesMonth WHERE intFutureMonthId=@intFutureMonthId  

SELECT TOP 1 @strUnitMeasure= strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId=@intUOMId  
select @intUOMId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId and intUnitMeasureId=@intUOMId  
SELECT @ysnIncludeInventoryHedge = ysnIncludeInventoryHedge FROM tblRKCompanyPreference  
SELECT @strRiskView = strRiskView FROM tblRKCompanyPreference 
DECLARE @intForecastWeeklyConsumptionUOMId1 int
SELECT @intForecastWeeklyConsumptionUOMId1=intCommodityUnitMeasureId from tblICCommodityUnitMeasure 
			WHERE intCommodityId=@intCommodityId and intUnitMeasureId=@intForecastWeeklyConsumptionUOMId  

SELECT @dblForecastWeeklyConsumption=isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(@intForecastWeeklyConsumptionUOMId1,@intUOMId,@intForecastWeeklyConsumption),1)
     

DECLARE @List as Table (  
     intRowNumber int identity(1,1),  
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

SELECT  DISTINCT 
  cv.strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,  
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblNoOfContract,  
  LEFT(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, 
  dtmStartDate as TransactionDate,  
  strContractType as TranType, 
  strEntityName  as CustVendor,  
  dblNoOfLots as dblNoOfLot,
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity,
  cv.intContractHeaderId,null as intFutOptTransactionHeaderId  
  ,intPricingTypeId
  ,cv.strContractType
  ,cv.intCommodityId
  ,cv.intCompanyLocationId
  ,cv.intFutureMarketId
  ,dtmFutureMonthsDate
  ,ysnExpired
	   	 INTO #ContractTransaction
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=cv.intFutureMarketId and cv.intContractStatusId <> 3
  JOIN tblICCommodityUnitMeasure um1 on um1.intCommodityId=cv.intCommodityId and um1.intUnitMeasureId=ffm.intUnitMeasureId  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(SELECT intItemId FROM tblICItem ici    
																		 JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
																		 AND ici.intProductLineId=pl.intCommodityProductLineId)  
  LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  
  LEFT JOIN tblARProductType pt on pt.intProductTypeId=ic.intProductTypeId
  LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId AND um.intUnitMeasureId=cv.intUnitMeasureId
  WHERE @intCommodityId=cv.intCommodityId and cv.intFutureMarketId=@intFutureMarketId

SELECT   
  strContractType+' - '+pl.strDescription +'(Delta='+convert(nvarchar,left(pl.dblDeltaPercent,4))+'%)' as strAccountNumber,
  cv.strFutureMonth as strFutureMonth,
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,
   -dblNoOfLots as dblNoOfLot,  
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity  
  , cv.intContractHeaderId,
  null as intFutOptTransactionHeaderId 
  ,intPricingTypeId	
  ,cv.strContractType
  ,cv.intCommodityId
  ,cv.intCompanyLocationId
  ,cv.intFutureMarketId
  ,ysnExpired
  ,dtmFutureMonthsDate INTO #DeltaPrecent
FROM vyuCTContractDetailView cv  
JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=cv.intFutureMarketId and cv.intContractStatusId <> 3
JOIN tblICCommodityUnitMeasure um1 on um1.intCommodityId=cv.intCommodityId and um1.intUnitMeasureId=ffm.intUnitMeasureId  
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
JOIN tblICItem ic on ic.intItemId=cv.intItemId  
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId   
AND ic.intProductLineId=pl.intCommodityProductLineId  
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId
where @intCommodityId=cv.intCommodityId and cv.intFutureMarketId=@intFutureMarketId

BEGIN  
INSERT INTO @List(Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId)  
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,ROUND(dblNoOfContract,@intDecimal) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId FROM(  
  
SELECT * FROM(  
  SELECT  DISTINCT 'Physical position / Basis risk' as Selection,
  'a. Unpriced - (Balance to be Priced)' as PriceStatus,
  'Previous' as strFutureMonth,  
  strAccountNumber,  
  case when strContractType='Purchase' then dblNoOfContract else -(abs(dblNoOfContract)) end as dblNoOfContract,
  strTradeNo, 
  TransactionDate,  
  TranType, 
  CustVendor,  
  case when strContractType='Purchase' then -(abs(dblNoOfLot)) else dblNoOfLot end dblNoOfLot,  
  case when strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end as dblQuantity, 
  intContractHeaderId,
  NULL as intFutOptTransactionHeaderId  
  FROM #ContractTransaction 
  WHERE ysnExpired=0 and intPricingTypeId <> 1 AND dtmFutureMonthsDate < @dtmFutureMonthsDate AND intCommodityId=@intCommodityId  
   AND intCompanyLocationId= CASE WHEN isnull(@intCompanyLocationId,0)=0 then intCompanyLocationId else @intCompanyLocationId end
   AND intFutureMarketId=@intFutureMarketId   
      
  UNION    
  SELECT DISTINCT  'Physical position / Basis risk'  as Selection,
  'a. Unpriced - (Balance to be Priced)' as PriceStatus,
  strFutureMonth,  
  strAccountNumber,  
  case when strContractType='Purchase' then dblNoOfContract else -(abs(dblNoOfContract)) end as dblNoOfContract,  
  strTradeNo, 
  TransactionDate,  
  TranType, 
  CustVendor,  
  case when strContractType='Purchase' then -(abs(dblNoOfLot)) else dblNoOfLot end dblNoOfLot,  
  case when strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end as dblQuantity, 
  intContractHeaderId,
  null as intFutOptTransactionHeaderId    
  FROM #ContractTransaction 
  WHERE ysnExpired=0 AND intPricingTypeId <> 1   
     AND intCommodityId=@intCommodityId AND intCompanyLocationId= CASE WHEN ISNULL(@intCompanyLocationId,0)=0 THEN intCompanyLocationId ELSE @intCompanyLocationId end 
     AND intFutureMarketId=@intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1    
  
UNION   
  
SELECT * FROM(  
  SELECT  DISTINCT  'Physical position / Basis risk' AS Selection,
  'b. Priced / Outright - (Outright position)' as PriceStatus,
  'Previous' as strFutureMonth,  
  strAccountNumber,  
  case when strContractType='Purchase' then dblNoOfContract else -(abs(dblNoOfContract)) end as dblNoOfContract,
  strTradeNo, 
  TransactionDate,  
  TranType, 
  CustVendor,  
  case when strContractType='Purchase' then -(abs(dblNoOfLot)) else dblNoOfLot end dblNoOfLot,  
  case when strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end as dblQuantity, 
  intContractHeaderId,
  NULL as intFutOptTransactionHeaderId  
  FROM #ContractTransaction 
  WHERE intPricingTypeId =1 AND dtmFutureMonthsDate < @dtmFutureMonthsDate AND intCommodityId=@intCommodityId  
  AND intCompanyLocationId= CASE WHEN isnull(@intCompanyLocationId,0)=0 then intCompanyLocationId else @intCompanyLocationId end
  AND intFutureMarketId=@intFutureMarketId 
     
  UNION    
  
  SELECT DISTINCT 'Physical position / Basis risk' as Selection,
  'b. Priced / Outright - (Outright position)' as PriceStatus,
  strFutureMonth,  
  strAccountNumber,  
  case when strContractType='Purchase' then dblNoOfContract else -(abs(dblNoOfContract)) end as dblNoOfContract,  
  strTradeNo, 
  TransactionDate,  
  TranType, 
  CustVendor,  
  case when strContractType='Purchase' then -(abs(dblNoOfLot)) else dblNoOfLot end dblNoOfLot,  
  case when strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end as dblQuantity, 
  intContractHeaderId,
  null as intFutOptTransactionHeaderId    
  FROM #ContractTransaction 
  WHERE ysnExpired=0 AND intPricingTypeId = 1   
     AND intCommodityId=@intCommodityId AND intCompanyLocationId= CASE WHEN ISNULL(@intCompanyLocationId,0)=0 THEN intCompanyLocationId ELSE @intCompanyLocationId end 
     AND intFutureMarketId=@intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
  
UNION  
SELECT * FROM(  
  SELECT DISTINCT 'Specialities & Low grades' as Selection,'a. Unfixed' as PriceStatus,
  strFutureMonth,  
  strAccountNumber,
  case when strContractType='Purchase' then dblNoOfContract else -(abs(dblNoOfContract)) end as dblNoOfContract,
  strTradeNo, 
  TransactionDate,  
  TranType,CustVendor,
  CASE WHEN strContractType='Purchase' then -(abs(dblNoOfLot)) else dblNoOfLot end as dblNoOfLot,
  CASE WHEN strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end as dblQuantity, 
  intContractHeaderId,
  null as intFutOptTransactionHeaderId  
FROM #DeltaPrecent 
WHERE ysnExpired=0 AND intPricingTypeId <> 1   
AND intCommodityId=@intCommodityId 
AND intCompanyLocationId= case when isnull(@intCompanyLocationId,0)=0 then intCompanyLocationId else @intCompanyLocationId end
AND intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
  
UNION  
SELECT * FROM(  
  SELECT DISTINCT 'Specialities & Low grades' as Selection,'b. fixed' as PriceStatus,
   strFutureMonth,  
	  strAccountNumber,
	  case when strContractType='Purchase' then dblNoOfContract else -(abs(dblNoOfContract)) end as dblNoOfContract,
	  strTradeNo, 
	  TransactionDate,  
	  TranType,CustVendor,
	  CASE WHEN strContractType='Purchase' then -(abs(dblNoOfLot)) else dblNoOfLot end as dblNoOfLot,
	  CASE WHEN strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end as dblQuantity, 
	  intContractHeaderId,
	  null as intFutOptTransactionHeaderId  
FROM #DeltaPrecent  
WHERE ysnExpired=0 AND intPricingTypeId = 1   
AND intCommodityId=@intCommodityId  AND intCompanyLocationId= case when isnull(@intCompanyLocationId,0)=0 then intCompanyLocationId else @intCompanyLocationId end 
AND intFutureMarketId=@intFutureMarketId   AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  

  
UNION  
SELECT * FROM(  
  SELECT DISTINCT 'Total speciality delta fixed' as Selection,'a. Delta %' as PriceStatus,
    strFutureMonth,  
	  strAccountNumber,
	  case when strContractType='Purchase' then dblNoOfContract else -(abs(dblNoOfContract)) end as dblNoOfContract,
	  strTradeNo, 
	  TransactionDate,  
	  TranType,CustVendor,
	  CASE WHEN strContractType='Purchase' then -(abs(dblNoOfLot)) else dblNoOfLot end as dblNoOfLot,
	  CASE WHEN strContractType='Purchase' then dblQuantity else -(abs(dblQuantity)) end as dblQuantity, 
	  intContractHeaderId,
	  null as intFutOptTransactionHeaderId  
FROM #DeltaPrecent  
WHERE ysnExpired=0 AND intPricingTypeId = 1   
AND intCommodityId=@intCommodityId  AND intCompanyLocationId= case when isnull(@intCompanyLocationId,0)=0 then intCompanyLocationId else @intCompanyLocationId end 
AND intFutureMarketId=@intFutureMarketId   AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  

UNION  
  
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,(dblNoOfContract) as dblNoOfContract,  
  strTradeNo, TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity, intContractHeaderId,intFutOptTransactionHeaderId   from  
(  
SELECT DISTINCT 'Terminal position (a. in lots )' as Selection,'Broker Account' as PriceStatus,  
  fm.strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,  
  ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
  case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,   
  case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end as dblQuantity  
  ,null as intContractHeaderId,ft.intFutOptTransactionHeaderId  
FROM tblRKFutOptTransaction ft  
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
JOIN tblEMEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId=1  
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0
WHERE  ft.intCommodityId=@intCommodityId 
AND intLocationId= case when isnull(@intCompanyLocationId,0)=0 then intLocationId else @intCompanyLocationId end 
AND intLocationId= case when isnull(@intCompanyLocationId,0)=0 then intLocationId else @intCompanyLocationId end
AND ft.intFutureMarketId=@intFutureMarketId   
and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)t  
   
UNION   
  
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,  
  dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intUOMId,(dblNoOfContract))*@dblContractSize as dblNoOfContract,  
  strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intUOMId,dblQuantity) dblQuantity
  ,intContractHeaderId,intFutOptTransactionHeaderId  from  
(  
SELECT DISTINCT 'Terminal position (b. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,  
  strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,  
  ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
  case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,   
  case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity,um.intCommodityUnitMeasureId  
  , null as intContractHeaderId,ft.intFutOptTransactionHeaderId 
FROM tblRKFutOptTransaction ft  
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
JOIN tblEMEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId = 1  
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
JOIN tblRKFutureMarket mar on mar.intFutureMarketId=ft.intFutureMarketId
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=ft.intCommodityId and um.intUnitMeasureId=mar.intUnitMeasureId
WHERE  ft.intCommodityId=@intCommodityId AND intLocationId= case when isnull(@intCompanyLocationId,0)=0 then intLocationId else @intCompanyLocationId end AND ft.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)t  
  
UNION  
  
  SELECT DISTINCT 'Delta options' as Selection,'Broker Account' as PriceStatus,  
     strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,
       case when ft.strBuySell='Buy' then (ft.intNoOfContract-isnull((SELECT sum(intMatchQty)  FROM tblRKOptionsMatchPnS l WHERE l.intLFutOptTransactionId=ft.intFutOptTransactionId),0) )
         else -(ft.intNoOfContract-isnull((SELECT sum(intMatchQty)  FROM tblRKOptionsMatchPnS s WHERE s.intSFutOptTransactionId=ft.intFutOptTransactionId),0)) end *
            isnull((
                                         SELECT TOP 1 dblDelta
                                         FROM tblRKFuturesSettlementPrice sp
                                         INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
                                         WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
                                         AND ft.dblStrike = mm.dblStrike
                                         ORDER BY dtmPriceDate DESC
                           ),0)     
          as dblNoOfContract,  
    ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
        case when ft.strBuySell='Buy' then (ft.intNoOfContract-isnull((SELECT sum(intMatchQty)  FROM tblRKOptionsMatchPnS l WHERE l.intLFutOptTransactionId=ft.intFutOptTransactionId),0) )
         else -(ft.intNoOfContract-isnull((SELECT sum(intMatchQty)  FROM tblRKOptionsMatchPnS s WHERE s.intSFutOptTransactionId=ft.intFutOptTransactionId),0)) end as dblNoOfLot,   
     isnull((SELECT TOP 1 dblDelta
                                         FROM tblRKFuturesSettlementPrice sp
                                         INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
                                         WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
                                         AND ft.dblStrike = mm.dblStrike
                                         ORDER BY dtmPriceDate DESC
                           ),0) as dblDelta
                           , null as intContractHeaderId,ft.intFutOptTransactionHeaderId 
       FROM tblRKFutOptTransaction ft  
       JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
       JOIN tblEMEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId=2  
       JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
       WHERE  intCommodityId=@intCommodityId AND intLocationId= case when isnull(@intCompanyLocationId,0)=0 then intLocationId else @intCompanyLocationId end AND ft.intFutureMarketId=@intFutureMarketId   
       and dtmFutureMonthsDate >= @dtmFutureMonthsDate 
       and intFutOptTransactionId not in(select intFutOptTransactionId from tblRKOptionsPnSExercisedAssigned) 
        and intFutOptTransactionId not in(select intFutOptTransactionId from tblRKOptionsPnSExpired)
       )t  
UNION  
  
SELECT DISTINCT 'F&O' as Selection,'F&O' as PriceStatus,strFutureMonth,'F&O' as strAccountNumber,(dblNoOfContract) as dblNoOfContract,  
  strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId   from (  
  SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,(dblNoOfContract) as dblNoOfContract,  
  strTradeNo, TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity, intContractHeaderId,intFutOptTransactionHeaderId  from  
   (  
   SELECT DISTINCT 'Terminal position (a. in lots )' as Selection,'Broker Account' as PriceStatus,  
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
   )t  
  Union  
        SELECT DISTINCT 'Delta options' as Selection,'Broker Account' as PriceStatus,  
     strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,
       case when ft.strBuySell='Buy' then (ft.intNoOfContract-isnull((SELECT sum(intMatchQty)  FROM tblRKOptionsMatchPnS l WHERE l.intLFutOptTransactionId=ft.intFutOptTransactionId),0) )
         else -(ft.intNoOfContract-isnull((SELECT sum(intMatchQty)  FROM tblRKOptionsMatchPnS s WHERE s.intSFutOptTransactionId=ft.intFutOptTransactionId),0)) end *
            isnull((
                                         SELECT TOP 1 dblDelta
                                         FROM tblRKFuturesSettlementPrice sp
                                         INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
                                         WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
                                         AND ft.dblStrike = mm.dblStrike
                                         ORDER BY dtmPriceDate DESC
                           ),0)
         
          as dblNoOfContract,  
    ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
        case when ft.strBuySell='Buy' then (ft.intNoOfContract-isnull((SELECT sum(intMatchQty)  FROM tblRKOptionsMatchPnS l WHERE l.intLFutOptTransactionId=ft.intFutOptTransactionId),0) )
         else -(ft.intNoOfContract-isnull((SELECT sum(intMatchQty)  FROM tblRKOptionsMatchPnS s WHERE s.intSFutOptTransactionId=ft.intFutOptTransactionId),0)) end as dblNoOfLot,   
     isnull((SELECT TOP 1 dblDelta
                                         FROM tblRKFuturesSettlementPrice sp
                                         INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
                                         WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
                                         AND ft.dblStrike = mm.dblStrike
                                         ORDER BY dtmPriceDate DESC
                           ),0) as dblDelta
                           , null as intContractHeaderId,ft.intFutOptTransactionHeaderId 
       FROM tblRKFutOptTransaction ft  
       JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
       JOIN tblEMEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId=2  
       JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
       WHERE  intCommodityId=@intCommodityId AND intLocationId= case when isnull(@intCompanyLocationId,0)=0 then intLocationId else @intCompanyLocationId end AND ft.intFutureMarketId=@intFutureMarketId   
       and dtmFutureMonthsDate >= @dtmFutureMonthsDate 
       and intFutOptTransactionId not in(select intFutOptTransactionId from tblRKOptionsPnSExercisedAssigned) 
        and intFutOptTransactionId not in(select intFutOptTransactionId from tblRKOptionsPnSExpired)
       )t  

UNION  
  
SELECT DISTINCT 'Total F&O(b. in ' + @strUnitMeasure + ' )' AS Selection, 'F&O' AS PriceStatus, strFutureMonth, 'F&O' AS strAccountNumber, dblNoOfContract, strTradeNo, TransactionDate, TranType, CustVendor, dblNoOfLot, dblQuantity
, intContractHeaderId,intFutOptTransactionHeaderId 
FROM (
       SELECT strFutureMonth, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intUOMId, (dblNoOfContract)) * @dblContractSize AS dblNoOfContract, strTradeNo, TransactionDate, TranType, CustVendor, dblNoOfLot, dblQuantity, intCommodityUnitMeasureId
       ,intContractHeaderId,intFutOptTransactionHeaderId 
       FROM (
              SELECT DISTINCT 'Terminal position (b. in ' + @strUnitMeasure + ' )' AS Selection, 'Broker Account' AS PriceStatus, 
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
       
       UNION
       
       SELECT strFutureMonth, dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId, @intUOMId, (dblNoOfContract))*dblDelta* dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intUOMId,@dblContractSize) AS dblNoOfContract, strTradeNo, TransactionDate, TranType, CustVendor, dblNoOfLot, dblQuantity, intCommodityUnitMeasureId
       ,intContractHeaderId,intFutOptTransactionHeaderId 
       FROM (
              SELECT DISTINCT 'Delta options' AS Selection, 'Broker Account' AS PriceStatus, strFutureMonth, e.strName + '-' + strAccountNumber AS strAccountNumber, CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract) ELSE - (ft.intNoOfContract) END AS dblNoOfContract, ft.strInternalTradeNo AS strTradeNo, ft.dtmTransactionDate AS TransactionDate, strBuySell AS TranType, e.strName AS CustVendor, CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract) ELSE - (ft.intNoOfContract) END AS dblNoOfLot, CASE WHEN ft.strBuySell = 'Buy' THEN (ft.intNoOfContract * @dblContractSize) ELSE - (ft.intNoOfContract * @dblContractSize) END dblQuantity, um.intCommodityUnitMeasureId, (
                           SELECT TOP 1 dblDelta
                                         FROM tblRKFuturesSettlementPrice sp
                                         INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
                                         WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
                                         AND ft.dblStrike = mm.dblStrike
                                         ORDER BY dtmPriceDate DESC
                           ) AS dblDelta
                           , null as intContractHeaderId,ft.intFutOptTransactionHeaderId 
              FROM tblRKFutOptTransaction ft
              INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
              INNER JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
              INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
              INNER JOIN tblRKFutureMarket mar ON mar.intFutureMarketId = ft.intFutureMarketId
              LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = ft.intCommodityId AND um.intUnitMeasureId = mar.intUnitMeasureId
              WHERE ft.intCommodityId = @intCommodityId AND intLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intLocationId ELSE @intCompanyLocationId END AND ft.intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate
              ) t
       ) T
---- Taken inventory Qty ----------

     
INSERT INTO @List(Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId )  
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,sum(dblNoOfContract),strTradeNo,TransactionDate,TranType,CustVendor,sum(dblNoOfLot), sum(dblQuantity)
,intContractHeaderId,intFutOptTransactionHeaderId 
FROM(
       SELECT  'Net market risk'  AS Selection,'Net market risk' as PriceStatus,strFutureMonth
                     ,'Market Risk' as strAccountNumber,sum(dblNoOfContract) dblNoOfContract,
                     strTradeNo, TransactionDate,TranType,CustVendor,sum(dblNoOfLot) dblNoOfLot, sum(dblQuantity)  dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId  
       FROM @List WHERE Selection='Physical position / Basis risk' 
                                    and PriceStatus = 'b. Priced / Outright - (Outright position)' 
       GROUP BY strFutureMonth,strTradeNo, TransactionDate,TranType,CustVendor,intContractHeaderId,intFutOptTransactionHeaderId  
       UNION
       SELECT 'Net market risk'  AS Selection,'Net market risk'  as PriceStatus,strFutureMonth
                     ,'Market Risk' as strAccountNumber,sum(dblNoOfContract) dblNoOfContract,
                     strTradeNo, TransactionDate,TranType,CustVendor,sum(dblNoOfLot) dblNoOfLot, sum(dblQuantity)  dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId  
       FROM @List WHERE PriceStatus ='F&O' and Selection LIKE ('Total F&O%')
       GROUP BY strFutureMonth,strAccountNumber,strTradeNo, TransactionDate,TranType,CustVendor,intContractHeaderId,intFutOptTransactionHeaderId  
       
       UNION 
        SELECT 'Net market risk'  AS Selection, 'Net market risk' as PriceStatus,strFutureMonth
                     ,'Market Risk' as strAccountNumber,sum(dblNoOfContract) dblNoOfContract,
                     strTradeNo, TransactionDate,TranType,CustVendor,sum(dblNoOfLot) dblNoOfLot, sum(dblQuantity)  dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId  
       FROM @List WHERE PriceStatus ='a. Delta %' and Selection = ('Total speciality delta fixed')
       GROUP BY strFutureMonth,strAccountNumber,strTradeNo, TransactionDate,TranType,CustVendor,intContractHeaderId,intFutOptTransactionHeaderId  
       )t 
GROUP BY Selection,PriceStatus,strAccountNumber,strFutureMonth,strTradeNo, TransactionDate,TranType,CustVendor,intContractHeaderId,intFutOptTransactionHeaderId  

--- Switch Position ---------
INSERT INTO @List(Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId )  
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,(dblNoOfContract),strTradeNo,TransactionDate,TranType,CustVendor,(dblNoOfLot), (dblQuantity),intContractHeaderId,intFutOptTransactionHeaderId  
FROM(
       SELECT  'Switch position' as Selection,'Switch position' as PriceStatus,strFutureMonth
                     ,'Switch position' as strAccountNumber,(dblNoOfLot) dblNoOfContract,
                     strTradeNo, TransactionDate,TranType,CustVendor,(dblNoOfLot) dblNoOfLot, (dblQuantity)  dblQuantity,intContractHeaderId,intFutOptTransactionHeaderId   
       FROM @List WHERE Selection='Physical position / Basis risk' 
           and PriceStatus = 'a. Unpriced - (Balance to be Priced)' and strAccountNumber like '%Purchase%'
       UNION
       SELECT  'Switch position' as Selection,'Switch position' as PriceStatus,strFutureMonth
                     ,'Switch position' as strAccountNumber,((dblNoOfLot)) dblNoOfContract,
                     strTradeNo, TransactionDate,TranType,CustVendor,dblNoOfLot dblNoOfLot,  dblQuantity  dblQuantity ,intContractHeaderId,intFutOptTransactionHeaderId  
       FROM @List WHERE Selection='Physical position / Basis risk' 
           and PriceStatus = 'a. Unpriced - (Balance to be Priced)'  and strAccountNumber like '%Sale%'
       UNION 
       SELECT  'Switch position' as Selection,'Switch position' as PriceStatus,strFutureMonth
                     ,'Switch position' as strAccountNumber,dblNoOfLot dblNoOfContract,
                     strTradeNo, TransactionDate,TranType,CustVendor,dblNoOfLot dblNoOfLot, dblQuantity  dblQuantity ,intContractHeaderId,intFutOptTransactionHeaderId  
       FROM @List WHERE PriceStatus ='F&O' and Selection ='F&O'
       )t 
END


SELECT TOP 1 @strFutureMonth=strFutureMonth FROM @List where  strFutureMonth<>'Previous' order by convert(datetime,'01 '+strFutureMonth) asc

UPDATE @List set strFutureMonth=@strFutureMonth where Selection='Switch position' and strFutureMonth='Previous'
UPDATE @List set strFutureMonth=@strFutureMonth where Selection='Net market risk'  and strFutureMonth='Previous'

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

 
update @List set intOrderByHeading=1 WHERE Selection in ('Physical position / Differential cover','Physical position / Basis risk')
update @List set intOrderByHeading=2 WHERE Selection = 'Specialities & Low grades'
update @List set intOrderByHeading=3 WHERE Selection = 'Total speciality delta fixed'
update @List set intOrderByHeading=4 WHERE Selection = 'Terminal position (a. in lots )'
update @List set intOrderByHeading=5 WHERE Selection = 'Terminal position (Avg Long Price)'
update @List set intOrderByHeading=6 WHERE Selection like ('%Terminal position (b.%')
update @List set intOrderByHeading=7 WHERE Selection = 'Delta options'
update @List set intOrderByHeading=8 WHERE Selection = 'F&O'
update @List set intOrderByHeading=9 WHERE Selection like ('%Total F&O(b. in%')
update @List set intOrderByHeading=10 WHERE Selection in('Outright coverage','Net market risk')
update @List set intOrderByHeading=13 WHERE Selection in('Switch position','Futures required')
  
DECLARE @ListFinal as Table (  
     intRowNumber1 int identity(1,1),  
        intRowNumber int,
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
intRowNumber,Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @List    
    WHERE Selection NOT in('Switch position','Futures required')
ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC

INSERT INTO @ListFinal
SELECT
intRowNumber,Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId    FROM @List    
    WHERE  Selection in('Switch position','Futures required')
ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END,intOrderByHeading,PriceStatus ASC

SELECT intRowNumber,Selection,PriceStatus,strFutureMonth,strAccountNumber, CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, 
       dblQuantity,intOrderByHeading,intContractHeaderId,intFutOptTransactionHeaderId  from @ListFinal --order by intRowNumber1 asc

GO