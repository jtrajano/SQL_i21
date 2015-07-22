
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

DECLARE loopProduce CURSOR LOCAL FAST_FORWARD
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
WHERE	TransType.strName = 'Produce'
		AND ISNULL(InvTransaction.ysnIsUnposted, 0) = 0 
ORDER BY InvTransaction.intInventoryTransactionId ASC
		
OPEN loopProduce;

-- Initial fetch attempt
FETCH NEXT FROM loopProduce INTO 
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
	DECLARE @rawMaterialValue AS NUMERIC(18,6)
			,@dblComputedCost AS NUMERIC(18,6)

	SELECT	@rawMaterialValue = SUM(dblQty * dblCost)
	FROM	dbo.tblICInventoryTransaction
	WHERE	strBatchId = @strBatchId
			AND intTransactionId = @intTransactionId 
			AND dblQty < 0
			AND ysnIsUnposted = 0

	SET @dblComputedCost = ABS(@rawMaterialValue / @dblQty) 

	IF @dblComputedCost <> @dblCost
	BEGIN 
		DECLARE @strLotNumber AS NVARCHAR(50)
		SELECT @strLotNumber = strLotNumber FROM dbo.tblICLot WHERE intLotId = @intLotId

		PRINT 'Fixing Produce in Lot ' + @strLotNumber
		
		-- Update the cost
		BEGIN 
			UPDATE	dbo.tblICInventoryTransaction
			SET		dblCost = @dblComputedCost
			WHERE	intLotId = @intLotId
					AND intTransactionId = @intTransactionId
					AND strBatchId = @strBatchId

			UPDATE	dbo.tblICInventoryLotTransaction
			SET		dblCost = @dblComputedCost
			WHERE	intLotId = @intLotId
					AND intTransactionId = @intTransactionId
					AND strBatchId = @strBatchId

			UPDATE	dbo.tblICLot
			SET		dblLastCost = dbo.fnCalculateUnitCost(@dblComputedCost, @dblUOMQty) 
			WHERE	intLotId = @intLotId 
		END 

		-- Update the cost bucket
		BEGIN 
			UPDATE	dbo.tblICInventoryLot
			SET		dblCost = @dblComputedCost
			WHERE	intTransactionId = @intTransactionId 
					AND intLotId = @intLotId
					AND strTransactionId = @strTransactionId 
		END 

		-- Update the G/L Entries
		BEGIN 
			UPDATE	dbo.tblGLDetail 
			SET		dblDebit = CASE WHEN ISNULL(dblDebit, 0) <> 0 THEN ABS(@dblComputedCost * @dblQty) ELSE 0 END 
					,dblCredit = CASE WHEN ISNULL(dblCredit, 0) <> 0 THEN ABS(@dblComputedCost * @dblQty) ELSE 0 END 
			WHERE	intJournalLineNo = @intInventoryTransactionId
					AND intTransactionId = @intTransactionId
					AND strBatchId = @strBatchId
		END 
	END 
	ELSE
	BEGIN 
		PRINT 'Update the last cost.'

		-- Update the last cost of the produce 			
		UPDATE dbo.tblICLot
		SET dblLastCost = dbo.fnCalculateUnitCost(@dblCost, @dblUOMQty) 
		WHERE intLotId = @intLotId
	END

	FETCH NEXT FROM loopProduce INTO 
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

CLOSE loopProduce;
DEALLOCATE loopProduce;
