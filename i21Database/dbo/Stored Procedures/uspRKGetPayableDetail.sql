CREATE PROC uspRKGetPayableDetail 
	@intCommodityId int,
	@intLocationId int = NULL,
	@intSeqId int
AS
IF @intSeqId = 10
	BEGIN
		IF ISNULL(@intLocationId, 0) <> 0
		BEGIN
			
			SELECT *,dblUnitCost-dblQtyReceived as dblTotal FROM( 
			SELECT DISTINCT ri.intInventoryReceiptItemId,cl.strLocationName,st.intTicketNumber,st.dtmTicketDateTime,strCustomerReference,strDistributionOption,ri.dblLineTotal as dblUnitCost
				,(	SELECT isnull(sum(dblTotal), 0)
					FROM tblAPBillDetail apd
					WHERE apd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					) AS dblQtyReceived
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
				AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intPricingTypeId = 1
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=r.intLocationId
			WHERE intSourceType = 1
				AND strReceiptType IN ('Purchase Contract')
				AND st.intCommodityId = @intCommodityId
				AND r.intLocationId = @intLocationId
				) as t		
		
		UNION ALL
		
		SELECT *,dblUnitCost-dblQtyReceived as dblTotal from( 
			SELECT DISTINCT ri.intInventoryReceiptItemId,cl.strLocationName,st.intTicketNumber,st.dtmTicketDateTime,strCustomerReference,strDistributionOption,ri.dblLineTotal as dblUnitCost
				,(
					SELECT isnull(sum(dblTotal), 0)
					FROM tblAPBillDetail apd
					WHERE apd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					) AS dblQtyReceived
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=r.intLocationId
			WHERE intSourceType = 1
				AND strReceiptType IN ('Direct')
				AND st.intCommodityId = @intCommodityId
				AND r.intLocationId = @intLocationId
			) AS t
				
		END
		ELSE
		BEGIN 
				SELECT *,dblUnitCost-dblQtyReceived as dblTotal FROM( 
			SELECT DISTINCT ri.intInventoryReceiptItemId,cl.strLocationName,st.intTicketNumber,st.dtmTicketDateTime,strCustomerReference,strDistributionOption,ri.dblLineTotal as dblUnitCost
				,(	SELECT isnull(sum(dblTotal), 0)
					FROM tblAPBillDetail apd
					WHERE apd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					) AS dblQtyReceived
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
				AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intPricingTypeId = 1
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=r.intLocationId
			WHERE intSourceType = 1
				AND strReceiptType IN ('Purchase Contract')
				AND st.intCommodityId = @intCommodityId
				) as t		
		
		UNION ALL
		
		SELECT *,dblUnitCost-dblQtyReceived as dblTotal from( 
			SELECT DISTINCT ri.intInventoryReceiptItemId,cl.strLocationName,st.intTicketNumber,st.dtmTicketDateTime,strCustomerReference,strDistributionOption,ri.dblLineTotal as dblUnitCost
				,(
					SELECT isnull(sum(dblTotal), 0)
					FROM tblAPBillDetail apd
					WHERE apd.intInventoryReceiptItemId = ri.intInventoryReceiptItemId
					) AS dblQtyReceived
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=r.intLocationId
			WHERE intSourceType = 1
				AND strReceiptType IN ('Direct')
				AND st.intCommodityId = @intCommodityId		
			) as t
		END	
