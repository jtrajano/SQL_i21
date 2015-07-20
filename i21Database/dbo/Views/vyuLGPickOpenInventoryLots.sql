CREATE VIEW vyuLGPickOpenInventoryLots
	AS 
SELECT Lot.intLotId
	, Lot.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, Lot.intLocationId as intCompanyLocationId
	, Location.strLocationName
	, Lot.intItemLocationId
	, Lot.intItemUOMId
	, UOM.intUnitMeasureId
	, strItemUOM = UOM.strUnitMeasure
	, strItemUOMType = UOM.strUnitType
	, dblItemUOMConv = ItemUOM.dblUnitQty
	, Lot.strLotNumber
	, Lot.intSubLocationId
	, SubLocation.strSubLocationName
	, Lot.intStorageLocationId
	, strStorageLocation = StorageLocation.strName
	, Lot.dblQty
	, Lot.dblQty - IsNull((SELECT SUM (SR.dblQty) from tblICStockReservation SR Group By SR.intLotId Having Lot.intLotId = SR.intLotId), 0) AS dblUnPickedQty 
	, Lot.dblLastCost
	, Lot.dtmExpiryDate
	, Lot.strLotAlias
	, Lot.intLotStatusId
	, strLotStatus = LotStatus.strSecondaryStatus
	, strLotStatusType = LotStatus.strPrimaryStatus
	, Lot.intParentLotId
	, Lot.intSplitFromLotId
	, ReceiptLot.dblGrossWeight
	, ReceiptLot.dblTareWeight
	, Lot.dblWeight as dblNetWeight
	, Lot.intWeightUOMId as intItemWeightUOMId
	, strWeightUOM = WeightUOM.strUnitMeasure
	, dblWeightUOMConv = ItemWeightUOM.dblUnitQty
	, Lot.dblWeightPerQty
	, Lot.intOriginId
	, Lot.strBOLNo
	, Lot.strVessel
	, Lot.strReceiptNumber
	, Lot.strMarkings
	, Lot.strNotes
	, Lot.intEntityVendorId
	, Lot.strVendorLotNo
	, Lot.intVendorLocationId
	, Lot.strVendorLocation
	, Lot.strContractNo
	, Lot.dtmManufacturedDate
	, Lot.ysnReleasedToWarehouse
	, Lot.ysnProduced
	, Lot.dtmDateCreated
	, Lot.intCreatedUserId
	, Lot.intConcurrencyId
	, Receipt.dtmReceiptDate
	, ReceiptLot.intInventoryReceiptItemLotId
	, ReceiptLot.strCondition
	, ReceiptItem.intSourceId
	, CTHeader.intContractNumber
	, CTDetail.intContractDetailId
	, CTDetail.intContractSeq
	, CTDetail.dblQuantity as dblOriginalQty
	, dblAllocatedQty = IsNull((SELECT SUM(AL.dblPAllocatedQty) FROM tblLGAllocationDetail AL GROUP BY AL.intPContractDetailId HAVING AL.intPContractDetailId = CTDetail.intContractDetailId), 0)
	, dblReservedQty = IsNull((SELECT SUM(RS.dblReservedQuantity) FROM tblLGReservation RS GROUP BY RS.intContractDetailId HAVING RS.intContractDetailId = CTDetail.intContractDetailId), 0)
	, dblAllocReserve = IsNull((SELECT SUM(AL.dblPAllocatedQty) FROM tblLGAllocationDetail AL GROUP BY AL.intPContractDetailId HAVING AL.intPContractDetailId = CTDetail.intContractDetailId), 0) +
						IsNull((SELECT SUM(RS.dblReservedQuantity) FROM tblLGReservation RS GROUP BY RS.intContractDetailId HAVING RS.intContractDetailId = CTDetail.intContractDetailId), 0)
	, dblBalance = CTDetail.dblQuantity - 
					IsNull((SELECT SUM(AL.dblPAllocatedQty) FROM tblLGAllocationDetail AL GROUP BY AL.intPContractDetailId HAVING AL.intPContractDetailId = CTDetail.intContractDetailId), 0) + 
					IsNull((SELECT SUM(RS.dblReservedQuantity) FROM tblLGReservation RS GROUP BY RS.intContractDetailId HAVING RS.intContractDetailId = CTDetail.intContractDetailId), 0)
	, ShipmentContainer.strContainerNumber
	, ShipmentBL.strBLNumber

FROM tblICLot Lot
LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intLotId = Lot.intLotId
LEFT JOIN tblICInventoryReceiptItem	ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
LEFT JOIN tblLGShipmentContractQty ShipmentContract ON ShipmentContract.intShipmentContractQtyId = ReceiptItem.intSourceId
LEFT JOIN tblLGShipmentBLContainer ShipmentContainer ON ShipmentContainer.intShipmentBLContainerId = ReceiptItem.intContainerId
LEFT JOIN tblLGShipmentBLContainerContract ShipmentContainerContract ON ShipmentContainerContract.intShipmentContractQtyId = ShipmentContract.intShipmentContractQtyId AND ShipmentContainerContract.intShipmentBLContainerId = ShipmentContainer.intShipmentBLContainerId
LEFT JOIN tblLGShipmentBL ShipmentBL ON ShipmentBL.intShipmentBLId = ShipmentContainer.intShipmentBLId
LEFT JOIN tblCTContractDetail CTDetail ON CTDetail.intContractDetailId = ShipmentContract.intContractDetailId
LEFT JOIN tblCTContractHeader CTHeader ON CTHeader.intContractHeaderId = CTDetail.intContractHeaderId
LEFT JOIN tblICItem Item ON Item.intItemId = Lot.intItemId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Lot.intLocationId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = Lot.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = Lot.intSubLocationId
LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = Lot.intStorageLocationId
LEFT JOIN tblICLotStatus LotStatus ON LotStatus.intLotStatusId = Lot.intLotStatusId
LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = Lot.intWeightUOMId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
