﻿CREATE VIEW vyuRKGetInventoryAdjustQty

AS

SELECT DISTINCT ISNULL(dblBalance,0)+(isnull(dblQuantity,0)-(case when dblAdjustByQuantity > 0 then -(isnull(dblAdjustByQuantity,0)) else abs(isnull(dblAdjustByQuantity,0)) end)) as dblDetailQuantity,(isnull(dblOpenReceive,0)-isnull(dblAdjustByQuantity,0)

) OpenQty,
isnull(dblBalance,0) dblBalance,intContractDetailId,isnull(dblInvoiceQty,0) dblInvoiceQty FROM (
SELECT min(isnull(cd.dblBalance,0)) dblBalance,
		sum(case when (r.ysnPosted)=1 then (isnull(il.dblQuantity,0)) else 0 end) dblQuantity,
		cd.intContractDetailId intContractDetailId,
		sum(ISNULL(ri.dblOpenReceive,0)) dblOpenReceive,
        SUM(a.dblAdjustByQuantity) dblAdjustByQuantity,
		isnull((
		select dblQtyShipped from (
							SELECT isnull(sum(dblSalesInvoiceQty),0) dblQtyShipped FROM vyuRKGetInvoicedQty inv WHERE inv.intSContractDetailId=cd.intContractDetailId )t		
		 ),0) dblInvoiceQty
FROM tblCTContractDetail cd
LEFT JOIN tblICInventoryReceiptItem ri on cd.intContractDetailId=ri.intLineNo
LEFT JOIN tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId 
LEFT JOIN tblICInventoryReceiptItemLot il on ri.intInventoryReceiptItemId=il.intInventoryReceiptItemId 
LEFT JOIN (SELECT isnull(sum(ad.dblAdjustByQuantity),0) dblAdjustByQuantity,cd.intContractDetailId

			FROM tblCTContractDetail cd
			LEFT JOIN tblICInventoryReceiptItem ri on cd.intContractDetailId=ri.intLineNo
			LEFT JOIN tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId
			LEFT JOIN tblICInventoryReceiptItemLot il on ri.intInventoryReceiptItemId=il.intInventoryReceiptItemId 
			LEFT JOIN tblICInventoryAdjustmentDetail ad on   ad.intLotId=il.intLotId 
			GROUP BY cd.intContractDetailId) a on a.intContractDetailId=cd.intContractDetailId
GROUP BY cd.intContractDetailId)t
