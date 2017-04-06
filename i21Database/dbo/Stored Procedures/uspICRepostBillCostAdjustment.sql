CREATE PROCEDURE [dbo].[uspICRepostBillCostAdjustment]
	@strBillId AS NVARCHAR(50)
	,@strBatchId AS NVARCHAR(20)
	,@intEntityUserSecurityId AS INT
	,@ysnRegenerateBillGLEntries AS BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intBillId AS INT
		
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

	INSERT INTO @billGLEntries
	SELECT	* 
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
		,[intSourceTransactionDetailId]
		,[strSourceTransactionId]	
	)
	SELECT
			[intItemId]							=	B.intItemId
			,[intItemLocationId]				=	D.intItemLocationId
			,[intItemUOMId]						=   itemUOM.intItemUOMId
			,[dtmDate] 							=	A.dtmDate
			,[dblQty] 							=	CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END
			,[dblUOMQty] 						=	itemUOM.dblUnitQty
			,[intCostUOMId]						=	voucherCostUOM.intItemUOMId 
			,[dblVoucherCost] 					=	B.dblCost 
			,[intCurrencyId] 					=	A.intCurrencyId
			,[dblExchangeRate] 					=	0
			,[intTransactionId]					=	A.intBillId
			,[intTransactionDetailId] 			=	B.intBillDetailId
			,[strTransactionId] 				=	A.strBillId
			,[intTransactionTypeId] 			=	25
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
				ON D.intLocationId = A.intShipToId AND D.intItemId = item.intItemId
			LEFT JOIN tblICItemUOM itemUOM
				ON itemUOM.intItemUOMId = ISNULL(B.intWeightUOMId, B.intUnitOfMeasureId)
			LEFT JOIN tblICItemUOM voucherCostUOM
				ON voucherCostUOM.intItemUOMId = ISNULL(B.intCostUOMId, B.intUnitOfMeasureId)
			LEFT JOIN tblICItemUOM receiptCostUOM
				ON receiptCostUOM.intItemUOMId = ISNULL(E2.intCostUOMId, E2.intUnitMeasureId)

	WHERE	A.intBillId = @intBillId
			AND B.intInventoryReceiptChargeId IS NULL 
			-- Compare the cost used in Voucher against the IR cost. 
			-- If there is a difference, add it to @adjustedEntries table variable. 
			AND dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId, receiptCostUOM.intItemUOMId, B.dblCost) != E2.dblUnitCost

	IF EXISTS(SELECT TOP 1 1 FROM @adjustedEntries)
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
		EXEC uspICPostCostAdjustment 
			@adjustedEntries
			, @strBatchId
			, @intEntityUserSecurityId
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
