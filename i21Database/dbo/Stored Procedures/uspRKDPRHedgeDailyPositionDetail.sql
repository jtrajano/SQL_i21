CREATE PROCEDURE [dbo].[uspRKDPRHedgeDailyPositionDetail] 
		 @intCommodityId nvarchar(max)
		,@intLocationId int = NULL
AS

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
)

DECLARE @Final AS TABLE (
		 intRow INT IDENTITY(1,1),
		 intContractHeaderId int,
		 strContractNumber NVARCHAR(200),
		 intFutOptTransactionHeaderId int,
		 strInternalTradeNo NVARCHAR(200),
		 strCommodityCode NVARCHAR(200),   
		 strType  NVARCHAR(50), 
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
)

DECLARE @mRowNumber INT
DECLARE @intCommodityId1 INT
DECLARE @strDescription NVARCHAR(50)
declare @intOneCommodityId int
declare @intCommodityUnitMeasureId int

SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity
WHILE @mRowNumber >0
BEGIN
	SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
	SELECT @strDescription = strCommodityCode FROM tblICCommodity	WHERE intCommodityId = @intCommodityId
	SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId AND ysnDefault=1
IF  @intCommodityId >0
BEGIN

INSERT INTO @tempFinal (strCommodityCode,intContractHeaderId,strContractNumber,strType,strLocationName,strContractEndMonth,dblTotal,intFromCommodityUnitMeasureId,intCommodityId)
	SELECT strCommodityCode,intContractHeaderId,
	strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
			,strContractType+ ' ' + strPricingType [strType]
		,strLocationName,
		RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,
		dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) AS dblTotal
	 ,CD.intUnitMeasureId,@intCommodityId 
	FROM vyuCTContractDetailView CD
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CD.intCommodityId AND CD.intUnitMeasureId=ium.intUnitMeasureId 
	WHERE intContractTypeId in(1,2) AND intPricingTypeId IN (1,2,3) and CD.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
	AND intCompanyLocationId= case when isnull(@intLocationId,0)=0 then intCompanyLocationId else @intLocationId end
	
