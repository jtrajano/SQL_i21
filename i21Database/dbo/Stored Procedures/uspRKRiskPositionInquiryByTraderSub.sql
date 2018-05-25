CREATE PROC [dbo].[uspRKRiskPositionInquiryByTraderSub]  
        @intCommodityId INTEGER,  
        @intCompanyLocationId INTEGER,  
        @intFutureMarketId INTEGER,  
        @intFutureMonthId INTEGER,  
        @intUOMId INTEGER,  
        @intDecimal INTEGER,
		@intBookId int = NULL, 
		@intSubBookId int = NULL,
		@strPositionBy nvarchar(100) = NULL,
		@intCompanyId int
AS  
DECLARE @strUnitMeasure NVARCHAR(max)
DECLARE @dtmFutureMonthsDate DATETIME
DECLARE @dblContractSize INT
DECLARE @ysnIncludeInventoryHedge BIT
DECLARE @strRiskView NVARCHAR(max)
DECLARE @strFutureMonth NVARCHAR(max)
DECLARE @strParamFutureMonth NVARCHAR(max)
DECLARE @strMarketSymbol NVARCHAR(max)

SELECT @dblContractSize = convert(INT, dblContractSize) FROM tblRKFutureMarket WHERE intFutureMarketId = @intFutureMarketId

SELECT TOP 1 @dtmFutureMonthsDate = dtmFutureMonthsDate,@strParamFutureMonth = strFutureMonth,@strMarketSymbol=strSymbol FROM tblRKFuturesMonth 
WHERE intFutureMonthId = @intFutureMonthId

SELECT TOP 1 @strUnitMeasure = strUnitMeasure
FROM tblICUnitMeasure
WHERE intUnitMeasureId = @intUOMId

SELECT @intUOMId = intCommodityUnitMeasureId
FROM tblICCommodityUnitMeasure
WHERE intCommodityId = @intCommodityId AND intUnitMeasureId = @intUOMId

SELECT @ysnIncludeInventoryHedge = ysnIncludeInventoryHedge
FROM tblRKCompanyPreference

SELECT @strRiskView = strRiskView
FROM tblRKCompanyPreference


--    Invoice End
DECLARE @List AS TABLE (
	intRowNumber INT identity(1, 1)		
	,strFutureMonth NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,strAccountNumber NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,dblNoOfContract DECIMAL(24, 10)
	,strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,TransactionDate DATETIME
	,strTranType NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,CustVendor NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,dblNoOfLot DECIMAL(24, 10)
	,dblQuantity DECIMAL(24, 10)
	,intContractHeaderId INT
	,intFutOptTransactionHeaderId INT
	,strFutMarketName nvarchar(100) COLLATE Latin1_General_CI_AS
	,strBook nvarchar(100) COLLATE Latin1_General_CI_AS
	,strProductType nvarchar(100) COLLATE Latin1_General_CI_AS
	,strProductLine nvarchar(100) COLLATE Latin1_General_CI_AS
	,strPricingType nvarchar(100) COLLATE Latin1_General_CI_AS
	,strType nvarchar(100) COLLATE Latin1_General_CI_AS
	,strPhysicalOrFuture nvarchar(100) COLLATE Latin1_General_CI_AS
	,strContractType NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,TranType NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,strItemOrigin NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,strLocationName NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,strItemDescription NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,intMultiCompanyId int
	,strCompanyName  NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,strShipmentPeriod  NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,intGroupId int
	,dblDeltaPercent DECIMAL(24, 10)
	)
DECLARE @PricedContractList AS TABLE (
	strFutureMonth NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,TransactionDate datetime
	,strAccountNumber NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,dblNoOfContract DECIMAL(24, 10)
	,strTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,strTranType NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,CustVendor NVARCHAR(max) COLLATE Latin1_General_CI_AS
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
	,strSymbol nvarchar(100) COLLATE Latin1_General_CI_AS
	,dblNoOfLot DECIMAL(24, 10)
	,strFutMarketName nvarchar(100) COLLATE Latin1_General_CI_AS
	,strBook nvarchar(100) COLLATE Latin1_General_CI_AS
	,strProductType nvarchar(100) COLLATE Latin1_General_CI_AS
	,strProductLine nvarchar(100) COLLATE Latin1_General_CI_AS
	,strPricingType nvarchar(100) COLLATE Latin1_General_CI_AS
	,strType nvarchar(100) COLLATE Latin1_General_CI_AS
	,TranType NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,strItemOrigin NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,strLocationName NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,strItemDescription NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,intMultiCompanyId int
	,strCompanyName  NVARCHAR(max) COLLATE Latin1_General_CI_AS
	,strShipmentPeriod  NVARCHAR(max) COLLATE Latin1_General_CI_AS
	)

