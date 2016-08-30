CREATE VIEW vyuRKGetInventoryAdjustQty

AS

SELECT DISTINCT ISNULL(dblBalance,0)+(isnull(dblQuantity,0)-(-isnull(dblAdjustByQuantity,0))) as dblDetailQuantity,(isnull(dblOpenReceive,0)-isnull(dblAdjustByQuantity,0)) OpenQty,
isnull(dblBalance,0) dblBalance,intContractDetailId FROM (
SELECT sum(isnull(cd.dblBalance,0)) dblBalance,sum(isnull(il.dblQuantity,0)) dblQuantity,intContractDetailId,sum(ISNULL(ri.dblOpenReceive,0)) dblOpenReceive,
              ISNULL((SELECT SUM(ad.dblAdjustByQuantity) dblAdjustByQuantity from tblICInventoryAdjustmentDetail ad where  ad.intLotId=il.intLotId),0) dblAdjustByQuantity
FROM tblCTContractDetail cd
LEFT JOIN tblICInventoryReceiptItem ri on cd.intContractDetailId=ri.intLineNo
LEFT JOIN tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId 
LEFT JOIN tblICInventoryReceiptItemLot il on ri.intInventoryReceiptItemId=il.intInventoryReceiptItemId 
WHERE  r.ysnPosted=1 group by cd.intContractDetailId , il.intLotId
)t 
