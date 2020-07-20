CREATE PROCEDURE [dbo].[uspICIncreaseUsageQty]
	@ItemsToIncreaseUsageQty AS ItemCostingTableType READONLY
	,@intEntityUserSecurityId AS INT = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Validate the item-location. 
BEGIN 
	DECLARE @intItemId AS INT 
			,@strItemNo AS NVARCHAR(50)

	SELECT	@intItemId = Item.intItemId 
			,@strItemNo = Item.strItemNo
	FROM	@ItemsToIncreaseUsageQty ItemsToValidate LEFT JOIN dbo.tblICItem Item
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

-- Do an upsert for the Item Stock table when updating the In-Transit Inbound Qty
MERGE	
INTO	dbo.tblICItemStockUsagePerPeriod 
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	ib.intItemId
				,ib.intItemLocationId
				,fyp.intGLFiscalYearPeriodId
				,Aggregrate_Qty = SUM(dbo.fnCalculateQtyBetweenUOM(ib.intItemUOMId, StockUOM.intItemUOMId, ib.dblQty))  
		FROM	@ItemsToIncreaseUsageQty ib 
				CROSS APPLY (
					SELECT	TOP 1 
							intItemUOMId
							,dblUnitQty 
					FROM	tblICItemUOM iUOM
					WHERE	iUOM.intItemId = ib.intItemId
							AND iUOM.ysnStockUnit = 1 
				) StockUOM 
				CROSS APPLY (
					SELECT TOP 1 
						fyp.intGLFiscalYearPeriodId
					FROM
						tblGLFiscalYearPeriod fyp
					WHERE
						dbo.fnRemoveTimeOnDate(ib.dtmDate) BETWEEN fyp.dtmStartDate AND fyp.dtmEndDate 
				) fyp
		GROUP BY 
			ib.intItemId
			,ib.intItemLocationId
			,fyp.intGLFiscalYearPeriodId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId
	AND ItemStock.intGLFiscalYearPeriodId = Source_Query.intGLFiscalYearPeriodId

-- If matched, update the In-Transit Inbound qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		
		dblQty = CASE WHEN ISNULL(ItemStock.dblQty, 0) + Source_Query.Aggregrate_Qty < 0 THEN 0 ELSE ISNULL(ItemStock.dblQty, 0) + Source_Query.Aggregrate_Qty END 
		,dtmDateModified = GETDATE()

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,intGLFiscalYearPeriodId
		,dblQty
		,dtmDateCreated
		,intCreatedByUserId
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,Source_Query.intGLFiscalYearPeriodId 
		,Source_Query.Aggregrate_Qty 
		,GETDATE()
		,@intEntityUserSecurityId
		,1	
	)		
;

-- Create the Item Stock Detail 
BEGIN 
	DECLARE		
		@stockType_UsageQty AS INT = 12

	INSERT INTO tblICItemStockDetail (
			intItemStockTypeId 
			,intItemId   
			,intItemLocationId 
			,intItemUOMId 
			,intSubLocationId 
			,intStorageLocationId 
			,strTransactionId
			,dblQty
			,dtmDateCreated
			,dtmDateModified
			,intModifiedByUserId
			,intConcurrencyId
	)
	SELECT 
			intItemStockTypeId	= @stockType_UsageQty
			,intItemId			= intItemId
			,intItemLocationId  = intItemLocationId
			,intItemUOMId		= intItemUOMId
			,intSubLocationId	= intSubLocationId
			,intStorageLocationId = intStorageLocationId 
			,strTransactionId	= strTransactionId
			,dblQty				= dblQty
			,dtmDateCreated		= dtmDate
			,dtmDateModified	= GETDATE() 
			,intModifiedByUserId = @intEntityUserSecurityId
			,intConcurrencyId	= 1
	FROM	@ItemsToIncreaseUsageQty cp 
	WHERE	ISNULL(dblQty, 0) <> 0 
END 

_Exit: