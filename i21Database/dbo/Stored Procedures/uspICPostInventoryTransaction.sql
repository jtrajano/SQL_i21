CREATE PROCEDURE [dbo].[uspICPostInventoryTransaction]
	@intItemId INT
	,@intItemLocationId INT
	,@intItemUOMId INT 
	,@intSubLocationId INT
	,@intStorageLocationId INT
	,@dtmDate DATETIME
	,@dblQty NUMERIC(38,20)
	,@dblUOMQty NUMERIC(38,20)
	,@dblCost NUMERIC(38,20)
	,@dblValue NUMERIC(38,20)
	,@dblSalesPrice NUMERIC(18, 6)	
	,@intCurrencyId INT
	--,@dblExchangeRate NUMERIC (38,20) -- OBSOLETE 
	,@intTransactionId INT
	,@intTransactionDetailId INT 
	,@strTransactionId NVARCHAR(40)
	,@strBatchId NVARCHAR(40)
	,@intTransactionTypeId INT
	,@intLotId INT
	,@intRelatedInventoryTransactionId INT
	,@intRelatedTransactionId INT
	,@strRelatedTransactionId NVARCHAR(40)
	,@strTransactionForm NVARCHAR (255)
	,@intEntityUserSecurityId INT
	,@intCostingMethod INT
	,@InventoryTransactionIdentityId INT OUTPUT 
	,@intFobPointId TINYINT = NULL 
	,@intInTransitSourceLocationId INT = NULL 
	,@intForexRateTypeId INT = NULL
	,@dblForexRate NUMERIC(38, 20) = 1
	,@strDescription NVARCHAR(255) = NULL 
	,@strActualCostId NVARCHAR(50) = NULL  
	,@dblUnitRetail NUMERIC(38,20) = NULL  
	,@dblCategoryCostValue NUMERIC(38,20) = NULL  
	,@dblCategoryRetailValue NUMERIC(38,20) = NULL  
	,@intSourceEntityId INT = NULL  
	,@intTransactionItemUOMId INT = NULL 
	,@strSourceType NVARCHAR(100) = NULL 
	,@strSourceNumber NVARCHAR(100) = NULL 
	,@strBOLNumber NVARCHAR(100) = NULL 
	,@intTicketId INT = NULL 
	,@dtmCreated DATETIME = NULL OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

DECLARE @InventoryStockMovementId AS INT 

BEGIN 
	DECLARE @intFunctionalCurrencyId AS INT
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 	
END 

SET @InventoryTransactionIdentityId = NULL
SET @dtmCreated = GETDATE()

-- Initialize the UOM Qty
SELECT	TOP 1
		@dblUOMQty = ItemUOM.dblUnitQty
FROM	tblICItemUOM ItemUOM
WHERE	intItemUOMId = @intItemUOMId

-- Validate Functional Currency
IF ISNULL(@dblForexRate , 0) = 0
BEGIN
	-- 'Unable to post {Transaction Id}. Functional currency is not set for the company.'
	EXEC uspICRaiseError 80197, @strTransactionId
	GOTO _EXIT
END

-- Check if it has an existing inventory trnsaction. If yes, update it instead of creating a new record. 
BEGIN 
	SELECT TOP 1 
		@InventoryTransactionIdentityId = t.intInventoryTransactionId
	FROM 
		tblICInventoryTransaction t
	WHERE
		t.strTransactionId = @strTransactionId
		AND t.strBatchId = @strBatchId
		AND t.intTransactionId = @intTransactionId
		AND t.intTransactionDetailId = @intTransactionDetailId
		AND t.intItemId = @intItemId
		AND t.intItemLocationId = @intItemLocationId
		AND t.intItemUOMId = @intItemUOMId
		AND t.intTransactionTypeId = @intTransactionTypeId
		AND (t.intLotId = @intLotId OR (t.intLotId IS NULL AND @intLotId IS NULL))
		AND (t.intSubLocationId = @intSubLocationId OR (t.intSubLocationId IS NULL AND @intSubLocationId IS NULL))
		AND (t.intStorageLocationId = @intStorageLocationId OR (t.intStorageLocationId IS NULL AND intStorageLocationId IS NULL))
		AND (t.dblCost = @dblCost OR (t.dblCost IS NULL AND @dblCost IS NULL))
		AND (t.dblSalesPrice = @dblSalesPrice OR (t.dblSalesPrice IS NULL AND @dblSalesPrice IS NULL))
		AND (t.intRelatedTransactionId = @intRelatedTransactionId OR (t.intRelatedTransactionId IS NULL AND @intRelatedTransactionId IS NULL))
		AND (t.strRelatedTransactionId = @strRelatedTransactionId OR (t.strRelatedTransactionId IS NULL AND @strRelatedTransactionId IS NULL))
		AND (t.strActualCostId = @strActualCostId OR (t.strActualCostId IS NULL AND @strActualCostId IS NULL))
		AND @dblQty < 0 
		AND t.dblQty < 0 

	UPDATE tblICInventoryTransaction 
	SET 
		dblQty = dblQty + @dblQty
	WHERE 
		intInventoryTransactionId = @InventoryTransactionIdentityId
		AND @InventoryTransactionIdentityId IS NOT NULL 
