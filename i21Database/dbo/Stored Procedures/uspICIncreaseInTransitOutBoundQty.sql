/*
	uspICIncreaseInTransitOutBoundQty
	Update the tblICItemStock and tblICItemStockUOM tables. 
	It will increase (or decrease) the dblInTransitOutBound qty if the FOB Point is 'Destination'. 	

*/
CREATE PROCEDURE [dbo].[uspICIncreaseInTransitOutBoundQty]
	@ItemsToIncreaseInTransitOutBound AS InTransitTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2;

DECLARE @TransactionType_Invoice AS INT;

SELECT	TOP 1 @TransactionType_Invoice = intTransactionTypeId
FROM	tblICInventoryTransactionType 
WHERE	strName = 'Invoice';
		
-- Validate the item-location. 
BEGIN 
	DECLARE @intItemId AS INT 
			,@strItemNo AS NVARCHAR(50)

	SELECT	@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	@ItemsToIncreaseInTransitOutBound ItemsToValidate LEFT JOIN dbo.tblICItem Item
				ON ItemsToValidate.intItemId = Item.intItemId
	WHERE	NOT EXISTS (
				SELECT TOP 1 1 
				FROM	dbo.tblICItemLocation
				WHERE	tblICItemLocation.intItemLocationId = ItemsToValidate.intItemLocationId
						AND tblICItemLocation.intItemId = ItemsToValidate.intItemId
			)
			AND ItemsToValidate.intItemId IS NOT NULL 	
			
	-- 'Item-Location is invalid or missing for {Item}.'
	IF @intItemId IS NOT NULL 
	BEGIN 
		EXEC uspICRaiseError 80002, @strItemNo;
		GOTO _Exit
	END 
END 
	
-- Do an upsert for the Item Stock table when updating the In-Transit Outbound Qty
MERGE	
INTO	dbo.tblICItemStock 
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	ob.intItemId
				,ob.intItemLocationId
				,ob.intTransactionTypeId
				,dtmTransactionDate = CASE 
										WHEN ARI.ysnPosted = 0 
										THEN [dbo].[fnICGetPreviousTransactionDate](ob.intItemId, ob.intItemLocationId, NULL, NULL, ob.intTransactionTypeId) 
										ELSE ob.dtmTransactionDate 
									END
				,Aggregrate_Qty =  SUM(dbo.fnCalculateQtyBetweenUOM(ob.intItemUOMId, StockUOM.intItemUOMId, ob.dblQty))   --SUM(ISNULL(dbo.fnCalculateCostBetweenUOM(ob.intItemUOMId, StockUOM.intItemUOMId, ob.dblQty), 0)) 	-- Convert the qty to stock unit. 			
		FROM	@ItemsToIncreaseInTransitOutBound ob 
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = ob.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM 
				LEFT JOIN tblARInvoice ARI
					ON ARI.intInvoiceId = ob.intTransactionId
					AND ob.intTransactionTypeId = @TransactionType_Invoice
		--WHERE	ISNULL(ob.intFOBPointId, @FOB_DESTINATION) = @FOB_DESTINATION -- IF NULL, default to @FOB_DESTINATION so that the other modules using this sp will not be affected. 
		GROUP BY ob.intItemId
				, ob.intItemLocationId
				, ob.intTransactionTypeId
				, ARI.ysnPosted
				, ob.dtmTransactionDate
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId

-- If matched, update the In-Transit Outbound qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblInTransitOutbound = ISNULL(ItemStock.dblInTransitOutbound, 0) + Source_Query.Aggregrate_Qty 
			,dtmLastSaleDate = CASE 
								WHEN Source_Query.intTransactionTypeId = @TransactionType_Invoice 
									AND ((Source_Query.Aggregrate_Qty < 0 AND Source_Query.dtmTransactionDate IS NOT NULL 
										AND Source_Query.dtmTransactionDate > ISNULL(ItemStock.dtmLastSaleDate, '2000-01-01'))
									OR Source_Query.Aggregrate_Qty > 0)
								THEN Source_Query.dtmTransactionDate
								ELSE ItemStock.dtmLastSaleDate
							END

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,dblInTransitOutbound
		,intSort
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,CASE WHEN Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE Source_Query.Aggregrate_Qty END -- dblInTransitOutbound
		,NULL 
		,1	
	)		
;

