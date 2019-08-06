﻿/*
	CAUTION: Execute this stored procedure with extreme care.

	This is a utility stored procedure used to fix the stock quantities. 
	
	Features
	----------------------------------------------------------------
	07/08/2015:		Re-calculate the On-Hand Qty. 

*/
CREATE PROCEDURE [dbo].[uspICFixStockQuantities]
	@intItemId AS INT = NULL 
	,@intCategoryId AS INT = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


--------------------------------------
-- Fix the Stock On-Hand
--------------------------------------
BEGIN 
	EXEC uspICFixStockOnHand 
		@intItemId
		,@intCategoryId
END 

-------------------
--UPDATE ON ORDER
-------------------
BEGIN 
	UPDATE tblICItemStock
	SET dblOnOrder = 0
	FROM 
		tblICItemStock s INNER JOIN tblICItem i
			ON s.intItemId = i.intItemId
	WHERE
			ISNULL(@intItemId, i.intItemId) = i.intItemId
			AND ISNULL(@intCategoryId, i.intCategoryId) = i.intCategoryId

	UPDATE tblICItemStockUOM
	SET dblOnOrder = 0 
	FROM 
		tblICItemStockUOM s INNER JOIN tblICItem i
			ON s.intItemId = i.intItemId
	WHERE
			ISNULL(@intItemId, i.intItemId) = i.intItemId
			AND ISNULL(@intCategoryId, i.intCategoryId) = i.intCategoryId

	MERGE	
	INTO	dbo.tblICItemStock 
	WITH	(HOLDLOCK) 
	AS		ItemStock	
	USING (
			SELECT
				ItemTransactions.intItemId
				,ItemTransactions.intItemLocationId
				,SUM(ItemTransactions.dblOnOrder) dblOnOrder
			FROM (
				SELECT	
					B.intItemId
					,C.intItemLocationId
					,dblOnOrder =  (CASE WHEN dblQtyReceived > dblQtyOrdered THEN 0 ELSE dblQtyOrdered - dblQtyReceived END) * D.dblUnitQty --ItemStock should be the base qty
				FROM 
					tblPOPurchase A INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
					INNER JOIN tblICItemLocation C ON A.intShipToId = C.intLocationId AND B.intItemId = C.intItemId
					INNER JOIN tblICItemUOM D ON B.intUnitOfMeasureId = D.intItemUOMId AND B.intItemId = D.intItemId
				WHERE 
					intOrderStatusId NOT IN (4, 3, 6)
					OR (dblQtyOrdered > dblQtyReceived AND intOrderStatusId NOT IN (4, 3, 6))--Handle wrong status of PO, greater qty received should be closed status
			) ItemTransactions INNER JOIN tblICItem i
				ON ItemTransactions.intItemId = i.intItemId 
			WHERE
				ISNULL(@intItemId, i.intItemId) = i.intItemId
				AND ISNULL(@intCategoryId, i.intCategoryId) = i.intCategoryId
			GROUP BY 
				ItemTransactions.intItemLocationId
				, ItemTransactions.intItemId
	) AS StockToUpdate
		ON ItemStock.intItemId = StockToUpdate.intItemId
		AND ItemStock.intItemLocationId = StockToUpdate.intItemLocationId

	-- If matched, update the unit on order qty. 
	WHEN MATCHED THEN 
		UPDATE 
		--SET		dblOnOrder = ISNULL(ItemStock.dblOnOrder, 0) + StockToUpdate.dblOnOrder
		SET		dblOnOrder = StockToUpdate.dblOnOrder

	-- If none found, insert a new item stock record
	WHEN NOT MATCHED THEN 
		INSERT (
			intItemId
			,intItemLocationId
			,dblUnitOnHand
			,dblOrderCommitted
			,dblOnOrder
			,dblLastCountRetail
			,intSort
			,intConcurrencyId
		)
		VALUES (
			StockToUpdate.intItemId
			,StockToUpdate.intItemLocationId
			,0
			,StockToUpdate.dblOnOrder
			,0
			,0
			,NULL 
			,1	
		);
	--UPDATE tblICItemStockUOM
	MERGE	
	INTO	dbo.tblICItemStockUOM 
	WITH	(HOLDLOCK) 
	AS		ItemStockUOM	
	USING (
		SELECT	
			B.intItemId
			,B.intUnitOfMeasureId AS intItemUOMId
			,C.intItemLocationId
			,B.intSubLocationId
			,B.intStorageLocationId
			,dblOnOrder =  (CASE WHEN SUM(dblQtyReceived) > SUM(dblQtyOrdered) THEN 0 ELSE SUM(dblQtyOrdered) - SUM(dblQtyReceived) END)
		FROM 
			tblPOPurchase A INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
			INNER JOIN tblICItem i ON i.intItemId = B.intItemId 
			INNER JOIN tblICItemLocation C ON A.intShipToId = C.intLocationId AND B.intItemId = C.intItemId
		WHERE 
			ISNULL(@intItemId, i.intItemId) = i.intItemId
			AND ISNULL(@intCategoryId, i.intCategoryId) = i.intCategoryId
			AND (
				intOrderStatusId NOT IN (4, 3, 6)
				OR (dblQtyOrdered > dblQtyReceived AND intOrderStatusId NOT IN (4, 3, 6))--Handle wrong status of PO, greater qty received should be closed status
			)
		GROUP BY 
			B.intItemId,
			B.intUnitOfMeasureId,
			C.intItemLocationId,
			B.intSubLocationId,
			B.intStorageLocationId
	) AS RawStockData
		ON ItemStockUOM.intItemId = RawStockData.intItemId
		AND ItemStockUOM.intItemLocationId = RawStockData.intItemLocationId
		AND ItemStockUOM.intItemUOMId = RawStockData.intItemUOMId
		AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(RawStockData.intSubLocationId, 0)
		AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(RawStockData.intStorageLocationId, 0)	

	WHEN MATCHED THEN 
		UPDATE 
		--SET		dblOnOrder = ISNULL(ItemStockUOM.dblOnOrder, 0) + RawStockData.dblOnOrder
		SET		dblOnOrder = RawStockData.dblOnOrder

	-- If none found, insert a new item stock record
	WHEN NOT MATCHED AND RawStockData.intItemUOMId IS NOT NULL THEN 
		INSERT (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intSubLocationId
			,intStorageLocationId
			,dblOnHand
			,dblOnOrder
			,intConcurrencyId
		)
		VALUES (
			RawStockData.intItemId
			,RawStockData.intItemLocationId
			,RawStockData.intItemUOMId
			,RawStockData.intSubLocationId
			,RawStockData.intStorageLocationId
			,0
			,RawStockData.dblOnOrder
			,1	
		);
END;

--------------------------------------
--Update the In-Transit Outbound 
--------------------------------------
BEGIN 
	UPDATE tblICItemStock
	SET dblInTransitOutbound = 0
	FROM 
		tblICItemStock s INNER JOIN tblICItem i
			ON s.intItemId = i.intItemId
	WHERE 
		ISNULL(@intItemId, i.intItemId) = i.intItemId
		AND ISNULL(@intCategoryId, i.intCategoryId) = i.intCategoryId

	UPDATE tblICItemStockUOM
	SET dblInTransitOutbound = 0 
	FROM 
		tblICItemStockUOM s INNER JOIN tblICItem i
			ON s.intItemId = i.intItemId
	WHERE 
		ISNULL(@intItemId, i.intItemId) = i.intItemId
		AND ISNULL(@intCategoryId, i.intCategoryId) = i.intCategoryId

	MERGE	
	INTO	dbo.tblICItemStock 
	WITH	(HOLDLOCK) 
	AS		ItemStock	
	USING (
		SELECT	i.intItemId
				,il.intItemLocationId
				,dblInTransitOutbound = ISNULL(t.dblQuantity, 0)
		FROM	tblICItem i INNER JOIN tblICItemLocation il
					ON i.intItemId = il.intItemId 
				OUTER APPLY (
					SELECT	dblQuantity = SUM(dbo.fnCalculateStockUnitQty(t.dblQty, t.dblUOMQty)) 
					FROM	tblICInventoryTransaction t
					WHERE	t.intItemId = i.intItemId 
							AND t.intInTransitSourceLocationId = il.intItemLocationId
							AND t.strTransactionForm IN (
								'Inventory Shipment'
								,'Outbound Shipment'
								,'Invoice'
							)
							
				) t 
		WHERE
			ISNULL(@intItemId, i.intItemId) = i.intItemId
			AND ISNULL(@intCategoryId, i.intCategoryId) = i.intCategoryId
	) AS StockToUpdate
		ON ItemStock.intItemId = StockToUpdate.intItemId
		AND ItemStock.intItemLocationId = StockToUpdate.intItemLocationId

	-- If matched, update the unit on order qty. 
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblInTransitOutbound = StockToUpdate.dblInTransitOutbound

	-- If none found, insert a new item stock record
	WHEN NOT MATCHED AND ISNULL(StockToUpdate.dblInTransitOutbound, 0) <> 0 THEN 
		INSERT (
			intItemId
			,intItemLocationId
			,dblInTransitOutbound
			,intSort
			,intConcurrencyId
		)
		VALUES (
			StockToUpdate.intItemId
			,StockToUpdate.intItemLocationId
			,StockToUpdate.dblInTransitOutbound
			,NULL 
			,1	
		);

	-- Update the Stock UOM
	-- (1) Convert all qty to stock unit
	MERGE	
	INTO	dbo.tblICItemStockUOM 
	WITH	(HOLDLOCK) 
	AS		ItemStockUOM	
	USING (
		SELECT	i.intItemId
				,il.intItemLocationId
				,StockUOM.intItemUOMId
				,intSubLocationId = null 
				,intStorageLocationId = null 
				,dblInTransitOutbound = SUM(ISNULL(t.dblQuantity, 0)) 
		FROM	tblICItem i INNER JOIN tblICItemLocation il
					ON i.intItemId = il.intItemId 
				CROSS APPLY (
					SELECT	intItemUOMId
					FROM	tblICItemUOM stockUOM
					WHERE	stockUOM.intItemId = i.intItemId
							AND stockUOM.ysnStockUnit = 1
				) StockUOM
				OUTER APPLY (
					SELECT	dblQuantity = dbo.fnCalculateStockUnitQty(t.dblQty, t.dblUOMQty)
					FROM	tblICInventoryTransaction t
					WHERE	t.intItemId = i.intItemId 
							AND t.intInTransitSourceLocationId = il.intItemLocationId
							AND t.strTransactionForm IN (
								'Inventory Shipment'
								,'Outbound Shipment'
								,'Invoice'
							)
				) t 
		WHERE
			ISNULL(@intItemId, i.intItemId) = i.intItemId
			AND ISNULL(@intCategoryId, i.intCategoryId) = i.intCategoryId
		GROUP BY 
			i.intItemId
			, il.intItemLocationId
			, StockUOM.intItemUOMId
	) AS RawStockData
		ON ItemStockUOM.intItemId = RawStockData.intItemId
		AND ItemStockUOM.intItemLocationId = RawStockData.intItemLocationId
		AND ItemStockUOM.intItemUOMId = RawStockData.intItemUOMId
		AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(RawStockData.intSubLocationId, 0)
		AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(RawStockData.intStorageLocationId, 0)	

	WHEN MATCHED THEN 
		UPDATE 
		SET		dblInTransitOutbound = RawStockData.dblInTransitOutbound

	-- If none found, insert a new item stock record
	WHEN NOT MATCHED AND ISNULL(RawStockData.dblInTransitOutbound, 0) <> 0 THEN 
		INSERT (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intSubLocationId
			,intStorageLocationId
			,dblInTransitOutbound
			,intConcurrencyId
		)
		VALUES (
			RawStockData.intItemId
			,RawStockData.intItemLocationId
			,RawStockData.intItemUOMId
			,RawStockData.intSubLocationId
			,RawStockData.intStorageLocationId
			,RawStockData.dblInTransitOutbound
			,1	
		)
	;

	-- Update the Stock UOM
	-- (2) ysnStockUnit = 0 
	MERGE	
	INTO	dbo.tblICItemStockUOM 
	WITH	(HOLDLOCK) 
	AS		ItemStockUOM	
	USING (
		SELECT	i.intItemId
				,il.intItemLocationId
				,uom.intItemUOMId 
				,intSubLocationId = null 
				,intStorageLocationId = null 
				,dblInTransitOutbound = SUM(t.dblQuantity) 
		FROM	tblICItem i INNER JOIN tblICItemLocation il
					ON i.intItemId = il.intItemId 
				INNER JOIN tblICItemUOM uom
					ON uom.intItemId = i.intItemId
					AND ISNULL(uom.ysnStockUnit, 0) = 0
				OUTER APPLY (
					SELECT	dblQuantity = dbo.fnCalculateStockUnitQty(t.dblQty, t.dblUOMQty)
					FROM	tblICInventoryTransaction t
					WHERE	t.intItemId = i.intItemId 
							AND t.intItemUOMId = uom.intItemUOMId 
							AND t.intInTransitSourceLocationId = il.intItemLocationId
							AND t.strTransactionForm IN (
								'Inventory Shipment'
								,'Outbound Shipment'
								,'Invoice'
							)
				) t 
		WHERE
			ISNULL(@intItemId, i.intItemId) = i.intItemId
			AND ISNULL(@intCategoryId, i.intCategoryId) = i.intCategoryId
		GROUP BY 
			i.intItemId
			, il.intItemLocationId
			, uom.intItemUOMId
	) AS RawStockData
		ON ItemStockUOM.intItemId = RawStockData.intItemId
		AND ItemStockUOM.intItemLocationId = RawStockData.intItemLocationId
		AND ItemStockUOM.intItemUOMId = RawStockData.intItemUOMId
		AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(RawStockData.intSubLocationId, 0)
		AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(RawStockData.intStorageLocationId, 0)	

	WHEN MATCHED THEN 
		UPDATE 
		SET		dblInTransitOutbound = RawStockData.dblInTransitOutbound

	-- If none found, insert a new item stock record
	WHEN NOT MATCHED AND ISNULL(RawStockData.dblInTransitOutbound, 0) <> 0 THEN 
		INSERT (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intSubLocationId
			,intStorageLocationId
			,dblInTransitOutbound
			,intConcurrencyId
		)
		VALUES (
			RawStockData.intItemId
			,RawStockData.intItemLocationId
			,RawStockData.intItemUOMId
			,RawStockData.intSubLocationId
			,RawStockData.intStorageLocationId
			,RawStockData.dblInTransitOutbound
			,1	
		)
	;
END 

--------------------------------------
--Update the Reservation
--------------------------------------
BEGIN 
	DECLARE @FixStockReservation AS ItemReservationTableType

	UPDATE	s
	SET		dblUnitReserved = 0 
	FROM	tblICItemStock s INNER JOIN tblICItem i
				ON s.intItemId = i.intItemId
	WHERE 
		ISNULL(@intItemId, i.intItemId) = i.intItemId
		AND ISNULL(@intCategoryId, i.intCategoryId) = i.intCategoryId


	UPDATE	s
	SET		dblUnitReserved = 0 
	FROM	tblICItemStockUOM s INNER JOIN tblICItem i
				ON s.intItemId = i.intItemId
	WHERE 
		ISNULL(@intItemId, i.intItemId) = i.intItemId
		AND ISNULL(@intCategoryId, i.intCategoryId) = i.intCategoryId
			
	INSERT INTO @FixStockReservation (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,dblQty
			,intTransactionId
			,strTransactionId
			,intTransactionTypeId
			,intSubLocationId
			,intStorageLocationId	
	)
	SELECT	r.intItemId
			,r.intItemLocationId
			,r.intItemUOMId
			,r.intLotId
			,SUM(r.dblQty)
			,r.intTransactionId
			,r.strTransactionId
			,r.intInventoryTransactionType
			,r.intSubLocationId
			,r.intStorageLocationId	 
	FROM	tblICStockReservation r INNER JOIN tblICItem i 
				ON r.intItemId = i.intItemId
	WHERE	r.ysnPosted = 0 
			AND ISNULL(@intItemId, i.intItemId) = i.intItemId
			AND ISNULL(@intCategoryId, i.intCategoryId) = i.intCategoryId
	GROUP BY 
		r.intItemId
		,r.intItemLocationId
		,r.intItemUOMId
		,r.intLotId
		,r.intTransactionId
		,r.strTransactionId
		,r.intInventoryTransactionType
		,r.intSubLocationId
		,r.intStorageLocationId

	-- Clear the stock detail 
	DELETE sd
	FROM	
		tblICItemStockDetail sd INNER JOIN tblICItemStockType sdType
			ON sdType.intItemStockTypeId = sd.intItemStockTypeId
	WHERE 
		sdType.strName = 'Reserved'	

	-- Call this SP to increase the reserved qty. 
	EXEC dbo.uspICIncreaseReservedQty
		@FixStockReservation
END 

--------------------------------------
-- Fix the Storage Quantities
--------------------------------------
BEGIN 
	EXEC uspICFixStorageQty
END 