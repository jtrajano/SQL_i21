CREATE PROCEDURE uspRKGetPayableDetail  
 	 @intCommodityId INT 
	,@intLocationId INT = NULL
	,@intSeqId INT
AS
DECLARE @tblTemp TABLE (
	intInventoryReceiptItemId INT
	,strLocationName NVARCHAR(50)
	,strTicketNumber  NVARCHAR(50)
	,dtmTicketDateTime DATETIME
	,strCustomerReference NVARCHAR(100)
	,strDistributionOption NVARCHAR(50)
	,dblUnitCost NUMERIC(24, 10)
	,dblQtyReceived NUMERIC(24, 10)
	,intCommodityId INT
	,dblTotal NUMERIC(24, 10)
	)

IF @intSeqId = 10
BEGIN
	IF ISNULL(@intLocationId, 0) <> 0
	BEGIN
		INSERT INTO @tblTemp (
			intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption
			,dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblTotal
			)
		SELECT intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, 
			 dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblUnitCost - dblQtyReceived AS dblTotal
		FROM (
			SELECT DISTINCT ri.intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,ri.dblLineTotal AS dblUnitCost
				,(
					SELECT isnull(sum(dblTotal), 0)
					FROM tblAPBillDetail apd
					WHERE apd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					) AS dblQtyReceived
				,ch.intCommodityId
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
				AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
				AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1 and cd.intContractStatusId <> 3
				AND strReceiptType IN ('Purchase Contract')
				AND st.intCommodityId = @intCommodityId
				AND r.intLocationId = @intLocationId
			) AS t
		
		UNION ALL
		
		SELECT intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblUnitCost - dblQtyReceived AS dblTotal
		FROM (
			SELECT DISTINCT ri.intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,ri.dblLineTotal AS dblUnitCost
				,(
					SELECT isnull(sum(dblTotal), 0)
					FROM tblAPBillDetail apd
					WHERE apd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					) AS dblQtyReceived
				,st.intCommodityId
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
				AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1
				AND strReceiptType IN ('Direct')
				AND st.intCommodityId = @intCommodityId
				AND r.intLocationId = @intLocationId
			) AS t
	END
	ELSE
	BEGIN
		INSERT INTO @tblTemp (
			intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption
			,dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblTotal)
		SELECT intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblUnitCost - dblQtyReceived AS dblTotal
		FROM (
			SELECT DISTINCT ri.intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,ri.dblLineTotal AS dblUnitCost
				,(
					SELECT isnull(sum(dblTotal), 0)
					FROM tblAPBillDetail apd
					WHERE apd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					) AS dblQtyReceived
				,ch.intCommodityId
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
				AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
				AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1 and cd.intContractStatusId <> 3
				AND strReceiptType IN ('Purchase Contract')
				AND st.intCommodityId = @intCommodityId
			) AS t
		
		UNION ALL
		
		SELECT intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblUnitCost - dblQtyReceived AS dblTotal
		FROM (
			SELECT DISTINCT ri.intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,ri.dblLineTotal AS dblUnitCost
				,(
					SELECT isnull(sum(dblTotal), 0)
					FROM tblAPBillDetail apd
					WHERE apd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					) AS dblQtyReceived
				,st.intCommodityId
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
				AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
			WHERE intSourceType = 1
				AND strReceiptType IN ('Direct')
				AND st.intCommodityId = @intCommodityId
			) AS t
	END
END
ELSE IF @intSeqId = 11
BEGIN
	IF ISNULL(@intLocationId, 0) <> 0
	BEGIN
	
		INSERT INTO @tblTemp (
			intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption
			,dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblTotal			
			)
		SELECT DISTINCT ri.intInventoryReceiptItemId
			,cl.strLocationName
			,st.strTicketNumber
			,st.dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption
			,dblOrderQty AS dblUnitCost
			,dblBillQty AS dblQtyReceived
			,ch.intCommodityId
			,dblOrderQty - dblBillQty AS dblTotal
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
			AND strDistributionOption IN ('CNT')
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
		INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
			AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE intSourceType = 1 and cd.intContractStatusId <> 3
			AND strReceiptType IN ('Purchase Contract')
			AND ch.intCommodityId = @intCommodityId
			AND r.intLocationId = @intLocationId
		
		UNION ALL
		
		SELECT DISTINCT ri.intInventoryReceiptItemId
			,cl.strLocationName
			,st.strTicketNumber
			,st.dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption
			,dblOrderQty AS dblUnitCost
			,dblBillQty AS dblQtyReceived
			,st.intCommodityId
			,dblOrderQty - dblBillQty AS dblTotal
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
			AND strDistributionOption IN ('SPT')
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE intSourceType = 1
			AND strReceiptType IN ('Direct')
			AND st.intCommodityId = @intCommodityId
			AND r.intLocationId = @intLocationId
	END
	ELSE
	BEGIN
		INSERT INTO @tblTemp (
			intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption
			,dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblTotal			
			)
		SELECT DISTINCT ri.intInventoryReceiptItemId
			,cl.strLocationName
			,st.strTicketNumber
			,st.dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption
			,dblOrderQty AS dblUnitCost
			,dblBillQty AS dblQtyReceived
			,ch.intCommodityId
			,dblOrderQty - dblBillQty AS dblTotal
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
			AND strDistributionOption IN ('CNT')
		INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
		INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
			AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE intSourceType = 1 and cd.intContractStatusId <> 3
			AND strReceiptType IN ('Purchase Contract')
			AND ch.intCommodityId = @intCommodityId
		
		UNION ALL
		
		SELECT DISTINCT ri.intInventoryReceiptItemId
			,cl.strLocationName
			,st.strTicketNumber
			,st.dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption
			,dblOrderQty AS dblUnitCost
			,dblBillQty AS dblQtyReceived
			,st.intCommodityId
			,dblOrderQty - dblBillQty AS dblTotal
		FROM tblICInventoryReceipt r
		INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
			AND strDistributionOption IN ('SPT')
		INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = r.intLocationId
		WHERE intSourceType = 1
			AND strReceiptType IN ('Direct')
			AND st.intCommodityId = @intCommodityId
	END
END
ELSE IF @intSeqId = 12
BEGIN
	IF ISNULL(@intLocationId, 0) <> 0
	BEGIN
		INSERT INTO @tblTemp (
			intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption
			,dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblTotal)
		SELECT intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblUnitCost - dblQtyReceived AS dblTotal
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,(
					SELECT isnull(SUM(R.dblAmountApplied), 0)
					FROM vyuARCustomerPaymentHistoryReport R
					LEFT JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					WHERE isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
						AND R.intCompanyLocationId = @intLocationId
					) dblQtyReceived
				,st.intCommodityId
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
				AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
				AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (1)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId = @intLocationId
			) t
		
		UNION ALL
		
		SELECT intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblUnitCost - dblQtyReceived AS dblTotal
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,st.intCommodityId
				,(
					SELECT isnull(SUM(R.dblAmountApplied), 0)
					FROM vyuARCustomerPaymentHistoryReport R
					LEFT JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					WHERE isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
						AND R.intCompanyLocationId = @intLocationId
					) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
				AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (4)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId = @intLocationId
			) t
	END
	ELSE
	BEGIN
		INSERT INTO @tblTemp (
			intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption
			,dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblTotal		
			)
		SELECT intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblUnitCost - dblQtyReceived AS dblTotal
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,st.intCommodityId
				,(
					SELECT isnull(SUM(R.dblAmountApplied), 0)
					FROM vyuARCustomerPaymentHistoryReport R
					LEFT JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					WHERE isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
					) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
				AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
				AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (1)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
			) t
		
		UNION ALL
		
		SELECT intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblUnitCost - dblQtyReceived AS dblTotal
		FROM (
			SELECT DISTINCT isi.intInventoryShipmentItemId AS intInventoryReceiptItemId
				,cl.strLocationName
				,st.strTicketNumber
				,st.dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,isi.dblQuantity * isi.dblUnitPrice AS dblUnitCost
				,st.intCommodityId
				,(
					SELECT isnull(SUM(R.dblAmountApplied), 0)
					FROM vyuARCustomerPaymentHistoryReport R
					LEFT JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					WHERE isi.intInventoryShipmentItemId = I.intInventoryShipmentItemId
					) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
				AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (4)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
			) t
	END
END
ELSE IF @intSeqId = 13
BEGIN
	IF ISNULL(@intLocationId, 0) <> 0
	BEGIN
		INSERT INTO @tblTemp (
			intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption
			,dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblTotal			
			)
		SELECT intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblUnitCost - dblQtyReceived AS dblTotal
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
						AND R.intCompanyLocationId = @intLocationId
					) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
				AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
				AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (1)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId = @intLocationId
			) t
		
		UNION ALL
		
		SELECT intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblUnitCost - dblQtyReceived AS dblTotal
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
						AND R.intCompanyLocationId = @intLocationId
					) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
				AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (4)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
				AND st.intProcessingLocationId = @intLocationId
			) t
	END
	ELSE
	BEGIN
		INSERT INTO @tblTemp (
			intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption
			,dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblTotal		
			)
		SELECT intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblUnitCost - dblQtyReceived AS dblTotal
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
					) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
				AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId
				AND cd.intPricingTypeId = 1 and cd.intContractStatusId <> 3
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (1)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
			) t
		
		UNION ALL
		
		SELECT intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption, dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblUnitCost - dblQtyReceived AS dblTotal
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
					) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId
				AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
			WHERE intOrderType IN (4)
				AND intSourceType = 1
				AND st.intCommodityId = @intCommodityId
			) t
	END
END

DECLARE @intUnitMeasureId int
SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference

if isnull(@intUnitMeasureId,'')<> ''
BEGIN
	IF ((@intSeqId = 11) OR (@intSeqId=13))
		BEGIN
			SELECT intInventoryReceiptItemId
						,strLocationName
						,strTicketNumber
						,dtmTicketDateTime
						,strCustomerReference
						,strDistributionOption, 
						 dblUnitCost
						,dblQtyReceived,cuc.intCommodityUnitMeasureId,cuc1.intCommodityUnitMeasureId,t.intCommodityId
						,isnull(dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId,case when isnull(cuc1.intCommodityUnitMeasureId,0) = 0 then cuc.intCommodityUnitMeasureId else cuc1.intCommodityUnitMeasureId end,dblTotal),0) dblTotal
				FROM @tblTemp t
			JOIN tblICCommodityUnitMeasure cuc on t.intCommodityId=cuc.intCommodityId and cuc.ysnDefault=1 
			JOIN tblICCommodityUnitMeasure cuc1 on t.intCommodityId=cuc1.intCommodityId and @intUnitMeasureId=cuc1.intUnitMeasureId
		END
	ELSE
		BEGIN
		SELECT intInventoryReceiptItemId
				,strLocationName
				,strTicketNumber
				,dtmTicketDateTime
				,strCustomerReference
				,strDistributionOption
				,dblUnitCost
				,dblQtyReceived
				,intCommodityId
				,dblTotal FROM @tblTemp
			END	
END
ELSE
BEGIN
SELECT intInventoryReceiptItemId
			,strLocationName
			,strTicketNumber
			,dtmTicketDateTime
			,strCustomerReference
			,strDistributionOption
			,dblUnitCost
			,dblQtyReceived
			,intCommodityId
			,dblTotal FROM @tblTemp
END

