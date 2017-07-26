CREATE PROC uspRKRiskReportByTypeDetail
		@intFutureMarketId int = null,
		@intCompanyLocationId nvarchar(250) = null,
		@intCommodityAttributeId nvarchar(250) = null,
		@intUnitMeasureId int ,
		@intDecimals int,
		@strDetailColumnName nvarchar(100),
		@intFutureMonthId int

AS

	 DECLARE @Location AS TABLE 
	 (	intLocationId INT IDENTITY(1,1) PRIMARY KEY, 
		intCompanyLocationId  INT
	 )

	 DECLARE @CommodityAttribute AS TABLE 
	 (	intAttributeId INT IDENTITY(1,1) PRIMARY KEY, 
		intCommodityAttributeId  INT
	 )
	 	
	 INSERT INTO @Location(intCompanyLocationId)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCompanyLocationId, ',') 
	 delete from @Location where intCompanyLocationId=0

	 INSERT INTO @CommodityAttribute(intCommodityAttributeId)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityAttributeId, ',')   
	 delete from @CommodityAttribute where intCommodityAttributeId=0

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

SELECT * INTO #ContractTransaction from (     
SELECT fm.intFutureMonthId,cv.strFutureMonth,strFutMarketName,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,  
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intUnitMeasureId,dblBalance) AS dblNoOfContract,  
  LEFT(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, 
  dtmStartDate as TransactionDate,  
  strContractType as TranType, 
  strEntityName  as CustVendor,  
  dblNoOfLots as dblNoOfLot,
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,um1.intCommodityUnitMeasureId,isnull(dblBalance,0)) as dblQuantity,
  cv.intContractHeaderId,null as intFutOptTransactionHeaderId  
  ,intPricingTypeId
  ,cv.strContractType
  ,cv.intCommodityId
  ,cv.intCompanyLocationId
  ,cv.intFutureMarketId
  ,dtmFutureMonthsDate
  ,ysnExpired,'Priced' strPricingType,strLocationName
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
  LEFT join tblICCommodityUnitMeasure um1 on  um1.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=@intUnitMeasureId  
  WHERE  cv.intFutureMarketId =@intFutureMarketId and  cv.intContractStatusId <> 3 and cv.intPricingTypeId=1 
		and cv.intCompanyLocationId in (select intCompanyLocationId from @Location)
		and ca.intCommodityAttributeId in((SELECT intCommodityAttributeId from @CommodityAttribute ))
  union
--Parcial Priced
SELECT intFutureMonthId,strFutureMonth,strFutMarketName,strAccountNumber,dblFixedQty as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblFixedLots dblNoOfLot,dblFixedQty,
intContractHeaderId,intFutOptTransactionHeaderId,intPricingTypeId,strContractType,intCommodityId,intCompanyLocationId,intFutureMarketId,dtmFutureMonthsDate,ysnExpired,
'Priced' strPricingType,strLocationName 
FROM (
SELECT cv.strFutureMonth,strFutMarketName,fm.intFutureMonthId,  
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,  
  0 AS dblNoOfContract,  
  LEFT(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, 
  dtmStartDate as TransactionDate,  
  strContractType as TranType, 
  strEntityName  as CustVendor,  
  dblNoOfLots as dblNoOfLot,
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,um1.intCommodityUnitMeasureId,isnull(dblBalance,0)) as dblQuantity,
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
		,strLocationName
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
		and ca.intCommodityAttributeId in((SELECT intCommodityAttributeId from @CommodityAttribute ))
  )t where isnull(dblNoOfLot,0)-isnull(dblFixedLots,0) <> 0

  union
--Parcial UnPriced
  SELECT intFutureMonthId,strFutureMonth,strFutMarketName,strAccountNumber,dblQuantity-dblFixedQty as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,isnull(dblNoOfLot,0)-isnull(dblFixedLots,0) dblNoOfLot,dblQuantity-dblFixedQty dblQuantity,
