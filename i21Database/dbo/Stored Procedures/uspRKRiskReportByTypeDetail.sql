CREATE PROC uspRKRiskReportByTypeDetail
		@intProductTypeId int= null,
		@intFutureMarketId int = null,
		@intCompanyLocationId nvarchar(250) = null,
		@intCommodityAttributeId nvarchar(250) = null,
		@intUnitMeasureId int ,
		@intDecimals int,
		@strDetailColumnName nvarchar(100),
		@strFutureMonth nvarchar(10)
	
AS

	 DECLARE @Location AS TABLE 
	 (	intLocationId INT IDENTITY(1,1) PRIMARY KEY, 
		intCompanyLocationId  INT
	 )
	 	
	 INSERT INTO @Location(intCompanyLocationId)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ',') 
	 delete from @Location where intCompanyLocationId=0


DECLARE @BrokerageAttribute AS TABLE 
(	intAttributeId INT IDENTITY(1,1) PRIMARY KEY, 
	intFutureMarketId int,
	intBrokersAccountMarketMapId  INT,
	strCommodityAttributeId nvarchar(max),
	intBrokerageAccountId int
)
DECLARE @BrokerageAttributeFinal AS TABLE 
(	intAttributeId INT IDENTITY(1,1) PRIMARY KEY, 
	intFutureMarketId int,
	intBrokerageAccountId  INT,
	strCommodityAttributeId nvarchar(max)
)
INSERT INTO @BrokerageAttribute
SELECT mm.intFutureMarketId,intBrokersAccountMarketMapId,strCommodityAttributeId,intBrokerageAccountId FROM tblRKFutureMarket m
JOIN [tblRKBrokersAccountMarketMapping] mm on mm.intFutureMarketId=m.intFutureMarketId where m.intFutureMarketId=@intFutureMarketId

DECLARE @intAttributeId INT
DECLARE @intFutureMarketId1 INT
DECLARE @intBrokerageAccountId INT
DECLARE @strCommodityAttributeId NVARCHAR(MAX)

SELECT @intAttributeId= min(intAttributeId) from @BrokerageAttribute
WHILE @intAttributeId >0
BEGIN
	SELECT @intFutureMarketId1=intFutureMarketId,@intBrokerageAccountId=intBrokerageAccountId,@strCommodityAttributeId=strCommodityAttributeId
	FROM @BrokerageAttribute WHERE intAttributeId=@intAttributeId
	  IF @intAttributeId >0
	  BEGIN
		  INSERT INTO @BrokerageAttributeFinal(strCommodityAttributeId)	  
		  SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@strCommodityAttributeId, ',') 
		  update @BrokerageAttributeFinal set intBrokerageAccountId=@intBrokerageAccountId,intFutureMarketId=@intFutureMarketId1 where intBrokerageAccountId is null
	  END
SELECT @intAttributeId= min(intAttributeId) FROM @BrokerageAttribute WHERE intAttributeId > @intAttributeId
END	
DECLARE @intPreviousMonthId int,@dtmFutureMonthsDate DATETIME
SELECT @intPreviousMonthId  = null
SELECT @dtmFutureMonthsDate  = null
SELECT TOP 1 @intPreviousMonthId=intFutureMonthId FROM tblRKFuturesMonth WHERE ysnExpired = 0 
		AND  dtmSpotDate <= GETDATE() AND intFutureMarketId = @intFutureMarketId ORDER BY intFutureMonthId DESC
SELECT TOP 1 @dtmFutureMonthsDate=dtmFutureMonthsDate FROM tblRKFuturesMonth WHERE intFutureMonthId=@intPreviousMonthId