INSERT INTO @PricedContractList
SELECT strFutureMonth
	,dtmContractDate TransactionDate
	,strContractType + ' - ' + case when @strPositionBy= 'Product Type' 
				then isnull(ca.strDescription, '') else isnull(cv.strEntityName, '') end AS strAccountNumber
	,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, @intUOMId, isnull(dblBalance, 0))  AS dblNoOfContract
	,LEFT(strContractType, 1) + ' - ' + strContractNumber  AS strTradeNo
	,strContractType AS strTranType
	,strEntityName AS CustVendor
	,dbo.fnCTConvertQtyToTargetCommodityUOM(cv.intCommodityId,cv.intUnitMeasureId,@intUOMId, (dblBalance)) dblQuantity
	--,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId, @intUOMId, isnull(dblBalance, 0) ) AS dblQuantity
	,cv.intContractHeaderId
	,NULL AS intFutOptTransactionHeaderId
	,intPricingTypeId
	,cv.strContractType
	,cv.intCommodityId
	,cv.intCompanyLocationId
	,cv.intFutureMarketId
	,dtmFutureMonthsDate,ysnExpired
	,isnull(pl.ysnDeltaHedge, 0) ysnDeltaHedge
	,intContractStatusId
	,dblDeltaPercent,cv.intContractDetailId,um.intCommodityUnitMeasureId
	,dbo.fnCTConvertQuantityToTargetCommodityUOM(um2.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,cv.dblContractSize) dblRatioContractSize,
	strSymbol,cv.dblNoOfLots
	,strFutMarketName
	,strBook
	,strProductType 
	,strProductLine 
	,strPricingType 
	,case when cv.strType=' Basis' then 'Unpriced' else 'Priced' end strType
	,strContractType+'(C)' TranType
	,strItemOrigin,strLocationName,strItemDescription,intMultiCompanyId,strCompanyName,strShipmentPeriod
