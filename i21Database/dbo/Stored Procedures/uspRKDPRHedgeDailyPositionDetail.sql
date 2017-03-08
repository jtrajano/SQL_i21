CREATE PROCEDURE [dbo].[uspRKDPRHedgeDailyPositionDetail] 
		 @intCommodityId nvarchar(max)
		,@intLocationId int = NULL
		,@intVendorId int = null
		,@strPurchaseSales nvarchar(50) = NULL
AS

IF isnull(@strPurchaseSales,'') <> ''
BEGIN
	if @strPurchaseSales='Purchase'
	BEGIN
		SELECT @strPurchaseSales='Sale'
	END
	ELSE
	BEGIN
		SELECT @strPurchaseSales='Purchase'
	END
END

DECLARE @Commodity AS TABLE 
(
intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
intCommodity  INT
)
INSERT INTO @Commodity(intCommodity)
SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  
	 
DECLARE @tempFinal AS TABLE (
		 intRow INT IDENTITY(1,1),
		 intContractHeaderId int,
		 strContractNumber NVARCHAR(200),
		 intFutOptTransactionHeaderId int,
		 strInternalTradeNo NVARCHAR(200),
		 strCommodityCode NVARCHAR(200),   
		 strType  NVARCHAR(50), 
		 strSubType  NVARCHAR(50), 
		 strContractType NVARCHAR(50),
		 strLocationName NVARCHAR(100),
		 strContractEndMonth NVARCHAR(50),
		 intInventoryReceiptItemId INT
		,strTicketNumber  NVARCHAR(50)
		,dtmTicketDateTime DATETIME
		,strCustomerReference NVARCHAR(100)
		,strDistributionOption NVARCHAR(50)
		,dblUnitCost NUMERIC(24, 10)
		,dblQtyReceived NUMERIC(24, 10)
		,dblTotal DECIMAL(24,10)
		,intSeqNo int
		,intFromCommodityUnitMeasureId int
		,intToCommodityUnitMeasureId int
		,intCommodityId int
		,strAccountNumber NVARCHAR(100)
		,strTranType NVARCHAR(20)
		,dblNoOfLot NUMERIC(24, 10)
		,dblDelta NUMERIC(24, 10)
		,intBrokerageAccountId int
		,strInstrumentType nvarchar(50)
		,invQty NUMERIC(24, 10),
		 PurBasisDelivary NUMERIC(24, 10),
		 OpenPurQty NUMERIC(24, 10),
		 OpenSalQty NUMERIC(24, 10), 
		 dblCollatralSales NUMERIC(24, 10), 
		 SlsBasisDeliveries NUMERIC(24, 10),
		 intNoOfContract NUMERIC(24, 10),
		 dblContractSize NUMERIC(24, 10),
		 CompanyTitled NUMERIC(24, 10)
)

DECLARE @Final AS TABLE (
		 intRow INT IDENTITY(1,1),
		 intContractHeaderId int,
		 strContractNumber NVARCHAR(200),
		 intFutOptTransactionHeaderId int,
		 strInternalTradeNo NVARCHAR(200),
		 strCommodityCode NVARCHAR(200),   
		 strType  NVARCHAR(50), 
		 strSubType NVARCHAR(50), 
		 strContractType NVARCHAR(50),
		 strLocationName NVARCHAR(100),
		 strContractEndMonth NVARCHAR(50),
		 intInventoryReceiptItemId INT
		,strTicketNumber  NVARCHAR(50)
		,dtmTicketDateTime DATETIME
		,strCustomerReference NVARCHAR(100)
		,strDistributionOption NVARCHAR(50)
		,dblUnitCost NUMERIC(24, 10)
		,dblQtyReceived NUMERIC(24, 10)
		,dblTotal DECIMAL(24,10)
		,strUnitMeasure NVARCHAR(50)
		,intSeqNo int
		,intFromCommodityUnitMeasureId int
		,intToCommodityUnitMeasureId int
		,intCommodityId int
		,strAccountNumber NVARCHAR(100)
		,strTranType NVARCHAR(20)
		,dblNoOfLot NUMERIC(24, 10)
		,dblDelta NUMERIC(24, 10)
		,intBrokerageAccountId int
		,strInstrumentType nvarchar(50)
		,invQty NUMERIC(24, 10),
		 PurBasisDelivary NUMERIC(24, 10),
		 OpenPurQty NUMERIC(24, 10),
		 OpenSalQty NUMERIC(24, 10), 
		 dblCollatralSales NUMERIC(24, 10), 
		 SlsBasisDeliveries NUMERIC(24, 10),
		 intNoOfContract NUMERIC(24, 10),
		 dblContractSize NUMERIC(24, 10),
		 CompanyTitled NUMERIC(24, 10)
)

DECLARE @mRowNumber INT
DECLARE @intCommodityId1 INT
DECLARE @strDescription NVARCHAR(50)
declare @intOneCommodityId int
declare @intCommodityUnitMeasureId int
DECLARE @intUnitMeasureId int
DECLARE @strUnitMeasure nvarchar(50)
SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity
WHILE @mRowNumber >0
BEGIN
	SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
	SELECT @strDescription = strCommodityCode FROM tblICCommodity	WHERE intCommodityId = @intCommodityId
	SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId AND ysnDefault=1
