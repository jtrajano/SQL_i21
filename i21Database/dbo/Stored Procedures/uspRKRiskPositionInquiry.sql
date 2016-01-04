CREATE PROC [dbo].[uspRKRiskPositionInquiry]  
 @intCommodityId INTEGER,  
 @intCompanyLocationId INTEGER,  
 @intFutureMarketId INTEGER,  
 @intFutureMonthId INTEGER,  
 @intUOMId INTEGER,  
 @intDecimal INTEGER   
AS  
  
DECLARE @strUnitMeasure nvarchar(50)  
DECLARE @dtmFutureMonthsDate datetime  
DECLARE @dblContractSize int  
DECLARE @ysnIncludeInventoryHedge BIT  
DECLARE @strRiskView nvarchar(50)  
  
SELECT @dblContractSize= convert(int,dblContractSize) FROM tblRKFutureMarket WHERE intFutureMarketId=@intFutureMarketId  
SELECT TOP 1 @dtmFutureMonthsDate=dtmFutureMonthsDate FROM tblRKFuturesMonth WHERE intFutureMonthId=@intFutureMonthId  
SELECT top 1 @strUnitMeasure= strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId=@intUOMId  
select @intUOMId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId and intUnitMeasureId=@intUOMId  
SELECT @ysnIncludeInventoryHedge = ysnIncludeInventoryHedge FROM tblRKCompanyPreference  
SELECT @strRiskView = strRiskView FROM tblRKCompanyPreference  
  
DECLARE @List as Table (  
     intRowNumber int identity(1,1),  
     Selection  nvarchar(200),  
     PriceStatus  nvarchar(50),  
     strFutureMonth  nvarchar(20),  
     strAccountNumber  nvarchar(200),  
     dblNoOfContract  decimal(24,10),  
     strTradeNo  nvarchar(200),  
     TransactionDate  datetime,  
     TranType  nvarchar(50),  
     CustVendor nvarchar(50),       
     dblNoOfLot decimal(24,10),  
     dblQuantity decimal(24,10)       
     )  
       
IF (isnull(@intCompanyLocationId,0) <> 0)  
BEGIN  
INSERT INTO @List(Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity)  
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,ROUND(dblNoOfContract,@intDecimal) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity FROM(  
  
SELECT * FROM(  
  SELECT  DISTINCT case when @strRiskView='Processor' then '1.Physical position / Differential cover' else '1.Physical position / Basis risk' end as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,'Previous' as strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,  
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblNoOfContract,  
  LEFT(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,  
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,  
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity  
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)  
  LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  
  LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE fm.ysnExpired=1 and intPricingTypeId <> 1 AND cv.strContractType='Purchase'  
   AND dtmFutureMonthsDate <= @dtmFutureMonthsDate   
   AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId   
      
  UNION    
  SELECT DISTINCT case when @strRiskView='Processor' then '1.Physical position / Differential cover' else '1.Physical position / Basis risk' end as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0)
 end) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity  
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
  LEFT JOIN tblARProductType pt on pt.intProductTypeId=ic.intProductTypeId    
  LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  
  LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId <> 1   
     AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId   
     AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
  
UNION   
  
SELECT * FROM(  
  SELECT  DISTINCT case when @strRiskView='Processor' then '1.Physical position / Basis risk' else '1.Physical position / Basis risk' end as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,'Previous' as strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  isnull(dblBalance,0)) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,-(dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)  ) as dblNoOfLot,  
  -dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, isnull(dblBalance,0)) as dblQuantity  
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
      LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  
      LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE fm.ysnExpired=1 and intPricingTypeId <> 1 AND cv.strContractType='sale'   
     AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId   
     AND dtmFutureMonthsDate <= @dtmFutureMonthsDate        
  UNION    
  SELECT DISTINCT case when @strRiskView='Processor' then '1.Physical position / Differential cover' else '1.Physical position / Basis risk' end as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, isnull(dblBalance,0)) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,-(dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)  ) as dblNoOfLot,   
   dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, isnull(dblBalance,0)) as dblQuantity  
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
        LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  
        LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE fm.ysnExpired=0 and strContractType='sale' AND intPricingTypeId <> 1   
     AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId   
     and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
  
UNION   
  
SELECT * FROM(  
  SELECT  DISTINCT case when @strRiskView='Processor' then '1.Physical position / Differential cover' else '1.Physical position / Basis risk' end as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,'Previous' as strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,   
   dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity   
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
           LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId   
           LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId     
  WHERE fm.ysnExpired=1 and intPricingTypeId = 1 AND cv.strContractType='Purchase'   
     AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId   
     AND dtmFutureMonthsDate <= @dtmFutureMonthsDate   
  UNION    
  SELECT DISTINCT case when @strRiskView='Processor' then '1.Physical position / Differential cover' else '1.Physical position / Basis risk' end as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0)
 end) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,   
   dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity  
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
               LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  
               LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1   
     AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId   
     and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
  
UNION   
  
SELECT * FROM(  
  SELECT  DISTINCT case when @strRiskView='Processor' then '1.Physical position / Differential cover' else '1.Physical position / Basis risk' end as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,'Previous' as strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,  
  -(dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)  ) as dblNoOfLot,   
   -dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity  
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)  
             LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId   
             LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE fm.ysnExpired=1 and intPricingTypeId = 1 AND cv.strContractType='sale'   
     AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId   
     AND dtmFutureMonthsDate <= @dtmFutureMonthsDate   
  UNION    
    
  SELECT DISTINCT case when @strRiskView='Processor' then '1.Physical position / Differential cover' else '1.Physical position / Basis risk' end as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, isnull(dblBalance,0)) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,-(dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)  ) as dblNoOfLot,   
   dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,isnull(dblBalance,0)) as dblQuantity  
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
  LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId   
  LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId          
  WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId = 1   
     AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId   
     and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