FROM vyuRKPositionReportContractDetail cv
JOIN tblICCommodityUnitMeasure um2 ON um2.intUnitMeasureId = cv.intFutMarketUOM and um2.intCommodityId = cv.intCommodityId
JOIN tblICItemUOM u ON cv.intItemUOMId = u.intItemUOMId
JOIN tblICItem ic ON ic.intItemId = cv.intItemId
LEFT JOIN tblICCommodityProductLine pl ON ic.intCommodityId = pl.intCommodityId AND ic.intProductLineId = pl.intCommodityProductLineId
LEFT JOIN tblICCommodityAttribute ca ON ca.intCommodityAttributeId = ic.intProductTypeId
LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = cv.intCommodityId AND um.intUnitMeasureId = cv.intUnitMeasureId
WHERE cv.intCommodityId = @intCommodityId AND cv.intFutureMarketId = @intFutureMarketId AND cv.intContractStatusId NOT IN (2, 3) 
AND isnull(intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(intBookId,0) else @intBookId end
AND isnull(cv.intMultiCompanyId,0)= case when isnull(@intCompanyId,0)=0 then isnull(intMultiCompanyId,0) else @intCompanyId end
-- inventory and FG		
SELECT strFutMarketName
		,strBook
		,strProductType 
		,strProductLine 
		,strPricingType 
		,strTranType
		,case when intPricingTypeId= 1 then right(strFutureMonth,2)+strSymbol else right(strFutureMonth,2)+strSymbol+' (UP)'  end strFutureMonth
		, dblNoOfContract
		, dblNoOfLot
		,dblQuantity
		,'Physical' strPhysicalOrFuture,strContractType,dtmFutureMonthsDate,@strMarketSymbol strMarketSymbol, strTradeNo 
		,intContractHeaderId,TransactionDate,TranType,CustVendor,ysnDeltaHedge,strItemOrigin,strLocationName,strItemDescription,dblDeltaPercent,intMultiCompanyId,
		strCompanyName, strShipmentPeriod
		INTO #tempContractAfterRecInventory		
	FROM (			
			SELECT DISTINCT 
				 strFutMarketName
				,strBook
				,pty.strDescription strProductType 
				,ptl.strDescription strProductLine 
				,strPricingType 
				,case when isnull(cd.intPricingTypeId,0)=1 then 'Priced' else 'Unpriced' end strTranType 
				,strFutureMonth
				,((ROUND(oc.dblQty, @intDecimal)) * case when isnull(dblYield,0)=0 then 1 else dblYield end)/100 AS dblNoOfContract
				,((oc.dblQty/dblContractSize) * case when isnull(dblYield,0)=0 then 1 else dblYield end)/100   dblNoOfLot
				,dbo.fnCTConvertQtyToTargetCommodityUOM(ch.intCommodityId,cd.intUnitMeasureId,@intUOMId, (oc.dblQty)) AS dblQuantity
				,@strMarketSymbol strSymbol, strContractType,strItemNo,
				cd.intPricingTypeId,dtmFutureMonthsDate,LEFT(strContractType, 1) + ' - ' + strContractNumber  strTradeNo
				,cd.intContractHeaderId, dtmContractDate TransactionDate, strContractType+'(I)' TranType,strEntityName CustVendor
				,isnull(ysnDeltaHedge,0) ysnDeltaHedge,CA.strDescription AS	strItemOrigin,strLocationName,IM.strDescription strItemDescription
				,(select top 1 strPropertyValue from(
					SELECT intSampleId,sum(convert(numeric(24,10),isnull(strPropertyValue,0))) strPropertyValue
					FROM tblQMTestResult TR
					JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
					 AND P.intDataTypeId IN (1,2) AND TR.intProductTypeId = 6 -- Lot Identifier
					 AND TR.intProductValueId = oc.intLotId -- Lot Id
					 AND TR.intPropertyItemId IS NOT NULL -- Inventory Item Id
					 WHERE isnull(strPropertyValue,'') <> ''
					 group by TR.intSampleId)t
					ORDER BY intSampleId DESC) dblYield,dblDeltaPercent,intMultiCompanyId, strCompanyName
					,CONVERT(VARCHAR(11), cd.dtmStartDate, 106) +'-'+CONVERT(VARCHAR(11), cd.dtmEndDate, 106) strShipmentPeriod
					,dbo.fnCTConvertQuantityToTargetCommodityUOM(um2.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,fm.dblContractSize) dblContractSize
			FROM tblICLot oc 
			JOIN tblICInventoryReceiptItemLot il on il.intLotId=oc.intLotId
			join tblICInventoryReceiptItem ri on il.intInventoryReceiptItemId= ri.intInventoryReceiptItemId
			join tblCTContractDetail cd on cd.intContractDetailId=ri.intLineNo
			JOIN tblSMCompanyLocation cl on cl.intCompanyLocationId		=	cd.intCompanyLocationId
			JOIN tblCTContractHeader ch on ch.intContractHeaderId=cd.intContractHeaderId AND cd.intContractStatusId  not in(2,3,6)
			JOIN	vyuCTEntity							EY	ON	EY.intEntityId						=		ch.intEntityId			AND														
													1 = (
														CASE 
															WHEN ch.intContractTypeId = 1 AND EY.strEntityType = 'Vendor' THEN 1 
															WHEN ch.intContractTypeId <> 1 AND EY.strEntityType = 'Customer' THEN 1 
															ELSE 0
														END
													) 
			JOIN	tblICItem			 IM	ON	IM.intItemId				=	cd.intItemId
			JOIN tblICCommodity c on ch.intCommodityId=c.intCommodityId and cd.intPricingTypeId IN (1,2)
			JOIN tblCTPricingType pt on pt.intPricingTypeId=cd.intPricingTypeId
			JOIN tblCTContractType ct on ct.intContractTypeId=ch.intContractTypeId
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=ch.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			JOIN tblRKFutureMarket fm on fm.intFutureMarketId=cd.intFutureMarketId
			join tblRKFuturesMonth mo on mo.intFutureMonthId=cd.intFutureMonthId
			LEFt JOIN tblCTBook b on b.intBookId=case when isnull(cd.intBookId,0)=0 then (SELECT DISTINCT top 1 b.intBookId from tblCTBookVsEntity e
																	join tblCTContractHeader ch on ch.intEntityId=e.intEntityId
																	join tblCTBook b on b.intBookId=ch.intBookId) else cd.intBookId end	
			LEFT JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = c.intCommodityId AND um.intUnitMeasureId = cd.intUnitMeasureId
			JOIN tblICCommodityUnitMeasure um2 ON um2.intUnitMeasureId = fm.intUnitMeasureId and um2.intCommodityId = c.intCommodityId
			LEFT JOIN tblSMMultiCompany comp on comp.intMultiCompanyId=oc.intCompanyId
			LEFT JOIN tblICCommodityAttribute			CA	ON	CA.intCommodityAttributeId	=	IM.intOriginId				
			LEFT JOIN tblICCommodityAttribute pty on IM.intProductTypeId=pty.intCommodityAttributeId and pty.strType='ProductType'
			LEFT JOIN tblICCommodityProductLine ptl on IM.intProductLineId=ptl.intCommodityProductLineId 
			WHERE c.intCommodityId = @intCommodityId AND intLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intLocationId ELSE @intCompanyLocationId END 
			AND intLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intLocationId ELSE @intCompanyLocationId END 
			AND cd.intFutureMarketId = @intFutureMarketId  
			AND isnull(cd.intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(cd.intBookId,0) else @intBookId end
			AND isnull(oc.intCompanyId,0)= case when isnull(@intCompanyId,0)=0 then isnull(oc.intCompanyId,0) else @intCompanyId end

			UNION

			SELECT DISTINCT 
				 strFutMarketName
				,strBook strBook
				,pty.strDescription strProductType 
				,ptl.strDescription strProductLine 
				,'Priced' strPricingType 
				,'Priced' strTranType 
				,@strParamFutureMonth strFutureMonth
				,dbo.fnCTConvertQtyToTargetCommodityUOM(MM.intCommodityId,u.intUnitMeasureId,um.intUnitMeasureId, Lot.dblQty)/Market.dblContractSize  AS dblNoOfContract
				,dbo.fnCTConvertQtyToTargetCommodityUOM(MM.intCommodityId,u.intUnitMeasureId,um.intUnitMeasureId, Lot.dblQty)/Market.dblContractSize as  dblNoOfLot
				,dbo.fnCTConvertQtyToTargetCommodityUOM(MM.intCommodityId,u.intUnitMeasureId,um.intUnitMeasureId, Lot.dblQty) AS dblQuantity
				,@strMarketSymbol strSymbol,'Inventory (FG)' strContractType,strItemNo,
				1 intPricingTypeId,@dtmFutureMonthsDate dtmFutureMonthsDate,strItemNo  strTradeNo
				,null intContractHeaderId,@dtmFutureMonthsDate TransactionDate, 'FG (I)' TranType,null CustVendor
				,isnull(ysnDeltaHedge,0) ysnDeltaHedge,CA.strDescription AS	strItemOrigin,null strLocationName,Item.strDescription strItemDescription
				,100 dblYield,dblDeltaPercent,Lot.intCompanyId intMultiCompanyId, strCompanyName
					,'' strShipmentPeriod
					,dbo.fnCTConvertQtyToTargetCommodityUOM(MM.intCommodityId,um.intUnitMeasureId,@intUOMId, Market.dblContractSize)dblContractSize
			 FROM tblICLot Lot
			join tblICItemUOM u on u.intItemUOMId=Lot.intItemUOMId
			JOIN tblICItem Item ON Item.intItemId = Lot.intItemId			
			JOIN tblRKCommodityMarketMapping MM ON MM.strCommodityAttributeId = Item.intProductTypeId
			JOIN tblRKFutureMarket Market ON Market.intFutureMarketId = MM.intFutureMarketId
			JOIN tblICCommodityUnitMeasure um ON um.intCommodityId = MM.intCommodityId AND um.intUnitMeasureId = Market.intUnitMeasureId			
			JOIN tblSMMultiCompany comp on comp.intMultiCompanyId=Lot.intCompanyId
			LEFT join tblCTBookVsEntity be on comp.intMultiCompanyId=be.intMultiCompanyId
			LEFt JOIN tblCTBook b on b.intBookId=case when isnull(be.intBookId,0)=0 then (SELECT DISTINCT top 1 b.intBookId from tblCTBookVsEntity e
																	join tblCTContractHeader ch on ch.intEntityId=e.intEntityId
																	join tblCTBook b on b.intBookId=ch.intBookId) else be.intBookId end	
				JOIN tblICCommodityAttribute CA	ON	CA.intCommodityAttributeId	=	MM.strCommodityAttributeId			
				JOIN tblICCommodityAttribute pty on Item.intProductTypeId=pty.intCommodityAttributeId and pty.strType='ProductType'
				JOIN tblICCommodityProductLine ptl on Item.intProductLineId=ptl.intCommodityProductLineId 
			WHERE ysnProduced = 1 and MM.intCommodityId = @intCommodityId 			
			AND intLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intLocationId ELSE @intCompanyLocationId END 
			AND Market.intFutureMarketId = @intFutureMarketId  			
			AND isnull(Lot.intCompanyId,0)= case when isnull(@intCompanyId,0)=0 then isnull(Lot.intCompanyId,0) else @intCompanyId end
			)t where dblQuantity <>0

SELECT strFutMarketName
		,strBook
		,strProductType 
		,strProductLine 
		,strPricingType 
		,strTranType
		,right(strFutureMonth,2)+strSymbol strFutureMonth
		,ROUND(dblNoOfContract, @intDecimal) AS dblNoOfContract
		,dblNoOfLot
		,dblQuantity
		,'Futures' strPhysicalOrFuture,strContractType ,dtmFutureMonthsDate,@strMarketSymbol strMarketSymbol,strTradeNo,
		intFutOptTransactionHeaderId,TransactionDate,TranType,CustVendor,strLocationName,intMultiCompanyId,strCompanyName,isnull(ysnDeltaHedge,0) ysnDeltaHedge 
INTO #tempFutureRec
	FROM (			
			SELECT DISTINCT 
				 strFutMarketName
				,strBook
				,ca.strDescription strProductType 
				,bac.strAccountNumber strProductLine 
				,'' strPricingType 
				,ca.strType strTranType
				,strFutureMonth
				,oc.intOpenContract AS dblNoOfContract
				,oc.intOpenContract   dblNoOfLot
				,oc.intOpenContract * @dblContractSize AS dblQuantity
				,strSymbol,strBuySell strContractType,dtmFutureMonthsDate,strInternalTradeNo strTradeNo,ft.intFutOptTransactionHeaderId,
				fh.dtmTransactionDate TransactionDate, strBuySell+'(F)' TranType,strName CustVendor,strLocationName,fh.intCompanyId intMultiCompanyId,strCompanyName
				,isnull(ysnDeltaHedge,0) ysnDeltaHedge
			FROM vyuRKGetOpenContract oc 
			JOIN tblRKFutOptTransaction ft on oc.intFutOptTransactionId=ft.intFutOptTransactionId AND ft.intInstrumentTypeId = 1
			join tblRKFutOptTransactionHeader fh on fh.intFutOptTransactionHeaderId=ft.intFutOptTransactionHeaderId
			join tblRKBrokerageAccount bac on bac.intBrokerageAccountId=ft.intBrokerageAccountId
			join tblEMEntity e on e.intEntityId=ft.intEntityId
			JOIN tblRKFutureMarket ba ON ft.intFutureMarketId = ba.intFutureMarketId			
			JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
			JOIN tblRKCommodityMarketMapping mm on mm.intFutureMarketId=ft.intFutureMarketId and mm.intCommodityId=ft.intCommodityId
			join tblSMCompanyLocation l on l.intCompanyLocationId=ft.intLocationId
			LEFT JOIN tblSMMultiCompany comp on comp.intMultiCompanyId=fh.intCompanyId
			LEFT join tblICCommodityAttribute ca on ca.intCommodityAttributeId=mm.strCommodityAttributeId 
			LEFT JOIN tblCTBook b on b.intBookId=case when isnull(ft.intBookId,0)=0 then (SELECT DISTINCT top 1 b.intBookId from tblCTBookVsEntity e
																	JOIN tblCTBookVsEntity be on comp.intMultiCompanyId=be.intMultiCompanyId
																	join tblCTBook b on b.intBookId=be.intBookId) else ft.intBookId end	
			WHERE ft.intCommodityId = @intCommodityId AND intLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intLocationId ELSE @intCompanyLocationId END 
			AND intLocationId = CASE WHEN isnull(@intCompanyLocationId, 0) = 0 THEN intLocationId ELSE @intCompanyLocationId END 
			AND ft.intFutureMarketId = @intFutureMarketId 
			AND isnull(ft.intBookId,0)= case when isnull(@intBookId,0)=0 then isnull(ft.intBookId,0) else @intBookId end
			AND isnull(fh.intCompanyId,0)= case when isnull(@intCompanyId,0)=0 then isnull(fh.intCompanyId,0) else @intCompanyId end
			) T1

BEGIN
--- Phycial contract lessthan the spot date
	INSERT INTO @List (
		 strFutMarketName,strBook,strProductType ,strProductLine ,strPricingType 
		,strTranType,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strPhysicalOrFuture,strContractType,strTradeNo,intContractHeaderId,
		TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod
		)
		SELECT strFutMarketName
		,strBook
		,strProductType 
		,strProductLine 
		,strPricingType 
		,strTranType
		,right(strFutureMonth,2)+strSymbol strFutureMonth
		,ROUND(dblNoOfContract, @intDecimal) AS dblNoOfContract
		,dblNoOfLot
		,dblQuantity
		,'Physical' strPhysicalOrFuture,strContractType,strTradeNo,intContractHeaderId,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName
		,strItemDescription,strCompanyName,strShipmentPeriod
	FROM (			
			SELECT DISTINCT strFutMarketName
				,strBook 
				,strProductType 
				,strProductLine 
				,strPricingType 
				,strType strTranType
				,@strParamFutureMonth strFutureMonth
				,CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (abs(dblNoOfContract)) END AS dblNoOfContract
				,CASE WHEN strContractType = 'Purchase' THEN dblNoOfLot ELSE - (abs(dblNoOfLot)) END dblNoOfLot
				,CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (abs(dblQuantity)) END AS dblQuantity
				,@strMarketSymbol strSymbol,strContractType,intPricingTypeId,strTradeNo,intContractHeaderId,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName
				,strItemDescription,strCompanyName,strShipmentPeriod,intContractDetailId
			FROM @PricedContractList
			WHERE  intCommodityId = @intCommodityId AND intCompanyLocationId = CASE WHEN ISNULL(@intCompanyLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intCompanyLocationId END 
			AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate < @dtmFutureMonthsDate --and isnull(ysnDeltaHedge,0) =0
		  ) T1
	UNION
	-- Physical contract graterthan or equal to spot date
	SELECT strFutMarketName
		,strBook
		,strProductType 
		,strProductLine 
		,strPricingType 
		,strTranType
		,right(strFutureMonth,2)+strSymbol strFutureMonth
		,ROUND(dblNoOfContract, @intDecimal) AS dblNoOfContract
		,dblNoOfLot
		,dblQuantity
		,'Physical' strPhysicalOrFuture,strContractType,strTradeNo,intContractHeaderId,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName
		,strItemDescription,strCompanyName,strShipmentPeriod
	FROM (			
			SELECT DISTINCT strFutMarketName
				,strBook
				,strProductType 
				,strProductLine 
				,strPricingType 
				,strType strTranType
				,strFutureMonth
				,CASE WHEN strContractType = 'Purchase' THEN dblNoOfContract ELSE - (abs(dblNoOfContract)) END AS dblNoOfContract
				,CASE WHEN strContractType = 'Purchase' THEN dblNoOfLot ELSE - (abs(dblNoOfLot)) END dblNoOfLot
				,CASE WHEN strContractType = 'Purchase' THEN dblQuantity ELSE - (abs(dblQuantity)) END AS dblQuantity
				,strSymbol,strContractType,intPricingTypeId,strTradeNo,intContractHeaderId,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName
				,strItemDescription,strCompanyName,strShipmentPeriod,intContractDetailId
			FROM @PricedContractList
			WHERE  intCommodityId = @intCommodityId AND intCompanyLocationId = CASE WHEN ISNULL(@intCompanyLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intCompanyLocationId END 
			AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate --and isnull(ysnDeltaHedge,0)=0
		  ) T1
-- Inventory lessthan spot date
INSERT INTO @List (
		 strFutMarketName,strBook,strProductType ,strProductLine ,strPricingType 
		,strTranType,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strPhysicalOrFuture,strContractType,strTradeNo,intContractHeaderId,
		TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod)	
SELECT DISTINCT strFutMarketName,strBook,strProductType ,strProductLine ,strPricingType ,strTranType, @strMarketSymbol+right(@strParamFutureMonth,2)+'P'
,dblNoOfContract	,dblNoOfLot	,dblQuantity,'Physical' strPhysicalOrFuture,strContractType,strTradeNo,intContractHeaderId,TransactionDate,TranType,CustVendor
,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod
FROM #tempContractAfterRecInventory where  dtmFutureMonthsDate < @dtmFutureMonthsDate and isnull(ysnDeltaHedge,0)=0  
-- inventory graterthan or equal to spot date
INSERT INTO @List (
		 strFutMarketName,strBook,strProductType ,strProductLine ,strPricingType 
		,strTranType,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strPhysicalOrFuture,strContractType,strTradeNo,intContractHeaderId,TransactionDate,
		TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod)	
SELECT DISTINCT strFutMarketName,strBook,strProductType ,strProductLine ,strPricingType ,strTranType,strFutureMonth
,dblNoOfContract AS dblNoOfContract	,dblNoOfLot	,dblQuantity,'Physical' strPhysicalOrFuture,strContractType,strTradeNo,intContractHeaderId,
TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod
FROM #tempContractAfterRecInventory where  dtmFutureMonthsDate >= @dtmFutureMonthsDate   and isnull(ysnDeltaHedge,0)=0

-- PTBF of Futures
INSERT INTO @List ( strFutMarketName,strBook,strProductType ,strProductLine ,strPricingType 
		,strTranType,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strPhysicalOrFuture,strContractType,strCompanyName)
		SELECT strFutMarketName
		,strBook 
		,strProductType 
		,CASE WHEN strContractType = 'Purchase' THEN 'PTBF Sell' ELSE 'PTBF Buy' END strProductLine  
		,strPricingType 
		,CASE WHEN strContractType = 'Purchase' THEN 'PTBF Sell' ELSE 'PTBF Buy' END strTranType
		, strFutureMonth
		,CASE WHEN strContractType = 'Purchase' THEN sum(-abs(dblNoOfContract)) ELSE sum(abs(dblNoOfContract))  END dblNoOfContract
		,CASE WHEN strContractType = 'Purchase' THEN sum(-abs(dblNoOfLot)) ELSE sum(abs(dblNoOfLot)) END dblNoOfLot
		,CASE WHEN strContractType = 'Purchase' THEN sum(-abs(dblQuantity)) ELSE sum(abs(dblQuantity)) END dblQuantity ,	
		'Futures' strPhysicalOrFuture,strContractType,strCompanyName  FROM @List WHERE strTranType = 'Unpriced'
GROUP BY strFutMarketName,strBook,strProductType ,strPricingType,strFutureMonth,strContractType,strCompanyName

END		

--Future Rec 
INSERT INTO @List (
		 strFutMarketName,strBook,strProductType ,strProductLine ,strPricingType ,strTranType,strFutureMonth,dblNoOfContract,
		 dblNoOfLot,dblQuantity,strPhysicalOrFuture,strContractType,strTradeNo,intFutOptTransactionHeaderId,intContractHeaderId,TransactionDate,TranType,
		 CustVendor,strLocationName,strCompanyName		 
		)
SELECT strFutMarketName,strBook,strProductType ,strProductLine ,strPricingType ,strTranType,@strMarketSymbol+right(@dtmFutureMonthsDate,2)+'P',
	dblNoOfContract,dblNoOfLot,dblQuantity,strPhysicalOrFuture,strContractType,strTradeNo,intFutOptTransactionHeaderId,null,TransactionDate,TranType,CustVendor
	,strLocationName,strCompanyName
FROM #tempFutureRec	WHERE isnull(ysnDeltaHedge,0) = 0 and dtmFutureMonthsDate < @dtmFutureMonthsDate    

INSERT INTO @List (
		 strFutMarketName,strBook,strProductType ,strProductLine ,strPricingType ,strTranType,strFutureMonth,dblNoOfContract,dblNoOfLot,
		 dblQuantity,strPhysicalOrFuture,strContractType,strTradeNo,intFutOptTransactionHeaderId,intContractHeaderId,TransactionDate,TranType,
		 CustVendor,strLocationName,strCompanyName	
		)
SELECT strFutMarketName,strBook,strProductType ,strProductLine ,strPricingType,strTranType,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,
strPhysicalOrFuture,strContractType,strTradeNo,intFutOptTransactionHeaderId,null intContractHeaderId,TransactionDate,TranType,CustVendor,strLocationName,strCompanyName		
FROM #tempFutureRec	WHERE isnull(ysnDeltaHedge,0) = 0 and dtmFutureMonthsDate >= @dtmFutureMonthsDate 	

INSERT INTO @List (
	strFutMarketName,strBook,strProductType ,strProductLine ,strPricingType 
,strTranType,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strPhysicalOrFuture,strContractType
,strTradeNo,intFutOptTransactionHeaderId,intContractHeaderId,TransactionDate,TranType,CustVendor,strLocationName,strCompanyName	,strShipmentPeriod
)
select strFutMarketName,strBook ,strProductType ,strProductLine ,strPricingType 
,strTranType,'Total' strFutureMonth,sum(dblNoOfContract),sum(dblNoOfLot),sum(dblQuantity),strPhysicalOrFuture,strContractType
,strTradeNo,intFutOptTransactionHeaderId,intContractHeaderId,TransactionDate,TranType,CustVendor,strLocationName,strCompanyName,strShipmentPeriod	
 FROM @List WHERE strTranType in('Priced','Unpriced')
GROUP BY strFutMarketName,strBook ,strProductType ,strProductLine ,strPricingType ,strTranType,strFutureMonth,strPhysicalOrFuture,strContractType
,strTradeNo,intFutOptTransactionHeaderId,intContractHeaderId,TransactionDate,TranType,CustVendor,strLocationName,strCompanyName	,strShipmentPeriod


INSERT INTO @List (
	strFutMarketName,strBook ,strProductType ,strProductLine ,strPricingType 
,strTranType,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strPhysicalOrFuture,strContractType
,strTradeNo,intFutOptTransactionHeaderId,intContractHeaderId,TransactionDate,TranType,CustVendor,strLocationName,strCompanyName	,strShipmentPeriod		
)
select strFutMarketName,strBook ,strProductType ,strProductLine ,strPricingType 
,strTranType,'Total' strFutureMonth,sum(dblNoOfContract),sum(dblNoOfLot),sum(dblQuantity),strPhysicalOrFuture,strContractType
,strTradeNo,intFutOptTransactionHeaderId,intContractHeaderId,TransactionDate,TranType,CustVendor,strLocationName,strCompanyName,strShipmentPeriod
 FROM @List where strPhysicalOrFuture='Futures' --strTranType in('PTBF Sell','PTBF Buy')
GROUP BY strFutMarketName,strBook ,strProductType ,strProductLine ,strPricingType ,strTranType,strFutureMonth,strPhysicalOrFuture,strContractType
,strTradeNo,intFutOptTransactionHeaderId,intContractHeaderId,TransactionDate,TranType,CustVendor,strLocationName,strCompanyName	,strShipmentPeriod

----------------------- delta % 
	INSERT INTO @List (
		 strFutMarketName,strBook ,strProductType ,strProductLine ,strFutureMonth ,dblNoOfLot	,strPhysicalOrFuture,strCompanyName
		)
	select strFutMarketName,strBook ,strProductType ,strProductLine ,strFutureMonth ,dblNoOfLot	,strPhysicalOrFuture,strCompanyName from(
			SELECT DISTINCT strFutMarketName
				,strBook 
				,strProductType 
				,strProductLine 
				,'Delta Ratio' strFutureMonth 
				,dblDeltaPercent  dblNoOfLot
				,'Physical' strPhysicalOrFuture
				,strCompanyName
			FROM @PricedContractList
			WHERE  intCommodityId = @intCommodityId AND intCompanyLocationId = CASE WHEN ISNULL(@intCompanyLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intCompanyLocationId END 
			AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate < @dtmFutureMonthsDate and ysnDeltaHedge =1
	UNION
	-- Physical contract graterthan or equal to spot date
			SELECT  DISTINCT strFutMarketName
				,strBook 
				,strProductType 
				,strProductLine 
				,'Delta Ratio' strFutureMonth 
				,dblDeltaPercent  dblNoOfLot
				,'Physical' strPhysicalOrFuture
				,strCompanyName
			FROM @PricedContractList
			WHERE  intCommodityId = @intCommodityId AND intCompanyLocationId = CASE WHEN ISNULL(@intCompanyLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intCompanyLocationId END 
			AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate and ysnDeltaHedge=1)t
	GROUP BY strFutMarketName,strBook ,strProductType ,strProductLine ,strFutureMonth ,dblNoOfLot,strPhysicalOrFuture,strCompanyName

---- inventory
INSERT INTO @List (
	strFutMarketName,strBook ,strProductType ,strProductLine ,strFutureMonth ,dblNoOfLot	,strPhysicalOrFuture,strCompanyName)
	select strFutMarketName,strBook ,strProductType ,strProductLine ,strFutureMonth ,dblNoOfLot	,strPhysicalOrFuture,strCompanyName from(
			SELECT DISTINCT strFutMarketName
				,strBook 
				,strProductType 
				,strProductLine 
				,'Delta Ratio' strFutureMonth 
				,dblDeltaPercent  dblNoOfLot
				,'Physical' strPhysicalOrFuture
				,strCompanyName
			FROM #tempContractAfterRecInventory
			WHERE  dtmFutureMonthsDate < @dtmFutureMonthsDate and ysnDeltaHedge =1
	UNION
	-- Physical contract graterthan or equal to spot date
			SELECT  DISTINCT strFutMarketName
				,strBook 
				,strProductType 
				,strProductLine 
				,'Delta Ratio' strFutureMonth 
				,dblDeltaPercent  dblNoOfLot
				,'Physical' strPhysicalOrFuture
				,strCompanyName
			FROM #tempContractAfterRecInventory
			WHERE  dtmFutureMonthsDate >= @dtmFutureMonthsDate and ysnDeltaHedge=1)t
	GROUP BY strFutMarketName,strBook ,strProductType ,strProductLine ,strFutureMonth ,dblNoOfLot,strPhysicalOrFuture,strCompanyName

---- Future 
--INSERT INTO @List (
--	strFutMarketName,strBook ,strProductType ,strProductLine ,strFutureMonth ,dblNoOfLot	,strPhysicalOrFuture,strCompanyName)
--	select strFutMarketName,strBook ,strProductType ,strProductLine ,strFutureMonth ,dblNoOfLot	,strPhysicalOrFuture,strCompanyName from(
--			SELECT DISTINCT strFutMarketName
--				,strBook 
--				,strProductType 
--				,strProductLine 
--				,'Delta Ratio' strFutureMonth 
--				,dblDeltaPercent  dblNoOfLot
--				,'Physical' strPhysicalOrFuture
--				,strCompanyName
--			FROM #tempFutureRec
--			WHERE  dtmFutureMonthsDate < @dtmFutureMonthsDate and ysnDeltaHedge =1
--	UNION
--	-- Physical contract graterthan or equal to spot date
--			SELECT  DISTINCT strFutMarketName
--				,strBook 
--				,strProductType 
--				,strProductLine 
--				,'Delta Ratio' strFutureMonth 
--				,dblDeltaPercent  dblNoOfLot
--				,'Physical' strPhysicalOrFuture
--				,strCompanyName
--			FROM #tempFutureRec
--			WHERE  dtmFutureMonthsDate >= @dtmFutureMonthsDate and ysnDeltaHedge=1)t
--	GROUP BY strFutMarketName,strBook ,strProductType ,strProductLine ,strFutureMonth ,dblNoOfLot,strPhysicalOrFuture,strCompanyName



	INSERT INTO @List (
		 strFutMarketName,strBook ,strProductType ,strProductLine ,strPricingType 
		,strTranType,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strPhysicalOrFuture,strContractType,strTradeNo,intContractHeaderId,
		TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod,intGroupId,dblDeltaPercent
		)
	
			SELECT DISTINCT strFutMarketName
				,strBook 
				,strProductType 
				,strProductLine 
				,strPricingType 
				,strType strTranType
				,right(strFutureMonth,2)+strSymbol strFutureMonth  
				,CASE WHEN strContractType = 'Purchase' THEN (dblNoOfContract) ELSE - ((abs(dblNoOfContract))) END AS dblNoOfContract
				,CASE WHEN strContractType = 'Purchase' THEN (dblNoOfLot) ELSE - ((abs(dblNoOfLot))) END dblNoOfLot
				,CASE WHEN strContractType = 'Purchase' THEN (dblQuantity)/100 ELSE - ((abs(dblQuantity))) END AS dblQuantity
				,'Physical' strPhysicalOrFuture,strContractType,strTradeNo,intContractHeaderId,TransactionDate,TranType,CustVendor,strItemOrigin,
				strLocationName
				,strItemDescription
				,strCompanyName,strShipmentPeriod,1 intGroupId,dblDeltaPercent
			FROM @PricedContractList
			WHERE  intCommodityId = @intCommodityId AND intCompanyLocationId = CASE WHEN ISNULL(@intCompanyLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intCompanyLocationId END 
			AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate < @dtmFutureMonthsDate and ysnDeltaHedge =1
	UNION
	-- Physical contract graterthan or equal to spot date

			SELECT DISTINCT strFutMarketName
				,strBook 
				,strProductType 
				,strProductLine 
				,strPricingType 
				,strType strTranType
				,right(strFutureMonth,2)+strSymbol strFutureMonth 
				,CASE WHEN strContractType = 'Purchase' THEN (dblNoOfContract) ELSE - ((abs(dblNoOfContract))) END AS dblNoOfContract
				,CASE WHEN strContractType = 'Purchase' THEN (dblNoOfLot) ELSE - ((abs(dblNoOfLot))) END dblNoOfLot
				,CASE WHEN strContractType = 'Purchase' THEN (dblQuantity)/100 ELSE - ((abs(dblQuantity))) END AS dblQuantity
				,'Physical' strPhysicalOrFuture,strContractType,strTradeNo,intContractHeaderId,TransactionDate,TranType,CustVendor,
				strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod,1 intGroupId,dblDeltaPercent
			FROM @PricedContractList
			WHERE  intCommodityId = @intCommodityId AND intCompanyLocationId = CASE WHEN ISNULL(@intCompanyLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intCompanyLocationId END 
			AND intFutureMarketId = @intFutureMarketId AND dtmFutureMonthsDate >= @dtmFutureMonthsDate and ysnDeltaHedge=1

INSERT INTO @List (
		 strFutMarketName,strBook ,strProductType ,strProductLine ,strPricingType 
		,strTranType,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strPhysicalOrFuture,strContractType,strTradeNo,intContractHeaderId,
		TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod,intGroupId,dblDeltaPercent
		)
	
			SELECT DISTINCT strFutMarketName
				,strBook 
				,strProductType 
				,strProductLine 
				,strPricingType 
				,strTranType
				,strFutureMonth  
				,CASE WHEN strContractType = 'Purchase' THEN (dblNoOfContract) ELSE - ((abs(dblNoOfContract))) END AS dblNoOfContract
				,CASE WHEN strContractType = 'Purchase' THEN (dblNoOfLot) ELSE - ((abs(dblNoOfLot))) END dblNoOfLot
				,CASE WHEN strContractType = 'Purchase' THEN (dblQuantity)/100 ELSE - ((abs(dblQuantity))) END AS dblQuantity
				,'Physical' strPhysicalOrFuture,strContractType,strTradeNo,intContractHeaderId,TransactionDate,TranType,CustVendor,strItemOrigin,
				strLocationName
				,strItemDescription
				,strCompanyName,strShipmentPeriod,1 intGroupId,dblDeltaPercent
			FROM #tempContractAfterRecInventory
			WHERE   dtmFutureMonthsDate < @dtmFutureMonthsDate and ysnDeltaHedge =1
	UNION
	-- Physical contract graterthan or equal to spot date

			SELECT DISTINCT strFutMarketName
				,strBook 
				,strProductType 
				,strProductLine 
				,strPricingType 
				,strTranType
				, strFutureMonth 
				, dblNoOfContract
				,dblNoOfLot
				,dblQuantity
				,'Physical' strPhysicalOrFuture,strContractType,strTradeNo,intContractHeaderId,TransactionDate,TranType,CustVendor,
				strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod,1 intGroupId,dblDeltaPercent
			FROM #tempContractAfterRecInventory
			WHERE  dtmFutureMonthsDate >= @dtmFutureMonthsDate and ysnDeltaHedge=1


	INSERT INTO @List (
		 strFutMarketName,strBook ,strProductType ,strProductLine ,strPricingType 
		,strTranType,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strPhysicalOrFuture,strContractType,strTradeNo,intContractHeaderId,
		TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod
		)
	SELECT DISTINCT strFutMarketName
				,strBook 
				,strProductType 
				,strProductLine 
				,strPricingType 
				,strTranType
				,'Delta Total' strFutureMonth 
				,(dblNoOfContract*dblDeltaPercent)/100 dblNoOfContract
				,(dblNoOfLot*dblDeltaPercent)/100  dblNoOfLot
				,(dblQuantity*dblDeltaPercent)/100  dblQuantity
				,strPhysicalOrFuture,strContractType,strTradeNo,intContractHeaderId,TransactionDate,TranType,CustVendor,
				strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod
			FROM @List
			WHERE  isnull(intGroupId,0)=1
-- Delta Total future


INSERT INTO @List (
		 strFutMarketName,strBook ,strProductType ,strProductLine ,strPricingType ,strTranType,strFutureMonth,dblNoOfContract,dblNoOfLot,
		 dblQuantity,strPhysicalOrFuture,strContractType,strTradeNo,intFutOptTransactionHeaderId,intContractHeaderId,TransactionDate,TranType,CustVendor,strLocationName
		 ,strCompanyName		 
		)

SELECT strFutMarketName,strBook ,strProductType ,strProductLine ,strPricingType,strTranType,'Delta Total' strFutureMonth ,dblNoOfContract,dblNoOfLot,dblQuantity,
strPhysicalOrFuture,strContractType,strTradeNo,intFutOptTransactionHeaderId,null,TransactionDate,TranType,CustVendor,strLocationName,strCompanyName
FROM @List where isnull(intGroupId,0) = 2

SELECT 	 intRowNumber,strFutMarketName,strBook ,strProductType ,strProductLine ,strContractType  
		,strTranType,strPhysicalOrFuture,strFutureMonth,dblNoOfContract,dblNoOfLot,dblQuantity,strTradeNo,intContractHeaderId,intFutOptTransactionHeaderId
		,TransactionDate,TranType,CustVendor,strItemOrigin,strLocationName,strItemDescription,strCompanyName,strShipmentPeriod
FROM @List order by intRowNumber