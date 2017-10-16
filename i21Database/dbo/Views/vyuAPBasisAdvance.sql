CREATE VIEW [dbo].[vyuAPBasisAdvance]
AS 

SELECT 
    CAST(ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS INT) AS intBasisAdvanceId --generate identity without sorting
    ,ticket.intTicketId
    ,entity.strName
    ,ISNULL(customer.dblARBalance,0) AS dblARBalance
    ,strSplit = ''
    ,ct.strContractNumber
    ,ticket.strTicketNumber 
    ,ticket.dtmTicketDateTime
    ,loc.strLocationName
    ,receipt.intInventoryReceiptId
    ,receipt.strReceiptNumber
    ,receipt.strBillOfLading
    ,commodity.strDescription
    ,cur.strCurrency
    ,ISNULL(ticket.dblUnitPrice,0) AS dblFuture
    ,ISNULL(ticket.dblNetUnits,0) AS dblQuantity
    ,uom.strUnitMeasure
    ,ISNULL(ticket.dblUnitBasis,0) AS dblUnitBasis
    ,ISNULL(ticket.dblUnitPrice,0) + ISNULL(ticket.dblUnitBasis,0) AS dblFuturesPrice
    ,ISNULL(discounts.dblAmount,0) AS dblDiscountAmount
FROM tblSCTicket ticket
INNER JOIN (tblAPVendor vendor INNER JOIN tblEMEntity entity ON vendor.intEntityId = entity.intEntityId)
     ON ticket.intEntityId = vendor.intEntityId
INNER JOIN tblSMCompanyLocation loc ON ticket.intProcessingLocationId = loc.intCompanyLocationId
LEFT JOIN tblARCustomer customer ON ticket.intEntityId = customer.intEntityId
LEFT JOIN tblSCTicketSplit tcktSPlit ON ticket.intTicketId = tcktSPlit.intTicketId
LEFT JOIN (tblICInventoryReceipt receipt INNER JOIN tblICInventoryReceiptItem receiptItem ON receipt.intInventoryReceiptId = receiptItem.intInventoryReceiptId)
    ON ticket.intTicketId = receiptItem.intSourceId AND receipt.intSourceType = 1
INNER JOIN (tblCTContractHeader ct INNER JOIN tblCTContractDetail ctd ON ct.intContractHeaderId =  ctd.intContractHeaderId)
    ON receiptItem.intLineNo = ctd.intContractDetailId
INNER JOIN tblICCommodity commodity ON ticket.intCommodityId = commodity.intCommodityId
INNER JOIN tblSMCurrency cur ON ticket.intCurrencyId = cur.intCurrencyID
INNER JOIN (tblICItemUOM itemUOM INNER JOIN tblICUnitMeasure uom ON itemUOM.intUnitMeasureId = uom.intUnitMeasureId)
    ON itemUOM.intItemId = ticket.intItemId AND itemUOM.ysnStockUnit = 1
OUTER APPLY (
    SELECT
        SUM(charge.dblAmount) AS dblAmount
    FROM tblICInventoryReceiptCharge charge
    LEFT JOIN tblQMTicketDiscount tktDiscount ON tktDiscount.intTicketId = ticket.intTicketId
    LEFT JOIN tblGRDiscountScheduleCode dscntCode ON tktDiscount.intDiscountScheduleCodeId = dscntCode.intDiscountScheduleCodeId
    LEFT JOIN tblICItem dscnItem ON dscntCode.intItemId = dscnItem.intItemId 
    WHERE charge.intInventoryReceiptId = receipt.intInventoryReceiptId    
    GROUP BY charge.intInventoryReceiptId
) discounts
WHERE ct.intPricingTypeId = 2