UNION  
SELECT * FROM(  
  SELECT DISTINCT '2.Specialities & Low grades' as Selection,'a. Unfixed' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+pl.strDescription +'(Delta='+convert(nvarchar,left(pl.dblDeltaPercent,4))+'%)' as strAccountNumber,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity  
FROM vyuCTContractDetailView cv  
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
JOIN tblICItem ic on ic.intItemId=cv.intItemId  
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId   
AND ic.intProductLineId=pl.intCommodityProductLineId  
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId <> 1   
AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
UNION  
SELECT * FROM(  
  SELECT DISTINCT '2.Specialities & Low grades' as Selection,'a. Unfixed' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+pl.strDescription +'(Delta='+convert(nvarchar,left(pl.dblDeltaPercent,4))+'%)' as strAccountNumber,  
  -dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, isnull(dblBalance,0)) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  isnull(dblBalance,0)) as dblQuantity  
FROM vyuCTContractDetailView cv  
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
JOIN tblICItem ic on ic.intItemId=cv.intItemId  
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId AND ic.intProductLineId=pl.intCommodityProductLineId  
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
WHERE fm.ysnExpired=0 and strContractType='Sale' AND intPricingTypeId <> 1   
AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
  
UNION  
SELECT * FROM(  
  SELECT DISTINCT '2.Specialities & Low grades' as Selection,'a. fixed' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+pl.strDescription +'(Delta='+convert(nvarchar,left(pl.dblDeltaPercent,4))+'%)' as strAccountNumber,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity  
FROM vyuCTContractDetailView cv  
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
JOIN tblICItem ic on ic.intItemId=cv.intItemId  
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId   
AND ic.intProductLineId=pl.intCommodityProductLineId  
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1   
AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
UNION  
SELECT * FROM(  
  SELECT DISTINCT '2.Specialities & Low grades' as Selection,'a. fixed' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+pl.strDescription +'(Delta='+convert(nvarchar,left(pl.dblDeltaPercent,4))+'%)' as strAccountNumber,  
  -dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, isnull(dblBalance,0)) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  isnull(dblBalance,0)) as dblQuantity  
FROM vyuCTContractDetailView cv  
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
JOIN tblICItem ic on ic.intItemId=cv.intItemId  
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId   
AND ic.intProductLineId=pl.intCommodityProductLineId  
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
WHERE fm.ysnExpired=0 and strContractType='Sale' AND intPricingTypeId = 1   
AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
  
UNION  
SELECT * FROM(  
  SELECT DISTINCT '3.Total speciality delta fixed' as Selection,'a. Delta %' as PriceStatus,cv.strFutureMonth,    
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,  
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)*isnull(dblDeltaPercent,0)/100 as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity  
FROM vyuCTContractDetailView cv  
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
JOIN tblICItem ic on ic.intItemId=cv.intItemId  
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId   
AND ic.intProductLineId=pl.intCommodityProductLineId  
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1   
AND cv.intCommodityId=@intCommodityId AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
UNION  
SELECT * FROM(  
  SELECT DISTINCT '3.Total speciality delta fixed' as Selection,'a. Delta %' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,  
  -dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, isnull(dblBalance,0))*isnull(dblDeltaPercent,0)/100 as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  isnull(dblBalance,0)) as dblQuantity  
FROM vyuCTContractDetailView cv  
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
JOIN tblICItem ic on ic.intItemId=cv.intItemId  
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId   
AND ic.intProductLineId=pl.intCommodityProductLineId  
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
WHERE fm.ysnExpired=0 and strContractType='Sale' AND intPricingTypeId = 1   
AND cv.intCommodityId=@intCommodityId  AND intCompanyLocationId= @intCompanyLocationId AND cv.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
UNION  
  
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,(dblNoOfContract) as dblNoOfContract,  
  strTradeNo, TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from  
(  
SELECT DISTINCT '4.Terminal position (a. in lots )' as Selection,'Broker Account' as PriceStatus,  
   strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,  
  ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
  case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,   
  case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end as dblQuantity  
FROM tblRKFutOptTransaction ft  
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
JOIN tblEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId=1  
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId   
and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)t  
  
  
UNION   
  
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,  
  dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intUOMId,(dblNoOfContract))*@dblContractSize as dblNoOfContract,  
  strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from  
(  
SELECT DISTINCT '5.Terminal position (b. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,  
  strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,  
  ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
  case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,   
  case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity,um.intCommodityUnitMeasureId  
FROM tblRKFutOptTransaction ft  
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
JOIN tblEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId = 1  
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
JOIN tblRKFutureMarket mar on mar.intFutureMarketId=ft.intFutureMarketId
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=ft.intCommodityId and um.intUnitMeasureId=mar.intUnitMeasureId
WHERE  ft.intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)t  
  
UNION  
  
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract*dblDelta as dblNoOfContract,  
  strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity*dblDelta from  
