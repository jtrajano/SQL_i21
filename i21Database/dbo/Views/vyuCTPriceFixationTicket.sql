CREATE VIEW [dbo].[vyuCTPriceFixationTicket]
AS 
SELECT intPriceFixationTicketId
,intPriceFixationId
,intPricingId
,intPricingNumber
,dblCash
,intTicketId
,strTicketNumber
,intInventoryShipmentId
,intInventoryReceiptId
,intInventoryShipmentReceiptId
,strShipmentReceiptNumber
,dblQuantity
,dtmDeliveryDate
,strInvoiceVoucher
,intDetailId 
,intConcurrencyId
FROM 
(
	SELECT intPriceFixationTicketId
	,ft.intPriceFixationId
	,intPricingId
	,intPricingNumber = fd.intNumber
	,dblCash = fd.dblCashPrice
	,ft.intTicketId
	,strTicketNumber
	,ft.intInventoryShipmentId
	,ft.intInventoryReceiptId
	,intInventoryShipmentReceiptId = ft.intInventoryShipmentId
	,strShipmentReceiptNumber
	,ft.dblQuantity
	,dtmDeliveryDate
	,strInvoiceVoucher
	,intDetailId
	,ft.intConcurrencyId 
	FROM tblCTPriceFixationTicket ft
	INNER JOIN tblCTPriceFixationDetail fd ON ft.intPricingId = fd.intPriceFixationDetailId
	OUTER APPLY
	(
		SELECT a.intInventoryShipmentId
		,a.strTicketNumber
		,strShipmentReceiptNumber = a.strShipmentNumber
		,dtmDeliveryDate = GETDATE()	
		,strInvoiceVoucher = d.strInvoiceNumber
		,intDetailId = c.intBillDetailId
		,c.intPriceFixationDetailId
		FROM vyuSCTicketInventoryShipmentView a
		INNER JOIN tblARInvoiceDetail b ON b.intInventoryShipmentItemId = a.intInventoryShipmentItemId
		INNER JOIN tblCTPriceFixationDetailAPAR c ON c.intInvoiceDetailId = b.intInvoiceDetailId
		INNER JOIN tblARInvoice d ON d.intInvoiceId = c.intInvoiceId
		WHERE a.intInventoryShipmentId = ft.intInventoryShipmentId AND c.intPriceFixationDetailId = ft.intPricingId
	) details1
	WHERE ft.intInventoryShipmentId IS NOT NULL
	UNION ALL
	SELECT intPriceFixationTicketId
	,ft.intPriceFixationId
	,intPricingId
	,intPricingNumber = fd.intNumber
	,dblCash = fd.dblCashPrice
	,ft.intTicketId
	,strTicketNumber
	,ft.intInventoryShipmentId
	,ft.intInventoryReceiptId
	,intInventoryShipmentReceiptId = ft.intInventoryReceiptId
	,strShipmentReceiptNumber
	,ft.dblQuantity
	,dtmDeliveryDate
	,strInvoiceVoucher
	,intDetailId
	,ft.intConcurrencyId 
	FROM tblCTPriceFixationTicket ft
	INNER JOIN tblCTPriceFixationDetail fd ON ft.intPricingId = fd.intPriceFixationDetailId
	OUTER APPLY
	(
		SELECT a.intInventoryReceiptId
		,a.strTicketNumber
		,strShipmentReceiptNumber = a.strReceiptNumber
		,dtmDeliveryDate = GETDATE()	
		,strInvoiceVoucher = d.strBillId
		,intDetailId = c.intBillDetailId
		,c.intPriceFixationDetailId
		FROM vyuSCTicketInventoryReceiptView a
		INNER JOIN tblAPBillDetail b ON b.intInventoryReceiptItemId = a.intInventoryReceiptItemId
		INNER JOIN tblCTPriceFixationDetailAPAR c ON c.intBillDetailId = b.intBillDetailId
		INNER JOIN tblAPBill d ON d.intBillId = c.intBillId	
		WHERE a.intInventoryReceiptId = ft.intInventoryReceiptId AND c.intPriceFixationDetailId = ft.intPricingId
	) details2
	WHERE ft.intInventoryReceiptId IS NOT NULL
)tbl
