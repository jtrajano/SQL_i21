CREATE PROCEDURE [dbo].[uspARUpdateOnHand]
	  @TransactionId	INT
	, @Post				BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN
	DECLARE @ItemsToDeductOnHand AS ItemCostingTableType	
	DECLARE @IsCreditMemo BIT = 0
	IF (SELECT TOP 1 strTransactionType FROM tblARInvoice WHERE intInvoiceId = @TransactionId) = 'Credit Memo'
		BEGIN
			SET @IsCreditMemo = 1
		END
	ELSE
		BEGIN
			SET @IsCreditMemo = 0
		END

	INSERT INTO @ItemsToDeductOnHand
		 ([intItemId]
		, [intItemLocationId]
		, [intItemUOMId]
		, [dtmDate]
		, [dblQty]
		, [dblUOMQty]
		, [dblCost]
		, [dblValue]
		, [dblSalesPrice]
		, [intCurrencyId]
		, [dblExchangeRate]
		, [intTransactionId]
		, [intTransactionDetailId] 
		, [strTransactionId]
		, [intTransactionTypeId])
	SELECT ID.intItemId
		, IL.intItemLocationId
		, ID.intItemUOMId
		, I.dtmDate
		, ID.dblQtyShipped
		, UOM.dblUnitQty
		, IST.dblLastCost
		, 0
		, ID.dblPrice
		, I.intCurrencyId
		, 0
		, I.intInvoiceId
		, ID.intInvoiceDetailId
		, I.strInvoiceNumber
		, 7
	FROM tblARInvoiceDetail ID
		INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
		INNER JOIN tblICItemLocation IL ON ID.intItemId = IL.intItemId AND I.intCompanyLocationId = IL.intLocationId
		INNER JOIN tblICItemUOM UOM ON UOM.intItemUOMId = ID.intItemUOMId
		LEFT OUTER JOIN vyuICGetItemStock IST ON ID.intItemId = IST.intItemId  AND I.intCompanyLocationId = IST.intLocationId 
	WHERE ID.intInvoiceId = @TransactionId 
		AND ISNULL(ID.intInventoryShipmentItemId, 0) > 0
		
	UPDATE @ItemsToDeductOnHand
	SET dblQty = dblQty * (CASE WHEN @Post = 1
								THEN (CASE WHEN @IsCreditMemo = 0 THEN -1 ELSE 1 END)
								ELSE (CASE WHEN @IsCreditMemo = 0 THEN 1 ELSE -1 END)
							END) 
END

BEGIN 
	DECLARE @intItemId AS INT 
			,@strItemNo AS NVARCHAR(50)

	SELECT	@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	@ItemsToDeductOnHand ItemsToValidate LEFT JOIN dbo.tblICItem Item
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
		RAISERROR('Item Location is invalid or missing for %s.', 11, 1, @strItemNo)
		GOTO _Exit
	END 
END

-- Do an upsert for the Item Stock table when updating the On Hand Qty
MERGE	
INTO	dbo.tblICItemStock 
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	intItemId
				,intItemLocationId
				,Aggregrate_UnitOnHandQty = SUM(ISNULL(dblQty, 0) * ISNULL(dblUOMQty, 0))					
		FROM	@ItemsToDeductOnHand
		GROUP BY intItemId, intItemLocationId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId

-- If matched, update the On-Hand qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblUnitOnHand = CASE WHEN ISNULL(ItemStock.dblUnitOnHand, 0) + Source_Query.Aggregrate_UnitOnHandQty < 0 THEN 0 ELSE ISNULL(ItemStock.dblUnitOnHand, 0) + Source_Query.Aggregrate_UnitOnHandQty END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,dblUnitOnHand		
		,intSort
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,CASE WHEN Source_Query.Aggregrate_UnitOnHandQty < 0 THEN 0 ELSE Source_Query.Aggregrate_UnitOnHandQty END		
		,NULL 
		,1	
	)		
;

-- Do an upsert for the Item Stock UOM table when updating the On Hand Qty
MERGE	
INTO	dbo.tblICItemStockUOM
WITH	(HOLDLOCK) 
AS		ItemStockUOM
USING (
		SELECT	intItemId
				,intItemLocationId
				,intItemUOMId
				,intSubLocationId
				,intStorageLocationId
				,Aggregrate_UnitOnHandQty = SUM(ISNULL(dblQty, 0))
		FROM	@ItemsToDeductOnHand
		GROUP BY intItemId, intItemLocationId, intItemUOMId, intSubLocationId, intStorageLocationId
) AS Source_Query  
	ON ItemStockUOM.intItemId = Source_Query.intItemId
	AND ItemStockUOM.intItemLocationId = Source_Query.intItemLocationId
	AND ItemStockUOM.intItemUOMId = Source_Query.intItemUOMId
	AND ISNULL(ItemStockUOM.intSubLocationId, 0) = ISNULL(Source_Query.intSubLocationId, 0)
	AND ISNULL(ItemStockUOM.intStorageLocationId, 0) = ISNULL(Source_Query.intStorageLocationId, 0)

-- If matched, update the On-Hand qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblOnHand = CASE WHEN ISNULL(ItemStockUOM.dblOnHand, 0) + Source_Query.Aggregrate_UnitOnHandQty < 0 THEN 0 ELSE ISNULL(ItemStockUOM.dblOnHand, 0) + Source_Query.Aggregrate_UnitOnHandQty END 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId		
		,dblOnHand
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,Source_Query.intItemUOMId
		,Source_Query.intSubLocationId
		,Source_Query.intStorageLocationId		
		,CASE WHEN Source_Query.Aggregrate_UnitOnHandQty < 0 THEN 0 ELSE Source_Query.Aggregrate_UnitOnHandQty END
		,1	
	)
;

_Exit:

GO