CREATE VIEW vyuLGStockSalesAllocation
AS
SELECT AH.strAllocationNumber
	  ,AD.dtmAllocatedDate
	  ,CTHeader.strContractNumber + '/' + CONVERT(NVARCHAR,CTDetail.intContractSeq) AS strPContractSeq
	  ,SCTHeader.strContractNumber + '/' + CONVERT(NVARCHAR,SCTDetail.intContractSeq) AS strSContractSeq
	  ,AD.dblPAllocatedQty
	  ,AD.dblSAllocatedQty
	  ,Lot.intLotId
	  ,AH.intAllocationHeaderId
FROM tblICLot Lot
JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intParentLotId = Lot.intParentLotId
JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = ReceiptItem.intSourceId
JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
JOIN tblCTContractDetail CTDetail ON CTDetail.intContractDetailId = LD.intPContractDetailId
JOIN tblCTContractHeader CTHeader ON CTHeader.intContractHeaderId = CTDetail.intContractHeaderId
JOIN tblLGAllocationDetail AD ON AD.intPContractDetailId = CTDetail.intContractDetailId
JOIN tblLGAllocationHeader AH ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN tblCTContractDetail SCTDetail ON SCTDetail.intContractDetailId = AD.intSContractDetailId
JOIN tblCTContractHeader SCTHeader ON SCTHeader.intContractHeaderId = SCTDetail.intContractHeaderId
LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = ReceiptItem.intContainerId
LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
	AND LDCL.intLoadContainerId = LC.intLoadContainerId