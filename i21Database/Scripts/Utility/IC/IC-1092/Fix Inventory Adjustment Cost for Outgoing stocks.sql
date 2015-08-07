
-- Modify the uspICPostInventoryTransaction for use in this fix. 
-- Return it back to the original code after the fix. 
ALTER PROCEDURE [dbo].[uspICPostInventoryTransaction]
	@intItemId INT
	,@intItemLocationId INT
	,@intItemUOMId INT 
	,@intSubLocationId INT
	,@intStorageLocationId INT
	,@dtmDate DATETIME
	,@dblQty NUMERIC(18, 6)
	,@dblUOMQty NUMERIC(18, 6)
	,@dblCost NUMERIC(18, 6)
	,@dblValue NUMERIC(18, 6)
	,@dblSalesPrice NUMERIC(18, 6)	
	,@intCurrencyId INT
	,@dblExchangeRate NUMERIC (38, 20)
	,@intTransactionId INT
	,@intTransactionDetailId INT 
	,@strTransactionId NVARCHAR(40)
	,@strBatchId NVARCHAR(20)
	,@intTransactionTypeId INT
	,@intLotId INT
	,@intRelatedInventoryTransactionId INT
	,@intRelatedTransactionId INT
	,@strRelatedTransactionId NVARCHAR(40)
	,@strTransactionForm NVARCHAR (255)
	,@intUserId INT
	,@InventoryTransactionIdentityId INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

UPDATE	dbo.tblICInventoryTransaction
SET		dblCost = @dblCost
WHERE	intLotId = @intLotId
		AND strBatchId = @strBatchId

UPDATE	dbo.tblICInventoryLotTransaction
SET		dblCost = @dblCost
WHERE	intLotId = @intLotId
		AND strBatchId = @strBatchId

GO 

DECLARE @intInventoryTransactionId AS INT
		,@intItemId AS INT
		,@intItemLocationId AS INT
		,@intItemUOMId AS INT
		,@intSubLocationId AS INT
		,@intStorageLocationId AS INT 
		,@dblQty AS NUMERIC(18,6)
		,@dblCost AS NUMERIC(18,6)
		,@dblUOMQty AS NUMERIC(18,6)
		,@strBatchId AS NVARCHAR(50)
		,@intLotId AS INT
		,@intTransactionId AS INT 
		,@strTransactionId AS NVARCHAR(50)
		,@intTransactionDetailId AS INT 
		,@intTransactionTypeId AS INT 
		,@dtmDate AS DATETIME 
		,@intCurrencyId AS INT
		,@dblExchangeRate AS NUMERIC(38,20)
		,@intUserId AS INT

DECLARE loopAdjustment CURSOR LOCAL FAST_FORWARD
FOR 
SELECT	InvTransaction.intInventoryTransactionId
		,InvTransaction.intItemId
		,InvTransaction.intItemLocationId
		,InvTransaction.intItemUOMId
		,InvTransaction.intSubLocationId
		,InvTransaction.intStorageLocationId
		,InvTransaction.dblQty
		,InvTransaction.dblUOMQty
		,InvTransaction.dblCost
		,InvTransaction.strBatchId
		,InvTransaction.intLotId
		,InvTransaction.intTransactionId
		,InvTransaction.strTransactionId
		,InvTransaction.intTransactionDetailId
		,InvTransaction.intTransactionTypeId
		,InvTransaction.dtmDate
		,InvTransaction.intCurrencyId
		,InvTransaction.dblExchangeRate
		,InvTransaction.intCreatedUserId
FROM	dbo.tblICInventoryTransaction InvTransaction INNER JOIN tblICLot Lot
			ON InvTransaction.intLotId = Lot.intLotId
		INNER JOIN dbo.tblICInventoryTransactionType TransType
			ON TransType.intTransactionTypeId = InvTransaction.intTransactionTypeId
WHERE	TransType.strName = 'Inventory Adjustment'
		AND ISNULL(InvTransaction.ysnIsUnposted, 0) = 0 
ORDER BY InvTransaction.intInventoryTransactionId ASC
		
OPEN loopAdjustment;

-- Initial fetch attempt
FETCH NEXT FROM loopAdjustment INTO 
		@intInventoryTransactionId	
		,@intItemId
		,@intItemLocationId
		,@intItemUOMId
		,@intSubLocationId
		,@intStorageLocationId
		,@dblQty
		,@dblUOMQty
		,@dblCost
		,@strBatchId
		,@intLotId
		,@intTransactionId
		,@strTransactionId
		,@intTransactionDetailId
		,@intTransactionTypeId 
		,@dtmDate
		,@intCurrencyId
		,@dblExchangeRate
		,@intUserId
		;

WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE @dblCorrectLastCost AS NUMERIC(18,6) = NULL 
	DECLARE @errorFound AS BIT 
			,@dblLastCost AS NUMERIC(18,6)

	-- Check if cost is not one of the 'last costs' used to add stock to the lot number. 
	SET @errorFound = NULL
	SET @dblLastCost = NULL 

	SELECT	@errorFound = 1
	WHERE	dbo.fnCalculateUnitCost(@dblCost, @dblUOMQty) NOT IN (
		SELECT	CAST(dbo.fnCalculateUnitCost(dblCost, dblUOMQty) AS NUMERIC(18,6))
		FROM	dbo.tblICInventoryTransaction
		WHERE	intItemId = @intItemId
				AND intItemLocationId = @intItemLocationId
				AND intLotId = @intLotId 
				AND dblQty > 0 
				AND intInventoryTransactionId < @intInventoryTransactionId
	)

	IF @errorFound = 1
	BEGIN 
		DECLARE @strLotNumber AS NVARCHAR(50)
		SELECT @strLotNumber = strLotNumber FROM dbo.tblICLot WHERE intLotId = @intLotId

		PRINT 'Fixing Inventory Adjustment in Lot ' + @strLotNumber

		-- Remove the wrong cost bucket
		BEGIN 
			DECLARE @intInventoryLotIdToCorrect AS INT = NULL 

			SELECT	@intInventoryLotIdToCorrect = intInventoryLotId
			FROM	dbo.tblICInventoryLot 
			WHERE	intLotId = @intLotId 
					AND strTransactionId = @strTransactionId
					AND ysnIsUnposted = 0

			IF @intInventoryLotIdToCorrect IS NOT NULL
			BEGIN 
				UPDATE	dbo.tblICInventoryLot 
				SET		ysnIsUnposted = 1
						,dblStockIn = dblStockOut
				WHERE	intInventoryLotId = @intInventoryLotIdToCorrect
			END 
		END 

		-- Fix the last cost of the Lot
		BEGIN 
			-- Get the last cost
			SELECT	TOP 1 
					@dblLastCost = dbo.fnCalculateUnitCost(dblCost, dblUOMQty) 
			FROM	dbo.tblICInventoryTransaction
			WHERE	intItemId = @intItemId
					AND intItemLocationId = @intItemLocationId
					AND intLotId = @intLotId 
					AND dblQty > 0 
					AND intInventoryTransactionId < @intInventoryTransactionId

			-- Update the last cost for the Lot. 
			UPDATE dbo.tblICLot
			SET dblLastCost = @dblLastCost
			WHERE intLotId = @intLotId
		END 

		-- Re-post the lot 
		-- Inventory Adjustment from the correct cost bucket
		-- Rebuild the Lot-Out table. 
		BEGIN 
			EXEC [dbo].[uspICPostLot]
				@intItemId
				,@intItemLocationId
				,@intItemUOMId
				,@intSubLocationId
				,@intStorageLocationId
				,@dtmDate
				,@intLotId
				,@dblQty
				,@dblUOMQty
				,@dblCost = @dblLastCost
				,@dblSalesPrice = 0.00
				,@intCurrencyId = @intCurrencyId
				,@dblExchangeRate = @dblExchangeRate
				,@intTransactionId = @intTransactionId
				,@intTransactionDetailId = @intTransactionDetailId
				,@strTransactionId = @strTransactionId
				,@strBatchId = @strBatchId
				,@intTransactionTypeId = @intTransactionTypeId
				,@intUserId = @intUserId
		END 

		-- Fix the G/L Entries
		BEGIN
			-- Get the correct cost 
			DECLARE @dblCorrectCost AS NUMERIC(18,6) = NULL 

			SELECT	@dblCorrectCost = dblCost
			FROM	dbo.tblICInventoryTransaction
			WHERE	intLotId = @intLotId
					AND intItemLocationId = @intItemLocationId
					AND strBatchId = @strBatchId
					AND intTransactionId = @intTransactionId
					AND ysnIsUnposted = 0 

			UPDATE	dbo.tblGLDetail 
			SET		dblDebit = CASE WHEN ISNULL(dblDebit, 0) <> 0 THEN ABS(@dblCorrectCost * @dblQty) ELSE 0 END 
					,dblCredit = CASE WHEN ISNULL(dblCredit, 0) <> 0 THEN ABS(@dblCorrectCost * @dblQty) ELSE 0 END 
			WHERE	intJournalLineNo = @intInventoryTransactionId
					AND intTransactionId = @intTransactionId
					AND strBatchId = @strBatchId
		END 		
	END 

	FETCH NEXT FROM loopAdjustment INTO 
			@intInventoryTransactionId	
			,@intItemId
			,@intItemLocationId
			,@intItemUOMId
			,@intSubLocationId
			,@intStorageLocationId
			,@dblQty
			,@dblUOMQty
			,@dblCost
			,@strBatchId
			,@intLotId
			,@intTransactionId
			,@strTransactionId
			,@intTransactionDetailId
			,@intTransactionTypeId 
			,@dtmDate
			,@intCurrencyId
			,@dblExchangeRate
			,@intUserId
	;
