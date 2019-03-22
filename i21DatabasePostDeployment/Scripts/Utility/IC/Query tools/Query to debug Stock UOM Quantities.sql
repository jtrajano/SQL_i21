
DECLARE @intItemId AS INT 
SELECT @intItemId = intItemId FROM tblICItem WHERE strItemNo = 'Kamut 50 kg bag'

SELECT 'tblICItem', * FROM tblICItem WHERE intItemId = @intItemId

SELECT	'tblICLot'
		, strLotNumber
		, intLotId 
		, intItemUOMId
		, intWeightUOMId
		, dblWeightPerQty
		, dblQty
		, dblWeight
		, [Calculated Weight] = dblQty * dblWeightPerQty
		, dblWeightPerQty
FROM	tblICLot 
WHERE	intItemId = @intItemId 

SELECT	'tblICItemStock', dblUnitOnHand, * 
FROM	tblICItemStock 
WHERE	intItemId = @intItemId

SELECT	'tblICItemStockUOM', tblICUnitMeasure.strUnitMeasure, * 
from	tblICItemStockUOM inner join tblICItemUOM
			on tblICItemStockUOM.intItemUOMId = tblICItemUOM.intItemUOMId
		inner join tblICUnitMeasure
			on tblICUnitMeasure.intUnitMeasureId = tblICItemUOM.intUnitMeasureId
where	tblICItemStockUOM.intItemId = @intItemId

select	'tblICInventoryTransaction', *
from	tblICInventoryTransaction
where	intItemId = @intItemId

select	'tblICInventoryTransaction', sum(dblQty * dblUOMQty)
from	tblICInventoryTransaction
where	intItemId = @intItemId
		and ISNULL(ysnIsUnposted, 0) <> 1

select	'tblICInventoryTransaction'
		, [StockUnit] = sum(dblQty * dblUOMQty)
		, [Qty] = sum(dblQty)
		,intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId
from	tblICInventoryTransaction
where	intItemId = @intItemId
		and ISNULL(ysnIsUnposted, 0) <> 1
GROUP BY 
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId


select	'tbICItemUOM', UOM.strUnitMeasure, ItemUOM.intItemUOMId, ItemUOM.dblUnitQty, ItemUOM.ysnStockUnit, UOM.strUnitType
from	tblICItemUOM ItemUOM inner join tblICUnitMeasure UOM
			on ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
where	intItemId = @intItemId