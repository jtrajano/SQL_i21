CREATE VIEW vyuRKGetInventoryAdjustQty

AS

SELECT isnull(dblBalance,0)+(isnull(dblQuantity,0)-(-isnull(dblAdjustByQuantity,0))) as dblDetailQuantity,isnull(dblBalance,0) dblBalance,intContractDetailId FROM (
SELECT cd.dblBalance,il.dblQuantity,il.intLotId,intContractDetailId,
		isnull((select sum(ad.dblAdjustByQuantity) dblAdjustByQuantity from tblICInventoryAdjustmentDetail ad where  ad.intLotId=il.intLotId),0) dblAdjustByQuantity
FROM tblCTContractDetail cd
JOIN tblICInventoryReceiptItem ri on cd.intContractDetailId=ri.intLineNo
JOIN tblICInventoryReceiptItemLot il on ri.intInventoryReceiptItemId=il.intInventoryReceiptItemId 
)t