--Contract Transaction
SELECT DISTINCT * INTO #ContractTransaction from (     
SELECT distinct fm.intFutureMonthId,cv.strFutureMonth,strFutMarketName,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,  
    dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,um1.intCommodityUnitMeasureId,isnull(cv.dblDetailQuantity,0)) -
  sum(
  case when intPricingTypeId=1 then 
  case when intContractTypeId=1 then isnull(iq.dblPurchaseInvoiceQty,0) else isnull(iq1.dblSalesInvoiceQty,0) end 
  else 0 END) OVER (PARTITION BY cv.intContractDetailId ) dblNoOfContract,   
  LEFT(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, 
  dtmStartDate as TransactionDate,  
  strContractType as TranType, 
  strEntityName  as CustVendor,  
  dblNoOfLots as dblNoOfLot,
    dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,um1.intCommodityUnitMeasureId,isnull(cv.dblDetailQuantity,0)) -
  sum(
  case when intPricingTypeId=1 then 
  case when intContractTypeId=1 then isnull(iq.dblPurchaseInvoiceQty,0) else isnull(iq1.dblSalesInvoiceQty,0) end 
  else 0 END) OVER (PARTITION BY cv.intContractDetailId ) dblQuantity,
  cv.intContractHeaderId,null as intFutOptTransactionHeaderId  
  ,intPricingTypeId
  ,cv.strContractType
  ,cv.intCommodityId
  ,cv.intCompanyLocationId
  ,cv.intFutureMarketId
  ,dtmFutureMonthsDate
  ,ysnExpired,'Priced' strPricingType,strLocationName,ca.intCommodityAttributeId intProductTypeId
  FROM vyuRKRiskPositionContractDetail cv  
  JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=cv.intFutureMarketId  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=cv.intCompanyLocationId
  JOIN tblICItem ic on ic.intItemId=cv.intItemId 
				and cv.intItemId not in(SELECT intItemId FROM tblICItem ici    
										JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
										AND ici.intProductLineId=pl.intCommodityProductLineId)
  LEFT JOIN vyuRKGetInvoicedQty iq on cv.intContractDetailId= iq.intPContractDetailId 
  LEFT JOIN vyuRKGetInvoicedQty iq1 on cv.intContractDetailId= iq1.intSContractDetailId
  LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  	
  LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId AND um.intUnitMeasureId=cv.intUnitMeasureId
  LEFT join tblICCommodityUnitMeasure um1 on  um1.intCommodityId=cv.intCommodityId and um1.intUnitMeasureId=@intUnitMeasureId  
  WHERE  cv.intFutureMarketId =@intFutureMarketId and  cv.intContractStatusId <> 3 and cv.intPricingTypeId=1 
		and cv.intCompanyLocationId in (select intCompanyLocationId from @Location)
		--and ca.intCommodityAttributeId = case when isnull(@intProductTypeId,0) =0 then ca.intCommodityAttributeId else @intProductTypeId end
  union
--Parcial Priced
SELECT intFutureMonthId,strFutureMonth,strFutMarketName,strAccountNumber,dblFixedQty as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblFixedLots dblNoOfLot,dblFixedQty,
intContractHeaderId,intFutOptTransactionHeaderId,intPricingTypeId,strContractType,intCommodityId,intCompanyLocationId,intFutureMarketId,dtmFutureMonthsDate,ysnExpired,
'Priced' strPricingType,strLocationName,intCommodityAttributeId intProductTypeId
FROM (
SELECT cv.strFutureMonth,strFutMarketName,fm.intFutureMonthId,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,  
  0 AS dblNoOfContract,  
  LEFT(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, 
  dtmStartDate as TransactionDate,  
  strContractType as TranType, 
  strEntityName  as CustVendor,  
  dblNoOfLots as dblNoOfLot,
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,um1.intCommodityUnitMeasureId,isnull(dblDetailQuantity,0)) as dblQuantity,
  cv.intContractHeaderId,null as intFutOptTransactionHeaderId  
  ,1 intPricingTypeId
  ,cv.strContractType
  ,cv.intCommodityId
  ,cv.intCompanyLocationId
  ,cv.intFutureMarketId
  ,dtmFutureMonthsDate
  ,ysnExpired
  ,isnull((SELECT sum(dblLotsFixed) dblNoOfLots FROM tblCTPriceFixation pf 
		where pf.intContractHeaderId =cv.intContractHeaderId and pf.intContractDetailId=cv.intContractDetailId),0) dblFixedLots
  ,isnull((SELECT  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,um1.intCommodityUnitMeasureId,sum(dblQuantity)) dblQuantity FROM tblCTPriceFixation pf
		 join tblCTPriceFixationDetail pd on pf.intPriceFixationId=pd.intPriceFixationId	 
		where pf.intContractHeaderId =cv.intContractHeaderId and pf.intContractDetailId=cv.intContractDetailId),0) dblFixedQty
		,strLocationName,ca.intCommodityAttributeId 
  FROM vyuRKRiskPositionContractDetail cv  
  JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=cv.intFutureMarketId   
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId 
  JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=cv.intCompanyLocationId 
  JOIN tblICItem ic on ic.intItemId=cv.intItemId 
				and cv.intItemId not in(SELECT intItemId FROM tblICItem ici    
										JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
										AND ici.intProductLineId=pl.intCommodityProductLineId)  
  LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  	
  LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId AND um.intUnitMeasureId=cv.intUnitMeasureId
  LEFT join tblICCommodityUnitMeasure um1 on  um1.intCommodityId=cv.intCommodityId and um1.intUnitMeasureId=@intUnitMeasureId  
  WHERE   cv.intFutureMarketId = @intFutureMarketId AND cv.intContractStatusId <> 3  and intPricingTypeId <> 1
		and cv.intCompanyLocationId in (select intCompanyLocationId from @Location)
		--and ca.intCommodityAttributeId =case when isnull(@intProductTypeId,0) =0 then ca.intCommodityAttributeId else @intProductTypeId end
  )t where isnull(dblNoOfLot,0)-isnull(dblFixedLots,0) <> 0

  union
--Parcial UnPriced
  SELECT intFutureMonthId,strFutureMonth,strFutMarketName,strAccountNumber,dblQuantity-dblFixedQty as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,isnull(dblNoOfLot,0)-isnull(dblFixedLots,0) dblNoOfLot,dblQuantity-dblFixedQty dblQuantity,
intContractHeaderId,intFutOptTransactionHeaderId,intPricingTypeId,strContractType,intCommodityId,intCompanyLocationId,intFutureMarketId,dtmFutureMonthsDate,ysnExpired
,'UnPriced' strPricingType,strLocationName,intCommodityAttributeId intProductTypeId 
FROM (
SELECT cv.strFutureMonth,strFutMarketName,intContractDetailId, fm.intFutureMonthId, 
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,  
  0 AS dblNoOfContract,  
  LEFT(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, 
  dtmStartDate as TransactionDate,  
  strContractType as TranType, 
  strEntityName  as CustVendor,  
  dblNoOfLots as dblNoOfLot,
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,um1.intCommodityUnitMeasureId,isnull(dblDetailQuantity,0)) as dblQuantity,
  cv.intContractHeaderId,null as intFutOptTransactionHeaderId  
  ,2 as intPricingTypeId
  ,cv.strContractType
  ,cv.intCommodityId
  ,cv.intCompanyLocationId
  ,cv.intFutureMarketId
  ,dtmFutureMonthsDate
  ,ysnExpired
  ,isnull((SELECT sum(dblLotsFixed) dblNoOfLots FROM tblCTPriceFixation pf 
		where pf.intContractHeaderId =cv.intContractHeaderId and pf.intContractDetailId=cv.intContractDetailId),0) dblFixedLots
  ,isnull((SELECT  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,um1.intCommodityUnitMeasureId,sum(pd.dblQuantity)) dblQuantity FROM tblCTPriceFixation pf
		 JOIN tblCTPriceFixationDetail pd on pf.intPriceFixationId=pd.intPriceFixationId	 
		where pf.intContractHeaderId =cv.intContractHeaderId and pf.intContractDetailId=cv.intContractDetailId),0) dblFixedQty,
  strLocationName,ca.intCommodityAttributeId
  FROM vyuRKRiskPositionContractDetail cv  
  JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=cv.intFutureMarketId 
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u ON cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic ON ic.intItemId=cv.intItemId 
				AND cv.intItemId NOT IN(SELECT intItemId FROM tblICItem ici    
										JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
										AND ici.intProductLineId=pl.intCommodityProductLineId)  
  JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=cv.intCompanyLocationId
  LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  	
  LEFT JOIN tblARProductType pt on pt.intProductTypeId=ic.intProductTypeId
  LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId AND um.intUnitMeasureId=cv.intUnitMeasureId
  LEFT JOIN tblICCommodityUnitMeasure um1 on  um1.intCommodityId=cv.intCommodityId AND um1.intUnitMeasureId=@intUnitMeasureId 
  WHERE cv.intFutureMarketId =@intFutureMarketId AND cv.intContractStatusId <> 3  AND intPricingTypeId <> 1
		AND cv.intCompanyLocationId in (select intCompanyLocationId from @Location)
		--AND ca.intCommodityAttributeId =case when isnull(@intProductTypeId,0) =0 then ca.intCommodityAttributeId else @intProductTypeId end
  )t WHERE isnull(dblNoOfLot,0)-isnull(dblFixedLots,0) <> 0)t1 where dblNoOfContract <>0			
