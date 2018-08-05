CREATE PROC [dbo].[uspRKDPRDailyPositionByCommodityLocation]
	 @intCommodityId NVARCHAR(max) = ''
	,@intVendorId INT = NULL
	,@strPositionIncludes NVARCHAR(100) = NULL
AS

DECLARE @Commodity AS TABLE (
	intCommodityIdentity INT IDENTITY(1, 1) PRIMARY KEY
	,intCommodity INT
	)
DECLARE @tblGetOpenContractDetail TABLE (
	strCommodityCode NVARCHAR(100)
	,intCommodityId INT
	,intContractHeaderId INT
	,strContractNumber NVARCHAR(100)
	,strLocationName NVARCHAR(100)
	,dtmEndDate DATETIME
	,dblBalance NUMERIC(18, 6)
	,intUnitMeasureId INT
	,intPricingTypeId INT
	,intContractTypeId INT
	,intCompanyLocationId INT
	,strContractType NVARCHAR(100)
	,strPricingType NVARCHAR(100)
	,intCommodityUnitMeasureId INT
	,intContractDetailId INT
	,intContractStatusId INT
	,intEntityId INT
	,intCurrencyId INT
	,strType NVARCHAR(100)
	)
INSERT INTO @tblGetOpenContractDetail (
	strCommodityCode
	,intCommodityId
	,intContractHeaderId
	,strContractNumber
	,strLocationName
	,dtmEndDate
	,dblBalance
	,intUnitMeasureId
	,intPricingTypeId
	,intContractTypeId
	,intCompanyLocationId
	,strContractType
	,strPricingType
	,intCommodityUnitMeasureId
	,intContractDetailId
	,intContractStatusId
	,intEntityId
	,intCurrencyId
	,strType
	)
SELECT strCommodityCode
	,intCommodityId
	,intContractHeaderId
	,strContractNumber
	,strLocationName
	,dtmEndDate
	,dblBalance
	,intUnitMeasureId
	,intPricingTypeId
	,intContractTypeId
	,intCompanyLocationId
	,strContractType
	,strPricingType
	,intCommodityUnitMeasureId
	,intContractDetailId
	,intContractStatusId
	,intEntityId
	,intCurrencyId
	,strType
FROM vyuRKContractDetail

SELECT DISTINCT c.intCommodityId
	,strLocationName
	,intLocationId
	,strCommodityCode
	,u.intUnitMeasureId
	,u.strUnitMeasure
	,(
		SELECT sum(Qty)
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((cd.dblBalance), 0)) AS Qty
			FROM @tblGetOpenContractDetail cd
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intContractStatusId <> 3 
			AND cd.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 1 AND cd.intPricingTypeId IN (1, 3)
			WHERE cd.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = cd.intCompanyLocationId
			) t
		) AS OpenPurQty
	,(
		SELECT sum(Qty)
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((CD.dblBalance), 0)) AS Qty
			FROM @tblGetOpenContractDetail CD
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = CD.intCommodityId AND CD.intContractStatusId <> 3 
			AND CD.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 2 AND CD.intPricingTypeId IN (1, 3)
			WHERE CD.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = CD.intCompanyLocationId
			) t
		) AS OpenSalQty
	,(
		SELECT sum(Qty)
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((CD.dblBalance), 0)) AS Qty
			FROM @tblGetOpenContractDetail CD
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = CD.intCommodityId AND CD.intContractStatusId <> 3 AND CD.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 1 AND CD.intPricingTypeId IN (1, 2)
			WHERE CD.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = CD.intCompanyLocationId
			) t
		) AS ReceiptProductQty
	,(
		SELECT sum(Qty)
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((CD.dblBalance), 0)) AS Qty
			FROM @tblGetOpenContractDetail CD
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = CD.intCommodityId AND CD.intContractStatusId <> 3 AND CD.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 1 AND CD.intPricingTypeId IN (1, 2)
			WHERE CD.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = CD.intCompanyLocationId
			) t
		) AS OpenPurchasesQty
	,(
		SELECT sum(Qty)
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((CD.dblBalance), 0)) AS Qty
			FROM @tblGetOpenContractDetail CD
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = CD.intCommodityId AND CD.intContractStatusId <> 3 AND CD.intUnitMeasureId = ium.intUnitMeasureId AND intContractTypeId = 2 AND CD.intPricingTypeId IN (1, 2)
			WHERE CD.intCommodityId = c.intCommodityId AND cl.intCompanyLocationId = CD.intCompanyLocationId
			) t
		) AS OpenSalesQty
	,(
		 select  sum(Qty) from(
		SELECT (dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,isnull(s.dblOnHand,0))) AS Qty
		FROM vyuICGetItemStockUOM s
		JOIN tblICItemUOM iuom on s.intItemId=iuom.intItemId and iuom.ysnStockUnit=1
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=s.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId   
		WHERE s.intLocationId = cl.intCompanyLocationId AND s.intCommodityId = c.intCommodityId AND iuom.ysnStockUnit = 1 AND ISNULL(dblOnHand,0) <>0
		) t)AS invQty
	,isnull((
			SELECT isnull(SUM(dblRemainingQuantity), 0) CollateralSale
			FROM (
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull((SUM(dblRemainingQuantity)), 0)) dblRemainingQuantity
					,intContractHeaderId
				FROM tblRKCollateral c2
				LEFT JOIN tblRKCollateralAdjustment ca ON c2.intCollateralId = ca.intCollateralId
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = c2.intCommodityId AND c2.intUnitMeasureId = ium.intUnitMeasureId
				WHERE strType = 'Sales' AND c2.intCommodityId = c.intCommodityId AND c2.intLocationId = cl.intCompanyLocationId
				GROUP BY intContractHeaderId
					,ium.intCommodityUnitMeasureId
				) t
			), 0) AS dblCollatralSales
	,isnull((
			SELECT isnull(SUM(dblRemainingQuantity), 0) CollateralSale
			FROM (
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(dblRemainingQuantity, 0)) dblRemainingQuantity
					,intContractHeaderId
				FROM tblRKCollateral c2
				LEFT JOIN tblRKCollateralAdjustment ca ON c2.intCollateralId = ca.intCollateralId
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = c2.intCommodityId AND c2.intUnitMeasureId = ium.intUnitMeasureId
				WHERE strType = 'Purchase' AND c2.intCommodityId = c.intCommodityId AND c2.intLocationId = cl.intCompanyLocationId
				) t
			), 0) AS dblCollatralPurchase
	,(
		SELECT sum(SlsBasisDeliveries)
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(ri.dblQuantity, 0)) AS SlsBasisDeliveries
			FROM tblICInventoryShipment r
			INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
			INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3 AND cd.intContractTypeId = 2
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId
			WHERE cd.intCommodityId = c.intCommodityId AND cd.intCompanyLocationId = cl.intCompanyLocationId
			) t
		) AS SlsBasisDeliveries
	,(
		SELECT Sum(dblTotal)
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(s.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal
			FROM vyuGRGetStorageDetail s
			WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company' AND s.intCommodityId = c.intCommodityId AND s.intCompanyLocationId = cl.intCompanyLocationId
			) t
		) AS OffSite
	,(
		SELECT Sum(dblTotal)
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(s.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal
			FROM vyuGRGetStorageDetail s
			WHERE s.intCommodityId = c.intCommodityId AND ysnDPOwnedType = 1 AND s.intCompanyLocationId = cl.intCompanyLocationId AND intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN intEntityId ELSE @intVendorId END
			) t
		) AS DP
	,(
		SELECT Sum(dblTotal)
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(s.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal
			FROM vyuGRGetStorageDetail s
			WHERE s.intCommodityId = c.intCommodityId AND s.intCompanyLocationId = cl.intCompanyLocationId AND strOwnedPhysicalStock = 'Customer' AND intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN intEntityId ELSE @intVendorId END
			
			UNION ALL
			SELECT SUM(dblTotal)  dblTotal from(
			SELECT distinct   GR1.intCustomerStorageId,E.intEntityId, dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId,GR1.dblOpenBalance) dblTotal
			FROM tblSCDeliverySheet SCD 
			INNER JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId 
			INNER JOIN tblGRCustomerStorage GR1 on SCD.intDeliverySheetId = GR1.intDeliverySheetId
			INNER JOIN tblSCDeliverySheetSplit SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId and GR1.intEntityId=SCDS.intEntityId
			INNER JOIN tblICItem i on i.intItemId=SCT.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation l on SCT.intProcessingLocationId=l.intCompanyLocationId
			INNER JOIN tblEMEntity E on E.intEntityId=SCDS.intEntityId
			LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId 				
			WHERE
			 isnull(GR.intStorageScheduleTypeId,0) > 0 and isnull(SCD.ysnPost,0) =1  and SCT.strTicketStatus <> 'V' and 
			 SCT.strTicketStatus = 'H' AND isnull(SCT.intDeliverySheetId, 0) <> 0 AND SCT.intCommodityId = c.intCommodityId 
			 AND l.intCompanyLocationId = cl.intCompanyLocationId AND strOwnedPhysicalStock = 'Customer' AND E.intEntityId = CASE WHEN isnull(@intVendorId, 0) = 0 THEN E.intEntityId ELSE @intVendorId END
			 ) t where dblTotal >0 
			 UNION ALL
			 SELECT SUM(dblTotal)  dblTotal from(
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, ((SCT.dblNetUnits * SCDS.dblSplitPercent) / 100)) dblTotal
			FROM tblSCDeliverySheet SCD
			INNER JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId AND SCT.ysnDeliverySheetPost = 0
			INNER JOIN tblSCDeliverySheetSplit SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
			INNER JOIN tblICItem i ON i.intItemId = SCT.intItemId
			JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
			INNER JOIN tblSMCompanyLocation l ON SCT.intProcessingLocationId = l.intCompanyLocationId
			INNER JOIN tblEMEntity E ON E.intEntityId = SCDS.intEntityId
			LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId 
			WHERE SCT.strTicketStatus = 'H' AND isnull(SCT.intDeliverySheetId, 0) <> 0 AND SCT.intCommodityId = c.intCommodityId AND l.intCompanyLocationId = cl.intCompanyLocationId 
			AND strOwnedPhysicalStock = 'Customer' AND E.intEntityId = CASE WHEN isnull(@intVendorId, 0) = 0 THEN E.intEntityId ELSE @intVendorId END
			and isnull(SCD.ysnPost,0) =0 AND GR.intStorageScheduleTypeId > 0  and SCT.strTicketStatus <> 'V'
			) t where dblTotal >0 
			)t1
		) AS DPCustomer
	,(
		SELECT Sum(dblTotal)
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(s.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(Balance, 0)) dblTotal
			FROM vyuGRGetStorageDetail s
			WHERE s.intCommodityId = c.intCommodityId AND s.intCompanyLocationId = cl.intCompanyLocationId AND intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN intEntityId ELSE @intVendorId END
			
			UNION ALL
			
			SELECT SUM(dblTotal)  dblTotal from(
			SELECT distinct   GR1.intCustomerStorageId,E.intEntityId, dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId,GR1.dblOpenBalance) dblTotal
			FROM tblSCDeliverySheet SCD 
			INNER JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId 
			INNER JOIN tblGRCustomerStorage GR1 on SCD.intDeliverySheetId = GR1.intDeliverySheetId
			INNER JOIN tblSCDeliverySheetSplit SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId and GR1.intEntityId=SCDS.intEntityId
			INNER JOIN tblICItem i on i.intItemId=SCT.intItemId
			JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
			INNER JOIN tblSMCompanyLocation l on SCT.intProcessingLocationId=l.intCompanyLocationId
			INNER JOIN tblEMEntity E on E.intEntityId=SCDS.intEntityId
			LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId 				
			WHERE
			 isnull(GR.intStorageScheduleTypeId,0) > 0 and isnull(SCD.ysnPost,0) =1 and 
			 SCT.strTicketStatus = 'H' AND isnull(SCT.intDeliverySheetId, 0) <> 0 AND SCT.intCommodityId = c.intCommodityId 
			 AND l.intCompanyLocationId = cl.intCompanyLocationId  AND E.intEntityId = CASE WHEN isnull(@intVendorId, 0) = 0 THEN E.intEntityId ELSE @intVendorId END
			  and SCT.strTicketStatus <> 'V'
			 ) t where dblTotal >0 
			 UNION ALL
			 SELECT SUM(dblTotal)  dblTotal from(
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, ((SCT.dblNetUnits * SCDS.dblSplitPercent) / 100)) dblTotal
			FROM tblSCDeliverySheet SCD
			INNER JOIN tblSCTicket SCT ON SCD.intDeliverySheetId = SCT.intDeliverySheetId AND SCT.ysnDeliverySheetPost = 0
			INNER JOIN tblSCDeliverySheetSplit SCDS ON SCDS.intDeliverySheetId = SCD.intDeliverySheetId
			INNER JOIN tblICItem i ON i.intItemId = SCT.intItemId
			JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
			INNER JOIN tblSMCompanyLocation l ON SCT.intProcessingLocationId = l.intCompanyLocationId
			INNER JOIN tblEMEntity E ON E.intEntityId = SCDS.intEntityId
			LEFT JOIN tblGRStorageType GR ON GR.intStorageScheduleTypeId = SCDS.intStorageScheduleTypeId 
			WHERE SCT.strTicketStatus = 'H' AND isnull(SCT.intDeliverySheetId, 0) <> 0 AND SCT.intCommodityId = c.intCommodityId AND l.intCompanyLocationId = cl.intCompanyLocationId 
			 AND E.intEntityId = CASE WHEN isnull(@intVendorId, 0) = 0 THEN E.intEntityId ELSE @intVendorId END
			and isnull(SCD.ysnPost,0) =0 AND GR.intStorageScheduleTypeId > 0  and SCT.strTicketStatus <> 'V'	
			) t where dblTotal >0 
			)t1
		) AS dblGrainBalance
 ,(select sum(dblPurBasisQty) from(
				select sum(dblPurBasisQty) dblPurBasisQty,intCommodityId ,intCompanyLocationId,strContractNumber from(
				SELECT CD.intContractDetailId,dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,um.intCommodityUnitMeasureId,CASE WHEN CD.dblQuantity - ISNULL(CD.dblBalance,0) - ISNULL(FD.dblQuantity,0) > 0 THEN
				CD.dblQuantity - ISNULL(CD.dblBalance,0) - ISNULL(FD.dblQuantity,0) ELSE 0  END) dblPurBasisQty ,intCompanyLocationId,CH.intCommodityId,strContractNumber
				FROM tblCTContractDetail CD
				join tblCTContractHeader CH on CH.intContractHeaderId=CD.intContractHeaderId and intContractTypeId=1 and CD.intPricingTypeId=2
				JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=CH.intCommodityId AND CH.intCommodityUOMId=ium.intUnitMeasureId
				LEFT   JOIN	tblCTPriceFixation		    PF  ON  PF.intContractDetailId	=	CD.intContractDetailId 
				LEFT   JOIN	 (SELECT  intPriceFixationId,SUM(dblQuantity) AS  dblQuantity
								FROM	   tblCTPriceFixationDetail
								GROUP   BY  intPriceFixationId)
													FD  ON  FD.intPriceFixationId	  =	 PF.intPriceFixationId
				where CH.intCommodityId=c.intCommodityId and CD.intCompanyLocationId=cl.intCompanyLocationId  )t  group by intCommodityId ,intCompanyLocationId,strContractNumber)t1
				where dblPurBasisQty<>0 ) 
				as PurBasisDelivary
	,(
		SELECT sum(dblTotal)
		FROM (
			(
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, isnull(st.dblNetUnits, 0)) AS dblTotal
				FROM tblSCTicket st
				JOIN tblICItem i1 ON i1.intItemId = st.intItemId AND st.strDistributionOption = 'HLD'
				JOIN tblICItemUOM iuom ON i1.intItemId = iuom.intItemId AND ysnStockUnit = 1
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i1.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
				WHERE st.intCommodityId = c.intCommodityId AND st.intProcessingLocationId = cl.intCompanyLocationId AND st.intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN st.intEntityId ELSE @intVendorId END AND isnull(st.intDeliverySheetId, 0) = 0
				 and st.strTicketStatus <> 'V'
				)
			) t
		) AS OnHold
INTO #Physical
FROM tblSMCompanyLocation cl
JOIN tblICItemLocation lo ON lo.intLocationId = cl.intCompanyLocationId AND lo.intLocationId IN (
		SELECT intCompanyLocationId
		FROM tblSMCompanyLocation
		WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
		)
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

SELECT DISTINCT c.intCommodityId
	,strLocationName
	,intLocationId
	,strCommodityCode
	,u.intUnitMeasureId
	,u.strUnitMeasure
	,(
		SELECT SUM(dblNetHedge) dblNetHedge
		FROM (
			SELECT CASE WHEN ft.strBuySell = 'Buy' THEN (
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
						), 0) * m.dblContractSize AS dblNetHedge
			FROM tblRKFutOptTransaction ft
			INNER JOIN tblRKFutureMarket m ON ft.intFutureMarketId = m.intFutureMarketId AND ft.intLocationId IN (
					SELECT intCompanyLocationId
					FROM tblSMCompanyLocation
					WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
					)
			INNER JOIN tblSMCompanyLocation l ON ft.intLocationId = l.intCompanyLocationId
			INNER JOIN tblICCommodity ic ON ft.intCommodityId = ic.intCommodityId
			INNER JOIN tblRKBrokerageAccount ba ON ft.intBrokerageAccountId = ba.intBrokerageAccountId
			INNER JOIN tblEMEntity e ON e.intEntityId = ft.intEntityId AND ft.intInstrumentTypeId = 2
			INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = ft.intFutureMonthId AND fm.intFutureMarketId = ft.intFutureMarketId AND fm.ysnExpired = 0
			WHERE ft.intCommodityId = c.intCommodityId AND intLocationId = cl.intCompanyLocationId AND ft.intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN ft.intEntityId ELSE @intVendorId END AND intFutOptTransactionId NOT IN (
					SELECT intFutOptTransactionId
					FROM tblRKOptionsPnSExercisedAssigned
					) AND intFutOptTransactionId NOT IN (
					SELECT intFutOptTransactionId
					FROM tblRKOptionsPnSExpired
					)
			) t
		) dblOptionNetHedge
	,(
		SELECT sum(dblNetHedge) dblFutNetHedge
		FROM (
			SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, um.intCommodityUnitMeasureId, CASE WHEN f.strBuySell = 'Buy' THEN ISNULL(intOpenContract, 0) ELSE ISNULL(intOpenContract, 0) END * dblContractSize) AS dblNetHedge
			FROM vyuRKGetOpenContract oc
			JOIN tblRKFutOptTransaction f ON oc.intFutOptTransactionId = f.intFutOptTransactionId AND oc.intOpenContract <> 0
			INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId AND f.intLocationId IN (
					SELECT intCompanyLocationId
					FROM tblSMCompanyLocation
					WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
					)
			INNER JOIN tblICCommodity ic ON f.intCommodityId = ic.intCommodityId
			JOIN tblICCommodityUnitMeasure cuc1 ON f.intCommodityId = cuc1.intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
			INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = f.intFutureMonthId
			INNER JOIN tblSMCompanyLocation l ON f.intLocationId = l.intCompanyLocationId
			INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
			INNER JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
			WHERE ic.intCommodityId = c.intCommodityId AND f.intLocationId = cl.intCompanyLocationId AND f.intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN f.intEntityId ELSE @intVendorId END
			) t
		) dblFutNetHedge
INTO #Future
FROM tblSMCompanyLocation cl
JOIN tblRKFutOptTransaction lo ON lo.intLocationId = cl.intCompanyLocationId AND lo.intLocationId IN (
		SELECT intCompanyLocationId
		FROM tblSMCompanyLocation
		WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
		)
JOIN tblICCommodity c ON c.intCommodityId = lo.intCommodityId
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

SELECT DISTINCT ISNULL(a.intCommodityId, b.intCommodityId) intCommodityId
	,isnull(a.intLocationId, b.intLocationId) intLocationId
	,isnull(a.strCommodityCode, b.strCommodityCode) strCommodityCode
	,isnull(a.strLocationName, b.strLocationName) strLocationName
	,isnull(a.intUnitMeasureId, b.intUnitMeasureId) intUnitMeasureId
	,isnull(a.strUnitMeasure, b.strUnitMeasure) strUnitMeasure
	,a.OpenPurQty
	,a.OpenSalQty
	,a.ReceiptProductQty
	,a.OpenPurchasesQty
	,a.OpenSalesQty
	,invQty
	,dblCollatralSales
	,dblCollatralPurchase
	,SlsBasisDeliveries
	,OffSite
	,DP
	,DPCustomer
	,dblGrainBalance
	,PurBasisDelivary
	,OnHold
	,b.dblFutNetHedge
	,b.dblOptionNetHedge
INTO #TempContractFutByLocation
FROM #Physical a
FULL JOIN #Future b ON a.intLocationId = b.intLocationId AND a.intCommodityId = b.intCommodityId

SELECT strLocationName
	,OpenPurchasesQty
	,OpenSalesQty
	,intCommodityId
	,strCommodityCode
	,intUnitMeasureId
	,strUnitMeasure
	,isnull(CompanyTitled, 0) - (isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0)) AS dblCompanyTitled
	,isnull(CashExposure, 0) AS dblCaseExposure
	,isnull(CompanyTitled, 0) AS dblBasisExposure
	,isnull(CompanyTitled, 0) - isnull(ReceiptProductQty, 0) AS dblAvailForSale
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
					) = 1 THEN 0 ELSE - isnull(DP, 0) END + (isnull(dblCollatralPurchase, 0) - isnull(dblCollatralSales, 0)) + isnull(SlsBasisDeliveries, 0) + (isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0)) AS CompanyTitled
		,isnull(invQty, 0) - isnull(PurBasisDelivary, 0) + (isnull(OpenPurQty, 0) - isnull(OpenSalQty, 0)) + isnull(dblCollatralSales, 0) + isnull(SlsBasisDeliveries, 0) + CASE WHEN (
					SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled
					FROM tblRKCompanyPreference
					) = 1 THEN 0 ELSE - isnull(DP, 0) END + isnull(dblOptionNetHedge, 0) + isnull(dblFutNetHedge, 0) AS CashExposure
		,isnull(ReceiptProductQty, 0) ReceiptProductQty
		,isnull(OpenPurchasesQty, 0) OpenPurchasesQty
		,isnull(OpenSalesQty, 0) OpenSalesQty
		,isnull(OpenPurQty, 0) OpenPurQty
		,CASE WHEN isnull(@intVendorId, 0) = 0 THEN 
		isnull(invQty, 0) + isnull(dblGrainBalance, 0) + isnull(OnHold, 0) 
			ELSE isnull(DPCustomer, 0) + isnull(OnHold, 0) END AS InHouse
	FROM (
		SELECT *
		FROM #TempContractFutByLocation
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
		,CASE WHEN isnull(@strUnitMeasure, '') = '' THEN t.strUnitMeasure ELSE @strUnitMeasure END AS strUnitMeasure		
		,CASE WHEN ((isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN OpenPurchasesQty else
			Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId , OpenPurchasesQty)) end OpenPurchasesQty
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN OpenSalesQty else
			Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId , OpenSalesQty)) end OpenSalesQty
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblCompanyTitled else
			Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId , dblCompanyTitled)) end dblCompanyTitled
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblCaseExposure ELSE
			Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId , dblCaseExposure)) end dblCaseExposure
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblBasisExposure ELSE
			Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId , dblBasisExposure)) end OpenSalQty
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblAvailForSale else
		 Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId , dblAvailForSale)) end dblAvailForSale
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblInHouse else
			Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId , dblInHouse))end dblInHouse
		,CASE WHEN (isnull(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblBasisExposure else
			Convert(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId , dblBasisExposure)) end dblBasisExposure
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