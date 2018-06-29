CREATE VIEW vyuRKGetPurchaseInventory
as
SELECT 
    CTDetail.intContractDetailId
       ,Sum(Lot.dblQty) dblLotQty
FROM tblICLot Lot
LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intParentLotId = Lot.intParentLotId
LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
LEFT JOIN tblCTContractDetail CTDetail ON CTDetail.intContractDetailId = ReceiptItem.intLineNo 
LEFT JOIN tblCTContractHeader CTHeader ON CTHeader.intContractHeaderId = ReceiptItem.intOrderId
WHERE Lot.dblQty > 0.0
GROUP BY CTDetail.intContractDetailId