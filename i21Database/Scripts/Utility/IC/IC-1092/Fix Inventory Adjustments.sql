-- Fix transactions with the wrong Unit Qty. 
UPDATE	InventoryTransaction
SET		dblUOMQty = ItemUOM.dblUnitQty  
FROM	dbo.tblICInventoryTransaction InventoryTransaction INNER JOIN dbo.tblICItemUOM ItemUOM
			ON InventoryTransaction.intItemUOMId = ItemUOM.intItemUOMId
WHERE	InventoryTransaction.dblUOMQty <> ItemUOM.dblUnitQty

GO
--------------------------------------------------------------
-- Restore the unposted transactions
--------------------------------------------------------------
BEGIN TRY 
	BEGIN TRANSACTION

	DECLARE @intInventoryAdjustmentId AS INT
			,@strAdjustmentNo AS NVARCHAR(50)
			,@intEntityId AS INT 
			,@ysnPosted AS BIT
			,@dtmUnpostedDate AS DATETIME 
			,@intUserId AS INT

	DECLARE @strBatchId_UsedInUnpost AS NVARCHAR(50)
			,@strBatchId_WhenItWasPosted AS NVARCHAR(50)
			,@batchCount AS INT 

	-- Get all the unposted inventory adjustments 
	SELECT	intInventoryAdjustmentId
			,strAdjustmentNo
			,intEntityId
			,ysnPosted
			,dtmUnpostedDate
	INTO	#tmpRestoreUnpostedAdjustments
	FROM	dbo.tblICInventoryAdjustment
	WHERE	dbo.fnRemoveTimeOnDate(dtmUnpostedDate) = CAST('2015-07-23' AS DATETIME)
	
	DECLARE loopUnpostAdjustment CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT	* 
	FROM	#tmpRestoreUnpostedAdjustments
		
	OPEN loopUnpostAdjustment;

	-- Initial fetch attempt
	FETCH NEXT FROM loopUnpostAdjustment INTO 
			@intInventoryAdjustmentId	
			,@strAdjustmentNo
			,@intEntityId
			,@ysnPosted
			,@dtmUnpostedDate
	;

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Restoring ' + @strAdjustmentNo
				
		IF ISNULL(@ysnPosted, 0) = 0
		BEGIN
			-- Get the user security id
			SELECT	@intUserId = [intEntityId]
			FROM	tblSMUserSecurity
			WHERE	[intEntityId] = @intEntityId

			-- 2. Get the batch id of the unposted record. 
			BEGIN 
				SELECT	@strBatchId_UsedInUnpost = NULL
						,@strBatchId_WhenItWasPosted = NULL 
						
				SELECT	DISTINCT @batchCount = COUNT(strBatchId)
				FROM	dbo.tblICInventoryTransaction
				WHERE	intTransactionId = @intInventoryAdjustmentId
						AND strTransactionId = @strAdjustmentNo
						AND ISNULL(ysnIsUnposted, 0) = 1

				-- 2.1 Get the batch id used to unpost the ADJ
				SELECT	TOP 1 
						@strBatchId_UsedInUnpost = strBatchId
				FROM	dbo.tblICInventoryTransaction
				WHERE	intTransactionId = @intInventoryAdjustmentId
						AND strTransactionId = @strAdjustmentNo
						AND ISNULL(ysnIsUnposted, 0) = 1
				ORDER BY intInventoryTransactionId DESC

				-- 2.1 Get the batch id when it was posted. 
				SELECT	TOP 1
						@strBatchId_WhenItWasPosted = strBatchId
				FROM	dbo.tblICInventoryTransaction
				WHERE	intTransactionId = @intInventoryAdjustmentId
						AND strTransactionId = @strAdjustmentNo
						AND ISNULL(ysnIsUnposted, 0) = 1
						AND strBatchId <> @strBatchId_UsedInUnpost
				ORDER BY intInventoryTransactionId DESC

				IF @strBatchId_WhenItWasPosted IS NULL 
				BEGIN
					SET @strBatchId_WhenItWasPosted = @strBatchId_UsedInUnpost
					SET @strBatchId_UsedInUnpost = NULL 
				END
			END 
				
			-- 3. Set the inventory transaction back to unposted state
			UPDATE	dbo.tblICInventoryTransaction
			SET		ysnIsUnposted = 0 
			WHERE	intTransactionId = @intInventoryAdjustmentId
					AND strTransactionId = @strAdjustmentNo
					AND strBatchId = @strBatchId_WhenItWasPosted

			-- 4. Set the inventory lot transaction back to unposted state
			UPDATE	dbo.tblICInventoryLotTransaction
			SET		ysnIsUnposted = 0 
			WHERE	intTransactionId = @intInventoryAdjustmentId
					AND strTransactionId = @strAdjustmentNo
					AND strBatchId = @strBatchId_WhenItWasPosted

			-- 5. Set the Lot cost bucket back to unposted state
			UPDATE	dbo.tblICInventoryLot
			SET		ysnIsUnposted = 0
			WHERE	strTransactionId = @strAdjustmentNo
					AND intTransactionId = @intInventoryAdjustmentId

			-- 6. Mark the GL Detail as unposted
			UPDATE	dbo.tblGLDetail 
			SET		ysnIsUnposted = 0
			WHERE	intTransactionId = @intInventoryAdjustmentId
					AND strTransactionId = @strAdjustmentNo
					AND strBatchId = @strBatchId_WhenItWasPosted

			-- 7. Mark the Adjustment as posted again 
			UPDATE dbo.tblICInventoryAdjustment
			SET ysnPosted = 1
			WHERE intInventoryAdjustmentId = @intInventoryAdjustmentId
						
			-- 8. Delete the unpost records
			BEGIN 
				-- 6.1. Delete the Unpost Inventory Transaction 
				DELETE FROM dbo.tblICInventoryTransaction
				WHERE	intTransactionId = @intInventoryAdjustmentId
						AND strTransactionId = @strAdjustmentNo
						AND strBatchId = @strBatchId_UsedInUnpost

				-- 6.2. Delete the Unpost Inventory Lot Transaction 
				DELETE FROM dbo.tblICInventoryLotTransaction
				WHERE	intTransactionId = @intInventoryAdjustmentId
						AND strTransactionId = @strAdjustmentNo
						AND strBatchId = @strBatchId_UsedInUnpost
				
				-- 6.3. Delete the Unpost GL entries
				DELETE FROM dbo.tblGLDetail 
				WHERE	intTransactionId = @intInventoryAdjustmentId
						AND strTransactionId = @strAdjustmentNo
						AND strBatchId = @strBatchId_UsedInUnpost
			END

			-- X. Delete Inventory transactions that does not have any GL entries.
			--BEGIN 
			--	DELETE	InvTrans
			--	FROM	dbo.tblICInventoryTransaction InvTrans LEFT JOIN dbo.tblGLDetail GL
			--				ON GL.intJournalLineNo = InvTrans.intInventoryTransactionId 
			--				AND GL.intTransactionId = InvTrans.intTransactionId
			--				AND GL.strTransactionId = InvTrans.strTransactionId
			--	WHERE	InvTrans.intTransactionId = @intInventoryAdjustmentId
			--			AND InvTrans.strTransactionId = @strAdjustmentNo
			--			AND GL.intGLDetailId IS NULL 		

			--	DELETE	InvLotTrans
			--	FROM	dbo.tblICInventoryLotTransaction InvLotTrans LEFT JOIN dbo.tblGLDetail GL
			--				ON GL.strBatchId = InvLotTrans.strBatchId
			--				AND GL.intTransactionId = InvLotTrans.intTransactionId
			--				AND GL.strTransactionId = InvLotTrans.strTransactionId
			--	WHERE	InvLotTrans.intTransactionId = @intInventoryAdjustmentId
			--			AND InvLotTrans.strTransactionId = @strAdjustmentNo
			--			AND GL.intGLDetailId IS NULL 
			--END	
						
			IF @@ERROR <> 0
			BEGIN 
				PRINT ERROR_MESSAGE()  
			END 
		END 

		FETCH NEXT FROM loopUnpostAdjustment INTO 
			@intInventoryAdjustmentId	
			,@strAdjustmentNo
			,@intEntityId
			,@ysnPosted
			,@dtmUnpostedDate
		;
	END 

	CLOSE loopUnpostAdjustment;
	DEALLOCATE loopUnpostAdjustment;

	-- 9. Fix the stock out of the Cost Buckets 
	UPDATE	CostBucketLot
	SET		dblStockOut = dblStockOut - LotOutFix.dblQty
	FROM	dbo.tblICInventoryLot CostBucketLot INNER JOIN (
				SELECT	dblQty = SUM(LotOut.dblQty)
						,LotOut.intInventoryLotId
				FROM	dbo.tblICInventoryLotOut LotOut LEFT JOIN dbo.tblICInventoryTransaction InvTrans
							ON LotOut.intInventoryTransactionId = InvTrans.intInventoryTransactionId
				WHERE	ISNULL(InvTrans.ysnIsUnposted, 0) = 0
						AND LotOut.dblQty <> ISNULL(InvTrans.dblQty * -1, 0)
						AND ISNULL(InvTrans.dblValue, 0) = 0 -- Do not update Revalue or Write-Off Sold 
				GROUP BY LotOut.intInventoryLotId
			) LotOutFix
				ON CostBucketLot.intInventoryLotId = LotOutFix.intInventoryLotId

	UPDATE	CostBucketFIFO
	SET		dblStockOut = dblStockOut - FIFOOutFix.dblQty
	FROM	dbo.tblICInventoryFIFO CostBucketFIFO INNER JOIN (
				SELECT	dblQty = SUM(FIFOOut.dblQty)
						,FIFOOut.intInventoryFIFOId
				FROM	dbo.tblICInventoryFIFOOut FIFOOut LEFT JOIN dbo.tblICInventoryTransaction InvTrans
							ON FIFOOut.intInventoryTransactionId = InvTrans.intInventoryTransactionId
				WHERE	ISNULL(InvTrans.ysnIsUnposted, 0) = 0
						AND FIFOOut.dblQty <> ISNULL(InvTrans.dblQty * -1, 0)
						AND ISNULL(InvTrans.dblValue, 0) = 0 -- Do not update Revalue or Write-Off Sold 
				GROUP BY FIFOOut.intInventoryFIFOId
			) FIFOOutFix
				ON CostBucketFIFO.intInventoryFIFOId = FIFOOutFix.intInventoryFIFOId

	UPDATE	CostBucketLIFO
	SET		dblStockOut = dblStockOut - LIFOOutFix.dblQty
	FROM	dbo.tblICInventoryLIFO CostBucketLIFO INNER JOIN (
				SELECT	dblQty = SUM(LIFOOut.dblQty)
						,LIFOOut.intInventoryLIFOId
				FROM	dbo.tblICInventoryLIFOOut LIFOOut LEFT JOIN dbo.tblICInventoryTransaction InvTrans
							ON LIFOOut.intInventoryTransactionId = InvTrans.intInventoryTransactionId
				WHERE	ISNULL(InvTrans.ysnIsUnposted, 0) = 0
						AND LIFOOut.dblQty <> ISNULL(InvTrans.dblQty * -1, 0)
						AND ISNULL(InvTrans.dblValue, 0) = 0 -- Do not update Revalue or Write-Off Sold 
				GROUP BY LIFOOut.intInventoryLIFOId
			) LIFOOutFix
				ON CostBucketLIFO.intInventoryLIFOId = LIFOOutFix.intInventoryLIFOId

