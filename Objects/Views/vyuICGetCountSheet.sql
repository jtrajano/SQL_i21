CREATE VIEW [dbo].[vyuICGetCountSheet]
	AS 

SELECT Header.intLocationId
	, Header.intCommodityId
	, Header.strCommodity
	, Header.strCountNo
	, Header.dtmCountDate
	
	, Detail.intInventoryCountDetailId
	, Detail.intInventoryCountId
	, Detail.intItemId
	, Detail.strItemNo
	, Detail.strItemDescription
	, Detail.strLotTracking
	, Detail.ysnLotWeightsRequired
	, Detail.intCategoryId
	, Detail.strCategory	
	, Detail.strDescription	
	, Detail.ysnScannedCountEntry	
	, Detail.strCountBy	
	, Detail.ysnRecountMismatch
	, Detail.ysnExternal
	, Detail.intRecountReferenceId
	, Detail.intStatus
	, Detail.strStatus
	, Detail.intItemLocationId
	, Detail.strLocationName
	, Detail.intSubLocationId
	, Detail.strSubLocationName
	, Detail.intStorageLocationId
	, Detail.strStorageLocationName
	, Detail.intLotId
	, Detail.strLotNo
	, Detail.strLotAlias
	, Detail.intParentLotId
	, Detail.strParentLotNo
	, Detail.strParentLotAlias
	, Detail.dblSystemCount
	, Detail.dblLastCost
	, Detail.strCountLine
	, Detail.dblPallets
	, Detail.dblQtyPerPallet
	, Detail.dblPhysicalCount
	, Detail.intStockUOMId
	, Detail.strStockUOM
	, Detail.intItemUOMId
	, Detail.intWeightUOMId
	, Detail.dblWeightQty
	, Detail.dblNetQty
	, Detail.strUnitMeasure
	, Detail.strWeightUOM
	, Detail.dblItemUOMConversionFactor
	, Detail.dblWeightUOMConversionFactor
	, Detail.dblWeightPerQty
	, Detail.dblConversionFactor
	, Detail.dblPhysicalCountStockUnit
	, Detail.dblVariance
	, Detail.ysnRecount
	, Detail.intEntityUserSecurityId
	, Detail.strUserName
	, Detail.intCountGroupId
	, Detail.strCountGroup
	, Detail.dblQtyReceived
	, Detail.dblQtySold
	, Detail.intSort
	, Detail.intConcurrencyId
	, Detail.strStorageUnitNo


	, Header.ysnCountByLots
	, Header.ysnCountByPallets
	, Header.ysnIncludeOnHand
	, Header.ysnIncludeZeroOnHand
	, dblPalletsBlank = null
	, dblQtyPerPalletBlank = null
	, dblPhysicalCountBlank = null
FROM vyuICGetInventoryCountDetail Detail
	LEFT JOIN vyuICGetInventoryCount Header ON Header.intInventoryCountId = Detail.intInventoryCountId
