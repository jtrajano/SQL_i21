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
		SELECT isnull(dblOpenReceive,0) dblOpenReceive
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Purchase Contract')
		INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 1
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		WHERE ch.intCommodityId = @intCommodityId and ch.intEntityId=@intVendorCustomerId 
		AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
			
		UNION
		
		SELECT isnull(dblOpenReceive,0) dblOpenReceive
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Direct') 
		AND r.intSourceType=1 and isnull(dblUnitCost,0) <> 0 
		INNER JOIN tblICItem i on ri.intItemId=i.intItemId
		WHERE i.intCommodityId = @intCommodityId AND r.intEntityId=@intVendorCustomerId
			AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
		 --AND r.intLocationId = @intLocationId
		) t	

UNION

	SELECT 2 AS intSeqId
	,'Quantity Sales' [strType]
	,SUM(dblQuantity) AS dblTotal
	FROM (
		SELECT ISNULL(dblQuantity,0) dblQuantity from tblICInventoryShipment s
		join tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId and intOrderType =4 and isnull(dblUnitPrice,0) <>0
		JOIN vyuCTContractDetailView cd on cd.intContractDetailId=si.intLineNo
		join tblICItem i on si.intItemId=i.intItemId  WHERE i.intCommodityId=@intCommodityId and cd.intEntityId=@intVendorCustomerId
		AND cd.intCompanyLocationId = @intLocationId
			AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
		UNION
		SELECT ISNULL(dblQuantity,0) dblQuantity from tblICInventoryShipment s
		JOIN tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId 
		JOIN vyuCTContractDetailView cd on cd.intContractDetailId=si.intLineNo and cd.intContractTypeId=2
		AND cd.intCommodityId=@intCommodityId and cd.intEntityId=@intVendorCustomerId 
		AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end) t	
		
UNION

SELECT 3 AS intSeqId
	,'Purchase Gross Dollers' [strType]
	,SUM(dblOpenReceive) AS dblTotal
	FROM (
		SELECT isnull(dblOpenReceive,0)*dblUnitCost  dblOpenReceive
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Purchase Contract')
		INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 1
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = cd.intContractHeaderId
		WHERE ch.intCommodityId = @intCommodityId and ch.intEntityId=@intVendorCustomerId 
		AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
		
		UNION
		
		SELECT isnull(dblOpenReceive,0)*dblUnitCost dblOpenReceive
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Direct') 
		AND r.intSourceType=1 and isnull(dblUnitCost,0) <> 0 
		INNER JOIN tblICItem i on ri.intItemId=i.intItemId 
		WHERE i.intCommodityId = @intCommodityId and r.intEntityId=@intVendorCustomerId  
		AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end) t
		
UNION

SELECT 4 AS intSeqId
	,'Sales Gross Dollers' [strType]
	,SUM(dblQuantity) AS dblTotal
	FROM (
		select isnull(dblQuantity,0)*dblUnitPrice dblQuantity from tblICInventoryShipment s
		join tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId and intOrderType =4 and isnull(dblUnitPrice,0) <>0
		join tblICItem i on si.intItemId=i.intItemId 
		JOIN vyuCTContractDetailView cd on cd.intContractDetailId=si.intLineNo
		WHERE i.intCommodityId=@intCommodityId and cd.intEntityId=@intVendorCustomerId and  cd.intCompanyLocationId = @intLocationId
		UNION
		select isnull(dblQuantity,0)*dblUnitPrice dblQuantity from tblICInventoryShipment s
		join tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId 
		JOIN vyuCTContractDetailView cd on cd.intContractDetailId=si.intLineNo and cd.intContractTypeId=2
		and cd.intCommodityId=@intCommodityId and cd.intEntityId=@intVendorCustomerId 
		 AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end) t		

UNION

SELECT 5 AS intSeqId
		,'Net Purchase Un-Paid Quantity' [strType]
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
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intPricingTypeId = 1
			WHERE intSourceType = 1 and  ch.intEntityId=@intVendorCustomerId
				AND strReceiptType IN ('Purchase Contract')	AND ch.intCommodityId = @intCommodityId	
				AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
			) t
		
		UNION
		
		SELECT isnull(SUM(dblOrderQty), 0) - isnull(sum(dblBillQty), 0) AS dblBalance
		FROM (
			SELECT DISTINCT ri.*
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
				AND strDistributionOption IN ('SPT')
			WHERE intSourceType = 1 and r.intEntityId=@intVendorCustomerId
				AND strReceiptType IN ('Direct') AND st.intCommodityId = @intCommodityId 
				AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
			) t
		) t
		
UNION
SELECT 6 AS intSeqId
		,'Net Purchase Payable' [strType]
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
			WHERE intSourceType = 1 and ch.intEntityId=@intVendorCustomerId	AND strReceiptType IN ('Purchase Contract')	
			AND ch.intCommodityId = @intCommodityId AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
			) t
		
		UNION 
				
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
			WHERE intSourceType = 1 and r.intEntityId=@intVendorCustomerId	AND strReceiptType IN ('Direct')
			 AND st.intCommodityId = @intCommodityId 
			 AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
			) t
		) t1
		
)t1

END

--DECLARE @intUnitMeasureId int
--DECLARE @intFromCommodityUnitMeasureId int
--DECLARE @intToCommodityUnitMeasureId int
--SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference

--SELECT @intFromCommodityUnitMeasureId=cuc.intCommodityUnitMeasureId,@intToCommodityUnitMeasureId=cuc1.intCommodityUnitMeasureId 
--FROM tblICCommodity t
--JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
--JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
--WHERE t.intCommodityId= @intCommodityId

--IF ISNULL(@intLocationId, 0) <> 0
--BEGIN
--SELECT intSeqId,strType, 
--		CASE WHEN strType = 'Net Payable' THEN dblTotal
--			 WHEN strType = 'Net Receivable' THEN dblTotal
--			 else dbo.fnCTConvertQuantityToTargetCommodityUOM(@intFromCommodityUnitMeasureId,@intToCommodityUnitMeasureId,dblTotal) end dblTotal
--FROM #temp 

--END
--ELSE
--BEGIN
--	SELECT intSeqId,strType,
--		dbo.fnCTConvertQuantityToTargetCommodityUOM(@intFromCommodityUnitMeasureId,@intToCommodityUnitMeasureId,dblTotal) dblTotal
--FROM #temp1
--END

IF @strPurchaseSales = 'Sales'
BEGIN
SELECT intSeqId,strType, dblTotal
		--dbo.fnCTConvertQuantityToTargetCommodityUOM(@intFromCommodityUnitMeasureId,@intToCommodityUnitMeasureId,dblTotal) dblTotal
FROM #temp where strType not like '%Purchase%' order by intSeqId
END
ELSE
BEGIN
SELECT intSeqId,strType, dblTotal
		--dbo.fnCTConvertQuantityToTargetCommodityUOM(@intFromCommodityUnitMeasureId,@intToCommodityUnitMeasureId,dblTotal) dblTotal
FROM #temp where strType not like '%Sales%' order by intSeqId
END