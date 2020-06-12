/*
	Used to reverse the stocks from a posted transaction.
*/
CREATE PROCEDURE [dbo].[uspICUnpostCosting]
	@intTransactionId AS INT
	,@strTransactionId AS NVARCHAR(40)
	,@strBatchId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT
	,@ysnRecap AS BIT = 0 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInventoryTransactionStockToReverse')) 
	DROP TABLE #tmpInventoryTransactionStockToReverse
	
-- Create the temp table 
CREATE TABLE #tmpInventoryTransactionStockToReverse (
	intInventoryTransactionId INT NOT NULL 
	,intTransactionId INT NULL 
	,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	,strRelatedTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	,intRelatedTransactionId INT NULL 
	,intTransactionTypeId INT NOT NULL 
	,dblQty NUMERIC(38, 20) NULL 
)

-- Create the variables for the internal transaction types used by costing. 
DECLARE @AUTO_NEGATIVE AS INT = 1
		,@WRITE_OFF_SOLD AS INT = 2
		,@REVALUE_SOLD AS INT = 3

-- Create the CONSTANT variables for the costing methods
DECLARE @AVERAGECOST AS INT = 1
		,@FIFO AS INT = 2
		,@LIFO AS INT = 3
		,@LOTCOST AS INT = 4
		,@ACTUALCOST AS INT = 5

		,@FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2

		,@Ownership_Own AS INT = 1
		,@Ownership_Storage AS INT = 2

DECLARE @ItemsToUnpost AS dbo.UnpostItemsTableType

DECLARE @intItemId AS INT
		,@intItemUOMId AS INT 
		,@intItemLocationId AS INT 
		,@intSubLocationId AS INT
		,@intStorageLocationId AS INT 					
		,@dblQty AS NUMERIC(38,20) 
		,@dblUOMQty AS NUMERIC(38,20)
		,@dblCost AS NUMERIC(38,20)
		,@intLotId AS INT
		,@dtmDate AS DATETIME
		,@intCurrencyId AS INT 
		,@dblExchangeRate AS DECIMAL (38, 20) 
		,@intTransactionTypeId AS INT
		,@strTransactionForm AS NVARCHAR(255)
		,@intCostingMethod AS INT
		,@intFobPointId AS TINYINT
		,@intInTransitSourceLocationId AS INT 

DECLARE @intTransactionId_AutoNegative AS INT
		,@strTransactionId_AutoNegative AS NVARCHAR(40)
		
-- Get the list of items to unpost
BEGIN 
	-- Insert the items per location, UOM, and if possible also by Lot. 
	INSERT INTO @ItemsToUnpost (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,dblQty
			,dblCost
			,dblUOMQty
			,intSubLocationId
			,intStorageLocationId
			,intInventoryTransactionId
			,intTransactionTypeId
			,intCostingMethod
			,intFobPointId
			,intInTransitSourceLocationId
	)
	SELECT	t.intItemId
			,t.intItemLocationId
			,t.intItemUOMId
			,t.intLotId
			,ISNULL(-t.dblQty, 0)
			,t.dblCost
			,t.dblUOMQty		
			,t.intSubLocationId
			,t.intStorageLocationId
			,t.intInventoryTransactionId
			,t.intTransactionTypeId
			,t.intCostingMethod
			,t.intFobPointId
			,t.intInTransitSourceLocationId 
	FROM	dbo.tblICInventoryTransaction t 
	WHERE	intTransactionId = @intTransactionId
			AND strTransactionId = @strTransactionId
			AND ISNULL(ysnIsUnposted, 0) = 0
			AND (
				ISNULL(t.dblQty, 0) <> 0 
				OR t.intCostingMethod = 6
			)

	-- Get the unpost date. 
	SELECT TOP 1 
		@dtmDate = dbo.fnRemoveTimeOnDate(dtmDate) 
	FROM
		tblICInventoryTransaction t
	WHERE	
		intTransactionId = @intTransactionId
		AND strTransactionId = @strTransactionId
		AND ISNULL(ysnIsUnposted, 0) = 0
		AND (
			ISNULL(t.dblQty, 0) <> 0 
			OR t.intCostingMethod = 6
		)

END 

