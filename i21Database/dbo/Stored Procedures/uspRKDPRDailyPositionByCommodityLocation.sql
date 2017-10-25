CREATE PROC [dbo].[uspRKDPRDailyPositionByCommodityLocation]
	 @intCommodityId NVARCHAR(max) = ''
	,@intVendorId INT = NULL
AS
DECLARE @Commodity AS TABLE (
	intCommodityIdentity INT IDENTITY(1, 1) PRIMARY KEY
	,intCommodity INT
	)

INSERT INTO @Commodity (intCommodity)
SELECT Item Collate Latin1_General_CI_AS
FROM [dbo].[fnSplitString](@intCommodityId, ',')

SELECT strLocationName
	,OpenPurchasesQty
	,OpenSalesQty
	,intCommodityId
	,strCommodityCode
	,intUnitMeasureId
	,strUnitMeasure
	,isnull(CompanyTitled, 0) AS dblCompanyTitled
	,isnull(CashExposure, 0) AS dblCaseExposure
	,isnull(DeltaOption, 0) DeltaOption
	,(isnull(CompanyTitled, 0) + (isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0))) AS dblBasisExposure
	,(isnull(CompanyTitled, 0) + (isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0))) - isnull(ReceiptProductQty, 0) AS dblAvailForSale
	,isnull(InHouse, 0) AS dblInHouse
	,intLocationId
INTO #temp
FROM (
	SELECT strLocationName
		,intCommodityId
		,strCommodityCode
		,strUnitMeasure
		,intUnitMeasureId
		,intLocationId
		,isnull(invQty, 0) + CASE WHEN (
					SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled
					FROM tblRKCompanyPreference
					) = 1 THEN isnull(OffSite, 0) ELSE 0 END + CASE WHEN (
					SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled
					FROM tblRKCompanyPreference
					) = 1 THEN 0 ELSE -isnull(DP, 0)  END + (isnull(dblCollatralPurchase, 0) - isnull(dblCollatralSales, 0)) + isnull(SlsBasisDeliveries, 0) AS CompanyTitled
		,(isnull(invQty, 0) - isnull(PurBasisDelivary, 0)) + (isnull(OpenPurQty, 0) - isnull(OpenSalQty, 0)) + isnull(dblCollatralSales, 0) + isnull(SlsBasisDeliveries, 0)
		+CASE WHEN (
					SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled
					FROM tblRKCompanyPreference
					) = 1 THEN isnull(DP, 0) ELSE 0  END
		 AS CashExposure
		,(isnull(intOpenContract, 0)) + isnull(DeltaOption, 0) DeltaOption
		,isnull(ReceiptProductQty, 0) ReceiptProductQty
		,isnull(OpenPurchasesQty, 0) OpenPurchasesQty
		,isnull(OpenSalesQty, 0) OpenSalesQty
		,isnull(OpenPurQty, 0) OpenPurQty
		,CASE WHEN isnull(@intVendorId, 0) = 0 THEN isnull(invQty, 0) + isnull(dblGrainBalance, 0) + isnull(OnHold, 0) --+ isnull(DP ,0)
			ELSE isnull(CASE WHEN (
								SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled
								FROM tblRKCompanyPreference
								) = 1 THEN isnull(DPCustomer, 0) ELSE 0 END, 0) + isnull(OnHold, 0) END AS InHouse
	FROM (
		SELECT DISTINCT c.intCommodityId
			,strLocationName
			,intLocationId
			,strCommodityCode
			,u.intUnitMeasureId
			,u.strUnitMeasure
			,(
				SELECT sum(Qty)
				FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((CD.dblBalance), 0)) AS Qty
					FROM tblCTContractDetail CD
					JOIN tblCTContractHeader ch ON ch.intContractHeaderId = CD.intContractHeaderId
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = ch.intCommodityId AND CD.intContractStatusId <> 3 AND CD.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 1 AND CD.intPricingTypeId IN (1, 3)
					WHERE ch.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = CD.intCompanyLocationId
					) t
				) AS OpenPurQty
			,(
				SELECT sum(Qty)
				FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((CD.dblBalance), 0)) AS Qty
					FROM tblCTContractDetail CD
					JOIN tblCTContractHeader ch ON ch.intContractHeaderId = CD.intContractHeaderId
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = ch.intCommodityId AND CD.intContractStatusId <> 3 AND CD.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 2 AND CD.intPricingTypeId IN (1, 3)
					WHERE ch.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = CD.intCompanyLocationId
					) t
				) AS OpenSalQty
			,(
				SELECT sum(Qty)
				FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((CD.dblBalance), 0)) AS Qty
					FROM tblCTContractDetail CD
					JOIN tblCTContractHeader ch ON ch.intContractHeaderId = CD.intContractHeaderId
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = ch.intCommodityId AND CD.intContractStatusId <> 3 AND CD.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 1 AND CD.intPricingTypeId IN (1, 2)
					WHERE ch.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = CD.intCompanyLocationId
					) t
				) AS ReceiptProductQty
			,(
				SELECT sum(Qty)
				FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((CD.dblBalance), 0)) AS Qty
					FROM tblCTContractDetail CD
					JOIN tblCTContractHeader ch ON ch.intContractHeaderId = CD.intContractHeaderId
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = ch.intCommodityId AND CD.intContractStatusId <> 3 AND CD.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 1 AND CD.intPricingTypeId IN (1, 2)
					WHERE ch.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = CD.intCompanyLocationId
					) t
				) AS OpenPurchasesQty
			,(
				SELECT sum(Qty)
				FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((CD.dblBalance), 0)) AS Qty
					FROM tblCTContractDetail CD
					JOIN tblCTContractHeader ch ON ch.intContractHeaderId = CD.intContractHeaderId
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = ch.intCommodityId AND CD.intContractStatusId <> 3 AND CD.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 2 AND CD.intPricingTypeId IN (1, 2)
					WHERE ch.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = CD.intCompanyLocationId
					) t
				) AS OpenSalesQty
			,(
				SELECT sum(intOpenContract)
				FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, intOpenContract * dblContractSize) AS intOpenContract
					FROM vyuRKGetOpenContract otr
					JOIN tblRKFutOptTransaction t ON otr.intFutOptTransactionId = t.intFutOptTransactionId
					JOIN tblRKFutureMarket m ON t.intFutureMarketId = m.intFutureMarketId
					JOIN tblICCommodityUnitMeasure cuc1 ON t.intCommodityId = cuc1.intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
					WHERE t.intCommodityId = c.intCommodityId AND t.intLocationId = cl.intCompanyLocationId
					) t
				) intOpenContract
			,(
				SELECT SUM(ISNULL(Qty, 0)) Qty
				FROM (
					SELECT s.dblOnHand AS Qty
					FROM vyuICGetItemStockUOM s
					-- JOIN tblICItemUOM iuom on s.intItemUOMId=iuom.intItemUOMId and s.intItemId=iuom.intItemId and s.ysnStockUnit=1 and s.dblOnHand>0 
					--JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = s.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
					WHERE s.intLocationId = cl.intCompanyLocationId AND s.intCommodityId = c.intCommodityId 	
					) t
				) AS invQty
			,isnull((
					SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
					FROM (
						SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((SUM(dblAdjustmentAmount)), 0)) dblAdjustmentAmount
							,intContractHeaderId
							,dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((SUM(dblOriginalQuantity)), 0)) dblOriginalQuantity
						FROM tblRKCollateral c1
						LEFT JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId
						JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = c1.intCommodityId AND c1.intUnitMeasureId = ium.intUnitMeasureId
						WHERE strType = 'Sale' AND c1.intCommodityId = c.intCommodityId AND c1.intLocationId = cl.intCompanyLocationId
						GROUP BY intContractHeaderId
							,ium.intCommodityUnitMeasureId
						) t
					WHERE dblAdjustmentAmount <> dblOriginalQuantity
					), 0) AS dblCollatralSales
			,isnull((
					SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) CollateralSale
					FROM (
						SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((SUM(dblAdjustmentAmount)), 0)) dblAdjustmentAmount
							,intContractHeaderId
							,dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((SUM(dblOriginalQuantity)), 0)) dblOriginalQuantity
						FROM tblRKCollateral c1
						LEFT JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId
						JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = c1.intCommodityId AND c1.intUnitMeasureId = ium.intUnitMeasureId
						WHERE strType = 'Purchase' AND c1.intCommodityId = c.intCommodityId AND c1.intLocationId = cl.intCompanyLocationId
						GROUP BY intContractHeaderId
							,ium.intCommodityUnitMeasureId
						) t
					WHERE dblAdjustmentAmount <> dblOriginalQuantity
					), 0) AS dblCollatralPurchase
			,(
				SELECT sum(SlsBasisDeliveries)
				FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((ri.dblQuantity), 0)) AS SlsBasisDeliveries
					FROM tblICInventoryShipment r
					INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
					INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND ri.intOrderId = 1 AND cd.intContractStatusId <> 3
					INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = ch.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId
					WHERE ch.intCommodityId = c.intCommodityId AND cd.intCompanyLocationId = cl.intCompanyLocationId ) t
				) AS SlsBasisDeliveries
			,(
				SELECT Sum(dblTotal)
				FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal
					FROM vyuGRGetStorageDetail CH
					WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company' AND CH.intCommodityId = c.intCommodityId AND CH.intCompanyLocationId = cl.intCompanyLocationId 
					) t
				) AS OffSite
			,(
				SELECT Sum(dblTotal)
				FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal
					FROM vyuGRGetStorageDetail CH
					WHERE CH.intCommodityId = c.intCommodityId AND ysnDPOwnedType = 1 AND CH.intCompanyLocationId = cl.intCompanyLocationId AND intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN intEntityId ELSE @intVendorId END 
					) t
				) AS DP
			,(
				SELECT Sum(dblTotal)
				FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal
					FROM vyuGRGetStorageDetail CH
					WHERE CH.intCommodityId = c.intCommodityId AND CH.intCompanyLocationId = cl.intCompanyLocationId AND strOwnedPhysicalStock = 'Customer' AND intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN intEntityId ELSE @intVendorId END 
					) t
				) AS DPCustomer
			,(
				SELECT Sum(dblTotal)
				FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal
					FROM vyuGRGetStorageDetail CH
					WHERE CH.intCommodityId = c.intCommodityId AND CH.intCompanyLocationId = cl.intCompanyLocationId AND intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN intEntityId ELSE @intVendorId END 
					) t
				) AS dblGrainBalance
			,(
				SELECT sum(isnull(dblNoOfContract, 0)) dblNoOfContract
				FROM (
					SELECT (
							CASE WHEN ft.strBuySell = 'Buy' THEN (
											ft.intNoOfContract - isnull((
													SELECT sum(intMatchQty)
													FROM tblRKOptionsMatchPnS l
													WHERE l.intLFutOptTransactionId = ft.intFutOptTransactionId
													), 0)
											) ELSE - (
										ft.intNoOfContract - isnull((
												SELECT sum(intMatchQty)
												FROM tblRKOptionsMatchPnS s
												WHERE s.intSFutOptTransactionId = ft.intFutOptTransactionId
												), 0)
										) END * isnull((
									SELECT TOP 1 dblDelta
									FROM tblRKFuturesSettlementPrice sp
									INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
									WHERE intFutureMarketId = ft.intFutureMarketId AND mm.intOptionMonthId = ft.intOptionMonthId AND mm.intTypeId = CASE WHEN ft.strOptionType = 'Put' THEN 1 ELSE 2 END AND ft.dblStrike = mm.dblStrike
									ORDER BY dtmPriceDate DESC
									), 0)
							) * m.dblContractSize AS dblNoOfContract
					FROM tblRKFutOptTransaction ft
					INNER JOIN tblRKFutureMarket m ON ft.intFutureMarketId = m.intFutureMarketId AND ft.intLocationId = cl.intCompanyLocationId AND intInstrumentTypeId = 2
					INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
					WHERE ft.intCommodityId = ft.intCommodityId AND intFutOptTransactionId NOT IN (
							SELECT intFutOptTransactionId
							FROM tblRKOptionsPnSExercisedAssigned
							) AND intFutOptTransactionId NOT IN (
							SELECT intFutOptTransactionId
							FROM tblRKOptionsPnSExpired
							)
					) t
				) DeltaOption
			,(
				SELECT sum(dblTotal) dblTotal
				FROM (
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((PLDetail.dblLotPickedQty), 0)) AS dblTotal
					FROM tblLGDeliveryPickDetail Del
					INNER JOIN tblLGPickLotDetail PLDetail ON PLDetail.intPickLotDetailId = Del.intPickLotDetailId
					INNER JOIN vyuLGPickOpenInventoryLots Lots ON Lots.intLotId = PLDetail.intLotId
					INNER JOIN tblCTContractDetail CT ON CT.intContractDetailId = Lots.intContractDetailId AND CT.intContractStatusId <> 3
					INNER JOIN tblCTContractHeader ch ON CT.intContractHeaderId = ch.intContractHeaderId
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = ch.intCommodityId AND CT.intUnitMeasureId = ium.intUnitMeasureId
					INNER JOIN tblSMCompanyLocation cl1 ON cl1.intCompanyLocationId = CT.intCompanyLocationId
					WHERE CT.intPricingTypeId = 2 AND ch.intCommodityId = c.intCommodityId AND cl1.intCompanyLocationId = cl.intCompanyLocationId
					
					UNION
					
					SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(ri.dblReceived, 0)) AS dblTotal
					FROM tblICInventoryReceipt r
					INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
					INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('CNT')
					INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3
					INNER JOIN tblCTContractHeader ch ON cd.intContractHeaderId = ch.intContractHeaderId
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = ch.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId
					INNER JOIN tblSMCompanyLocation cl1 ON cl1.intCompanyLocationId = st.intProcessingLocationId
					WHERE ch.intCommodityId = c.intCommodityId AND cl1.intCompanyLocationId = cl.intCompanyLocationId 
					) t
				) AS PurBasisDelivary
			,(
				SELECT sum(dblTotal)
				FROM (
					(
						SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(st.dblNetUnits, 0)) AS dblTotal
						FROM tblSCTicket st
						JOIN tblICItem i1 ON i1.intItemId = st.intItemId AND st.strDistributionOption = 'HLD'
						JOIN tblICItemUOM iuom ON i1.intItemId = iuom.intItemId AND ysnStockUnit = 1
						JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i1.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
						WHERE st.intCommodityId = c.intCommodityId AND st.intProcessingLocationId = cl.intCompanyLocationId AND st.intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN st.intEntityId ELSE @intVendorId END
						)
					) t
				) AS OnHold
		FROM tblSMCompanyLocation cl
		JOIN tblICItemLocation lo ON lo.intLocationId = cl.intCompanyLocationId 
		JOIN tblICItem i ON lo.intItemId = i.intItemId
		JOIN tblICCommodity c ON c.intCommodityId = i.intCommodityId
		LEFT JOIN tblICCommodityUnitMeasure um ON c.intCommodityId = um.intCommodityId
		LEFT JOIN tblICUnitMeasure u ON um.intUnitMeasureId = u.intUnitMeasureId
		WHERE ysnDefault = 1
		GROUP BY c.intCommodityId
			,strCommodityCode
			,cl.intCompanyLocationId
			,cl.strLocationName
			,intLocationId
			,u.intUnitMeasureId
			,u.strUnitMeasure
			,um.intCommodityUnitMeasureId
		) t
	) t1

DECLARE @intUnitMeasureId INT
DECLARE @strUnitMeasure NVARCHAR(50)

SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId
FROM tblRKCompanyPreference

IF isnull(@intVendorId, 0) = 0
BEGIN
	SELECT @strUnitMeasure = strUnitMeasure
	FROM tblICUnitMeasure
	WHERE intUnitMeasureId = @intUnitMeasureId

	SELECT DISTINCT convert(INT, row_number() OVER (
				ORDER BY t.intCommodityId
					,intLocationId
				)) intRowNum
		,t.strLocationName
		,intLocationId
		,t.intCommodityId
		,strCommodityCode
		,CASE WHEN isnull(@strUnitMeasure, '') = '' THEN um.strUnitMeasure ELSE @strUnitMeasure END AS strUnitMeasure
		,isnull(Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, CASE WHEN isnull(@intUnitMeasureId, 0) = 0 THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END, OpenPurchasesQty)), 0) OpenPurchasesQty
		,isnull(Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, CASE WHEN isnull(@intUnitMeasureId, 0) = 0 THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END, OpenSalesQty)), 0) OpenSalesQty
		,isnull(Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, CASE WHEN isnull(@intUnitMeasureId, 0) = 0 THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END, dblCompanyTitled)), 0) dblCompanyTitled
		,isnull(Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, CASE WHEN isnull(@intUnitMeasureId, 0) = 0 THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END, isnull(dblCaseExposure + DeltaOption, 0))), 0) dblCaseExposure
		,isnull(Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, CASE WHEN isnull(@intUnitMeasureId, 0) = 0 THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END, dblBasisExposure)), 0) OpenSalQty
		,isnull(Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, CASE WHEN isnull(@intUnitMeasureId, 0) = 0 THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END, dblAvailForSale)), 0) dblAvailForSale
		,isnull(Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, CASE WHEN isnull(@intUnitMeasureId, 0) = 0 THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END, dblInHouse)), 0) dblInHouse
		,isnull(Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, CASE WHEN isnull(@intUnitMeasureId, 0) = 0 THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END, dblBasisExposure)), 0) dblBasisExposure
	FROM #temp t
	JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 ON t.intCommodityId = cuc1.intCommodityId AND @intUnitMeasureId = cuc1.intUnitMeasureId
	WHERE t.intCommodityId IN (
			SELECT Item Collate Latin1_General_CI_AS
			FROM [dbo].[fnSplitString](@intCommodityId, ',')
			)
	ORDER BY strCommodityCode
END
ELSE
BEGIN
	SELECT @strUnitMeasure = strUnitMeasure
	FROM tblICUnitMeasure
	WHERE intUnitMeasureId = @intUnitMeasureId

	SELECT DISTINCT convert(INT, row_number() OVER (
				ORDER BY t.intCommodityId
					,intLocationId
				)) intRowNum
		,t.strLocationName
		,intLocationId
		,t.intCommodityId
		,strCommodityCode
		,CASE WHEN isnull(@strUnitMeasure, '') = '' THEN um.strUnitMeasure ELSE @strUnitMeasure END AS strUnitMeasure
		,0.00 OpenPurchasesQty
		,0.00 OpenSalesQty
		,0.00 dblCompanyTitled
		,0.00 dblCaseExposure
		,0.00 OpenSalQty
		,0.00 dblAvailForSale
		,isnull(Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, CASE WHEN isnull(@intUnitMeasureId, 0) = 0 THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END, dblInHouse)), 0) dblInHouse
		,0.00 dblBasisExposure
	FROM #temp t
	JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
	LEFT JOIN tblICCommodityUnitMeasure cuc1 ON t.intCommodityId = cuc1.intCommodityId AND @intUnitMeasureId = cuc1.intUnitMeasureId
	WHERE t.intCommodityId IN (
			SELECT Item Collate Latin1_General_CI_AS
			FROM [dbo].[fnSplitString](@intCommodityId, ',')
			)
	ORDER BY strCommodityCode
END
