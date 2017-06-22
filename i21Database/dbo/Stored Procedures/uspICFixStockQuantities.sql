/*
	CAUTION: Execute this stored procedure with extreme care.

	This is a utility stored procedure used to fix the stock quantities. 
	
	Features
	----------------------------------------------------------------
	07/08/2015:		Re-calculate the On-Hand Qty. 

*/
CREATE PROCEDURE [dbo].[uspICFixStockQuantities]
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
END 

-------------------
--UPDATE ON ORDER
-------------------
BEGIN 
	UPDATE tblICItemStock
	SET dblOnOrder = 0

	UPDATE tblICItemStockUOM
	SET dblOnOrder = 0 

	MERGE	
	INTO	dbo.tblICItemStock 
	WITH	(HOLDLOCK) 
	AS		ItemStock	
	USING (
					SELECT
			 intItemId
			 ,intItemLocationId
			 ,SUM(dblOnOrder) dblOnOrder
			 FROM (
				SELECT	
					B.intItemId
					,C.intItemLocationId
					,dblOnOrder =  (CASE WHEN dblQtyReceived > dblQtyOrdered THEN 0 ELSE dblQtyOrdered - dblQtyReceived END) * D.dblUnitQty --ItemStock should be the base qty
				FROM tblPOPurchase A
				INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
				INNER JOIN tblICItemLocation C
					ON A.intShipToId = C.intLocationId AND B.intItemId = C.intItemId
				INNER JOIN tblICItemUOM D ON B.intUnitOfMeasureId = D.intItemUOMId AND B.intItemId = D.intItemId
				WHERE 
				intOrderStatusId NOT IN (4, 3, 6)
				OR (dblQtyOrdered > dblQtyReceived AND intOrderStatusId NOT IN (4, 3, 6))--Handle wrong status of PO, greater qty received should be closed status
			) ItemTransactions
			GROUP BY intItemLocationId, intItemId
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
			FROM tblPOPurchase A
			INNER JOIN tblPOPurchaseDetail B ON A.intPurchaseId = B.intPurchaseId
			INNER JOIN tblICItemLocation C
				ON A.intShipToId = C.intLocationId AND B.intItemId = C.intItemId
			WHERE 
			intOrderStatusId NOT IN (4, 3, 6)
			OR (dblQtyOrdered > dblQtyReceived AND intOrderStatusId NOT IN (4, 3, 6))--Handle wrong status of PO, greater qty received should be closed status
			GROUP BY B.intItemId,
			 B.intUnitOfMeasureId,
			 C.intItemLocationId,
			 B.intSubLocationId,
			 B.intStorageLocationId


			--SELECT	ItemTransactions.intItemId
			--		,ItemTransactions.intUnitOfMeasureId AS intItemUOMId
			--		,ItemTransactions.intItemLocationId
			--		,ItemTransactions.intSubLocationId
			--		,ItemTransactions.intStorageLocationId
			--		,dblOnOrder = (CASE WHEN SUM(dblQtyReceived) > SUM(dblQtyOrdered) THEN 0 ELSE SUM(dblQtyOrdered) - SUM(dblQtyReceived) END)
			--FROM	vyuPOStatus ItemTransactions
			--WHERE 
			--intOrderStatusId NOT IN (4, 3, 6)
			--OR (dblQtyOrdered < dblQtyReceived)--Handle wrong status of PO, greater qty received should be closed status
			--GROUP BY ItemTransactions.intItemId, ItemTransactions.intUnitOfMeasureId, ItemTransactions.intItemLocationId, ItemTransactions.intSubLocationId, ItemTransactions.intStorageLocationId
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

	UPDATE tblICItemStockUOM
	SET dblInTransitOutbound = 0 

	MERGE	
	INTO	dbo.tblICItemStock 
	WITH	(HOLDLOCK) 
	AS		ItemStock	
	USING (
		SELECT	i.intItemId
				,il.intItemLocationId
				,dblInTransitOutbound = SUM(ISNULL(Shipment.dblQuantity, 0) - ISNULL(SalesInvoice.dblQuantity, 0)) 
		FROM	tblICItem i INNER JOIN tblICItemLocation il
					ON i.intItemId = il.intItemId 
				OUTER APPLY (
					SELECT  dblQuantity = SUM(dbo.fnCalculateStockUnitQty(d.dblQuantity, u.dblUnitQty))
					FROM	tblICInventoryShipment h INNER JOIN tblICInventoryShipmentItem d
								ON h.intInventoryShipmentId = d.intInventoryShipmentId
							INNER JOIN tblICItemUOM u
								ON u.intItemId = d.intItemId
								AND u.intItemUOMId = d.intItemUOMId						
					WHERE	h.ysnPosted = 1
							AND h.intShipFromLocationId = il.intLocationId
							AND d.intItemId = i.intItemId 
							AND d.intItemId = il.intItemId 
							
				) Shipment 
				OUTER APPLY (
					SELECT  dblQuantity = SUM(dbo.fnCalculateStockUnitQty(d.dblQtyShipped, u.dblUnitQty)) 
					FROM	tblARInvoice h INNER JOIN tblARInvoiceDetail d
								on h.intInvoiceId = d.intInvoiceId
							INNER JOIN tblICItemUOM u
								ON u.intItemId = d.intItemId
								AND u.intItemUOMId = d.intItemUOMId
							INNER JOIN tblICInventoryShipmentItem shipmentItem
								ON shipmentItem.intInventoryShipmentId = d.intInventoryShipmentItemId 
					WHERE	h.ysnPosted = 1
							AND h.intCompanyLocationId = il.intLocationId
							AND d.intItemId = i.intItemId 
							AND d.intItemId = il.intItemId 
				) SalesInvoice 
		GROUP BY il.intItemLocationId, i.intItemId
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
				,SubLocation.intSubLocationId
				,StorageLocation.intStorageLocationId
				,dblInTransitOutbound = SUM(ISNULL(Shipment.dblQuantity, 0) - ISNULL(SalesInvoice.dblQuantity, 0)) 
		FROM	tblICItem i INNER JOIN tblICItemLocation il
					ON i.intItemId = il.intItemId 
				CROSS APPLY (
					SELECT	intItemUOMId
					FROM	tblICItemUOM stockUOM
					WHERE	stockUOM.intItemId = i.intItemId
							AND stockUOM.ysnStockUnit = 1
				) StockUOM
				OUTER APPLY (
					SELECT	intSubLocationId = intCompanyLocationSubLocationId
					FROM	tblSMCompanyLocationSubLocation sub
					WHERE	sub.intCompanyLocationId = il.intLocationId 
					UNION ALL	
					SELECT	intSubLocationId = NULL
				) SubLocation 
				OUTER APPLY (
					SELECT	intStorageLocationId 
					FROM	tblICStorageLocation storage 
					WHERE	storage.intLocationId = il.intLocationId
							AND storage.intSubLocationId = SubLocation.intSubLocationId  
					UNION ALL	
					SELECT	intSubLocationId = NULL
				) StorageLocation
 				OUTER APPLY (
					SELECT  dblQuantity = SUM(dbo.fnCalculateStockUnitQty(d.dblQuantity, u.dblUnitQty))
					FROM	tblICInventoryShipment h INNER JOIN tblICInventoryShipmentItem d
								ON h.intInventoryShipmentId = d.intInventoryShipmentId
							INNER JOIN tblICItemUOM u
								ON u.intItemId = d.intItemId
								AND u.intItemUOMId = d.intItemUOMId						
					WHERE	h.ysnPosted = 1
							AND h.intShipFromLocationId = il.intLocationId
							AND d.intItemId = i.intItemId 
							AND d.intItemId = il.intItemId 
							AND ISNULL(d.intSubLocationId, 0) = ISNULL(SubLocation.intSubLocationId, 0) 
							AND ISNULL(d.intStorageLocationId, 0) = ISNULL(StorageLocation.intStorageLocationId, 0) 							
				) Shipment 
				OUTER APPLY (
					SELECT  dblQuantity = SUM(dbo.fnCalculateStockUnitQty(d.dblQtyShipped, u.dblUnitQty))
					FROM	tblARInvoice h INNER JOIN tblARInvoiceDetail d
								on h.intInvoiceId = d.intInvoiceId
							INNER JOIN tblICItemUOM u
								ON u.intItemId = d.intItemId
								AND u.intItemUOMId = d.intItemUOMId
							INNER JOIN tblICInventoryShipmentItem shipmentItem
								ON shipmentItem.intInventoryShipmentId = d.intInventoryShipmentItemId 
					WHERE	h.ysnPosted = 1
							AND h.intCompanyLocationId = il.intLocationId
							AND d.intItemId = i.intItemId 
							AND d.intItemId = il.intItemId 
							AND ISNULL(d.intSubLocationId, 0) = ISNULL(SubLocation.intSubLocationId, 0) 
							AND ISNULL(d.intStorageLocationId, 0) = ISNULL(StorageLocation.intStorageLocationId, 0) 
				) SalesInvoice 
			GROUP BY i.intItemId, il.intItemLocationId, StockUOM.intItemUOMId, SubLocation.intSubLocationId, StorageLocation.intStorageLocationId
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
				,SubLocation.intSubLocationId
				,StorageLocation.intStorageLocationId
				,dblInTransitOutbound = SUM(ISNULL(Shipment.dblQuantity, 0) - ISNULL(SalesInvoice.dblQuantity, 0)) 
		FROM	tblICItem i INNER JOIN tblICItemLocation il
					ON i.intItemId = il.intItemId 
				INNER JOIN tblICItemUOM uom
					ON uom.intItemId = i.intItemId
					AND ISNULL(uom.ysnStockUnit, 0) = 0
				OUTER APPLY (
					SELECT	intSubLocationId = intCompanyLocationSubLocationId
					FROM	tblSMCompanyLocationSubLocation sub
					WHERE	sub.intCompanyLocationId = il.intLocationId 
					UNION ALL	
					SELECT	intSubLocationId = NULL
				) SubLocation 
				OUTER APPLY (
					SELECT	intStorageLocationId 
					FROM	tblICStorageLocation storage 
					WHERE	storage.intLocationId = il.intLocationId
							AND storage.intSubLocationId = SubLocation.intSubLocationId  
					UNION ALL	
					SELECT	intSubLocationId = NULL
				) StorageLocation
 				OUTER APPLY (
					SELECT  dblQuantity = SUM(d.dblQuantity)
					FROM	tblICInventoryShipment h INNER JOIN tblICInventoryShipmentItem d
								ON h.intInventoryShipmentId = d.intInventoryShipmentId
					WHERE	h.ysnPosted = 1
							AND h.intShipFromLocationId = il.intLocationId
							AND d.intItemId = i.intItemId 
							AND d.intItemId = il.intItemId 
							AND d.intItemUOMId = uom.intItemUOMId
							AND ISNULL(d.intSubLocationId, 0) = ISNULL(SubLocation.intSubLocationId, 0) 
							AND ISNULL(d.intStorageLocationId, 0) = ISNULL(StorageLocation.intStorageLocationId, 0) 							
				) Shipment 
				OUTER APPLY (
					SELECT  dblQuantity = SUM(d.dblQtyShipped)
					FROM	tblARInvoice h INNER JOIN tblARInvoiceDetail d
								on h.intInvoiceId = d.intInvoiceId
							INNER JOIN tblICInventoryShipmentItem shipmentItem
								ON shipmentItem.intInventoryShipmentId = d.intInventoryShipmentItemId 
					WHERE	h.ysnPosted = 1
							AND h.intCompanyLocationId = il.intLocationId
							AND d.intItemId = i.intItemId 
							AND d.intItemId = il.intItemId 
							AND d.intItemUOMId = uom.intItemUOMId
							AND ISNULL(d.intSubLocationId, 0) = ISNULL(SubLocation.intSubLocationId, 0) 
							AND ISNULL(d.intStorageLocationId, 0) = ISNULL(StorageLocation.intStorageLocationId, 0) 
				) SalesInvoice 
			GROUP BY i.intItemId, il.intItemLocationId, uom.intItemUOMId, SubLocation.intSubLocationId, StorageLocation.intStorageLocationId
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
	FROM	tblICItemStock s 

	UPDATE	s
	SET		dblUnitReserved = 0 
	FROM	tblICItemStockUOM s
			
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
	SELECT	intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,SUM(dblQty)
			,intTransactionId
			,strTransactionId
			,intInventoryTransactionType
			,intSubLocationId
			,intStorageLocationId	 
	FROM	tblICStockReservation r 
	WHERE	r.ysnPosted = 0 
	GROUP BY intItemId
			, intItemLocationId
			, intItemUOMId
			, intLotId
			, intTransactionId
			, strTransactionId
			, intInventoryTransactionType
			, intSubLocationId
			, intStorageLocationId

	-- Call this SP to increase the reserved qty. 
	EXEC dbo.uspICIncreaseReservedQty
		@FixStockReservation
END 