END TRY 
BEGIN CATCH 

	PRINT 'Error found in ' + @strAdjustmentNo
	PRINT ERROR_MESSAGE()           

	IF @@TRANCOUNT > 0	
	BEGIN 
		PRINT 'Rolling back.'
		ROLLBACK TRANSACTION 
	END 
		
END CATCH 

IF @@TRANCOUNT > 0
BEGIN 
	PRINT 'Commit transactions'
	COMMIT TRANSACTION 
END 
	
GO

--------------------------------------------------------------
-- Update the tblGLSummary Amounts
--------------------------------------------------------------
MERGE	
	INTO	dbo.tblGLSummary 
	WITH	(HOLDLOCK) 
	AS		gl_summary 
	USING (
				SELECT	intAccountId
						,dtmDate = dbo.fnRemoveTimeOnDate(GLEntries.dtmDate)
						,strCode
						,dblDebit = SUM(CASE WHEN 1 = 1 THEN Debit.Value ELSE Credit.Value * -1 END)
						,dblCredit = SUM(CASE WHEN 1 = 1 THEN Credit.Value ELSE Debit.Value * -1 END)
						,dblDebitUnit = SUM(CASE WHEN 1 = 1 THEN DebitUnit.Value ELSE CreditUnit.Value * -1 END)
						,dblCreditUnit = SUM(CASE WHEN 1 = 1 THEN CreditUnit.Value ELSE DebitUnit.Value * -1 END)						
				FROM	dbo.tblGLDetail GLEntries
						CROSS APPLY dbo.fnGetDebit(ISNULL(GLEntries.dblDebit, 0) - ISNULL(GLEntries.dblCredit, 0)) Debit
						CROSS APPLY dbo.fnGetCredit(ISNULL(GLEntries.dblDebit, 0) - ISNULL(GLEntries.dblCredit, 0))  Credit
						CROSS APPLY dbo.fnGetDebit(ISNULL(GLEntries.dblDebitUnit, 0) - ISNULL(GLEntries.dblCreditUnit, 0)) DebitUnit
						CROSS APPLY dbo.fnGetCredit(ISNULL(GLEntries.dblDebitUnit, 0) - ISNULL(GLEntries.dblCreditUnit, 0))  CreditUnit
				GROUP BY intAccountId, dbo.fnRemoveTimeOnDate(GLEntries.dtmDate), strCode
	) AS Source_Query  
		ON gl_summary.intAccountId = Source_Query.intAccountId
		AND gl_summary.strCode = Source_Query.strCode 
		AND dbo.fnDateEquals(gl_summary.dtmDate, Source_Query.dtmDate) = 1

	-- Update an existing gl summary record
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblDebit = Source_Query.dblDebit 
				,dblCredit = Source_Query.dblCredit 
				,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1

	-- Insert a new gl summary record 
	WHEN NOT MATCHED  THEN 
		INSERT (
			intAccountId
			,dtmDate
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strCode
			,intConcurrencyId
		)
		VALUES (
			Source_Query.intAccountId
			,Source_Query.dtmDate
			,Source_Query.dblDebit
			,Source_Query.dblCredit
			,Source_Query.dblDebitUnit
			,Source_Query.dblCreditUnit
			,Source_Query.strCode
			,1
		);

GO

EXEC dbo.uspICFixStockQuantities

GO 

-- Regress test the following:
-- 1. Check the values in tblICInventoryLot for any orphaned records with tblICnventoryTransaction.
