CREATE VIEW [dbo].[vyuICGetInventoryAdjustmentDetail]
	AS 

SELECT 
	AdjDetail.intInventoryAdjustmentDetailId
	, AdjDetail.intInventoryAdjustmentId
	, Adj.intLocationId
	, Adj.strLocationName
	, Adj.dtmAdjustmentDate
	, Adj.intAdjustmentType
	, Adj.strAdjustmentType
	, Adj.strAdjustmentNo
	, Adj.strDescription
	, Adj.ysnPosted
	, Adj.intEntityId
	, Adj.strUser
	, Adj.dtmPostedDate
	, Adj.dtmUnpostedDate
	, AdjDetail.intSubLocationId
	, strSubLocation = SubLocation.strSubLocationName
	, AdjDetail.intStorageLocationId
	, strStorageLocation = StorageLocation.strName
	, AdjDetail.intItemId
	, Item.strItemNo
	, strItemDescription = Item.strDescription
	, Item.strLotTracking
	, AdjDetail.intNewItemId
	, strNewItemNo = NewItem.strItemNo
	, strNewItemDescription = NewItem.strDescription
	, strNewLotTracking = NewItem.strLotTracking
	, AdjDetail.intLotId
	, Lot.strLotNumber
	, dblLotQty = Lot.dblQty
	, dblLotUnitCost = Lot.dblLastCost
	, dblLotWeightPerQty = Lot.dblWeightPerQty 
	, AdjDetail.intNewLotId
	, AdjDetail.strNewLotNumber
	, AdjDetail.dblQuantity --dblQuantity = CAST(CASE AdjDetail.intOwnershipType WHEN 2 THEN ItemUOM.dbl ELSE AdjDetail.dblQuantity END AS NUMERIC(38, 20))
	, AdjDetail.dblNewQuantity
	, AdjDetail.dblNewSplitLotQuantity
	, AdjDetail.dblAdjustByQuantity
	, AdjDetail.intItemUOMId
	, strItemUOM = ItemUOM.strUnitMeasure
	, dblItemUOMUnitQty = ItemUOM.dblUnitQty
	, AdjDetail.intNewItemUOMId
	, strNewItemUOM = NewItemUOM.strUnitMeasure
	, dblNewItemUOMUnitQty = NewItemUOM.dblUnitQty
	, AdjDetail.intWeightUOMId
	, strWeightUOM = WeightUOM.strUnitMeasure
	, AdjDetail.intNewWeightUOMId
	, strNewWeightUOM = NewWeightUOM.strUnitMeasure
	, AdjDetail.dblWeight
	, AdjDetail.dblNewWeight
	, AdjDetail.dblWeightPerQty
	, AdjDetail.dblNewWeightPerQty
	, AdjDetail.dtmExpiryDate
	, AdjDetail.dtmNewExpiryDate
	, AdjDetail.intLotStatusId
	, strLotStatus = LotStatus.strSecondaryStatus
	, AdjDetail.intNewLotStatusId
	, strNewLotStatus = NewLotStatus.strSecondaryStatus
	, AdjDetail.dblCost
	, AdjDetail.dblNewCost
	, AdjDetail.intNewLocationId
	, strNewLocationName = NewLocation.strLocationName
	, AdjDetail.intNewSubLocationId
	, strNewSubLocation = NewSubLocation.strSubLocationName
	, AdjDetail.intNewStorageLocationId
	, strNewStorageLocation = NewStorageLocation.strName
	, AdjDetail.dblLineTotal
	, AdjDetail.intSort
	, strOwnerName = LotOwnerEntity.strName
	, strNewOwnerName = NewLotOwnerEntity.strName
	, AdjDetail.intOwnershipType
	, AdjDetail.intCostingMethod
	, strCostingMethod = ISNULL(CostingMethod.strCostingMethod, '')
	, strOwnershipType = CASE AdjDetail.intOwnershipType WHEN 1 THEN 'Own' WHEN 2 THEN 'Storage' WHEN 3 THEN 'Consigned Purchase' WHEN 4 THEN 'Consigned Sale' ELSE NULL END
	, AdjDetail.intConcurrencyId
FROM tblICInventoryAdjustmentDetail AdjDetail
LEFT JOIN vyuICGetInventoryAdjustment Adj ON Adj.intInventoryAdjustmentId = AdjDetail.intInventoryAdjustmentId
LEFT JOIN tblSMCompanyLocation NewLocation ON NewLocation.intCompanyLocationId = AdjDetail.intNewLocationId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = AdjDetail.intSubLocationId
LEFT JOIN tblSMCompanyLocationSubLocation NewSubLocation ON NewSubLocation.intCompanyLocationSubLocationId = AdjDetail.intNewSubLocationId
LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = AdjDetail.intStorageLocationId
LEFT JOIN tblICStorageLocation NewStorageLocation ON NewStorageLocation.intStorageLocationId = AdjDetail.intNewStorageLocationId
LEFT JOIN tblICItem Item ON Item.intItemId = AdjDetail.intItemId
LEFT JOIN tblICItem NewItem ON NewItem.intItemId = AdjDetail.intNewItemId
LEFT JOIN tblICLot Lot ON Lot.intLotId = AdjDetail.intLotId
LEFT JOIN vyuICGetItemUOM ItemUOM ON ItemUOM.intItemUOMId = AdjDetail.intItemUOMId
LEFT JOIN vyuICGetItemUOM NewItemUOM ON NewItemUOM.intItemUOMId = AdjDetail.intNewItemUOMId
LEFT JOIN vyuICGetItemUOM WeightUOM ON WeightUOM.intItemUOMId = AdjDetail.intWeightUOMId
LEFT JOIN vyuICGetItemUOM NewWeightUOM ON NewWeightUOM.intItemUOMId = AdjDetail.intNewWeightUOMId
LEFT JOIN tblICLotStatus LotStatus ON LotStatus.intLotStatusId = AdjDetail.intLotStatusId
LEFT JOIN tblICLotStatus NewLotStatus ON NewLotStatus.intLotStatusId = AdjDetail.intNewLotStatusId
LEFT JOIN tblICCostingMethod CostingMethod ON CostingMethod.intCostingMethodId = AdjDetail.intCostingMethod
LEFT JOIN (
	tblICItemOwner LotOwner INNER JOIN tblEMEntity LotOwnerEntity 
		ON LotOwner.intOwnerId = LotOwnerEntity.intEntityId
)
	ON LotOwner.intItemOwnerId = AdjDetail.intItemOwnerId

LEFT JOIN (
	tblICItemOwner NewLotOwner INNER JOIN tblEMEntity NewLotOwnerEntity 
		ON NewLotOwner.intOwnerId = NewLotOwnerEntity.intEntityId
)
	ON NewLotOwner.intItemOwnerId = AdjDetail.intNewItemOwnerId