(  
SELECT DISTINCT '6.Delta options' as Selection,'Broker Account' as PriceStatus,  
   strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,  
  ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
  case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,   
  case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end dblQuantity,  
  (SELECT top 1 dblDelta FROM tblRKFuturesSettlementPrice sp  
   JOIN tblRKOptSettlementPriceMarketMap mm on sp.intFutureSettlementPriceId=mm.intFutureSettlementPriceId   
   WHERE intFutureMarketId=ft.intFutureMarketId and mm.intOptionMonthId=ft.intOptionMonthId and   
   mm.intTypeId = case when ft.strOptionType='Put' then 1 else 2 end Order By dtmPriceDate desc) as dblDelta  
FROM tblRKFutOptTransaction ft  
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
JOIN tblEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId=2  
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId   
and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)t  
UNION  
  
SELECT DISTINCT '7.F&O' as Selection,'F&O' as PriceStatus,strFutureMonth,'F&O' as strAccountNumber,(dblNoOfContract) as dblNoOfContract,  
  strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from (  
  SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,(dblNoOfContract) as dblNoOfContract,  
  strTradeNo, TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from  
   (  
   SELECT DISTINCT '4.Terminal position (a. in lots )' as Selection,'Broker Account' as PriceStatus,  
      strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,  
     ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
     case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,   
     case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity  
   FROM tblRKFutOptTransaction ft  
   JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
   JOIN tblEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId=1  
   JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
   WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId   
   and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
   )t  
  Union  
   SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract*dblDelta as dblNoOfContract,  
   strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity*dblDelta from  
   (  
   SELECT DISTINCT '6.Delta options' as Selection,'Broker Account' as PriceStatus,  
      strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,  
     ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
     case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,   
     case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end dblQuantity,  
     (SELECT top 1 dblDelta FROM tblRKFuturesSettlementPrice sp  
      JOIN tblRKOptSettlementPriceMarketMap mm on sp.intFutureSettlementPriceId=mm.intFutureSettlementPriceId   
      WHERE intFutureMarketId=ft.intFutureMarketId and mm.intOptionMonthId=ft.intOptionMonthId and   
      mm.intTypeId = case when ft.strOptionType='Put' then 1 else 2 end Order By dtmPriceDate desc) as dblDelta  
   FROM tblRKFutOptTransaction ft  
   JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
   JOIN tblEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId=2  
   JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
   WHERE  intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId   
   and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
   )t  
) t   
UNION  
  
SELECT DISTINCT '8.Total F&O(b. in '+ @strUnitMeasure +' )' as Selection,'F&O' as PriceStatus,strFutureMonth,'F&O' as strAccountNumber,
	 dblNoOfContract,  
  strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from (  
  SELECT strFutureMonth,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intUOMId,(dblNoOfContract))*@dblContractSize as dblNoOfContract,  
  strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity,intCommodityUnitMeasureId from  
  (  
SELECT DISTINCT '5.Terminal position (b. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,  
  strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,  
  ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
  case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,   
  case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity,um.intCommodityUnitMeasureId  
FROM tblRKFutOptTransaction ft  
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
JOIN tblEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId = 1  
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
JOIN tblRKFutureMarket mar on mar.intFutureMarketId=ft.intFutureMarketId
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=ft.intCommodityId and um.intUnitMeasureId=mar.intUnitMeasureId
WHERE  ft.intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate   
  )t  
  Union  
  SELECT strFutureMonth,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract*dblDelta)) as dblNoOfContract,  
    strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity*dblDelta,intCommodityUnitMeasureId from  
  (  
  SELECT DISTINCT '6.Delta options' as Selection,'Broker Account' as PriceStatus,  
     strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,  
    ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
    case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,   
    case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity,um.intCommodityUnitMeasureId,  
    (SELECT top 1 dblDelta FROM tblRKFuturesSettlementPrice sp  
     JOIN tblRKOptSettlementPriceMarketMap mm on sp.intFutureSettlementPriceId=mm.intFutureSettlementPriceId   
     WHERE intFutureMarketId=ft.intFutureMarketId and mm.intOptionMonthId=ft.intOptionMonthId and   
     mm.intTypeId = case when ft.strOptionType='Put' then 1 else 2 end Order By dtmPriceDate desc) as dblDelta  
  FROM tblRKFutOptTransaction ft  
  JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
  JOIN tblEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId = 2  
  JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
  JOIN tblRKFutureMarket mar on mar.intFutureMarketId=ft.intFutureMarketId
  LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=ft.intCommodityId and um.intUnitMeasureId=mar.intUnitMeasureId
  WHERE  ft.intCommodityId=@intCommodityId AND intLocationId= @intCompanyLocationId AND ft.intFutureMarketId=@intFutureMarketId   
  AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
  )t  
) t   
) T  
--select * from @List
INSERT INTO @List(Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity)  
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,sum(dblNoOfContract),strTradeNo,TransactionDate,TranType,CustVendor,sum(dblNoOfLot), sum(dblQuantity)
FROM(
	 SELECT  CASE WHEN @strRiskView='Processor' THEN '9.Outright coverage' ELSE '9.Net market risk' END AS Selection,'Net market risk' as PriceStatus,strFutureMonth
			 ,case when @strRiskView='Processor' then 'Market Coverage' else 'Market Risk' end as strAccountNumber,sum(dblNoOfContract) dblNoOfContract,
			 strTradeNo, TransactionDate,TranType,CustVendor,sum(dblNoOfLot) dblNoOfLot, sum(dblQuantity)  dblQuantity 
	FROM @List WHERE Selection='1.Physical position / Basis risk'  and PriceStatus = 'b. Priced / Outright - (Outright position)'
	GROUP BY strFutureMonth,strTradeNo, TransactionDate,TranType,CustVendor
	UNION 
	 SELECT  CASE WHEN @strRiskView='Processor' THEN '9.Outright coverage' ELSE '9.Net market risk' END AS Selection,'Net market risk' as PriceStatus,strFutureMonth
			 ,case when @strRiskView='Processor' then 'Market Coverage' else 'Market Risk' end as strAccountNumber,sum(dblNoOfContract) dblNoOfContract,
			 strTradeNo, TransactionDate,TranType,CustVendor,sum(dblNoOfLot) dblNoOfLot, sum(dblQuantity)  dblQuantity
	FROM @List WHERE PriceStatus ='F&O' and Selection LIKE ('8.Total F&O%')
	GROUP BY strFutureMonth,strAccountNumber,strTradeNo, TransactionDate,TranType,CustVendor
	
	UNION 
	 SELECT  CASE WHEN @strRiskView='Processor' THEN '9.Outright coverage' ELSE '9.Net market risk' END AS Selection,'Net market risk' as PriceStatus,strFutureMonth
			 ,case when @strRiskView='Processor' then 'Market Coverage' else 'Market Risk' end as strAccountNumber,sum(dblNoOfContract) dblNoOfContract,
			 strTradeNo, TransactionDate,TranType,CustVendor,sum(dblNoOfLot) dblNoOfLot, sum(dblQuantity)  dblQuantity
	FROM @List WHERE PriceStatus ='a. Delta %' and Selection = ('3.Total speciality delta fixed')
	GROUP BY strFutureMonth,strAccountNumber,strTradeNo, TransactionDate,TranType,CustVendor
	)t 
