CREATE PROCEDURE [dbo].[uspAPRepostBillCostAdjustment]
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

	DECLARE @voucherIds AS Id

	INSERT INTO @voucherIds
	SELECT intBillId = @intBillId
		
	--INSERT INTO @adjustedEntries (
	--	[intItemId] 
	--	,[intItemLocationId] 
	--	,[intItemUOMId] 
	--	,[dtmDate] 
	--	,[dblQty] 
	--	,[dblUOMQty] 
	--	,[intCostUOMId] 
	--	,[dblVoucherCost] 
	--	,[dblNewValue]
	--	,[intCurrencyId] 
	--	--,[dblExchangeRate] 
	--	,[intTransactionId]
	--	,[intTransactionDetailId]
	--	,[strTransactionId]
	--	,[intTransactionTypeId]
	--	,[intLotId]
	--	,[intSubLocationId]
	--	,[intStorageLocationId]
	--	,[ysnIsStorage]
	--	,[strActualCostId]
	--	,[intSourceTransactionId]
	--	,[intSourceTransactionDetailId]
	--	,[strSourceTransactionId]	
	--)
	--SELECT
	--		[intItemId]							=	B.intItemId
	--		,[intItemLocationId]				=	D.intItemLocationId
	--		,[intItemUOMId]						=   itemUOM.intItemUOMId
	--		,[dtmDate] 							=	A.dtmDate
	--		,[dblQty] 							=	NULL --CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END
	--		,[dblUOMQty] 						=	NULL --itemUOM.dblUnitQty
	--		,[intCostUOMId]						=	NULL -- voucherCostUOM.intItemUOMId 
	--		,[dblVoucherCost] 					=	NULL -- B.dblCost 
	--		,[dblNewValue]						=	
	--											/*
	--												New Formula: 
	--												Cost Adjustment Value = 
	--												[Voucher Qty x Voucher Cost] - [Voucher Qty x Receipt Cost]												
	--											*/
	--											dbo.fnMultiply(
	--												--[Voucher Qty]
	--												CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END
	--												--[Voucher Cost]
	--												,CASE WHEN A.intCurrencyId <> @intFunctionalCurrencyId THEN 														
	--														dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId,
	--															COALESCE(B.intWeightUOMId, B.intUnitOfMeasureId),
	--															(B.dblCost - (B.dblCost * (ISNULL(B.dblDiscount,0) / 100)))) * ISNULL(B.dblRate, 0) 
	--													ELSE 
	--														dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId, 
	--															COALESCE(B.intWeightUOMId, B.intUnitOfMeasureId),
	--															(B.dblCost - (B.dblCost * (ISNULL(B.dblDiscount,0) / 100))))
	--												END 													
	--											)
	--											- dbo.fnMultiply(
	--												--[Voucher Qty]
	--												CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END
													
	--												,--[Receipt Cost]
	--												CASE WHEN E2.ysnSubCurrency = 1 AND E1.intSubCurrencyCents <> 0 THEN 
	--														CASE WHEN E1.intCurrencyId <> @intFunctionalCurrencyId THEN 	
	--																dbo.fnCalculateCostBetweenUOM(
	--																	receiptCostUOM.intItemUOMId
	--																	, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
	--																	, E2.dblUnitCost
	--																) 
	--																/ E1.intSubCurrencyCents
	--																* E2.dblForexRate
	--															ELSE 
	--																dbo.fnCalculateCostBetweenUOM(
	--																	receiptCostUOM.intItemUOMId
	--																	, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
	--																	, E2.dblUnitCost
	--																) 
	--																/ E1.intSubCurrencyCents
	--														END 
	--													ELSE
	--														CASE WHEN E1.intCurrencyId <> @intFunctionalCurrencyId THEN 	
	--															dbo.fnCalculateCostBetweenUOM(
	--																receiptCostUOM.intItemUOMId
	--																, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
	--																, E2.dblUnitCost
	--															) 
	--															* E2.dblForexRate
	--														ELSE 
	--															dbo.fnCalculateCostBetweenUOM(
	--																receiptCostUOM.intItemUOMId
	--																, COALESCE(E2.intWeightUOMId, E2.intUnitMeasureId) 
	--																, E2.dblUnitCost
	--															) 
	--													END 
	--												END
	--											)
	--		,[intCurrencyId] 					=	A.intCurrencyId
	--		--,[dblExchangeRate] 					=	0
	--		,[intTransactionId]					=	A.intBillId
	--		,[intTransactionDetailId] 			=	B.intBillDetailId
	--		,[strTransactionId] 				=	A.strBillId
	--		,[intTransactionTypeId] 			=	transType.intTransactionTypeId
	--		,[intLotId] 						=	NULL 
	--		,[intSubLocationId] 				=	E2.intSubLocationId
	--		,[intStorageLocationId] 			=	E2.intStorageLocationId
	--		,[ysnIsStorage] 					=	0
	--		,[strActualCostId] 					=	E1.strActualCostId
	--		,[intSourceTransactionId] 			=	E2.intInventoryReceiptId
	--		,[intSourceTransactionDetailId] 	=	E2.intInventoryReceiptItemId
	--		,[strSourceTransactionId] 			=	E1.strReceiptNumber
	--FROM	tblAPBill A INNER JOIN tblAPBillDetail B
	--			ON A.intBillId = B.intBillId
	--		INNER JOIN (
	--			tblICInventoryReceipt E1 INNER JOIN tblICInventoryReceiptItem E2 
	--				ON E1.intInventoryReceiptId = E2.intInventoryReceiptId
	--		)
	--			ON B.intInventoryReceiptItemId = E2.intInventoryReceiptItemId
	--			AND B.intItemId = E2.intItemId 
	--		INNER JOIN tblICItem item 
	--			ON B.intItemId = item.intItemId
	--		INNER JOIN tblICItemLocation D
	--			ON D.intLocationId = E1.intLocationId AND D.intItemId = item.intItemId
	--		LEFT JOIN tblICItemUOM itemUOM
	--			ON itemUOM.intItemUOMId = ISNULL(B.intWeightUOMId, B.intUnitOfMeasureId)
	--		LEFT JOIN tblICItemUOM voucherCostUOM
	--			ON voucherCostUOM.intItemUOMId = ISNULL(B.intCostUOMId, B.intUnitOfMeasureId)
	--		LEFT JOIN tblICItemUOM receiptCostUOM
	--			ON receiptCostUOM.intItemUOMId = ISNULL(E2.intCostUOMId, E2.intUnitMeasureId)
	--		LEFT JOIN tblICInventoryTransactionType transType
	--			ON transType.strName = 'Bill'
	--WHERE	A.intBillId = @intBillId
	--		AND B.intInventoryReceiptChargeId IS NULL 
	--		-- Compare the cost used in Voucher against the IR cost. 
	--		-- If there is a difference, add it to @adjustedEntries table variable. 
	--		AND (
	--			dbo.fnCalculateCostBetweenUOM(
	--				voucherCostUOM.intItemUOMId
	--				,receiptCostUOM.intItemUOMId
	--				,B.dblCost - (B.dblCost * (B.dblDiscount / 100))
	--				) <> E2.dblUnitCost
	--			OR E2.dblForexRate <> B.dblRate
	--		) 

	INSERT INTO @adjustedEntries (
		[intItemId] 
		,[intItemLocationId] 
		,[intItemUOMId] 
		,[dtmDate] 
		,[dblQty] 
		,[dblUOMQty] 
		,[intCostUOMId] 
		--,[dblVoucherCost] 
		,[dblNewValue]
		,[dblNewForexValue]
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
		,[intFobPointId]
		,[intInTransitSourceLocationId]
		,[intForexRateTypeId] 
		,[dblForexRate] 
	)
	SELECT 
		[intItemId] 
		,[intItemLocationId] 
		,[intItemUOMId] 
		,[dtmDate] 
		,[dblQty] 
		,[dblUOMQty] 
		,[intCostUOMId] 
		,[dblNewValue]
		,[dblNewForexValue]
		,[intCurrencyId] 
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
		,[intFobPointId]
		,[intInTransitSourceLocationId]
		,[intForexRateTypeId] 
		,[dblForexRate] 
	FROM dbo.fnAPCreateReceiptItemCostAdjustment(
			@voucherIds
			, @intFunctionalCurrencyId
	)

	--CHARGES COST ADJUSTMENT
	DECLARE @ChargesToAdjust as OtherChargeCostAdjustmentTableType
	INSERT INTO @ChargesToAdjust 
	(
		[intInventoryReceiptChargeId] 
		,[dblNewValue] 
		,[dblNewForexValue]
		,[dtmDate] 
		,[intTransactionId] 
		,[intTransactionDetailId] 
		,[strTransactionId] 
		,[intCurrencyId] 
		,[intForexRateTypeId] 
		,[dblForexRate] 
	)
	SELECT 
		[intInventoryReceiptChargeId] = rc.intInventoryReceiptChargeId
		,[dblNewValue] = --B.dblCost - B.dblOldCost
			CASE 
				WHEN ISNULL(rc.dblForexRate, 1) <> 1 AND ISNULL(rc.ysnSubCurrency, 0) = 1 THEN 
					-- Formula: 
					-- 1. {Voucher Other Charge} minus {IR Other Charge} 
					-- 2. convert to sub currency cents. 
					-- 3. and then convert into functional currency. 
					CAST(
						(
							(B.dblQtyReceived * B.dblCost)
							/ ISNULL(r.intSubCurrencyCents, 1) 
							* ISNULL(rc.dblForexRate, 1)
						) 
						AS DECIMAL(18,2)
					)
					- 
					CAST(
						(
							(B.dblQtyReceived * COALESCE(NULLIF(rc.dblRate, 0), rc.dblAmount, 0))
							/ ISNULL(r.intSubCurrencyCents, 1) 
							* ISNULL(rc.dblForexRate, 1) 
						)
						AS DECIMAL(18,2)
					)
				WHEN ISNULL(rc.dblForexRate, 1) <> 1 AND ISNULL(rc.ysnSubCurrency, 0) = 0 THEN 
					-- Formula: 
					-- 1. {Voucher Other Charge} minus {IR Other Charge} 
					-- 2. and then convert into functional currency. 
					CAST(
						(
							(B.dblQtyReceived * B.dblCost)
							* ISNULL(rc.dblForexRate, 1)
						) 
						AS DECIMAL(18,2)
					)
					- 
					CAST(
						(
							(B.dblQtyReceived * COALESCE(NULLIF(rc.dblRate, 0), rc.dblAmount, 0))
							* ISNULL(rc.dblForexRate, 1) 
						)
						AS DECIMAL(18,2)
					)
				WHEN ISNULL(rc.ysnSubCurrency, 0) = 1 THEN 
					-- Formula: 
					-- 1. {Voucher Other Charge} minus {IR Other Charge} 
					-- 2. and then convert into functional currency. 
						CAST(
							(
								(B.dblQtyReceived * B.dblCost)
								/ ISNULL(r.intSubCurrencyCents, 1) 
							)  
							AS DECIMAL(18,2)
						)
						- 
						CAST(
							(
								(B.dblQtyReceived * COALESCE(NULLIF(rc.dblRate, 0), rc.dblAmount, 0))
								/ ISNULL(r.intSubCurrencyCents, 1)
							)
							AS DECIMAL(18,2)
						)
				ELSE
					-- Formula: 
					-- 1. {Voucher Other Charge} minus {IR Other Charge} 
						CAST(
							(B.dblQtyReceived * B.dblCost)  
							AS DECIMAL(18,2)
						)
						- 
						CAST(
							(B.dblQtyReceived * COALESCE(NULLIF(rc.dblRate, 0), rc.dblAmount, 0))
							AS DECIMAL(18,2)
						)
			END 
		,[dblNewForexValue] = --B.dblCost - B.dblOldCost
			CASE 
				WHEN ISNULL(rc.ysnSubCurrency, 0) = 1 THEN 
					-- Formula: 
					-- 1. {Voucher Other Charge} minus {IR Other Charge} 
					-- 2. and then convert into functional currency. 
					CAST(
						(
							(B.dblQtyReceived * B.dblCost) / ISNULL(r.intSubCurrencyCents, 1) 
						)  
						AS DECIMAL(18,2)
					)
					- 
					CAST(
					(
						(B.dblQtyReceived * COALESCE(NULLIF(rc.dblRate, 0), rc.dblAmount, 0))
						/ ISNULL(r.intSubCurrencyCents, 1))
						AS DECIMAL(18,2)
					)
				ELSE
					-- Formula: 
					-- 1. {Voucher Other Charge} minus {IR Other Charge} 
					CAST(
						(B.dblQtyReceived * B.dblCost )  
						AS DECIMAL(18,2)
					)
					- 
					CAST(
						(B.dblQtyReceived * COALESCE(NULLIF(rc.dblRate, 0), rc.dblAmount, 0))
						AS DECIMAL(18,2)
					)
			END  			
		,[dtmDate] = A.dtmDate
		,[intTransactionId] = A.intBillId
		,[intTransactionDetailId] = B.intBillDetailId
		,[strTransactionId] = A.strBillId
		,[intCurrencyId] = rc.intCurrencyId
		,[intForexRateTypeId] = rc.intForexRateTypeId
		,[dblForexRate] = B.dblRate
	FROM 
		tblAPBill A INNER JOIN tblAPBillDetail B
			ON A.intBillId = B.intBillId
		INNER JOIN (
			tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge rc 
				ON r.intInventoryReceiptId = rc.intInventoryReceiptId
		)
			ON rc.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
	WHERE 
		A.intBillId = @intBillId 
		AND B.intInventoryReceiptChargeId IS NOT NULL 
		AND rc.ysnInventoryCost = 1 --create cost adjustment entries for Inventory only for inventory cost yes
		AND (
			(B.dblCost <> (CASE WHEN rc.strCostMethod IN ('Amount','Percentage') THEN rc.dblAmount ELSE rc.dblRate END))
			OR ISNULL(NULLIF(rc.dblForexRate,0),1) <> B.dblRate
		)
		AND A.intTransactionReversed IS NULL

	-- Remove zero cost adjustments. 
	DELETE FROM @adjustedEntries WHERE ROUND(dblNewValue, 2) = 0 

	-- Remove zero cost adjustments. 
	DELETE FROM @ChargesToAdjust WHERE ROUND(dblNewValue, 2) = 0 

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
	END

	IF EXISTS(SELECT TOP 1 1 FROM @ChargesToAdjust)
	BEGIN 
		EXEC @intReturnValue = uspICPostCostAdjustmentFromOtherCharge 
			@ChargesToAdjust = @ChargesToAdjust 
			,@strBatchId = @strBatchId 
			,@intEntityUserSecurityId = @intEntityUserSecurityId 
			,@ysnPost = 1
			,@strTransactionType = DEFAULT 

		IF @intReturnValue <> 0 
		BEGIN 
			SELECT	TOP 1 
					@ErrorMessage = strMessage
			FROM	tblICPostResult
			WHERE	strBatchNumber = @strBatchId

			RAISERROR(@ErrorMessage, 11, 1);
			GOTO _Exit
		END 			
	END 
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM @adjustedEntries) AND NOT EXISTS (SELECT TOP 1 1 FROM @ChargesToAdjust)
	BEGIN 			
		-- 'Cost adjustment for {Transaction Id} is missing. Stock rebuild will abort.'
		EXEC uspICRaiseError 80265, @strBillId; 	
		RETURN -80265;
	END 

	-- Create the GL entries for the cost adjustment. 
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
			,intSourceEntityId
			,intCommodityId
			,intCurrencyExchangeRateTypeId
			,strRateType
		)
		EXEC dbo.uspICCreateGLEntriesOnCostAdjustment 
			@strBatchId = @strBatchId
			,@intEntityUserSecurityId = @intEntityUserSecurityId
			,@strTransactionId = @strBillId
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