END		
ELSE IF @intSeqId = 11
	BEGIN
		IF ISNULL(@intLocationId, 0) <> 0
		BEGIN
				SELECT DISTINCT ri.intInventoryReceiptItemId,cl.strLocationName,st.intTicketNumber,st.dtmTicketDateTime,strCustomerReference,
				 strDistributionOption,
				 dblOrderQty as dblUnitCost,dblBillQty as dblQtyReceived,dblOrderQty-dblBillQty as dblTotal
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
				AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intPricingTypeId = 1
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=r.intLocationId
			WHERE intSourceType = 1	AND strReceiptType IN ('Purchase Contract')	AND ch.intCommodityId = @intCommodityId AND r.intLocationId = @intLocationId
			
		UNION ALL		

			SELECT DISTINCT ri.intInventoryReceiptItemId,cl.strLocationName,st.intTicketNumber,st.dtmTicketDateTime,strCustomerReference,
				 strDistributionOption,
				  dblOrderQty as dblUnitCost,dblBillQty as dblQtyReceived,dblOrderQty-dblBillQty as dblTotal
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=r.intLocationId
			WHERE intSourceType = 1
				AND strReceiptType IN ('Direct') AND st.intCommodityId = @intCommodityId AND r.intLocationId = @intLocationId
		
		END
		ELSE
		BEGIN
				SELECT DISTINCT ri.intInventoryReceiptItemId,cl.strLocationName,st.intTicketNumber,st.dtmTicketDateTime,strCustomerReference,
				 strDistributionOption,
				 dblOrderQty as dblUnitCost,dblBillQty as dblQtyReceived,dblOrderQty-dblBillQty as dblTotal
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId
				AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = ri.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intPricingTypeId = 1
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=r.intLocationId
			WHERE intSourceType = 1	AND strReceiptType IN ('Purchase Contract')	AND ch.intCommodityId = @intCommodityId
			
		UNION ALL		

			SELECT DISTINCT ri.intInventoryReceiptItemId,cl.strLocationName,st.intTicketNumber,st.dtmTicketDateTime,strCustomerReference,
				 strDistributionOption,
				 dblOrderQty as dblUnitCost,dblBillQty as dblQtyReceived,dblOrderQty-dblBillQty as dblTotal
			FROM tblICInventoryReceipt r
			INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
			INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=r.intLocationId
			WHERE intSourceType = 1
				AND strReceiptType IN ('Direct') AND st.intCommodityId = @intCommodityId
		END
END

ELSE IF @intSeqId = 12
	BEGIN
		IF ISNULL(@intLocationId, 0) <> 0
		BEGIN
			SELECT *,dblUnitCost-dblQtyReceived as dblTotal from( 
			SELECT DISTINCT isi.intInventoryShipmentItemId as intInventoryReceiptItemId,cl.strLocationName,st.intTicketNumber,st.dtmTicketDateTime,strCustomerReference,strDistributionOption,
					 isi.dblQuantity*isi.dblUnitPrice as dblUnitCost,
					(SELECT isnull(SUM(R.dblAmountApplied),0)
					 FROM vyuARCustomerPaymentHistoryReport R
					 LEFT OUTER JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					 WHERE isi.intInventoryShipmentItemId=I.intInventoryShipmentItemId and R.intCompanyLocationId=@intLocationId) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intPricingTypeId = 1
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId
			WHERE intOrderType IN (1)	AND intSourceType = 1 AND st.intCommodityId = @intCommodityId  AND st.intProcessingLocationId = @intLocationId)t

			UNION ALL
			SELECT *,dblUnitCost-dblQtyReceived as dblTotal from( 
			SELECT DISTINCT isi.intInventoryShipmentItemId  as intInventoryReceiptItemId,cl.strLocationName,st.intTicketNumber,st.dtmTicketDateTime,strCustomerReference,strDistributionOption,
					 isi.dblQuantity*isi.dblUnitPrice as dblUnitCost,
					(SELECT isnull(SUM(R.dblAmountApplied),0)
					 FROM vyuARCustomerPaymentHistoryReport R
					 LEFT OUTER JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					 WHERE isi.intInventoryShipmentItemId=I.intInventoryShipmentItemId and R.intCompanyLocationId=@intLocationId) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId
			WHERE intOrderType IN (4) AND intSourceType = 1	AND st.intCommodityId = @intCommodityId and st.intProcessingLocationId = @intLocationId)t
		
		END
		ELSE
		BEGIN
			SELECT *,dblUnitCost-dblQtyReceived as dblTotal from( 
			SELECT DISTINCT isi.intInventoryShipmentItemId as intInventoryReceiptItemId,cl.strLocationName,st.intTicketNumber,st.dtmTicketDateTime,strCustomerReference,strDistributionOption,
					 isi.dblQuantity*isi.dblUnitPrice as dblUnitCost,
					(SELECT isnull(SUM(R.dblAmountApplied),0)
					 FROM vyuARCustomerPaymentHistoryReport R
					 LEFT OUTER JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					 WHERE isi.intInventoryShipmentItemId=I.intInventoryShipmentItemId) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intPricingTypeId = 1
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId
			WHERE intOrderType IN (1)	AND intSourceType = 1 AND st.intCommodityId = @intCommodityId)t

			UNION ALL
			SELECT *,dblUnitCost-dblQtyReceived as dblTotal from( 
			SELECT DISTINCT isi.intInventoryShipmentItemId  as intInventoryReceiptItemId,cl.strLocationName,st.intTicketNumber,st.dtmTicketDateTime,strCustomerReference,strDistributionOption,
					 isi.dblQuantity*isi.dblUnitPrice as dblUnitCost,
					(SELECT isnull(SUM(R.dblAmountApplied),0)
					 FROM vyuARCustomerPaymentHistoryReport R
					 LEFT OUTER JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					 WHERE isi.intInventoryShipmentItemId=I.intInventoryShipmentItemId ) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId
			WHERE intOrderType IN (4) AND intSourceType = 1	AND st.intCommodityId = @intCommodityId)t
		END
END

ELSE IF @intSeqId = 13
	BEGIN
		IF ISNULL(@intLocationId, 0) <> 0
		BEGIN
						SELECT *,dblUnitCost-dblQtyReceived as dblTotal from( 
			SELECT DISTINCT isi.intInventoryShipmentItemId as intInventoryReceiptItemId,cl.strLocationName,st.intTicketNumber,st.dtmTicketDateTime,strCustomerReference,strDistributionOption,
					 isi.dblQuantity as dblUnitCost,
					(SELECT isnull(SUM(I.dblQtyShipped),0)
					 FROM vyuARCustomerPaymentHistoryReport R
					 LEFT OUTER JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					 WHERE isi.intInventoryShipmentItemId=I.intInventoryShipmentItemId and R.intCompanyLocationId=@intLocationId) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intPricingTypeId = 1
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId
			WHERE intOrderType IN (1)	AND intSourceType = 1 AND st.intCommodityId = @intCommodityId AND st.intProcessingLocationId = @intLocationId)t

			UNION ALL
			SELECT *,dblUnitCost-dblQtyReceived as dblTotal from( 
			SELECT DISTINCT isi.intInventoryShipmentItemId  as intInventoryReceiptItemId,cl.strLocationName,st.intTicketNumber,st.dtmTicketDateTime,strCustomerReference,strDistributionOption,
					 isi.dblQuantity as dblUnitCost,
					(SELECT isnull(SUM(I.dblQtyShipped),0)
					 FROM vyuARCustomerPaymentHistoryReport R
					 LEFT OUTER JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					 WHERE isi.intInventoryShipmentItemId=I.intInventoryShipmentItemId and R.intCompanyLocationId=@intLocationId) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId
			WHERE intOrderType IN (4) AND intSourceType = 1	AND st.intCommodityId = @intCommodityId AND st.intProcessingLocationId = @intLocationId)t
		
		END
		ELSE
		BEGIN
			SELECT *,dblUnitCost-dblQtyReceived as dblTotal from( 
			SELECT DISTINCT isi.intInventoryShipmentItemId as intInventoryReceiptItemId,cl.strLocationName,st.intTicketNumber,st.dtmTicketDateTime,strCustomerReference,strDistributionOption,
					 isi.dblQuantity as dblUnitCost,
					(SELECT isnull(SUM(I.dblQtyShipped),0)
					 FROM vyuARCustomerPaymentHistoryReport R
					 LEFT OUTER JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					 WHERE isi.intInventoryShipmentItemId=I.intInventoryShipmentItemId) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('CNT')
			INNER JOIN tblCTContractHeader ch ON ch.intContractHeaderId = isi.intOrderId
			INNER JOIN tblCTContractDetail cd ON cd.intContractHeaderId = ch.intContractHeaderId AND cd.intPricingTypeId = 1
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId
			WHERE intOrderType IN (1)	AND intSourceType = 1 AND st.intCommodityId = @intCommodityId )t

			UNION ALL
			SELECT *,dblUnitCost-dblQtyReceived as dblTotal from( 
			SELECT DISTINCT isi.intInventoryShipmentItemId  as intInventoryReceiptItemId,cl.strLocationName,st.intTicketNumber,st.dtmTicketDateTime,strCustomerReference,strDistributionOption,
					 isi.dblQuantity as dblUnitCost,
					(SELECT isnull(SUM(I.dblQtyShipped),0)
					 FROM vyuARCustomerPaymentHistoryReport R
					 LEFT OUTER JOIN tblARInvoiceDetail I ON R.intInvoiceId = I.intInvoiceId
					 WHERE isi.intInventoryShipmentItemId=I.intInventoryShipmentItemId) dblQtyReceived
			FROM tblICInventoryShipment ici
			INNER JOIN tblICInventoryShipmentItem isi ON isi.intInventoryShipmentId = ici.intInventoryShipmentId
			INNER JOIN tblSCTicket st ON st.intTicketId = isi.intSourceId AND strDistributionOption IN ('SPT')
			INNER JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId
			WHERE intOrderType IN (4) AND intSourceType = 1	AND st.intCommodityId = @intCommodityId)t
		END
END