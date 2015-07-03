CREATE VIEW [dbo].[vyuICGetLot]
	AS 
	
SELECT Lot.intLotId
	, Lot.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, Lot.intLocationId
	, Location.strLocationName
	, Lot.intItemLocationId
	, Lot.intItemUOMId
	, strItemUOM = UOM.strUnitMeasure
	, strItemUOMType = UOM.strUnitType
	, dblItemUOMConv = ItemUOM.dblUnitQty
	, Lot.strLotNumber
	, Lot.intOwnershipType
	, strOwnershipType = (CASE WHEN Lot.intOwnershipType = 1 THEN 'Own'
						WHEN Lot.intOwnershipType = 2 THEN 'Storage'
						WHEN Lot.intOwnershipType = 3 THEN 'Consigned Purchase'
						WHEN Lot.intOwnershipType = 4 THEN 'Consigned Sale'
						END)
	, Lot.intSubLocationId
	, SubLocation.strSubLocationName
	, Lot.intStorageLocationId
	, strStorageLocation = StorageLocation.strName
	, dblQty = ISNULL(Lot.dblQty, 0)
	, dblReservedQty = ISNULL(Reserve.dblTotalQty, 0)
	, dblAvailableQty = ISNULL(Lot.dblQty, 0) - ISNULL(Reserve.dblTotalQty, 0)
	, Lot.dblLastCost
	, Lot.dtmExpiryDate
	, Lot.strLotAlias
	, Lot.intLotStatusId
	, strLotStatus = LotStatus.strSecondaryStatus
	, strLotStatusType = LotStatus.strPrimaryStatus
	, Lot.intParentLotId
	, Lot.intSplitFromLotId
	, Lot.dblWeight
	, Lot.intWeightUOMId
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
LEFT JOIN tblICItem Item ON Item.intItemId = Lot.intItemId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Lot.intLocationId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = Lot.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = Lot.intSubLocationId
LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = Lot.intStorageLocationId
LEFT JOIN tblICLotStatus LotStatus ON LotStatus.intLotStatusId = Lot.intLotStatusId
LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = Lot.intWeightUOMId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
LEFT JOIN (
		SELECT intItemId
			, intItemLocationId
			, intItemUOMId
			, intSubLocationId
			, intStorageLocationId
			, intLotId
			, dblTotalQty = SUM(dblQty)
		FROM tblICStockReservation
		GROUP BY intItemId
			, intItemLocationId
			, intItemUOMId
			, intSubLocationId
			, intStorageLocationId
			, intLotId
	) Reserve ON Reserve.intItemId = Lot.intItemId
	AND Reserve.intItemLocationId = Lot.intItemLocationId
	AND Reserve.intItemUOMId = Lot.intItemUOMId
	AND Reserve.intSubLocationId = Lot.intSubLocationId
	AND Reserve.intStorageLocationId = Lot.intStorageLocationId
	AND Reserve.intLotId = Lot.intLotId