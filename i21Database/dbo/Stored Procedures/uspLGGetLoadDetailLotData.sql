CREATE PROCEDURE uspLGGetLoadDetailLotData 
	@intLoadDetailId INT
AS
BEGIN
	SELECT L.strLoadNumber
		,L.intLoadId
		,LOT.strLotNumber AS strLot
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
		,UM.strUnitMeasure AS strItemUOM
		,WUM.strUnitMeasure AS strWeightUOM
		,LOT.strLotNumber
		,Receipt.strWarehouseRefNo
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
	JOIN tblICLot LOT ON LOT.intLotId = LDL.intLotId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = LOT.intItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	JOIN tblICItemUOM WU ON WU.intItemUOMId = LOT.intWeightUOMId
	JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = L.intWeightUnitMeasureId
	LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intParentLotId = LOT.intParentLotId
	LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
	WHERE LD.intLoadDetailId = @intLoadDetailId
END