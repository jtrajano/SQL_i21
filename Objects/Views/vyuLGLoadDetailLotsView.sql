CREATE VIEW vyuLGLoadDetailLotsView
AS
SELECT L.strLoadNumber
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
	  ,UM.strUnitMeasure AS strItemUnitMeasure
	  ,WUM.strUnitMeasure AS strWeightUnitMeasure
	  ,LOT.strLotNumber 
	  ,Receipt.strWarehouseRefNo
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
JOIN tblICLot LOT ON LOT.intLotId = LDL.intLotId
JOIN tblICItemUOM IU ON IU.intItemUOMId = ISNULL(LOT.intItemUOMId, LDL.intItemUOMId)
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN tblICItemUOM WU ON WU.intItemUOMId = ISNULL(LOT.intWeightUOMId, LDL.intWeightUOMId)
JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = WU.intUnitMeasureId
LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intLotId = LOT.intLotId
LEFT JOIN tblICInventoryReceiptItem	ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId