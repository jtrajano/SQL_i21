/*
	This is the stored procedure that handles the Category Costing Method. 
	
	Parameters: 

*/

CREATE PROCEDURE [dbo].[uspICPostCategory]	
	@intCategoryId AS INT
	,@intItemId AS INT
	,@intItemLocationId AS INT
	,@intItemUOMId AS INT
	,@intSubLocationId AS INT
	,@intStorageLocationId AS INT 
	,@dtmDate AS DATETIME
	,@dblQty AS NUMERIC(38,20)
	,@dblUOMQty AS NUMERIC(38,20)
	,@dblCost AS NUMERIC(38,20)	
	,@dblUnitRetail AS NUMERIC(38,20)
	,@dblSalesPrice AS NUMERIC(18,6)	
	,@intCurrencyId AS INT
	,@intTransactionId AS INT
	,@intTransactionDetailId AS INT
	,@strTransactionId AS NVARCHAR(20)
	,@strBatchId AS NVARCHAR(40)
	,@intTransactionTypeId AS INT
	,@strTransactionForm AS NVARCHAR(255)
	,@intEntityUserSecurityId AS INT
	,@intForexRateTypeId AS INT
	,@dblForexRate NUMERIC(38, 20) 
	,@dblAdjustCostValue AS NUMERIC(38,20)
	,@dblAdjustRetailValue AS NUMERIC(38,20)	
	,@intSourceEntityId AS INT = NULL 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4
		,@ACTUALCOST AS INT = 5
		,@CATEGORY AS INT = 6

DECLARE @AdjustTypeCategorySales AS INT = 1
		,@AdjustTypeCategorySalesReturn AS INT = 2
		,@AdjustTypeCategoryCreditMemo AS INT = 3
		,@AdjustTypeCategoryMarkupOrMarkDown AS INT --= 3
		,@AdjustTypeCategoryWriteOff AS INT --= 4
		,@AdjustTypeInventoryCountByCategory AS INT

DECLARE @intTransactionItemUOMId AS INT = @intItemUOMId 

SELECT	TOP 1 @AdjustTypeCategorySales = intTransactionTypeId
FROM	tblICInventoryTransactionType 
WHERE	strName = 'Invoice'

SELECT	TOP 1 @AdjustTypeCategorySalesReturn = intTransactionTypeId
FROM	tblICInventoryTransactionType 
WHERE	strName = 'Sales Return'

SELECT	TOP 1 @AdjustTypeCategoryCreditMemo = intTransactionTypeId
FROM	tblICInventoryTransactionType 
WHERE	strName = 'Credit Memo'

SELECT	TOP 1 @AdjustTypeCategorySalesReturn = intTransactionTypeId
FROM	tblICInventoryTransactionType 
WHERE	strName = 'Inventory Return'

SELECT	TOP 1 @AdjustTypeCategoryMarkupOrMarkDown = intTransactionTypeId
FROM	tblICInventoryTransactionType 
WHERE	strName = 'Retail Mark Ups/Downs'

SELECT	TOP 1 @AdjustTypeCategoryWriteOff = intTransactionTypeId
FROM	tblICInventoryTransactionType 
WHERE	strName = 'Retail Write Offs'

SELECT	TOP 1 @AdjustTypeInventoryCountByCategory = intTransactionTypeId
FROM	tblICInventoryTransactionType 
WHERE	strName = 'Inventory Count By Category'


-- Create the variables for the internal transaction types used by costing. 
DECLARE @INVENTORY_AUTO_VARIANCE AS INT = 1;
DECLARE @INVENTORY_WRITE_OFF_SOLD AS INT = 2;
DECLARE @INVENTORY_REVALUE_SOLD AS INT = 3;
DECLARE @INVENTORY_AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK AS INT = 35;

-- Create the variables 
DECLARE  @dblCostValue AS NUMERIC(38,20)
		,@dblRetailValue AS NUMERIC(38,20)
		,@dblAverageMargin AS NUMERIC(38,20)
		,@dblValue AS NUMERIC(38,20)
		,@dblGrossMarginPct AS Numeric(38,20);

DECLARE @TransactionType_InventoryReceipt AS INT = 4
		,@TransactionType_InventoryReturn AS INT = 42

		,@InventoryTransactionIdentityId AS INT 
		,@dtmCreated AS DATETIME 

-- Exit immediately if there is nothing to post. 
IF @dblAdjustRetailValue IS NULL AND ISNULL(@dblQty, 0) = 0
BEGIN 
	RETURN;
END 


-- Do Sales Adjustments for Category Retail 
IF @intTransactionTypeId IN (@AdjustTypeCategorySales, @AdjustTypeCategoryCreditMemo)--AND (@dblUnitRetail IS NOT NULL OR @dblSalesPrice)
BEGIN
	SET @dblAdjustRetailValue = dbo.fnMultiply(@dblQty, ISNULL(@dblUnitRetail,@dblSalesPrice));

	-- Compute Cost based from AverageMargin
	SET @dblCostValue = @dblAdjustRetailValue - dbo.fnMultiply(@dblAdjustRetailValue, dbo.fnICGetCategoryAverageMargin(@intCategoryId,@intItemLocationId));
	SET @dblCost = ABS(@dblCostValue);
	SET @dblValue = @dblCostValue;
	
	-- Set Default Values for Inventory Transaction table
	SET @dblQty = 0;
	SET @dblUOMQty = 0;
	SET @dblRetailValue = @dblAdjustRetailValue;
END

-- If Qty is known. Do it here. 
-- It will update the Total Cost Value and Total Retail Value using the supplied item cost and retail price. 
IF @intTransactionTypeId NOT IN (@TransactionType_InventoryReturn) AND @dblAdjustRetailValue IS NULL 
BEGIN 
	IF EXISTS (SELECT 1 FROM tblICItem i WHERE i.intItemId = @intItemId AND ISNULL(i.ysnSeparateStockForUOMs, 0) = 0) 
	BEGIN 	
		-- Replace the UOM to 'Stock Unit'. 
		-- Convert the Qty, Cost, and Sales Price to stock UOM. 
		SELECT 
			@dblQty = dbo.fnCalculateQtyBetweenUOM(@intItemUOMId, iu.intItemUOMId, @dblQty) 
			,@dblCost = dbo.fnCalculateCostBetweenUOM(@intItemUOMId, iu.intItemUOMId, @dblCost) 
			,@dblSalesPrice = dbo.fnCalculateCostBetweenUOM(@intItemUOMId, iu.intItemUOMId, @dblSalesPrice) 		
			,@intItemUOMId = iu.intItemUOMId
			,@dblUOMQty = iu.dblUnitQty
		FROM 
			tblICItemUOM iu 
		WHERE 
			iu.intItemId = @intItemId 		
			AND iu.ysnStockUnit = 1
			AND iu.intItemUOMId <> @intItemUOMId -- Do not do the conversion if @intItemUOMId is already the stock uom. 
	END 

	-- If Adding stocks, compute the cost value and retail value. 
	IF @dblQty > 0 
	BEGIN 
		SET @dblRetailValue = dbo.fnMultiply(@dblQty, @dblUnitRetail) 	
		SET @dblCostValue = dbo.fnMultiply(@dblQty, @dblCost) 		
	END 
	
	-- If Reducing stocks, get the retail value and compute the cost. 
	IF @dblQty < 0 
	BEGIN 
		-- Get the Average Margin from the Category Pricing. 
		SELECT	@dblAverageMargin = dbo.fnICGetCategoryAverageMargin(@intCategoryId,@intItemLocationId);

		-- Get the retail price from the Item Pricing > Sales Price 
		-- and Compute the cost from the Sales Price. 
		-- Formula:
		-- (Retail Price) - ((Retail Price) x (Average Margin))
		SELECT	@dblUnitRetail = itemPricing.dblSalePrice
				,@dblCost = 
					itemPricing.dblSalePrice
					- dbo.fnMultiply(
						itemPricing.dblSalePrice
						,@dblAverageMargin
					)
		FROM	tblICItemPricing itemPricing 
		WHERE	itemPricing.intItemId = @intItemId
				AND itemPricing.intItemLocationId = @intItemLocationId
				
		-- Convert the cost and unit retail from stock unit to @intItemUOM 
		SELECT	@dblUnitRetail = dbo.fnCalculateCostBetweenUOM(
					stockUOM.intItemUOMId
					, @intItemUOMId
					, @dblUnitRetail
				)
				,@dblCost = dbo.fnCalculateCostBetweenUOM(
					stockUOM.intItemUOMId
					, @intItemUOMId
					, @dblCost
				)
		FROM	tblICItemUOM stockUOM
		WHERE	stockUOM.intItemId = @intItemId 
				AND stockUOM.ysnStockUnit = 1						
		
		-- Compute the cost value and retail values
		SET @dblRetailValue = dbo.fnMultiply(@dblQty, @dblUnitRetail) 
		SET @dblCostValue = dbo.fnMultiply(@dblQty, @dblCost) 				
	END 
END 

-- If Qty is unknown and it will only adjust the retail value, then do it here. 
-- It will compute the cost using the Average Margin. 
IF	ISNULL(@dblAdjustRetailValue, 0) <> 0 
	AND ISNULL(@dblAdjustCostValue, 0) = 0 
	AND @intTransactionTypeId NOT IN (@AdjustTypeCategorySales, @AdjustTypeCategoryCreditMemo)
BEGIN 
	-- Compute the Cost Value 
	SET	@dblCostValue = 
				CASE 
					-- Do not compute the cost value if it a Mark Up or Mark Down. 
					WHEN @intTransactionTypeId IN (@AdjustTypeCategoryMarkupOrMarkDown) THEN 
						0.00
					ELSE 			
					-- Formula: 
					-- (Retail Value) - ((Retail Value) x (Average Margin))
						ISNULL(@dblAdjustRetailValue, 0)
						- (
							ISNULL(@dblAdjustRetailValue, 0) * ISNULL(dbo.fnICGetCategoryAverageMargin(@intCategoryId,@intItemLocationId), 0)
						)
				END 

	SET @dblValue = @dblCostValue
	SET @dblRetailValue = @dblAdjustRetailValue
END 

-- Write-Off transaction. 
-- It will adjust both the Cost Value and Retail Value
IF	ISNULL(@dblAdjustRetailValue, 0) <> 0 
	AND ISNULL(@dblAdjustCostValue, 0) <> 0  
	AND @intTransactionTypeId IN (@AdjustTypeCategoryWriteOff, @AdjustTypeInventoryCountByCategory) 
BEGIN 
	SET	@dblCostValue = @dblAdjustCostValue
	SET @dblRetailValue = @dblAdjustRetailValue
	SET @dblQty = 0
	SET @dblValue = @dblAdjustCostValue
END 

-- Create the Inventory Transaction. 
BEGIN
	EXEC [dbo].[uspICPostInventoryTransaction]
		@intItemId = @intItemId
		,@intItemLocationId = @intItemLocationId
		,@intItemUOMId = @intItemUOMId
		,@intSubLocationId = @intSubLocationId
		,@intStorageLocationId = @intStorageLocationId
		,@dtmDate = @dtmDate
		,@dblQty  = @dblQty
		,@dblUOMQty = @dblUOMQty
		,@dblCost = @dblCost
		,@dblValue = @dblValue 
		,@dblSalesPrice = @dblSalesPrice
		,@intCurrencyId = @intCurrencyId
		,@intTransactionId = @intTransactionId
		,@intTransactionDetailId = @intTransactionDetailId
		,@strTransactionId = @strTransactionId
		,@strBatchId = @strBatchId
		,@intTransactionTypeId = @intTransactionTypeId
		,@intLotId = NULL 
		,@intRelatedInventoryTransactionId = NULL 
		,@intRelatedTransactionId = NULL 
		,@strRelatedTransactionId = NULL 
		,@strTransactionForm = @strTransactionForm
		,@intEntityUserSecurityId = @intEntityUserSecurityId
		,@intCostingMethod = @CATEGORY
		,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT
		,@intForexRateTypeId = @intForexRateTypeId
		,@dblForexRate = @dblForexRate
		,@dblUnitRetail = @dblUnitRetail
		,@dblCategoryCostValue = @dblCostValue
		,@dblCategoryRetailValue = @dblRetailValue 
		,@intSourceEntityId = @intSourceEntityId 
		,@intTransactionItemUOMId = @intTransactionItemUOMId
		,@dtmCreated = @dtmCreated OUTPUT 
END 

-- Update the Category Pricing
-- 1. Update the Total Cost Value
-- 2. Update the Total Retail Value
-- 3. Update the Average Margin
BEGIN 
	MERGE	
	INTO	dbo.tblICCategoryPricing 
	WITH	(HOLDLOCK) 
	AS		CategoryPricing	
	USING (
			SELECT	intCategoryId = @intCategoryId
					,intItemLocationId = @intItemLocationId
					,dblCostValue = @dblCostValue
					,dblRetailValue = @dblRetailValue
	) AS CategoryCosting
		ON CategoryPricing.intCategoryId = CategoryCosting.intCategoryId
		AND CategoryPricing.intItemLocationId = CategoryCosting.intItemLocationId

	-- If matched, update the unit on hand qty. 
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblTotalCostValue = ISNULL(dblTotalCostValue, 0) + ISNULL(@dblCostValue, 0) 
				,dblTotalRetailValue = ISNULL(dblTotalRetailValue, 0) + ISNULL(@dblRetailValue, 0) 
				,dblAverageMargin = 
					CASE 
						--WHEN @dblQty < 1 THEN 
						--	CategoryPricing.dblAverageMargin 
						WHEN ISNULL(dblTotalRetailValue, 0) + ISNULL(@dblRetailValue, 0) <> 0 THEN 
							dbo.fnDivide(
								(
									(ISNULL(dblTotalRetailValue, 0) + ISNULL(@dblRetailValue, 0))
									- (ISNULL(dblTotalCostValue, 0) + ISNULL(@dblCostValue, 0))
								)
								, (ISNULL(dblTotalRetailValue, 0) + ISNULL(@dblRetailValue, 0))
							)						
						ELSE 
							0.00
					END

	-- If none found, insert a new item stock record
	WHEN NOT MATCHED THEN 
		INSERT (
			[intCategoryId]
			,[intItemLocationId]
			,[dblTotalCostValue]
			,[dblTotalRetailValue]
			,[dblAverageMargin]
			,[intSort]
			,[intConcurrencyId]
		)
		VALUES (
			@intCategoryId --[intCategoryId]
			,@intItemLocationId--,[intItemLocationId]
			,ISNULL(@dblCostValue,0)--,[dblTotalCostValue]
			,ISNULL(@dblRetailValue, 0)--,[dblTotalRetailValue]
			,--,[dblAverageMargin]
				CASE 
						WHEN ISNULL(@dblRetailValue, 0) <> 0 THEN 
							dbo.fnDivide(
								(
									ISNULL(@dblRetailValue, 0)
									- ISNULL(@dblCostValue, 0)
								)
								, ISNULL(@dblRetailValue, 0)
							)						
						ELSE 
							0.00
					END
			,1--,[intSort]
			,1--,[intConcurrencyId]
		)
	;
END 