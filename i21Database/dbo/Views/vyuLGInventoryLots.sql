CREATE VIEW vyuLGInventoryLots
AS
SELECT DISTINCT intLotId
	,strLotNumber
	,intItemUOMId
	,strItemUOM
	,intItemWeightUOMId
	,strWeightUOM
	,intSubLocationId
	,strSubLocationName
	,strStorageLocation
	,dblGrossWeight
	,dblQty
	,dblUnPickedQty
	,dblTareWeight
	,dblNetWeight
	,intItemId
	,strWarehouseRefNo
FROM vyuLGPickOpenInventoryLots
