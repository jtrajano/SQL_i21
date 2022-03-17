CREATE VIEW [dbo].[vyuLGGetOpenWeightClaimLots]
AS
SELECT
	Lot.intLotId
	,Lot.strLotNumber
	,strCondition = ISNULL(Lot.strCondition, '')
	,L.intLoadId
	,L.strLoadNumber
	,intContractDetailId = IRI.intLineNo
	,intContractHeaderId = IRI.intOrderId
	,dblGross = ISNULL(IRIL.dblGrossWeight, 0)
	,dblNet = ISNULL(IRIL.dblGrossWeight, 0) - ISNULL(IRIL.dblTareWeight, 0)
	,LC.intLoadContainerId
	,LC.strContainerNumber
FROM tblICLot Lot
	INNER JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intLotId = Lot.intLotId
	INNER JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRIL.intInventoryReceiptItemId
	INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId AND IR.intSourceType = 2
	INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = IRI.intSourceId
	INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	CROSS APPLY (SELECT TOP 1 ysnWeightClaimsByContainer = ISNULL(ysnWeightClaimsByContainer, 0) FROM tblLGCompanyPreference) CP
	LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = IRI.intContainerId AND CP.ysnWeightClaimsByContainer = 1
	LEFT JOIN tblLGPendingClaim PL ON PL.intLoadId = L.intLoadId AND (ISNULL(PL.intLoadContainerId, 0) = ISNULL(LC.intLoadContainerId, 0))
WHERE IR.ysnPosted = 1
	AND IR.strReceiptType <> 'Inventory Return'
	AND PL.intPendingClaimId IS NOT NULL