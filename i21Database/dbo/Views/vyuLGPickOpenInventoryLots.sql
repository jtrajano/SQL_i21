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
	, Lot.dblQty - IsNull((SELECT SUM (PL.dblLotPickedQty) from tblLGPickLotDetail PL Group By PL.intLotId Having Lot.intLotId = PL.intLotId), 0) AS dblUnPickedQty 
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
FROM tblICLot Lot
LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intLotId = Lot.intLotId
LEFT JOIN tblICItem Item ON Item.intItemId = Lot.intItemId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Lot.intLocationId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = Lot.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = Lot.intSubLocationId
LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = Lot.intStorageLocationId
LEFT JOIN tblICLotStatus LotStatus ON LotStatus.intLotStatusId = Lot.intLotStatusId
LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = Lot.intWeightUOMId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
WHERE	Lot.dblQty - IsNull((SELECT SUM (PL.dblLotPickedQty) from tblLGPickLotDetail PL Group By PL.intLotId Having Lot.intLotId = PL.intLotId), 0) > 0