END 

-- If it does not exists, create a new transaction. 
IF @InventoryTransactionIdentityId IS NULL 
BEGIN 
	INSERT INTO dbo.tblICInventoryTransaction (
			[intItemId] 
			,[intItemLocationId]
			,[intItemUOMId]
			,[intLotId]
			,[dtmDate] 
			,[dblQty] 
			,[dblUOMQty]
			,[dblCost] 
			,[dblValue]
			,[dblSalesPrice] 		
			,[intCurrencyId] 
			,[dblExchangeRate] 
			,[intTransactionId] 
			,[intTransactionDetailId]
			,[strTransactionId] 
			,[strBatchId] 
			,[intTransactionTypeId] 
			,[strRelatedTransactionId]
			,[intRelatedTransactionId]
			,[strTransactionForm]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[ysnIsUnposted]
			,[intRelatedInventoryTransactionId]
			,[dtmCreated] 
			,[intCreatedEntityId] 
			,[intConcurrencyId] 
			,[intCostingMethod]
			,[intFobPointId]
			,[intInTransitSourceLocationId]
			,[intForexRateTypeId]
			,[dblForexRate]
			,[strDescription]
			,[strActualCostId]
			,[dblUnitRetail]
			,[dblCategoryCostValue]
			,[dblCategoryRetailValue]
			,[intCategoryId]
			,[intSourceEntityId]
			,[intCompanyLocationId]
			,[dtmDateCreated]
			,[intTransactionItemUOMId]
			,[strSourceType]
			,[strSourceNumber]
			,[strBOLNumber]
			,[intTicketId]
			,[strAccountIdInventory]
			,[strAccountIdInTransit]
	)
	SELECT	[intItemId]							= @intItemId
			,[intItemLocationId]				= @intItemLocationId
			,[intItemUOMId]						= @intItemUOMId
			,[intLotId]							= @intLotId
			,[dtmDate]							= @dtmDate
			,[dblQty]							= ISNULL(@dblQty, 0)
			,[dblUOMQty]						= ISNULL(@dblUOMQty, 0)
			,[dblCost]							= ISNULL(@dblCost, 0)
			,[dblValue]							= ISNULL(@dblValue, 0)
			,[dblSalesPrice]					= ISNULL(@dblSalesPrice, 0)
			,[intCurrencyId]					= ISNULL(@intCurrencyId, @intFunctionalCurrencyId) 
			,[dblExchangeRate]					= ISNULL(@dblForexRate, 1)
			,[intTransactionId]					= @intTransactionId
			,[intTransactionDetailId]			= @intTransactionDetailId
			,[strTransactionId]					= @strTransactionId
			,[strBatchId]						= @strBatchId
			,[intTransactionTypeId]				= @intTransactionTypeId
			,[strRelatedTransactionId]			= @strRelatedTransactionId
			,[intRelatedTransactionId]			= @intRelatedTransactionId
			,[strTransactionForm]				= @strTransactionForm
			,[intSubLocationId]					= @intSubLocationId
			,[intStorageLocationId]				= @intStorageLocationId
			,[ysnIsUnposted]					= 0 
			,[intRelatedInventoryTransactionId] = @intRelatedInventoryTransactionId
			,[dtmCreated]						= @dtmCreated
			,[intCreatedEntityId]				= @intEntityUserSecurityId
			,[intConcurrencyId]					= 1
			,[intCostingMethod]					= @intCostingMethod
			,[intFobPointId]					= @intFobPointId
			,[intInTransitSourceLocationId]		= @intInTransitSourceLocationId
			,[intForexRateTypeId]				= @intForexRateTypeId	
			,[dblForexRate]						= @dblForexRate
			,[strDescription]					= @strDescription
			,[strActualCostId]					= @strActualCostId
			,[dblUnitRetail]					= @dblUnitRetail
			,[dblCategoryCostValue]				= @dblCategoryCostValue
			,[dblCategoryRetailValue]			= @dblCategoryRetailValue 
			,[intCategoryId]					= i.intCategoryId
			,[intSourceEntityId]				= @intSourceEntityId
			,[intCompanyLocationId]				= [location].intCompanyLocationId
			,[dtmDateCreated]					= GETUTCDATE()
			,[intTransactionItemUOMId]			= @intTransactionItemUOMId
			,[strSourceType]					= @strSourceType
			,[strSourceNumber]					= @strSourceNumber
			,[strBOLNumber]						= @strBOLNumber
			,[intTicketId]						= @intTicketId
			,[strAccountIdInventory]			= glAccountIdInventory.strAccountId
			,[strAccountIdInTransit]			= glAccountIdInTransit.strAccountId
	FROM	tblICItem i 
			CROSS APPLY [dbo].[fnICGetCompanyLocation](@intItemLocationId, @intInTransitSourceLocationId) [location]
			OUTER APPLY dbo.fnGetItemGLAccountAsTable(
				@intItemId
				,ISNULL(@intInTransitSourceLocationId, @intItemLocationId)
				,'Inventory'
			) accountIdInventory
			LEFT JOIN tblGLAccount glAccountIdInventory
				ON accountIdInventory.intAccountId = glAccountIdInventory.intAccountId
			OUTER APPLY dbo.fnGetItemGLAccountAsTable(
				@intItemId
				,ISNULL(@intInTransitSourceLocationId, @intItemLocationId)
				,'Inventory In-Transit'
			) accountIdInTransit
			LEFT JOIN tblGLAccount glAccountIdInTransit
				ON accountIdInTransit.intAccountId = glAccountIdInTransit.intAccountId

	WHERE	i.intItemId = @intItemId
			AND @intItemId IS NOT NULL
			AND @intItemLocationId IS NOT NULL
			AND @intItemUOMId IS NOT NULL 

	SET @InventoryTransactionIdentityId = SCOPE_IDENTITY();
