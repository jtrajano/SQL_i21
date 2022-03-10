CREATE VIEW vyuLGInventoryLots
AS
SELECT DISTINCT Lot.intLotId
	,Lot.strLotNumber
	,Lot.intItemUOMId
	,Lot.strItemUOM
	,Lot.intItemWeightUOMId
	,Lot.strWeightUOM
	,Lot.intSubLocationId
	,Lot.strSubLocationName
	,Lot.strStorageLocation
	,Lot.dblGrossWeight
	,Lot.dblQty
	,Lot.dblUnPickedQty
	,Lot.dblTareWeight
	,Lot.dblNetWeight
	,Lot.intItemId
	,Lot.strWarehouseRefNo
	,strWarrantNo = ISNULL(IRIL.strWarrantNo, IR.strWarrantNo)
	,strWarrantStatus = CASE WHEN ISNULL(IRIL.intWarrantStatus, IR.intWarrantStatus) = 2 THEN 'Released' ELSE 'Pledged' END COLLATE Latin1_General_CI_AS
	,IR.strTradeFinanceNumber
	,IR.strBankReferenceNo
	,IR.strReferenceNo
	,Lot.strLoadNumber
FROM vyuLGPickOpenInventoryLots Lot
	LEFT JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intInventoryReceiptItemLotId = Lot.intInventoryReceiptItemLotId
	LEFT JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRIL.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