GROUP BY Selection,PriceStatus,strAccountNumber,strFutureMonth,strTradeNo, TransactionDate,TranType,CustVendor
--- Switch Position ---------
INSERT INTO @List(Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity)  
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,sum(dblNoOfContract),strTradeNo,TransactionDate,TranType,CustVendor,sum(dblNoOfLot), sum(dblQuantity)
FROM(
	 SELECT  case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as Selection,case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as PriceStatus,strFutureMonth
			 ,case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as strAccountNumber,-sum(dblNoOfContract) dblNoOfContract,
			 strTradeNo, TransactionDate,TranType,CustVendor,-sum(dblNoOfLot) dblNoOfLot, sum(dblQuantity)  dblQuantity 
	FROM @List WHERE Selection='1.Physical position / Basis risk'  and PriceStatus = 'a. Unpriced - (Balance to be Priced)' and strAccountNumber like '%Purchase%'
	GROUP BY strFutureMonth,strTradeNo, TransactionDate,TranType,CustVendor
	UNION
	SELECT  case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as Selection,case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as PriceStatus,strFutureMonth
			 ,case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as strAccountNumber,abs (sum(dblNoOfContract)) dblNoOfContract,
			 strTradeNo, TransactionDate,TranType,CustVendor,abs(sum(dblNoOfLot)) dblNoOfLot,  abs(sum(dblQuantity))  dblQuantity 
	FROM @List WHERE Selection='1.Physical position / Basis risk'  and PriceStatus = 'a. Unpriced - (Balance to be Priced)'  and strAccountNumber like '%Sale%'
	GROUP BY strFutureMonth,strTradeNo, TransactionDate,TranType,CustVendor
	UNION 
	SELECT  case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as Selection,case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as PriceStatus,strFutureMonth
			 ,case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as strAccountNumber,sum(dblNoOfContract) dblNoOfContract,
			 strTradeNo, TransactionDate,TranType,CustVendor,sum(dblNoOfLot) dblNoOfLot, sum(dblQuantity)  dblQuantity 
	FROM @List WHERE PriceStatus ='F&O' and Selection = ('7.F&O')
	GROUP BY strFutureMonth,strAccountNumber,strTradeNo, TransactionDate,TranType,CustVendor
	)t 
GROUP BY Selection,PriceStatus,strAccountNumber,strFutureMonth,strTradeNo, TransactionDate,TranType,CustVendor

END

ELSE  
BEGIN  
INSERT INTO @List(Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity)  
  
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,ROUND(dblNoOfContract,@intDecimal) as dblNoOfContract,  
  strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity FROM(  
SELECT * FROM(  
  SELECT  DISTINCT case when @strRiskView='Processor' then '1.Physical position / Differential cover' else '1.Physical position / Basis risk' end as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,'Previous' as strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityName  as CustVendor,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,   
   dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity  
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
          LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId   
          LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  where fm.ysnExpired=1 and intPricingTypeId <> 1 AND cv.strContractType='Purchase'  
   AND dtmFutureMonthsDate <= @dtmFutureMonthsDate   
   AND cv.intCommodityId=@intCommodityId AND cv.intFutureMarketId=@intFutureMarketId   
  UNION    
  SELECT DISTINCT case when @strRiskView='Processor' then '1.Physical position / Differential cover' else '1.Physical position / Basis risk' end as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0)
 end) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,   
   dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity  
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
          LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId   
          LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId <> 1   
     AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId   
     AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
UNION   
  
