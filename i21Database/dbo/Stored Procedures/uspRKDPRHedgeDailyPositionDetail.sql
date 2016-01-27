CREATE PROCEDURE [dbo].[uspRKDPRHedgeDailyPositionDetail] 
		 @intCommodityId nvarchar(max)
		,@intLocationId nvarchar(max) = NULL
AS

	 DECLARE @Commodity AS TABLE 
	 (
		intCommodityIdentity int IDENTITY(1,1) PRIMARY KEY , 
		intCommodity  INT
	 )
	 INSERT INTO @Commodity(intCommodity)
	 SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')  
	 
DECLARE @Final AS TABLE (
intRow int IDENTITY(1,1) PRIMARY KEY , 
intSeqId int, 
strCommodityCode nvarchar(100),
strType nvarchar(100),
dblTotal DECIMAL(24,10)
)


DECLARE @mRowNumber INT
DECLARE @intCommodityId1 INT
DECLARE @strDescription NVARCHAR(50)

SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity

WHILE @mRowNumber > 0
BEGIN
	SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
	SELECT @strDescription = strDescription	FROM tblICCommodity	WHERE intCommodityId = @intCommodityId

INSERT INTO @Final(intSeqId,strCommodityCode,strType,dblTotal)
SELECT intSeqId,@strDescription,strType,dblTotal FROM (
	SELECT 1 AS intSeqId
		,'Purchases Priced' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 1
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (1)
	WHERE CH.intCommodityId  = @intCommodityId
		AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
		
	
	UNION ALL
	
	SELECT 2 AS intSeqId
		,'Purchases Basis' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 1
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (2)
	WHERE CH.intCommodityId  = @intCommodityId
		AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
	
	UNION ALL
	
	SELECT 3 AS intSeqId
		,'Purchases HTA' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 1
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (3)
	WHERE CH.intCommodityId  = @intCommodityId
		AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
	
	UNION ALL
	
	SELECT 4 AS intSeqId
		,'Sales Priced' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 2
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (1)
	WHERE CH.intCommodityId  = @intCommodityId
		AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
	
	UNION ALL
	
	SELECT 5 AS intSeqId
		,'Sales Basis' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 2
	LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
	WHERE ISNULL(PT.intPricingTypeId, 0) = 2
		AND CH.intCommodityId  = @intCommodityId
		AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
	
	UNION ALL
	
	SELECT 6 AS intSeqId
		,'Sales HTA' [strType]
		,isnull(Sum(CD.dblBalance), 0) AS dblTotal
	FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		AND CH.intContractTypeId = 2
	INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
		AND PT.intPricingTypeId IN (3)
		AND CH.intCommodityId  = @intCommodityId
		AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
	
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
			AND intCommodityId  = @intCommodityId
			AND f.intLocationId= case when isnull(@intLocationId,0)=0 then f.intLocationId else @intLocationId end
			
		
		UNION ALL
		
		SELECT -(isnull(intNoOfContract, 0) - isnull(dblMatchQty, 0)) * m.dblContractSize AS HedgedQty
		FROM tblRKFutOptTransaction f
		INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
		LEFT JOIN tblRKMatchFuturesPSDetail psd ON f.intFutOptTransactionId = psd.intSFutOptTransactionId
		WHERE f.strBuySell = 'Sell'
			AND intCommodityId  = @intCommodityId
			AND f.intLocationId= case when isnull(@intLocationId,0)=0 then f.intLocationId else @intLocationId end
		) t
	
	UNION ALL
	
	SELECT 8 AS intSeqId
		,'Cash Exposure' [strType]
		,(isnull(invQty, 0) - isnull(ReserveQty, 0)) + (isnull(OpenPurQty, 0) - isnull(OpenSalQty, 0)) + (((isnull(FutLBalTransQty, 0) - isnull(FutMatchedQty, 0)) - (isnull(FutSBalTransQty, 0) - isnull(FutMatchedQty, 0))) * isnull(dblContractSize,0)) AS dblTota

	FROM (
		SELECT (
				SELECT sum(isnull(it1.dblUnitOnHand, 0))
				FROM tblICItem i1
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
				INNER JOIN tblICItemLocation ic ON ic.intItemLocationId = it1.intItemLocationId
				WHERE i1.intCommodityId  = @intCommodityId
					AND ic.intLocationId= case when isnull(@intLocationId,0)=0 then ic.intLocationId else @intLocationId end					
				) AS invQty
			,(
				SELECT SUM(isnull(sr1.dblQty, 0))
				FROM tblICItem i1
				INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
				INNER JOIN tblICItemLocation ic ON ic.intItemLocationId = it1.intItemLocationId
				INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
				WHERE i1.intCommodityId  = @intCommodityId
					AND ic.intLocationId= case when isnull(@intLocationId,0)=0 then ic.intLocationId else @intLocationId end
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
				WHERE CH.intCommodityId  = @intCommodityId
					AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
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
				WHERE CH.intCommodityId  = @intCommodityId
					AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
				) AS OpenSalQty
			,(
				SELECT TOP 1 rfm.dblContractSize AS dblContractSize
				FROM tblRKFutOptTransaction otr
				INNER JOIN tblRKFutureMarket rfm ON rfm.intFutureMarketId = otr.intFutureMarketId
				WHERE otr.intCommodityId  = @intCommodityId
				AND otr.intLocationId= case when isnull(@intLocationId,0)=0 then otr.intLocationId else @intLocationId end
				GROUP BY rfm.intFutureMarketId
					,rfm.dblContractSize
				) dblContractSize
			,(
				SELECT SUM(intNoOfContract)
				FROM tblRKFutOptTransaction otr
				WHERE otr.strBuySell = 'Sell'
					AND otr.intCommodityId  = @intCommodityId
					AND otr.intLocationId= case when isnull(@intLocationId,0)=0 then otr.intLocationId else @intLocationId end
				) FutSBalTransQty
			,(
				SELECT SUM(intNoOfContract)
				FROM tblRKFutOptTransaction otr
				WHERE otr.strBuySell = 'Buy'
					AND otr.intCommodityId  = @intCommodityId
					AND otr.intLocationId= case when isnull(@intLocationId,0)=0 then otr.intLocationId else @intLocationId end
				) AS FutLBalTransQty
			,(
				SELECT SUM(psd.dblMatchQty)
				FROM tblRKMatchFuturesPSHeader psh
				INNER JOIN tblRKMatchFuturesPSDetail psd ON psd.intMatchFuturesPSHeaderId = psh.intMatchFuturesPSHeaderId
				WHERE psh.intCommodityId  = @intCommodityId				
					AND psh.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then psh.intCompanyLocationId else @intLocationId end
				) FutMatchedQty
		FROM tblICCommodity c
		WHERE c.intCommodityId  = @intCommodityId
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
						WHERE i1.intCommodityId  = @intCommodityId
							AND ic.intLocationId= case when isnull(@intLocationId,0)=0 then ic.intLocationId else @intLocationId end
						), 0) AS invQty
				,isnull((
						SELECT SUM(isnull(sr1.dblQty, 0))
						FROM tblICItem i1
						INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
						INNER JOIN tblICItemLocation ic ON ic.intItemLocationId = it1.intItemLocationId
						INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
						WHERE i1.intCommodityId  = @intCommodityId
							AND ic.intLocationId= case when isnull(@intLocationId,0)=0 then ic.intLocationId else @intLocationId end
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
					WHERE CH.intCommodityId  = @intCommodityId
						AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
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
					WHERE CH.intCommodityId  = @intCommodityId
						AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
					) AS OpenSalesQty
				,(
					SELECT isnull(sum(Balance), 0) dblTotal
					FROM vyuGRGetStorageDetail CH
					WHERE ysnCustomerStorage = 1
						AND strOwnedPhysicalStock = 'Company'
						AND CH.intCommodityId  = @intCommodityId
						AND CH.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CH.intCompanyLocationId else @intLocationId end
						
					) AS OffSite
				,(
					SELECT isnull(SUM(Balance), 0) DP
					FROM vyuGRGetStorageDetail ch
					WHERE ch.intCommodityId  = @intCommodityId
						AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
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
							AND c1.intCommodityId  = @intCommodityId							
							AND c1.intLocationId= case when isnull(@intLocationId,0)=0 then c1.intLocationId else @intLocationId end
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
					WHERE ch.intCommodityId  = @intCommodityId
						AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
					) AS SlsBasisDeliveries
			FROM tblICCommodity c
			WHERE c.intCommodityId  = @intCommodityId
			) t
		) t1
	
	UNION ALL
	
	SELECT 10 AS intSeqId
		,'Net Payable  ($)' [strType]
		,SUM(dblBalance) AS dblTotal
	FROM (
		SELECT isnull(sum(dblLineTotal), 0) - isnull(sum(dblTotal), 0) dblBalance
		FROM (
			SELECT ri.dblLineTotal
				,(
					SELECT isnull(sum(dblTotal), 0)
					FROM tblAPBillDetail apd
					WHERE apd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					) AS dblTotal
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intPricingTypeId = 1
			WHERE intSourceType = 1
				AND strReceiptType IN ('Purchase Contract')
				AND ch.intCommodityId  = @intCommodityId
				AND r.intLocationId= case when isnull(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
				
			) t
		
		UNION ALL
		
		SELECT sum(dblLineTotal) - sum(dblTotal) AS dblBalance
		FROM (
			SELECT ri.dblLineTotal
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
				AND st.intCommodityId  = @intCommodityId
				AND r.intLocationId= case when isnull(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
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
				AND ch.intCommodityId  = @intCommodityId
				AND r.intLocationId= case when isnull(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
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
				AND st.intCommodityId  = @intCommodityId
				AND r.intLocationId= case when isnull(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
			) t
		) t
	
	UNION ALL
	
	SELECT 12 AS intSeqId
		,'Net Receivable  ($)' [strType]
		,(isnull(dblprice,0) - isnull(dbltotal,0)) AS dblTotal
	FROM (
		SELECT SUM(dblprice) AS dblprice
			,(
				SELECT SUM(dblAmountPaid) dblAmountPaid
				FROM vyuARCustomerPaymentHistoryReport R
				WHERE R.intCommodityId  = @intCommodityId
					AND R.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then R.intCompanyLocationId else @intLocationId end					
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
					AND st.intCommodityId  = @intCommodityId
					AND st.intProcessingLocationId = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
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
					AND st.intCommodityId  = @intCommodityId
					AND st.intProcessingLocationId = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
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
				WHERE V.intCommodityId  = @intCommodityId
					AND V.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then V.intCompanyLocationId else @intLocationId end					
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
					AND st.intCommodityId  = @intCommodityId
					AND st.intProcessingLocationId = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
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
					AND st.intCommodityId  = @intCommodityId
					AND st.intProcessingLocationId = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
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
					WHERE i1.intCommodityId  = @intCommodityId
						AND il.intLocationId = case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end						
					) AS invQty
				,(
					SELECT SUM(isnull(sr1.dblQty, 0))
					FROM tblICItem i1
					INNER JOIN tblICItemStock it1 ON it1.intItemId = i1.intItemId
					INNER JOIN tblICItemLocation il ON il.intItemLocationId = it1.intItemLocationId
					INNER JOIN tblICStockReservation sr1 ON it1.intItemId = sr1.intItemId
					WHERE i1.intCommodityId  = @intCommodityId
						AND il.intLocationId = case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end
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
					WHERE CH.intCommodityId  = @intCommodityId
						AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
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
					WHERE CH.intCommodityId  = @intCommodityId
						AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
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
					WHERE CH.intCommodityId  = @intCommodityId
						AND CD.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CD.intCompanyLocationId else @intLocationId end
					) AS OpenSalesQty
				,(
					SELECT isnull(sum(Balance), 0) dblTotal
					FROM vyuGRGetStorageDetail CH
					WHERE ysnCustomerStorage = 1
						AND strOwnedPhysicalStock = 'Company'
						AND CH.intCommodityId  = @intCommodityId
						AND CH.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CH.intCompanyLocationId else @intLocationId end
					) AS OffSite
				,(
					SELECT isnull(SUM(Balance), 0) DP
					FROM vyuGRGetStorageDetail ch
					WHERE ch.intCommodityId  = @intCommodityId
						AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then ch.intCompanyLocationId else @intLocationId end
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
							AND c1.intCommodityId  = @intCommodityId
							AND c1.intLocationId= case when isnull(@intLocationId,0)=0 then c1.intLocationId else @intLocationId end
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
					WHERE ch.intCommodityId  = @intCommodityId
						AND cd.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
					) AS SlsBasisDeliveries
			FROM tblICCommodity c
			WHERE c.intCommodityId  = @intCommodityId
			) t
		) t1
	)t2
		SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber
	
END

DECLARE @intUnitMeasureId int
DECLARE @intFromCommodityUnitMeasureId int
DECLARE @intToCommodityUnitMeasureId int
DECLARE @StrUnitMeasure nvarchar(50)

SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference

IF ISNULL(@intUnitMeasureId,'') <> ''
BEGIN
	SELECT @intFromCommodityUnitMeasureId=cuc.intCommodityUnitMeasureId,@intToCommodityUnitMeasureId=cuc1.intCommodityUnitMeasureId 
	FROM tblICCommodity t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
	JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
	WHERE t.intCommodityId = @intCommodityId
	SELECT @StrUnitMeasure=strUnitMeasure from tblICUnitMeasure where intUnitMeasureId=@intUnitMeasureId
END
ELSE
BEGIN
	SELECT @StrUnitMeasure=c.strUnitMeasure
	FROM tblICCommodity t
	JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1
	join tblICUnitMeasure c on c.intUnitMeasureId=cuc.intUnitMeasureId 	
	WHERE t.intCommodityId = @intCommodityId
END

BEGIN

		IF (ISNULL(@intToCommodityUnitMeasureId,'') <> '' and ISNULL(@intToCommodityUnitMeasureId,'') <> '')
		BEGIN
		SELECT intRow,intSeqId,strCommodityCode,strType,@StrUnitMeasure as strUnitMeasure, 
				CASE WHEN strType = 'Net Payable  ($)' THEN dblTotal
					 WHEN strType = 'Net Receivable  ($)' THEN dblTotal
					 else dbo.fnCTConvertQuantityToTargetCommodityUOM(@intFromCommodityUnitMeasureId,@intToCommodityUnitMeasureId,dblTotal) end dblTotal
		FROM @Final 

		END
		ELSE
		BEGIN
			SELECT intRow,intSeqId,strCommodityCode,strType,@StrUnitMeasure as strUnitMeasure,Convert(decimal(24,10),dblTotal) dblTotal FROM @Final
		END
END