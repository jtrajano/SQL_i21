-- use i21Demo01

-- Compare tblICItemStock against Inventory Transactions
SELECT	ItemStock.intItemId
		,Item.strItemNo
		,ItemStock.dblUnitOnHand
		,[StockQtyFromTransactions] = StockQtyFromTransactions.dblOnHand
FROM	dbo.tblICItemStock ItemStock LEFT JOIN (
			SELECT	dblOnHand = SUM(dblQty * dblUOMQty)
					,InvTransaction.intItemId
					,InvTransaction.intItemLocationId
			FROM	dbo.tblICInventoryTransaction InvTransaction
			GROUP BY intItemId, intItemLocationId
		) StockQtyFromTransactions 
			ON ItemStock.intItemId = StockQtyFromTransactions.intItemId
			AND ItemStock.intItemLocationId = StockQtyFromTransactions.intItemLocationId
		INNER JOIN dbo.tblICItem Item
			ON ItemStock.intItemId = Item.intItemId
WHERE  ItemStock.dblUnitOnHand <> ISNULL(StockQtyFromTransactions.dblOnHand, 0)

-- Compare tblICItemStockUOM against Inventory Transactions
SELECT	ItemStockUOM.intItemId
		,ItemStockUOM.intItemUOMId
		,Item.strItemNo
		,UOM.strUnitMeasure
		,ItemStockUOM.dblOnHand
		,FromInvTrans.dblTransactionQty
		