intContractHeaderId,intFutOptTransactionHeaderId,intPricingTypeId,strContractType,intCommodityId,intCompanyLocationId,intFutureMarketId,dtmFutureMonthsDate,ysnExpired
,'UnPriced' strPricingType,strLocationName 
FROM (
SELECT cv.strFutureMonth,strFutMarketName,intContractDetailId, fm.intFutureMonthId, 
  strContractType+' - '+isnull(ca.strDescription,'') as strAccountNumber,  
  0 AS dblNoOfContract,  
  LEFT(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, 
  dtmStartDate as TransactionDate,  
  strContractType as TranType, 
  strEntityName  as CustVendor,  
  dblNoOfLots as dblNoOfLot,
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,um1.intCommodityUnitMeasureId,isnull(dblBalance,0)) as dblQuantity,
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
  strLocationName
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
		AND ca.intCommodityAttributeId in((SELECT intCommodityAttributeId from @CommodityAttribute))
  )t WHERE isnull(dblNoOfLot,0)-isnull(dblFixedLots,0) <> 0)t1 where dblNoOfContract <>0

  
 IF (@strDetailColumnName='colTotalPurchase')
	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,strTradeNo,CustVendor,dblQuantity,null dtmTransactionDate,'' strBuySell,
	0 intNoOfContract,0.0 dblPrice,'' strInternalTradeNo FROM #ContractTransaction WHERE intFutureMonthId=@intFutureMonthId AND TranType='Purchase' 
  ELSE IF  (@strDetailColumnName='colTotalSales')
	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,strTradeNo,CustVendor,dblQuantity,null dtmTransactionDate,'' strBuySell,
	0 intNoOfContract,0.0 dblPrice,'' strInternalTradeNo FROM #ContractTransaction WHERE intFutureMonthId=@intFutureMonthId AND TranType='Sale'
  ELSE IF (@strDetailColumnName='colUnfixedPurchase')
	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,strTradeNo,CustVendor,dblQuantity,null dtmTransactionDate,'' strBuySell,
	0 intNoOfContract,0.0 dblPrice,'' strInternalTradeNo FROM #ContractTransaction WHERE intFutureMonthId=@intFutureMonthId AND TranType='Purchase' AND  strPricingType='UnPriced'
 ELSE IF (@strDetailColumnName='colUnfixedSales')  
	SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,strTradeNo,CustVendor,dblQuantity,null dtmTransactionDate,'' strBuySell,
	0 intNoOfContract,0.0 dblPrice,'' strInternalTradeNo FROM #ContractTransaction WHERE intFutureMonthId=@intFutureMonthId AND TranType='Sale' AND  strPricingType='UnPriced'
 ELSE IF (@strDetailColumnName='colPrevious')
    SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,strTradeNo,CustVendor,dblQuantity,null dtmTransactionDate,'' strBuySell,
	0 intNoOfContract,0.0 dblPrice,'' strInternalTradeNo FROM #ContractTransaction WHERE intFutureMonthId=@intFutureMonthId AND TranType='Sale' AND  strPricingType='Previous'

ELSE IF (@strDetailColumnName='colFutures')
  SELECT CONVERT(INT,ROW_NUMBER() OVER(ORDER BY strFutMarketName)) as intRowNum,strLocationName,'' as strTradeNo,'' CustVendor,strInternalTradeNo,
	intNoOfContract*dblContractSize dblQuantity,th.dtmTransactionDate,strBuySell,intNoOfContract,dblPrice
  FROM tblRKFutOptTransaction t
  JOIN tblRKFutOptTransactionHeader th on th.intFutOptTransactionHeaderId=t.intFutOptTransactionHeaderId
  JOIN tblRKFutureMarket mar on mar.intFutureMarketId=t.intFutureMarketId
  JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=t.intFutureMonthId and th.intSelectedInstrumentTypeId=1 and t.intInstrumentTypeId=1
  JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId=t.intLocationId   
  WHERE t.intFutureMarketId = @intFutureMarketId and t.intFutureMonthId=@intFutureMonthId
		AND t.intLocationId IN (SELECT intCompanyLocationId FROM @Location)
		AND t.intBrokerageAccountId in(SELECT intBrokerageAccountId FROM @BrokerageAttributeFinal									
										WHERE strCommodityAttributeId IN (SELECT intCommodityAttributeId from @CommodityAttribute) )
										