CREATE PROCEDURE [dbo].[uspRKHedgeCustomerPositionDetail] 
	 @intCommodityId INT
	,@intLocationId INT = NULL
	,@strPurchaseSales nvarchar(50) = NULL
	,@intVendorCustomerId INT = NULL
AS
BEGIN
SELECT * INTO #temp FROM (	
		
	SELECT 1 AS intSeqId
	,'Quantity Purchase' [strType]
	,SUM(dblOpenReceive) AS dblTotal
	FROM (
				SELECT ri.intInventoryReceiptItemId
					,cl.strLocationName
					,r.strReceiptNumber strTicketNumber
					,r.dtmReceiptDate dtmTicketDateTime
					,r.strVendorRefNo as strCustomerReference
					,'Purchase Contract' as strDistributionOption
					,dblUnitCost AS dblUnitCost
					,isnull(dblUnitCost,0)*isnull(dblOpenReceive,0) AS dblQtyReceived
							,ch.intCommodityId,
				isnull(dblOpenReceive,0) dblOpenReceive
				FROM tblICInventoryReceipt r
				INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Purchase Contract')
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			    INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intContractDetailId=intLineNo AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
				INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
				WHERE ch.intCommodityId = @intCommodityId and ch.intEntityId=@intVendorCustomerId 
				AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end

		UNION

		SELECT ri.intInventoryReceiptItemId
					,cl.strLocationName
					,r.strReceiptNumber strTicketNumber
					,r.dtmReceiptDate dtmTicketDateTime
					,r.strVendorRefNo as strCustomerReference
					,'Direct' as strDistributionOption
					,dblUnitCost AS dblUnitCost
					,isnull(dblUnitCost,0)*isnull(dblOpenReceive,0) AS dblQtyReceived
					,i.intCommodityId,
					isnull(dblOpenReceive,0) dblOpenReceive
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Direct') 
		AND r.intSourceType=1 and isnull(dblUnitCost,0) <> 0 
		INNER JOIN tblICItem i on ri.intItemId=i.intItemId
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE i.intCommodityId = @intCommodityId AND r.intEntityVendorId =@intVendorCustomerId
		AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
		) t	

UNION

	SELECT 2 AS intSeqId
	,'Quantity Sales' [strType]
	,SUM(dblQuantity) AS dblTotal
	FROM (
		SELECT ISNULL(dblQuantity,0) dblQuantity from tblICInventoryShipment s
		join tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId and intOrderType =4 and isnull(dblUnitPrice,0) <>0
		JOIN vyuCTContractDetailView cd on cd.intContractDetailId=si.intLineNo and cd.intContractStatusId <> 3 
		join tblICItem i on si.intItemId=i.intItemId  WHERE i.intCommodityId=@intCommodityId and s.intEntityCustomerId=@intVendorCustomerId
			AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
		UNION
		SELECT ISNULL(dblQuantity,0) dblQuantity from tblICInventoryShipment s
		JOIN tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId 
		JOIN vyuCTContractDetailView cd on cd.intContractDetailId=si.intLineNo and cd.intContractTypeId=2 and cd.intContractStatusId <> 3
		AND cd.intCommodityId=@intCommodityId and cd.intEntityId=@intVendorCustomerId 
		AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end) t	
		
UNION

SELECT 3 AS intSeqId
	,'Purchase Gross Dollars' [strType]
	,SUM(dblQtyReceived) AS dblTotal
	FROM (
		select sum(dblQtyReceived) dblQtyReceived from(
			SELECT  isnull(dblUnitCost,0)*isnull(dblOpenReceive,0) AS dblQtyReceived
				FROM tblICInventoryReceipt r
				INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Purchase Contract')
				INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			    INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intContractDetailId=intLineNo AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
				INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
				WHERE ch.intCommodityId  = @intCommodityId and ch.intEntityId=@intVendorCustomerId 
				AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end)t
		
		UNION
		
		SELECT isnull(dblOpenReceive,0)*dblUnitCost dblOpenReceive
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Direct') 
		AND r.intSourceType=1 and isnull(dblUnitCost,0) <> 0 
		INNER JOIN tblICItem i on ri.intItemId=i.intItemId 
		WHERE i.intCommodityId = @intCommodityId and r.intEntityVendorId=@intVendorCustomerId  
		AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end) t
		
UNION

SELECT 4 AS intSeqId
	,'Sales Gross Dollars' [strType]
	,SUM(dblQuantity) AS dblTotal
	FROM (
		select isnull(dblQuantity,0)*dblUnitPrice dblQuantity from tblICInventoryShipment s
		join tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId and intOrderType =4 and isnull(dblUnitPrice,0) <>0
		join tblICItem i on si.intItemId=i.intItemId 
		JOIN vyuCTContractDetailView cd on cd.intContractDetailId=si.intLineNo and cd.intContractStatusId <> 3
		WHERE i.intCommodityId=@intCommodityId and cd.intEntityId=@intVendorCustomerId 
		 AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
		UNION
		select isnull(dblQuantity,0)*dblUnitPrice dblQuantity from tblICInventoryShipment s
		join tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId 
		JOIN vyuCTContractDetailView cd on cd.intContractDetailId=si.intLineNo and cd.intContractTypeId=2 and cd.intContractStatusId <> 3
		and cd.intCommodityId=@intCommodityId and cd.intEntityId=@intVendorCustomerId 
		 AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end) t		

UNION

SELECT 5 AS intSeqId
		,'Net Purchase Un-Paid Quantity' [strType]
		,SUM(dblTotal) AS dblTotal
	FROM (
		SELECT *,dblUnitCost-dblQtyReceived dblTotal FROM(				
		SELECT DISTINCT ri.intInventoryReceiptItemId
			,cl.strLocationName
			,st.strTicketNumber
			,st.dtmTicketDateTime
			,strCustomerReference
			,'CNT' strDistributionOption
			,ch.intCommodityId
			,dblOrderQty AS dblUnitCost
			,isnull((SELECT (bd.dblQtyReceived) FROM tblAPBillDetail bd 
					INNER JOIN tblAPBill b on b.intBillId=bd.intBillId
					WHERE  bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId and ysnPosted=1 ),0) AS dblQtyReceived			
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intContractDetailId=intLineNo AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1
				AND strReceiptType IN ('Purchase Contract')	AND ch.intCommodityId = @intCommodityId	and r.intEntityVendorId=@intVendorCustomerId
				AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
		
		UNION ALL
		
		SELECT DISTINCT ri.intInventoryReceiptItemId
			,cl.strLocationName
			,st.strTicketNumber
			,st.dtmTicketDateTime
			,strCustomerReference
			,'SPT' strDistributionOption
			,st.intCommodityId
			,dblOrderQty AS dblUnitCost
			,isnull((Select (bd.dblQtyReceived) FROM tblAPBillDetail bd 
				INNER JOIN tblAPBill b on b.intBillId=bd.intBillId
				where  bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId and ysnPosted=1 ),0) AS dblQtyReceived	
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('SPT')	
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId		
			WHERE intSourceType = 1 AND strReceiptType IN ('Direct') AND st.intCommodityId = @intCommodityId  
			AND r.intEntityVendorId=@intVendorCustomerId
				AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end)t
	) t1
				
UNION
SELECT 6 AS intSeqId
		,'Net Purchase Payable' [strType]
		,sum(dblBalance) dblTotal FROM (
		SELECT sum(dblUnitCost)-sum(dblQtyReceived) dblBalance from(
		SELECT DISTINCT ri.intInventoryReceiptItemId
			,cl.strLocationName
			,st.strTicketNumber
			,st.dtmTicketDateTime
			,strCustomerReference
			,'SPT' strDistributionOption
			,dblOrderQty*dblUnitCost AS dblUnitCost
			,isnull((Select (bd.dblQtyReceived*bd.dblCost) FROM tblAPBillDetail bd 
				INNER JOIN tblAPBill b on b.intBillId=bd.intBillId
				where  bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId and ysnPosted=1 ),0) AS dblQtyReceived
			,st.intCommodityId
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intContractDetailId=intLineNo AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1
				AND strReceiptType IN ('Purchase Contract')	AND ch.intCommodityId = @intCommodityId	and r.intEntityVendorId=@intVendorCustomerId
				AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end)t
	
		UNION
		
		SELECT isnull(sum(dblOrderQty), 0) - isnull(sum(dblBillQty), 0) AS dblBalance
		FROM (
			SELECT DISTINCT (dblOrderQty*dblUnitCost) dblOrderQty,
			(Select (bd.dblQtyReceived*bd.dblCost) FROM tblAPBillDetail bd 
				INNER JOIN tblAPBill b on b.intBillId=bd.intBillId
				where  bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId and ysnPosted=1 ) dblBillQty
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('SPT')			
			WHERE intSourceType = 1 AND strReceiptType IN ('Direct') AND st.intCommodityId = @intCommodityId  and r.intEntityVendorId=@intVendorCustomerId
				AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
			) t
	) t1
)t3
END

IF @strPurchaseSales = 'Sales'
BEGIN
	SELECT intSeqId,strType, dblTotal FROM #temp where strType not like '%Purchase%' 
	order by intSeqId
END
ELSE
BEGIN
	SELECT intSeqId,strType, dblTotal FROM #temp where strType not like '%Sales%' 
	order by intSeqId
END