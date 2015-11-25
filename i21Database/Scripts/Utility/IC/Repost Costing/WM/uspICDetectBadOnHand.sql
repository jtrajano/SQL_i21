-- USE i21Demo01

IF EXISTS (SELECT 1 FROM sys.objects WHERE name = 'uspICDetectBadOnHand' AND type = 'P')
	DROP PROCEDURE [dbo].[uspICDetectBadOnHand]
	
GO 

CREATE PROCEDURE dbo.uspICDetectBadOnHand
	@intItemId AS INT 
	,@strTransactionId AS NVARCHAR(50)
	,@strBatchId AS NVARCHAR(50)
AS 

IF OBJECT_ID('tempdb..#tmpStockDiscrepancies') IS NULL  
BEGIN 
	CREATE TABLE #tmpStockDiscrepancies (
		id INT IDENTITY(1, 1) PRIMARY KEY 
		,strType NVARCHAR(500) 
		,intItemId INT
		,strTransactionId NVARCHAR(50)
		,strBatchId NVARCHAR(50) 
		,intItemUOMId INT 
		,dblOnHand NUMERIC(18,6)
		,dblTransaction NUMERIC(18,6)
	)
END 


DECLARE @intItemUOMId AS INT 
		,@dblStockOnHand AS NUMERIC(18, 6)
		,@dblStockFromTransactions AS NUMERIC(18, 6)		
		,@dblStockUOMOnHand AS NUMERIC(18, 6) 
		,@dblStockUOMFromTransactions AS NUMERIC(18, 6) 

-- Compare tblICItemStock against Inventory Transactions
SELECT	@dblStockOnHand = StockQtyFromTransactions.dblOnHand
		,@dblStockFromTransactions = ISNULL(StockQtyFromTransactions.dblOnHand, 0)
		,@intItemUOMId = StockUOM.intItemUOMId
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
		LEFT JOIN dbo.tblICItemUOM StockUOM
			ON StockUOM.intItemId = ItemStock.intItemId
			AND StockUOM.ysnStockUnit = 1
			
WHERE  ItemStock.dblUnitOnHand <> ISNULL(StockQtyFromTransactions.dblOnHand, 0)

-- Compare tblICItemStockUOM against Inventory Transactions
SELECT	@intItemUOMId = ItemStockUOM.intItemUOMId
		,@dblStockUOMOnHand = ItemStockUOM.dblOnHand
		,@dblStockUOMFromTransactions = FromInvTrans.dblTransactionQty
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
						AND intItemId = @intItemId

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
						AND InvTransaction.intItemId = @intItemId

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
						AND InvTransaction.intItemId = @intItemId

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
						AND InvTransaction.intItemId = @intItemId

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
						AND InvTransaction.intItemId = @intItemId

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
						AND InvTransaction.intItemId = @intItemId

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
						AND InvTransaction.intItemId = @intItemId

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
						AND InvTransaction.intItemId = @intItemId

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

WHERE	ItemStockUOM.intItemId = @intItemId
		AND ItemStockUOM.dblOnHand <> ISNULL(FromInvTrans.dblTransactionQty, 0)	

IF @dblStockOnHand <> @dblStockFromTransactions
BEGIN 
	INSERT INTO #tmpStockDiscrepancies (
		intItemId 
		,strType
		,strTransactionId 
		,strBatchId 
		,intItemUOMId
		,dblOnHand
		,dblTransaction
	)
	SELECT intItemId = @intItemId
			,strType = 'Discrepancy with tblICItemStock'
			,strTransactionId = @strTransactionId
			,strBatchId = @strBatchId
			,intItemUOMId = @intItemUOMId
			,dblOnHand = @dblStockOnHand
			,dblTransaction = @dblStockFromTransactions
END 

IF @dblStockUOMOnHand <> @dblStockUOMFromTransactions
BEGIN 
	INSERT INTO #tmpStockDiscrepancies (
		intItemId 
		,strType
		,strTransactionId 
		,strBatchId 
		,intItemUOMId
		,dblOnHand
		,dblTransaction
	)
	SELECT intItemId = @intItemId
			,strType = 'Discrepancy with tblICItemStockUOM'
			,strTransactionId = @strTransactionId
			,strBatchId = @strBatchId
			,intItemUOMId = @intItemUOMId
			,dblOnHand = @dblStockUOMOnHand
			,dblTransaction = @dblStockUOMFromTransactions
END 	

RETURN 0;