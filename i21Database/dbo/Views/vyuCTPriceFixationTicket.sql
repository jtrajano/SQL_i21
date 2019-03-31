CREATE VIEW [dbo].[vyuCTPriceFixationTicket]
AS 
SELECT intPriceFixationTicketId
,a.intPriceFixationId
,intPricingId
,intPricingNumber = c.intNumber
,dblCash = c.dblCashPrice
,a.intTicketId
,strTicketNumber = b.strTicketNumber
,a.intInventoryShipmentId
,strShipmentNumber = b.strShipmentNumber
,a.dblQuantity
,dtmDeliveryDate = GETDATE()
,strInvoiceVoucher = ''
,a.intConcurrencyId 
FROM tblCTPriceFixationTicket a
INNER JOIN vyuSCTicketInventoryShipmentView b ON a.intTicketId = b.intTicketId
INNER JOIN tblCTPriceFixationDetail c ON a.intPricingId = c.intPriceFixationDetailId
