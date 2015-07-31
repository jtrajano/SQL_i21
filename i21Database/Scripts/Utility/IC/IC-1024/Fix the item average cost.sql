
-- Query to detect items with the wrong average cost. 
SELECT	intItemId, intItemLocationId, dblAverageCost,
		ISNULL(
			(
				SELECT	SUM(dbo.fnCalculateStockUnitQty(dblQty, dblUOMQty) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty)) / SUM(dbo.fnCalculateStockUnitQty(dblQty, dblUOMQty))
				FROM	dbo.tblICInventoryTransaction InvTransactions
				WHERE	InvTransactions.dblQty > 1
						AND InvTransactions.ysnIsUnposted = 0
						AND InvTransactions.intItemId = ItemPricing.intItemId
						AND InvTransactions.intItemLocationId = ItemPricing.intItemLocationId
			), 0
		)
FROM	dbo.tblICItemPricing ItemPricing 
WHERE	dblAverageCost <> ISNULL(
				(
					SELECT	SUM(dbo.fnCalculateStockUnitQty(dblQty, dblUOMQty) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty)) / SUM(dbo.fnCalculateStockUnitQty(dblQty, dblUOMQty))
					FROM	dbo.tblICInventoryTransaction InvTransactions
					WHERE	InvTransactions.dblQty > 1
							AND InvTransactions.ysnIsUnposted = 0
							AND InvTransactions.intItemId = ItemPricing.intItemId
							AND InvTransactions.intItemLocationId = ItemPricing.intItemLocationId
				), 0
			)

-- Script to fix the average cost. 
UPDATE	ItemPricing 
SET		dblAverageCost = ISNULL(
				(
					SELECT	SUM(dbo.fnCalculateStockUnitQty(dblQty, dblUOMQty) * dbo.fnCalculateUnitCost(dblCost, dblUOMQty)) / SUM(dbo.fnCalculateStockUnitQty(dblQty, dblUOMQty))
					FROM	dbo.tblICInventoryTransaction InvTransactions
					WHERE	InvTransactions.dblQty > 1
							AND InvTransactions.ysnIsUnposted = 0
							AND InvTransactions.intItemId = ItemPricing.intItemId
							AND InvTransactions.intItemLocationId = ItemPricing.intItemLocationId
				), 0
			)
FROM	dbo.tblICItemPricing ItemPricing 