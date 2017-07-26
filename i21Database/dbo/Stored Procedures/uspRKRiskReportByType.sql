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
  ,ysnExpired,'Priced' strPricingType,ca.intCommodityAttributeId,ca.strDescription
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
  LEFT JOIN tblICCommodityUnitMeasure um1 on  um1.intCommodityId=cv.intCommodityId and um.intUnitMeasureId=@intUnitMeasureId  
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

DECLARE @intCAttributeId INT = NULL
SELECT @intCAttributeId= min(intAttributeId) from @CommodityAttribute
WHILE @intCAttributeId >0
BEGIN
	DECLARE @intLCommodityAttributeId int = null
	DECLARE @strDescription nvarchar(100)= null

	SELECT @intLCommodityAttributeId=a.intCommodityAttributeId,@strDescription=ca.strDescription from @CommodityAttribute a
	JOIN tblICCommodityAttribute ca on ca.intCommodityAttributeId=a.intCommodityAttributeId  where intAttributeId=@intCAttributeId 

	INSERT INTO @FinalResult(strProductTypeH,strProductType,strColor,intMarketSumDummyId)
	select @strDescription,@strDescription,'ProductTypeHeader',1


		DECLARE @intFMarketId INT= NULL
		SELECT @intFMarketId= MIN(intMarketId) FROM @Market

		WHILE @intFMarketId >0
		BEGIN

		DECLARE @intCMarketId INT = NULL
		DECLARE @strFutMarket nvarchar(50)=null
		SELECT @intCMarketId=m.intFutureMarketId,@strFutMarket=strFutMarketName from @Market m
		JOIN tblRKFutureMarket fm on fm.intFutureMarketId=m.intFutureMarketId where m.intMarketId=@intFMarketId 
				
		DECLARE @intPreviousMonthId int = null
		DECLARE @dtmFutureMonthsDate as datetime = null
		SELECT TOP 1 @intPreviousMonthId=intFutureMonthId FROM tblRKFuturesMonth WHERE ysnExpired = 0 
				AND  dtmSpotDate <= GETDATE() AND intFutureMarketId = @intCMarketId ORDER BY intFutureMonthId DESC
		SELECT TOP 1 @dtmFutureMonthsDate=dtmFutureMonthsDate FROM tblRKFuturesMonth WHERE intFutureMonthId=@intPreviousMonthId
		
			
				INSERT INTO @FinalResult (strProductType,strFutMarketName,strFutureMonth,dblTotalPurchase,dblTotalSales ,dblUnfixedPurchase, dblUnfixedSales, dblFutures,dblTotal, intFutureMarketId,intFutureMonthId,intCAttributeId)
					SELECT  @strDescription,strFutMarketName,strFutureMonth strFutureMonth,dblPurchase dblTotalPurchase,
						dblSale dblTotalSales,dblPurchaseUnpriced dblUnfixedPurchase,dblSaleUnpriced dblUnfixedSales,dblBuySell dblFutures,
						 (dblPurchasePriced-dblSalePriced)+ dblBuySell as dblTotal, t.intFutureMarketId,t.intFutureMonthId,@intLCommodityAttributeId
					FROM (
					 SELECT ft.strFutMarketName,'Previous' as strFutureMonth,t.intFutureMarketId,t.intFutureMonthId, 
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and ct.TranType='Purchase' and intCommodityAttributeId=@intLCommodityAttributeId and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblPurchase,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale' and intCommodityAttributeId=@intLCommodityAttributeId and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblSale,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Purchase' and intCommodityAttributeId=@intLCommodityAttributeId and  strPricingType='UnPriced'  and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblPurchaseUnpriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale' and intCommodityAttributeId=@intLCommodityAttributeId and  strPricingType='UnPriced'  and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblSaleUnpriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Purchase' and intCommodityAttributeId=@intLCommodityAttributeId and  strPricingType='Priced'  and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblPurchasePriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale' and intCommodityAttributeId=@intLCommodityAttributeId and  strPricingType='Priced'  and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblSalePriced,
					 isnull((select sum(dblBuy-dblSell) dblNoOfcontract from vyuRKGetBuySellTransaction ct where ct.intFutureMarketId=t.intFutureMarketId and ct.strFutureMonth=t.strFutureMonth   and dtmFutureMonthsDate > @dtmFutureMonthsDate),0)*ft.dblContractSize dblBuySell 
					 FROM #ContractTransaction t  
					 JOIN vyuRKGetBuySellTransaction ft ON ft.intFutureMarketId=t.intFutureMarketId and  t.dtmFutureMonthsDate < @dtmFutureMonthsDate 					
					 WHERE ft.intFutureMarketId=@intCMarketId and intCommodityAttributeId=@intLCommodityAttributeId
					 GROUP BY ft.strFutMarketName,t.strFutureMonth,t.intFutureMarketId,ft.dblContractSize,t.intFutureMarketId,t.intFutureMonthId

					 UNION

					 SELECT ft.strFutMarketName,t.strFutureMonth,t.intFutureMarketId,t.intFutureMonthId, 
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and ct.TranType='Purchase'  and intCommodityAttributeId=@intLCommodityAttributeId and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblPurchase,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale'  and intCommodityAttributeId=@intLCommodityAttributeId and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblSale,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Purchase'  and intCommodityAttributeId=@intLCommodityAttributeId and  strPricingType='UnPriced'  and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblPurchaseUnpriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale'  and intCommodityAttributeId=@intLCommodityAttributeId and  strPricingType='UnPriced'  and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblSaleUnpriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Purchase'  and intCommodityAttributeId=@intLCommodityAttributeId and  strPricingType='Priced'  and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblPurchasePriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale' and intCommodityAttributeId=@intLCommodityAttributeId and  strPricingType='Priced'  and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblSalePriced,
					 isnull((select sum(dblBuy-dblSell) dblNoOfcontract from vyuRKGetBuySellTransaction ct where ct.intFutureMarketId=t.intFutureMarketId and ct.strFutureMonth=t.strFutureMonth   and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0)*ft.dblContractSize dblBuySell 
					 FROM #ContractTransaction t  
					 JOIN vyuRKGetBuySellTransaction ft ON ft.intFutureMarketId=t.intFutureMarketId and t.dtmFutureMonthsDate >= @dtmFutureMonthsDate 					
					 WHERE ft.intFutureMarketId =@intCMarketId and intCommodityAttributeId=@intLCommodityAttributeId
					 GROUP BY ft.strFutMarketName,t.strFutureMonth,t.intFutureMarketId,ft.dblContractSize,t.intFutureMarketId,t.intFutureMonthId
 
					 UNION

					 SELECT t.strFutMarketName,'Previous' strFutureMonth, t.intFutureMarketId,t.intFutureMonthId,
					 0.0 dblPurchase,
					 0.0 dblSale,
					 0.0 dblPurchaseUnpriced,
					 0.0 dblSaleUnpriced,
					 0.0 dblPurchasePriced,
					 0.0 dblSalePriced,
					 isnull((select sum(dblBuy-dblSell) dblNoOfcontract from vyuRKGetBuySellTransaction ct where ct.intFutureMarketId=t.intFutureMarketId and ct.strFutureMonth=t.strFutureMonth and ct.dtmFutureMonthsDate < @dtmFutureMonthsDate),0)*t.dblContractSize dblBuySell 
					 FROM vyuRKGetBuySellTransaction t 
					  WHERE t.intFutureMarketId =@intCMarketId
							and t.intLocationId in (select intCompanyLocationId from @Location)
							AND strFutureMonth NOT IN(SELECT strFutureMonth FROM #ContractTransaction ct 
																				WHERE ct.intFutureMarketId=t.intFutureMarketId and ct.strFutureMonth=t.strFutureMonth)
							and t.intBrokerageAccountId in(SELECT intBrokerageAccountId from @BrokerageAttributeFinal									
															WHERE strCommodityAttributeId =@intLCommodityAttributeId)
						and  t.dtmFutureMonthsDate < @dtmFutureMonthsDate									
					 GROUP BY t.strFutMarketName,t.strFutureMonth,t.intFutureMarketId,t.dblContractSize,t.intFutureMarketId,t.intFutureMonthId

					 UNION

					 SELECT t.strFutMarketName,t.strFutureMonth, t.intFutureMarketId,t.intFutureMonthId,
						 0.0 dblPurchase,
						 0.0 dblSale,
						 0.0 dblPurchaseUnpriced,
						 0.0 dblSaleUnpriced,
						 0.0 dblPurchasePriced,
						 0.0 dblSalePriced,
					 isnull((select sum(dblBuy-dblSell) dblNoOfcontract from vyuRKGetBuySellTransaction ct where ct.intFutureMarketId=t.intFutureMarketId and ct.strFutureMonth=t.strFutureMonth and ct.dtmFutureMonthsDate >= @dtmFutureMonthsDate),0)*t.dblContractSize dblBuySell 
					 FROM vyuRKGetBuySellTransaction t 
					  WHERE t.intFutureMarketId = @intCMarketId
							AND t.intLocationId in (select intCompanyLocationId from @Location)
							AND strFutureMonth NOT IN(SELECT strFutureMonth FROM #ContractTransaction ct 
																				WHERE ct.intFutureMarketId=t.intFutureMarketId and ct.strFutureMonth=t.strFutureMonth)
							AND t.intBrokerageAccountId in(SELECT intBrokerageAccountId from @BrokerageAttributeFinal									
															WHERE strCommodityAttributeId=@intLCommodityAttributeId )
						AND  t.dtmFutureMonthsDate >= @dtmFutureMonthsDate									
					 GROUP BY t.strFutMarketName,t.strFutureMonth,t.intFutureMarketId,t.dblContractSize,t.intFutureMarketId,t.intFutureMonthId)t
					 ORDER BY strFutMarketName, CASE WHEN  strFutureMonth ='Previous' THEN '01/01/1900' 
					  WHEN  strFutureMonth ='Total' THEN '01/01/9999'
					 ELSE CONVERT(DATETIME,'01 '+strFutureMonth) END ASC
			
				INSERT INTO @FinalResult (strFutMarketName,dblTotalPurchase,dblTotalSales ,dblUnfixedPurchase, dblUnfixedSales, dblFutures,dblTotal,strColor)
					SELECT 'Total -' +@strFutMarket,sum(dblTotalPurchase),sum(dblTotalSales) ,sum(dblUnfixedPurchase), sum(dblUnfixedSales), sum(dblFutures),sum(dblTotal),'Total' 
					FROM @FinalResult 			
					WHERE  intFutureMarketId=@intCMarketId and intCAttributeId = @intLCommodityAttributeId
				DELETE FROM @FinalResult where strFutureMonth='Total -' +@strFutMarket and isnull(dblTotalPurchase,0) = 0
					and isnull(dblTotalSales,0) = 0 and isnull(dblUnfixedPurchase,0) = 0 and isnull(dblUnfixedSales,0) = 0
					and isnull(dblFutures,0) = 0 and isnull(dblTotal,0) = 0
		SELECT @intFMarketId= min(intMarketId) FROM @Market WHERE intMarketId > @intFMarketId
		END	

		INSERT INTO @FinalResult (strFutMarketName,dblTotalPurchase,dblTotalSales ,dblUnfixedPurchase, dblUnfixedSales, dblFutures,dblTotal,strColor)
					SELECT 'Total -'+@strDescription,sum(dblTotalPurchase),sum(dblTotalSales) ,sum(dblUnfixedPurchase), sum(dblUnfixedSales), sum(dblFutures),sum(dblTotal),'Over all Total' 
					FROM @FinalResult 			
					WHERE  intCAttributeId=@intLCommodityAttributeId 
		DELETE FROM @FinalResult WHERE strFutureMonth='Total -'+@strDescription and isnull(dblTotalPurchase,0) = 0
		and isnull(dblTotalSales,0) = 0 and isnull(dblUnfixedPurchase,0) = 0 and isnull(dblUnfixedSales,0) = 0
		and isnull(dblFutures,0) = 0 and isnull(dblTotal,0) = 0

SELECT @intCAttributeId= min(intAttributeId) FROM @CommodityAttribute WHERE intAttributeId > @intCAttributeId
END	

DELETE from @FinalResult
WHERE strProductType IN (SELECT strProductType FROM @FinalResult GROUP BY strProductType HAVING COUNT(*) <= 1 and strProductType IS NOT NULL) 

-----------------------------By Market ----------------------

insert into @FinalResult(strProductTypeH,strColor,intMarketSumDummyId) values ('Over all against market','Total - Over All',1)

		SELECT @intFMarketId = NULL
		SELECT @intFMarketId= MIN(intMarketId) FROM @Market

		WHILE @intFMarketId >0
		BEGIN

		SELECT @intCMarketId  = NULL
		SELECT @strFutMarket =null
		SELECT @intCMarketId=m.intFutureMarketId,@strFutMarket=strFutMarketName from @Market m
		JOIN tblRKFutureMarket fm on fm.intFutureMarketId=m.intFutureMarketId where m.intMarketId=@intFMarketId 

		SELECT @intPreviousMonthId  = null
		SELECT @dtmFutureMonthsDate  = null
		SELECT TOP 1 @intPreviousMonthId=intFutureMonthId FROM tblRKFuturesMonth WHERE ysnExpired = 0 
				AND  dtmSpotDate <= GETDATE() AND intFutureMarketId = @intCMarketId ORDER BY intFutureMonthId DESC
		SELECT TOP 1 @dtmFutureMonthsDate=dtmFutureMonthsDate FROM tblRKFuturesMonth WHERE intFutureMonthId=@intPreviousMonthId
		insert into @FinalResult(strFutMarketName,strColor,intMarketSumDummyId) values (@strFutMarket,'MarketHeader',1)			
				INSERT INTO @FinalResult (strFutureMonth,dblTotalPurchase,dblTotalSales ,dblUnfixedPurchase, dblUnfixedSales, dblFutures,dblTotal, intFutureMarketId,intFutureMonthId,intMarketSumDummyId)
					SELECT  strFutureMonth strFutureMonth,dblPurchase dblTotalPurchase,
						dblSale dblTotalSales,dblPurchaseUnpriced dblUnfixedPurchase,dblSaleUnpriced dblUnfixedSales,dblBuySell dblFutures,
						 (dblPurchasePriced-dblSalePriced)+ dblBuySell as dblTotal, t.intFutureMarketId,t.intFutureMonthId,-1
					FROM (
					 SELECT ft.strFutMarketName,'Previous' as strFutureMonth,t.intFutureMarketId,t.intFutureMonthId, 
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and ct.TranType='Purchase' and intCommodityAttributeId in(SELECT intCommodityAttributeId from @CommodityAttribute) and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblPurchase,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale' and intCommodityAttributeId in(SELECT intCommodityAttributeId from @CommodityAttribute) and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblSale,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Purchase' and intCommodityAttributeId in(SELECT intCommodityAttributeId from @CommodityAttribute) and  strPricingType='UnPriced'  and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblPurchaseUnpriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale' and intCommodityAttributeId  in(SELECT intCommodityAttributeId from @CommodityAttribute)and  strPricingType='UnPriced'  and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblSaleUnpriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Purchase' and intCommodityAttributeId  in(SELECT intCommodityAttributeId from @CommodityAttribute) and  strPricingType='Priced'  and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblPurchasePriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale' and intCommodityAttributeId in(SELECT intCommodityAttributeId from @CommodityAttribute) and  strPricingType='Priced'  and dtmFutureMonthsDate < @dtmFutureMonthsDate),0) dblSalePriced,
					 isnull((select sum(dblBuy-dblSell) dblNoOfcontract from vyuRKGetBuySellTransaction ct where ct.intFutureMarketId=t.intFutureMarketId and ct.strFutureMonth=t.strFutureMonth   and dtmFutureMonthsDate > @dtmFutureMonthsDate),0)*ft.dblContractSize dblBuySell 
					 FROM #ContractTransaction t  
					 JOIN vyuRKGetBuySellTransaction ft ON ft.intFutureMarketId=t.intFutureMarketId and  t.dtmFutureMonthsDate < @dtmFutureMonthsDate 					
					 WHERE ft.intFutureMarketId=@intCMarketId and intCommodityAttributeId in(SELECT intCommodityAttributeId from @CommodityAttribute)
					 GROUP BY ft.strFutMarketName,t.strFutureMonth,t.intFutureMarketId,ft.dblContractSize,t.intFutureMarketId,t.intFutureMonthId

					 UNION

					 SELECT ft.strFutMarketName,t.strFutureMonth,t.intFutureMarketId,t.intFutureMonthId, 
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and ct.TranType='Purchase'  and intCommodityAttributeId  in(SELECT intCommodityAttributeId from @CommodityAttribute) and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblPurchase,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale'  and intCommodityAttributeId  in(SELECT intCommodityAttributeId from @CommodityAttribute) and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblSale,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Purchase'  and intCommodityAttributeId  in(SELECT intCommodityAttributeId from @CommodityAttribute) and  strPricingType='UnPriced'  and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblPurchaseUnpriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale'  and intCommodityAttributeId  in(SELECT intCommodityAttributeId from @CommodityAttribute) and  strPricingType='UnPriced'  and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblSaleUnpriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Purchase'  and intCommodityAttributeId  in(SELECT intCommodityAttributeId from @CommodityAttribute) and  strPricingType='Priced'  and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblPurchasePriced,
					 isnull((SELECT SUM(dblQuantity) FROM #ContractTransaction ct WHERE ct.strFutMarketName=ft.strFutMarketName and ct.strFutureMonth=t.strFutureMonth and TranType='Sale' and intCommodityAttributeId  in(SELECT intCommodityAttributeId from @CommodityAttribute) and  strPricingType='Priced'  and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0) dblSalePriced,
					 isnull((select sum(dblBuy-dblSell) dblNoOfcontract from vyuRKGetBuySellTransaction ct where ct.intFutureMarketId=t.intFutureMarketId and ct.strFutureMonth=t.strFutureMonth   and dtmFutureMonthsDate >= @dtmFutureMonthsDate),0)*ft.dblContractSize dblBuySell 
					 FROM #ContractTransaction t  
					 JOIN vyuRKGetBuySellTransaction ft ON ft.intFutureMarketId=t.intFutureMarketId and t.dtmFutureMonthsDate >= @dtmFutureMonthsDate 					
					 WHERE ft.intFutureMarketId =@intCMarketId and 
					 intCommodityAttributeId in (SELECT intCommodityAttributeId from @CommodityAttribute)
					 GROUP BY ft.strFutMarketName,t.strFutureMonth,t.intFutureMarketId,ft.dblContractSize,t.intFutureMarketId,t.intFutureMonthId
 
					 UNION

					 SELECT t.strFutMarketName,'Previous' strFutureMonth, t.intFutureMarketId,t.intFutureMonthId,
					 0.0 dblPurchase,
					 0.0 dblSale,
					 0.0 dblPurchaseUnpriced,
					 0.0 dblSaleUnpriced,
					 0.0 dblPurchasePriced,
					 0.0 dblSalePriced,
					 isnull((select sum(dblBuy-dblSell) dblNoOfcontract from vyuRKGetBuySellTransaction ct where ct.intFutureMarketId=t.intFutureMarketId and ct.strFutureMonth=t.strFutureMonth and ct.dtmFutureMonthsDate < @dtmFutureMonthsDate),0)*t.dblContractSize dblBuySell 
					 FROM vyuRKGetBuySellTransaction t 
					  WHERE t.intFutureMarketId =@intCMarketId
							anD t.intLocationId in (select intCompanyLocationId from @Location)
							AND strFutureMonth NOT IN(SELECT strFutureMonth FROM #ContractTransaction ct 
																				WHERE ct.intFutureMarketId=t.intFutureMarketId and ct.strFutureMonth=t.strFutureMonth)
							and t.intBrokerageAccountId in(SELECT intBrokerageAccountId from @BrokerageAttributeFinal									
															WHERE strCommodityAttributeId in(SELECT intCommodityAttributeId from @CommodityAttribute))
						and  t.dtmFutureMonthsDate < @dtmFutureMonthsDate									
					 GROUP BY t.strFutMarketName,t.strFutureMonth,t.intFutureMarketId,t.dblContractSize,t.intFutureMarketId,t.intFutureMonthId

					 UNION

					 SELECT t.strFutMarketName,t.strFutureMonth, t.intFutureMarketId,t.intFutureMonthId,
						 0.0 dblPurchase,
						 0.0 dblSale,
						 0.0 dblPurchaseUnpriced,
						 0.0 dblSaleUnpriced,
						 0.0 dblPurchasePriced,
						 0.0 dblSalePriced,
					 isnull((select sum(dblBuy-dblSell) dblNoOfcontract from vyuRKGetBuySellTransaction ct where ct.intFutureMarketId=t.intFutureMarketId and ct.strFutureMonth=t.strFutureMonth and ct.dtmFutureMonthsDate >= @dtmFutureMonthsDate),0)*t.dblContractSize dblBuySell 
					 FROM vyuRKGetBuySellTransaction t 
					  WHERE t.intFutureMarketId = @intCMarketId
							AND t.intLocationId in (select intCompanyLocationId from @Location)
							AND strFutureMonth NOT IN(SELECT strFutureMonth FROM #ContractTransaction ct 
																				WHERE ct.intFutureMarketId=t.intFutureMarketId and ct.strFutureMonth=t.strFutureMonth)
							AND t.intBrokerageAccountId in(SELECT intBrokerageAccountId from @BrokerageAttributeFinal									
															WHERE strCommodityAttributeId in(SELECT intCommodityAttributeId from @CommodityAttribute) )
						AND  t.dtmFutureMonthsDate >= @dtmFutureMonthsDate									
					 GROUP BY t.strFutMarketName,t.strFutureMonth,t.intFutureMarketId,t.dblContractSize,t.intFutureMarketId,t.intFutureMonthId)t
					 ORDER BY strFutMarketName, CASE WHEN  strFutureMonth ='Previous' THEN '01/01/1900' 
					  WHEN  strFutureMonth ='Total' THEN '01/01/9999'
					 ELSE CONVERT(DATETIME,'01 '+strFutureMonth) END ASC
			
				INSERT INTO @FinalResult (strFutMarketName,dblTotalPurchase,dblTotalSales ,dblUnfixedPurchase, dblUnfixedSales, dblFutures,dblTotal,strColor,intMarketSumDummyId)
					SELECT 'Total -' +@strFutMarket,sum(dblTotalPurchase),sum(dblTotalSales) ,sum(dblUnfixedPurchase), sum(dblUnfixedSales), sum(dblFutures),sum(dblTotal),'Total',-2 
					FROM @FinalResult 			
					WHERE  intFutureMarketId=@intCMarketId and intMarketSumDummyId =-1
		SELECT @intFMarketId= min(intMarketId) FROM @Market WHERE intMarketId > @intFMarketId
	END	


----------------------- END

INSERT INTO @FinalResult (strProductTypeH,dblTotalPurchase,dblTotalSales ,dblUnfixedPurchase, dblUnfixedSales, dblFutures,dblTotal,strColor)
SELECT 'Total - Over All',sum(dblTotalPurchase),sum(dblTotalSales) ,sum(dblUnfixedPurchase), sum(dblUnfixedSales), sum(dblFutures),sum(dblTotal),'Total - Over All' 
FROM @FinalResult 			
WHERE   intMarketSumDummyId =-2


SELECT intRowNum,strProductTypeH strProductType,strFutMarketName,strFutureMonth,round(dblTotalPurchase,@intDecimals) as dblTotalPurchase,
		round(dblTotalSales,@intDecimals) dblTotalSales ,round(dblUnfixedPurchase,@intDecimals) dblUnfixedPurchase, round(dblUnfixedSales,@intDecimals) dblUnfixedSales, 
		round(dblFutures,@intDecimals) dblFutures,round(dblTotal,@intDecimals) dblTotal, intFutureMarketId,intFutureMonthId,intCAttributeId intCommodityAttributeId,strColor,intMarketSumDummyId  FROM @FinalResult order by intRowNum