END 

CLOSE loopAdjustment;
DEALLOCATE loopAdjustment;

GO 

ALTER PROCEDURE [dbo].[uspICPostInventoryTransaction]
	@intItemId INT
	,@intItemLocationId INT
	,@intItemUOMId INT 
	,@intSubLocationId INT
	,@intStorageLocationId INT
	,@dtmDate DATETIME
	,@dblQty NUMERIC(18, 6)
	,@dblUOMQty NUMERIC(18, 6)
	,@dblCost NUMERIC(18, 6)
	,@dblValue NUMERIC(18, 6)
	,@dblSalesPrice NUMERIC(18, 6)	
	,@intCurrencyId INT
	,@dblExchangeRate NUMERIC (38, 20)
	,@intTransactionId INT
	,@intTransactionDetailId INT 
	,@strTransactionId NVARCHAR(40)
	,@strBatchId NVARCHAR(20)
	,@intTransactionTypeId INT
	,@intLotId INT
	,@intRelatedInventoryTransactionId INT
	,@intRelatedTransactionId INT
	,@strRelatedTransactionId NVARCHAR(40)
	,@strTransactionForm NVARCHAR (255)
	,@intUserId INT
	,@InventoryTransactionIdentityId INT OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SET @InventoryTransactionIdentityId = NULL

-- Initialize the UOM Qty
SELECT	TOP 1
		@dblUOMQty = ItemUOM.dblUnitQty
FROM	tblICItemUOM ItemUOM
WHERE	intItemUOMId = @intItemUOMId

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
		,[intCreatedUserId] 
		,[intConcurrencyId] 
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
		,[intCurrencyId]					= @intCurrencyId
		,[dblExchangeRate]					= ISNULL(@dblExchangeRate, 1)
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
		,[dtmCreated]						= GETDATE()
		,[intCreatedUserId]					= @intUserId
		,[intConcurrencyId]					= 1
WHERE	@intItemId IS NOT NULL
		AND @intItemLocationId IS NOT NULL
		AND @intItemUOMId IS NOT NULL 

SET @InventoryTransactionIdentityId = SCOPE_IDENTITY();

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
		,@intUserId 
		,NULL  
END