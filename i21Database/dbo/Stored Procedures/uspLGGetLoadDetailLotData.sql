CREATE PROCEDURE uspLGGetLoadDetailLotData 
	@intLoadDetailId INT
AS
BEGIN
	SELECT L.strLoadNumber
		,L.intLoadId
		,strLot = LOT.strLotNumber
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
		,strItemUnitMeasure = UM.strUnitMeasure
		,strWeightUnitMeasure = WUM.strUnitMeasure
		,strItemUOM = UM.strUnitMeasure
		,strWeightUOM = WUM.strUnitMeasure
		,LOT.strLotNumber
		,strWarehouseRefNo = ISNULL(Receipt.strWarehouseRefNo,LOT.strWarehouseRefNo)
		,CLSL.strSubLocationName
		,strStorageLocation = SL.strName
		,LDL.intConcurrencyId
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