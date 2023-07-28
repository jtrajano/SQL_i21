--liquibase formatted sql

-- changeset Von:vyuICGetPostedLot.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetPostedLot]
AS 

SELECT	intLotId				= Lot.intLotId
		,strLotNumber			= Lot.strLotNumber
		,strLotAlias			= Lot.strLotAlias
		,intItemId				= Lot.intItemId
		,strItemNo				= Item.strItemNo 
		,strDescription			= COALESCE(ItemUOM.strUPCDescription, Item.strDescription)
		,intLocationId			= Lot.intLocationId
		,strLocationName		= Location.strLocationName
		,intItemLocationId		= Lot.intItemLocationId
		,intSubLocationId		= Lot.intSubLocationId
		,strSubLocationName		= SubLocation.strSubLocationName
		,intStorageLocationId	= Lot.intStorageLocationId
		,strStorageLocationName = StorageLocation.strName
		,intItemUOMId			= ItemUOM.intItemUOMId
		,dblItemUOMUnitQty		= ItemUOM.dblUnitQty
		,strItemUOM				= UOM.strUnitMeasure
		,intWeightUOMId			= Lot.intWeightUOMId
		,strWeightUOM			= WeightUOM.strUnitMeasure
		,dblQty					= Lot.dblQty
		,dblWeight				= Lot.dblWeight
		,dblWeightPerQty		= Lot.dblWeightPerQty
		,dblCost				= Lot.dblLastCost
		,dtmExpiryDate			= Lot.dtmExpiryDate
		,intLotStatusId			= Lot.intLotStatusId
		,strLotStatus			= LotStatus.strSecondaryStatus
		,strLotPrimaryStatus	= LotStatus.strPrimaryStatus
		,strOwnerName			= entity.strName
		,intItemOwnerId			= Lot.intItemOwnerId
		,intOwnershipType		= Lot.intOwnershipType
		,strWarehouseRefNo		= Lot.strWarehouseRefNo
		,strCargoNo				= Lot.strCargoNo
		,strWarrantNo			= Lot.strWarrantNo
		,strCondition			= Lot.strCondition
FROM	dbo.tblICLot Lot INNER JOIN tblICItem Item 
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
		LEFT JOIN tblICItemOwner o
			ON o.intItemOwnerId = Lot.intItemOwnerId
		LEFT JOIN tblEMEntity entity
			ON entity.intEntityId = o.intOwnerId



