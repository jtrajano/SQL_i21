CREATE VIEW [dbo].[vyuICGetPostedLot]
AS 

SELECT	intLotId				= Lot.intLotId
		,strLotNumber			= Lot.strLotNumber
		,strLotAlias			= Lot.strLotAlias
		,intItemId				= Lot.intItemId
		,strItemNo				= Item.strItemNo 
		,strDescription			= Item.strDescription
		,intLocationId			= Lot.intLocationId
		,strLocationName		= Location.strLocationName
		,intItemLocationId		= Lot.intItemLocationId
		,intSubLocationId		= Lot.intSubLocationId
		,strSubLocationName		= SubLocation.strSubLocationName
		,intStorageLocationId	= Lot.intStorageLocationId
		,strStorageLocationName = StorageLocation.strName
		,intItemUOMId			= Lot.intItemUOMId
		,strItemUOM				= UOM.strUnitMeasure
		,intWeightUOMId			= Lot.intWeightUOMId
		,strWeightUOM			= WeightUOM.strUnitMeasure
		,dblQty					= (
					SELECT	SUM(ISNULL(PostedLot.dblStockIn, 0) - ISNULL(PostedLot.dblStockOut, 0))
					FROM	dbo.tblICInventoryLot PostedLot
					WHERE	PostedLot.intLotId = Lot.intLotId
							AND PostedLot.intItemId = Lot.intItemId
							AND PostedLot.intItemLocationId = Lot.intItemLocationId
							AND ISNULL(PostedLot.ysnIsUnposted, 0) = 0 
				)
		,dblWeight				= Lot.dblWeight
		,dblWeightPerQty		= Lot.dblWeightPerQty
		,dblCost				= (
				SELECT	TOP 1 
						dblCost 
				FROM	dbo.tblICInventoryLot PostedLot
				WHERE	PostedLot.intLotId = Lot.intLotId
						AND PostedLot.intItemId = Lot.intItemId
						AND PostedLot.intItemLocationId = Lot.intItemLocationId
						AND ISNULL(PostedLot.ysnIsUnposted, 0) = 0 
				ORDER BY intInventoryLotId DESC 
			)
		,dtmExpiryDate			= Lot.dtmExpiryDate
		,intLotStatusId			= Lot.intLotStatusId
		,strLotStatus			= LotStatus.strSecondaryStatus
		,strLotPrimaryStatus	= LotStatus.strPrimaryStatus
FROM	dbo.tblICLot Lot 
		LEFT JOIN tblICItem Item 
			ON Item.intItemId = Lot.intItemId
		LEFT JOIN tblSMCompanyLocation Location 
			ON Location.intCompanyLocationId = Lot.intLocationId
		LEFT JOIN tblICItemUOM ItemUOM 
			ON ItemUOM.intItemUOMId = Lot.intItemUOMId
		LEFT JOIN tblICUnitMeasure UOM 
			ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
			ON SubLocation.intCompanyLocationSubLocationId = Lot.intSubLocationId
		LEFT JOIN tblICStorageLocation StorageLocation 
			ON StorageLocation.intStorageLocationId = Lot.intStorageLocationId
		LEFT JOIN tblICLotStatus LotStatus 
			ON LotStatus.intLotStatusId = Lot.intLotStatusId
		LEFT JOIN tblICItemUOM ItemWeightUOM 
			ON ItemWeightUOM.intItemUOMId = Lot.intWeightUOMId
		LEFT JOIN tblICUnitMeasure WeightUOM 
			ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