UPDATE #ContractTransaction set strFutureMonth = 'Previous' where dtmFutureMonthsDate < @dtmFutureMonthsDate

if (isnull(@intProductTypeId,0) <> 0)
BEGIN
--Future Transaction with product Type
SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strFutMarketName,strLocationName,strTradeNo,CustVendor,strFutureMonth as strFutureMonth,
		abs((isnull(strBuy,0)-isnull(strSell,0)))*dblContractSize dblQuantity,dtmFutureMonthsDate as dtmTransactionDate,strBuySell,
		abs((isnull(strBuy,0)-isnull(strSell,0))) intNoOfContract,dblPrice dblPrice,strTradeNo strInternalTradeNo,intFutureMarketId,intFutOptTransactionHeaderId 
INTO #FutureTransaction
FROM (
	SELECT strFutMarketName,strFutureMonth, t.intFutureMarketId, strName CustVendor,strBuySell,dtmFutureMonthsDate,dblPrice,
	(select intNoOfContract from tblRKFutOptTransaction ot where ot.intFutOptTransactionId=t.intFutOptTransactionId and strBuySell='Buy') strBuy,
	(select intNoOfContract from tblRKFutOptTransaction ot where ot.intFutOptTransactionId=t.intFutOptTransactionId and strBuySell='Sell') strSell,
	m.dblContractSize dblContractSize ,strLocationName strLocationName,t.strInternalTradeNo strTradeNo,t.intFutOptTransactionHeaderId
	FROM tblRKFutOptTransaction t 
	join tblRKFutureMarket m on m.intFutureMarketId=t.intFutureMarketId
	join tblSMCompanyLocation cl on cl.intCompanyLocationId=t.intLocationId and intInstrumentTypeId=1
	join tblRKFuturesMonth fm on t.intFutureMonthId=fm.intFutureMonthId
	join tblEMEntity e on t.intEntityId=e.intEntityId
	WHERE t.intFutureMarketId =@intFutureMarketId
		AND t.intLocationId in (SELECT intCompanyLocationId from @Location)
		and t.intBrokerageAccountId in(SELECT intBrokerageAccountId from @BrokerageAttributeFinal									
										WHERE strCommodityAttributeId = @intProductTypeId))t