-----------------------------------------------------------------------------------------------------------------------------
-- Do the Validation
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	DECLARE @ValidateItemsToUnpost AS dbo.UnpostItemsTableType	
	DECLARE @ValidateItemsInTransitToUnpost AS dbo.UnpostItemsTableType	
	DECLARE @returnValue AS INT 

	-- Aggregate the stock qty for a faster validation. (Regular Item Costing)
	INSERT INTO @ValidateItemsToUnpost (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,dblQty
			,intSubLocationId
			,intStorageLocationId
	)
	SELECT	intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,SUM(ISNULL(dblQty, 0))
			,intSubLocationId
			,intStorageLocationId
	FROM	@ItemsToUnpost
	WHERE	intInTransitSourceLocationId IS NULL 
	GROUP BY 
		intItemId
		, intItemLocationId
		, intItemUOMId
		, intLotId
		, intSubLocationId
		, intStorageLocationId

	-- Aggregate the stock qty for a faster validation. (In-Transit Costing)
	INSERT INTO @ValidateItemsInTransitToUnpost (
			intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,dblQty
			,intSubLocationId
			,intStorageLocationId
	)
	SELECT	intItemId
			,intItemLocationId
			,intItemUOMId
			,intLotId
			,SUM(ISNULL(dblQty, 0))				
			,intSubLocationId
			,intStorageLocationId
	FROM	@ItemsToUnpost
	WHERE	intInTransitSourceLocationId IS NOT NULL 
	GROUP BY 
		intItemId
		, intItemLocationId
		, intItemUOMId
		, intLotId
		, intSubLocationId
		, intStorageLocationId

	-- Fill-in the Unit qty from the UOM
	UPDATE	ValidateItemsToUnpost
	SET		dblUOMQty = ItemUOM.dblUnitQty
	FROM	@ValidateItemsToUnpost ValidateItemsToUnpost INNER JOIN dbo.tblICItemUOM ItemUOM
				ON ValidateItemsToUnpost.intItemUOMId = ItemUOM.intItemUOMId

	-- Fill-in the Unit qty from the UOM
	UPDATE	ValidateItemsInTransitToUnpost
	SET		dblUOMQty = ItemUOM.dblUnitQty
	FROM	@ValidateItemsInTransitToUnpost ValidateItemsInTransitToUnpost INNER JOIN dbo.tblICItemUOM ItemUOM
				ON ValidateItemsInTransitToUnpost.intItemUOMId = ItemUOM.intItemUOMId

	EXEC @returnValue = dbo.uspICValidateCostingOnUnpost 
		@ValidateItemsToUnpost
		,@ysnRecap
		,@intTransactionId
		,@strTransactionId

	IF @returnValue < 0 RETURN -1;

	EXEC @returnValue = dbo.uspICValidateInTransitCostingOnUnpost 
		@ValidateItemsInTransitToUnpost
		,@ysnRecap
		,@intTransactionId
		,@strTransactionId

	IF @returnValue < 0 RETURN -1;

END 

-----------------------------------------------------------------------------------------------------------------------------
-- Call the FIFO unpost stored procedures. This is also used in Average Costing.
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostFIFOIn 
		@strTransactionId
		,@intTransactionId
		,@ysnRecap

	EXEC dbo.uspICUnpostFIFOOut
		@strTransactionId
		,@intTransactionId
		,@ysnRecap
END

-----------------------------------------------------------------------------------------------------------------------------
-- Call the LIFO unpost stored procedures 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostLIFOIn 
		@strTransactionId
		,@intTransactionId
		,@ysnRecap

	EXEC dbo.uspICUnpostLIFOOut
		@strTransactionId
		,@intTransactionId
		,@ysnRecap
END


-----------------------------------------------------------------------------------------------------------------------------
-- Call the LOT unpost stored procedures 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostLotIn 
		@strTransactionId
		,@intTransactionId
		,@ysnRecap

	EXEC dbo.uspICUnpostLotOut
		@strTransactionId
		,@intTransactionId
		,@ysnRecap
END

-----------------------------------------------------------------------------------------------------------------------------
-- Call the Actual Costing unpost stored procedures 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostActualCostIn
		@strTransactionId
		,@intTransactionId
		,@ysnRecap

	EXEC dbo.uspICUnpostActualCostOut
		@strTransactionId
		,@intTransactionId
		,@ysnRecap
END

-----------------------------------------------------------------------------------------------------------------------------
-- Unpost the auto-negative gl entries
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostAutoNegative
		@strTransactionId
		,@intTransactionId
		,@ysnRecap
END

-----------------------------------------------------------------------------------------------------------------------------
-- Unpost the Category costing. 
-----------------------------------------------------------------------------------------------------------------------------
BEGIN 
	EXEC dbo.uspICUnpostCategory
		@strTransactionId
		,@intTransactionId
		,@ysnRecap
END


IF EXISTS (SELECT TOP 1 1 FROM #tmpInventoryTransactionStockToReverse) 
BEGIN 
	-------------------------------------------------
	-- Create reversal of the inventory transactions
	-------------------------------------------------
	INSERT INTO dbo.tblICInventoryTransaction (
			[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[dtmDate]
			,[dblQty]
			,[dblUOMQty]
			,[dblCost]
			,[dblValue]
			,[dblUnitRetail]
			,[dblSalesPrice]
			,[intCurrencyId]
			,[dblExchangeRate]
			,[intTransactionId]
			,[intTransactionDetailId]			
			,[strTransactionId]
			,[strBatchId]
			,[intTransactionTypeId]
			,[intLotId]
			,[ysnIsUnposted]
			,[intRelatedInventoryTransactionId]
			,[intRelatedTransactionId]
			,[strRelatedTransactionId]
			,[strTransactionForm]
			,[dtmCreated]
			,[intCreatedEntityId]
			,[intConcurrencyId]
			,[intCostingMethod]
			,[strDescription]
			,[intFobPointId]
			,[intInTransitSourceLocationId]
			,[intForexRateTypeId]
			,[dblForexRate]
			,[intCompanyId]
			,[dblCategoryCostValue]
			,[dblCategoryRetailValue]
			,[intCategoryId]
			,[strActualCostId]
			,[intSourceEntityId]
			,[intCompanyLocationId]
	)			
	SELECT	
			[intItemId]								= ActualTransaction.intItemId
			,[intItemLocationId]					= ActualTransaction.intItemLocationId
			,[intItemUOMId]							= ActualTransaction.intItemUOMId
			,[intSubLocationId]						= ActualTransaction.intSubLocationId
			,[intStorageLocationId]					= ActualTransaction.intStorageLocationId
			,[dtmDate]								= @dtmDate --dbo.fnRemoveTimeOnDate(ActualTransaction.dtmDate)
			,[dblQty]								= -ActualTransaction.dblQty
			,[dblUOMQty]							= ActualTransaction.dblUOMQty
			,[dblCost]								= ActualTransaction.dblCost
			,[dblValue]								= -ActualTransaction.dblValue
			,[dblUnitRetail]						= ActualTransaction.dblUnitRetail 
			,[dblSalesPrice]						= ActualTransaction.dblSalesPrice
			,[intCurrencyId]						= ActualTransaction.intCurrencyId
			,[dblExchangeRate]						= ActualTransaction.dblExchangeRate
			,[intTransactionId]						= ActualTransaction.intTransactionId
			,[intTransactionDetailId]				= ActualTransaction.intTransactionDetailId
			,[strTransactionId]						= ActualTransaction.strTransactionId
			,[strBatchId]							= @strBatchId
			,[intTransactionTypeId]					= ActualTransaction.intTransactionTypeId
			,[intLotId]								= ActualTransaction.intLotId
			,[ysnIsUnposted]						= 1
			,[intRelatedInventoryTransactionId]		= transactionsToReverse.intInventoryTransactionId
			,[intRelatedTransactionId]				= ActualTransaction.intRelatedTransactionId
			,[strRelatedTransactionId]				= ActualTransaction.strRelatedTransactionId
			,[strTransactionForm]					= ActualTransaction.strTransactionForm
			,[dtmCreated]							= GETDATE()
			,[intCreatedEntityId]					= @intEntityUserSecurityId
			,[intConcurrencyId]						= 1
			,[intCostingMethod]						= ActualTransaction.intCostingMethod
			,[strDescription]						= ActualTransaction.strDescription
			,[intFobPointId]						= ActualTransaction.intFobPointId
			,[intInTransitSourceLocationId]			= ActualTransaction.intInTransitSourceLocationId
			,[intForexRateTypeId]					= ActualTransaction.intForexRateTypeId
			,[dblForexRate]							= ActualTransaction.dblForexRate
			,[intCompanyId]							= ActualTransaction.intCompanyId
			,[dblCategoryCostValue]					= -ActualTransaction.dblCategoryCostValue
			,[dblCategoryRetailValue]				= -ActualTransaction.dblCategoryRetailValue
			,[intCategoryId]						= ActualTransaction.intCategoryId 
			,[strActualCostId]						= ActualTransaction.strActualCostId
			,[intSourceEntityId]					= ActualTransaction.intSourceEntityId
			,[intCompanyLocationId]					= ActualTransaction.intCompanyLocationId
	FROM	#tmpInventoryTransactionStockToReverse transactionsToReverse INNER JOIN dbo.tblICInventoryTransaction ActualTransaction
				ON transactionsToReverse.intInventoryTransactionId = ActualTransaction.intInventoryTransactionId				
	
	----------------------------------------------------
	-- Create reversal of the inventory LOT transactions
	----------------------------------------------------
	DECLARE @ActiveLotStatus AS INT = 1
	INSERT INTO dbo.tblICInventoryLotTransaction (		
		[intItemId]
		,[intLotId]
		,[intLocationId]
		,[intItemLocationId]
		,[intSubLocationId]
		,[intStorageLocationId]
		,[dtmDate]
		,[dblQty]
		,[intItemUOMId]
		,[dblCost]
		,[intTransactionId]
		,[strTransactionId]
		,[intTransactionTypeId]
		,[strBatchId]
		,[intLotStatusId] 
		,[strTransactionForm]
		,[ysnIsUnposted]
		,[dtmCreated] 
		,[intCreatedEntityId] 
		,[intConcurrencyId] 
		,[intCompanyId]
		,[intSourceEntityId]
	)
	SELECT	[intItemId]					= ActualTransaction.intItemId
			,[intLotId]					= ActualTransaction.intLotId
			,[intLocationId]			= ItemLocation.intLocationId
			,[intItemLocationId]		= ActualTransaction.intItemLocationId
			,[intSubLocationId]			= ActualTransaction.intSubLocationId
			,[intStorageLocationId]		= ActualTransaction.intStorageLocationId
			,[dtmDate]					= @dtmDate --dbo.fnRemoveTimeOnDate(ActualTransaction.dtmDate)
			,[dblQty]					= -ActualTransaction.dblQty
			,[intItemUOMId]				= ActualTransaction.intItemUOMId
			,[dblCost]					= ActualTransaction.dblCost
			,[intTransactionId]			= ActualTransaction.intTransactionId
			,[strTransactionId]			= ActualTransaction.strTransactionId
			,[intTransactionTypeId]		= ActualTransaction.intTransactionTypeId
			,[strBatchId]				= @strBatchId
			,[intLotStatusId]			= @ActiveLotStatus 
			,[strTransactionForm]		= ActualTransaction.strTransactionForm
			,[ysnIsUnposted]			= 1
			,[dtmCreated]				= GETDATE()
			,[intCreatedEntityId]		= @intEntityUserSecurityId
			,[intConcurrencyId]			= 1
			,[intCompanyId]				= ActualTransaction.intCompanyId
			,[intSourceEntityId]		= ActualTransaction.intSourceEntityId
	FROM	#tmpInventoryTransactionStockToReverse transactionsToReverse INNER JOIN dbo.tblICInventoryTransaction ActualTransaction
				ON transactionsToReverse.intInventoryTransactionId = ActualTransaction.intInventoryTransactionId
				AND ActualTransaction.intLotId IS NOT NULL 
				AND ActualTransaction.intItemUOMId IS NOT NULL
			INNER JOIN tblICItemLocation ItemLocation
				ON ActualTransaction.intItemLocationId = ItemLocation.intItemLocationId
				AND ItemLocation.intLocationId IS NOT NULL 

	--------------------------------------------------------------
	-- Update the ysnIsUnposted flag for related transactions 
	--------------------------------------------------------------
	UPDATE	RelatedTransactions
	SET		ysnIsUnposted = 1			
	FROM	dbo.tblICInventoryTransaction RelatedTransactions 
	WHERE	RelatedTransactions.intRelatedTransactionId = @intTransactionId
			AND RelatedTransactions.strRelatedTransactionId = @strTransactionId
			AND RelatedTransactions.ysnIsUnposted = 0

	--------------------------------------------------------------
	-- Update the ysnIsUnposted flag for related LOT transactions 
	--------------------------------------------------------------
	UPDATE	RelatedLotTransactions
	SET		ysnIsUnposted = 1
	FROM	dbo.tblICInventoryLotTransaction RelatedLotTransactions 
	WHERE	RelatedLotTransactions.intTransactionId = @intTransactionId
			AND RelatedLotTransactions.strTransactionId = @strTransactionId
			AND RelatedLotTransactions.ysnIsUnposted = 0

	------------------------------------------------------------
	-- Update the Stock Quantity and Average Cost
	------------------------------------------------------------
	BEGIN 
		BEGIN 
			DECLARE loopItemsToUnpost CURSOR LOCAL FAST_FORWARD
			FOR 
			SELECT  intItemId 
					,intItemUOMId 
					,intItemLocationId 
					,intSubLocationId 
					,intStorageLocationId 
					,dblQty 
					,dblUOMQty 
					,dblCost
					,intLotId 
					,intCostingMethod
					,intFobPointId
					,intInTransitSourceLocationId
					,intTransactionTypeId
			FROM	@ItemsToUnpost 

			OPEN loopItemsToUnpost;	

			-- Initial fetch attempt
			FETCH NEXT FROM loopItemsToUnpost INTO 
				@intItemId
				,@intItemUOMId
				,@intItemLocationId 
				,@intSubLocationId 
				,@intStorageLocationId 
				,@dblQty 
				,@dblUOMQty 
				,@dblCost
				,@intLotId
				,@intCostingMethod
				,@intFobPointId
				,@intInTransitSourceLocationId
				,@intTransactionTypeId
				;

			-----------------------------------------------------------------------------------------------------------------------------
			-- Start of the loop
			-----------------------------------------------------------------------------------------------------------------------------
			WHILE @@FETCH_STATUS = 0
			BEGIN 
				-- Update the lot Qty for each inventory transaction being unposted. 
				UPDATE	Lot 
				SET		Lot.dblQty =	
							CASE 
								WHEN @intInTransitSourceLocationId IS NULL THEN 
									dbo.fnCalculateLotQty(
											Lot.intItemUOMId
											, @intItemUOMId
											, Lot.dblQty
											, Lot.dblWeight
											, @dblQty 
											, Lot.dblWeightPerQty
									)
								ELSE 
									Lot.dblQty
							END 
						,Lot.dblWeight = 
							CASE 
								WHEN @intInTransitSourceLocationId IS NULL THEN 
									dbo.fnCalculateLotWeight(
										Lot.intItemUOMId
										, Lot.intWeightUOMId
										, @intItemUOMId 
										, Lot.dblWeight
										, @dblQty 
										, Lot.dblWeightPerQty
									)
								ELSE 
									Lot.dblWeight
							END 
						,Lot.dblQtyInTransit =	
							CASE 
								WHEN @intInTransitSourceLocationId IS NOT NULL THEN 
									dbo.fnCalculateLotQty(
										Lot.intItemUOMId
										, @intItemUOMId
										, Lot.dblQtyInTransit
										, Lot.dblWeightInTransit 
										, @dblQty 
										, Lot.dblWeightPerQty
									)
								ELSE
									Lot.dblQtyInTransit 
							END
						,Lot.dblWeightInTransit = 
							CASE 
								WHEN @intInTransitSourceLocationId IS NOT NULL THEN 
									dbo.fnCalculateLotWeight(
										Lot.intItemUOMId
										, Lot.intWeightUOMId
										, @intItemUOMId 
										, Lot.dblWeightInTransit
										, @dblQty 
										, Lot.dblWeightPerQty
									)
								ELSE
									Lot.dblWeightInTransit
							END 
						--,Lot.dblLastCost = CASE WHEN @dblQty > 0 THEN dbo.fnCalculateUnitCost(@dblCost, @dblUOMQty) ELSE Lot.dblLastCost END 
				FROM	dbo.tblICLot Lot
				WHERE	Lot.intItemLocationId = ISNULL(@intInTransitSourceLocationId, @intItemLocationId) 
						AND Lot.intLotId = @intLotId
						--AND intInTransitSourceLocationId IS NULL 
						--AND ISNULL(@intFobPointId, @FOB_ORIGIN) <> @FOB_DESTINATION

				-- Recalculate the average cost from the inventory transaction table. 
				-- Except on Actual Costing. Do not compute the average cost when doing actual costing.
				UPDATE	ItemPricing
				SET		dblAverageCost = ISNULL(
							dbo.fnRecalculateAverageCost(intItemId, intItemLocationId)
							, dblAverageCost
						) 
						, ysnIsPendingUpdate = 1
				FROM	dbo.tblICItemPricing ItemPricing	
				WHERE	ItemPricing.intItemId = @intItemId
						AND ItemPricing.intItemLocationId = @intItemLocationId
						AND ISNULL(@intCostingMethod, dbo.fnGetCostingMethod(intItemId, intItemLocationId)) <> @ACTUALCOST
						AND ISNULL(@intFobPointId, @FOB_ORIGIN) <> @FOB_DESTINATION

				-- Recalculate the item pricing because of the new average cost. 
				EXEC uspICUpdateItemPricing
					@intItemId
					,@intItemLocationId

				-- Update the stock quantities on tblICItemStock and tblICItemStockUOM tables. 
				IF ISNULL(@intFobPointId, @FOB_ORIGIN) <> @FOB_DESTINATION
				BEGIN 
					EXEC [dbo].[uspICPostStockQuantity]
						@intItemId
						,@intItemLocationId
						,@intSubLocationId
						,@intStorageLocationId
						,@intItemUOMId
						,@dblQty
						,@dblUOMQty
						,@intLotId
						,@intTransactionTypeId
						,NULL
						,0
				END 

				FETCH NEXT FROM loopItemsToUnpost INTO 
					@intItemId
					,@intItemUOMId
					,@intItemLocationId 
					,@intSubLocationId 
					,@intStorageLocationId 
					,@dblQty 
					,@dblUOMQty 
					,@dblCost
					,@intLotId
					,@intCostingMethod
					,@intFobPointId	
					,@intInTransitSourceLocationId				
					,@intTransactionTypeId
					;
			END;

			-----------------------------------------------------------------------------------------------------------------------------
			-- End of the loop
			-----------------------------------------------------------------------------------------------------------------------------
			CLOSE loopItemsToUnpost;
			DEALLOCATE loopItemsToUnpost;
		END
	END
	
	---------------------------------------------------------------------------------------
	-- Create the AUTO-Negative if costing method is average costing
	---------------------------------------------------------------------------------------
	BEGIN 
		DECLARE @ItemsForAutoNegative AS UnpostItemsTableType

		-- Get the qualified items for auto-negative. 
		INSERT INTO @ItemsForAutoNegative (
				intItemId
				,intItemLocationId
				,intItemUOMId
				,intLotId
				,dblQty
				,intSubLocationId
				,intStorageLocationId
				,intInventoryTransactionId
		)
		SELECT 
				intItemId
				,intItemLocationId
				,intItemUOMId
				,intLotId
				,dblQty
				,intSubLocationId
				,intStorageLocationId
				,intInventoryTransactionId
		FROM	@ItemsToUnpost
		WHERE	ISNULL(intCostingMethod, dbo.fnGetCostingMethod(intItemId, intItemLocationId)) = @AVERAGECOST
				AND dblQty > 0 
				AND ISNULL(intFobPointId, @FOB_ORIGIN) <> @FOB_DESTINATION
				
		SET @intTransactionId_AutoNegative = NULL 
		SET @strTransactionId_AutoNegative = NULL 

		SELECT	TOP 1 
				@intCurrencyId				= intCurrencyId
				,@dtmDate					= dbo.fnRemoveTimeOnDate(dtmDate)
				,@dblExchangeRate			= dblExchangeRate
				,@intTransactionId_AutoNegative	= intTransactionId
				,@strTransactionId_AutoNegative	= strTransactionId
				,@strTransactionForm		= strTransactionForm
		FROM	dbo.tblICInventoryTransaction
		WHERE	strBatchId = @strBatchId
				AND strTransactionId = @strTransactionId
				AND ISNULL(ysnIsUnposted, 0) = 1 

		WHILE EXISTS (SELECT TOP 1 1 FROM @ItemsForAutoNegative)
		BEGIN 
			SELECT TOP 1 
					@intItemId				= intItemId 
					,@intItemLocationId		= intItemLocationId
					,@intItemUOMId			= intItemUOMId
					,@intSubLocationId		= intSubLocationId
					,@intStorageLocationId	= intStorageLocationId
					,@intLotId				= intLotId
			FROM	@ItemsForAutoNegative

			INSERT INTO dbo.tblICInventoryTransaction (
						[intItemId]
						,[intItemLocationId]
						,[intItemUOMId]
						,[intSubLocationId]
						,[intStorageLocationId]
						,[dtmDate]
						,[dblQty]
						,[dblUOMQty]
						,[dblCost]
						,[dblValue]
						,[dblSalesPrice]
						,[intCurrencyId]
						,[dblExchangeRate]
						,[intTransactionId]
						,[strTransactionId]
						,[strBatchId]
						,[intTransactionTypeId]
						,[intLotId]
						,[ysnIsUnposted]
						,[intRelatedInventoryTransactionId]
						,[intRelatedTransactionId]
						,[strRelatedTransactionId]
						,[strTransactionForm]
						,[dtmCreated]
						,[intCreatedEntityId]
						,[intConcurrencyId]
						,[strDescription]
						,[intCompanyLocationId]
				)			
			SELECT	
					[intItemId]								= @intItemId
					,[intItemLocationId]					= @intItemLocationId
					,[intItemUOMId]							= NULL 
					,[intSubLocationId]						= NULL 
					,[intStorageLocationId]					= NULL 
					,[dtmDate]								= @dtmDate
					,[dblQty]								= 0
					,[dblUOMQty]							= 0
					,[dblCost]								= 0
					,[dblValue]								=	dbo.fnMultiply(Stock.dblUnitOnHand, ItemPricing.dblAverageCost) 
																- dbo.fnGetItemTotalValueFromTransactions(@intItemId, @intItemLocationId) 
					,[dblSalesPrice]						= 0
					,[intCurrencyId]						= NULL -- @intCurrencyId
					,[dblExchangeRate]						= 1 -- @dblExchangeRate
					,[intTransactionId]						= @intTransactionId_AutoNegative
					,[strTransactionId]						= @strTransactionId_AutoNegative
					,[strBatchId]							= @strBatchId
					,[intTransactionTypeId]					= @AUTO_NEGATIVE
					,[intLotId]								= NULL 
					,[ysnIsUnposted]						= 0
					,[intRelatedInventoryTransactionId]		= NULL 
					,[intRelatedTransactionId]				= NULL 
					,[strRelatedTransactionId]				= NULL 
					,[strTransactionForm]					= @strTransactionForm
					,[dtmCreated]							= GETDATE()
					,[intCreatedEntityId]					= @intEntityUserSecurityId
					,[intConcurrencyId]						= 1
					,[strDescription]						= -- Inventory variance is created. The current item valuation is %s. The new valuation is (Qty x New Average Cost) %s x %s = %s. 
															 dbo.fnFormatMessage(
																dbo.fnICGetErrorMessage(80078)
																, dbo.fnGetItemTotalValueFromTransactions(@intItemId, @intItemLocationId)
																, Stock.dblUnitOnHand
																, ItemPricing.dblAverageCost
																, (Stock.dblUnitOnHand * ItemPricing.dblAverageCost)
																, DEFAULT
																, DEFAULT
																, DEFAULT
																, DEFAULT
																, DEFAULT
																, DEFAULT
															)
					,[intCompanyLocationId]					= [location].intCompanyLocationId
			FROM	dbo.tblICItemPricing AS ItemPricing INNER JOIN dbo.tblICItemStock AS Stock 
						ON ItemPricing.intItemId = Stock.intItemId
						AND ItemPricing.intItemLocationId = Stock.intItemLocationId
					CROSS APPLY [dbo].[fnICGetCompanyLocation](@intItemLocationId, @intInTransitSourceLocationId) [location]

			WHERE	ItemPricing.intItemId = @intItemId
					AND ItemPricing.intItemLocationId = @intItemLocationId			
					AND dbo.fnMultiply(Stock.dblUnitOnHand, ItemPricing.dblAverageCost) - dbo.fnGetItemTotalValueFromTransactions(@intItemId, @intItemLocationId) <> 0

			-- Delete the item and item-location from the table variable. 
			DELETE FROM	@ItemsForAutoNegative
			WHERE	intItemId = @intItemId 
					AND intItemLocationId = @intItemLocationId
		END 
	END
END

-----------------------------------------
-- Generate the g/l entries
-----------------------------------------
BEGIN 
	EXEC dbo.uspICCreateReversalGLEntries 
		@strBatchId
		,@intTransactionId
		,@strTransactionId
		,@intEntityUserSecurityId
	;
END 

-------------------------------------------
-- Add records to the stock movement table
-------------------------------------------
BEGIN 
	INSERT INTO dbo.tblICInventoryStockMovement (		
		intItemId
		,intItemLocationId
		,intItemUOMId
		,intSubLocationId
		,intStorageLocationId
		,intLotId
		,dtmDate
		,dblQty
		,dblUOMQty
		,dblCost
		,dblValue
		,dblSalesPrice
		,intCurrencyId
		,dblExchangeRate
		,intTransactionId
		,intTransactionDetailId
		,strTransactionId
		,strBatchId
		,intTransactionTypeId
		,ysnIsUnposted
		,strTransactionForm
		,intRelatedInventoryTransactionId
		,intRelatedTransactionId
		,strRelatedTransactionId
		,intCostingMethod
		,dtmCreated
		,intCreatedUserId
		,intCreatedEntityId
		,intConcurrencyId
		,intForexRateTypeId
		,dblForexRate
		,intInventoryTransactionId
		,intInventoryTransactionStorageId
		,intOwnershipType
		,intCommodityId
		,intCategoryId
		,intLocationId
		,intSourceEntityId
	)
	SELECT 
		t.intItemId
		,t.intItemLocationId
		,t.intItemUOMId
		,t.intSubLocationId
		,t.intStorageLocationId
		,t.intLotId
		,dbo.fnRemoveTimeOnDate(t.dtmDate)
		,-t.dblQty
		,t.dblUOMQty
		,t.dblCost
		,t.dblValue
		,t.dblSalesPrice
		,t.intCurrencyId
		,t.dblExchangeRate
		,t.intTransactionId
		,t.intTransactionDetailId
		,t.strTransactionId
		,@strBatchId
		,t.intTransactionTypeId
		,t.ysnIsUnposted
		,t.strTransactionForm
		,t.intRelatedInventoryTransactionId
		,t.intRelatedTransactionId
		,t.strRelatedTransactionId
		,t.intCostingMethod
		,GETDATE()
		,@intEntityUserSecurityId
		,@intEntityUserSecurityId
		,t.intConcurrencyId
		,t.intForexRateTypeId
		,t.dblForexRate
		,t.intInventoryTransactionId
		,t.intInventoryTransactionStorageId
		,t.intOwnershipType
		,t.intCommodityId
		,t.intCategoryId
		,t.intLocationId
		,t.intSourceEntityId
	FROM	#tmpInventoryTransactionStockToReverse tmp INNER JOIN dbo.tblICInventoryStockMovement t
				ON tmp.intInventoryTransactionId = t.intInventoryTransactionId 
		
	--------------------------------------------------------------
	-- Update the ysnIsUnposted flag for the related transactions 
	--------------------------------------------------------------
	UPDATE	t
	SET		ysnIsUnposted = 1
	FROM	dbo.tblICInventoryStockMovement t 
	WHERE	t.intRelatedTransactionId = @intTransactionId
			AND t.strRelatedTransactionId = @strTransactionId
			AND t.ysnIsUnposted = 0

	--------------------------------------------------------------
	-- Update the ysnIsUnposted flag for the transaction
	--------------------------------------------------------------
	UPDATE	t
	SET		ysnIsUnposted = 1
	FROM	dbo.tblICInventoryStockMovement t 
	WHERE	t.intTransactionId = @intTransactionId
			AND t.strTransactionId = @strTransactionId
			AND t.ysnIsUnposted = 0
END 

-----------------------------------------
-- Call the Risk Log sp
-----------------------------------------
IF @ysnRecap = 0 
BEGIN 
	EXEC dbo.uspICLogRiskPositionFromOnHand
		@strBatchId
		,@strTransactionId
		,@intEntityUserSecurityId
END 

-----------------------------------------
-- Call the Risk Log sp
-----------------------------------------
IF @ysnRecap = 0 
BEGIN 
	EXEC dbo.uspICLogRiskPositionFromInTransit
		@strBatchId
		,@strTransactionId
		,@intEntityUserSecurityId
END 