SELECT * FROM(  
  SELECT  DISTINCT case when @strRiskView='Processor' then '1.Physical position / Differential cover' else '1.Physical position / Basis risk' end as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,'Previous' as strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,-(dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)  ) as dblNoOfLot,   
   -dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity  
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
          LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId   
          LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE fm.ysnExpired=1 and intPricingTypeId <> 1 AND cv.strContractType='sale'   
     AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId   
     AND dtmFutureMonthsDate <= @dtmFutureMonthsDate        
  UNION    
  SELECT DISTINCT case when @strRiskView='Processor' then '1.Physical position / Differential cover' else '1.Physical position / Basis risk' end as Selection,'a. Unpriced - (Balance to be Priced)' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, isnull(dblBalance,0)) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,-(dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)  ) as dblNoOfLot,   
   -dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, isnull(dblBalance,0)) as dblQuantity  
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
          LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId   
          LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE fm.ysnExpired=0 and strContractType='sale' AND intPricingTypeId <> 1   
     AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId   
     and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
  
UNION   
  
SELECT * FROM(  
  SELECT  DISTINCT case when @strRiskView='Processor' then '1.Physical position / Differential cover' else '1.Physical position / Basis risk' end as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,'Previous' as strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,strContractType as TranType, strEntityName  as CustVendor,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,   
   dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity  
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
          LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId   
          LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE fm.ysnExpired=1 and intPricingTypeId = 1 AND cv.strContractType='Purchase'   
     AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId   
     AND dtmFutureMonthsDate <= @dtmFutureMonthsDate   
  UNION    
  SELECT DISTINCT case when @strRiskView='Processor' then '1.Physical position / Differential cover' else '1.Physical position / Basis risk' end as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0)
 end) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,   
   dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity  
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
          LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId   
          LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1   
     AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId   
     and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
  
UNION   
  
SELECT * FROM(  
  SELECT  DISTINCT case when @strRiskView='Processor' then '1.Physical position / Differential cover' else '1.Physical position / Basis risk' end as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,'Previous' as strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  isnull(dblBalance,0)) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,-(dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)  ) as dblNoOfLot,   
   -dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
   isnull(dblBalance,0)) as dblQuantity  
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
          LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId   
          LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE fm.ysnExpired=1 and intPricingTypeId = 1 AND cv.strContractType='sale'   
     AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId   
     AND dtmFutureMonthsDate <= @dtmFutureMonthsDate   
  UNION    
    
  SELECT DISTINCT case when @strRiskView='Processor' then '1.Physical position / Differential cover' else '1.Physical position / Basis risk' end as Selection,'b. Priced / Outright - (Outright position)' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  isnull(dblBalance,0)) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType,   
  strEntityName  as CustVendor,-(dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)  ) as dblNoOfLot,   
   dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
   isnull(dblBalance,0)) as dblQuantity  
  FROM vyuCTContractDetailView cv  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId and cv.intItemId not in(select intItemId from tblICItem ici    
         JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId   
         AND ici.intProductLineId=pl.intCommodityProductLineId)   
          LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId   
          LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
  WHERE fm.ysnExpired=0 AND strContractType='sale' AND intPricingTypeId = 1   
     AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId   
     and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
UNION  
SELECT * FROM(  
  SELECT DISTINCT '2.Specialities & Low grades' as Selection,'a. Unfixed' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+pl.strDescription +'(Delta='+convert(nvarchar,left(pl.dblDeltaPercent,4))+'%)' as strAccountNumber,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity  
FROM vyuCTContractDetailView cv  
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
JOIN tblICItem ic on ic.intItemId=cv.intItemId  
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId   
AND ic.intProductLineId=pl.intCommodityProductLineId  
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId <> 1   
AND cv.intCommodityId=@intCommodityId AND cv.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
UNION  
SELECT * FROM(  
  SELECT DISTINCT '2.Specialities & Low grades' as Selection,'a. Unfixed' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+pl.strDescription +'(Delta='+convert(nvarchar,left(pl.dblDeltaPercent,4))+'%)' as strAccountNumber,  
  -dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, isnull(dblBalance,0)) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  isnull(dblBalance,0)) as dblQuantity  
FROM vyuCTContractDetailView cv  
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
JOIN tblICItem ic on ic.intItemId=cv.intItemId  
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId   
AND ic.intProductLineId=pl.intCommodityProductLineId  
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
WHERE fm.ysnExpired=0 and strContractType='Sale' AND intPricingTypeId <> 1   
AND cv.intCommodityId=@intCommodityId AND cv.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
UNION  
SELECT * FROM(  
  SELECT DISTINCT '2.Specialities & Low grades' as Selection,'a. fixed' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+pl.strDescription +'(Delta='+convert(nvarchar,left(pl.dblDeltaPercent,4))+'%)' as strAccountNumber,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity  
FROM vyuCTContractDetailView cv  
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
JOIN tblICItem ic on ic.intItemId=cv.intItemId  
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId   
AND ic.intProductLineId=pl.intCommodityProductLineId  
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1   
AND cv.intCommodityId=@intCommodityId AND cv.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
UNION  
SELECT * FROM(  
  SELECT DISTINCT '2.Specialities & Low grades' as Selection,'a. fixed' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+pl.strDescription +'(Delta='+convert(nvarchar,left(pl.dblDeltaPercent,4))+'%)' as strAccountNumber,  
  -dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, isnull(dblBalance,0)) as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  isnull(dblBalance,0)) as dblQuantity  
FROM vyuCTContractDetailView cv  
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
JOIN tblICItem ic on ic.intItemId=cv.intItemId  
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId   
AND ic.intProductLineId=pl.intCommodityProductLineId  
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
WHERE fm.ysnExpired=0 and strContractType='Sale' AND intPricingTypeId = 1   
AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
  