FROM	dbo.tblICItemStockUOM ItemStockUOM INNER JOIN (			
			SELECT	dblTransactionQty = SUM(dblTransactionQty)
					,intItemId
					,intItemUOMId
					,intItemLocationId					
					,intSubLocationId
					,intStorageLocationId										
			FROM (
				-- Non Lot Items. Convert it to stock unit. 
				SELECT	dblTransactionQty = SUM(InvTransaction.dblQty * dblUOMQty)
						,InvTransaction.intItemId
						,InvTransaction.intItemLocationId					
						,InvTransaction.intSubLocationId
						,InvTransaction.intStorageLocationId						
						,intItemUOMId = (SELECT intItemUOMId FROM tblICItemUOM WHERE intItemId = InvTransaction.intItemId AND ysnStockUnit = 1) 
				FROM	dbo.tblICInventoryTransaction InvTransaction 						
				WHERE	InvTransaction.intLotId IS NULL 

				GROUP BY InvTransaction.intItemId
						,InvTransaction.intItemLocationId					
						,InvTransaction.intStorageLocationId
						,InvTransaction.intSubLocationId
						,InvTransaction.intItemUOMId

				-- Non Lot Items. 
				UNION ALL 
				SELECT	dblTransactionQty = SUM(InvTransaction.dblQty)
						,InvTransaction.intItemId
						,InvTransaction.intItemLocationId					
						,InvTransaction.intSubLocationId
						,InvTransaction.intStorageLocationId						
						,InvTransaction.intItemUOMId
				FROM	dbo.tblICInventoryTransaction InvTransaction 						
						LEFT JOIN dbo.tblICItemUOM StockUOM
							ON StockUOM.intItemId = InvTransaction.intItemId
							AND StockUOM.ysnStockUnit = 1
				WHERE	InvTransaction.intLotId IS NULL 
						AND StockUOM.intItemUOMId <> InvTransaction.intItemUOMId

				GROUP BY InvTransaction.intItemId
						,InvTransaction.intItemLocationId					
						,InvTransaction.intSubLocationId
						,InvTransaction.intStorageLocationId						
						,InvTransaction.intItemUOMId

				-- Lot Items in Packs. Convert it to weights. and then Convert it to Stock Units. 
				UNION ALL 
				SELECT	dblTransactionQty = SUM(
							InvTransaction.dblQty
							* CASE	WHEN Lot.intWeightUOMId IS NOT NULL THEN Lot.dblWeightPerQty
									ELSE 1
							END
							* CASE	WHEN Lot.intWeightUOMId IS NOT NULL THEN WeightUOM.dblUnitQty
									ELSE PackUOM.dblUnitQty
							END
						)
						,InvTransaction.intItemId
						,InvTransaction.intItemLocationId					
						,InvTransaction.intSubLocationId
						,InvTransaction.intStorageLocationId						
						,intItemUOMId = (SELECT intItemUOMId FROM tblICItemUOM WHERE intItemId = InvTransaction.intItemId AND ysnStockUnit = 1) 
				FROM	dbo.tblICInventoryTransaction InvTransaction INNER JOIN dbo.tblICLot Lot 
							ON InvTransaction.intLotId = Lot.intLotId 
							AND InvTransaction.intItemUOMId = Lot.intItemUOMId
						LEFT JOIN dbo.tblICItemUOM PackUOM
							ON PackUOM.intItemUOMId = Lot.intItemUOMId
						LEFT JOIN dbo.tblICItemUOM WeightUOM
							ON WeightUOM.intItemUOMId = Lot.intWeightUOMId
				WHERE	InvTransaction.intLotId IS NOT NULL 

				GROUP BY InvTransaction.intItemId
						,InvTransaction.intItemLocationId					
						,InvTransaction.intStorageLocationId
						,InvTransaction.intSubLocationId
						,InvTransaction.intItemUOMId

				-- Lot Items in Packs. Convert it to weights. 
				UNION ALL 
				SELECT	dblTransactionQty = SUM(
							InvTransaction.dblQty
							* CASE	WHEN Lot.intWeightUOMId IS NOT NULL THEN Lot.dblWeightPerQty
										ELSE 1
								END
						)
						,InvTransaction.intItemId
						,InvTransaction.intItemLocationId					
						,InvTransaction.intSubLocationId
						,InvTransaction.intStorageLocationId						
						,Lot.intWeightUOMId
				FROM	dbo.tblICInventoryTransaction InvTransaction INNER JOIN dbo.tblICLot Lot 
							ON InvTransaction.intLotId = Lot.intLotId 
							AND InvTransaction.intItemUOMId = Lot.intItemUOMId
						LEFT JOIN dbo.tblICItemUOM PackUOM
							ON PackUOM.intItemUOMId = Lot.intItemUOMId
						LEFT JOIN dbo.tblICItemUOM WeightUOM
							ON WeightUOM.intItemUOMId = Lot.intWeightUOMId
						LEFT JOIN dbo.tblICItemUOM StockUOM
							ON StockUOM.intItemId = InvTransaction.intItemId
							AND StockUOM.ysnStockUnit = 1
				WHERE	InvTransaction.intLotId IS NOT NULL 
						AND Lot.intWeightUOMId IS NOT NULL 
						AND StockUOM.intItemUOMId <> Lot.intWeightUOMId

				GROUP BY InvTransaction.intItemId
						,InvTransaction.intItemLocationId					
						,InvTransaction.intStorageLocationId
						,InvTransaction.intSubLocationId
						,Lot.intWeightUOMId

				-- Lot Items in Packs. 
				UNION ALL 
				SELECT	dblTransactionQty = SUM(
							InvTransaction.dblQty
						)
						,InvTransaction.intItemId
						,InvTransaction.intItemLocationId					
						,InvTransaction.intSubLocationId
						,InvTransaction.intStorageLocationId						
						,InvTransaction.intItemUOMId
				FROM	dbo.tblICInventoryTransaction InvTransaction INNER JOIN dbo.tblICLot Lot 
							ON InvTransaction.intLotId = Lot.intLotId 
							AND InvTransaction.intItemUOMId = Lot.intItemUOMId
						LEFT JOIN dbo.tblICItemUOM PackUOM
							ON PackUOM.intItemUOMId = Lot.intItemUOMId
						LEFT JOIN dbo.tblICItemUOM WeightUOM
							ON WeightUOM.intItemUOMId = Lot.intWeightUOMId
						LEFT JOIN dbo.tblICItemUOM StockUOM
							ON StockUOM.intItemId = InvTransaction.intItemId
							AND StockUOM.ysnStockUnit = 1
				WHERE	InvTransaction.intLotId IS NOT NULL 
						AND StockUOM.intItemUOMId <> InvTransaction.intItemUOMId
						AND Lot.intItemUOMId <> Lot.intWeightUOMId

				GROUP BY InvTransaction.intItemId
						,InvTransaction.intItemLocationId					
						,InvTransaction.intStorageLocationId
						,InvTransaction.intSubLocationId
						,InvTransaction.intItemUOMId

				-- Lot Items in Weight. Convert it to stock Units. 
				UNION ALL 
				SELECT	dblTransactionQty = SUM(
							InvTransaction.dblQty 
							* WeightUOM.dblUnitQty
						)
						,InvTransaction.intItemId
						,InvTransaction.intItemLocationId					
						,InvTransaction.intSubLocationId
						,InvTransaction.intStorageLocationId						
						,intItemUOMId = (SELECT intItemUOMId FROM tblICItemUOM WHERE intItemId = InvTransaction.intItemId AND ysnStockUnit = 1) 
				FROM	dbo.tblICInventoryTransaction InvTransaction INNER JOIN dbo.tblICLot Lot 
							ON InvTransaction.intLotId = Lot.intLotId 
							AND InvTransaction.intItemUOMId = Lot.intWeightUOMId
						LEFT JOIN dbo.tblICItemUOM WeightUOM
							ON WeightUOM.intItemUOMId = Lot.intWeightUOMId
				WHERE	InvTransaction.intLotId IS NOT NULL 
						AND Lot.intWeightUOMId IS NOT NULL 
						AND Lot.intItemUOMId <> Lot.intWeightUOMId

				GROUP BY InvTransaction.intItemId
						,InvTransaction.intItemLocationId					
						,InvTransaction.intStorageLocationId
						,InvTransaction.intSubLocationId
						,InvTransaction.intItemUOMId 

				-- Lot Items in Weight. 
				UNION ALL 
				SELECT	dblTransactionQty = SUM(
							InvTransaction.dblQty 
						)
						,InvTransaction.intItemId
						,InvTransaction.intItemLocationId	
						,InvTransaction.intSubLocationId				
						,InvTransaction.intStorageLocationId						
						,InvTransaction.intItemUOMId
				FROM	dbo.tblICInventoryTransaction InvTransaction INNER JOIN dbo.tblICLot Lot 
							ON InvTransaction.intLotId = Lot.intLotId 
							AND InvTransaction.intItemUOMId = Lot.intWeightUOMId
						LEFT JOIN dbo.tblICItemUOM WeightUOM
							ON WeightUOM.intItemUOMId = Lot.intWeightUOMId
						LEFT JOIN dbo.tblICItemUOM StockUOM
							ON StockUOM.intItemId = InvTransaction.intItemId
							AND StockUOM.ysnStockUnit = 1
				WHERE	InvTransaction.intLotId IS NOT NULL 
						AND Lot.intWeightUOMId IS NOT NULL 
						AND Lot.intItemUOMId <> Lot.intWeightUOMId
						AND StockUOM.intItemUOMId <> InvTransaction.intItemUOMId

				GROUP BY InvTransaction.intItemId
						,InvTransaction.intItemLocationId					
						,InvTransaction.intStorageLocationId
						,InvTransaction.intSubLocationId
						,InvTransaction.intItemUOMId 

				-- Lot Items in Weight. Convert it to packs. 
				UNION ALL 
				SELECT	dblTransactionQty = SUM(							
							CASE WHEN ISNULL(Lot.dblWeightPerQty, 0) <> 0 THEN InvTransaction.dblQty / Lot.dblWeightPerQty ELSE 0 END 
						)
						,InvTransaction.intItemId
						,InvTransaction.intItemLocationId					
						,InvTransaction.intSubLocationId
						,InvTransaction.intStorageLocationId						
						,Lot.intItemUOMId
						
				FROM	dbo.tblICInventoryTransaction InvTransaction INNER JOIN dbo.tblICLot Lot 
							ON InvTransaction.intLotId = Lot.intLotId 
							AND InvTransaction.intItemUOMId = Lot.intWeightUOMId
						LEFT JOIN dbo.tblICItemUOM WeightUOM
							ON WeightUOM.intItemUOMId = Lot.intWeightUOMId
						LEFT JOIN dbo.tblICItemUOM StockUOM
							ON StockUOM.intItemId = InvTransaction.intItemId
							AND StockUOM.ysnStockUnit = 1
				WHERE	InvTransaction.intLotId IS NOT NULL 
						AND Lot.intWeightUOMId IS NOT NULL 
						AND Lot.intItemUOMId <> Lot.intWeightUOMId
						AND StockUOM.intItemUOMId <> Lot.intItemUOMId 												

				GROUP BY InvTransaction.intItemId
						,InvTransaction.intItemLocationId					
						,InvTransaction.intStorageLocationId
						,InvTransaction.intSubLocationId
						,Lot.intItemUOMId

			) Query
			GROUP BY intItemId
					,intItemUOMId
					,intItemLocationId					
					,intSubLocationId
					,intStorageLocationId										
		) FromInvTrans 
			ON ItemStockUOM.intItemId = FromInvTrans.intItemId
			AND ItemStockUOM.intItemUOMId = FromInvTrans.intItemUOMId
			AND ItemStockUOM.intItemLocationId = FromInvTrans.intItemLocationId			
			AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(FromInvTrans.intSubLocationId, 0)
			AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(FromInvTrans.intStorageLocationId, 0) 
			
		INNER JOIN dbo.tblICItem Item
			ON ItemStockUOM.intItemId = Item.intItemId

		LEFT JOIN dbo.tblICItemUOM ItemUOM 
			ON ItemUOM.intItemUOMId = ItemStockUOM.intItemUOMId

		LEFT JOIN dbo.tblICUnitMeasure UOM
			ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId

WHERE	ItemStockUOM.dblOnHand <> ISNULL(FromInvTrans.dblTransactionQty, 0)	