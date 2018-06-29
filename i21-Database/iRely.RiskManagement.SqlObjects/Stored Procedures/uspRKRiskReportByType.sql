CREATE PROC uspRKRiskReportByType
		@intFutureMarketId nvarchar(250) = null,
		@intCompanyLocationId nvarchar(250) = null,
		@intCommodityAttributeId nvarchar(250) = null,
		@intUnitMeasureId int ,
		@intDecimals int
AS

	 DECLARE @Market AS TABLE 
	 (	intMarketId INT IDENTITY(1,1) PRIMARY KEY, 
		intFutureMarketId  INT
	 )
	 DECLARE @Location AS TABLE 
	 (	intLocationId INT IDENTITY(1,1) PRIMARY KEY, 
		intCompanyLocationId  INT
	 )

	 DECLARE @CommodityAttribute AS TABLE 
	 (	intAttributeId INT IDENTITY(1,1) PRIMARY KEY, 
		intCommodityAttributeId  INT
	 )

	 INSERT INTO @Market(intFutureMarketId)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intFutureMarketId, ',')  	 
	 delete from @Market where intFutureMarketId=0
	 	
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
SELECT mm.intFutureMarketId,intBrokersAccountMarketMapId,strCommodityAttributeId,intBrokerageAccountId FROM @Market m
JOIN [tblRKBrokersAccountMarketMapping] mm on mm.intFutureMarketId=m.intFutureMarketId and isnull(strCommodityAttributeId ,'') <> '' 

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
      dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,um1.intCommodityUnitMeasureId,isnull(cv.dblDetailQuantity,0)) -
  sum(
  case when intPricingTypeId=1 then 
  case when intContractTypeId=1 then isnull(iq.dblPurchaseInvoiceQty,0) else isnull(iq1.dblSalesInvoiceQty,0) end 
  else 0 END) OVER (PARTITION BY cv.intContractDetailId )AS dblNoOfContract,  
  LEFT(strContractType,1)+' - '+ strContractNumber +' - '+convert(nvarchar,intContractSeq) as strTradeNo, 
  dtmStartDate as TransactionDate,  
  strContractType as TranType, 
  strEntityName  as CustVendor,  
  dblNoOfLots as dblNoOfLot,
  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,um1.intCommodityUnitMeasureId,isnull(cv.dblDetailQuantity,0)) -
  sum(
  case when intPricingTypeId=1 then 
  case when intContractTypeId=1 then isnull(iq.dblPurchaseInvoiceQty,0) else isnull(iq1.dblSalesInvoiceQty,0) end 
  else 0 END) OVER (PARTITION BY cv.intContractDetailId ) as dblQuantity,
  cv.intContractHeaderId,null as intFutOptTransactionHeaderId  
  ,intPricingTypeId
  ,cv.strContractType
  ,cv.intCommodityId
  ,cv.intCompanyLocationId
  ,cv.intFutureMarketId
  ,dtmFutureMonthsDate
  ,ysnExpired,'Priced' strPricingType,ca.intCommodityAttributeId,ca.strDescription
  FROM vyuRKRiskPositionContractDetail cv  
  JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=cv.intFutureMarketId  
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId 
				and cv.intItemId not in(SELECT intItemId FROM tblICItem ici    
										JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
										AND ici.intProductLineId=pl.intCommodityProductLineId)
  LEFT JOIN vyuRKGetInvoicedQty iq on cv.intContractDetailId= iq.intPContractDetailId 
  LEFT JOIN vyuRKGetInvoicedQty iq1 on cv.intContractDetailId= iq1.intSContractDetailId
  LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  	
  LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId AND um.intUnitMeasureId=cv.intUnitMeasureId
  LEFT JOIN tblICCommodityUnitMeasure um1 on  um1.intCommodityId=cv.intCommodityId and um1.intUnitMeasureId=@intUnitMeasureId  
  WHERE  cv.intFutureMarketId in (select intFutureMarketId from @Market) and  cv.intContractStatusId <> 3 and cv.intPricingTypeId=1 
		and cv.intCompanyLocationId in (select intCompanyLocationId from @Location)
		and ca.intCommodityAttributeId in((SELECT intCommodityAttributeId from @CommodityAttribute ))
  union
--Parcial Priced
SELECT intFutureMonthId,strFutureMonth,strFutMarketName,strAccountNumber,dblFixedQty as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,dblFixedLots dblNoOfLot,dblFixedQty,
intContractHeaderId,intFutOptTransactionHeaderId,intPricingTypeId,strContractType,intCommodityId,intCompanyLocationId,intFutureMarketId,dtmFutureMonthsDate,ysnExpired,'Priced' strPricingType
,intCommodityAttributeId,strDescription
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
  ,isnull((SELECT  dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,um1.intCommodityUnitMeasureId,sum(dblQuantity)) dblQuantity 
		 FROM tblCTPriceFixation pf
		 join tblCTPriceFixationDetail pd on pf.intPriceFixationId=pd.intPriceFixationId	 
		where pf.intContractHeaderId =cv.intContractHeaderId and pf.intContractDetailId=cv.intContractDetailId),0) dblFixedQty
		,ca.intCommodityAttributeId,ca.strDescription
  FROM vyuRKRiskPositionContractDetail cv  
  JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=cv.intFutureMarketId   
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId 
				and cv.intItemId not in(SELECT intItemId FROM tblICItem ici    
										JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
										AND ici.intProductLineId=pl.intCommodityProductLineId) 
  LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  	
  LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId AND um.intUnitMeasureId=cv.intUnitMeasureId
  LEFT join tblICCommodityUnitMeasure um1 on  um1.intCommodityId=cv.intCommodityId and um1.intUnitMeasureId=@intUnitMeasureId  
  WHERE   cv.intFutureMarketId in (select intFutureMarketId from @Market) AND cv.intContractStatusId <> 3  and intPricingTypeId <> 1
		and cv.intCompanyLocationId in (select intCompanyLocationId from @Location)
		and ca.intCommodityAttributeId in((SELECT intCommodityAttributeId from @CommodityAttribute ))
  )t where isnull(dblNoOfLot,0)-isnull(dblFixedLots,0) <> 0

  union
--Parcial UnPriced
  SELECT intFutureMonthId,strFutureMonth,strFutMarketName,strAccountNumber,dblQuantity-dblFixedQty as dblNoOfContract,strTradeNo,TransactionDate,TranType,CustVendor,isnull(dblNoOfLot,0)-isnull(dblFixedLots,0) dblNoOfLot,dblQuantity-dblFixedQty dblQuantity,
intContractHeaderId,intFutOptTransactionHeaderId,intPricingTypeId,strContractType,intCommodityId,intCompanyLocationId,intFutureMarketId,dtmFutureMonthsDate,ysnExpired
,'UnPriced' strPricingType  ,intCommodityAttributeId,strDescription
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
		where pf.intContractHeaderId =cv.intContractHeaderId and pf.intContractDetailId=cv.intContractDetailId),0) dblFixedQty
 ,ca.intCommodityAttributeId,ca.strDescription
  FROM vyuRKRiskPositionContractDetail cv  
  JOIN tblRKFutureMarket ffm on ffm.intFutureMarketId=cv.intFutureMarketId 
  JOIN tblRKFuturesMonth fm on cv.intFutureMarketId=fm.intFutureMarketId and cv.intFutureMonthId=fm.intFutureMonthId  
  JOIN tblICItemUOM u on cv.intItemUOMId=u.intItemUOMId  
  JOIN tblICItem ic on ic.intItemId=cv.intItemId 
				and cv.intItemId not in(SELECT intItemId FROM tblICItem ici    
										JOIN tblICCommodityProductLine pl on ici.intCommodityId=pl.intCommodityId 
										AND ici.intProductLineId=pl.intCommodityProductLineId) 
  LEFT JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=ic.intProductTypeId  	
  LEFT JOIN tblARProductType pt on pt.intProductTypeId=ic.intProductTypeId
  LEFT JOIN tblICCommodityUnitMeasure um on um.intCommodityId=cv.intCommodityId AND um.intUnitMeasureId=cv.intUnitMeasureId
  LEFT join tblICCommodityUnitMeasure um1 on  um1.intCommodityId=cv.intCommodityId and um1.intUnitMeasureId=@intUnitMeasureId 
  WHERE   cv.intFutureMarketId in (select intFutureMarketId from @Market) AND cv.intContractStatusId <> 3  and intPricingTypeId <> 1
		and cv.intCompanyLocationId in (select intCompanyLocationId from @Location)
		and ca.intCommodityAttributeId in((SELECT intCommodityAttributeId from @CommodityAttribute))
  )t where isnull(dblNoOfLot,0)-isnull(dblFixedLots,0) <> 0)t1 where dblNoOfContract <>0
  
SELECT t.strFutMarketName,t.strFutureMonth, t.intFutureMarketId,t.intFutureMonthId,dblBuy,dblSell,t.dblContractSize,dtmFutureMonthsDate,
(SELECT TOP 1 strCommodityAttributeId from @BrokerageAttributeFinal b where b.intBrokerageAccountId=t.intBrokerageAccountId) intCommodityAttributeId
 INTO #FutTranTemp
FROM vyuRKGetBuySellTransaction t 
WHERE t.intFutureMarketId IN (select intFutureMarketId from @Market)
	AND t.intLocationId IN (SELECT intCompanyLocationId FROM @Location)
	AND strFutureMonth NOT IN(SELECT strFutureMonth FROM #ContractTransaction ct 
													WHERE ct.intFutureMarketId=t.intFutureMarketId and ct.strFutureMonth=t.strFutureMonth)
	AND t.intBrokerageAccountId in(SELECT intBrokerageAccountId from @BrokerageAttributeFinal)

DECLARE @FinalResult AS TABLE 
(	    
	intRowNum INT IDENTITY(1,1) PRIMARY KEY, 
	strFutMarketName  nvarchar(100),
	strFutMarketNameH  nvarchar(100),
	strFutureMonth nvarchar(100),
	dblTotalPurchase numeric(24,10),
	dblTotalSales numeric(24,10),
	dblUnfixedPurchase numeric(24,10), 
	dblUnfixedSales numeric(24,10), 
	dblFutures numeric(24,10),
	dblTotal numeric(24,10), 
	intFutureMarketId int,
	intFutureMonthId int,
	intCAttributeId int,
	strProductType nvarchar(100),
	strProductTypeH nvarchar(100),
	strColor nvarchar(50),
	intMarketSumDummyId int
)

DECLARE @ContractTemp AS TABLE 
(	    
	strFutMarketName  nvarchar(100),
	strFutureMonth nvarchar(100),
	dblTotalPurchase numeric(24,10),
	dblTotalSales numeric(24,10),
	dblUnfixedPurchase numeric(24,10), 
	dblUnfixedSales numeric(24,10), 
	dblFutures numeric(24,10),
	dblTotal numeric(24,10), 
	intFutureMarketId int,
	intFutureMonthId int,
	intMarketSumDummyId int
)

DECLARE @intLCommodityAttributeId INT = NULL
DECLARE @strDescription NVARCHAR(100)= NULL
DECLARE @intCMarketId INT = NULL
DECLARE @strFutMarket nvarchar(50)=null
	
DECLARE @intCAttributeId INT = NULL
SELECT @intCAttributeId= MIN(intAttributeId) FROM @CommodityAttribute 
WHILE @intCAttributeId >0
BEGIN

	SELECT @intLCommodityAttributeId=a.intCommodityAttributeId,@strDescription=ca.strDescription FROM @CommodityAttribute a
	JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=a.intCommodityAttributeId  WHERE intAttributeId=@intCAttributeId 

	IF EXISTS((SELECT intCommodityAttributeId FROM #ContractTransaction WHERE intCommodityAttributeId=@intLCommodityAttributeId
				UNION
				SELECT top 1 intCommodityAttributeId FROM #FutTranTemp  WHERE intCommodityAttributeId=@intLCommodityAttributeId)) 			 
	BEGIN
		INSERT INTO @FinalResult(strProductTypeH,strProductType,strColor,intMarketSumDummyId,intCAttributeId)
		SELECT upper(@strDescription),@strDescription,'Over all Total',1,@intLCommodityAttributeId
    
		DECLARE @intFMarketId INT= NULL
		SELECT @intFMarketId= MIN(intMarketId) FROM @Market

		WHILE @intFMarketId >0
		BEGIN		

		SELECT @intCMarketId= intFutureMarketId from @Market where intMarketId=@intFMarketId
		SELECT @strFutMarket=strFutMarketName  FROM tblRKFutureMarket WHERE intFutureMarketId=@intCMarketId

		DECLARE @intPreviousMonthId int = null
		DECLARE @dtmFutureMonthsDate as datetime = null
		SELECT TOP 1 @intPreviousMonthId=intFutureMonthId FROM tblRKFuturesMonth WHERE ysnExpired = 0 
				AND  dtmSpotDate <= GETDATE() AND intFutureMarketId = @intCMarketId ORDER BY intFutureMonthId DESC
		SELECT TOP 1 @dtmFutureMonthsDate=dtmFutureMonthsDate FROM tblRKFuturesMonth WHERE intFutureMonthId=@intPreviousMonthId
		
		DELETE FROM @ContractTemp
							


		--Physical
			INSERT INTO @ContractTemp(strFutMarketName,strFutureMonth,dblTotalPurchase,dblTotalSales ,dblUnfixedPurchase, dblUnfixedSales, dblFutures,dblTotal, intFutureMarketId)
				SELECT  strFutMarketName,strFutureMonth strFutureMonth,sum(dblPurchase) dblTotalPurchase,
					sum(dblSale) dblTotalSales,sum(dblPurchaseUnpriced) dblUnfixedPurchase,sum(dblSaleUnpriced) dblUnfixedSales,sum(dblBuySell) dblFutures,
						sum((dblPurchasePriced-dblSalePriced)+ dblBuySell) as dblTotal, t.intFutureMarketId  
				FROM (
					 SELECT ft.strFutMarketName,'Previous' as strFutureMonth,t.intFutureMarketId, 
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and ct.TranType='Purchase' and intCommodityAttributeId=@intLCommodityAttributeId and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblPurchase,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale' and intCommodityAttributeId=@intLCommodityAttributeId and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblSale,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Purchase' and intCommodityAttributeId=@intLCommodityAttributeId and  strPricingType='UnPriced'  and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblPurchaseUnpriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale' and intCommodityAttributeId=@intLCommodityAttributeId and  strPricingType='UnPriced'  and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblSaleUnpriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Purchase' and intCommodityAttributeId=@intLCommodityAttributeId and  strPricingType='Priced'  and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblPurchasePriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale' and intCommodityAttributeId=@intLCommodityAttributeId and  strPricingType='Priced'  and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblSalePriced,
					 0.0 dblBuySell 
					 FROM #ContractTransaction t  
					 JOIN vyuRKGetBuySellTransaction ft ON ft.intFutureMarketId=t.intFutureMarketId and  t.dtmFutureMonthsDate < @dtmFutureMonthsDate 					
					 WHERE ft.intFutureMarketId=@intCMarketId and intCommodityAttributeId=@intLCommodityAttributeId 
					 and t.intCompanyLocationId in (select intCompanyLocationId from @Location)
					 GROUP BY ft.strFutMarketName,t.strFutureMonth,t.intFutureMarketId,ft.dblContractSize,t.intFutureMarketId

					 UNION

					 SELECT ft.strFutMarketName,t.strFutureMonth,t.intFutureMarketId, 
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and ct.TranType='Purchase'  and intCommodityAttributeId=@intLCommodityAttributeId and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblPurchase,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale'  and intCommodityAttributeId=@intLCommodityAttributeId and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblSale,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Purchase'  and intCommodityAttributeId=@intLCommodityAttributeId and  strPricingType='UnPriced'  and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblPurchaseUnpriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale'  and intCommodityAttributeId=@intLCommodityAttributeId and  strPricingType='UnPriced'  and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblSaleUnpriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Purchase'  and intCommodityAttributeId=@intLCommodityAttributeId and  strPricingType='Priced'  and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblPurchasePriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale' and intCommodityAttributeId=@intLCommodityAttributeId and  strPricingType='Priced'  and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblSalePriced,
					 --isnull((select sum(dblBuy-dblSell) dblNoOfcontract from vyuRKGetBuySellTransaction ct where ct.intFutureMarketId=t.intFutureMarketId and ct.strFutureMonth=t.strFutureMonth   and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0)*ft.dblContractSize 
					 0.0 dblBuySell 
					 FROM #ContractTransaction t  
					 JOIN vyuRKGetBuySellTransaction ft ON ft.intFutureMarketId=t.intFutureMarketId and t.dtmFutureMonthsDate >= @dtmFutureMonthsDate 					
					 WHERE ft.intFutureMarketId =@intCMarketId and intCommodityAttributeId=@intLCommodityAttributeId
					  and t.intCompanyLocationId in (select intCompanyLocationId from @Location)
					 GROUP BY ft.strFutMarketName,t.strFutureMonth,t.intFutureMarketId,ft.dblContractSize,t.intFutureMarketId
 
					 UNION
	--Futures
					 SELECT strFutMarketName,strFutureMonth,intFutureMarketId, 0.0 dblPurchase, 0.0 dblSale, 
							0.0 dblPurchaseUnpriced, 0.0 dblSaleUnpriced, 0.0 dblPurchasePriced, 0.0 dblSalePriced, sum(dblBuy-dblSell)*max(dblContractSize)  dblBuySell 
					 FROM (
					 SELECT t.strFutMarketName,'Previous' strFutureMonth, t.intFutureMarketId,
					 isnull(dblBuy,0) dblBuy, isnull(dblSell,0) dblSell,dblContractSize
					 FROM vyuRKGetBuySellTransaction t 
					  WHERE t.intFutureMarketId =@intCMarketId
							and t.intLocationId in (select intCompanyLocationId from @Location)
							and t.intBrokerageAccountId in(SELECT intBrokerageAccountId from @BrokerageAttributeFinal									
															WHERE strCommodityAttributeId =@intLCommodityAttributeId)
						and  t.dtmFutureMonthsDate < @dtmFutureMonthsDate)t
					 GROUP BY  strFutMarketName,strFutureMonth,intFutureMarketId

					 UNION
					 SELECT strFutMarketName,strFutureMonth,intFutureMarketId, 0.0 dblPurchase, 0.0 dblSale, 
							0.0 dblPurchaseUnpriced, 0.0 dblSaleUnpriced, 0.0 dblPurchasePriced, 0.0 dblSalePriced, sum(dblBuy-dblSell)*max(dblContractSize)  dblBuySell
					FROM (
					 SELECT t.strFutMarketName,t.strFutureMonth, t.intFutureMarketId,
					  isnull(dblBuy,0) dblBuy, isnull(dblSell,0) dblSell,dblContractSize
					 FROM vyuRKGetBuySellTransaction t 
					  WHERE t.intFutureMarketId = @intCMarketId
							AND t.intLocationId in (SELECT intCompanyLocationId FROM @Location)
							AND t.intBrokerageAccountId in(SELECT intBrokerageAccountId from @BrokerageAttributeFinal									
															WHERE strCommodityAttributeId=@intLCommodityAttributeId )
						AND  t.dtmFutureMonthsDate >= @dtmFutureMonthsDate)t
					 GROUP BY  strFutMarketName,strFutureMonth,intFutureMarketId
					 )t
					 group by strFutMarketName,strFutureMonth,t.intFutureMarketId
					 ORDER BY strFutMarketName, CASE WHEN  strFutureMonth ='Previous' THEN '01/01/1900' 
					  WHEN  strFutureMonth ='TOTAL' THEN '01/01/9999'
					 ELSE CONVERT(DATETIME,'01 '+strFutureMonth) END ASC
			
			IF EXISTS(SELECT * FROM @ContractTemp)
			BEGIN
				INSERT INTO @FinalResult (strFutMarketNameH,strColor) 
				select upper(@strFutMarket),'TOTAL'
				INSERT INTO @FinalResult (strFutureMonth,dblTotalPurchase,dblTotalSales ,dblUnfixedPurchase, dblUnfixedSales, dblFutures,dblTotal, intFutureMarketId,intCAttributeId)
				SELECT strFutureMonth strFutureMonth,dblTotalPurchase,
							dblTotalSales,dblUnfixedPurchase,dblUnfixedSales,dblFutures,dblTotal,intFutureMarketId,@intLCommodityAttributeId from @ContractTemp
			
				INSERT INTO @FinalResult (strFutMarketNameH,dblTotalPurchase,dblTotalSales ,dblUnfixedPurchase, dblUnfixedSales, dblFutures,dblTotal,strColor)
				SELECT 'TOTAL',sum(dblTotalPurchase),sum(dblTotalSales) ,sum(dblUnfixedPurchase), sum(dblUnfixedSales), sum(dblFutures),sum(dblTotal),'Total' 
				FROM @FinalResult 			
				WHERE  intFutureMarketId=@intCMarketId and intCAttributeId = @intLCommodityAttributeId
			END

		SELECT @intFMarketId= min(intMarketId) FROM @Market WHERE intMarketId > @intFMarketId
		END	
		INSERT INTO @FinalResult (strProductTypeH,dblTotalPurchase,dblTotalSales ,dblUnfixedPurchase, dblUnfixedSales, dblFutures,dblTotal,strColor)
		SELECT 'TOTAL',sum(dblTotalPurchase),sum(dblTotalSales) ,sum(dblUnfixedPurchase), sum(dblUnfixedSales), sum(dblFutures),sum(dblTotal),'Total' 
		FROM @FinalResult WHERE  intCAttributeId=@intLCommodityAttributeId 
	END
SELECT @intCAttributeId= min(intAttributeId) FROM @CommodityAttribute WHERE intAttributeId > @intCAttributeId
END	


-------------------------------By Market ----------------------

INSERT INTO @FinalResult(strProductTypeH,strColor,intMarketSumDummyId) values (upper('OVER ALL AGAINST MARKET'),'TOTAL - OVER All',1)
declare @intFMarketId1  int = null
declare @intPreviousMonthId1 int = null
declare @dtmFutureMonthsDate1 datetime=null

		SELECT @intFMarketId1 = NULL
		SELECT @intFMarketId1= MIN(intMarketId) FROM @Market

		WHILE @intFMarketId1 >0
		BEGIN

		SELECT @intCMarketId  = NULL
		SELECT @strFutMarket =null
		SELECT @intCMarketId=m.intFutureMarketId,@strFutMarket=strFutMarketName from @Market m
		JOIN tblRKFutureMarket fm on fm.intFutureMarketId=m.intFutureMarketId where m.intMarketId=@intFMarketId1 

		SELECT @intPreviousMonthId1  = null
		SELECT @dtmFutureMonthsDate1  = null
		SELECT TOP 1 @intPreviousMonthId1=intFutureMonthId FROM tblRKFuturesMonth WHERE ysnExpired = 0 
				AND  dtmSpotDate <= GETDATE() AND intFutureMarketId = @intCMarketId ORDER BY intFutureMonthId DESC
		SELECT TOP 1 @dtmFutureMonthsDate1=dtmFutureMonthsDate FROM tblRKFuturesMonth WHERE intFutureMonthId=@intPreviousMonthId1

		DELETE FROM @ContractTemp


		INSERT INTO @ContractTemp(strFutMarketName,strFutureMonth,dblTotalPurchase,dblTotalSales ,dblUnfixedPurchase, dblUnfixedSales, dblFutures,dblTotal, intFutureMarketId,intMarketSumDummyId)
				SELECT  strFutMarketName,strFutureMonth strFutureMonth,sum(dblPurchase) dblTotalPurchase,
						sum(dblSale) dblTotalSales,sum(dblPurchaseUnpriced) dblUnfixedPurchase,sum(dblSaleUnpriced) dblUnfixedSales,sum(dblBuySell) dblFutures,
						 sum((dblPurchasePriced-dblSalePriced)+ dblBuySell) as dblTotal, t.intFutureMarketId,-1
					FROM (
					 SELECT ft.strFutMarketName,'Previous' as strFutureMonth,t.intFutureMarketId, 
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and ct.TranType='Purchase' and intCommodityAttributeId in(SELECT intCommodityAttributeId from @CommodityAttribute) and dtmFutureMonthsDate < @dtmFutureMonthsDate1),0) dblPurchase,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale' and intCommodityAttributeId in(SELECT intCommodityAttributeId from @CommodityAttribute) and dtmFutureMonthsDate < @dtmFutureMonthsDate1),0) dblSale,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Purchase' and intCommodityAttributeId in(SELECT intCommodityAttributeId from @CommodityAttribute) and  strPricingType='UnPriced'  and dtmFutureMonthsDate < @dtmFutureMonthsDate1),0) dblPurchaseUnpriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale' and intCommodityAttributeId  in(SELECT intCommodityAttributeId from @CommodityAttribute)and  strPricingType='UnPriced'  and dtmFutureMonthsDate < @dtmFutureMonthsDate1),0) dblSaleUnpriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Purchase' and intCommodityAttributeId  in(SELECT intCommodityAttributeId from @CommodityAttribute) and  strPricingType='Priced'  and dtmFutureMonthsDate < @dtmFutureMonthsDate1),0) dblPurchasePriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale' and intCommodityAttributeId in(SELECT intCommodityAttributeId from @CommodityAttribute) and  strPricingType='Priced'  and dtmFutureMonthsDate < @dtmFutureMonthsDate1),0) dblSalePriced,
					 0.0 dblBuySell 
					 FROM #ContractTransaction t  
					 JOIN vyuRKGetBuySellTransaction ft ON ft.intFutureMarketId=t.intFutureMarketId and  t.dtmFutureMonthsDate < @dtmFutureMonthsDate1 					
					 WHERE ft.intFutureMarketId=@intCMarketId and intCommodityAttributeId in(SELECT intCommodityAttributeId from @CommodityAttribute)
					  and t.intCompanyLocationId in (select intCompanyLocationId from @Location)
					 GROUP BY ft.strFutMarketName,t.strFutureMonth,t.intFutureMarketId,ft.dblContractSize,t.intFutureMarketId

					 UNION

					 SELECT ft.strFutMarketName,t.strFutureMonth,t.intFutureMarketId, 
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and ct.TranType='Purchase'  and intCommodityAttributeId  in(SELECT intCommodityAttributeId from @CommodityAttribute) and dtmFutureMonthsDate >= @dtmFutureMonthsDate1),0) dblPurchase,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale'  and intCommodityAttributeId  in(SELECT intCommodityAttributeId from @CommodityAttribute) and dtmFutureMonthsDate >= @dtmFutureMonthsDate1),0) dblSale,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Purchase'  and intCommodityAttributeId  in(SELECT intCommodityAttributeId from @CommodityAttribute) and  strPricingType='UnPriced'  and dtmFutureMonthsDate >= @dtmFutureMonthsDate1),0) dblPurchaseUnpriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale'  and intCommodityAttributeId  in(SELECT intCommodityAttributeId from @CommodityAttribute) and  strPricingType='UnPriced'  and dtmFutureMonthsDate >= @dtmFutureMonthsDate1),0) dblSaleUnpriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Purchase'  and intCommodityAttributeId  in(SELECT intCommodityAttributeId from @CommodityAttribute) and  strPricingType='Priced'  and dtmFutureMonthsDate >= @dtmFutureMonthsDate1),0) dblPurchasePriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale' and intCommodityAttributeId  in(SELECT intCommodityAttributeId from @CommodityAttribute) and  strPricingType='Priced'  and dtmFutureMonthsDate >= @dtmFutureMonthsDate1),0) dblSalePriced,
					 0.0 dblBuySell 
					 FROM #ContractTransaction t  
					 JOIN vyuRKGetBuySellTransaction ft ON ft.intFutureMarketId=t.intFutureMarketId and t.dtmFutureMonthsDate >= @dtmFutureMonthsDate1 					
					 WHERE ft.intFutureMarketId =@intCMarketId and 
					 intCommodityAttributeId in (SELECT intCommodityAttributeId from @CommodityAttribute)
					 and t.intCompanyLocationId in (select intCompanyLocationId from @Location)
					 GROUP BY ft.strFutMarketName,t.strFutureMonth,t.intFutureMarketId,ft.dblContractSize,t.intFutureMarketId
 
					UNION
					SELECT strFutMarketName,strFutureMonth,intFutureMarketId, 0.0 dblPurchase, 0.0 dblSale, 
							0.0 dblPurchaseUnpriced, 0.0 dblSaleUnpriced, 0.0 dblPurchasePriced, 0.0 dblSalePriced, sum(dblBuy-dblSell)*max(dblContractSize)  dblBuySell
					FROM (
					 SELECT t.strFutMarketName,'Previous' strFutureMonth, t.intFutureMarketId, isnull(dblBuy,0) dblBuy, isnull(dblSell,0) dblSell,dblContractSize
					 FROM vyuRKGetBuySellTransaction t 
					  WHERE t.intFutureMarketId =@intCMarketId
							anD t.intLocationId in (select intCompanyLocationId from @Location)
							and t.intBrokerageAccountId in(SELECT intBrokerageAccountId from @BrokerageAttributeFinal									
															WHERE strCommodityAttributeId in(SELECT intCommodityAttributeId from @CommodityAttribute))
						and  t.dtmFutureMonthsDate < @dtmFutureMonthsDate1)t
					 GROUP BY strFutMarketName,strFutureMonth,intFutureMarketId

					 UNION

					 SELECT strFutMarketName,strFutureMonth,intFutureMarketId, 0.0 dblPurchase, 0.0 dblSale, 
						0.0 dblPurchaseUnpriced, 0.0 dblSaleUnpriced, 0.0 dblPurchasePriced, 0.0 dblSalePriced, sum(dblBuy-dblSell)*max(dblContractSize)  dblBuySell
					FROM (
					 SELECT t.strFutMarketName,t.strFutureMonth, t.intFutureMarketId, isnull(dblBuy,0) dblBuy, isnull(dblSell,0) dblSell,dblContractSize					 
					 FROM vyuRKGetBuySellTransaction t 
					  WHERE t.intFutureMarketId = @intCMarketId
							AND t.intLocationId in (select intCompanyLocationId from @Location)
							AND t.intBrokerageAccountId in(SELECT intBrokerageAccountId from @BrokerageAttributeFinal									
															WHERE strCommodityAttributeId in(SELECT intCommodityAttributeId from @CommodityAttribute) )
						AND  t.dtmFutureMonthsDate >= @dtmFutureMonthsDate1)t
					 GROUP BY strFutMarketName,strFutureMonth,intFutureMarketId)t
					 GROUP BY strFutMarketName,strFutureMonth,intFutureMarketId
					 ORDER BY strFutMarketName, CASE WHEN  strFutureMonth ='Previous' THEN '01/01/1900' 
					  WHEN  strFutureMonth ='TOTAL' THEN '01/01/9999'
					 ELSE CONVERT(DATETIME,'01 '+strFutureMonth) END ASC
			
			IF EXISTS(SELECT * FROM @ContractTemp)
			BEGIN
				INSERT INTO @FinalResult (strFutMarketNameH,strColor) 
				select upper(@strFutMarket),'TOTAL'

				INSERT INTO @FinalResult (strFutureMonth,dblTotalPurchase,dblTotalSales ,dblUnfixedPurchase, dblUnfixedSales, dblFutures,dblTotal, intFutureMarketId,intCAttributeId,intMarketSumDummyId)
				SELECT strFutureMonth strFutureMonth,dblTotalPurchase,
							dblTotalSales,dblUnfixedPurchase,dblUnfixedSales,dblFutures,dblTotal,intFutureMarketId,0,-1 from @ContractTemp

				INSERT INTO @FinalResult (strFutMarketNameH,dblTotalPurchase,dblTotalSales ,dblUnfixedPurchase, dblUnfixedSales, dblFutures,dblTotal,strColor,intMarketSumDummyId)
					SELECT 'TOTAL',sum(dblTotalPurchase),sum(dblTotalSales) ,sum(dblUnfixedPurchase), sum(dblUnfixedSales), sum(dblFutures),sum(dblTotal),'TOTAL',-2 
					FROM @FinalResult 			
					WHERE  intFutureMarketId=@intCMarketId and intMarketSumDummyId =-1
		   	END
		SELECT @intFMarketId1= min(intMarketId) FROM @Market WHERE intMarketId > @intFMarketId1
	END	


------------------------- END

INSERT INTO @FinalResult (strProductTypeH,dblTotalPurchase,dblTotalSales ,dblUnfixedPurchase, dblUnfixedSales, dblFutures,dblTotal,strColor)
SELECT 'TOTAL',sum(dblTotalPurchase),sum(dblTotalSales) ,sum(dblUnfixedPurchase), sum(dblUnfixedSales), sum(dblFutures),sum(dblTotal),'Total' 
FROM @FinalResult 			
WHERE   intMarketSumDummyId =-2

SELECT intRowNum,strProductTypeH strProductType,strFutMarketNameH strFutMarketName,strFutureMonth,round(dblTotalPurchase,@intDecimals) as dblTotalPurchase,
		round(dblTotalSales,@intDecimals) dblTotalSales ,round(dblUnfixedPurchase,@intDecimals) dblUnfixedPurchase, round(dblUnfixedSales,@intDecimals) dblUnfixedSales, 
		round(dblFutures,@intDecimals) dblFutures,round(dblTotal,@intDecimals) dblTotal, intFutureMarketId,intCAttributeId intCommodityAttributeId,strColor,intMarketSumDummyId,null as intFutureMonthId  FROM @FinalResult order by intRowNum