UNION  
SELECT * FROM(  
  SELECT DISTINCT '3.Total speciality delta fixed' as Selection,'a. Delta %' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,  
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)*isnull(dblDeltaPercent,0)/100 as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  case when @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end) as dblQuantity  
FROM vyuCTContractDetailView cv  
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
JOIN tblICItem ic on ic.intItemId=cv.intItemId  
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId   
AND ic.intProductLineId=pl.intCommodityProductLineId  
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
WHERE fm.ysnExpired=0 and strContractType='Purchase' AND intPricingTypeId = 1   
AND cv.intCommodityId=@intCommodityId AND cv.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
UNION  
SELECT * FROM(  
  SELECT DISTINCT '3.Total speciality delta fixed' as Selection,'a. Delta %' as PriceStatus,cv.strFutureMonth,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,  
  -dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId, isnull(dblBalance,0))*isnull(dblDeltaPercent,0)/100 as dblNoOfContract,  
  Left(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, dtmStartDate as TransactionDate,  
  strContractType as TranType, strEntityName  as CustVendor,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,CASE WHEN @ysnIncludeInventoryHedge = 0 then isnull(dblBalance,0) else isnull(dblDetailQuantity,0) end)/dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,@dblContractSize)   as dblNoOfLot,-dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUOMId,   
  isnull(dblBalance,0)) as dblQuantity  
FROM vyuCTContractDetailView cv  
JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
JOIN tblICItem ic on ic.intItemId=cv.intItemId  
LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  
JOIN tblICCommodityProductLine pl on ic.intCommodityId=pl.intCommodityId   
AND ic.intProductLineId=pl.intCommodityProductLineId  
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=cv.intUnitMeasureId  
WHERE fm.ysnExpired=0 and strContractType='Sale' AND intPricingTypeId = 1   
AND cv.intCommodityId=@intCommodityId  AND cv.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)T1  
  
UNION  
  
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,(dblNoOfContract) as dblNoOfContract,  
  strTradeNo, TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from  
(  
SELECT DISTINCT '4.Terminal position (a. in lots )' as Selection,'Broker Account' as PriceStatus,  
   strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,  
  ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
  case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,   
  case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity  
FROM tblRKFutOptTransaction ft  
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
JOIN tblEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId=1  
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
WHERE  intCommodityId=@intCommodityId  AND ft.intFutureMarketId=@intFutureMarketId   
and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)t  
UNION   
  
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,  
  dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intUOMId,(dblNoOfContract))*@dblContractSize as dblNoOfContract,  
  strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from  
(  
SELECT DISTINCT '5.Terminal position (b. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,  
  strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,  
  ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
  case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,   
  case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity,um.intCommodityUnitMeasureId  
FROM tblRKFutOptTransaction ft  
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
JOIN tblEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId = 1  
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
JOIN tblRKFutureMarket mar on mar.intFutureMarketId=ft.intFutureMarketId
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=ft.intCommodityId and um.intUnitMeasureId=mar.intUnitMeasureId
WHERE  ft.intCommodityId=@intCommodityId  AND ft.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)t  
UNION   
  
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract*dblDelta as dblNoOfContract,  
  strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity*dblDelta from  
(  
SELECT DISTINCT '6.Delta options' as Selection,'Broker Account' as PriceStatus,  
   strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,  
  ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
  case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,   
  case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end dblQuantity,  
  (SELECT top 1 dblDelta FROM tblRKFuturesSettlementPrice sp  
   JOIN tblRKOptSettlementPriceMarketMap mm on sp.intFutureSettlementPriceId=mm.intFutureSettlementPriceId   
   WHERE intFutureMarketId=ft.intFutureMarketId and mm.intOptionMonthId=ft.intOptionMonthId and   
   mm.intTypeId = case when ft.strOptionType='Put' then 1 else 2 end Order By dtmPriceDate desc) as dblDelta  
FROM tblRKFutOptTransaction ft  
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
JOIN tblEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId=2  
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
WHERE  intCommodityId=@intCommodityId  AND ft.intFutureMarketId=@intFutureMarketId   
and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
)t  
UNION  
  
SELECT DISTINCT '7.F&O' as Selection,'F&O' as PriceStatus,strFutureMonth,'F&O' as strAccountNumber,(dblNoOfContract) as dblNoOfContract,  
  strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from (  
  SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,(dblNoOfContract) as dblNoOfContract,  
  strTradeNo, TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from  
   (  
   SELECT DISTINCT '4.Terminal position (a. in lots )' as Selection,'Broker Account' as PriceStatus,  
      strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,  
     ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
     case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,   
     case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity  
   FROM tblRKFutOptTransaction ft  
   JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
   JOIN tblEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId=1  
   JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
   WHERE  intCommodityId=@intCommodityId  AND ft.intFutureMarketId=@intFutureMarketId   
   and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
   )t  
  Union  
   SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract*dblDelta as dblNoOfContract,  
   strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity*dblDelta from  
   (  
   SELECT DISTINCT '6.Delta options' as Selection,'Broker Account' as PriceStatus,  
      strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,  
     ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
     case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,   
     case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end dblQuantity,  
     (SELECT top 1 dblDelta FROM tblRKFuturesSettlementPrice sp  
      JOIN tblRKOptSettlementPriceMarketMap mm on sp.intFutureSettlementPriceId=mm.intFutureSettlementPriceId   
      WHERE intFutureMarketId=ft.intFutureMarketId and mm.intOptionMonthId=ft.intOptionMonthId and   
      mm.intTypeId = case when ft.strOptionType='Put' then 1 else 2 end Order By dtmPriceDate desc) as dblDelta  
   FROM tblRKFutOptTransaction ft  
   JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
   JOIN tblEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId=2  
   JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
   WHERE  intCommodityId=@intCommodityId  AND ft.intFutureMarketId=@intFutureMarketId   
   and dtmFutureMonthsDate >= @dtmFutureMonthsDate  
   )t  
) t   
UNION  
  
SELECT DISTINCT '8.Total F&O(b. in '+ @strUnitMeasure +' )' as Selection,'F&O' as PriceStatus,strFutureMonth,'F&O' as strAccountNumber,
	 dblNoOfContract,  
  strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity from (  
  SELECT strFutureMonth,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intUOMId,(dblNoOfContract))*@dblContractSize as dblNoOfContract,  
  strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity,intCommodityUnitMeasureId from  
  (  
SELECT DISTINCT '5.Terminal position (b. in '+ @strUnitMeasure +' )' as Selection,'Broker Account' as PriceStatus,  
  strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,  
  ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
  case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,   
  case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity,um.intCommodityUnitMeasureId  
FROM tblRKFutOptTransaction ft  
JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
JOIN tblEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId = 1  
JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
JOIN tblRKFutureMarket mar on mar.intFutureMarketId=ft.intFutureMarketId
LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=ft.intCommodityId and um.intUnitMeasureId=mar.intUnitMeasureId
WHERE  ft.intCommodityId=@intCommodityId AND ft.intFutureMarketId=@intFutureMarketId   
AND dtmFutureMonthsDate >= @dtmFutureMonthsDate   
  )t  
  Union  
  SELECT strFutureMonth,dbo.fnRKConvertQuantityToTargetUOM(@intFutureMarketId,@intUOMId,(dblNoOfContract*dblDelta)) as dblNoOfContract,  
    strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity*dblDelta,intCommodityUnitMeasureId from  
  (  
  SELECT DISTINCT '6.Delta options' as Selection,'Broker Account' as PriceStatus,  
     strFutureMonth,e.strName+'-'+strAccountNumber as strAccountNumber,case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfContract,  
    ft.strInternalTradeNo as strTradeNo, ft.dtmTransactionDate as TransactionDate,strBuySell as TranType, e.strName as CustVendor,  
    case when ft.strBuySell='Buy' then (ft.intNoOfContract) else -(ft.intNoOfContract) end as dblNoOfLot,   
    case when ft.strBuySell='Buy' then (ft.intNoOfContract*@dblContractSize) else -(ft.intNoOfContract*@dblContractSize) end dblQuantity,um.intCommodityUnitMeasureId,  
    (SELECT top 1 dblDelta FROM tblRKFuturesSettlementPrice sp  
     JOIN tblRKOptSettlementPriceMarketMap mm on sp.intFutureSettlementPriceId=mm.intFutureSettlementPriceId   
     WHERE intFutureMarketId=ft.intFutureMarketId and mm.intOptionMonthId=ft.intOptionMonthId and   
     mm.intTypeId = case when ft.strOptionType='Put' then 1 else 2 end Order By dtmPriceDate desc) as dblDelta  
  FROM tblRKFutOptTransaction ft  
  JOIN tblRKBrokerageAccount ba on ft.intBrokerageAccountId=ba.intBrokerageAccountId  
  JOIN tblEntity e on e.intEntityId=ft.intEntityId and ft.intInstrumentTypeId = 2  
  JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=ft.intFutureMonthId and fm.intFutureMarketId=ft.intFutureMarketId and fm.ysnExpired=0  
  JOIN tblRKFutureMarket mar on mar.intFutureMarketId=ft.intFutureMarketId
  LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=ft.intCommodityId and um.intUnitMeasureId=mar.intUnitMeasureId
  WHERE  ft.intCommodityId=@intCommodityId AND ft.intFutureMarketId=@intFutureMarketId   
  AND dtmFutureMonthsDate >= @dtmFutureMonthsDate  
  )t  
 ) t   
 ) T  
 --SELECT * FROM @List
INSERT INTO @List(Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity)  
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,sum(dblNoOfContract),strTradeNo,TransactionDate,TranType,CustVendor,sum(dblNoOfLot), sum(dblQuantity)
FROM(
	 SELECT  CASE WHEN @strRiskView='Processor' THEN '9.Outright coverage' ELSE '9.Net market risk' END AS Selection,'Net market risk' as PriceStatus,strFutureMonth
			 ,case when @strRiskView='Processor' then 'Market Coverage' else 'Market Risk' end as strAccountNumber,sum(dblNoOfContract) dblNoOfContract,
			 strTradeNo, TransactionDate,TranType,CustVendor,sum(dblNoOfLot) dblNoOfLot, sum(dblQuantity)  dblQuantity 
	FROM @List WHERE Selection='1.Physical position / Basis risk'  and PriceStatus = 'b. Priced / Outright - (Outright position)'
	GROUP BY strFutureMonth,strTradeNo, TransactionDate,TranType,CustVendor
	UNION 
	 SELECT  CASE WHEN @strRiskView='Processor' THEN '9.Outright coverage' ELSE '9.Net market risk' END AS Selection,'Net market risk' as PriceStatus,strFutureMonth
			 ,case when @strRiskView='Processor' then 'Market Coverage' else 'Market Risk' end as strAccountNumber,sum(dblNoOfContract) dblNoOfContract,
			 strTradeNo, TransactionDate,TranType,CustVendor,sum(dblNoOfLot) dblNoOfLot, sum(dblQuantity)  dblQuantity
	FROM @List WHERE PriceStatus ='F&O' and Selection LIKE ('8.Total F&O%')
	GROUP BY strFutureMonth,strAccountNumber,strTradeNo, TransactionDate,TranType,CustVendor
	
	UNION 
	 SELECT  CASE WHEN @strRiskView='Processor' THEN '9.Outright coverage' ELSE '9.Net market risk' END AS Selection,'Net market risk' as PriceStatus,strFutureMonth
			 ,case when @strRiskView='Processor' then 'Market Coverage' else 'Market Risk' end as strAccountNumber,sum(dblNoOfContract) dblNoOfContract,
			 strTradeNo, TransactionDate,TranType,CustVendor,sum(dblNoOfLot) dblNoOfLot, sum(dblQuantity)  dblQuantity
	FROM @List WHERE PriceStatus ='a. Delta %' and Selection = ('3.Total speciality delta fixed')
	GROUP BY strFutureMonth,strAccountNumber,strTradeNo, TransactionDate,TranType,CustVendor
	)t 
GROUP BY Selection,PriceStatus,strAccountNumber,strFutureMonth,strTradeNo, TransactionDate,TranType,CustVendor
--- Switch Position ---------

INSERT INTO @List(Selection,PriceStatus,strFutureMonth,strAccountNumber,dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity)  
SELECT Selection,PriceStatus,strFutureMonth,strAccountNumber,sum(dblNoOfContract),strTradeNo,TransactionDate,TranType,CustVendor,sum(dblNoOfLot), sum(dblQuantity)
FROM(
	 SELECT  case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as Selection,case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as PriceStatus,strFutureMonth
			 ,case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as strAccountNumber,-sum(dblNoOfContract) dblNoOfContract,
			 strTradeNo, TransactionDate,TranType,CustVendor,-sum(dblNoOfLot) dblNoOfLot, sum(dblQuantity)  dblQuantity 
	FROM @List WHERE Selection='1.Physical position / Basis risk'  and PriceStatus = 'a. Unpriced - (Balance to be Priced)' and strAccountNumber like '%Purchase%'
	GROUP BY strFutureMonth,strTradeNo, TransactionDate,TranType,CustVendor
	UNION
	SELECT  case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as Selection,case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as PriceStatus,strFutureMonth
			 ,case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as strAccountNumber,abs (sum(dblNoOfContract)) dblNoOfContract,
			 strTradeNo, TransactionDate,TranType,CustVendor,abs(sum(dblNoOfLot)) dblNoOfLot,  abs(sum(dblQuantity))  dblQuantity 
	FROM @List WHERE Selection='1.Physical position / Basis risk'  and PriceStatus = 'a. Unpriced - (Balance to be Priced)'  and strAccountNumber like '%Sale%'
	GROUP BY strFutureMonth,strTradeNo, TransactionDate,TranType,CustVendor
	UNION 
	SELECT  case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as Selection,case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as PriceStatus,strFutureMonth
			 ,case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end as strAccountNumber,sum(dblNoOfContract) dblNoOfContract,
			 strTradeNo, TransactionDate,TranType,CustVendor,sum(dblNoOfLot) dblNoOfLot, sum(dblQuantity)  dblQuantity 
	FROM @List WHERE PriceStatus ='F&O' and Selection = ('7.F&O')
	GROUP BY strFutureMonth,strAccountNumber,strTradeNo, TransactionDate,TranType,CustVendor
	)t 
GROUP BY Selection,PriceStatus,strAccountNumber,strFutureMonth,strTradeNo, TransactionDate,TranType,CustVendor  
END  

--- Switch position update ------- start --------  
declare @TotPrevious decimal(24,10)  
declare @RowNumber int  
SELECT @TotPrevious= sum(dblNoOfContract)/@dblContractSize FROM @List where Selection=case when @strRiskView='Processor' then '1.Physical position / Differential cover' else '1.Physical position / Basis risk' end   
   AND strFutureMonth='Previous' and PriceStatus='a. Unpriced - (Balance to be Priced)'  
  
SELECT TOP 1 @RowNumber=intRowNumber FROM @List  WHERE PriceStatus=case when @strRiskView='Processor' then 'Futures required' else 'Switch position' end  
ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END ASC  
UPDATE @List set dblNoOfContract= dblNoOfContract+isnull(@TotPrevious,0) where intRowNumber=@RowNumber  
--- Switch position update ------- end --------  
--- Net market risk ------- start --------  
declare @TotPreviousRisk decimal(24,10)  
declare @RowNumberRisk int  
SELECT @TotPreviousRisk= sum(dblNoOfContract) FROM @List where Selection=case when @strRiskView='Processor' then '1.Physical position / Differential cover' else '1.Physical position / Basis risk' end   
   AND strFutureMonth='Previous' and PriceStatus='b. Priced / Outright - (Outright position)'  
  
SELECT TOP 1 @RowNumberRisk=intRowNumber FROM @List  WHERE PriceStatus='Net market risk'  
ORDER BY CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END ASC  
UPDATE @List set dblNoOfContract= dblNoOfContract+isnull(@TotPrevious,0) where intRowNumber=@RowNumberRisk  
--- Net market risk ------- end --------  
  
SELECT intRowNumber,Selection,PriceStatus,strFutureMonth,strAccountNumber,  
    CONVERT(DOUBLE PRECISION,ROUND(dblNoOfContract,@intDecimal)) as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblNoOfLot, dblQuantity  FROM @List    
    WHERE dblQuantity <> 0  
 ORDER BY Selection, CASE WHEN  strFutureMonth <>'Previous' THEN CONVERT(DATETIME,'01 '+strFutureMonth) END ASC