/*

*/
CREATE PROCEDURE [dbo].[uspARBatchPostCosting]
	@ItemsToPost AS ItemCostingTableType READONLY
	,@strBatchId AS NVARCHAR(40)
	,@strAccountToCounterInventory AS NVARCHAR(255) = 'Cost of Goods'
	,@intEntityUserSecurityId AS INT
	,@strGLDescription AS NVARCHAR(255) = NULL 
	,@strPostMode AS NVARCHAR(50) = 'Detailed'
	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT OFF
SET ANSI_WARNINGS OFF

DECLARE @intReturnValue AS INT 

DECLARE @PostMode_Aggregrate AS NVARCHAR(50) = 'Aggregrate'
		,@PostMode_Detailed AS NVARCHAR(50) = 'Detailed'

IF @strBatchId IS NULL 
	RETURN; 

IF NOT EXISTS (SELECT TOP 1 1 FROM @ItemsToPost) 
	RETURN; 
	
IF @strPostMode = @PostMode_Aggregrate 
BEGIN 
	DECLARE @AggregrateItemsToPost AS ItemCostingTableType 

	--------------------------------------------------------------------------
	-- Log the batch details in the tblICBatchInventoryTransaction
	--------------------------------------------------------------------------
	INSERT INTO tblICBatchInventoryTransaction (
			[strBatchId] 
			,[strTransactionId] 
			,[intTransactionId] 
			,[intTransactionDetailId] 
			,[intItemId] 
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
			,[intLotId] 
			,[ysnIsUnposted] 
			,[intTransactionTypeId] 
			,[strTransactionForm] 
			,[intCostingMethod] 
			,[intInTransitSourceLocationId]
			,[strDescription] 
			,[intFobPointId] 
			,[intCurrencyId]
			,[intForexRateTypeId] 
			,[dblForexRate] 
			,[strActualCostId] 
			,[intCreatedEntityId] 
	)
	SELECT 
			@strBatchId 
			,[strTransactionId] 
			,[intTransactionId] 
			,[intTransactionDetailId] 
			,[intItemId] 
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
			,[intLotId] 
			,[ysnIsUnposted] = 0 
			,ty.[intTransactionTypeId] 
			,ty.strTransactionForm
			,[intCostingMethod] = NULL 
			,[intInTransitSourceLocationId]
			,[strDescription] = NULL 
			,[intFobPointId] = NULL 
			,[intCurrencyId]
			,[intForexRateTypeId] 
			,[dblForexRate] 
			,[strActualCostId] 
			,@intEntityUserSecurityId 
	FROM	@ItemsToPost itemsToPost LEFT JOIN tblICInventoryTransactionType ty 
				ON itemsToPost.intTransactionTypeId = ty.intTransactionTypeId

	INSERT INTO @AggregrateItemsToPost (
		[intItemId] 
		,[intItemLocationId] 
		,[intItemUOMId] 
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
		,[intTransactionTypeId] 
		,[intLotId] 
		,[intSubLocationId] 
		,[intStorageLocationId] 
		,[strActualCostId] 
		,[intSourceTransactionId] 
		,[strSourceTransactionId] 
		,[intInTransitSourceLocationId] 
		,[intForexRateTypeId] 
		,[dblForexRate] 
		,[intStorageScheduleTypeId] 
	)
	SELECT 		
		Query.[intItemId] 
		,[intItemLocationId] 
		,Query.[intItemUOMId] 
		,[dtmDate] 
		,[dblQty] 
		,[dblUOMQty] = iu.dblUnitQty
		,[dblCost] 
		,[dblValue] 
		,[dblSalesPrice] 
		,[intCurrencyId] 
		,[dblExchangeRate] 
		,[intTransactionId] 
		,[strTransactionId] 
		,[intTransactionTypeId] 
		,[intLotId] 
		,[intSubLocationId] 
		,[intStorageLocationId] 
		,[strActualCostId] 
		,[intSourceTransactionId] 
		,[strSourceTransactionId] 
		,[intInTransitSourceLocationId] 
		,[intForexRateTypeId] 
		,[dblForexRate] 
		,[intStorageScheduleTypeId]  
	FROM (
		SELECT 
				[intItemId]					= ItemsToPost_Aggregrate.intItemId
				,[intItemLocationId]		= ItemsToPost_Aggregrate.intItemLocationId
				,[intItemUOMId]				= ItemsToPost_Aggregrate.intItemUOMId
				,[dtmDate]					= ItemsToPost_Aggregrate.dtmDate
				,[dblQty]					= SUM(ISNULL(ItemsToPost_Aggregrate.dblQty, 0)) 
				--,[dblUOMQty]				= iu.dblUnitQty
				,[dblCost]					= ISNULL(ItemsToPost_Aggregrate.dblCost, 0) 
				,[dblValue]					= 0.00
				,[dblSalesPrice]			= ISNULL(ItemsToPost_Aggregrate.dblSalesPrice, 0)
				,[intCurrencyId]			= ItemsToPost_Aggregrate.intCurrencyId
				,[dblExchangeRate]			= ItemsToPost_Aggregrate.dblExchangeRate
				,[intTransactionId]			= ItemsToPost_Aggregrate.intTransactionId 
				,[strTransactionId]			= @strBatchId 
				,[intTransactionTypeId]		= ItemsToPost_Aggregrate.intTransactionTypeId
				,[intLotId]					= ItemsToPost_Aggregrate.intLotId
				,[intSubLocationId]			= ItemsToPost_Aggregrate.intSubLocationId
				,[intStorageLocationId]		= ItemsToPost_Aggregrate.intStorageLocationId
				,[strActualCostId]			= ItemsToPost_Aggregrate.strActualCostId
				,[intSourceTransactionId]	= ItemsToPost_Aggregrate.intSourceTransactionId 
				,[strSourceTransactionId]		= ItemsToPost_Aggregrate.strSourceTransactionId
				,[intInTransitSourceLocationId]	= ItemsToPost_Aggregrate.intInTransitSourceLocationId
				,[intForexRateTypeId]			= ItemsToPost_Aggregrate.intForexRateTypeId
				,[dblForexRate]					= ItemsToPost_Aggregrate.dblForexRate
				,[intStorageScheduleTypeId]		= ItemsToPost_Aggregrate.intStorageScheduleTypeId
			FROM @ItemsToPost ItemsToPost_Aggregrate 
			WHERE
				ISNULL(ItemsToPost_Aggregrate.ysnIsStorage, 0) = 0 
			GROUP BY 
				ItemsToPost_Aggregrate.[intItemId] 
				,ItemsToPost_Aggregrate.[intItemLocationId] 
				,ItemsToPost_Aggregrate.[intItemUOMId] 
				,ItemsToPost_Aggregrate.[dtmDate] 
				,ISNULL(ItemsToPost_Aggregrate.[dblCost], 0) 
				,ISNULL(ItemsToPost_Aggregrate.[dblSalesPrice], 0) 
				,[intCurrencyId] 
				,[dblExchangeRate] 
				,[intTransactionId] 
				,[intTransactionTypeId] 
				,[intLotId] 
				,[intSubLocationId] 
				,[intStorageLocationId] 
				,[strActualCostId] 
				,[intSourceTransactionId] 
				,[strSourceTransactionId] 
				,[intInTransitSourceLocationId] 
				,[intForexRateTypeId] 
				,[dblForexRate] 
				,[intStorageScheduleTypeId] 
		) Query	LEFT JOIN tblICItemUOM iu
			ON Query.intItemUOMId = iu.intItemUOMId

	-----------------------------
	-- Post the aggregrate. 
	-----------------------------
	EXEC @intReturnValue = dbo.uspICPostCosting
		@AggregrateItemsToPost
		,@strBatchId 
		,NULL 
		,@intEntityUserSecurityId 
		,@strGLDescription 
	
	IF @intReturnValue < 0 RETURN -1;

	-----------------------------------------
	-- Generate the g/l entries
	-----------------------------------------
	BEGIN 
		-- Validate it first. 
		EXEC @intReturnValue = dbo.uspICValidateCreateGLEntries
			@strBatchId
			,@strAccountToCounterInventory
		IF @intReturnValue < 0 RETURN -1;

		-- Return the GL entries. 
		EXEC @intReturnValue = dbo.uspICCreateGLEntries 
			@strBatchId
			,@strAccountToCounterInventory
			,@intEntityUserSecurityId
			,@strGLDescription

		IF @intReturnValue < 0 RETURN -1
	END 