-- Hedge
	INSERT INTO @tempFinal (strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,dblTotal,
							intFromCommodityUnitMeasureId,intCommodityId,strAccountNumber,strTranType,intBrokerageAccountId,strInstrumentType)		
	SELECT strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,'Net Hedge',strLocationName, strFutureMonth,HedgedQty,intUnitMeasureId,@intCommodityId,strAccountNumber,strTranType,intBrokerageAccountId,strInstrumentType
	FROM (
		SELECT strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,(ISNULL(intNoOfContract, 0) - isnull(dblMatchQty, 0)) * m.dblContractSize AS HedgedQty,
		l.strLocationName,left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) strFutureMonth,m.intUnitMeasureId,
		e.strName + '-' + ba.strAccountNumber strAccountNumber,strBuySell as strTranType,f.intBrokerageAccountId,
		case when f.intInstrumentTypeId = 1 then 'Futures' else 'Options ' end as strInstrumentType
		FROM tblRKFutOptTransaction f
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		INNER JOIN tblICCommodity ic on f.intCommodityId=ic.intCommodityId
		INNER JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=f.intFutureMonthId
		INNER JOIN tblSMCompanyLocation l on f.intLocationId=l.intCompanyLocationId
		INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
		INNER JOIN tblEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
		LEFT JOIN tblRKMatchFuturesPSDetail psd ON f.intFutOptTransactionId = psd.intLFutOptTransactionId
		WHERE f.strBuySell = 'Buy'
			AND ic.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
			AND f.intLocationId= case when isnull(@intLocationId,0)=0 then f.intLocationId else @intLocationId end	
		
		UNION ALL
		
		SELECT strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,-(ISNULL(intNoOfContract, 0) - isnull(dblMatchQty, 0)) * m.dblContractSize AS HedgedQty,
		l.strLocationName,left(strFutureMonth,4) + convert(nvarchar,DATEPART(yyyy,fm.dtmFutureMonthsDate)) strFutureMonth,m.intUnitMeasureId,
		e.strName + '-' + ba.strAccountNumber strAccountNumber,strBuySell as strTranType,f.intBrokerageAccountId,
		case when f.intInstrumentTypeId = 1 then 'Futures' else 'Options ' end as strInstrumentType
		FROM tblRKFutOptTransaction f
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		INNER JOIN tblICCommodity ic on f.intCommodityId=ic.intCommodityId
		INNER JOIN tblRKFuturesMonth fm on fm.intFutureMonthId=f.intFutureMonthId
		INNER JOIN tblSMCompanyLocation l on f.intLocationId=l.intCompanyLocationId
		INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
		INNER JOIN tblEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
		LEFT JOIN tblRKMatchFuturesPSDetail psd ON f.intFutOptTransactionId = psd.intLFutOptTransactionId
		WHERE f.strBuySell = 'Sell'
			AND ic.intCommodityId in (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
			AND f.intLocationId= case when isnull(@intLocationId,0)=0 then f.intLocationId else @intLocationId end
			
		) t	

	-- Option NetHEdge
		INSERT INTO @tempFinal (strCommodityCode,strInternalTradeNo,intFutOptTransactionHeaderId,strType,strLocationName,strContractEndMonth,dblTotal,
							intFromCommodityUnitMeasureId,intCommodityId,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType)	
		SELECT DISTINCT strCommodityCode,ft.strInternalTradeNo,intFutOptTransactionHeaderId,'Net Hedge' ,strLocationName,
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
	INNER JOIN tblEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
	INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
	WHERE ft.intCommodityId = @intCommodityId AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId else @intLocationId end AND intFutOptTransactionId NOT IN (
			SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned	) AND intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
		-- Net Hedge option end
			
	INSERT INTO @tempFinal(strCommodityCode,strType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId)
	SELECT @strDescription,'Cash Exposure' [strType]
		,(isnull(invQty, 0) - isnull(ReserveQty, 0)) + (isnull(OpenPurQty, 0) - isnull(OpenSalQty, 0))+ isnull(dblCollatralSales,0) + isnull(SlsBasisDeliveries,0) + CASE 
				WHEN (
						SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled
						FROM tblRKCompanyPreference
						) = 1
					THEN OffSite
				ELSE 0
				END + CASE 
				WHEN (
						SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled
						FROM tblRKCompanyPreference
						) = 1
					THEN DP
				ELSE 0
				END AS dblTotal,
		@intCommodityUnitMeasureId,@intCommodityId
	FROM (
		SELECT (select sum(qty) Qty from (
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((it1.dblUnitOnHand),0)) qty
				FROM tblICItem i1
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
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
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
					JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
				WHERE i1.intCommodityId  = @intCommodityId AND ic.intLocationId= case when isnull(@intLocationId,0)=0 then ic.intLocationId else @intLocationId end
				) t) AS ReserveQty
			,( select sum(dblBalance) dblBalance from (
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance
				FROM vyuCTContractDetailView cd
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId  AND cd.intUnitMeasureId=ium.intUnitMeasureId
				WHERE intContractTypeId = 1 and intPricingTypeId IN (1,3) AND cd.intCommodityId  = @intCommodityId 
				AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
				)t) AS OpenPurQty
			,( select sum(dblBalance) dblBalance from (
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance
				FROM vyuCTContractDetailView cd
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
				WHERE intContractTypeId = 2 and intPricingTypeId IN (1,3) AND cd.intCommodityId  = @intCommodityId 
				AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
				)t) AS OpenSalQty
				,(select sum(dblTotal) from (
					SELECT 
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(Balance)) dblTotal
					FROM vyuGRGetStorageDetail CH
					WHERE ysnCustomerStorage = 1
						AND strOwnedPhysicalStock = 'Company'
						AND CH.intCommodityId  = @intCommodityId
						AND CH.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CH.intCompanyLocationId else @intLocationId end						
					)t) AS OffSite
				,(select sum(dblTotal) from (
					SELECT 
					dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(isnull(Balance,0))) dblTotal
					FROM vyuGRGetStorageDetail ch
					WHERE ch.intCommodityId  = @intCommodityId
						AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
					)t) AS DP
				,

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


		,(SELECT sum(SlsBasisDeliveries) from( SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((ri.dblQuantity),0)) AS SlsBasisDeliveries  
		  FROM tblICInventoryShipment r  
		  INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId  
		  INNER JOIN vyuCTContractDetailView cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND ri.intOrderId = 1  
	  		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId
		  WHERE cd.intCommodityId = c.intCommodityId AND 
		  cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then   cd.intCompanyLocationId else @intLocationId end  
		  )t) as SlsBasisDeliveries 
			
		FROM tblICCommodity c
		WHERE c.intCommodityId  = @intCommodityId
		) t
	
	INSERT INTO @tempFinal(strCommodityCode,strType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId)
	SELECT @strDescription,'Cash Exposure2' [strType]
		,(((isnull(FutLBalTransQty, 0) - isnull(FutMatchedQty, 0)) - (isnull(FutSBalTransQty, 0) - isnull(FutMatchedQty, 0))) * isnull(dblContractSize,0)) AS dblTotal,
		@intCommodityUnitMeasureId,@intCommodityId
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

	-- Option NetHedge
		INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId)	
		SELECT DISTINCT strCommodityCode,'Cash Exposure1',
	
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
				),0)*m.dblContractSize AS dblNoOfContract, m.intUnitMeasureId,ft.intCommodityId
	FROM tblRKFutOptTransaction ft
	INNER JOIN tblRKFutureMarket m ON ft.intFutureMarketId = m.intFutureMarketId
	INNER JOIN tblSMCompanyLocation l on ft.intLocationId=l.intCompanyLocationId
	INNER JOIN tblICCommodity ic on ft.intCommodityId=ic.intCommodityId
	INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
	INNER JOIN tblEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
	INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
	WHERE ft.intCommodityId = @intCommodityId AND intLocationId = case when isnull(@intLocationId,0)=0 then intLocationId else @intLocationId end AND intFutOptTransactionId NOT IN (
			SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned	) AND intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
		-- Net Hedge option end

	
	INSERT INTO @tempFinal(strCommodityCode,strType,dblTotal,intFromCommodityUnitMeasureId,intCommodityId,strContractNumber)
	SELECT @strDescription,
		'Basis Exposure' [strType]
		,(isnull(CompanyTitled, 0) + (isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0))) AS dblTotal,
		@intCommodityUnitMeasureId,@intCommodityId,null strContractNumber
	FROM (
		SELECT (invQty) - isnull(ReserveQty, 0) +  isnull(SlsBasisDeliveries,0) AS CompanyTitled
			,OpenPurchasesQty
			,OpenSalesQty
		FROM (
			SELECT isnull((select sum(Qty) Qty from (
							SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((it1.dblUnitOnHand),0)) Qty
				FROM tblICItem i1
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
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
					INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
						JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
					JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
					WHERE i1.intCommodityId  = @intCommodityId AND ic.intLocationId= case when isnull(@intLocationId,0)=0 then ic.intLocationId else @intLocationId end
					) t) AS ReserveQty
				,( select sum(dblBalance) dblBalance from (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance
					FROM vyuCTContractDetailView cd
					JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId  AND cd.intUnitMeasureId=ium.intUnitMeasureId
					WHERE intContractTypeId = 1 and intPricingTypeId IN (1,2) AND cd.intCommodityId  = @intCommodityId 
					AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
					)t)  AS OpenPurchasesQty
				,( select sum(dblBalance) dblBalance from (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(cd.dblBalance,0)) dblBalance
					FROM vyuCTContractDetailView cd
					JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId  AND cd.intUnitMeasureId=ium.intUnitMeasureId
					WHERE intContractTypeId = 2 and intPricingTypeId IN (1,2) AND cd.intCommodityId  = @intCommodityId 
					AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
					)t)  AS OpenSalesQty

			,(
					SELECT 
					 dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblQuantity, 0))
					FROM tblICInventoryShipment r
					INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
					INNER JOIN vyuCTContractDetailView cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND ri.intOrderId = 1
					JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId 
					WHERE cd.intCommodityId  = @intCommodityId
						AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
					) AS SlsBasisDeliveries
			FROM tblICCommodity c
			WHERE c.intCommodityId  = @intCommodityId
			) t
		) t1
	
INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,strContractEndMonth,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intFromCommodityUnitMeasureId,intCommodityId)
	SELECT @strDescription, 'Net Payable  ($)' [strType],dblUnitCost - dblQtyReceived AS dblTotal
		,intInventoryReceiptItemId,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,strContractEndMonth
			,strCustomerReference
			,strDistributionOption, 
			 dblUnitCost
			,dblQtyReceived,intUnitMeasureId,@intCommodityId			
		FROM (
			SELECT DISTINCT ri.intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,ri.dblLineTotal AS dblUnitCost
				,ch.intContractHeaderId
				,ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
				,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth
				,(
					SELECT isnull(sum(dblTotal), 0)
					FROM tblAPBillDetail apd
					WHERE apd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					) AS dblQtyReceived,cd.intUnitMeasureId				
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intPricingTypeId = 1
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1	AND strReceiptType IN ('Purchase Contract')
				AND st.intCommodityId = @intCommodityId
				AND r.intLocationId= case when isnull(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
			) AS t
					
		UNION 
		
		SELECT @strDescription, 'NP Un-Paid Quantity' [strType],dblUnitCost - dblQtyReceived AS dblTotal
			,intInventoryReceiptItemId,null as intContractHeaderId,null as strContractNumber, strLocationName,strTicketNumber,dtmTicketDateTime,'' as strContractEndMonth,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intUnitMeasureId,@intCommodityId	
		FROM (
			SELECT DISTINCT ri.intInventoryReceiptItemId,cl.strLocationName,st.strTicketNumber,st.dtmTicketDateTime,strCustomerReference
				,strDistributionOption,ri.dblLineTotal AS dblUnitCost
				,(	SELECT isnull(sum(dblTotal), 0)
					FROM tblAPBillDetail apd
					WHERE apd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
				 ) AS dblQtyReceived,st.intCommodityId,intUnitMeasureId
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1	AND strReceiptType IN ('Direct')
				AND st.intCommodityId = @intCommodityId	AND r.intLocationId= case when isnull(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
			) AS t	

		INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,strContractEndMonth,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intFromCommodityUnitMeasureId,intCommodityId
			)
		SELECT DISTINCT @strDescription, 'NP Un-Paid Quantity' [strType],dblOrderQty - dblBillQty AS dblTotal,ri.intInventoryReceiptItemId,ch.intContractHeaderId,ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber,cl.strLocationName
						,st.strTicketNumber,st.dtmTicketDateTime,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) strContractEndMonth,strCustomerReference,strDistributionOption,dblOrderQty AS dblUnitCost,
						dblBillQty AS dblQtyReceived,ri.intUnitMeasureId,@intCommodityId
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('CNT')
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
		INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intPricingTypeId = 1
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE intSourceType = 1	AND strReceiptType IN ('Purchase Contract')	AND ch.intCommodityId = @intCommodityId
			AND r.intLocationId= case when isnull(@intLocationId,0)=0 then r.intLocationId else @intLocationId end	
		

		INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
					strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intFromCommodityUnitMeasureId,intCommodityId)
		
		SELECT DISTINCT @strDescription, 'Net Payable  ($)' [strType],dblOrderQty - dblBillQty AS dblTotal,ri.intInventoryReceiptItemId,
		null as intContractHeaderId,null as strContractNumber,
		cl.strLocationName,st.strTicketNumber,st.dtmTicketDateTime,strCustomerReference,strDistributionOption
			,dblOrderQty AS dblUnitCost,dblBillQty AS dblQtyReceived,ri.intUnitMeasureId,@intCommodityId
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('SPT')
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE intSourceType = 1	AND strReceiptType IN ('Direct') AND st.intCommodityId = @intCommodityId 
		AND r.intLocationId= case when isnull(@intLocationId,0)=0 then r.intLocationId else @intLocationId end	
		
		INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,intContractHeaderId,strContractNumber,strLocationName,strTicketNumber,dtmTicketDateTime,
				strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intFromCommodityUnitMeasureId,intCommodityId
		)	
		
		SELECT @strDescription, 'Net Receivable  ($)' [strType],dblUnitCost - dblQtyReceived AS dblTotal,intInventoryReceiptItemId,intContractHeaderId,strContractNumber
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived,intUnitMeasureId,@intCommodityId			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,ch.intContractHeaderId
				,ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,(
					SELECT isnull(SUM(R.dblAmountApplied), 0)
					FROM vyuARCustomerPaymentHistoryReport R
					LEFT JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					WHERE isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
						AND R.intCompanyLocationId = @intLocationId
					) dblQtyReceived
				,st.intCommodityId,cd.intUnitMeasureId
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intPricingTypeId = 1
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (1) AND intSourceType = 1	AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end	

			) t
		
		UNION ALL
		
		SELECT @strDescription, 'Net Receivable  ($)' [strType],dblUnitCost - dblQtyReceived AS dblTotal,intInventoryReceiptItemId,intContractHeaderId,strContractNumber
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived,intUnitMeasureId,@intCommodityId
			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,null as intContractHeaderId
				,null as strContractNumber
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,st.intCommodityId
				,(
					SELECT isnull(SUM(R.dblAmountApplied), 0)
					FROM vyuARCustomerPaymentHistoryReport R
					LEFT JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					WHERE isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
						AND R.intCompanyLocationId = @intLocationId
					) dblQtyReceived,intItemUOMId as intUnitMeasureId
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
				AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (4)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end	
			) t
			
			INSERT INTO @tempFinal (strCommodityCode,strType,dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber,strTicketNumber,dtmTicketDateTime,
				strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,intFromCommodityUnitMeasureId)	

		   SELECT  @strDescription, 'NR Un-Paid Quantity' [strType],dblUnitCost - dblQtyReceived AS dblTotal,intInventoryReceiptItemId,strLocationName,intContractHeaderId,strContractNumber			
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived,intUnitMeasureId
			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,ch.intContractHeaderId
				,ch.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber
				,isi.dblQuantity AS dblUnitCost
				,(
					SELECT isnull(SUM(I.dblQtyShipped), 0)
					FROM vyuARCustomerPaymentHistoryReport R
					LEFT JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					WHERE isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
						AND R.intCompanyLocationId = case when isnull(0,0)=@intLocationId then R.intCompanyLocationId else @intLocationId end
					) dblQtyReceived,cd.intUnitMeasureId as intUnitMeasureId
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
				AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
				AND cd.intPricingTypeId = 1
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (1)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			) t
		
		UNION ALL
		
		SELECT  @strDescription, 'NR Un-Paid Quantity' [strType],dblUnitCost - dblQtyReceived AS dblTotal,intInventoryReceiptItemId,strLocationName,null as intContractHeaderId,null strContractNumber
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived,intUnitMeasureId			
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,isi.dblQuantity AS dblUnitCost
				,st.intCommodityId
				,(
					SELECT isnull(SUM(I.dblQtyShipped), 0)
					FROM vyuARCustomerPaymentHistoryReport R
					LEFT JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					WHERE isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
						AND R.intCompanyLocationId = case when isnull(0,0)=@intLocationId then R.intCompanyLocationId else @intLocationId end
					) dblQtyReceived,intItemUOMId as intUnitMeasureId
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
				AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (4)	AND intSourceType = 1 AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId= case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
			) t

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
						  JOIN tblICItemLocation il on a.intItemLocationId=il.intItemLocationId   
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
					  JOIN tblICStockReservation sr1 ON a.intItemId = sr1.intItemId   
					  JOIN tblICItem i on a.intItemId=i.intItemId  
					  JOIN tblSMCompanyLocation sl on sl.intCompanyLocationId=il.intLocationId  
					   JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
					  JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
					 WHERE il.intLocationId = case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end 
					  and i.intCommodityId= c.intCommodityId		 
					 )t) AS ReserveQty
				,(SELECT sum(Qty) FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
					FROM vyuCTContractDetailView  CD     
					JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CD.intCommodityId  
							AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=1 and intPricingTypeId in(1,2) 
					WHERE  CD.intCommodityId=c.intCommodityId and CD.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end 
				)t) AS ReceiptProductQty
				,(SELECT sum(Qty) FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
					FROM vyuCTContractDetailView  CD     
					JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CD.intCommodityId  
							AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=1 and intPricingTypeId in(1,2) 
					WHERE  CD.intCommodityId=c.intCommodityId and CD.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end )t) AS OpenPurchasesQty --req              
				,(SELECT sum(Qty) FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((CD.dblBalance),0)) as Qty                   
					FROM vyuCTContractDetailView  CD     
					JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CD.intCommodityId  
							AND CD.intUnitMeasureId=ium.intUnitMeasureId and intContractTypeId=2 and intPricingTypeId in(1,2) 
					WHERE  CD.intCommodityId=c.intCommodityId and CD.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end )t) AS OpenSalesQty
			FROM tblICCommodity c
			WHERE c.intCommodityId  = @intCommodityId
			) t
		)t1
		

DECLARE @intUnitMeasureId int
DECLARE @strUnitMeasure nvarchar(50)
SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
select @strUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
	INSERT INTO @Final (strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractEndMonth, 
		dblTotal,strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType )

	SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractEndMonth, 	
	    Convert(decimal(24,10),dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,
		case when isnull(@intUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblTotal)) dblTotal,
		@strUnitMeasure as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId and strType<>'Net Hedge' and strType <>'Cash Exposure1' and strType <>'Cash Exposure2'
	UNION
	SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractEndMonth, 
	    dblTotal dblTotal,
		@strUnitMeasure as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId and strType='Net Hedge'
	UNION
	SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, 'Cash Exposure',strContractEndMonth, 
	    dblTotal dblTotal,
		@strUnitMeasure as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId and strType ='Cash Exposure1'
	
	INSERT INTO @Final (strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, strType,strContractEndMonth, 
		dblTotal,strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType )
	
	SELECT strCommodityCode ,intContractHeaderId,strContractNumber,intFutOptTransactionHeaderId,strInternalTradeNo, 'Cash Exposure',strContractEndMonth, 
	    dblTotal dblTotal,
		@strUnitMeasure as strUnitMeasure,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType  
	FROM @tempFinal t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	LEFT JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId= @intCommodityId and strType ='Cash Exposure2'

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
UPDATE @Final set intSeqNo = 8 where strType='Cash Exposure'
UPDATE @Final set intSeqNo = 9 where strType='Basis Exposure'
UPDATE @Final set intSeqNo = 10 where strType='Net Payable  ($)'
UPDATE @Final set intSeqNo = 11 where strType='NP Un-Paid Quantity'
UPDATE @Final set intSeqNo = 12 where strType='Net Receivable  ($)'
UPDATE @Final set intSeqNo = 13 where strType='NR Un-Paid Quantity'
UPDATE @Final set intSeqNo = 14 where strType='Avail for Spot Sale'


SELECT intSeqNo,intRow, strCommodityCode ,intContractHeaderId,strContractNumber,strInternalTradeNo,intFutOptTransactionHeaderId, strType,strContractEndMonth,dblTotal,strUnitMeasure 
			,intInventoryReceiptItemId,strLocationName,strTicketNumber,dtmTicketDateTime,strCustomerReference,strDistributionOption,dblUnitCost,dblQtyReceived,strAccountNumber,strTranType,dblNoOfLot,dblDelta,intBrokerageAccountId,strInstrumentType 			
FROM @Final
 ORDER BY intSeqNo ASC
