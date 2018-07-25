CREATE PROCEDURE [dbo].[uspICRepostBillCostAdjustment]
	@strBillId AS NVARCHAR(50)
	,@strBatchId AS NVARCHAR(40)
	,@intEntityUserSecurityId AS INT
	,@ysnRegenerateBillGLEntries AS BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intBillId AS INT
		,@intReturnValue AS INT 
		
SELECT @intBillId = intBillId 
FROM	tblAPBill b
WHERE	b.strBillId = @strBillId
		AND b.ysnPosted = 1

IF @intBillId IS NULL 
BEGIN 
	-- TODO Raiseerror 
	GOTO _Exit
END 

DECLARE @billGLEntries AS RecapTableType 
		,@adjustedEntries AS ItemCostAdjustmentTableType

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId  AS INT 
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END 

-- Regenerate the A/P module GL entries
IF @ysnRegenerateBillGLEntries = 1
BEGIN 
	--=======================================================
	--UPDATE BILL DETAIL OLD COST VALUE
	--=======================================================
	UPDATE	bd
	SET		dblOldCost = ri.dblUnitCost
	FROM	tblAPBill b INNER JOIN tblAPBillDetail bd
				ON b.intBillId = bd.intBillId
			INNER JOIN tblICInventoryReceiptItem ri 
				ON ri.intInventoryReceiptItemId = bd.intInventoryReceiptItemId
	WHERE	b.strBillId = @strBillId

	-- CLEAR THE G/L ENTRIES ON THE BILL
	DELETE	FROM tblGLDetail 
	WHERE	strBatchId = @strBatchId
			AND strTransactionId = @strBillId

	--UPDATE THE AMOUNT DUE OF THE BILL IF 0 THEN REVERT IT TO ORGINAL
	UPDATE	b
	SET		dblAmountDue = b.dblTotal
	FROM	tblAPBill b 
	WHERE	b.strBillId = @strBillId

	INSERT INTO @billGLEntries(
	[dtmDate],
	[strBatchId],
	[intAccountId],
	[dblDebit],
	[dblCredit],
	[dblDebitUnit],
	[dblCreditUnit],
	[strDescription],
	[strCode],    
	[strReference],
	[intCurrencyId],
	[dblExchangeRate],
	[dtmDateEntered] ,
	[dtmTransactionDate],
	[strJournalLineDescription],
	[intJournalLineNo],
	[ysnIsUnposted],    
	[intUserId],
	[intEntityId],
	[strTransactionId],
	[intTransactionId],
	[strTransactionType],
	[strTransactionForm],
	[strModuleName],
	[intConcurrencyId],
	[dblDebitForeign],
    [dblDebitReport],
    [dblCreditForeign],
    [dblCreditReport],
    [dblReportingRate],
    [dblForeignRate],
	[strRateType])
	SELECT	
	[dtmDate],
	[strBatchId],
	[intAccountId],
	[dblDebit],
	[dblCredit],
	[dblDebitUnit],
	[dblCreditUnit],
	[strDescription],
	[strCode],    
	[strReference],
	[intCurrencyId],
	[dblExchangeRate],
	[dtmDateEntered] ,
	[dtmTransactionDate],
	[strJournalLineDescription],
	[intJournalLineNo],
	[ysnIsUnposted],    
	[intUserId],
	[intEntityId],
	[strTransactionId],
	[intTransactionId],
	[strTransactionType],
	[strTransactionForm],
	[strModuleName],
	[intConcurrencyId],
	[dblDebitForeign],
    [dblDebitReport],
    [dblCreditForeign],
    [dblCreditReport],
    [dblReportingRate],
    [dblForeignRate],
	[strRateType]
	FROM	dbo.[fnAPCreateBillGLEntries](
				@intBillId
				, @intEntityUserSecurityId
				, @strBatchId
	)
END 

-- Generate a new cost adjustment 
BEGIN 		
	-- CLEAR THE G/L ENTRIES ON THE BILL
	DELETE	FROM tblGLDetail 
	WHERE	strBatchId = @strBatchId
			AND strTransactionId = @strBillId
			AND strCode <> 'AP'

	-- Delete the inventory transaction records
	DELETE	t 
	FROM	tblICInventoryTransaction t 
	WHERE	t.strTransactionId = @strBillId
			AND t.strBatchId = @strBatchId
		
	INSERT INTO @adjustedEntries (
		[intItemId] 
		,[intItemLocationId] 
		,[intItemUOMId] 
		,[dtmDate] 
		,[dblQty] 
		,[dblUOMQty] 
		,[intCostUOMId] 
		,[dblVoucherCost] 
		,[dblNewValue]
		,[intCurrencyId] 
		--,[dblExchangeRate] 
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
		,[intSourceTransactionDetailId]
		,[strSourceTransactionId]	
	)
	SELECT
			[intItemId]							=	B.intItemId
			,[intItemLocationId]				=	D.intItemLocationId
			,[intItemUOMId]						=   itemUOM.intItemUOMId
			,[dtmDate] 							=	A.dtmDate
			,[dblQty] 							=	NULL --CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END
			,[dblUOMQty] 						=	NULL --itemUOM.dblUnitQty
			,[intCostUOMId]						=	NULL -- voucherCostUOM.intItemUOMId 
			,[dblVoucherCost] 					=	NULL -- B.dblCost 
			,[dblNewValue]						=	
												/*
													New Formula: 
													Cost Adjustment Value = 
													[Voucher Qty x Voucher Cost] - [Voucher Qty x Receipt Cost]												
												*/
												dbo.fnMultiply(
													--[Voucher Qty]
													CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END
													--[Voucher Cost]
													,CASE WHEN A.intCurrencyId <> @intFunctionalCurrencyId THEN 														
															dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId,
																COALESCE(B.intWeightUOMId, B.intUnitOfMeasureId),
																(B.dblCost - (B.dblCost * (ISNULL(B.dblDiscount,0) / 100)))) * ISNULL(B.dblRate, 0) 
														ELSE 
															dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId, 
																COALESCE(B.intWeightUOMId, B.intUnitOfMeasureId),
																(B.dblCost - (B.dblCost * (ISNULL(B.dblDiscount,0) / 100))))
													END 													
												)
												- dbo.fnMultiply(
													--[Voucher Qty]
													CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END
													
													,--[Receipt Cost]
													CASE WHEN E2.ysnSubCurrency = 1 AND E1.intSubCurrencyCents <> 0 THEN 
															CASE WHEN E1.intCurrencyId <> @intFunctionalCurrencyId THEN 	
																	dbo.fnCalculateCostBetweenUOM(
																		receiptCostUOM.intItemUOMId
																		, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
																		, E2.dblUnitCost
																	) 
																	/ E1.intSubCurrencyCents
																	* E2.dblForexRate
																ELSE 
																	dbo.fnCalculateCostBetweenUOM(
																		receiptCostUOM.intItemUOMId
																		, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
																		, E2.dblUnitCost
																	) 
																	/ E1.intSubCurrencyCents
															END 
														ELSE
															CASE WHEN E1.intCurrencyId <> @intFunctionalCurrencyId THEN 	
																dbo.fnCalculateCostBetweenUOM(
																	receiptCostUOM.intItemUOMId
																	, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
																	, E2.dblUnitCost
																) 
																* E2.dblForexRate
															ELSE 
																dbo.fnCalculateCostBetweenUOM(
																	receiptCostUOM.intItemUOMId
																	, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
																	, E2.dblUnitCost
																) 
														END 
													END
												)
			,[intCurrencyId] 					=	A.intCurrencyId
			--,[dblExchangeRate] 					=	0
			,[intTransactionId]					=	A.intBillId
			,[intTransactionDetailId] 			=	B.intBillDetailId
			,[strTransactionId] 				=	A.strBillId
			,[intTransactionTypeId] 			=	transType.intTransactionTypeId
			,[intLotId] 						=	NULL 
			,[intSubLocationId] 				=	E2.intSubLocationId
			,[intStorageLocationId] 			=	E2.intStorageLocationId
			,[ysnIsStorage] 					=	0
			,[strActualCostId] 					=	E1.strActualCostId
			,[intSourceTransactionId] 			=	E2.intInventoryReceiptId
			,[intSourceTransactionDetailId] 	=	E2.intInventoryReceiptItemId
			,[strSourceTransactionId] 			=	E1.strReceiptNumber
	FROM	tblAPBill A INNER JOIN tblAPBillDetail B
				ON A.intBillId = B.intBillId
			INNER JOIN (
				tblICInventoryReceipt E1 INNER JOIN tblICInventoryReceiptItem E2 
					ON E1.intInventoryReceiptId = E2.intInventoryReceiptId
			)
				ON B.intInventoryReceiptItemId = E2.intInventoryReceiptItemId
			INNER JOIN tblICItem item 
				ON B.intItemId = item.intItemId
			INNER JOIN tblICItemLocation D
				ON D.intLocationId = E1.intLocationId AND D.intItemId = item.intItemId
			LEFT JOIN tblICItemUOM itemUOM
				ON itemUOM.intItemUOMId = ISNULL(B.intWeightUOMId, B.intUnitOfMeasureId)
			LEFT JOIN tblICItemUOM voucherCostUOM
				ON voucherCostUOM.intItemUOMId = ISNULL(B.intCostUOMId, B.intUnitOfMeasureId)
			LEFT JOIN tblICItemUOM receiptCostUOM
				ON receiptCostUOM.intItemUOMId = ISNULL(E2.intCostUOMId, E2.intUnitMeasureId)
			LEFT JOIN tblICInventoryTransactionType transType
				ON transType.strName = 'Bill'
	WHERE	A.intBillId = @intBillId
			AND B.intInventoryReceiptChargeId IS NULL 
			-- Compare the cost used in Voucher against the IR cost. 
			-- If there is a difference, add it to @adjustedEntries table variable. 
			AND (
				dbo.fnCalculateCostBetweenUOM(
					voucherCostUOM.intItemUOMId
					,receiptCostUOM.intItemUOMId
					,B.dblCost - (B.dblCost * (B.dblDiscount / 100))
					) <> E2.dblUnitCost
				OR E2.dblForexRate <> B.dblRate
			) 

	-- Remove zero cost adjustments. 
	DELETE FROM @adjustedEntries WHERE ROUND(dblNewValue, 2) = 0 

	IF EXISTS(SELECT TOP 1 1 FROM @adjustedEntries)
	BEGIN
		EXEC @intReturnValue = uspICPostCostAdjustment 
			@adjustedEntries
			, @strBatchId
			, @intEntityUserSecurityId

		IF @intReturnValue <> 0 
		BEGIN 
			DECLARE @ErrorMessage AS NVARCHAR(4000)
			SELECT	TOP 1 
					@ErrorMessage = strMessage
			FROM	tblICPostResult
			WHERE	strBatchNumber = @strBatchId

			RAISERROR(@ErrorMessage, 11, 1);
			GOTO _Exit
		END 
		ELSE 
		BEGIN 
			INSERT INTO @billGLEntries (
				dtmDate						
				,strBatchId					
				,intAccountId				
				,dblDebit					
				,dblCredit					
				,dblDebitUnit				
				,dblCreditUnit				
				,strDescription				
				,strCode					
				,strReference				
				,intCurrencyId				
				,dblExchangeRate			
				,dtmDateEntered				
				,dtmTransactionDate			
				,strJournalLineDescription  
				,intJournalLineNo			
				,ysnIsUnposted				
				,intUserId					
				,intEntityId				
				,strTransactionId			
				,intTransactionId			
				,strTransactionType			
				,strTransactionForm			
				,strModuleName				
				,intConcurrencyId			
				,dblDebitForeign			
				,dblDebitReport				
				,dblCreditForeign			
				,dblCreditReport			
				,dblReportingRate			
				,dblForeignRate						
			)
			EXEC dbo.uspICCreateGLEntriesOnCostAdjustment 
				@strBatchId = @strBatchId
				,@intEntityUserSecurityId = @intEntityUserSecurityId		
		END 
	END
END 

-- Create the g/l entries 
IF EXISTS (SELECT TOP 1 1 FROM @billGLEntries)
BEGIN 
	EXEC dbo.uspGLBookEntries @billGLEntries, 0
END

--THEN REVERT THE AMOUNTDUE TO 0
UPDATE	b
SET		dblAmountDue = 0
FROM	tblAPBill b
WHERE	b.intBillId = @intBillId 
		AND @ysnRegenerateBillGLEntries = 1

_Exit:
