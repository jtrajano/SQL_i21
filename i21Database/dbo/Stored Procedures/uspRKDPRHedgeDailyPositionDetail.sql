CREATE PROCEDURE [dbo].[uspRKDPRHedgeDailyPositionDetail] 
	 @intCommodityId INT
	,@intLocationId INT = NULL
AS
IF ISNULL(@intLocationId, 0) <> 0
BEGIN
	SELECT 1 AS intSeqId
		,'Purchases Priced' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 1
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (1)
	WHERE CH.intCommodityId = @intCommodityId
		AND CD.intCompanyLocationId = @intLocationId
	
	UNION ALL
	
	SELECT 2 AS intSeqId
		,'Purchases Basis' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 1
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (2)
	WHERE CH.intCommodityId = @intCommodityId
		AND CD.intCompanyLocationId = @intLocationId
	
	UNION ALL
	
	SELECT 3 AS intSeqId
		,'Purchases HTA' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 1
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (3)
	WHERE CH.intCommodityId = @intCommodityId
		AND CD.intCompanyLocationId = @intLocationId
	
	UNION ALL
	
	SELECT 4 AS intSeqId
		,'Sales Priced' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 2
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (1)
	WHERE CH.intCommodityId = @intCommodityId
		AND CD.intCompanyLocationId = @intLocationId
	
	UNION ALL
	
	SELECT 5 AS intSeqId
		,'Sales Basis' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 2
	LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
	WHERE ISNULL(PT.intPricingTypeId, 0) = 2
		AND CH.intCommodityId = @intCommodityId
		AND CD.intCompanyLocationId = @intLocationId
	
	UNION ALL
	
	SELECT 6 AS intSeqId
		,'Sales HTA' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 2
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (3)
		AND CH.intCommodityId = @intCommodityId
		AND CD.intCompanyLocationId = @intLocationId
	
	UNION ALL
	
	SELECT 7 AS intSeqId
		,'Net Hedge' [strType]
		,SUM(HedgedQty)
	FROM (
		SELECT (ISNULL(intNoOfContract, 0) - isnull(dblMatchQty, 0)) * m.dblContractSize AS HedgedQty
		FROM tblRKFutOptTransaction f
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		LEFT JOIN tblRKMatchFuturesPSDetail psd ON f.intFutOptTransactionId = psd.intLFutOptTransactionId
		WHERE f.strBuySell = 'Buy'
			AND intCommodityId = @intCommodityId
			AND f.intLocationId = @intLocationId
		
		UNION ALL
		
		SELECT - (isnull(intNoOfContract, 0) - isnull(dblMatchQty, 0)) * m.dblContractSize AS HedgedQty
		FROM tblRKFutOptTransaction f
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		LEFT JOIN tblRKMatchFuturesPSDetail psd ON f.intFutOptTransactionId = psd.intSFutOptTransactionId
		WHERE f.strBuySell = 'Sell'
			AND intCommodityId = @intCommodityId
			AND f.intLocationId = @intLocationId
		) t
	
	UNION ALL
	
	SELECT 8 AS intSeqId
		,'Cash Exposure' [strType]
		,(isnull(invQty, 0) - isnull(ReserveQty, 0)) + (isnull(OpenPurQty, 0) - isnull(OpenSalQty, 0)) + (((isnull(FutLBalTransQty, 0) - isnull(FutMatchedQty, 0)) - (isnull(FutSBalTransQty, 0) - isnull(FutMatchedQty, 0))) * dblContractSize) AS dblTotal
	FROM (
		SELECT (
				SELECT sum(isnull(it1.dblUnitOnHand, 0))
				FROM tblICItem i1
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
				INNER JOIN tblICItemLocation ic ON ic.intItemLocationId = it1.intItemLocationId
				WHERE i1.intCommodityId = @intCommodityId
					AND ic.intLocationId = @intLocationId
				) AS invQty
			,(
				SELECT SUM(isnull(sr1.dblQty, 0))
				FROM tblICItem i1
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
				INNER JOIN tblICItemLocation ic ON ic.intItemLocationId = it1.intItemLocationId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				WHERE i1.intCommodityId = @intCommodityId
					AND ic.intLocationId = @intLocationId
				) AS ReserveQty
			,(
				SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
				FROM tblCTContractDetail CD
				INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
					AND PT.intPricingTypeId IN (
						1
						,3
						)
				INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
				WHERE CH.intCommodityId = @intCommodityId
					AND CD.intCompanyLocationId = @intLocationId
				) AS OpenPurQty
			,(
				SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
				FROM tblCTContractDetail CD
				INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
					AND PT.intPricingTypeId IN (
						1
						,3
						)
				INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
				WHERE CH.intCommodityId = @intCommodityId
					AND CD.intCompanyLocationId = @intLocationId
				) AS OpenSalQty
			,(
				SELECT TOP 1 rfm.dblContractSize AS dblContractSize
				FROM tblRKFutOptTransaction otr
				INNER JOIN tblRKFutureMarket rfm ON rfm.intFutureMarketId = otr.intFutureMarketId
				WHERE otr.intCommodityId = @intCommodityId
					AND otr.intLocationId = @intLocationId
				GROUP BY rfm.intFutureMarketId
					,rfm.dblContractSize
				) dblContractSize
			,(
				SELECT SUM(intNoOfContract)
				FROM tblRKFutOptTransaction otr
				WHERE otr.strBuySell = 'Sell'
					AND otr.intCommodityId = @intCommodityId
					AND otr.intLocationId = @intLocationId
				) FutSBalTransQty
			,(
				SELECT SUM(intNoOfContract)
				FROM tblRKFutOptTransaction otr
				WHERE otr.strBuySell = 'Buy'
					AND otr.intCommodityId = @intCommodityId
					AND otr.intLocationId = @intLocationId
				) AS FutLBalTransQty
			,(
				SELECT SUM(psd.dblMatchQty)
				FROM tblRKMatchFuturesPSHeader psh
				INNER JOIN tblRKMatchFuturesPSDetail psd ON psd.intMatchFuturesPSHeaderId = psh.intMatchFuturesPSHeaderId
				WHERE psh.intCommodityId = @intCommodityId
					AND psh.intCompanyLocationId = @intLocationId
				) FutMatchedQty
		FROM tblICCommodity c
		WHERE c.intCommodityId = @intCommodityId
		) t
	
	UNION ALL
	
	SELECT 9 AS intSeqId
		,'Basis Exposure' [strType]
		,(isnull(CompanyTitled, 0) + (isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0))) AS dblTotal
	FROM (
		SELECT (invQty) - isnull(ReserveQty, 0) + CASE 
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
				END + dblCollatralSales + SlsBasisDeliveries AS CompanyTitled
			,OpenPurchasesQty
			,OpenSalesQty
		FROM (
			SELECT isnull((
						SELECT sum(isnull(it1.dblUnitOnHand, 0))
						FROM tblICItem i1
						INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
						INNER JOIN tblICItemLocation ic ON ic.intItemLocationId = it1.intItemLocationId
						WHERE i1.intCommodityId = @intCommodityId
							AND ic.intLocationId = @intLocationId
						), 0) AS invQty
				,isnull((
						SELECT SUM(isnull(sr1.dblQty, 0))
						FROM tblICItem i1
						INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
						INNER JOIN tblICItemLocation ic ON ic.intItemLocationId = it1.intItemLocationId
						INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
						WHERE i1.intCommodityId = @intCommodityId
							AND ic.intLocationId = @intLocationId
						), 0) AS ReserveQty
				,(
					SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
					FROM tblCTContractDetail CD
					INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
					INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
						AND CH.intContractTypeId = 1
					INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
						AND PT.intPricingTypeId IN (
							1
							,2
							)
					INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
					WHERE CH.intCommodityId = @intCommodityId
						AND CD.intCompanyLocationId = @intLocationId
					) AS OpenPurchasesQty
				,(
					SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
					FROM tblCTContractDetail CD
					INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
					INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
						AND CH.intContractTypeId = 2
					INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
						AND PT.intPricingTypeId IN (
							1
							,2
							)
					INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
					WHERE CH.intCommodityId = @intCommodityId
						AND CD.intCompanyLocationId = @intLocationId
					) AS OpenSalesQty
				,(
					SELECT isnull(sum(Balance), 0) dblTotal
					FROM vyuGRGetStorageDetail CH
					WHERE ysnCustomerStorage = 1
						AND strOwnedPhysicalStock = 'Company'
						AND CH.intCommodityId = @intCommodityId
						AND CH.intCompanyLocationId = @intLocationId
					) AS OffSite
				,(
					SELECT isnull(SUM(Balance), 0) DP
					FROM vyuGRGetStorageDetail ch
					WHERE ch.intCommodityId = @intCommodityId
						AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId = @intLocationId
					) AS DP
				,(
					SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) AS dblCollatralSales
					FROM (
						SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount
							,intContractHeaderId
							,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
						FROM tblRKCollateral c1
						INNER JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId
						WHERE strType = 'Sale'
							AND c1.intCommodityId = @intCommodityId
							AND c1.intLocationId = @intLocationId
						GROUP BY intContractHeaderId
						) t
					WHERE dblAdjustmentAmount <> dblOriginalQuantity
					) AS dblCollatralSales
				,(
					SELECT isnull(SUM(isnull(ri.dblQuantity, 0)), 0) AS SlsBasisDeliveries
					FROM tblICInventoryShipment r
					INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
					INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo
						AND cd.intPricingTypeId = 2
						AND ri.intOrderId = 1
					INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
					WHERE ch.intCommodityId = @intCommodityId
						AND cd.intCompanyLocationId = @intLocationId
					) AS SlsBasisDeliveries
			FROM tblICCommodity c
			WHERE c.intCommodityId = @intCommodityId
			) t
		) t1
	
	UNION ALL
	
	SELECT 10 AS intSeqId
		,'Net Payable' [strType]
		,SUM(dblBalance) AS dblTotal
	FROM (
		SELECT isnull(sum(dblLineTotal), 0) - isnull(sum(dblTotal), 0) dblBalance
		FROM (
			SELECT DISTINCT ri.dblLineTotal
				,(
					SELECT isnull(sum(dblTotal), 0)
					FROM tblAPBillDetail apd
					WHERE apd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					) AS dblTotal
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
				AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
				AND cd.intPricingTypeId = 1
			WHERE intSourceType = 1
				AND strReceiptType IN ('Purchase Contract')
				AND ch.intCommodityId = @intCommodityId
				AND r.intLocationId = @intLocationId
			) t
		
		UNION ALL
		
		SELECT sum(dblLineTotal) - sum(dblTotal) AS dblBalance
		FROM (
			SELECT DISTINCT ri.dblLineTotal
				,(
					SELECT isnull(sum(dblTotal), 0)
					FROM tblAPBillDetail apd
					WHERE apd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					) AS dblTotal
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
				AND strDistributionOption IN ('SPT')
			WHERE intSourceType = 1
				AND strReceiptType IN ('Direct')
				AND st.intCommodityId = @intCommodityId
				AND r.intLocationId = @intLocationId
			) t
		) t1
	
	UNION ALL
	
	SELECT 11 AS intSeqId
		,'NP Un-Paid Quantity' [strType]
		,SUM(dblBalance) AS dblTotal
	FROM (
		SELECT isnull(SUM(dblOrderQty), 0) - isnull(sum(dblBillQty), 0) AS dblBalance
		FROM (
			SELECT DISTINCT ri.*
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
				AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
				AND cd.intPricingTypeId = 1
			WHERE intSourceType = 1
				AND strReceiptType IN ('Purchase Contract')
				AND ch.intCommodityId = @intCommodityId
				AND r.intLocationId = @intLocationId
			) t
		
		UNION ALL
		
		SELECT isnull(SUM(dblOrderQty), 0) - isnull(sum(dblBillQty), 0) AS dblBalance
		FROM (
			SELECT DISTINCT ri.*
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
				AND strDistributionOption IN ('SPT')
			WHERE intSourceType = 1
				AND strReceiptType IN ('Direct')
				AND st.intCommodityId = @intCommodityId
				AND r.intLocationId = @intLocationId
			) t
		) t
	
	UNION ALL
	
	SELECT 12 AS intSeqId
		,'Net Receivable' [strType]
		,(dblprice - dbltotal) AS dblTotal
	FROM (
		SELECT SUM(dblprice) AS dblprice
			,(
				SELECT SUM(dblAmountPaid) dblAmountPaid
				FROM vyuARCustomerPaymentHistoryReport R
				WHERE R.intCommodityId = @intCommodityId
					AND R.intCompanyLocationId = @intLocationId
				) AS dbltotal
		FROM (
			SELECT SUM(dblQuantity * dblUnitPrice) AS dblprice
			FROM (
				SELECT DISTINCT isi.*
				FROM tblICInventoryShipment ici
				INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
				INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
					AND strDistributionOption IN ('CNT')
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
				INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
					AND cd.intPricingTypeId = 1
				WHERE intOrderType IN (1)
					AND intSourceType = 1
					AND st.intCommodityId = @intCommodityId
					AND st.intProcessingLocationId = @intLocationId
				) t
			
			UNION ALL
			
			SELECT SUM(dblQuantity * dblUnitPrice) AS dblprice
			FROM (
				SELECT DISTINCT isi.*
				FROM tblICInventoryShipment ici
				INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
				INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
					AND strDistributionOption IN ('SPT')
				WHERE intOrderType IN (4)
					AND intSourceType = 1
					AND st.intCommodityId = @intCommodityId
					AND st.intProcessingLocationId = @intLocationId
				) t
			) t
		) t
	
	UNION ALL
	
	SELECT 13 AS intSeqId
		,'NR Un-Paid Quantity' [strType]
		,(dblprice - dbltotal) AS dblTotal
	FROM (
		SELECT SUM(dblprice) AS dblprice
			,(
				SELECT isnull(sum(D.dblQtyShipped), 0)
				FROM [vyuARCustomerPaymentHistoryReport] V
				LEFT JOIN tblARInvoiceDetail D ON V.intInvoiceId = D.intInvoiceId
				WHERE V.intCommodityId = @intCommodityId
					AND V.intCompanyLocationId = @intLocationId
				) AS dbltotal
		FROM (
			SELECT SUM(dblQuantity) AS dblprice
			FROM (
				SELECT DISTINCT isi.*
				FROM tblICInventoryShipment ici
				INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
				INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
					AND strDistributionOption IN ('CNT')
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
				INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
					AND cd.intPricingTypeId = 1
				WHERE intOrderType IN (1)
					AND intSourceType = 1
					AND st.intCommodityId = @intCommodityId
					AND st.intProcessingLocationId = @intLocationId
				) t
			
			UNION ALL
			
			SELECT SUM(dblQuantity) AS dblprice
			FROM (
				SELECT DISTINCT isi.*
				FROM tblICInventoryShipment ici
				INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
				INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
					AND strDistributionOption IN ('SPT')
				WHERE intOrderType IN (4)
					AND intSourceType = 1
					AND st.intCommodityId = @intCommodityId
					AND st.intProcessingLocationId = @intLocationId
				) t
			) t
		) t
	
	UNION ALL
	
	SELECT 14 AS intSeqId
		,'Avail for Spot Sale' [strType]
		,(isnull(CompanyTitled, 0) + (isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0))) - isnull(ReceiptProductQty, 0) AS dblTotal
	FROM (
		SELECT (invQty) - isnull(ReserveQty, 0) + CASE 
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
				END + dblCollatralSales + SlsBasisDeliveries AS CompanyTitled
			,ReceiptProductQty
			,OpenPurchasesQty
			,OpenSalesQty
		FROM (
			SELECT (
					SELECT sum(isnull(it1.dblUnitOnHand, 0))
					FROM tblICItem i1
					INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
					INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
					WHERE i1.intCommodityId = @intCommodityId
						AND il.intLocationId = @intLocationId
					) AS invQty
				,(
					SELECT SUM(isnull(sr1.dblQty, 0))
					FROM tblICItem i1
					INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
					INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
					INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
					WHERE i1.intCommodityId = @intCommodityId
						AND il.intLocationId = @intLocationId
					) AS ReserveQty
				,(
					SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
					FROM tblCTContractDetail CD
					INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
					INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
						AND CH.intContractTypeId = 1
					INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
						AND PT.intPricingTypeId IN (
							1
							,2
							)
					INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
					WHERE CH.intCommodityId = @intCommodityId
						AND CD.intCompanyLocationId = @intLocationId
					) AS ReceiptProductQty
				,(
					SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
					FROM tblCTContractDetail CD
					INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
					INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
						AND CH.intContractTypeId = 1
					INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
						AND PT.intPricingTypeId IN (
							1
							,2
							)
					INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
					WHERE CH.intCommodityId = @intCommodityId
						AND CD.intCompanyLocationId = @intLocationId
					) AS OpenPurchasesQty --req              
				,(
					SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
					FROM tblCTContractDetail CD
					INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
					INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
						AND CH.intContractTypeId = 2
					INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
						AND PT.intPricingTypeId IN (
							1
							,2
							)
					INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
					WHERE CH.intCommodityId = @intCommodityId
						AND CD.intCompanyLocationId = @intLocationId
					) AS OpenSalesQty
				,(
					SELECT isnull(sum(Balance), 0) dblTotal
					FROM vyuGRGetStorageDetail CH
					WHERE ysnCustomerStorage = 1
						AND strOwnedPhysicalStock = 'Company'
						AND CH.intCommodityId = @intCommodityId
						AND CH.intCompanyLocationId = @intLocationId
					) AS OffSite
				,(
					SELECT isnull(SUM(Balance), 0) DP
					FROM vyuGRGetStorageDetail ch
					WHERE ch.intCommodityId = @intCommodityId
						AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId = @intLocationId
					) AS DP
				,(
					SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) AS dblCollatralSales
					FROM (
						SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount
							,intContractHeaderId
							,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
						FROM tblRKCollateral c1
						INNER JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId
						WHERE strType = 'Sale'
							AND c1.intCommodityId = @intCommodityId
							AND c1.intLocationId = @intLocationId
						GROUP BY intContractHeaderId
						) t
					WHERE dblAdjustmentAmount <> dblOriginalQuantity
					) AS dblCollatralSales
				,(
					SELECT isnull(SUM(isnull(ri.dblQuantity, 0)), 0) AS SlsBasisDeliveries
					FROM tblICInventoryShipment r
					INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
					INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo
						AND cd.intPricingTypeId = 2
						AND ri.intOrderId = 1
					INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
					WHERE ch.intCommodityId = @intCommodityId
						AND cd.intCompanyLocationId = @intLocationId
					) AS SlsBasisDeliveries
			FROM tblICCommodity c
			WHERE c.intCommodityId = @intCommodityId
			) t
		) t1
END
ELSE
BEGIN
	SELECT 1 AS intSeqId
		,'Purchases Priced' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 1
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (1)
	WHERE CH.intCommodityId = @intCommodityId
	
	UNION ALL
	
	SELECT 2 AS intSeqId
		,'Purchases Basis' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 1
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (2)
	WHERE CH.intCommodityId = @intCommodityId
	
	UNION ALL
	
	SELECT 3 AS intSeqId
		,'Purchases HTA' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 1
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (3)
	WHERE CH.intCommodityId = @intCommodityId
	
	UNION ALL
	
	SELECT 4 AS intSeqId
		,'Sales Priced' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 2
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (1)
	WHERE CH.intCommodityId = @intCommodityId
	
	UNION ALL
	
	SELECT 5 AS intSeqId
		,'Sales Basis' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 2
	LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
	WHERE ISNULL(PT.intPricingTypeId, 0) = 2
		AND CH.intCommodityId = @intCommodityId
	
	UNION ALL
	
	SELECT 6 AS intSeqId
		,'Sales HTA' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 2
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (3)
		AND CH.intCommodityId = @intCommodityId
	
	UNION ALL
	
	SELECT 7 AS intSeqId
		,'Net Hedge' [strType]
		,SUM(HedgedQty)
	FROM (
		SELECT (ISNULL(intNoOfContract, 0) - isnull(dblMatchQty, 0)) * m.dblContractSize AS HedgedQty
		FROM tblRKFutOptTransaction f
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		LEFT JOIN tblRKMatchFuturesPSDetail psd ON f.intFutOptTransactionId = psd.intLFutOptTransactionId
		WHERE f.strBuySell = 'Buy'
			AND intCommodityId = @intCommodityId
		
		UNION ALL
		
		SELECT - (isnull(intNoOfContract, 0) - isnull(dblMatchQty, 0)) * m.dblContractSize AS HedgedQty
		FROM tblRKFutOptTransaction f
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		LEFT JOIN tblRKMatchFuturesPSDetail psd ON f.intFutOptTransactionId = psd.intSFutOptTransactionId
		WHERE f.strBuySell = 'Sell'
			AND intCommodityId = @intCommodityId
		) t
	
	UNION ALL
	
	SELECT 8 AS intSeqId
		,'Cash Exposure' [strType]
		,(isnull(invQty, 0) - isnull(ReserveQty, 0)) + (isnull(OpenPurQty, 0) - isnull(OpenSalQty, 0)) + isnull((((isnull(FutLBalTransQty, 0) - isnull(FutMatchedQty, 0)) - (isnull(FutSBalTransQty, 0) - isnull(FutMatchedQty, 0))) * dblContractSize), 0) AS dblTotal	FROM (
		SELECT (
				SELECT sum(isnull(it1.dblUnitOnHand, 0))
				FROM tblICItem i1
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
				WHERE i1.intCommodityId = @intCommodityId
				) AS invQty
			,(
				SELECT SUM(isnull(sr1.dblQty, 0))
				FROM tblICItem i1
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				WHERE i1.intCommodityId = @intCommodityId
				) AS ReserveQty
			,(
				SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
				FROM tblCTContractDetail CD
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					AND CH.intContractTypeId = 1
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
					AND PT.intPricingTypeId IN (
						1
						,3
						)
				INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
				WHERE CH.intCommodityId = @intCommodityId
				) AS OpenPurQty
			,(
				SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
				FROM tblCTContractDetail CD
				INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					AND CH.intContractTypeId = 2
				INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
					AND PT.intPricingTypeId IN (
						1
						,3
						)
				INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
				WHERE CH.intCommodityId = @intCommodityId
				) AS OpenSalQty
			,(
				SELECT TOP 1 rfm.dblContractSize AS dblContractSize
				FROM tblRKFutOptTransaction otr
				INNER JOIN tblRKFutureMarket rfm ON rfm.intFutureMarketId = otr.intFutureMarketId
				WHERE otr.intCommodityId = @intCommodityId
				GROUP BY rfm.intFutureMarketId
					,rfm.dblContractSize
				) dblContractSize
			,(
				SELECT SUM(intNoOfContract)
				FROM tblRKFutOptTransaction otr
				WHERE otr.strBuySell = 'Sell'
					AND otr.intCommodityId = @intCommodityId
				) FutSBalTransQty
			,(
				SELECT SUM(intNoOfContract)
				FROM tblRKFutOptTransaction otr
				WHERE otr.strBuySell = 'Buy'
					AND otr.intCommodityId = @intCommodityId
				) AS FutLBalTransQty
			,(
				SELECT SUM(psd.dblMatchQty)
				FROM tblRKMatchFuturesPSHeader psh
				INNER JOIN tblRKMatchFuturesPSDetail psd ON psd.intMatchFuturesPSHeaderId = psh.intMatchFuturesPSHeaderId
				WHERE psh.intCommodityId = @intCommodityId
				) FutMatchedQty
		FROM tblICCommodity c
		WHERE c.intCommodityId = @intCommodityId
		) t
	
	UNION ALL
	
	SELECT 9 AS intSeqId
		,'Basis Exposure' [strType]
		,(isnull(CompanyTitled, 0) + (isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0))) AS dblTotal
	FROM (
		SELECT (invQty) - isnull(ReserveQty, 0) + CASE 
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
				END + dblCollatralSales + SlsBasisDeliveries AS CompanyTitled
			,OpenPurchasesQty
			,OpenSalesQty
		FROM (
			SELECT isnull((
						SELECT sum(isnull(it1.dblUnitOnHand, 0))
						FROM tblICItem i1
						INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
						INNER JOIN tblICItemLocation ic ON ic.intItemLocationId = it1.intItemLocationId
						WHERE i1.intCommodityId = @intCommodityId
						), 0) AS invQty
				,isnull((
						SELECT SUM(isnull(sr1.dblQty, 0))
						FROM tblICItem i1
						INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
						INNER JOIN tblICItemLocation ic ON ic.intItemLocationId = it1.intItemLocationId
						INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
						WHERE i1.intCommodityId = @intCommodityId
						), 0) AS ReserveQty
				,(
					SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
					FROM tblCTContractDetail CD
					INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
					INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
						AND CH.intContractTypeId = 1
					INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
						AND PT.intPricingTypeId IN (
							1
							,2
							)
					INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
					WHERE CH.intCommodityId = @intCommodityId
					) AS OpenPurchasesQty
				,(
					SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
					FROM tblCTContractDetail CD
					INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
					INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
						AND CH.intContractTypeId = 2
					INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
						AND PT.intPricingTypeId IN (
							1
							,2
							)
					INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
					WHERE CH.intCommodityId = @intCommodityId
					) AS OpenSalesQty
				,(
					SELECT isnull(sum(Balance), 0) dblTotal
					FROM vyuGRGetStorageDetail CH
					WHERE ysnCustomerStorage = 1
						AND strOwnedPhysicalStock = 'Company'
						AND CH.intCommodityId = @intCommodityId
					) AS OffSite
				,(
					SELECT isnull(SUM(Balance), 0) DP
					FROM vyuGRGetStorageDetail ch
					WHERE ch.intCommodityId = @intCommodityId
						AND ysnDPOwnedType = 1
					) AS DP
				,(
					SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) AS dblCollatralSales
					FROM (
						SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount
							,intContractHeaderId
							,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
						FROM tblRKCollateral c1
						INNER JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId
						WHERE strType = 'Sale'
							AND c1.intCommodityId = @intCommodityId
						GROUP BY intContractHeaderId
						) t
					WHERE dblAdjustmentAmount <> dblOriginalQuantity
					) AS dblCollatralSales
				,(
					SELECT isnull(SUM(isnull(ri.dblQuantity, 0)), 0) AS SlsBasisDeliveries
					FROM tblICInventoryShipment r
					INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
					INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo
						AND cd.intPricingTypeId = 2
						AND ri.intOrderId = 1
					INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
					WHERE ch.intCommodityId = @intCommodityId
					) AS SlsBasisDeliveries
			FROM tblICCommodity c
			WHERE c.intCommodityId = @intCommodityId
			) t
		) t1
	
	UNION ALL
	
	SELECT 10 AS intSeqId
		,'Net Payable' [strType]
		,SUM(dblBalance) AS dblTotal
	FROM (
		SELECT isnull(sum(dblLineTotal), 0) - isnull(sum(dblTotal), 0) dblBalance
		FROM (
			SELECT DISTINCT ri.dblLineTotal
				,(
					SELECT isnull(sum(dblTotal), 0)
					FROM tblAPBillDetail apd
					WHERE apd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					) AS dblTotal
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
				AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
				AND cd.intPricingTypeId = 1
			WHERE intSourceType = 1
				AND strReceiptType IN ('Purchase Contract')
				AND ch.intCommodityId = @intCommodityId
			) t
		
		UNION ALL
		
		SELECT sum(dblLineTotal) - sum(dblTotal) AS dblBalance
		FROM (
			SELECT DISTINCT ri.dblLineTotal
				,(
					SELECT isnull(sum(dblTotal), 0)
					FROM tblAPBillDetail apd
					WHERE apd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					) AS dblTotal
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
				AND strDistributionOption IN ('SPT')
			WHERE intSourceType = 1
				AND strReceiptType IN ('Direct')
				AND st.intCommodityId = @intCommodityId
			) t
		) t1
	
	UNION ALL
	
	SELECT 11 AS intSeqId
		,'NP Un-Paid Quantity' [strType]
		,SUM(dblBalance) AS dblTotal
	FROM (
		SELECT isnull(SUM(dblOrderQty), 0) - isnull(sum(dblBillQty), 0) AS dblBalance
		FROM (
			SELECT DISTINCT ri.*
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
				AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
				AND cd.intPricingTypeId = 1
			WHERE intSourceType = 1
				AND strReceiptType IN ('Purchase Contract')
				AND ch.intCommodityId = @intCommodityId
			) t
		
		UNION ALL
		
		SELECT isnull(SUM(dblOrderQty), 0) - isnull(sum(dblBillQty), 0) AS dblBalance
		FROM (
			SELECT DISTINCT ri.*
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
				AND strDistributionOption IN ('SPT')
			WHERE intSourceType = 1
				AND strReceiptType IN ('Direct')
				AND st.intCommodityId = @intCommodityId
			) t
		) t
	
	UNION ALL
	
	SELECT 12 AS intSeqId
		,'Net Receivable' [strType]
		,(dblprice - dbltotal) AS dblTotal
	FROM (
		SELECT SUM(dblprice) AS dblprice
			,(
				SELECT SUM(dblAmountPaid) dblAmountPaid
				FROM vyuARCustomerPaymentHistoryReport R
				WHERE R.intCommodityId = @intCommodityId
				) AS dbltotal
		FROM (
			SELECT SUM(dblQuantity * dblUnitPrice) AS dblprice
			FROM (
				SELECT DISTINCT isi.*
				FROM tblICInventoryShipment ici
				INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
				INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
					AND strDistributionOption IN ('CNT')
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
				INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
					AND cd.intPricingTypeId = 1
				WHERE intOrderType IN (1)
					AND intSourceType = 1
					AND st.intCommodityId = @intCommodityId
				) t
			
			UNION ALL
			
			SELECT SUM(dblQuantity * dblUnitPrice) AS dblprice
			FROM (
				SELECT DISTINCT isi.*
				FROM tblICInventoryShipment ici
				INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
				INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
					AND strDistributionOption IN ('SPT')
				WHERE intOrderType IN (4)
					AND intSourceType = 1
					AND st.intCommodityId = @intCommodityId
				) t
			) t
		) t
	
	UNION ALL
	
	SELECT 13 AS intSeqId
		,'NR Un-Paid Quantity' [strType]
		,(dblprice - dbltotal) AS dblTotal
	FROM (
		SELECT SUM(dblprice) AS dblprice
			,(
				SELECT isnull(sum(D.dblQtyShipped), 0)
				FROM [vyuARCustomerPaymentHistoryReport] V
				LEFT JOIN tblARInvoiceDetail D ON V.intInvoiceId = D.intInvoiceId
				WHERE V.intCommodityId = @intCommodityId
				) AS dbltotal
		FROM (
			SELECT SUM(dblQuantity) AS dblprice
			FROM (
				SELECT DISTINCT isi.*
				FROM tblICInventoryShipment ici
				INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
				INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
					AND strDistributionOption IN ('CNT')
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
				INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
					AND cd.intPricingTypeId = 1
				WHERE intOrderType IN (1)
					AND intSourceType = 1
					AND st.intCommodityId = @intCommodityId
				) t
			
			UNION ALL
			
			SELECT SUM(dblQuantity) AS dblprice
			FROM (
				SELECT DISTINCT isi.*
				FROM tblICInventoryShipment ici
				INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
				INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
					AND strDistributionOption IN ('SPT')
				WHERE intOrderType IN (4)
					AND intSourceType = 1
					AND st.intCommodityId = @intCommodityId
				) t
			) t
		) t
	
	UNION ALL
	
	SELECT 14 AS intSeqId
		,'Avail for Spot Sale' [strType]
		,(isnull(CompanyTitled, 0) + (isnull(OpenPurchasesQty, 0) - isnull(OpenSalesQty, 0))) - isnull(ReceiptProductQty, 0) AS dblTotal
	FROM (
		SELECT (invQty) - isnull(ReserveQty, 0) + CASE 
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
				END + dblCollatralSales + SlsBasisDeliveries AS CompanyTitled
			,ReceiptProductQty
			,OpenPurchasesQty
			,OpenSalesQty
		FROM (
			SELECT (
					SELECT sum(isnull(it1.dblUnitOnHand, 0))
					FROM tblICItem i1
					INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
					INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
					WHERE i1.intCommodityId = @intCommodityId
					) AS invQty
				,(
					SELECT SUM(isnull(sr1.dblQty, 0))
					FROM tblICItem i1
					INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
					INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
					INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
					WHERE i1.intCommodityId = @intCommodityId
					) AS ReserveQty
				,(
					SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
					FROM tblCTContractDetail CD
					INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
					INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
						AND CH.intContractTypeId = 1
					INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
						AND PT.intPricingTypeId IN (
							1
							,2
							)
					INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
					WHERE CH.intCommodityId = @intCommodityId
					) AS ReceiptProductQty
				,(
					SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
					FROM tblCTContractDetail CD
					INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
					INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
						AND CH.intContractTypeId = 1
					INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
						AND PT.intPricingTypeId IN (
							1
							,2
							)
					INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
					WHERE CH.intCommodityId = @intCommodityId
					) AS OpenPurchasesQty --req              
				,(
					SELECT isnull(Sum(CD.dblBalance), 0) AS Qty
					FROM tblCTContractDetail CD
					INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
					INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
						AND CH.intContractTypeId = 2
					INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
						AND PT.intPricingTypeId IN (
							1
							,2
							)
					INNER JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
					WHERE CH.intCommodityId = @intCommodityId
					) AS OpenSalesQty
				,(
					SELECT isnull(sum(Balance), 0) dblTotal
					FROM vyuGRGetStorageDetail CH
					WHERE ysnCustomerStorage = 1
						AND strOwnedPhysicalStock = 'Company'
						AND CH.intCommodityId = @intCommodityId
					) AS OffSite
				,(
					SELECT isnull(SUM(Balance), 0) DP
					FROM vyuGRGetStorageDetail ch
					WHERE ch.intCommodityId = @intCommodityId
						AND ysnDPOwnedType = 1
					) AS DP
				,(
					SELECT isnull(SUM(dblOriginalQuantity), 0) - isnull(sum(dblAdjustmentAmount), 0) AS dblCollatralSales
					FROM (
						SELECT SUM(dblAdjustmentAmount) dblAdjustmentAmount
							,intContractHeaderId
							,isnull(SUM(dblOriginalQuantity), 0) dblOriginalQuantity
						FROM tblRKCollateral c1
						INNER JOIN tblRKCollateralAdjustment ca ON c1.intCollateralId = ca.intCollateralId
						WHERE strType = 'Sale'
							AND c1.intCommodityId = @intCommodityId
						GROUP BY intContractHeaderId
						) t
					WHERE dblAdjustmentAmount <> dblOriginalQuantity
					) AS dblCollatralSales
				,(
					SELECT isnull(SUM(isnull(ri.dblQuantity, 0)), 0) AS SlsBasisDeliveries
					FROM tblICInventoryShipment r
					INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
					INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo
						AND cd.intPricingTypeId = 2
						AND ri.intOrderId = 1
					INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
					WHERE ch.intCommodityId = @intCommodityId
					) AS SlsBasisDeliveries
			FROM tblICCommodity c
			WHERE c.intCommodityId = @intCommodityId
			) t
		) t1
END