﻿CREATE VIEW vyuLGLoadDetailLotsView
AS
SELECT 
	L.strLoadNumber
	,L.intLoadId
	,LD.intLoadDetailId
	,LDL.intLoadDetailLotId
	,LDL.intLotId
	,LDL.dblLotQuantity
	,LDL.intItemUOMId
	,LDL.dblGross
	,LDL.dblTare
	,LDL.dblNet
	,LDL.intWeightUOMId
	,LDL.strWarehouseCargoNumber
	,LDL.strID1
	,LDL.strID2
	,LDL.strID3
	,LDL.strNewLotNumber
	,LDL.dblDivertQuantity
	,strItemUnitMeasure = UM.strUnitMeasure
	,strWeightUnitMeasure = WUM.strUnitMeasure
	,LOT.strLotNumber 
	,LOT.strLotAlias
	,strWarehouseRefNo = ISNULL(Receipt.strWarehouseRefNo,LOT.strWarehouseRefNo)
	,CLSL.strSubLocationName
	,strStorageLocation = SL.strName
	,LDL.intConcurrencyId
	,Receipt.intBankAccountId
	,BA.strBankAccountNo
	,BA.strBankName
	,strWarrantNo = LOT.strWarrantNo
	,strWarrantStatus = CASE LOT.intWarrantStatus
		WHEN 1 THEN 'Pledged' 
		WHEN 2 THEN 'Partially Released'
		WHEN 3 THEN 'Released'
		ELSE '' END COLLATE Latin1_General_CI_AS
	,Receipt.strTradeFinanceNumber
	,Receipt.strBankReferenceNo
	,Receipt.strReferenceNo
	,strSourceLoadNumber = PL.strLoadNumber
	,dblWeightPerUnit = CASE WHEN dbo.fnCalculateQtyBetweenUOM(LOT.intItemUOMId, LDL.intItemUOMId, 1) IS NOT NULL AND ISNULL(LOT.dblWeight, 0) > 0
						THEN dbo.fnDivide(LOT.dblWeight, ISNULL(dbo.fnCalculateQtyBetweenUOM(LOT.intItemUOMId, LDL.intItemUOMId, dblQty), 1.0))
						ELSE dbo.fnDivide(ISNULL(LDL.dblNet, (LDL.dblGross - LDL.dblTare)), LDL.dblLotQuantity)
						END
	,dblTarePerQty = CASE WHEN dbo.fnCalculateQtyBetweenUOM(LOT.intItemUOMId, LDL.intItemUOMId, 1) IS NULL AND ISNULL(LOT.dblTare, 0) > 0
						THEN dbo.fnDivide(LOT.dblTare, ISNULL(dbo.fnCalculateQtyBetweenUOM(LOT.intItemUOMId, LDL.intItemUOMId, dblQty), 1.0))
						ELSE dbo.fnDivide(ISNULL(LDL.dblTare, (LDL.dblNet - LDL.dblGross)), LDL.dblLotQuantity)
						END
	,strMarks = LOT.strMarkings
FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
	JOIN tblICLot LOT ON LOT.intLotId = LDL.intLotId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = LDL.intItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblICItemUOM WU ON WU.intItemUOMId = ISNULL(LOT.intWeightUOMId, LDL.intWeightUOMId)
	LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WU.intUnitMeasureId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LOT.intSubLocationId
	LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = LOT.intStorageLocationId
	LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intLotId = LOT.intLotId
	LEFT JOIN tblICInventoryReceiptItem	ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
	LEFT JOIN tblLGLoadDetail PLD ON PLD.intLoadDetailId = ReceiptItem.intSourceId
	LEFT JOIN tblLGLoad PL ON PL.intLoadId = PLD.intLoadId
	LEFT JOIN vyuCMBankAccount BA ON BA.intBankAccountId = Receipt.intBankAccountId