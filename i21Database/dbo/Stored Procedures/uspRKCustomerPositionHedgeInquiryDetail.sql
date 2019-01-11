CREATE PROCEDURE uspRKCustomerPositionHedgeInquiryDetail
	@intCommodityId int
	, @intLocationId int = null
	, @intSeqId int
	, @strGrainType nvarchar(20)
	, @intVendorCustomerId INT = NULL

AS

BEGIN
	
	IF (ISNULL(@intLocationId, 0) = 0)
	BEGIN
		SET @intLocationId = NULL
	END

	IF @intSeqId = 1
	BEGIN
		SELECT ri.intInventoryReceiptItemId
			, cl.strLocationName
			, r.strReceiptNumber strTicketNumber
			, r.dtmReceiptDate dtmTicketDateTime
			, r.strVendorRefNo as strCustomerReference
			, 'Purchase Contract' COLLATE Latin1_General_CI_AS as strDistributionOption
			, dblUnitCost AS dblUnitCost
			, isnull(dblUnitCost,0)*isnull(dblOpenReceive,0) AS dblQtyReceived
			, ch.intCommodityId
			, isnull(dblOpenReceive,0) dblTotal
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Purchase Contract')
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
		INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intContractDetailId=intLineNo AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE ch.intCommodityId = @intCommodityId and ch.intEntityId=@intVendorCustomerId
			AND r.intLocationId = ISNULL(@intLocationId, r.intLocationId)
			
		UNION ALL SELECT ri.intInventoryReceiptItemId
			, cl.strLocationName
			, r.strReceiptNumber strTicketNumber
			, r.dtmReceiptDate dtmTicketDateTime
			, r.strVendorRefNo as strCustomerReference
			, 'Direct' COLLATE Latin1_General_CI_AS as strDistributionOption
			, dblUnitCost AS dblUnitCost
			, isnull(dblUnitCost,0)*isnull(dblOpenReceive,0) AS dblQtyReceived
			, i.intCommodityId
			, isnull(dblOpenReceive,0) dblTotal
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Direct')
		AND r.intSourceType=1 and isnull(dblUnitCost,0) <> 0
		INNER JOIN tblICItem i on ri.intItemId=i.intItemId
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE i.intCommodityId = @intCommodityId AND r.intEntityVendorId =@intVendorCustomerId
			AND r.intLocationId = ISNULL(@intLocationId, r.intLocationId)
	END
	ELSE IF @intSeqId = 2
	BEGIN
		SELECT s.intInventoryShipmentId as intInventoryReceiptItemId
			, cd.strLocationName
			, s.strShipmentNumber strTicketNumber
			, s.dtmShipDate dtmTicketDateTime
			, s.strReferenceNumber as strCustomerReference
			, 'Spot Sale' COLLATE Latin1_General_CI_AS as strDistributionOption
			, dblUnitPrice AS dblUnitCost
			, ISNULL(dblQuantity,0)*ISNULL(dblUnitPrice,0) AS dblQtyReceived
			, cd.intCommodityId
			, ISNULL(dblQuantity,0) dblTotal
		FROM tblICInventoryShipment s
		JOIN tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId and intOrderType =4 and isnull(dblUnitPrice,0) <> 0
		JOIN vyuCTContractDetailView cd on cd.intContractDetailId=si.intLineNo and cd.intContractStatusId <> 3
		join tblICItem i on si.intItemId=i.intItemId  WHERE i.intCommodityId=@intCommodityId and s.intEntityCustomerId=@intVendorCustomerId
		AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
		
		UNION ALL SELECT s.intInventoryShipmentId as intInventoryReceiptItemId
			, cd.strLocationName
			, s.strShipmentNumber strTicketNumber
			, s.dtmShipDate dtmTicketDateTime
			, s.strReferenceNumber as strCustomerReference
			, 'Sales Contract' COLLATE Latin1_General_CI_AS as strDistributionOption
			, dblUnitPrice AS dblUnitCost
			, isnull(dblQuantity,0)*ISNULL(dblUnitPrice,0) AS dblQtyReceived
			, cd.intCommodityId
			, ISNULL(dblQuantity,0) dblTotal
		FROM tblICInventoryShipment s
		JOIN tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId
		JOIN vyuCTContractDetailView cd on cd.intContractDetailId=si.intLineNo and cd.intContractTypeId=2 and cd.intContractStatusId <> 3
		AND cd.intCommodityId=@intCommodityId and cd.intEntityId=@intVendorCustomerId
		AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
	END
	ELSE IF @intSeqId = 3
	BEGIN
		SELECT ri.intInventoryReceiptItemId
			, cl.strLocationName
			, r.strReceiptNumber strTicketNumber
			, r.dtmReceiptDate dtmTicketDateTime
			, r.strVendorRefNo as strCustomerReference
			, 'Purchase Contract' COLLATE Latin1_General_CI_AS as strDistributionOption
			, dblUnitCost AS dblUnitCost
			, isnull(dblOpenReceive,0)*isnull(dblUnitCost,0) AS dblQtyReceived
			, ch.intCommodityId
			, isnull(dblOpenReceive,0) dblTotal
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Purchase Contract')
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
		INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intContractDetailId=intLineNo AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE ch.intCommodityId = @intCommodityId and ch.intEntityId=@intVendorCustomerId
			AND r.intLocationId = ISNULL(@intLocationId, r.intLocationId)
		
		UNION ALL SELECT ri.intInventoryReceiptItemId
			, cl.strLocationName
			, r.strReceiptNumber strTicketNumber
			, r.dtmReceiptDate dtmTicketDateTime
			, r.strVendorRefNo as strCustomerReference
			, 'Direct' COLLATE Latin1_General_CI_AS as strDistributionOption
			, dblUnitCost AS dblUnitCost
			, isnull(dblOpenReceive,0)*isnull(dblUnitCost,0) AS dblQtyReceived
			, intCommodityId
			, isnull(dblOpenReceive,0) dblTotal
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Direct')
		AND r.intSourceType=1 and isnull(dblUnitCost,0) <> 0
		INNER JOIN tblICItem i on ri.intItemId=i.intItemId
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE i.intCommodityId = @intCommodityId AND r.intEntityVendorId =@intVendorCustomerId
			AND r.intLocationId = ISNULL(@intLocationId, r.intLocationId)
	END
	ELSE IF @intSeqId = 4
	BEGIN
		SELECT s.intInventoryShipmentId as intInventoryReceiptItemId
			, cd.strLocationName
			, s.strShipmentNumber strTicketNumber
			, s.dtmShipDate dtmTicketDateTime
			, s.strReferenceNumber as strCustomerReference
			, 'Purchase Contract' COLLATE Latin1_General_CI_AS as strDistributionOption
			, dblUnitPrice AS dblUnitCost
			, ISNULL(dblQuantity,0)*ISNULL(dblUnitPrice,0) AS dblQtyReceived
			, cd.intCommodityId
			, ISNULL(dblQuantity,0) dblTotal
		FROM tblICInventoryShipment s
		JOIN tblICInventoryShipmentItem si on s.intInventoryShipmentId=si.intInventoryShipmentId and intOrderType =4 and isnull(dblUnitPrice,0) <>0
		JOIN tblICItem i on si.intItemId=i.intItemId
		JOIN vyuCTContractDetailView cd on cd.intContractDetailId=si.intLineNo and cd.intContractStatusId <> 3
		WHERE i.intCommodityId=@intCommodityId and cd.intEntityId=@intVendorCustomerId
			AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
		
		UNION ALL SELECT s.intInventoryShipmentId as intInventoryReceiptItemId
			, cd.strLocationName
			, s.strShipmentNumber strTicketNumber
			, s.dtmShipDate dtmTicketDateTime
			, s.strReferenceNumber as strCustomerReference
			, 'Direct' COLLATE Latin1_General_CI_AS as strDistributionOption
			, dblUnitPrice AS dblUnitCost
			, ISNULL(dblQuantity,0)*ISNULL(dblUnitPrice,0) AS dblQtyReceived
			, cd.intCommodityId
			, ISNULL(dblQuantity,0) dblTotal  FROM tblICInventoryShipment s
		JOIN tblICInventoryShipmentItem si ON s.intInventoryShipmentId=si.intInventoryShipmentId
		JOIN vyuCTContractDetailView cd ON cd.intContractDetailId=si.intLineNo and cd.intContractTypeId=2 and cd.intContractStatusId <> 3
		AND cd.intCommodityId=@intCommodityId AND cd.intEntityId=@intVendorCustomerId
		AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
	END
	ELSE IF @intSeqId = 5
	BEGIN
		SELECT *
			,dblUnitCost-dblQtyReceived dblTotal
		FROM (
			SELECT DISTINCT ri.intInventoryReceiptItemId
				, cl.strLocationName
				, st.strTicketNumber
				, st.dtmTicketDateTime
				, strCustomerReference
				, 'CNT' COLLATE Latin1_General_CI_AS strDistributionOption
				, ch.intCommodityId
				, dblOrderQty AS dblUnitCost
				, isnull((SELECT (bd.dblQtyReceived) FROM tblAPBillDetail bd
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
				AND r.intLocationId = ISNULL(@intLocationId, r.intLocationId)
			
			UNION ALL SELECT DISTINCT ri.intInventoryReceiptItemId
				, cl.strLocationName
				, st.strTicketNumber
				, st.dtmTicketDateTime
				, strCustomerReference
				, 'SPT' COLLATE Latin1_General_CI_AS strDistributionOption
				, st.intCommodityId
				, dblOrderQty AS dblUnitCost
				, isnull((Select (bd.dblQtyReceived) FROM tblAPBillDetail bd
						INNER JOIN tblAPBill b on b.intBillId=bd.intBillId
						where  bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId and ysnPosted=1 ),0) AS dblQtyReceived
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('SPT')	
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1 AND strReceiptType IN ('Direct') AND st.intCommodityId = @intCommodityId
				AND r.intEntityVendorId=@intVendorCustomerId
				AND r.intLocationId = ISNULL(@intLocationId, r.intLocationId)
		) t
	END
	IF @intSeqId = 6
	BEGIN
		SELECT *
			, dblUnitCost-dblQtyReceived dblTotal
		FROM (
			SELECT DISTINCT ri.intInventoryReceiptItemId
				, cl.strLocationName
				, st.strTicketNumber
				, st.dtmTicketDateTime
				, strCustomerReference
				, 'SPT' COLLATE Latin1_General_CI_AS strDistributionOption
				, dblOrderQty*dblUnitCost AS dblUnitCost
				, isnull((Select (bd.dblQtyReceived*bd.dblCost) FROM tblAPBillDetail bd
						INNER JOIN tblAPBill b on b.intBillId=bd.intBillId
						where bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId and ysnPosted=1 ),0) AS dblQtyReceived
				, st.intCommodityId
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intContractDetailId=intLineNo AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1
				AND strReceiptType IN ('Purchase Contract')	AND ch.intCommodityId = @intCommodityId	and r.intEntityVendorId=@intVendorCustomerId
				AND r.intLocationId = ISNULL(@intLocationId, r.intLocationId)
			
			UNION ALL SELECT DISTINCT ri.intInventoryReceiptItemId
				, cl.strLocationName
				, st.strTicketNumber
				, st.dtmTicketDateTime
				, strCustomerReference
				, 'SPT' COLLATE Latin1_General_CI_AS strDistributionOption
				, dblOrderQty*dblUnitCost AS dblUnitCost
				, isnull((Select (bd.dblQtyReceived*bd.dblCost) FROM tblAPBillDetail bd
						INNER JOIN tblAPBill b on b.intBillId=bd.intBillId
						where  bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId and ysnPosted=1 ),0) AS dblQtyReceived
				, st.intCommodityId
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1 AND strReceiptType IN ('Direct') AND st.intCommodityId = @intCommodityId
				AND r.intEntityVendorId=@intVendorCustomerId
				AND r.intLocationId = ISNULL(@intLocationId, r.intLocationId)
		) t
	END
END