END 

IF @strPostMode = @PostMode_Detailed 
BEGIN 
	DECLARE @TransactionName AS VARCHAR(500) = 'BatchPostInvoiceItems' 
	DECLARE @ItemsToPostAsLoop AS ItemCostingTableType 
			,@strTransactionId AS NVARCHAR(50) 
			,@intTransactionId AS INT
			,@dtmDate AS DATETIME 
			,@intPostCostingError AS INT
			,@intCreateGLEntriesError AS INT 
	
	-----------------------------------------
	-- Start the Loop
	-----------------------------------------
	DECLARE loopItemsToPost CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT  DISTINCT 
			strTransactionId, intTransactionId, dtmDate
	FROM	@ItemsToPost
	ORDER BY dtmDate ASC, intTransactionId ASC 

	OPEN loopItemsToPost;

	FETCH NEXT FROM loopItemsToPost 
	INTO	@strTransactionId
			, @intTransactionId
			, @dtmDate;

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		BEGIN TRAN @TransactionName
		SAVE TRAN @TransactionName

		DELETE FROM @ItemsToPostAsLoop
		INSERT INTO @ItemsToPostAsLoop (
			[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
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
			,[intTransactionTypeId]
			,[intLotId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[ysnIsStorage]
			,[strActualCostId]
			,[intSourceTransactionId]
			,[strSourceTransactionId]
			,[intInTransitSourceLocationId]
			,[intForexRateTypeId]
			,[dblForexRate]
			,[intStorageScheduleTypeId]		
		)
		SELECT 
			[intItemId]
			,[intItemLocationId]
			,[intItemUOMId]
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
			,[intTransactionTypeId]
			,[intLotId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[ysnIsStorage]
			,[strActualCostId]
			,[intSourceTransactionId]
			,[strSourceTransactionId]
			,[intInTransitSourceLocationId]
			,[intForexRateTypeId]
			,[dblForexRate]
			,[intStorageScheduleTypeId]		
		FROM	@ItemsToPost
		WHERE	strTransactionId = @strTransactionId
		ORDER BY intId 

		---------------------------
		-- Call the IC posting sp. 
		---------------------------
		SET @intPostCostingError = NULL 
		EXEC @intPostCostingError = dbo.uspICPostCosting  
				@ItemsToPostAsLoop  
				,@strBatchId  
				,NULL  
				,@intEntityUserSecurityId

		---------------------------
		-- Validate the GL Entries 
		---------------------------
		SET @intCreateGLEntriesError = NULL 
		EXEC @intCreateGLEntriesError = dbo.uspICValidateCreateGLEntries
			@strBatchId
			,@strAccountToCounterInventory
			,@strTransactionId
		
		-- Rollback failed transaction and continue posting the next transaction. 
		IF ISNULL(@intPostCostingError, 0) = 0 AND ISNULL(@intCreateGLEntriesError, 0) = 0 
			COMMIT TRAN @TransactionName
		ELSE 
			ROLLBACK TRAN @TransactionName

		FETCH NEXT FROM loopItemsToPost 
		INTO	@strTransactionId
				, @intTransactionId
				, @dtmDate;
	END

	CLOSE loopItemsToPost;
	DEALLOCATE loopItemsToPost;
		
	-----------------------------------------
	-- End of the Loop
	-----------------------------------------
	
	-----------------------------------------
	-- Generate the g/l entries in one sweep. 
	-----------------------------------------	
	EXEC @intReturnValue = dbo.uspICCreateGLEntries 
		@strBatchId
		,@strAccountToCounterInventory
		,@intEntityUserSecurityId
		,@strGLDescription

	IF @intReturnValue < 0 RETURN -1
END 