UPDATE #FutureTransaction set strFutureMonth = 'Previous' where dtmTransactionDate < @dtmFutureMonthsDate

 IF (@strDetailColumnName='colTotalPurchase')
	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,strTradeNo,CustVendor,dblQuantity,dtmFutureMonthsDate dtmTransactionDate,TranType strBuySell,
	0 intNoOfContract,0.0 dblPrice,'' strInternalTradeNo,0 as intFutOptTransactionHeaderId,intContractHeaderId,@intDecimals intDecimals FROM #ContractTransaction WHERE strFutureMonth=@strFutureMonth AND TranType='Purchase' and intProductTypeId=@intProductTypeId and intFutureMarketId=@intFutureMarketId
 ELSE IF  (@strDetailColumnName='colTotalSales')
	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,strTradeNo,CustVendor,dblQuantity,dtmFutureMonthsDate dtmTransactionDate,TranType strBuySell,
	0 intNoOfContract,0.0 dblPrice,'' strInternalTradeNo,0 as intFutOptTransactionHeaderId,intContractHeaderId,@intDecimals intDecimals FROM #ContractTransaction WHERE strFutureMonth=@strFutureMonth AND TranType='Sale' and intProductTypeId=@intProductTypeId and intFutureMarketId=@intFutureMarketId
 ELSE IF (@strDetailColumnName='colUnfixedPurchase')
	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,strTradeNo,CustVendor,dblQuantity,dtmFutureMonthsDate dtmTransactionDate,TranType strBuySell,
	0 intNoOfContract,0.0 dblPrice,'' strInternalTradeNo,0 as intFutOptTransactionHeaderId,intContractHeaderId,@intDecimals intDecimals FROM #ContractTransaction WHERE strFutureMonth=@strFutureMonth AND TranType='Purchase' AND  strPricingType='UnPriced' and intProductTypeId=@intProductTypeId and intFutureMarketId=@intFutureMarketId
 ELSE IF (@strDetailColumnName='colUnfixedSales')  
	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,strTradeNo,CustVendor,dblQuantity,dtmFutureMonthsDate dtmTransactionDate,TranType strBuySell,
	0 intNoOfContract,0.0 dblPrice,'' strInternalTradeNo,0 as intFutOptTransactionHeaderId,intContractHeaderId,@intDecimals intDecimals FROM #ContractTransaction WHERE strFutureMonth=@strFutureMonth AND TranType='Sale' AND  strPricingType='UnPriced' and intProductTypeId=@intProductTypeId and intFutureMarketId=@intFutureMarketId
 ELSE IF (@strDetailColumnName='colPrevious') 
 SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,strTradeNo,CustVendor,dblQuantity,dtmFutureMonthsDate dtmTransactionDate,TranType strBuySell,
	0 intNoOfContract,0.0 dblPrice,'' strInternalTradeNo,0 as intFutOptTransactionHeaderId,intContractHeaderId,@intDecimals intDecimals FROM #ContractTransaction WHERE strFutureMonth=@strFutureMonth AND TranType='Sale'  and intProductTypeId=@intProductTypeId and intFutureMarketId=@intFutureMarketId

 ELSE IF (@strDetailColumnName='colFutures')							
	    SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,strTradeNo,CustVendor,dblQuantity,dtmTransactionDate dtmTransactionDate,strBuySell,
	 intNoOfContract,dblPrice dblPrice,'' strInternalTradeNo,intFutOptTransactionHeaderId,0 as intContractHeaderId,@intDecimals intDecimals FROM #FutureTransaction WHERE strFutureMonth=@strFutureMonth and intFutureMarketId=@intFutureMarketId
END
ELSE
BEGIN
--Futures Transaction With out product Type
SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strFutMarketName,strLocationName,strTradeNo,CustVendor,strFutureMonth as strFutureMonth,
		abs((isnull(strBuy,0)-isnull(strSell,0)))*dblContractSize dblQuantity,dtmFutureMonthsDate as dtmTransactionDate,strBuySell,
		abs((isnull(strBuy,0)-isnull(strSell,0))) intNoOfContract,dblPrice dblPrice,strTradeNo strInternalTradeNo,intFutureMarketId,intFutOptTransactionHeaderId into #FutureTransaction1
FROM (
	SELECT strFutMarketName,strFutureMonth, t.intFutureMarketId, strName CustVendor,strBuySell,dtmFutureMonthsDate,dblPrice,
	(select intNoOfContract from tblRKFutOptTransaction ot where ot.intFutOptTransactionId=t.intFutOptTransactionId and strBuySell='Buy') strBuy,
	(select intNoOfContract from tblRKFutOptTransaction ot where ot.intFutOptTransactionId=t.intFutOptTransactionId and strBuySell='Sell') strSell,
	m.dblContractSize dblContractSize ,strLocationName strLocationName,t.strInternalTradeNo strTradeNo,intFutOptTransactionHeaderId
	FROM tblRKFutOptTransaction t 
	join tblRKFutureMarket m on m.intFutureMarketId=t.intFutureMarketId
	join tblSMCompanyLocation cl on cl.intCompanyLocationId=t.intLocationId and intInstrumentTypeId=1
	join tblRKFuturesMonth fm on t.intFutureMonthId=fm.intFutureMonthId
	join tblEMEntity e on t.intEntityId=e.intEntityId
	WHERE t.intFutureMarketId =@intFutureMarketId
		AND t.intLocationId in (SELECT intCompanyLocationId from @Location))t	

UPDATE #FutureTransaction1 set strFutureMonth = 'Previous' where dtmTransactionDate < @dtmFutureMonthsDate

IF (@strDetailColumnName='colTotalPurchase')
	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,strTradeNo,CustVendor,dblQuantity,dtmFutureMonthsDate dtmTransactionDate,TranType strBuySell,intProductTypeId,intFutureMarketId,strFutureMonth,
	0 intNoOfContract,0.0 dblPrice,'' strInternalTradeNo,0 as intFutOptTransactionHeaderId,intContractHeaderId,@intDecimals intDecimals FROM #ContractTransaction WHERE strFutureMonth=@strFutureMonth AND TranType='Purchase' and intFutureMarketId=@intFutureMarketId and strFutureMonth=@strFutureMonth
 ELSE IF  (@strDetailColumnName='colTotalSales')
	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,strTradeNo,CustVendor,dblQuantity,dtmFutureMonthsDate dtmTransactionDate,TranType strBuySell,
	0 intNoOfContract,0.0 dblPrice,'' strInternalTradeNo,0 as intFutOptTransactionHeaderId,intContractHeaderId,@intDecimals intDecimals FROM #ContractTransaction WHERE strFutureMonth=@strFutureMonth AND TranType='Sale' and intFutureMarketId=@intFutureMarketId and strFutureMonth=@strFutureMonth
 ELSE IF (@strDetailColumnName='colUnfixedPurchase')
	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,strTradeNo,CustVendor,dblQuantity,dtmFutureMonthsDate dtmTransactionDate,TranType strBuySell,
	0 intNoOfContract,0.0 dblPrice,'' strInternalTradeNo,0 as intFutOptTransactionHeaderId,intContractHeaderId,@intDecimals intDecimals FROM #ContractTransaction WHERE strFutureMonth=@strFutureMonth AND TranType='Purchase' AND  strPricingType='UnPriced' and intFutureMarketId=@intFutureMarketId  and strFutureMonth=@strFutureMonth
 ELSE IF (@strDetailColumnName='colUnfixedSales')  
	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,strTradeNo,CustVendor,dblQuantity,dtmFutureMonthsDate dtmTransactionDate,TranType strBuySell,
	0 intNoOfContract,0.0 dblPrice,'' strInternalTradeNo,0 as intFutOptTransactionHeaderId,intContractHeaderId,@intDecimals intDecimals FROM #ContractTransaction WHERE strFutureMonth=@strFutureMonth AND TranType='Sale' AND  strPricingType='UnPriced' and intFutureMarketId=@intFutureMarketId and strFutureMonth=@strFutureMonth
 ELSE IF (@strDetailColumnName='colPrevious')
    SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,strTradeNo,CustVendor,dblQuantity,dtmFutureMonthsDate dtmTransactionDate,TranType strBuySell,
	0 intNoOfContract,0.0 dblPrice,'' strInternalTradeNo,0 as intFutOptTransactionHeaderId,intContractHeaderId,@intDecimals intDecimals FROM #ContractTransaction WHERE strFutureMonth=@strFutureMonth AND TranType='Sale'  and intFutureMarketId=@intFutureMarketId and strFutureMonth=@strFutureMonth

 ELSE IF (@strDetailColumnName='colFutures')							
	    SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,strTradeNo,CustVendor,dblQuantity,dtmTransactionDate dtmTransactionDate,strBuySell,
	 intNoOfContract,dblPrice dblPrice,'' strInternalTradeNo,intFutOptTransactionHeaderId,0 intContractHeaderId,@intDecimals intDecimals FROM #FutureTransaction1 WHERE strFutureMonth=@strFutureMonth and intFutureMarketId=@intFutureMarketId and strFutureMonth=@strFutureMonth
END