IF  @intCommodityId >0
BEGIN
if isnull(@intVendorId,0) = 0
BEGIN
	INSERT INTO @tempFinal (strCommodityCode,intContractHeaderId,strContractNumber,strType,strContractType,strLocationName,strContractEndMonth,dblTotal,intFromCommodityUnitMeasureId,intCommodityId)
	SELECT cd.strCommodityCode,cd.intContractHeaderId,strContractNumber	,cd.strContractType+ ' ' + cd.strPricingType [strType],'Physical',strLocationName,
		RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((cd.dblBalance),0)) AS dblTotal
	 ,cd.intUnitMeasureId,@intCommodityId 
	FROM vyuRKContractDetail cd
	WHERE cd.intContractTypeId in(1,2) AND cd.intPricingTypeId IN (1,2,3) and 
		cd.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
	AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end

	-- Hedge
	INSERT INTO @tempFinal (strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strContractType,strLocationName,strContractEndMonth,dblTotal,
							intFromCommodityUnitMeasureId,intCommodityId,strAccountNumber,strTranType,intBrokerageAccountId,strInstrumentType,dblNoOfLot)		
	SELECT strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,'Net Hedge','Future' strContractType,strLocationName, strFutureMonth,HedgedQty,intUnitMeasureId,@intCommodityId,strAccountNumber,strTranType,intBrokerageAccountId,strInstrumentType,dblNoOfLot
	FROM (
		SELECT strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,(ISNULL(intNoOfContract, 0) -  isnull((SELECT sum(dblMatchQty) FROM tblRKMatchFuturesPSDetail s WHERE s.intLFutOptTransactionId = f.intFutOptTransactionId), 0)) * m.dblContractSize AS HedgedQty,
		l.strLocationName,left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) strFutureMonth,m.intUnitMeasureId,
		e.strName + '-' + ba.strAccountNumber strAccountNumber,strBuySell as strTranType,f.intBrokerageAccountId,
		case when f.intInstrumentTypeId = 1 then 'Futures' else 'Options ' end as strInstrumentType,
		CASE WHEN f.strBuySell = 'Buy' THEN (
			f.intNoOfContract - isnull((SELECT sum(dblMatchQty) FROM tblRKMatchFuturesPSDetail l WHERE l.intLFutOptTransactionId = f.intFutOptTransactionId), 0))
			ELSE - (f.intNoOfContract - isnull((SELECT sum(dblMatchQty) FROM tblRKMatchFuturesPSDetail s WHERE s.intSFutOptTransactionId = f.intFutOptTransactionId), 0)
		) END AS dblNoOfLot 
		FROM tblRKFutOptTransaction f
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		INNER JOIN tblICCommodity ic on f.intCommodityId=ic.intCommodityId
		INNER JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=f.intFutureMonthId
		INNER JOIN tblSMCompanyLocation l on f.intLocationId=l.intCompanyLocationId
		INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
		INNER JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
		WHERE f.strBuySell = 'Buy'
			AND ic.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
			AND f.intLocationId= CASE WHEN ISNULL(@intLocationId,0)=0 then f.intLocationId else @intLocationId end	
		
		UNION 
		
		SELECT strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,-(ISNULL(intNoOfContract, 0) -  isnull((SELECT sum(dblMatchQty) FROM tblRKMatchFuturesPSDetail s WHERE s.intSFutOptTransactionId = f.intFutOptTransactionId), 0)) * m.dblContractSize AS HedgedQty,
		l.strLocationName,left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) strFutureMonth,m.intUnitMeasureId,
		e.strName + '-' + ba.strAccountNumber strAccountNumber,strBuySell as strTranType,f.intBrokerageAccountId,
		case when f.intInstrumentTypeId = 1 then 'Futures' else 'Options ' end as strInstrumentType,
		CASE WHEN f.strBuySell = 'Buy' THEN (
		f.intNoOfContract - isnull((SELECT sum(dblMatchQty) FROM tblRKMatchFuturesPSDetail l WHERE l.intLFutOptTransactionId = f.intFutOptTransactionId), 0))
		ELSE - (f.intNoOfContract - isnull((SELECT sum(dblMatchQty) FROM tblRKMatchFuturesPSDetail s WHERE s.intSFutOptTransactionId = f.intFutOptTransactionId), 0)
		) END AS dblNoOfLot 
		FROM tblRKFutOptTransaction f
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		INNER JOIN tblICCommodity ic on f.intCommodityId=ic.intCommodityId
		INNER JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=f.intFutureMonthId
		INNER JOIN tblSMCompanyLocation l on f.intLocationId=l.intCompanyLocationId
		INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
		INNER JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
		WHERE f.strBuySell = 'Sell'
			AND ic.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
			AND f.intLocationId= case when isnull(@intLocationId,0)=0 then f.intLocationId else @intLocationId end			
		) t	

--	-- Option NetHEdge
	INSERT INTO @tempFinal (strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strContractType,strLocationName,strContractEndMonth,dblTotal,
							intFromCommodityUnitMeasureId,intCommodityId,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType)	
		SELECT DISTINCT strCommodityCode,ft.strInternalTradeNo,intFutOptTransactionHeaderId,'Net Hedge' ,'Future',strLocationName,
				 left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) strFutureMonth, 				
				CASE WHEN ft.strBuySell = 'Buy' THEN (
						ft.intNoOfContract - isnull((SELECT sum(intMatchQty) FROM tblRKOptionsMatchPnS l
						WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId	), 0)
						) ELSE - (ft.intNoOfContract - isnull((	SELECT sum(intMatchQty)	FROM tblRKOptionsMatchPnS s	WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId	), 0)
						) END * isnull((
						SELECT TOP 1 dblDelta
						FROM tblRKFuturesSettlementPrice sp
						INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
						WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
						AND ft.dblStrike = mm.dblStrike
						ORDER BY dtmPriceDate DESC
				),0)*m.dblContractSize AS dblNoOfContract, m.intUnitMeasureId,ft.intCommodityId,				
		e.strName + '-' + strAccountNumber AS strAccountNumber, 		
		strBuySell AS TranType, 
		CASE WHEN ft.strBuySell = 'Buy' THEN (
					ft.intNoOfContract - isnull((SELECT sum(intMatchQty) FROM tblRKOptionsMatchPnS l WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId), 0))
					ELSE - (ft.intNoOfContract - isnull((SELECT sum(intMatchQty) FROM tblRKOptionsMatchPnS s WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId), 0)
				) END AS dblNoOfLot, 
		isnull((SELECT TOP 1 dblDelta
		FROM tblRKFuturesSettlementPrice sp
		INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
		WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
		AND ft.dblStrike = mm.dblStrike
		ORDER BY dtmPriceDate DESC
		),0) AS dblDelta,ft.intBrokerageAccountId,case when ft.intInstrumentTypeId  = 1 then 'Futures' else 'Options ' end as strInstrumentType
	FROM tblRKFutOptTransaction ft
	INNER JOIN tblRKFutureMarket m ON ft.intFutureMarketId = m.intFutureMarketId
	INNER JOIN tblSMCompanyLocation l on ft.intLocationId=l.intCompanyLocationId
	INNER JOIN tblICCommodity ic on ft.intCommodityId=ic.intCommodityId
	INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
	INNER JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
	INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
	WHERE ft.intCommodityId = @intCommodityId AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId else @intLocationId end AND intFutOptTransactionId NOT IN (
			SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned	) AND intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