-- Do an upsert for the Item Stock UOM table when updating the In-Transit Outbound Qty
MERGE	
INTO	dbo.tblICItemStockUOM
WITH	(HOLDLOCK) 
AS		ItemStockUOM
USING (
		-- If separate UOMs is not enabled, convert the qty to stock unit. 
		SELECT	ob.intItemId
				,ob.intItemLocationId
				,StockUOM.intItemUOMId
				,ob.intSubLocationId
				,ob.intStorageLocationId
				,ob.intTransactionTypeId
				,dtmTransactionDate = 
					CASE 
						WHEN ARI.ysnPosted = 0 THEN 
							[dbo].[fnICGetPreviousTransactionDate](
								ob.intItemId
								, ob.intItemLocationId
								, ob.intSubLocationId
								, ob.intStorageLocationId
								, ob.intTransactionTypeId
							) 
						ELSE 
							ob.dtmTransactionDate 
					END
				,Aggregrate_Qty = SUM(
						dbo.fnCalculateQtyBetweenUOM(ob.intItemUOMId, StockUOM.intItemUOMId, ISNULL(ob.dblQty, 0))
					)
		FROM	@ItemsToIncreaseInTransitOutBound ob 
				INNER JOIN tblICItem i
					ON ob.intItemId = i.intItemId 
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = ob.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM 
				LEFT JOIN tblARInvoice ARI
					ON ARI.intInvoiceId = ob.intTransactionId
					AND ob.intTransactionTypeId = @TransactionType_Invoice
		WHERE	
				ISNULL(i.ysnSeparateStockForUOMs, 0) = 0 
				AND i.strLotTracking NOT LIKE 'Yes%'
		GROUP BY ob.intItemId
				, ob.intItemLocationId
				, StockUOM.intItemUOMId
				, ob.intSubLocationId
				, ob.intStorageLocationId
				, ob.intTransactionTypeId
				, ARI.ysnPosted
				, ob.dtmTransactionDate 

		-- If separate UOMs is enabled, don't convert the qty. Track it using the same uom. 
		UNION ALL 
		SELECT	ob.intItemId
				,ob.intItemLocationId
				,ob.intItemUOMId
				,ob.intSubLocationId
				,ob.intStorageLocationId
				,ob.intTransactionTypeId
				,dtmTransactionDate =
					CASE 
						WHEN ARI.ysnPosted = 0 THEN 
							[dbo].[fnICGetPreviousTransactionDate](
								ob.intItemId
								, ob.intItemLocationId
								, ob.intSubLocationId
								, ob.intStorageLocationId
								, ob.intTransactionTypeId
							) 
						ELSE 
							ob.dtmTransactionDate 
					END
				,Aggregrate_Qty = SUM(ob.dblQty) 
		FROM	@ItemsToIncreaseInTransitOutBound ob 
				INNER JOIN tblICItem i
					ON ob.intItemId = i.intItemId 
				LEFT JOIN tblARInvoice ARI
					ON ARI.intInvoiceId = ob.intTransactionId
					AND ob.intTransactionTypeId = @TransactionType_Invoice
		WHERE 
				ISNULL(i.ysnSeparateStockForUOMs, 0) = 1
				OR i.strLotTracking LIKE 'Yes%'
		GROUP BY ob.intItemId
				, ob.intItemLocationId
				, ob.intItemUOMId
				, ob.intSubLocationId
				, ob.intStorageLocationId
				, ob.intTransactionTypeId
				, ARI.ysnPosted
				, ob.dtmTransactionDate
) AS Source_Query  
	ON ItemStockUOM.intItemId = Source_Query.intItemId
	AND ItemStockUOM.intItemLocationId = Source_Query.intItemLocationId
	AND ItemStockUOM.intItemUOMId = Source_Query.intItemUOMId
	AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)

-- If matched, update the In-Transit Outbound qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblInTransitOutbound = ISNULL(ItemStockUOM.dblInTransitOutbound, 0) + Source_Query.Aggregrate_Qty 
			,dtmLastSaleDate = CASE 
								WHEN Source_Query.intTransactionTypeId = @TransactionType_Invoice 
									AND ((Source_Query.Aggregrate_Qty < 0 AND Source_Query.dtmTransactionDate IS NOT NULL 
										AND Source_Query.dtmTransactionDate > ISNULL(ItemStockUOM.dtmLastSaleDate, '2000-01-01'))
									OR Source_Query.Aggregrate_Qty > 0)
								THEN Source_Query.dtmTransactionDate
								ELSE ItemStockUOM.dtmLastSaleDate
							END

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId 
		,dblInTransitOutbound
		,dtmLastSaleDate
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,Source_Query.intItemUOMId
		,Source_Query.intSubLocationId
		,Source_Query.intStorageLocationId 
		,Source_Query.Aggregrate_Qty 
		,CASE WHEN Source_Query.intTransactionTypeId = @TransactionType_Invoice AND Source_Query.Aggregrate_Qty < 0 THEN Source_Query.dtmTransactionDate ELSE NULL END
		,1	
	)
;

-- Create the Item Stock Detail 
BEGIN 
	DECLARE		
		@stockType_OnOrder AS INT = 1
		,@stockType_OnStorage AS INT = 2
		,@stockType_OrderCommitted AS INT = 3
		,@stockType_InTransitInbound AS INT = 4
		,@stockType_InTransitOutbound AS INT = 5
		,@stockType_InTransitDirect AS INT = 6
		,@stockType_ConsignedPurchase AS INT = 7
		,@stockType_ConsignedSale AS INT = 8
		,@stockType_Reserved AS INT = 9

	INSERT INTO tblICItemStockDetail (
			intItemStockTypeId 
			,intItemId   
			,intItemLocationId 
			,intItemUOMId 
			,intSubLocationId 
			,intStorageLocationId 
			,strTransactionId
			,dblQty
			,intConcurrencyId
			,dtmDate
			,dtmDateCreated
	)
	SELECT 
			intItemStockTypeId	= @stockType_InTransitOutbound
			,intItemId			= intItemId
			,intItemLocationId  = intItemLocationId
			,intItemUOMId		= intItemUOMId
			,intSubLocationId	= intSubLocationId
			,intStorageLocationId = intStorageLocationId 
			,strTransactionId	= strTransactionId
			,dblQty				= dblQty
			,intConcurrencyId	= 1
			,dtmDate			= cp.dtmTransactionDate
			,dtmDateCreated		= GETDATE()
	FROM	@ItemsToIncreaseInTransitOutBound cp 
	WHERE	ISNULL(dblQty, 0) <> 0 
END 

_Exit: 