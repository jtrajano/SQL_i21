CREATE VIEW vyuLGInventoryLots
AS
SELECT DISTINCT Lot.intLotId
	,Lot.strLotNumber
	,Lot.strLotAlias
	,Lot.strItemNo
	,Lot.strItemDescription
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
	,Lot.intCommodityId
	,Lot.strWarehouseRefNo
	,BA.intBankAccountId
	,BA.strBankAccountNo
	,BA.strBankName
	,strWarrantNo = Lot.strWarrantNo
	,strWarrantStatus = CASE Lot.intWarrantStatus
		WHEN 1 THEN 'Pledged' 
		WHEN 2 THEN 'Partially Released' 
		WHEN 3 THEN 'Released'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,IR.strTradeFinanceNumber
	,IR.strBankReferenceNo
	,IR.strReferenceNo
	,Lot.strLoadNumber
	,Lot.intContractDetailId
	,dblWeightPerQty = ISNULL(Lot.dblWeightPerQty,0.0)
	,dblTarePerQty = ISNULL(Lot.dblTarePerQty,0.0)
	,Lot.intEntityVendorId
	,Lot.strVendor
	,Lot.strContractNumber
	,Lot.intContractSeq
	,Lot.dtmReceiptDate
	,Lot.strLotStatus
	,Lot.strCondition
	,Lot.strMarks
FROM vyuLGPickOpenInventoryLots Lot
	LEFT JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intInventoryReceiptItemLotId = Lot.intInventoryReceiptItemLotId
	LEFT JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRIL.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	LEFT JOIN vyuCMBankAccount BA ON BA.intBankAccountId = IR.intBankAccountId
