CREATE PROCEDURE uspRKCustomerPositionHedgeInquiryDetail
	@intCommodityId INT
	, @intLocationId INT = NULL
	, @intSeqId INT
	, @strGrainType NVARCHAR(20)
	, @intVendorCustomerId INT = NULL

AS

BEGIN

	IF ISNULL(@intLocationId, 0) = 0
	BEGIN
		SET @intLocationId = NULL
	END

	IF @intSeqId = 1
	BEGIN
		SELECT ri.intInventoryReceiptItemId
			, cl.strLocationName COLLATE Latin1_General_CI_AS
			, strTicketNumber = r.strReceiptNumber COLLATE Latin1_General_CI_AS
			, dtmTicketDateTime = r.dtmReceiptDate
			, strCustomerReference = r.strVendorRefNo COLLATE Latin1_General_CI_AS
			, strDistributionOption = 'Purchase Contract' COLLATE Latin1_General_CI_AS
			, dblUnitCost = dblUnitCost
			, dblQtyReceived = ISNULL(dblUnitCost, 0) * ISNULL(dblOpenReceive, 0)
			, ch.intCommodityId
			, dblTotal = ISNULL(dblOpenReceive, 0)
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType IN ('Purchase Contract')
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
		INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intContractDetailId=intLineNo AND cd.intPricingTypeId = 1 AND cd.intContractStatusId <> 3
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE ch.intCommodityId = @intCommodityId AND ch.intEntityId = @intVendorCustomerId
			AND r.intLocationId = ISNULL(@intLocationId, r.intLocationId)
			
		UNION ALL SELECT ri.intInventoryReceiptItemId
			, cl.strLocationName COLLATE Latin1_General_CI_AS
			, strTicketNumber = r.strReceiptNumber COLLATE Latin1_General_CI_AS
			, dtmTicketDateTime = r.dtmReceiptDate
			, strCustomerReference = r.strVendorRefNo COLLATE Latin1_General_CI_AS
			, strDistributionOption = 'Direct' COLLATE Latin1_General_CI_AS
			, dblUnitCost = dblUnitCost
			, dblQtyReceived = ISNULL(dblUnitCost, 0) * ISNULL(dblOpenReceive, 0)
			, i.intCommodityId
			, dblTotal = ISNULL(dblOpenReceive, 0)
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType IN ('Direct')
			AND r.intSourceType = 1 AND ISNULL(dblUnitCost,0) <> 0
		INNER JOIN tblICItem i ON ri.intItemId = i.intItemId
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE i.intCommodityId = @intCommodityId AND r.intEntityVendorId = @intVendorCustomerId
			AND r.intLocationId = ISNULL(@intLocationId, r.intLocationId)
	END
	ELSE IF @intSeqId = 2
	BEGIN
		SELECT s.intInventoryShipmentId as intInventoryReceiptItemId
			, cd.strLocationName COLLATE Latin1_General_CI_AS
			, strTicketNumber = s.strShipmentNumber COLLATE Latin1_General_CI_AS
			, dtmTicketDateTime = s.dtmShipDate
			, strCustomerReference = s.strReferenceNumber COLLATE Latin1_General_CI_AS
			, strDistributionOption = 'Spot Sale' COLLATE Latin1_General_CI_AS
			, dblUnitCost = dblUnitPrice
			, dblQtyReceived = ISNULL(dblQuantity, 0) * ISNULL(dblUnitPrice, 0)
			, cd.intCommodityId
			, dblTotal = ISNULL(dblQuantity, 0)
		FROM tblICInventoryShipment s
		JOIN tblICInventoryShipmentItem si ON s.intInventoryShipmentId = si.intInventoryShipmentId AND intOrderType = 4 AND ISNULL(dblUnitPrice, 0) <> 0
		JOIN vyuCTContractDetailView cd ON cd.intContractDetailId = si.intLineNo AND cd.intContractStatusId <> 3
		JOIN tblICItem i ON si.intItemId = i.intItemId
		WHERE i.intCommodityId = @intCommodityId AND s.intEntityCustomerId = @intVendorCustomerId
			AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
		
		UNION ALL SELECT intInventoryReceiptItemId = s.intInventoryShipmentId
			,cd.strLocationName COLLATE Latin1_General_CI_AS
			,strTicketNumber = s.strShipmentNumber COLLATE Latin1_General_CI_AS
			,dtmTicketDateTime = s.dtmShipDate
			,strCustomerReference = s.strReferenceNumber COLLATE Latin1_General_CI_AS
			,strDistributionOption = 'Sales Contract' COLLATE Latin1_General_CI_AS
			,dblUnitCost = dblUnitPrice
			,dblQtyReceived = ISNULL(dblQuantity, 0) * ISNULL(dblUnitPrice, 0)
			,cd.intCommodityId
			,dblTotal = ISNULL(dblQuantity, 0)
		FROM tblICInventoryShipment s
		JOIN tblICInventoryShipmentItem si ON s.intInventoryShipmentId = si.intInventoryShipmentId
		JOIN vyuCTContractDetailView cd ON cd.intContractDetailId = si.intLineNo AND cd.intContractTypeId = 2 AND cd.intContractStatusId <> 3
		AND cd.intCommodityId = @intCommodityId AND cd.intEntityId = @intVendorCustomerId
		AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
	END
	ELSE IF @intSeqId = 3
	BEGIN
		SELECT ri.intInventoryReceiptItemId
			,cl.strLocationName COLLATE Latin1_General_CI_AS
			,strTicketNumber = r.strReceiptNumber COLLATE Latin1_General_CI_AS
			,r.dtmReceiptDate dtmTicketDateTime
			,strCustomerReference = r.strVendorRefNo COLLATE Latin1_General_CI_AS
			,strDistributionOption = 'Purchase Contract' COLLATE Latin1_General_CI_AS
			,dblUnitCost AS dblUnitCost
			,ISNULL(dblOpenReceive,0)*ISNULL(dblUnitCost,0) AS dblQtyReceived
			,ch.intCommodityId,
			ISNULL(dblOpenReceive,0) dblTotal
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Purchase Contract')
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
		INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intContractDetailId=intLineNo AND cd.intPricingTypeId = 1 AND cd.intContractStatusId <> 3
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE ch.intCommodityId = @intCommodityId AND ch.intEntityId=@intVendorCustomerId 
		AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end

		UNION

		SELECT ri.intInventoryReceiptItemId
					,cl.strLocationName COLLATE Latin1_General_CI_AS
					,r.strReceiptNumber COLLATE Latin1_General_CI_AS strTicketNumber
					,r.dtmReceiptDate dtmTicketDateTime
					,r.strVendorRefNo COLLATE Latin1_General_CI_AS as strCustomerReference
					,'Direct' COLLATE Latin1_General_CI_AS as strDistributionOption
					,dblUnitCost AS dblUnitCost
					,ISNULL(dblOpenReceive,0)*ISNULL(dblUnitCost,0) AS dblQtyReceived
					,intCommodityId,
					ISNULL(dblOpenReceive,0) dblTotal
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType in('Direct') 
		AND r.intSourceType=1 AND ISNULL(dblUnitCost,0) <> 0 
		INNER JOIN tblICItem i ON ri.intItemId=i.intItemId
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE i.intCommodityId = @intCommodityId AND r.intEntityVendorId =@intVendorCustomerId
		AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
	
END
ELSE IF @intSeqId= 4
		BEGIN				
		select 
		s.intInventoryShipmentId as intInventoryReceiptItemId
			,cd.strLocationName COLLATE Latin1_General_CI_AS
			,s.strShipmentNumber COLLATE Latin1_General_CI_AS strTicketNumber
			,s.dtmShipDate dtmTicketDateTime
			,s.strReferenceNumber COLLATE Latin1_General_CI_AS as strCustomerReference
			,'Purchase Contract' COLLATE Latin1_General_CI_AS as strDistributionOption			
			,dblUnitPrice AS dblUnitCost
			,ISNULL(dblQuantity,0)*ISNULL(dblUnitPrice,0) AS dblQtyReceived
			,cd.intCommodityId,
			ISNULL(dblQuantity,0) dblTotal 
		FROM tblICInventoryShipment s
		JOIN tblICInventoryShipmentItem si ON s.intInventoryShipmentId=si.intInventoryShipmentId AND intOrderType =4 AND ISNULL(dblUnitPrice,0) <>0
		JOIN tblICItem i ON si.intItemId=i.intItemId 
		JOIN vyuCTContractDetailView cd ON cd.intContractDetailId=si.intLineNo AND cd.intContractStatusId <> 3
		WHERE i.intCommodityId=@intCommodityId AND cd.intEntityId=@intVendorCustomerId  
		AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end
		UNION
		SELECT 
		s.intInventoryShipmentId as intInventoryReceiptItemId
			,cd.strLocationName COLLATE Latin1_General_CI_AS
			,s.strShipmentNumber COLLATE Latin1_General_CI_AS strTicketNumber
			,s.dtmShipDate dtmTicketDateTime
			,s.strReferenceNumber COLLATE Latin1_General_CI_AS as strCustomerReference
			,'Direct' COLLATE Latin1_General_CI_AS as strDistributionOption
			,dblUnitPrice AS dblUnitCost
			,ISNULL(dblQuantity,0)*ISNULL(dblUnitPrice,0) AS dblQtyReceived
			,cd.intCommodityId,
			ISNULL(dblQuantity,0) dblTotal  FROM tblICInventoryShipment s
		JOIN tblICInventoryShipmentItem si ON s.intInventoryShipmentId=si.intInventoryShipmentId 
		JOIN vyuCTContractDetailView cd ON cd.intContractDetailId=si.intLineNo AND cd.intContractTypeId=2 AND cd.intContractStatusId <> 3
		AND cd.intCommodityId=@intCommodityId AND cd.intEntityId=@intVendorCustomerId 
		AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then cd.intCompanyLocationId else @intLocationId end	
END

ELSE IF @intSeqId= 5
		BEGIN
		SELECT *,dblUnitCost-dblQtyReceived dblTotal FROM(				
		SELECT DISTINCT ri.intInventoryReceiptItemId
			,cl.strLocationName COLLATE Latin1_General_CI_AS
			,st.strTicketNumber COLLATE Latin1_General_CI_AS
			,st.dtmTicketDateTime
			,strCustomerReference COLLATE Latin1_General_CI_AS
			,'CNT' COLLATE Latin1_General_CI_AS strDistributionOption
			,ch.intCommodityId
			,dblOrderQty AS dblUnitCost
			,ISNULL((SELECT (bd.dblQtyReceived) FROM tblAPBillDetail bd 
					INNER JOIN tblAPBill b ON b.intBillId=bd.intBillId
					WHERE  bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId AND ysnPosted=1 ),0) AS dblQtyReceived			
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intContractDetailId=intLineNo AND cd.intPricingTypeId = 1 AND cd.intContractStatusId <> 3
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1
				AND strReceiptType IN ('Purchase Contract')	AND ch.intCommodityId = @intCommodityId	and r.intEntityVendorId=@intVendorCustomerId
				AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
		
		UNION ALL
		
		SELECT DISTINCT ri.intInventoryReceiptItemId
			,cl.strLocationName COLLATE Latin1_General_CI_AS
			,st.strTicketNumber COLLATE Latin1_General_CI_AS
			,st.dtmTicketDateTime
			,strCustomerReference COLLATE Latin1_General_CI_AS
			,'SPT' COLLATE Latin1_General_CI_AS strDistributionOption
			,st.intCommodityId
			,dblOrderQty AS dblUnitCost
			,ISNULL((Select (bd.dblQtyReceived) FROM tblAPBillDetail bd 
				INNER JOIN tblAPBill b ON b.intBillId=bd.intBillId
				where  bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId AND ysnPosted=1 ),0) AS dblQtyReceived	
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('SPT')	
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId		
			WHERE intSourceType = 1 AND strReceiptType IN ('Direct') AND st.intCommodityId = @intCommodityId  
			AND r.intEntityVendorId=@intVendorCustomerId
				AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end)t
	
END

IF @intSeqId= 6
		BEGIN
		SELECT *,dblUnitCost-dblQtyReceived dblTotal FROM(					
			SELECT DISTINCT ri.intInventoryReceiptItemId
			,cl.strLocationName COLLATE Latin1_General_CI_AS
			,st.strTicketNumber COLLATE Latin1_General_CI_AS
			,st.dtmTicketDateTime
			,strCustomerReference COLLATE Latin1_General_CI_AS
			,'SPT' COLLATE Latin1_General_CI_AS strDistributionOption
			,dblOrderQty*dblUnitCost AS dblUnitCost
			,ISNULL((Select (bd.dblQtyReceived*bd.dblCost) FROM tblAPBillDetail bd 
				INNER JOIN tblAPBill b ON b.intBillId=bd.intBillId
				where  bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId AND ysnPosted=1 ),0) AS dblQtyReceived
			,st.intCommodityId
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intContractDetailId=intLineNo AND cd.intPricingTypeId = 1 AND cd.intContractStatusId <> 3
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1
				AND strReceiptType IN ('Purchase Contract')	AND ch.intCommodityId = @intCommodityId	and r.intEntityVendorId=@intVendorCustomerId
				AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end
		
		UNION ALL
		
		SELECT DISTINCT ri.intInventoryReceiptItemId
			,cl.strLocationName COLLATE Latin1_General_CI_AS
			,st.strTicketNumber COLLATE Latin1_General_CI_AS
			,st.dtmTicketDateTime
			,strCustomerReference COLLATE Latin1_General_CI_AS
			,'SPT' COLLATE Latin1_General_CI_AS strDistributionOption
			,dblOrderQty*dblUnitCost AS dblUnitCost
			,ISNULL((Select (bd.dblQtyReceived*bd.dblCost) FROM tblAPBillDetail bd 
				INNER JOIN tblAPBill b ON b.intBillId=bd.intBillId
				where  bd.intInventoryReceiptItemId=ri.intInventoryReceiptItemId AND ysnPosted=1 ),0) AS dblQtyReceived
			,st.intCommodityId
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('SPT')	
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId		
			WHERE intSourceType = 1 AND strReceiptType IN ('Direct') AND st.intCommodityId = @intCommodityId  
			AND r.intEntityVendorId=@intVendorCustomerId AND r.intLocationId = CASE WHEN ISNULL(@intLocationId,0)=0 then r.intLocationId else @intLocationId end)t
	
END


END
