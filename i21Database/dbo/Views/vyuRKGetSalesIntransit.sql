CREATE  VIEW [dbo].[vyuRKGetSalesIntransit]

AS

SELECT cd.intContractDetailId,intPricingTypeId,dblUnitReserved,ri.intInventoryReceiptId from tblICItem item
JOIN tblICItemStock ics ON item.intItemId = ics.intItemId
JOIN tblICInventoryReceiptItem ri on item.intItemId=ri.intItemId
JOIN tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId
JOIN vyuCTContractDetailView cd on cd.intContractDetailId=ri.intLineNo AND strReceiptType = 'Purchase Contract' and intPricingTypeId in(1,2)
