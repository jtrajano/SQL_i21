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
		,CLSL.strSubLocationName
		,SL.strName AS strStorageLocation
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
	JOIN tblICLot LOT ON LOT.intLotId = LDL.intLotId
	JOIN tblICItemUOM IU ON IU.intItemUOMId = LOT.intItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = ISNULL(L.intWeightUnitMeasureId,IU.intUnitMeasureId)
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LOT.intSubLocationId
	LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = LOT.intStorageLocationId
	LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intParentLotId = LOT.intParentLotId
	LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
	WHERE LD.intLoadDetailId = @intLoadDetailId
END