END 

IF @intLotId IS NOT NULL 
BEGIN 
	DECLARE @ActiveLotStatus AS INT = 1
	EXEC dbo.uspICPostInventoryLotTransaction
		@intItemId 
		,@intLotId 
		,@intItemLocationId 
		,@intItemUOMId 
		,@intSubLocationId 
		,@intStorageLocationId 
		,@dtmDate 
		,@dblQty 
		,@dblCost
		,@intTransactionId 
		,@strTransactionId 
		,@strBatchId 
		,@ActiveLotStatus 
		,@intTransactionTypeId 
		,@strTransactionForm 
		,@intEntityUserSecurityId 
		,@intSourceEntityId
		,@strSourceType 
		,@strSourceNumber
		,@strBOLNumber
		,@intTicketId 
		,NULL  
END

IF @InventoryTransactionIdentityId IS NOT NULL 
BEGIN 
	------------------------------------------------------------
	-- Update the Stock Movement
	------------------------------------------------------------
	EXEC uspICPostInventoryStockMovement
		@InventoryTransactionId = @InventoryTransactionIdentityId
		,@InventoryTransactionStorageId = NULL
		,@InventoryStockMovementId = @InventoryStockMovementId OUTPUT 

	------------------------------------------------------------
	-- Update the Valuation Summary
	------------------------------------------------------------
	EXEC [uspICUpdateInventoryValuationSummary]
		@intItemId 
		,@intItemLocationId 
		,@intSubLocationId 
		,@intStorageLocationId 
		,@intItemUOMId 
		,@dblQty 
		,@dblCost 
		,@dblValue
		,@intTransactionTypeId 
		,@dtmDate
		,@intInTransitSourceLocationId
		
	-----------------------------------------
	-- Log the Daily Stock Quantity
	-----------------------------------------
	BEGIN 
		EXEC uspICPostStockDailyQuantity 
			@intInventoryTransactionId = @InventoryTransactionIdentityId
	END 
END 

_EXIT:
