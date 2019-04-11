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
	SELECT distinct intPriceFixationTicketId
	,a.intPriceFixationId
	,intPricingId
	,intPricingNumber = c.intNumber
	,dblCash = c.dblCashPrice
	,a.intTicketId
	,strTicketNumber = b.strTicketNumber
	,a.intInventoryShipmentId
	,a.intInventoryReceiptId
	,intInventoryShipmentReceiptId = a.intInventoryShipmentId
	,strShipmentReceiptNumber = b.strShipmentNumber
	,a.dblQuantity
	,dtmDeliveryDate = GETDATE()
	,strInvoiceVoucher = f.strInvoiceNumber
	,intDetailId = d.intInvoiceDetailId
	,a.intConcurrencyId 
	FROM tblCTPriceFixationTicket a
	INNER JOIN vyuSCTicketInventoryShipmentView b ON a.intTicketId = b.intTicketId AND a.intInventoryShipmentId = b.intInventoryShipmentId
	INNER JOIN tblCTPriceFixationDetail c ON a.intPricingId = c.intPriceFixationDetailId
	LEFT JOIN tblCTPriceFixationDetailAPAR d ON c.intPriceFixationDetailId = d.intPriceFixationDetailId
	LEFT JOIN tblARInvoiceDetail e ON d.intInvoiceDetailId = e.intInvoiceDetailId and b.intInventoryShipmentItemId = e.intInventoryShipmentItemId
	LEFT JOIN tblARInvoice f ON e.intInvoiceId = f.intInvoiceId
	UNION ALL
	SELECT intPriceFixationTicketId
	,a.intPriceFixationId
	,intPricingId
	,intPricingNumber = c.intNumber
	,dblCash = c.dblCashPrice
	,a.intTicketId
	,strTicketNumber = b.strTicketNumber
	,a.intInventoryShipmentId
	,a.intInventoryReceiptId
	,intInventoryShipmentReceiptId = a.intInventoryReceiptId
	,strShipmentReceiptNumber = b.strReceiptNumber
	,a.dblQuantity
	,dtmDeliveryDate = GETDATE()
	,strInvoiceVoucher = f.strBillId
	,intDetailId = d.intBillDetailId
	,a.intConcurrencyId 
	FROM tblCTPriceFixationTicket a
	INNER JOIN vyuSCTicketInventoryReceiptView b ON a.intTicketId = b.intTicketId AND a.intInventoryReceiptId = b.intInventoryReceiptId
	INNER JOIN tblCTPriceFixationDetail c ON a.intPricingId = c.intPriceFixationDetailId
	LEFT JOIN tblCTPriceFixationDetailAPAR d ON c.intPriceFixationDetailId = d.intPriceFixationDetailId
	LEFT JOIN tblAPBillDetail e ON  d.intBillDetailId = e.intBillDetailId and b.intInventoryReceiptItemId = e.intInventoryReceiptItemId
	LEFT JOIN tblAPBill f ON e.intBillId = f.intBillId
)tbl
