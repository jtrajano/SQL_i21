/*
	This is the stored procedure that handles the moving average costing method. 
	
	Parameters: 
	@intItemId - The item to process

	@intLocationId - The location where the item is being process. 

	@intItemUOMId - The UOM used for the item in a transaction. Each transaction can use different kinds of UOM on its items. 
	
	@dtmDate - The date used in the transaction and posting. 

	@dblQty - A positive qty indicates an increase of stock. A negative qty indicates a decrease in stock. 

	@dblUOMQty - The stock unit qty associated with the UOM. For example, a box may have 10 pieces of an item. In this case, UOM qty will be 10. 

	@dblCost - The cost per base qty of the item. 

	@dblSalesPrice - The sales price of an item sold to the customer. 

	@intCurrencyId - The foreign currency associated with the transaction. 

	@dblExchangeRate - The conversion factor between the base currency and the foreign currency. 

	@intTransactionId - The primary key id used in a transaction. 

	@strTransactionId - The string value of a transaction id. 

	@strBatchId - The batch id to use in generating the g/l entries. 

	@intEntityUserSecurityId - The user who initiated or called this stored procedure. 
*/

CREATE PROCEDURE [dbo].[uspICPostCategoryCosting]	
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
	,@dblAdjustRetailValue AS NUMERIC(38,20)
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

-- Create the variables for the internal transaction types used by costing. 
DECLARE @INVENTORY_AUTO_VARIANCE AS INT = 1;
DECLARE @INVENTORY_WRITE_OFF_SOLD AS INT = 2;
DECLARE @INVENTORY_REVALUE_SOLD AS INT = 3;
DECLARE @INVENTORY_AUTO_VARIANCE_ON_SOLD_OR_USED_STOCK AS INT = 35;

-- Create the variables 
DECLARE  @dblCostValue AS NUMERIC(38,20)
		,@dblRetailValue AS NUMERIC(38,20)

DECLARE @TransactionType_InventoryReceipt AS INT = 4
		,@TransactionType_InventoryReturn AS INT = 42

		,@InventoryTransactionIdentityId AS INT 

-- Exit immediately if there is nothing to post. 
IF @dblAdjustRetailValue IS NULL AND ISNULL(@dblQty, 0) = 0
BEGIN 
	RETURN;
END 

-- Update the total cost, total retail, and average margin. 
-- Post the Inventory transaction
IF @intTransactionTypeId NOT IN (@TransactionType_InventoryReturn) AND @dblAdjustRetailValue IS NULL 
BEGIN 
	SET @dblCostValue = dbo.fnMultiply(@dblCost, @dblQty) 
	SET @dblRetailValue = dbo.fnMultiply(@dblCost, @dblUnitRetail) 	

	UPDATE	CategoryPricing
	SET		dblTotalCostValue = ISNULL(dblTotalCostValue, 0) + ISNULL(@dblCostValue, 0) 
			,dblTotalRetailValue = ISNULL(dblTotalRetailValue, 0) + ISNULL(@dblRetailValue, 0) 
			,dblAverageMargin = 
				CASE 
					WHEN ISNULL(dblTotalRetailValue, 0) + ISNULL(@dblRetailValue, 0) <> 0 THEN 
						dbo.fnDivide(
							(
								(ISNULL(dblTotalRetailValue, 0) + ISNULL(@dblRetailValue, 0))
								- (ISNULL(dblTotalCostValue, 0) + ISNULL(@dblCostValue, 0))
							)
							, (ISNULL(dblTotalRetailValue, 0) + ISNULL(@dblRetailValue, 0))
						)						
					ELSE 
						0
				END
	FROM	tblICCategoryPricing CategoryPricing 
	WHERE	@intTransactionTypeId NOT IN (@TransactionType_InventoryReceipt, @TransactionType_InventoryReturn)
			AND CategoryPricing.intCategoryId = @intCategoryId
			AND CategoryPricing.intItemLocationId = @intItemLocationId

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
			,@dblValue = NULL 
			,@dblSalesPrice = @dblRetailValue
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
			,@intCostingMethod = @AVERAGECOST
			,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT
			,@intForexRateTypeId = @intForexRateTypeId
			,@dblForexRate = @dblForexRate
			,@dblUnitRetail = @dblUnitRetail
			,@dblCostValue = @dblCostValue
			,@dblRetailValue = @dblRetailValue 
END 

-- Adjust the retail value. 
-- Recalculate the Average Margin. 
-- Post the Inventory transaction
IF ISNULL(@dblAdjustRetailValue, 0) <> 0 
BEGIN 
	UPDATE	CategoryPricing
	SET		dblTotalRetailValue = ISNULL(dblTotalRetailValue, 0) + ISNULL(@dblAdjustRetailValue, 0) 
			,dblAverageMargin = 
				CASE 
					WHEN ISNULL(dblTotalRetailValue, 0) + ISNULL(@dblAdjustRetailValue, 0) <> 0 THEN 
						dbo.fnDivide(
							(
								(ISNULL(dblTotalRetailValue, 0) + ISNULL(@dblAdjustRetailValue, 0))
								- (ISNULL(dblTotalCostValue, 0) + ISNULL(@dblCostValue, 0))
							)
							, (ISNULL(dblTotalRetailValue, 0) + ISNULL(@dblAdjustRetailValue, 0))
						)						
					ELSE 
						0
				END
	FROM	tblICCategoryPricing CategoryPricing 
	WHERE	@intTransactionTypeId NOT IN (@TransactionType_InventoryReceipt, @TransactionType_InventoryReturn)
			AND CategoryPricing.intCategoryId = @intCategoryId
			AND CategoryPricing.intItemLocationId = @intItemLocationId

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
			,@dblValue = NULL 
			,@dblSalesPrice = @dblRetailValue
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
			,@intCostingMethod = @AVERAGECOST
			,@InventoryTransactionIdentityId = @InventoryTransactionIdentityId OUTPUT
			,@intForexRateTypeId = @intForexRateTypeId
			,@dblForexRate = @dblForexRate
			,@dblUnitRetail = @dblUnitRetail
			,@dblCostValue = NULL
			,@dblRetailValue = @dblAdjustRetailValue 
END 
