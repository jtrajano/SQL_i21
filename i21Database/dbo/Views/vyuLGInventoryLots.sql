﻿CREATE VIEW vyuLGInventoryLots
AS
SELECT DISTINCT Lot.intLotId
	,Lot.strLotNumber
	,Lot.intItemUOMId
	,Lot.strItemUOM
	,Lot.intItemWeightUOMId
	,Lot.strWeightUOM
	,Lot.intCompanyLocationId
	,Lot.strLocationName
	,Lot.intSubLocationId
	,Lot.strSubLocationName
	,Lot.intStorageLocationId
	,Lot.strStorageLocation
	,Lot.dblGrossWeight
	,Lot.dblQty
	,Lot.dblUnPickedQty
	,Lot.dblTareWeight
	,Lot.dblNetWeight
	,Lot.intItemId
	,Lot.strWarehouseRefNo
	,strWarrantNo = ISNULL(IRIL.strWarrantNo, IR.strWarrantNo)
	,strWarrantStatus = CASE ISNULL(IRIL.intWarrantStatus, IR.intWarrantStatus)
		WHEN 1 THEN 'Pledged' 
		WHEN 2 THEN 'Partially Released' 
		WHEN 3 THEN 'Released'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,IR.strTradeFinanceNumber
	,IR.strBankReferenceNo
	,IR.strReferenceNo
	,Lot.strLoadNumber
	,Lot.intContractDetailId
FROM vyuLGPickOpenInventoryLots Lot
	LEFT JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intInventoryReceiptItemLotId = Lot.intInventoryReceiptItemLotId
	LEFT JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRIL.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