--		-- Net Hedge option end			
	INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries)

	SELECT @strDescription,'Price Risk' [strType],'Physical' strContractType
		,isnull(invQty, 0)-isnull(PurBasisDelivary,0)  + (isnull(OpenPurQty, 0) - isnull(OpenSalQty, 0))+ isnull(dblCollatralSales,0) + isnull(SlsBasisDeliveries,0) AS dblTotal,
		@intCommodityUnitMeasureId,@intCommodityId,
		 isnull(invQty, 0) invQty ,-isnull(PurBasisDelivary,0) as PurBasisDelivary, isnull(OpenPurQty, 0) as OpenPurQty,
		 -isnull(OpenSalQty, 0) OpenSalQty,  isnull(dblCollatralSales,0) dblCollatralSales, isnull(SlsBasisDeliveries,0) SlsBasisDeliveries		 
	FROM (
		SELECT (select sum(qty) Qty from (
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((it1.dblUnitOnHand),0)) qty
				FROM tblICItem i1
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId and isnull(it1.dblUnitOnHand,0) > 0
				INNER JOIN tblICItemLocation ic ON ic.intItemLocationId = it1.intItemLocationId
				JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
				WHERE i1.intCommodityId  = @intCommodityId
				AND ic.intLocationId= case when isnull(@intLocationId,0)=0 then ic.intLocationId else @intLocationId end					
				)t) AS invQty
			,(select sum(dblQty) from (
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(sr1.dblQty, 0))) dblQty				 
				FROM tblICItem i1
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId 
				INNER JOIN tblICItemLocation ic ON ic.intItemLocationId = it1.intItemLocationId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId and isnull(sr1.dblQty,0) > 0
					JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1 and isnull(sr1.dblQty,0) > 0
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
				WHERE i1.intCommodityId  = @intCommodityId AND ic.intLocationId= case when isnull(@intLocationId,0)=0 then ic.intLocationId else @intLocationId end
				) t) AS ReserveQty
			,( SELECT sum(dblBalance) dblBalance from (
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance
				FROM vyuRKContractDetail cd
				WHERE intContractTypeId = 1 and intPricingTypeId IN (1,3) AND cd.intCommodityId  = @intCommodityId 
				AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
				)t) AS OpenPurQty
			,( SELECT sum(dblBalance) dblBalance from (
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance
				FROM vyuRKContractDetail cd
				WHERE intContractTypeId = 2 and intPricingTypeId IN (1,3) AND cd.intCommodityId  = @intCommodityId 
				AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
				)t) AS OpenSalQty,				

			(SELECT sum(ISNULL(dblTotal,0)) dblTotal FROM 
			(SELECT 
			dbo.fnCTConvertQuantityToTargetCommodityUOM(CT.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((PLDetail.dblLotPickedQty),0)) AS dblTotal
			FROM tblLGDeliveryPickDetail Del
			INNER JOIN tblLGPickLotDetail PLDetail ON PLDetail.intPickLotDetailId = Del.intPickLotDetailId
			INNER JOIN vyuLGPickOpenInventoryLots Lots ON Lots.intLotId = PLDetail.intLotId
			INNER JOIN vyuRKContractDetail CT ON CT.intContractDetailId = Lots.intContractDetailId
			WHERE CT.intPricingTypeId = 2 AND CT.intCommodityId = @intCommodityId 
			AND CT.intCompanyLocationId  = case when isnull(@intLocationId,0)=0 then CT.intCompanyLocationId   else @intLocationId end
			
			UNION ALL
			
			SELECT 
			dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblReceived, 0))  AS dblTotal
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT')
			INNER JOIN vyuRKContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 
			WHERE cd.intCommodityId = @intCommodityId 
			AND st.intProcessingLocationId  = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end)t) as PurBasisDelivary,

			isnull((SELECT SUM(isnull(dblOriginalQuantity,0)) - sum(isnull(dblAdjustmentAmount,0)) CollateralSale
			FROM ( 
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((SUM(dblAdjustmentAmount)),0)) dblAdjustmentAmount,
					intContractHeaderId,
					dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((SUM(dblOriginalQuantity)),0)) dblOriginalQuantity
					FROM tblRKCollateral c1
					LEFT JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId
					JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=c1.intCommodityId AND c1.intUnitMeasureId=ium.intUnitMeasureId 
					WHERE strType = 'Sale' AND c1.intCommodityId = c.intCommodityId 
					AND c1.intLocationId= case when isnull(@intLocationId,0)=0 then c1.intLocationId else @intLocationId end
					GROUP BY intContractHeaderId,ium.intCommodityUnitMeasureId) t 	WHERE dblAdjustmentAmount <> dblOriginalQuantity
			), 0) AS dblCollatralSales


		,(SELECT sum(SlsBasisDeliveries) from( SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((ri.dblQuantity),0)) AS SlsBasisDeliveries  
		  FROM tblICInventoryShipment r  
		  INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
		  INNER JOIN vyuRKContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND ri.intOrderId = 1 
		  WHERE cd.intCommodityId = c.intCommodityId AND 
		  cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then   cd.intCompanyLocationId else @intLocationId end  
		  )t) as SlsBasisDeliveries 			
		FROM tblICCommodity c
		WHERE c.intCommodityId  = @intCommodityId
		) t
				
	INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,intNoOfContract,dblContractSize)	
	SELECT @strDescription,'Price Risk2' [strType],'Future'
		,(((isnull(FutLBalTransQty, 0) - isnull(FutMatchedQty, 0)) - (isnull(FutSBalTransQty, 0) - isnull(FutMatchedQty, 0))) * isnull(dblContractSize,0)) AS dblTotal,
		@intCommodityUnitMeasureId,@intCommodityId,
		((isnull(FutLBalTransQty, 0) - isnull(FutMatchedQty, 0)) - (isnull(FutSBalTransQty, 0) - isnull(FutMatchedQty, 0))) intNoOfContract, isnull(dblContractSize,0) dblContractSize
	FROM (
		SELECT (
				SELECT TOP 1 rfm.dblContractSize AS dblContractSize
				FROM tblRKFutOptTransaction otr
				INNER JOIN tblRKFutureMarket rfm ON rfm.intFutureMarketId = otr.intFutureMarketId
				WHERE otr.intCommodityId  = @intCommodityId
				AND otr.intLocationId= case when isnull(@intLocationId,0)=0 then otr.intLocationId else @intLocationId end
				GROUP BY rfm.intFutureMarketId,rfm.dblContractSize) dblContractSize
			,(
				SELECT SUM(intNoOfContract)
				FROM tblRKFutOptTransaction otr
				WHERE otr.strBuySell = 'Sell' and intInstrumentTypeId=1 
					AND otr.intCommodityId  = @intCommodityId
					AND otr.intLocationId= case when isnull(@intLocationId,0)=0 then otr.intLocationId else @intLocationId end
				) FutSBalTransQty
			,(
				SELECT SUM(intNoOfContract)
				FROM tblRKFutOptTransaction otr
				WHERE otr.strBuySell = 'Buy' and intInstrumentTypeId=1 
					AND otr.intCommodityId  = @intCommodityId
					AND otr.intLocationId= case when isnull(@intLocationId,0)=0 then otr.intLocationId else @intLocationId end
				) AS FutLBalTransQty
			,(	SELECT SUM(psd.dblMatchQty)
				FROM tblRKMatchFuturesPSHeader psh
				INNER JOIN tblRKMatchFuturesPSDetail psd ON psd.intMatchFuturesPSHeaderId = psh.intMatchFuturesPSHeaderId 
				WHERE psh.intCommodityId  = @intCommodityId				
					AND psh.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then psh.intCompanyLocationId else @intLocationId end
				) FutMatchedQty
		FROM tblICCommodity c
		WHERE c.intCommodityId  = @intCommodityId
		) t

--	-- Option NetHedge
	INSERT INTO @tempFinal (strCommodityCode,strType,strContractType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,intNoOfContract,dblContractSize)	
		SELECT DISTINCT strCommodityCode,'Price Risk1','Option',
	
				CASE WHEN ft.strBuySell = 'Buy' THEN (
						ft.intNoOfContract - isnull((SELECT sum(intMatchQty) FROM tblRKOptionsMatchPnS l
						WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId	), 0)
						) ELSE - (ft.intNoOfContract - isnull((	SELECT sum(intMatchQty)	FROM tblRKOptionsMatchPnS s	WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId	), 0)
						) END * isnull((
						SELECT TOP 1 dblDelta
						FROM tblRKFuturesSettlementPrice sp
						INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
						WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
						AND ft.dblStrike = mm.dblStrike
						ORDER BY dtmPriceDate DESC
				),0)*m.dblContractSize AS dblNoOfContract, m.intUnitMeasureId,ft.intCommodityId,
				CASE WHEN ft.strBuySell = 'Buy' THEN (
						ft.intNoOfContract - isnull((SELECT sum(intMatchQty) FROM tblRKOptionsMatchPnS l
						WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId	), 0)
						) ELSE - (ft.intNoOfContract - isnull((	SELECT sum(intMatchQty)	FROM tblRKOptionsMatchPnS s	WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId	), 0)
						) END * isnull((
						SELECT TOP 1 dblDelta
						FROM tblRKFuturesSettlementPrice sp
						INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
						WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END
						AND ft.dblStrike = mm.dblStrike
						ORDER BY dtmPriceDate DESC
				),0) AS dblNoOfContract1, isnull(m.dblContractSize,0) dblContractSize

	FROM tblRKFutOptTransaction ft
	INNER JOIN tblRKFutureMarket m ON ft.intFutureMarketId = m.intFutureMarketId
	INNER JOIN tblSMCompanyLocation l on ft.intLocationId=l.intCompanyLocationId
	INNER JOIN tblICCommodity ic on ft.intCommodityId=ic.intCommodityId
	INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
	INNER JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
	INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
	WHERE ft.intCommodityId = @intCommodityId AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId else @intLocationId end AND intFutOptTransactionId NOT IN (
			SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned	) AND intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
--		-- Net Hedge option end
	
	INSERT INTO @tempFinal(strCommodityCode,strType,strContractType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,strContractNumber,CompanyTitled,OpenPurQty,OpenSalQty)
	SELECT @strDescription,
		'Basis Risk' [strType],'Physical'
		,(isnull(CompanyTitled, 0) + (isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0))) AS dblTotal,
		@intCommodityUnitMeasureId,@intCommodityId,null strContractNumber,isnull(CompanyTitled, 0) CompanyTitled,isnull(OpenPurchasesQty, 0) OpenPurchasesQty,-isnull(OpenSalesQty, 0)
	FROM (
		SELECT (invQty) - isnull(ReserveQty, 0) +  isnull(SlsBasisDeliveries,0) AS CompanyTitled
			,OpenPurchasesQty
			,OpenSalesQty
		FROM (
			SELECT isnull((select sum(Qty) Qty from (
							SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((it1.dblUnitOnHand),0)) Qty
				FROM tblICItem i1
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId and isnull(it1.dblUnitOnHand,0) > 0
				INNER JOIN tblICItemLocation ic ON ic.intItemLocationId = it1.intItemLocationId
				JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
				WHERE i1.intCommodityId  = @intCommodityId
				AND ic.intLocationId= case when isnull(@intLocationId,0)=0 then ic.intLocationId else @intLocationId end	
						)t), 0) AS invQty
				,(select sum(dblQty) from (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(sr1.dblQty, 0))) dblQty				 
					FROM tblICItem i1
					INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId 
					INNER JOIN tblICItemLocation ic ON ic.intItemLocationId = it1.intItemLocationId
					INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId AND ISNULL(sr1.dblQty,0) > 0
						JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
					JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
					WHERE i1.intCommodityId  = @intCommodityId AND ic.intLocationId= case when isnull(@intLocationId,0)=0 then ic.intLocationId else @intLocationId end
					) t) AS ReserveQty
				,( select sum(dblBalance) dblBalance from (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance
					FROM vyuRKContractDetail cd
					WHERE intContractTypeId = 1 and intPricingTypeId IN (1,2) AND cd.intCommodityId  = @intCommodityId 
					AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
					)t)  AS OpenPurchasesQty
				,( select sum(dblBalance) dblBalance from (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance
					FROM vyuRKContractDetail cd
					WHERE intContractTypeId = 2 and intPricingTypeId IN (1,2) AND cd.intCommodityId  = @intCommodityId 
					AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
					)t)  AS OpenSalesQty

			,(
					SELECT 
					 dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblQuantity, 0))
					FROM tblICInventoryShipment r
					INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
					INNER JOIN vyuRKContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND ri.intOrderId = 1  
					JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
					WHERE cd.intCommodityId  = @intCommodityId
						AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
					) AS SlsBasisDeliveries
			FROM tblICCommodity c
			WHERE c.intCommodityId  = @intCommodityId
			) t
		) t1
				
	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId)
	SELECT @strDescription, 'Net Payable  ($)' [strType],dblUnitCost-dblQtyReceived dblTotal,
		intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost1,
		dblQtyReceived,intCommodityId
	 FROM(					
			SELECT DISTINCT ri.intInventoryReceiptItemId
			,cl.strLocationName
			,st.strTicketNumber
			,st.dtmTicketDateTime
			,strCustomerReference
			,'SPT' strDistributionOption
			,dblOrderQty*dblUnitCost AS dblUnitCost
			,dblUnitCost dblUnitCost1
			,isnull((Select SUM((bd.dblQtyReceived*bd.dblCost)-isnull(b.dblAmountDue,0)) FROM tblAPBillDetail bd 
				INNER JOIN tblAPBill b on b.intBillId=bd.intBillId
				WHERE bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId and ysnPosted=1),0) AS dblQtyReceived
			,st.intCommodityId
			,cd.intContractHeaderId, cd.strContractNumber
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN vyuRKContractDetail cd ON cd.intContractHeaderId = ri.intOrderId AND cd.intContractDetailId=intLineNo AND cd.intPricingTypeId = 1   
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1
				AND strReceiptType IN ('Purchase Contract')	AND cd.intCommodityId = @intCommodityId	
				AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
		
		UNION ALL
		
		SELECT DISTINCT ri.intInventoryReceiptItemId
			,cl.strLocationName
			,st.strTicketNumber
			,st.dtmTicketDateTime
			,strCustomerReference
			,'SPT' strDistributionOption
			,dblOrderQty*dblUnitCost AS dblUnitCost
			,dblUnitCost dblUnitCost1
			,isnull((SELECT (bd.dblQtyReceived*bd.dblCost)-isnull(b.dblAmountDue,0) FROM tblAPBillDetail bd 
				INNER JOIN tblAPBill b on b.intBillId=bd.intBillId
				WHERE  bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId and ysnPosted=1 ),0) AS dblQtyReceived
			,st.intCommodityId, NULL as intContractHeaderId, NULL as strContractNumber
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			inner join tblICItem i on ri.intItemId=i.intItemId
			INNER JOIN tblICItemUOM iu on iu.intItemUOMId=ri.intUnitMeasureId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('SPT') and  intSourceType = 1 AND strReceiptType IN ('Direct') AND i.intCommodityId = @intCommodityId  
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId		
			INNER JOIN tblICCommodityUnitMeasure um on um.intCommodityId= @intCommodityId and um.intUnitMeasureId=iu.intUnitMeasureId	
			WHERE r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
			
			)t
	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,
		dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId)

	SELECT @strDescription, 'Net Receivable  ($)' [strType],isnull(dblUnitCost,0)-isnull(dblQtyReceived,0) AS dblTotal,strLocationName,
			intContractHeaderId,strContractNumber
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived,@intCommodityId			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,'Contract' strDistributionOption
				,cd.intContractHeaderId
				,cd.strContractNumber
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,R.dblAmountPaid as dblQtyReceived
				,st.intCommodityId,cd.intUnitMeasureId
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId			
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN vyuRKContractDetail cd ON cd.intContractHeaderId = isi.intOrderId AND cd.intPricingTypeId = 1 
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			LEFT JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
			LEFT JOIN vyuARCustomerPaymentHistoryReport R  ON R.intInvoiceId = I.intInvoiceId and isnull(R.dblAmountPaid, 0)>0
			WHERE intOrderType IN (1) AND intSourceType = 1	AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end	
			) t
		
UNION 
	SELECT @strDescription, 'Net Receivable  ($)' [strType],isnull(dblUnitCost,0)-isnull(dblQtyReceived,0) AS dblTotal,strLocationName,
			intContractHeaderId,strContractNumber
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived,@intCommodityId	
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,'Spot Sale' strDistributionOption
				,null as intContractHeaderId
				,null as strContractNumber
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,st.intCommodityId
				,isnull(R.dblAmountPaid, 0) dblQtyReceived,
				isi.intItemUOMId as intUnitMeasureId
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			LEFT JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
			LEFT JOIN vyuARCustomerPaymentHistoryReport R  ON R.intInvoiceId = I.intInvoiceId and isnull(R.dblAmountPaid, 0) > 0
			WHERE intOrderType IN (4)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			) t	
			
	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId)
	SELECT @strDescription, 'NP Un-Paid Quantity' [strType],(isnull(dblUnitCost,0)-isnull(dblQtyReceived,0))/case when isnull(dblUnitCost1,0)=0 then 1 else  dblUnitCost1 end dblTotal,
		intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost1,
		dblQtyReceived,intCommodityId
	 FROM(					
			SELECT DISTINCT ri.intInventoryReceiptItemId
			,cl.strLocationName
			,st.strTicketNumber
			,st.dtmTicketDateTime
			,strCustomerReference
			,'SPT' strDistributionOption
			,dblOrderQty*dblUnitCost AS dblUnitCost
			,dblUnitCost dblUnitCost1
			,dbo.fnCTConvertQuantityToTargetCommodityUOM(cd.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,
			isnull((Select sum((bd.dblQtyReceived*bd.dblCost)-isnull(b.dblAmountDue,0)) FROM tblAPBillDetail bd 
				INNER JOIN tblAPBill b on b.intBillId=bd.intBillId
				WHERE bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId and ysnPosted=1),0)) AS dblQtyReceived
			,st.intCommodityId
			,cd.intContractHeaderId,cd.strContractNumber
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN vyuRKContractDetail cd ON cd.intContractHeaderId = ri.intOrderId AND cd.intContractDetailId=intLineNo 
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1
				AND strReceiptType IN ('Purchase Contract')	AND cd.intCommodityId = @intCommodityId	
				AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
		
		UNION ALL
		SELECT * FROM (
		SELECT DISTINCT ri.intInventoryReceiptItemId
			,cl.strLocationName
			,st.strTicketNumber
			,st.dtmTicketDateTime
			,strCustomerReference
			,'SPT' strDistributionOption
			,dblOrderQty*dblUnitCost AS dblUnitCost
			,dblUnitCost dblUnitCost1
			,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,
			isnull((SELECT (bd.dblQtyReceived*bd.dblCost)-isnull(b.dblAmountDue,0) FROM tblAPBillDetail bd 
				INNER JOIN tblAPBill b on b.intBillId=bd.intBillId
				WHERE  bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId and ysnPosted=1 ),0)) AS dblQtyReceived
			,st.intCommodityId, NULL as intContractHeaderId, NULL as strContractNumber
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			inner join tblICItem i on ri.intItemId=i.intItemId
			INNER JOIN tblICItemUOM iu on iu.intItemUOMId=ri.intUnitMeasureId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('SPT') and  intSourceType = 1 AND strReceiptType IN ('Direct') AND i.intCommodityId = @intCommodityId  
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId		
			INNER JOIN tblICCommodityUnitMeasure um on um.intCommodityId= @intCommodityId and um.intUnitMeasureId=iu.intUnitMeasureId	
			WHERE r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end)t where dblQtyReceived >0 				
			)t
--done
	INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
	strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId)

	SELECT  @strDescription, 'NR Un-Paid Quantity' [strType], CASE WHEN dblQtyReceived IS NULL then dblQuantity else dblQtyReceived end AS dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber			
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived,@intCommodityId
			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,'Sales Contract' strDistributionOption
				,cd.intContractHeaderId
				,cd.strContractNumber
				,isi.dblQuantity AS dblUnitCost
				,(isnull(SUM(R.dblAmountDue) over (partition BY isi.intInventoryShipmentItemId ), 0)/sum(isnull(dblPrice,1)) over (partition BY isi.intInventoryShipmentItemId) ) as dblQtyReceived,
				cd.intUnitMeasureId as intUnitMeasureId,isi.dblQuantity
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
			JOIN vyuARCustomerPaymentHistoryReport R ON R.intInvoiceId = I.intInvoiceId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('CNT') and  intOrderType IN (1) AND intSourceType = 1
			INNER JOIN vyuRKContractDetail cd ON cd.intContractHeaderId = isi.intOrderId AND cd.intPricingTypeId = 1
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			) t where isnull(dblQtyReceived,0) > 0
		
		UNION ALL
		
		SELECT  @strDescription, 'NR Un-Paid Quantity' [strType],case when dblQtyReceived is null then dblQuantity else dblQtyReceived end AS dblTotal,intInventoryReceiptItemId,strLocationName,null as intContractHeaderId,null strContractNumber
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived,@intCommodityId			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,'Spot Sale' strDistributionOption
				,isi.dblQuantity AS dblUnitCost
				,st.intCommodityId
				,(isnull(SUM(R.dblAmountDue) over (partition BY isi.intInventoryShipmentItemId ), 0)/sum(isnull(dblPrice,1)) over (partition BY isi.intInventoryShipmentItemId) ) as dblQtyReceived,
				isi.intItemUOMId as intUnitMeasureId,isi.dblQuantity
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
			JOIN vyuARCustomerPaymentHistoryReport R ON R.intInvoiceId = I.intInvoiceId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('SPT') and intOrderType IN (4)	AND intSourceType = 1
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE  st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			) t WHERE isnull(dblQtyReceived,0) > 0

	INSERT INTO @tempFinal(strCommodityCode,strType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId)
	SELECT @strDescription
		,'Avail for Spot Sale' [strType]
		,(isnull(CompanyTitled, 0) + (isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0))) - isnull(ReceiptProductQty, 0) AS dblTotal,@intCommodityUnitMeasureId,@intCommodityId
	FROM (
		SELECT (invQty) - isnull(ReserveQty, 0) 
 		 AS CompanyTitled
			,ReceiptProductQty
			,OpenPurchasesQty
			,OpenSalesQty
		FROM (
			SELECT (
					(select sum(isnull(Qty,0)) Qty from(
						SELECT 
						 dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((a.dblUnitOnHand),0)) as Qty 
 						 FROM tblICItemStock a  
						  JOIN tblICItemLocation il on a.intItemLocationId=il.intItemLocationId   and isnull(a.dblUnitOnHand,0) > 0 
						  JOIN tblICItem i on a.intItemId=i.intItemId  
						  JOIN tblSMCompanyLocation sl on sl.intCompanyLocationId=il.intLocationId  
						  JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
						  JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
						 WHERE il.intLocationId = case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end 
							and i.intCommodityId= c.intCommodityId		 
						 )t)						
					) AS invQty
				,(select sum(isnull(Qty,0)) Qty from(
					SELECT 
					 dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((sr1.dblQty),0)) as Qty 
 					 FROM tblICItemStock a  
					  JOIN tblICItemLocation il on a.intItemLocationId=il.intItemLocationId 
					  JOIN tblICStockReservation sr1 ON a.intItemId = sr1.intItemId and isnull(sr1.dblQty,0) > 0
					  JOIN tblICItem i on a.intItemId=i.intItemId  
					  JOIN tblSMCompanyLocation sl on sl.intCompanyLocationId=il.intLocationId  
					   JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
					  JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
					 WHERE il.intLocationId = case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end 
					  and i.intCommodityId= c.intCommodityId		 
					 )t) AS ReserveQty
				,(SELECT sum(Qty) FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(CD.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
					FROM vyuRKContractDetail  CD  
					WHERE  intContractTypeId=1 and intPricingTypeId in(1,2) and CD.intCommodityId=c.intCommodityId and CD.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end 
				)t) AS ReceiptProductQty
				,(SELECT sum(Qty) FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(CD.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
					FROM vyuRKContractDetail  CD   
					WHERE  intContractTypeId=1 and intPricingTypeId in(1,2) and CD.intCommodityId=c.intCommodityId and CD.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end )t) AS OpenPurchasesQty --req              
				,(SELECT sum(Qty) FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(CD.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
					FROM vyuRKContractDetail  CD   
					WHERE   intContractTypeId=2 and intPricingTypeId in(1,2) and CD.intCommodityId=c.intCommodityId and CD.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end )t) AS OpenSalesQty
			FROM tblICCommodity c
			WHERE c.intCommodityId  = @intCommodityId
			) t
		)t1
	
	select @intUnitMeasureId =null
	select @strUnitMeasure =null
	SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
	SELECT @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
	INSERT INTO @Final (strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractType,strContractEndMonth, 
		dblTotal,strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType 
		,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled)

	SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractType,strContractEndMonth, 	
	    Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblTotal)) dblTotal,
		case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as  strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,
		strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType
		,Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,invQty)) invQty,
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,PurBasisDelivary)) PurBasisDelivary,
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,OpenPurQty)) OpenPurQty,
				Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,OpenSalQty)) OpenSalQty,
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblCollatralSales)) dblCollatralSales,
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,SlsBasisDeliveries)) SlsBasisDeliveries
		,intNoOfContract,dblContractSize,
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,CompanyTitled)) CompanyTitled
		  
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId and strType<>'Net Hedge' and strType <>'Price Risk1' and strType <>'Price Risk2' and strType not in('Net Payable  ($)','Net Receivable  ($)')
	UNION

	SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractType,strContractEndMonth, 	
	    dblTotal dblTotal,
		case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  
		,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId and strType in( 'Net Payable  ($)','Net Receivable  ($)')
	

	UNION
	SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractType,strContractEndMonth, 
	    dblTotal dblTotal,
		case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  
		,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId and strType='Net Hedge'

	INSERT INTO @Final (strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractType,strContractEndMonth, 
		dblTotal,strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,
		invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled)
	
	SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, 'Price Risk',strContractType,strContractEndMonth, 
	    dblTotal dblTotal,
		case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,
		invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled  
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId and strType ='Price Risk1'

	INSERT INTO @Final (strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractType,strContractEndMonth, 
		dblTotal,strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,
		invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled)
	SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, 'Price Risk',strContractType,strContractEndMonth, 
	    dblTotal dblTotal,
		case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  
		,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled 
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId and strType ='Price Risk2'


END
ELSE
BEGIN
	INSERT INTO @tempFinal (strCommodityCode,intContractHeaderId,strContractNumber,strType,strSubType,strContractType,strLocationName,strContractEndMonth,dblTotal,intFromCommodityUnitMeasureId,intCommodityId)
	SELECT strCommodityCode,intContractHeaderId,
	 strContractNumber
		,strContractType+ ' ' + strPricingType [strType],strContractType+ ' ' + strPricingType,'Physical'
		,strLocationName,
		RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(CD.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) AS dblTotal
		,CD.intUnitMeasureId,@intCommodityId 
	FROM vyuRKContractDetail CD
	WHERE intContractTypeId in(1,2) AND intPricingTypeId IN (1,2,3) and CD.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
	AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
	AND intEntityId= @intVendorId 
	
	INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId)
	SELECT  @strDescription, 'Quantity Purchase' [strType],'Quantity Purchase',isnull(dblOpenReceive,0) dblTotal,
			cd.intContractHeaderId, ch.strContractNumber + '-' + convert(varchar,intContractSeq) strContractNumber,
					cl.strLocationName
				,r.strReceiptNumber strTicketNumber
				,r.dtmReceiptDate dtmTicketDateTime
				,r.strVendorRefNo as strCustomerReference
				,'Purchase Contract' as strDistributionOption
				,dblUnitCost AS dblUnitCost
				,isnull(dblUnitCost,0)*isnull(dblOpenReceive,0) AS dblQtyReceived
				,ch.intCommodityId
	FROM tblICInventoryReceipt r
	INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Purchase Contract')
	INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
	INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intContractDetailId=intLineNo AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
	INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
	WHERE ch.intCommodityId = @intCommodityId and ch.intEntityId=@intVendorId 
	AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end

	UNION

	SELECT @strDescription, 'Quantity Purchase' [strType], 'Quantity Purchase',isnull(dblOpenReceive,0) dblTotal
				,null as intContractHeaderId, null as strContractNumber
				,cl.strLocationName
				,r.strReceiptNumber strTicketNumber
				,r.dtmReceiptDate dtmTicketDateTime
				,r.strVendorRefNo as strCustomerReference
				,'Direct' as strDistributionOption
				,dblUnitCost AS dblUnitCost
				,isnull(dblUnitCost,0)*isnull(dblOpenReceive,0) AS dblQtyReceived
				,i.intCommodityId			
	FROM tblICInventoryReceipt r
	INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Direct') 
	AND r.intSourceType=1 and isnull(dblUnitCost,0) <> 0 
	INNER JOIN tblICItem i on ri.intItemId=i.intItemId
	INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
	WHERE i.intCommodityId = @intCommodityId AND r.intEntityVendorId =@intVendorId
	AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end	
	
	INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId)
SELECT	@strDescription, 'Quantity Sales' [strType], 'Quantity Sales',isnull(dblQuantity,0) dblTotal,
		cd.intContractHeaderId,strContractNumber
			,cd.strLocationName
			,s.strShipmentNumber strTicketNumber
			,s.dtmShipDate dtmTicketDateTime
			,s.strReferenceNumber as strCustomerReference
			,'Spot Sale' as strDistributionOption
			,dblUnitPrice AS dblUnitCost
			,ISNULL(dblQuantity,0)*ISNULL(dblUnitPrice,0) AS dblQtyReceived
			,cd.intCommodityId
		FROM tblICInventoryShipment s
		join tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId and intOrderType =4 and isnull(dblUnitPrice,0) <>0
		JOIN vyuRKContractDetail cd on cd.intContractDetailId=si.intLineNo 
		join tblICItem i on si.intItemId=i.intItemId  WHERE i.intCommodityId=@intCommodityId and s.intEntityCustomerId=@intVendorId
		AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
		
	UNION
		SELECT @strDescription, 'Quantity Sales' [strType],'Quantity Sales',ISNULL(dblQuantity,0) dblTotal
			,cd.intContractHeaderId, strContractNumber
			,cd.strLocationName
			,s.strShipmentNumber strTicketNumber
			,s.dtmShipDate dtmTicketDateTime
			,s.strReferenceNumber as strCustomerReference
			,'Sales Contract' as strDistributionOption
			,dblUnitPrice AS dblUnitCost
			,isnull(dblQuantity,0)*ISNULL(dblUnitPrice,0) AS dblQtyReceived
			,cd.intCommodityId
		from tblICInventoryShipment s
		JOIN tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId 
		JOIN vyuRKContractDetail cd on cd.intContractDetailId=si.intLineNo and cd.intContractTypeId=2  
		AND cd.intCommodityId=@intCommodityId and cd.intEntityId=@intVendorId 
		AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end	
	
	INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId)
	SELECT  @strDescription, 'Purchase Gross Dollars' [strType], 'Purchase Gross Dollars',isnull(dblOpenReceive,0)*isnull(dblUnitCost,0) dblTotal,
			cd.intContractHeaderId, ch.strContractNumber + '-' + convert(varchar,cd.intContractSeq) strContractNumber
			,cl.strLocationName
			,r.strReceiptNumber strTicketNumber
			,r.dtmReceiptDate dtmTicketDateTime
			,r.strVendorRefNo as strCustomerReference
			,'Purchase Contract' as strDistributionOption
			,dblUnitCost AS dblUnitCost
			,isnull(dblOpenReceive,0) AS dblQtyReceived
			,ch.intCommodityId			
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Purchase Contract')
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
		INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intContractDetailId=intLineNo AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE ch.intCommodityId = @intCommodityId and ch.intEntityId=@intVendorId 
		AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end

		UNION

		SELECT	@strDescription, 'Purchase Gross Dollars' [strType], 'Purchase Gross Dollars',isnull(dblOpenReceive,0)*isnull(dblUnitCost,0) dblTotal,
					null as intContractHeaderId, null as strContractNumber
					,cl.strLocationName
					,r.strReceiptNumber strTicketNumber
					,r.dtmReceiptDate dtmTicketDateTime
					,r.strVendorRefNo as strCustomerReference
					,'Direct' as strDistributionOption
					,dblUnitCost AS dblUnitCost
					,isnull(dblOpenReceive,0) AS dblQtyReceived
					,intCommodityId
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Direct') 
		AND r.intSourceType=1 and isnull(dblUnitCost,0) <> 0 
		INNER JOIN tblICItem i on ri.intItemId=i.intItemId
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE i.intCommodityId = @intCommodityId AND r.intEntityVendorId =@intVendorId
		AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end		

INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId)
SELECT @strDescription, 'Sales Gross Dollars' [strType], 'Sales Gross Dollars',ISNULL(dblQuantity,0) dblTotal,
			cd.intContractHeaderId, cd.strContractNumber
			,cd.strLocationName
			,s.strShipmentNumber strTicketNumber
			,s.dtmShipDate dtmTicketDateTime
			,s.strReferenceNumber as strCustomerReference
			,'Purchase Contract' as strDistributionOption			
			,dblUnitPrice AS dblUnitCost
			,ISNULL(dblQuantity,0)*ISNULL(dblUnitPrice,0) AS dblQtyReceived
			,cd.intCommodityId
		FROM tblICInventoryShipment s
		JOIN tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId and intOrderType =4 and isnull(dblUnitPrice,0) <>0
		JOIN tblICItem i on si.intItemId=i.intItemId 
		JOIN vyuRKContractDetail cd on cd.intContractDetailId=si.intLineNo 
		WHERE i.intCommodityId=@intCommodityId and cd.intEntityId=@intVendorId  
		AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
		UNION
		SELECT @strDescription, 'Sales Gross Dollars' [strType], 'Sales Gross Dollars',ISNULL(dblQuantity,0)*ISNULL(dblUnitPrice,0) dblTotal,
			cd.intContractHeaderId, cd.strContractNumber
			,cd.strLocationName
			,s.strShipmentNumber strTicketNumber
			,s.dtmShipDate dtmTicketDateTime
			,s.strReferenceNumber as strCustomerReference
			,'Direct' as strDistributionOption
			,dblUnitPrice AS dblUnitCost
			,ISNULL(dblQuantity,0) AS dblQtyReceived
			,cd.intCommodityId
		FROM tblICInventoryShipment s
		JOIN tblICInventoryShipmentItem si ON s.intInventoryShipmentId=si.intInventoryShipmentId 
		JOIN vyuRKContractDetail cd ON cd.intContractDetailId=si.intLineNo and cd.intContractTypeId=2   
		AND cd.intCommodityId=@intCommodityId AND cd.intEntityId=@intVendorId 
		AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end	

	INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId)
	SELECT @strDescription, 'Net Receivable  ($)' [strType],'Sale Net Receivable  ($)',isnull(dblUnitCost,0)-isnull(dblQtyReceived,0) AS dblTotal,
			intContractHeaderId,strContractNumber,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived,@intCommodityId			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,'Contract' strDistributionOption
				,ch.intContractHeaderId
				,ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,R.dblAmountPaid as dblQtyReceived
				,st.intCommodityId,cd.intUnitMeasureId
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			LEFT JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
			LEFT JOIN vyuARCustomerPaymentHistoryReport R  ON R.intInvoiceId = I.intInvoiceId and isnull(R.dblAmountPaid, 0)>0
			WHERE intOrderType IN (1) AND intSourceType = 1	AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end	
				AND st.intEntityId= @intVendorId 	
			) t
		
UNION 
		SELECT @strDescription, 'Net Receivable  ($)' [strType],'Sale Net Receivable  ($)',isnull(dblUnitCost,0)-isnull(dblQtyReceived,0) AS dblTotal,
			intContractHeaderId,strContractNumber,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived,@intCommodityId	
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,'Spot Sale' strDistributionOption
				,null as intContractHeaderId
				,null as strContractNumber
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,st.intCommodityId
				,R.dblAmountPaid as dblQtyReceived,
				isi.intItemUOMId as intUnitMeasureId
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			LEFT JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
			LEFT JOIN vyuARCustomerPaymentHistoryReport R  ON R.intInvoiceId = I.intInvoiceId and isnull(R.dblAmountPaid, 0)>0
			WHERE intOrderType IN (4)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
				AND st.intEntityId= @intVendorId 	
			) t	
				
	INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
	strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId)

	SELECT @strDescription, 'Net Receivable  ($)' [strType],'Sale Net Receivable  ($)',dblQtyReceived AS dblTotal,intInventoryReceiptItemId,strLocationName,
			intContractHeaderId,strContractNumber
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived,@intCommodityId			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,'Contract' strDistributionOption
				,ch.intContractHeaderId
				,ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,R.dblAmountDue dblQtyReceived
				,st.intCommodityId,cd.intUnitMeasureId
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			LEFT JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
			LEFT JOIN vyuARCustomerPaymentHistoryReport R  ON R.intInvoiceId = I.intInvoiceId and isnull(R.dblAmountPaid, 0)>0
			WHERE intOrderType IN (1) AND intSourceType = 1	AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end	
				AND st.intEntityId= @intVendorId 	
			) t
		
UNION 

		SELECT @strDescription, 'Net Receivable  ($)' [strType],'Sale Net Receivable  ($)',dblQtyReceived AS dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber
			,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption, dblUnitCost,dblQtyReceived,@intCommodityId
			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,'Spot Sale' strDistributionOption
				,null as intContractHeaderId
				,null as strContractNumber
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,st.intCommodityId
				,R.dblAmountDue dblQtyReceived,
				isi.intItemUOMId as intUnitMeasureId
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			LEFT JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
			LEFT JOIN vyuARCustomerPaymentHistoryReport R  ON R.intInvoiceId = I.intInvoiceId and isnull(R.dblAmountPaid, 0)>0
			WHERE intOrderType IN (4)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
				AND st.intEntityId= @intVendorId 	
			) t	

	INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId)
	SELECT @strDescription, 'NP Un-Paid Quantity' [strType],'Purchase NP Un-Paid Quantity',(isnull(dblUnitCost,0)-isnull(dblQtyReceived,0))/isnull(dblUnitCost1,1)  dblTotal,
		intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost1,
		dblQtyReceived,intCommodityId
	 FROM(					
			SELECT DISTINCT ri.intInventoryReceiptItemId
			,cl.strLocationName
			,st.strTicketNumber
			,st.dtmTicketDateTime
			,strCustomerReference
			,'SPT' strDistributionOption
			,dblOrderQty*dblUnitCost AS dblUnitCost
			,dblUnitCost dblUnitCost1
			,dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,
			isnull((Select (bd.dblQtyReceived*bd.dblCost)-isnull(b.dblAmountDue,0) FROM tblAPBillDetail bd 
				INNER JOIN tblAPBill b on b.intBillId=bd.intBillId
				WHERE bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId and ysnPosted=1),0)) AS dblQtyReceived
			,st.intCommodityId
			,cd.intContractHeaderId, cd.strContractNumber
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN vyuRKContractDetail cd ON cd.intContractHeaderId = ri.intOrderId AND cd.intContractDetailId=intLineNo AND cd.intPricingTypeId = 1
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1
				AND strReceiptType IN ('Purchase Contract')	AND cd.intCommodityId = @intCommodityId	
				AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
				AND cd.intEntityId= @intVendorId 
		
		UNION ALL
		SELECT * FROM (
		SELECT DISTINCT ri.intInventoryReceiptItemId
			,cl.strLocationName
			,st.strTicketNumber
			,st.dtmTicketDateTime
			,strCustomerReference
			,'SPT' strDistributionOption
			,dblOrderQty*dblUnitCost AS dblUnitCost
			,dblUnitCost dblUnitCost1
			,dbo.fnCTConvertQuantityToTargetCommodityUOM(um.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,
			isnull((SELECT (bd.dblQtyReceived*bd.dblCost)-isnull(b.dblAmountDue,0) FROM tblAPBillDetail bd 
				INNER JOIN tblAPBill b on b.intBillId=bd.intBillId
				WHERE  bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId and ysnPosted=1 ),0)) AS dblQtyReceived
			,st.intCommodityId, NULL as intContractHeaderId, NULL as strContractNumber
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			inner join tblICItem i on ri.intItemId=i.intItemId
			INNER JOIN tblICItemUOM iu on iu.intItemUOMId=ri.intUnitMeasureId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('SPT') and  intSourceType = 1 AND strReceiptType IN ('Direct') AND i.intCommodityId = @intCommodityId  
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId		
			INNER JOIN tblICCommodityUnitMeasure um on um.intCommodityId= @intCommodityId and um.intUnitMeasureId=iu.intUnitMeasureId	
			WHERE r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
			AND st.intEntityId= @intVendorId )t where dblQtyReceived >0
			
			)t

	INSERT INTO @tempFinal (strCommodityCode,strType,strSubType,dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
	strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intCommodityId)

SELECT  @strDescription, 'NR Un-Paid Quantity' [strType],'Sale NR Un-Paid Quantity',CASE WHEN dblQtyReceived IS NULL then dblQuantity else dblQtyReceived end AS dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber			
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived,@intCommodityId
			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,'Sales Contract' strDistributionOption
				,ch.intContractHeaderId
				,ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
				,isi.dblQuantity AS dblUnitCost
				,(isnull(SUM(R.dblAmountDue) over (partition BY isi.intInventoryShipmentItemId ), 0)/sum(isnull(dblPrice,1)) over (partition BY isi.intInventoryShipmentItemId) ) as dblQtyReceived,
				cd.intUnitMeasureId as intUnitMeasureId,isi.dblQuantity
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
			JOIN vyuARCustomerPaymentHistoryReport R ON R.intInvoiceId = I.intInvoiceId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId and cd.intContractStatusId <> 3
				AND cd.intPricingTypeId = 1
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (1)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
				AND st.intEntityId= @intVendorId 
			) t  where isnull(dblQtyReceived,0) > 0
		
		UNION ALL
		
		SELECT  @strDescription, 'NR Un-Paid Quantity' [strType],'Sale NR Un-Paid Quantity',dblUnitCost - dblQtyReceived AS dblTotal,intInventoryReceiptItemId,strLocationName,null as intContractHeaderId,null strContractNumber
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived,@intCommodityId			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,'Spot Sale' strDistributionOption
				,isi.dblQuantity AS dblUnitCost
				,st.intCommodityId
				,(isnull(SUM(R.dblAmountDue) over (partition BY isi.intInventoryShipmentItemId ), 0)/sum(isnull(dblPrice,1)) over (partition BY isi.intInventoryShipmentItemId) ) as dblQtyReceived,
				isi.intItemUOMId as intUnitMeasureId,isi.dblQuantity
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			JOIN tblARInvoiceDetail I on isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
			JOIN vyuARCustomerPaymentHistoryReport R ON R.intInvoiceId = I.intInvoiceId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId	AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (4)	AND intSourceType = 1 AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
				AND st.intEntityId= @intVendorId 
			) t

	SELECT @intUnitMeasureId =null
	SELECT @strUnitMeasure =null
	SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
	SELECT @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
	INSERT INTO @Final (strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strSubType,strContractType,strContractEndMonth, 
		dblTotal,strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType 
		,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled)

	SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strSubType,strContractType,strContractEndMonth, 	
	    Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblTotal)) dblTotal,
		case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,
		strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType
		,Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,invQty)) invQty,
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,PurBasisDelivary)) PurBasisDelivary,
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,OpenPurQty)) OpenPurQty,
				Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,OpenSalQty)) OpenSalQty,
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblCollatralSales)) dblCollatralSales,
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,SlsBasisDeliveries)) SlsBasisDeliveries
		,intNoOfContract,dblContractSize,
		Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,CompanyTitled)) CompanyTitled
		  
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId and strType not in('Net Payable  ($)','Net Receivable  ($)')
	UNION

	SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strSubType,strContractType,
	strContractEndMonth, dblTotal dblTotal,case when isnull(@strUnitMeasure,'')='' then um.strUnitMeasure else @strUnitMeasure end as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,
	strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  
		,invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICUnitMeasure um on um.intUnitMeasureId=cuc.intUnitMeasureId
	 WHERE t.intCommodityId= @intCommodityId and strType in( 'Net Payable  ($)','Net Receivable  ($)')
	
END
END
SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber	
END

UPDATE @Final set intSeqNo = 1 where strType='Purchase Priced'
UPDATE @Final set intSeqNo = 2 where strType='Purchase Basis'
UPDATE @Final set intSeqNo = 3 where strType='Purchase HTA'
UPDATE @Final set intSeqNo = 4 where strType='Sale Priced'
UPDATE @Final set intSeqNo = 5 where strType='Sale Basis'
UPDATE @Final set intSeqNo = 6 where strType='Sale HTA'
UPDATE @Final set intSeqNo = 7 where strType='Net Hedge'
UPDATE @Final set intSeqNo = 8 where strType='Price Risk'
UPDATE @Final set intSeqNo = 9 where strType='Basis Risk'
UPDATE @Final set intSeqNo = 10 where strType='Net Payable  ($)'
UPDATE @Final set intSeqNo = 11 where strType='NP Un-Paid Quantity'
UPDATE @Final set intSeqNo = 12 where strType='Net Receivable  ($)'
UPDATE @Final set intSeqNo = 13 where strType='NR Un-Paid Quantity'
UPDATE @Final set intSeqNo = 14 where strType='Avail for Spot Sale'
	
IF isnull(@intVendorId,0) = 0
BEGIN
	SELECT intSeqNo,intRow, strCommodityCode ,intContractHeaderId,strContractNumber,strInternalTradeNo,intFutOptTransactionHeaderId, strType,strContractType,strContractEndMonth,dblTotal,strUnitMeasure 
				,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,
				invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled  			
	FROM @Final where dblTotal <> 0  
	ORDER BY intSeqNo ASC
END
ELSE
BEGIN
	SELECT intSeqNo,intRow, strCommodityCode ,intContractHeaderId,strContractNumber,strInternalTradeNo,intFutOptTransactionHeaderId, strType,strSubType,strContractType,strContractEndMonth,dblTotal,strUnitMeasure 
				,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType,
				invQty,PurBasisDelivary,OpenPurQty,OpenSalQty,dblCollatralSales, SlsBasisDeliveries,intNoOfContract,dblContractSize,CompanyTitled  			
	FROM @Final where dblTotal <> 0 and strSubType NOT like '%'+@strPurchaseSales+'%'
	ORDER BY intSeqNo ASC
END