
-- Fix transactions with the wrong Unit Qty. 
UPDATE	InventoryTransaction
SET		dblUOMQty = ItemUOM.dblUnitQty  
FROM	dbo.tblICInventoryTransaction InventoryTransaction INNER JOIN dbo.tblICItemUOM ItemUOM
			ON InventoryTransaction.intItemUOMId = ItemUOM.intItemUOMId
WHERE	InventoryTransaction.dblUOMQty <> ItemUOM.dblUnitQty
