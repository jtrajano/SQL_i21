CREATE PROCEDURE uspAPPostBill
	@batchId			AS NVARCHAR(40)		= NULL,
	@billBatchId		AS NVARCHAR(40)		= NULL,
	@transactionType	AS NVARCHAR(30)		= NULL,
	@post				AS BIT				= 0,
	@repost				AS BIT				= 0, -- do not validate if repost, this will use if you just fixing data gl entries and there's a fix on creating gl entries
	@recap				AS BIT				= 0,
	@isBatch			AS BIT				= 0,
	@param				AS NVARCHAR(MAX)	= NULL,
	@userId				AS INT,
	@beginDate			AS DATE				= NULL,
	@endDate			AS DATE				= NULL,
	@beginTransaction	AS NVARCHAR(50)		= NULL,
	@endTransaction		AS NVARCHAR(50)		= NULL,
	@exclude			AS NVARCHAR(MAX)	= NULL,
	@successfulCount	AS INT				= 0 OUTPUT,
	@invalidCount		AS INT				= 0 OUTPUT,
	@success			AS BIT				= 0 OUTPUT,
	@batchIdUsed		AS NVARCHAR(40)		= NULL OUTPUT,
	@recapId			AS NVARCHAR(250)	= NEWID OUTPUT,
	@isPricingContract	AS INT				= 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
-- Start the transaction 
BEGIN TRANSACTION

IF @userId IS NULL
BEGIN
	RAISERROR('User is required', 16, 1);
END

--DECLARE @success BIT
--DECLARE @successfulCount INT
--EXEC uspPostBill '', '', 1, 0, 12, 1, @success OUTPUT, @successfulCount OUTPUT

--=====================================================================================================================================
-- 	DECLARE TEMPORARY TABLES
---------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE #tmpPostBillData (
	[intBillId] [int] PRIMARY KEY,
	UNIQUE (intBillId)
);

CREATE TABLE #tmpInvalidBillData (
	[strError] [NVARCHAR](1000),
	[strTransactionType] [NVARCHAR](50),
	[strTransactionId] [NVARCHAR](50),
	[intTransactionId] INT,
	[intErrorKey]	INT
);

--DECLARRE VARIABLES
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @GLEntries AS RecapTableType 
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Bill'
DECLARE @validBillIds NVARCHAR(MAX)
DECLARE @failedPostCount INT;
DECLARE @succesfulPostCount INT;
DECLARE @failedAdjustment INT
DECLARE @failedPostValidation INT
DECLARE @billIds NVARCHAR(MAX)
DECLARE @totalRecords INT
DECLARE @costAdjustmentResult INT;
DECLARE @voucherPayables AS VoucherPayable;

-- Get the functional currency
BEGIN 
	DECLARE @intFunctionalCurrencyId  AS INT 
	SET @intFunctionalCurrencyId = dbo.fnSMGetDefaultCurrency('FUNCTIONAL') 
END 


SET @recapId = '1'
--=====================================================================================================================================
-- 	POPULATE JOURNALS TO POST TEMPORARY TABLE
---------------------------------------------------------------------------------------------------------------------------------------
IF (@param IS NOT NULL) 
BEGIN
	IF(@param = 'all')
	BEGIN
		INSERT INTO #tmpPostBillData SELECT intBillId FROM tblAPBill WHERE ysnPosted = 0
	END
	ELSE
	BEGIN
		INSERT INTO #tmpPostBillData SELECT [intID] FROM [dbo].fnGetRowsFromDelimitedValues(@param)
	END
END


IF (@billBatchId IS NOT NULL)
BEGIN
	INSERT INTO #tmpPostBillData
	SELECT B.intBillId FROM tblAPBillBatch A WITH (ROWLOCK, HOLDLOCK)
			LEFT JOIN tblAPBill B	
				ON A.intBillBatchId = B.intBillBatchId
	WHERE A.intBillBatchId = @billBatchId
END
	
IF(@beginDate IS NOT NULL)
BEGIN
	INSERT INTO #tmpPostBillData
	SELECT intBillId FROM tblAPBill
	WHERE DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) BETWEEN @beginDate AND @endDate AND ysnPosted = 0
END

IF(@beginTransaction IS NOT NULL)
BEGIN
	INSERT INTO #tmpPostBillData
	SELECT intBillId FROM tblAPBill
	WHERE intBillId BETWEEN @beginTransaction AND @endTransaction AND ysnPosted = 0
END

--Removed excluded bills to post/unpost
IF(@exclude IS NOT NULL)
BEGIN
	SELECT [intID] INTO #tmpBillsExclude FROM [dbo].fnGetRowsFromDelimitedValues(@exclude)
	DELETE FROM A
	FROM #tmpPostBillData A
	WHERE EXISTS(SELECT * FROM #tmpBillsExclude B WHERE A.intBillId = B.intID)
END

--SET THE UPDATED @billIds
SELECT @billIds = COALESCE(@billIds + ',', '') +  CONVERT(VARCHAR(12),intBillId)
FROM #tmpPostBillData
ORDER BY intBillId

--Update the prepay and debit memo
EXEC uspAPUpdatePrepayAndDebitMemo @billIds, @post
--=====================================================================================================================================
-- 	GET ALL INVALID TRANSACTIONS
---------------------------------------------------------------------------------------------------------------------------------------
DECLARE @reversedPost BIT = ~@post
IF (ISNULL(@recap, 0) = 0 AND @repost = 0)
BEGIN
	
	DECLARE @voucherBillId AS Id;
	INSERT INTO @voucherBillId
	SELECT intBillId FROM #tmpPostBillData

	IF @transactionType IS NULL
	BEGIN
		SET @transactionType = 'Voucher';
	END

	--VALIDATIONS
	INSERT INTO #tmpInvalidBillData (
		strError
		,strTransactionType
		,strTransactionId
		,intTransactionId
		,intErrorKey
	)
	SELECT * FROM fnAPValidatePostBill(@billIds, @post)
	UNION ALL
	SELECT
		strError
		,strTransactionType
		,strTransactionNo
		,intTransactionId
		,23
	FROM dbo.fnPATValidateAssociatedTransaction(@billIds, 4, @transactionType)
	UNION ALL
	SELECT
		C.strError
		,CASE WHEN B.intTransactionType = 1 THEN 'Bill'
												WHEN B.intTransactionType = 2 THEN 'Vendor Prepayment'
												WHEN B.intTransactionType = 3 THEN 'Debit Memo'
												WHEN B.intTransactionType = 13 THEN 'Basis Advance'
												WHEN B.intTransactionType = 14 THEN 'Deferred Interest'
											ELSE 'NONE' END
		,B.strBillId
		,B.intBillId
		,25
	FROM @voucherPayables A
	INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
	CROSS APPLY dbo.fnAPValidateVoucherPayableQty(@voucherPayables) C
	UNION ALL
	SELECT
		strError
		,strTransactionType
		,strTransactionNo
		,intTransactionId
		,26
	FROM dbo.fnCCValidateAssociatedTransaction(@billIds, 1, @transactionType)
	UNION ALL
	SELECT
		strError
		,strTransactionType
		,strTransactionNo
		,intTransactionId
		,27
	FROM dbo.[fnGRValidateBillPost](@billIds, @post, @transactionType)
	
	--if there are invalid applied amount, undo updating of amountdue and payment
	IF EXISTS(SELECT 1 FROM #tmpInvalidBillData WHERE intErrorKey = 1 OR intErrorKey = 33)
	BEGIN
		DECLARE @invalidAmountAppliedIds NVARCHAR(MAX);
		--undo updating of transactions for those invalid only
		SELECT 
			@invalidAmountAppliedIds = COALESCE(@invalidAmountAppliedIds + ',', '') +  CONVERT(VARCHAR(12),intTransactionId)
		FROM #tmpInvalidBillData
		WHERE intErrorKey = 1 OR intErrorKey = 33
		EXEC uspAPUpdatePrepayAndDebitMemo @invalidAmountAppliedIds, @reversedPost
	END

END
ELSE
BEGIN

	--VALIDATIONS
	INSERT INTO #tmpInvalidBillData 
	SELECT * FROM fnAPValidateRecapBill(@billIds, @post)
	--undo updating of transactions for all if recap
	EXEC uspAPUpdatePrepayAndDebitMemo @billIds, @reversedPost
	
END


DECLARE @totalInvalid INT = 0
DECLARE @postResult TABLE(id INT)
SELECT @totalInvalid = COUNT(*) FROM #tmpInvalidBillData

IF(@totalInvalid > 0)
BEGIN

	--Insert Invalid Post transaction result
	INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
	OUTPUT inserted.intId INTO @postResult
	SELECT strError, strTransactionType, strTransactionId, @batchId, intTransactionId FROM #tmpInvalidBillData

	SET @invalidCount = @totalInvalid

	--DELETE Invalid Transaction From temp table
	DELETE #tmpPostBillData
		FROM #tmpPostBillData A
			INNER JOIN #tmpInvalidBillData
				ON A.intBillId = #tmpInvalidBillData.intTransactionId

END

SELECT @totalRecords = COUNT(*) FROM #tmpPostBillData

COMMIT TRANSACTION --COMMIT inserted invalid transaction

IF(@totalRecords = 0 OR (@isBatch = 0 AND @totalInvalid > 0))  
BEGIN
	--if there is a value passed on batchId do not generate
	IF @batchId IS NULL
	BEGIN
		SET @batchId = NEWID(); --just use non standard batch id when posting failed for batch
	END
	SET @batchIdUsed = @batchId;
	
	UPDATE A
		SET A.strBatchNumber = @batchId
	FROM tblAPPostResult A
	INNER JOIN @postResult B ON A.intId = B.id

	SET @successfulCount = 0;
	SET @success = 0
	GOTO Post_Exit
END

--CREATE TEMP GL ENTRIES
SELECT @validBillIds = COALESCE(@validBillIds + ',', '') +  CONVERT(VARCHAR(12),intBillId)
FROM #tmpPostBillData
ORDER BY intBillId

BEGIN TRANSACTION

IF(@batchId IS NULL)
BEGIN
	-- --DO NOT GENERATE IF UNPOST
	-- IF NOT (@post = 0 AND @recap = 0)
	-- 	EXEC uspSMGetStartingNumber 3, @batchId OUT
	-- ELSE
	-- 	SET @batchId = NEWID()
	
	EXEC uspSMGetStartingNumber 3, @batchId OUT
END

SET @batchIdUsed = @batchId

UPDATE A
	SET A.strBatchNumber = @batchId
FROM tblAPPostResult A
INNER JOIN @postResult B ON A.intId = B.id

--CREATE DATA FOR COST ADJUSTMENT
DECLARE @adjustedEntries AS ItemCostAdjustmentTableType
DECLARE @voucherIds AS Id

INSERT INTO @voucherIds
SELECT intBillId FROM #tmpPostBillData

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
)
SELECT 
	[intItemId] 
	,[intItemLocationId] 
	,[intItemUOMId] 
	,[dtmDate] 
	,[dblQty] 
	,[dblUOMQty] 
	,[intCostUOMId] 
	--,[dblVoucherCost] 
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
	,[intFobPointId]
	,[intInTransitSourceLocationId]
FROM dbo.fnAPCreateReceiptItemCostAdjustment(@voucherIds, @intFunctionalCurrencyId)

-- Remove zero cost adjustments. 
DELETE FROM @adjustedEntries WHERE ROUND(dblNewValue, 2) = 0 

--CHARGES COST ADJUSTMENT
DECLARE @ChargesToAdjust as OtherChargeCostAdjustmentTableType

IF @isPricingContract = 0
BEGIN
	INSERT INTO @ChargesToAdjust 
	(
		[intInventoryReceiptChargeId] 
		,[dblNewValue] 
		,[dtmDate] 
		,[intTransactionId] 
		,[intTransactionDetailId] 
		,[strTransactionId] 
	)
	SELECT 
		[intInventoryReceiptChargeId] = rc.intInventoryReceiptChargeId
		,[dblNewValue] = --B.dblCost - B.dblOldCost
				CASE 
				WHEN ISNULL(rc.dblForexRate, 1) <> 1 THEN 
				-- Formula: 
				-- 1. {Voucher Other Charge} minus {IR Other Charge} 
				-- 2. convert to sub currency cents. 
				-- 3. and then convert into functional currency. 
					CAST(
					((B.dblQtyReceived * B.dblCost)
						/ ISNULL(r.intSubCurrencyCents, 1) 
						* ISNULL(rc.dblForexRate, 1)) 
					AS DECIMAL(18,2))
					- 
					CAST(
					((rc.dblAmount - ISNULL(rc.dblAmountBilled, 0)) 
						/ ISNULL(r.intSubCurrencyCents, 1) 
						* ISNULL(rc.dblForexRate, 1) )
					AS DECIMAL(18,2))
				WHEN ISNULL(rc.ysnSubCurrency, 0) = 1 THEN 
				-- Formula: 
				-- 1. {Voucher Other Charge} minus {IR Other Charge} 
				-- 2. and then convert into functional currency. 
				CAST(
					(
						(B.dblQtyReceived * B.dblCost)
						/ ISNULL(r.intSubCurrencyCents, 1) )  
				AS DECIMAL(18,2))
					- 
					CAST(
					(
						(rc.dblAmount - ISNULL(rc.dblAmountBilled, 0)) 
						/ ISNULL(r.intSubCurrencyCents, 1))
					AS DECIMAL(18,2))
				ELSE
				-- Formula: 
				-- 1. {Voucher Other Charge} minus {IR Other Charge} 
					CAST(
					(B.dblQtyReceived * B.dblCost )  
					AS DECIMAL(18,2))
					- 
					CAST(
					(rc.dblAmount - ISNULL(rc.dblAmountBilled, 0))
					AS DECIMAL(18,2))
				END  
		,[dtmDate] = A.dtmDate
		,[intTransactionId] = A.intBillId
		,[intTransactionDetailId] = B.intBillDetailId
		,[strTransactionId] = A.strBillId
	FROM tblAPBill A INNER JOIN tblAPBillDetail B
	ON A.intBillId = B.intBillId
	INNER JOIN (
		tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge rc 
	ON r.intInventoryReceiptId = rc.intInventoryReceiptId
	)
	ON rc.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
	WHERE 
	A.intBillId IN (SELECT intBillId FROM #tmpPostBillData)
	AND B.intInventoryReceiptChargeId IS NOT NULL 
	-- AND rc.ysnInventoryCost = 1 --create cost adjustment entries for Inventory only for inventory cost yes
	AND (
		(B.dblCost <> (CASE WHEN rc.strCostMethod = 'Amount' THEN rc.dblAmount ELSE rc.dblRate END))
		OR ISNULL(NULLIF(rc.dblForexRate,0),1) <> B.dblRate
	)
	AND A.intTransactionReversed IS NULL
END
-- Remove zero cost adjustments. 
DELETE FROM @ChargesToAdjust WHERE ROUND(dblNewValue, 2) = 0 
-- SELECT 
-- 	[intInventoryReceiptChargeId]	= rc.intInventoryReceiptChargeId
-- 	,[dblNewValue]					= B.dblCost - B.dblOldCost
-- 	,[dtmDate]						= A.dtmDate
-- 	,[intTransactionId]				= A.intBillId
-- 	,[intTransactionDetailId]		= B.intBillDetailId
-- 	,[strTransactionId]				= A.strBillId
-- FROM tblAPBill A
-- INNER JOIN tblAPBillDetail B
-- 		ON A.intBillId = B.intBillId
-- INNER JOIN (tblICInventoryReceipt r 
-- 				-- INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
-- 				INNER JOIN tblICInventoryReceiptCharge rc ON r.intInventoryReceiptId = rc.intInventoryReceiptId)
-- 		ON rc.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
-- WHERE	A.intBillId IN (SELECT intBillId FROM #tmpPostBillData)
-- 		AND B.intInventoryReceiptChargeId IS NOT NULL 
-- 		-- AND rc.ysnInventoryCost = 1 --create cost adjustment entries for Inventory only for inventory cost yes
-- 		AND (rc.dblAmount <> B.dblCost OR ISNULL(NULLIF(rc.dblForexRate,0),1) <> B.dblRate)

IF ISNULL(@post,0) = 1
BEGIN	

	INSERT INTO @GLEntries (
		dtmDate ,
	    strBatchId ,
	    intAccountId ,
	    dblDebit ,
	    dblCredit ,
	    dblDebitUnit ,
	    dblCreditUnit ,
	    strDescription ,
	    strCode ,
	    strReference ,
	    intCurrencyId ,
		intCurrencyExchangeRateTypeId,
	    dblExchangeRate ,
	    dtmDateEntered ,
	    dtmTransactionDate ,
	    strJournalLineDescription ,
	    intJournalLineNo ,
	    ysnIsUnposted ,
	    intUserId ,
	    intEntityId ,
	    strTransactionId ,
	    intTransactionId ,
	    strTransactionType ,
	    strTransactionForm ,
	    strModuleName ,
	    dblDebitForeign ,
	    dblDebitReport ,
	    dblCreditForeign ,
	    dblCreditReport ,
	    dblReportingRate ,
	    dblForeignRate ,
	    strRateType ,
		strDocument,
		strComments,
		dblSourceUnitCredit,
		dblSourceUnitDebit,
		intCommodityId,
		intSourceLocationId	
	)
	SELECT     
		dtmDate ,
	    strBatchId ,
	    intAccountId ,
	    Debit.Value ,
	    Credit.Value ,
	    DebitUnit.Value ,
	    CreditUnit.Value ,
	    strDescription ,
	    strCode ,
	    strReference ,
	    intCurrencyId ,
		intCurrencyExchangeRateTypeId,
	    dblExchangeRate ,
	    dtmDateEntered ,
	    dtmTransactionDate ,
	    strJournalLineDescription ,
	    intJournalLineNo ,
	    ysnIsUnposted ,
	    intUserId ,
	    intEntityId ,
	    strTransactionId ,
	    intTransactionId ,
	    strTransactionType ,
	    strTransactionForm ,
	    strModuleName ,
	    DebitForeign.Value ,
	    dblDebitReport ,
	    CreditForeign.Value ,
	    dblCreditReport ,
	    dblReportingRate ,
	    dblForeignRate ,
	    strRateType ,
		strDocument,
		strComments,
		dblSourceUnitCredit,
		dblSourceUnitDebit,
		intCommodityId,
		intSourceLocationId	
	FROM dbo.fnAPCreateBillGLEntries(@validBillIds, @userId, @batchId) A
	CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
	CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0))  Credit
	CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitForeign, 0) - ISNULL(A.dblCreditForeign, 0)) DebitForeign
	CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitForeign, 0) - ISNULL(A.dblCreditForeign, 0))  CreditForeign
	CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) DebitUnit
	CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0))  CreditUnit
	ORDER BY intTransactionId

	-- Call the Item's Cost Adjustment
	DECLARE @intReturnValue AS INT 
	DECLARE @errorAdjustment NVARCHAR(200) 
	IF EXISTS(SELECT 1 FROM @adjustedEntries)
	BEGIN	
		BEGIN TRY
			IF NOT EXISTS( SELECT TOP 1 1 FROM @adjustedEntries WHERE dblQty < 0) --CALL THE ADJUSTMENTS ONLY IF POSSITIVE
			EXEC @intReturnValue = uspICPostCostAdjustment 
					@adjustedEntries
					, @batchId
					, @userId
					, @ysnPost = @post
		END TRY
		BEGIN CATCH
			SET @errorAdjustment = ERROR_MESSAGE()
			RAISERROR(@errorAdjustment, 16, 1);
			GOTO Post_Rollback
		END CATCH
	END

	-- Call the Item's Cost Adjustment from the Other Charges. 
	IF EXISTS(SELECT 1 FROM @ChargesToAdjust)
	BEGIN
		BEGIN TRY
			EXEC @intReturnValue = uspICPostCostAdjustmentFromOtherCharge 
				@ChargesToAdjust = @ChargesToAdjust 
				,@strBatchId = @batchId 
				,@intEntityUserSecurityId = @userId 
				,@ysnPost = @post
				,@strTransactionType = DEFAULT 
		END TRY
		BEGIN CATCH
			SET @errorAdjustment = ERROR_MESSAGE()
			RAISERROR(@errorAdjustment, 16, 1);
			GOTO Post_Rollback
		END CATCH
	END

	-- Create the GL entries for the Cost Adjustment 
	IF	EXISTS(SELECT 1 FROM @adjustedEntries)
		OR EXISTS(SELECT 1 FROM @ChargesToAdjust)
	BEGIN 
		INSERT INTO @GLEntries (
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
			-- ,intCurrencyExchangeRateTypeId	
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
		)
		EXEC dbo.uspICCreateGLEntriesOnCostAdjustment 
			@strBatchId = @batchId
			,@intEntityUserSecurityId = @userId
			,@strGLDescription = 1
			,@ysnPost = @post
			,@AccountCategory_Cost_Adjustment = DEFAULT

		--DELETE FAILED BILLS
		DELETE A
		FROM #tmpPostBillData A
		WHERE EXISTS (
			SELECT 1
			FROM tblAPBill B
			INNER JOIN tblAPBillDetail C ON B.intBillId = C.intBillId AND C.intInventoryReceiptItemId > 0
			INNER JOIN @adjustedEntries D ON B.intBillId = D.intTransactionId AND B.strBillId = D.strTransactionId
			WHERE A.intBillId = B.intBillId
			AND EXISTS (
				SELECT 1 FROM tblICPostResult E WHERE E.strBatchNumber = @batchId AND E.intTransactionId = C.intInventoryReceiptItemId
			)
		)

		SET @failedAdjustment = @@ROWCOUNT;
		SET @invalidCount = @invalidCount + @failedAdjustment;
		SET @totalRecords = @totalRecords - @failedAdjustment;

		--DELETE FAILED BILLS
		DELETE A
		FROM #tmpPostBillData A
		WHERE EXISTS (
			SELECT 1
			FROM tblAPBill B
			INNER JOIN tblAPBillDetail C ON B.intBillId = C.intBillId AND C.intInventoryReceiptItemId > 0
			INNER JOIN @ChargesToAdjust D ON B.intBillId = D.intTransactionId AND B.strBillId = D.strTransactionId
			WHERE A.intBillId = B.intBillId
			AND EXISTS (
				SELECT 1 FROM tblICPostResult E WHERE E.strBatchNumber = @batchId AND E.intTransactionId = C.intInventoryReceiptItemId
			)
		)

		SET @failedAdjustment = @@ROWCOUNT;
		SET @invalidCount = @invalidCount + @failedAdjustment;
		SET @totalRecords = @totalRecords - @failedAdjustment;
	END

END
ELSE
BEGIN

	DECLARE @Ids AS Id
	INSERT INTO @Ids
	SELECT intBillId FROM #tmpPostBillData

	/*
	IF @recap = 0
	BEGIN
		INSERT INTO @GLEntries (
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
		,intCurrencyExchangeRateTypeId		
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
		,dblSourceUnitCredit
		,dblSourceUnitDebit
		,intCommodityId
		,intSourceLocationId	
	)
	SELECT 
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
		,intCurrencyExchangeRateTypeId			
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
		,dblSourceUnitCredit
		,dblSourceUnitDebit
		,intCommodityId
		,intSourceLocationId	
	--when unposting use same batch id as the original gl entry so we don't waste the batch id
	FROM dbo.fnAPReverseGLEntries(@Ids, 'Bill', DEFAULT, @userId, NULL) 
	END
	ELSE
	BEGIN
		INSERT INTO @GLEntries (
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
			,intCurrencyExchangeRateTypeId		
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
			,dblSourceUnitCredit
			,dblSourceUnitDebit
			,intCommodityId
			,intSourceLocationId	
		)
		SELECT 
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
			,intCurrencyExchangeRateTypeId			
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
			,dblSourceUnitCredit
			,dblSourceUnitDebit
			,intCommodityId
			,intSourceLocationId	
		FROM dbo.fnAPReverseGLEntries(@Ids, 'Bill', DEFAULT, @userId, @batchId)
	END
	*/

	INSERT INTO @GLEntries (
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
		,intCurrencyExchangeRateTypeId		
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
		,dblSourceUnitCredit
		,dblSourceUnitDebit
		,intCommodityId
		,intSourceLocationId	
	)
	SELECT 
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
		,intCurrencyExchangeRateTypeId			
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
		,dblSourceUnitCredit
		,dblSourceUnitDebit
		,intCommodityId
		,intSourceLocationId	
	FROM dbo.fnAPReverseGLEntries(@Ids, 'Bill', DEFAULT, @userId, @batchId)

	--NEGATE THE COST
	-- UPDATE @adjustedEntries
	-- SET dblNewValue = -dblNewValue

	-- UPDATE @ChargesToAdjust
	-- SET dblNewValue = -dblNewValue
	-- Call the Item's Cost Adjustment
	IF EXISTS(SELECT 1 FROM @adjustedEntries)
	BEGIN	
		BEGIN TRY
			IF NOT EXISTS( SELECT TOP 1 1 FROM @adjustedEntries WHERE dblQty < 0) --CALL THE ADJUSTMENTS ONLY IF POSSITIVE
			EXEC @intReturnValue = uspICPostCostAdjustment 
					@adjustedEntries
					, @batchId
					, @userId
					, @ysnPost = @post
		END TRY
		BEGIN CATCH
			SET @errorAdjustment = ERROR_MESSAGE()
			RAISERROR(@errorAdjustment, 16, 1);
			GOTO Post_Rollback
		END CATCH
	END

	-- Call the Item's Cost Adjustment from the Other Charges. 
	IF EXISTS(SELECT 1 FROM @ChargesToAdjust)
	BEGIN
		BEGIN TRY
			EXEC @intReturnValue = uspICPostCostAdjustmentFromOtherCharge 
				@ChargesToAdjust = @ChargesToAdjust 
				,@strBatchId = @batchId 
				,@intEntityUserSecurityId = @userId 
				,@ysnPost = @post
				,@strTransactionType = DEFAULT 
		END TRY
		BEGIN CATCH
			SET @errorAdjustment = ERROR_MESSAGE()
			RAISERROR(@errorAdjustment, 16, 1);
			GOTO Post_Rollback
		END CATCH
	END

	-- Create the GL entries for the Cost Adjustment 
	IF	EXISTS(SELECT 1 FROM @adjustedEntries)
		OR EXISTS(SELECT 1 FROM @ChargesToAdjust)
	BEGIN 
		INSERT INTO @GLEntries (
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
		)
		EXEC dbo.uspICCreateGLEntriesOnCostAdjustment 
			@strBatchId = @batchId
			,@intEntityUserSecurityId = @userId
			,@strGLDescription = 1
			,@ysnPost = @post
			,@AccountCategory_Cost_Adjustment = DEFAULT

		--DELETE FAILED BILLS
		DELETE A
		FROM #tmpPostBillData A
		WHERE EXISTS (
			SELECT 1
			FROM tblAPBill B
			INNER JOIN tblAPBillDetail C ON B.intBillId = C.intBillId AND C.intInventoryReceiptItemId > 0
			INNER JOIN @adjustedEntries D ON B.intBillId = D.intTransactionId AND B.strBillId = D.strTransactionId
			WHERE A.intBillId = B.intBillId
			AND EXISTS (
				SELECT 1 FROM tblICPostResult E WHERE E.strBatchNumber = @batchId AND E.intTransactionId = C.intInventoryReceiptItemId
			)
		)

		SET @failedAdjustment = @@ROWCOUNT;
		SET @invalidCount = @invalidCount + @failedAdjustment;
		SET @totalRecords = @totalRecords - @failedAdjustment;

		--DELETE FAILED BILLS
		DELETE A
		FROM #tmpPostBillData A
		WHERE EXISTS (
			SELECT 1
			FROM tblAPBill B
			INNER JOIN tblAPBillDetail C ON B.intBillId = C.intBillId AND C.intInventoryReceiptItemId > 0
			INNER JOIN @ChargesToAdjust D ON B.intBillId = D.intTransactionId AND B.strBillId = D.strTransactionId
			WHERE A.intBillId = B.intBillId
			AND EXISTS (
				SELECT 1 FROM tblICPostResult E WHERE E.strBatchNumber = @batchId AND E.intTransactionId = C.intInventoryReceiptItemId
			)
		)

		SET @failedAdjustment = @@ROWCOUNT;
		SET @invalidCount = @invalidCount + @failedAdjustment;
		SET @totalRecords = @totalRecords - @failedAdjustment;
	END
END

-- Get the vendor id to intSourceEntityId
UPDATE GL SET intSourceEntityId = BL.intEntityVendorId
FROM @GLEntries GL
JOIN tblAPBill BL
ON GL.strTransactionId = BL.strBillId

--=====================================================================================================================================
-- 	CHECK IF THE PROCESS IS RECAP OR NOT
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@recap, 0) = 0
BEGIN

	DECLARE @invalidGL AS Id
	DECLARE @billIdGL AS Id
	INSERT INTO @billIdGL
	SELECT DISTINCT intBillId FROM #tmpPostBillData	

	--VALIDATE GL ENTRIES
	INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
	OUTPUT inserted.intTransactionId INTO @invalidGL
	SELECT
		A.strError
		,A.strTransactionType
		,A.strTransactionId
		,@batchId
		,A.intTransactionId
	FROM dbo.fnAPValidateBillGLEntries(@GLEntries, @billIdGL) A
	WHERE 1 = 0

	--DELETE INVALID
	DELETE A
	FROM #tmpPostBillData A
	INNER JOIN @invalidGL B ON A.intBillId = B.intId

	IF EXISTS(SELECT 1 FROM #tmpPostBillData)
	BEGIN
		--handle error here as we do not get the error here
		IF @totalRecords = 1 AND @isBatch = 0
		BEGIN
			BEGIN TRY
			EXEC uspGLBookEntries @GLEntries, @post
			END TRY
			BEGIN CATCH
				DECLARE @error NVARCHAR(200) = ERROR_MESSAGE()
				SET @invalidCount = @invalidCount + 1;
				SET @totalRecords = @totalRecords - 1;
				RAISERROR(@error, 16, 1);
				GOTO Post_Rollback
			END CATCH
		END
		ELSE
		BEGIN
			BEGIN TRY
				EXEC uspGLBatchPostEntries @GLEntries, @batchId, @userId, @post

				DELETE A
				FROM #tmpPostBillData A
				INNER JOIN (SELECT DISTINCT strBatchId, intTransactionId, strDescription FROM tblGLPostResult) B ON A.intBillId = B.intTransactionId
				WHERE B.strDescription NOT LIKE '%success%' AND B.strBatchId = @batchId
				--DELETE data in @GLEntries so it will not add in computing the latest balance

				--update the invalid and total records based on the result of posting to gl and its result
				SET @failedPostValidation = @@ROWCOUNT;
				SET @invalidCount = @invalidCount + @failedPostValidation;
				SET @totalRecords = @totalRecords - @failedPostValidation;

				DELETE A
				FROM @GLEntries A
				INNER JOIN #tmpPostBillData B ON A.intTransactionId = B.intBillId
				INNER JOIN (SELECT DISTINCT strBatchId, intTransactionId, strDescription FROM tblGLPostResult) C ON B.intBillId = C.intTransactionId
				WHERE C.strDescription NOT LIKE '%success%' AND C.strBatchId = @batchId

				SELECT @totalRecords = COUNT(*) FROM #tmpPostBillData --update total records for the successfulCount

				INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					A.strDescription
					,A.strTransactionType
					,A.strTransactionId
					,@batchId
					,A.intTransactionId
				FROM tblGLPostResult A
				WHERE A.strBatchId = @batchId
			END TRY
			BEGIN CATCH
				DECLARE @errorBatchPost NVARCHAR(200) = ERROR_MESSAGE()
				SET @invalidCount = @invalidCount + 1;
				SET @totalRecords = @totalRecords - 1;
				RAISERROR(@errorBatchPost, 16, 1);
				GOTO Post_Rollback
			END CATCH
		END
	END
	ELSE
	BEGIN
		DECLARE @postError NVARCHAR(200);
		SELECT TOP 1 @postError = strMessage FROM tblAPPostResult WHERE strBatchNumber = @batchId
		RAISERROR(@postError, 16, 1);
		GOTO Post_Rollback
	END

	IF(ISNULL(@post,0) = 0)
	BEGIN

		IF(@billBatchId IS NOT NULL AND @totalRecords > 0)
		BEGIN
			UPDATE tblAPBillBatch
				SET ysnPosted = 0
				FROM tblAPBillBatch WHERE intBillBatchId = @billBatchId
		END

		IF EXISTS(SELECT TOP 1 intBillBatchId FROM dbo.tblAPBill WHERE intBillId IN (SELECT intBillId FROM #tmpPostBillData))
		BEGIN
			SET @billBatchId = (SELECT TOP 1 intBillBatchId FROM dbo.tblAPBill WHERE intBillId IN (SELECT intBillId FROM #tmpPostBillData))
			
			BEGIN
				UPDATE tblAPBillBatch
				SET ysnPosted = 0
				FROM tblAPBillBatch WHERE intBillBatchId IN (@billBatchId)
			END          
		END 
		UPDATE tblAPBill
			SET ysnPosted = 0,
				ysnPaid = 0,
				intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
		FROM tblAPBill WHERE intBillId IN (SELECT intBillId FROM #tmpPostBillData)

		--UPDATE amount due of vendor prepayment, debit memo once payment has been applied to bill
		--UPDATE A
		--	SET dblAmountDue = A.dblAmountDue + AppliedPayments.dblAmountApplied
		--	,dblPayment = dblPayment - AppliedPayments.dblAmountApplied
		--	,ysnPaid = 0
		--FROM tblAPBill A
		--CROSS APPLY
		--(
		--	SELECT 
		--		SUM(B.dblAmountApplied) AS dblAmountApplied
		--	FROM tblAPAppliedPrepaidAndDebit B
		--		--INNER JOIN tblAPBill C ON B.intTransactionId = C.intBillId
		--	WHERE A.intBillId = B.intTransactionId
		--	AND B.intBillId IN (SELECT intBillId FROM #tmpPostBillData)
		--	GROUP BY B.intTransactionId
		--) AppliedPayments
		--EXEC uspAPUpdatePrepayAndDebitMemo @validBillIds, 0

		-- IF EXISTS(SELECT 1 FROM @adjustedEntries)
		-- BEGIN
		-- 	--Unpost Cost Adjustment
		-- 	DECLARE @billsToUnpost AS Id
		-- 	INSERT INTO @billsToUnpost
		-- 	SELECT DISTINCT intTransactionId FROM @adjustedEntries

		-- 	EXEC uspAPUnpostCostAdjustmentGL  @billsToUnpost, @batchId, @userId
		-- END

		UPDATE tblGLDetail
		SET ysnIsUnposted = 1
		WHERE 
			tblGLDetail.[strTransactionId] IN (SELECT strBillId FROM tblAPBill WHERE intBillId IN (SELECT intBillId FROM #tmpPostBillData))
			AND strCode <> 'ICA'

		--Update Inventory Item Receipt
		--  UPDATE A
		--  	SET A.dblBillQty = A.dblBillQty - B.dblQtyReceived --(CASE WHEN C.intTransactionType != 1 THEN B.dblQtyReceived * -1 ELSE B.dblQtyReceived END)
		--  FROM tblICInventoryReceiptItem A
		--  	INNER JOIN tblAPBillDetail B ON B.[intInventoryReceiptItemId] = A.intInventoryReceiptItemId
		--  	INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
		--  AND B.intBillId IN (SELECT [intBillId] FROM #tmpPostBillData) AND B.intInventoryReceiptChargeId IS NULL

		-- --UPDATE CHARGES (Accrue)
		--  UPDATE	Charge
		--  SET		Charge.dblAmountBilled = ISNULL(Charge.dblAmountBilled, 0) - BillDetail.dblTotal
		--  		,Charge.dblQuantityBilled = ISNULL(Charge.dblQuantityBilled, 0) - BillDetail.dblQtyReceived
		--  FROM	tblAPBill Bill INNER JOIN tblAPBillDetail BillDetail 
		--  			ON Bill.intBillId = BillDetail.intBillId
		--  		INNER JOIN #tmpPostBillData
		--  			ON #tmpPostBillData.intBillId = Bill.intBillId
		--  		INNER JOIN tblICInventoryReceiptCharge Charge 
		--  			ON BillDetail.[intInventoryReceiptChargeId] = Charge.intInventoryReceiptChargeId
		--  			AND Charge.intEntityVendorId = Bill.intEntityVendorId
		--  WHERE	BillDetail.dblTotal > 0 

		--  --UPDATE CHARGES (Price)
		--  UPDATE	Charge
		--  SET		Charge.dblAmountPriced = ISNULL(Charge.dblAmountPriced, 0) - BillDetail.dblTotal
		--  		,Charge.dblQuantityPriced = ISNULL(Charge.dblQuantityPriced, 0) - BillDetail.dblQtyReceived
		--  FROM	tblAPBill Bill INNER JOIN tblAPBillDetail BillDetail 
		--  			ON Bill.intBillId = BillDetail.intBillId
		--  		INNER JOIN #tmpPostBillData
		--  			ON #tmpPostBillData.intBillId = Bill.intBillId
		--  		INNER JOIN tblICInventoryReceiptCharge Charge 
		--  			ON BillDetail.[intInventoryReceiptChargeId] = Charge.intInventoryReceiptChargeId
		--  		INNER JOIN tblICInventoryReceipt Receipt
		--  			ON Receipt.intInventoryReceiptId = Charge.intInventoryReceiptId
		--  			AND Receipt.intEntityVendorId = Bill.intEntityVendorId
		--  WHERE	ISNULL(Charge.ysnPrice, 0) = 1
		--  		AND BillDetail.dblTotal < 0 

		--  --UPDATE CHARGES (Accrue) FROM INVENTORY SHIPMENT
		--  UPDATE	Charge
		--  SET		Charge.dblAmountBilled = ISNULL(Charge.dblAmountBilled, 0) - BillDetail.dblTotal
		--  		,Charge.dblQuantityBilled = ISNULL(Charge.dblQuantityBilled, 0) - BillDetail.dblQtyReceived
		--  FROM	tblAPBill Bill INNER JOIN tblAPBillDetail BillDetail 
		--  			ON Bill.intBillId = BillDetail.intBillId
		--  		INNER JOIN #tmpPostBillData
		--  			ON #tmpPostBillData.intBillId = Bill.intBillId
		--  		INNER JOIN tblICInventoryShipmentCharge Charge 
		--  			ON BillDetail.[intInventoryShipmentChargeId] = Charge.intInventoryShipmentChargeId
		--  			AND Charge.intEntityVendorId = Bill.intEntityVendorId
		--  WHERE	BillDetail.dblTotal > 0 

		--UPDATE CONTRACT COST
		UPDATE  CC
			SET     CC.dblActualAmount = ISNULL(CC.dblActualAmount,0) - tblBilled.dblTotal
		FROM tblCTContractCost CC
		JOIN ( 
			SELECT Bill.intContractCostId, SUM(Bill.dblTotal) dblTotal 
			FROM tblAPBillDetail Bill
			INNER JOIN #tmpPostBillData
						ON #tmpPostBillData.intBillId = Bill.intBillId
			WHERE Bill.intContractCostId > 0 
			GROUP BY intContractCostId
		) tblBilled ON tblBilled.intContractCostId = CC.intContractCostId

		--Insert Successfully unposted transactions.
		INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT
			@UnpostSuccessfulMsg,
			'Bill',
			A.strBillId,
			@batchId,
			A.intBillId
		FROM tblAPBill A
		WHERE intBillId IN (SELECT intBillId FROM #tmpPostBillData)

		--GOTO Audit_Log_Invoke
	END
	ELSE
	BEGIN
		UPDATE tblAPBill
			SET ysnPosted = 1, intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
		WHERE tblAPBill.intBillId IN (SELECT intBillId FROM #tmpPostBillData)

		IF EXISTS(SELECT TOP 1 intBillBatchId FROM dbo.tblAPBill WHERE intBillId IN (SELECT intBillId FROM #tmpPostBillData))
		BEGIN
			SET @billBatchId = (SELECT TOP 1 intBillBatchId FROM dbo.tblAPBill WHERE intBillId IN (SELECT intBillId FROM #tmpPostBillData))
			DECLARE @ctr INT;
			SELECT @ctr = (CASE COUNT(DISTINCT ysnPosted) WHEN 1 THEN 1 ELSE 0 END)
			FROM tblAPBill A  WHERE intBillBatchId = @billBatchId

			IF(@ctr = 1)
			BEGIN
				UPDATE tblAPBillBatch
				SET ysnPosted = 1
				FROM tblAPBillBatch WHERE intBillBatchId IN (@billBatchId)
			END
			ELSE
			BEGIN
				UPDATE tblAPBillBatch
				SET ysnPosted = 0
				FROM tblAPBillBatch WHERE intBillBatchId IN (@billBatchId)
			END          
		END 
		--UPDATE amount due of vendor prepayment, debit memo and overpayment once payment has been applied to bill
		--UPDATE A
		--	SET dblAmountDue = A.dblAmountDue - AppliedPayments.dblAmountApplied
		--	,dblPayment = dblPayment + AppliedPayments.dblAmountApplied
		--	,ysnPaid = CASE WHEN (A.dblAmountDue - AppliedPayments.dblAmountApplied) = 0 THEN 1 ELSE 0 END
		--FROM tblAPBill A
		--CROSS APPLY
		--(
		--	SELECT 
		--		SUM(B.dblAmountApplied) AS dblAmountApplied
		--	FROM tblAPAppliedPrepaidAndDebit B
		--		--INNER JOIN tblAPBill C ON B.intTransactionId = C.intBillId
		--	WHERE A.intBillId = B.intTransactionId
		--	AND B.intBillId IN (SELECT intBillId FROM #tmpPostBillData)	--make sure update only those prepayments of the current bills
		--	GROUP BY B.intTransactionId
		--) AppliedPayments
		--EXEC uspAPUpdatePrepayAndDebitMemo @validBillIds, 1

		--DELETE THE RECORDS THAT HAS NOT BEEN USED FOR APPLYING IF POSTING
		DELETE A
		FROM tblAPAppliedPrepaidAndDebit A
		INNER JOIN #tmpPostBillData B ON A.intBillId = B.intBillId
		WHERE A.dblAmountApplied = 0 AND A.ysnApplied = 0

		--If Prepaid was made the bill fully paid, update the ysnPaid to 1
		UPDATE A
			SET A.ysnPaid = (CASE WHEN A.dblAmountDue = 0 THEN 1 ELSE 0 END)
		FROM tblAPBill A
		WHERE A.intBillId IN (SELECT intBillId FROM #tmpPostBillData)

		--Update Inventory Item Receipt
		--  UPDATE A
		--  	SET A.dblBillQty = A.dblBillQty + B.dblQtyReceived
		--  FROM tblICInventoryReceiptItem A
		--  	INNER JOIN tblAPBillDetail B ON B.[intInventoryReceiptItemId] = A.intInventoryReceiptItemId
		--  AND B.intBillId IN (SELECT [intBillId] FROM #tmpPostBillData)  AND B.intInventoryReceiptChargeId IS NULL

		--  --UPDATE CHARGES (Accrue)
		--  UPDATE	Charge
		--  SET		Charge.dblAmountBilled = ISNULL(Charge.dblAmountBilled, 0) + BillDetail.dblTotal
		--  		,Charge.dblQuantityBilled = ISNULL(Charge.dblQuantityBilled, 0) + BillDetail.dblQtyReceived
		--  FROM	tblAPBill Bill INNER JOIN tblAPBillDetail BillDetail 
		--  			ON Bill.intBillId = BillDetail.intBillId
		--  		INNER JOIN #tmpPostBillData
		--  			ON #tmpPostBillData.intBillId = Bill.intBillId
		--  		INNER JOIN tblICInventoryReceiptCharge Charge 
		--  			ON BillDetail.[intInventoryReceiptChargeId] = Charge.intInventoryReceiptChargeId
		--  			AND Charge.intEntityVendorId = Bill.intEntityVendorId
		--  WHERE	BillDetail.dblTotal > 0 

		--  -- --UPDATE CHARGES (Price)
		--  UPDATE	Charge
		--  SET		Charge.dblAmountPriced = ISNULL(Charge.dblAmountPriced, 0) + BillDetail.dblTotal
		--  		,Charge.dblQuantityPriced = ISNULL(Charge.dblQuantityPriced, 0) + BillDetail.dblQtyReceived
		--  FROM	tblAPBill Bill INNER JOIN tblAPBillDetail BillDetail 
		--  			ON Bill.intBillId = BillDetail.intBillId
		--  		INNER JOIN #tmpPostBillData
		--  			ON #tmpPostBillData.intBillId = Bill.intBillId
		--  		INNER JOIN tblICInventoryReceiptCharge Charge 
		--  			ON BillDetail.[intInventoryReceiptChargeId] = Charge.intInventoryReceiptChargeId
		--  		INNER JOIN tblICInventoryReceipt Receipt
		--  			ON Receipt.intInventoryReceiptId = Charge.intInventoryReceiptId
		--  			AND Receipt.intEntityVendorId = Bill.intEntityVendorId
		--  WHERE	ISNULL(Charge.ysnPrice, 0) = 1
		--  		AND BillDetail.dblTotal < 0 

		--  --UPDATE CHARGES (Accrue) FROM INVENTORY SHIPMENT
		--  UPDATE	Charge
		--  SET		Charge.dblAmountBilled = ISNULL(Charge.dblAmountBilled, 0) + BillDetail.dblTotal
		--  		,Charge.dblQuantityBilled = ISNULL(Charge.dblQuantityBilled, 0) + BillDetail.dblQtyReceived
		--  FROM	tblAPBill Bill INNER JOIN tblAPBillDetail BillDetail 
		--  			ON Bill.intBillId = BillDetail.intBillId
		--  		INNER JOIN #tmpPostBillData
		--  			ON #tmpPostBillData.intBillId = Bill.intBillId
		--  		INNER JOIN tblICInventoryShipmentCharge Charge 
		--  			ON BillDetail.[intInventoryShipmentChargeId] = Charge.intInventoryShipmentChargeId
		--  			AND Charge.intEntityVendorId = Bill.intEntityVendorId
		--  WHERE	BillDetail.dblTotal > 0 				
		
		UPDATE  CC
			SET     CC.dblActualAmount = ISNULL(CC.dblActualAmount,0) + tblBilled.dblTotal
		FROM tblCTContractCost CC
		JOIN ( 
			SELECT Bill.intContractCostId, SUM(Bill.dblTotal) dblTotal 
			FROM tblAPBillDetail Bill
			INNER JOIN #tmpPostBillData
						ON #tmpPostBillData.intBillId = Bill.intBillId
			WHERE Bill.intContractCostId > 0 
			GROUP BY intContractCostId
		) tblBilled ON tblBilled.intContractCostId = CC.intContractCostId

		--Insert Successfully posted transactions.
		INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT 
			@PostSuccessfulMsg,
			'Bill',
			A.strBillId,
			@batchId,
			A.intBillId
		FROM tblAPBill A
		WHERE intBillId IN (SELECT intBillId FROM #tmpPostBillData)

	END

	BEGIN TRY

		--PATRONAGE 
		/*DECLARE @patVoucherId INT, @patVoucherVendorId INT;
		DECLARE @patVoucherIds AS Id;
		INSERT INTO @patVoucherIds
		SELECT intBillId FROM #tmpPostBillData
		
		WHILE EXISTS(SELECT 1 FROM @patVoucherIds)
		BEGIN
			SELECT TOP 1 
				@patVoucherId = B.intBillId,
				@patVoucherVendorId = B.intEntityVendorId
			FROM @patVoucherIds A INNER JOIN tblAPBill B ON A.intId = B.intBillId

			EXEC uspPATBillToCustomerVolume @patVoucherVendorId, @patVoucherId, @post

			DELETE FROM @patVoucherIds WHERE intId = @patVoucherId;
		END*/
		EXEC uspPATGatherVolumeForPatronage @validBillIds, @post , 1 

		--UPDATE PO Status
		-- IF EXISTS(SELECT 1 FROM tblAPBillDetail A INNER JOIN tblICItem B 
		-- 			ON A.intItemId = B.intItemId 
		-- 			WHERE B.strType IN ('Service','Software','Non-Inventory','Other Charge')
		-- 			AND A.intBillId IN (SELECT intBillId FROM #tmpPostBillData)
		-- 			AND A.[intPurchaseDetailId] > 0)
		-- BEGIN
		-- 	DECLARE @countReceivedMisc INT = 0, @billIdReceived INT;
		-- 	DECLARE @miscItemId TABLE(intBillId INT);
		-- 	INSERT INTO @miscItemId
		-- 	SELECT intBillId FROM #tmpPostBillData
		-- 	WHILE @countReceivedMisc != @totalRecords
		-- 	BEGIN
		-- 		SET @countReceivedMisc = @countReceivedMisc + 1;
		-- 		SELECT TOP(1) @billIdReceived = intBillId FROM @miscItemId
		-- 		EXEC [uspPOReceivedMiscItem] @billIdReceived
		-- 		DELETE FROM @miscItemId WHERE intBillId = @billIdReceived
		-- 	END
		-- END
	END TRY
	BEGIN CATCH
		DECLARE @integrationError NVARCHAR(200) = ERROR_MESSAGE()
		RAISERROR(@integrationError, 16, 1);
		GOTO Post_Rollback
	END CATCH

	-- BEGIN TRY
	-- 	--UPDATE VOUCHER PAYABLE STAGING QTY
	-- 	--FOR NOW, SUPPORT ONLY FOR MISC PO
	-- 	EXEC uspAPUpdateVoucherPayableQty @voucherPayable = @voucherPayables, @post = @post, @throwError = 0
	-- END TRY
	-- BEGIN CATCH
	-- 	DECLARE @errorUpdateVoucherPayable NVARCHAR(200) = ERROR_MESSAGE()
	-- 	RAISERROR('Error updating voucher staging data.', 16, 1);
	-- 	GOTO Post_Rollback
	-- END CATCH
	
	BEGIN TRY
		EXEC uspAPUpdateVoucherHistory @voucherIds = @voucherBillId, @post = @post
	END TRY
	BEGIN CATCH
		DECLARE @errorUpdateVoucherHistory NVARCHAR(200) = ERROR_MESSAGE()
		RAISERROR('Error updating voucher history.', 16, 1);
		GOTO Post_Rollback
	END CATCH
	--GOTO Audit_Log_Invoke
	IF @@ERROR <> 0	GOTO Post_Rollback;

END
ELSE
	BEGIN

		ROLLBACK TRANSACTION; --ROLLBACK CHANGES MADE FROM OTHER STORED PROCEDURE e.g. cost adjustment, batch id
		--TODO:
		--DELETE TABLE PER Session
		DELETE FROM tblGLPostRecap
		WHERE strBatchId = @batchIdUsed
		--WHERE intTransactionId IN (SELECT intBillId FROM #tmpPostBillData) AND strModuleName = 'Accounts Payable';

		INSERT INTO tblGLPostRecap(
			 [strTransactionId]
			,[intTransactionId]
			,[intAccountId]
			,[strDescription]
			,[strJournalLineDescription]
			,[strReference]	
			,[intCurrencyId]
			,[dtmTransactionDate]
			,[dblDebit]
			,[dblCredit]
			,[dblDebitUnit]
			,[dblCreditUnit]
			,[dtmDate]
			,[ysnIsUnposted]
			,[intConcurrencyId]	
			,[dblExchangeRate]
			,[intUserId]
			,[dtmDateEntered]
			,[strBatchId]
			,[strCode]
			,[strModuleName]
			,[strTransactionForm]
			,[strTransactionType]
			,[strAccountId]
			,[strAccountGroup]
			,[dblDebitForeign]
			,[dblCreditForeign]
			,[strRateType]
			
		)
		SELECT
			[strTransactionId]
			,A.[intTransactionId]
			,A.[intAccountId]
			,A.[strDescription]
			,A.[strJournalLineDescription]
			,A.[strReference]	
			,A.[intCurrencyId]
			,A.[dtmTransactionDate]
			,Debit.Value
			,Credit.Value
			,DebitUnit.Value
			,CreditUnit.Value
			,A.[dtmDate]
			,A.[ysnIsUnposted]
			,A.[intConcurrencyId]	
			,A.[dblForeignRate]
			,A.[intUserId]
			,A.[dtmDateEntered]
			,A.[strBatchId]
			,A.[strCode]
			,A.[strModuleName]
			,A.[strTransactionForm]
			,A.[strTransactionType]
			,B.strAccountId
			,C.strAccountGroup
			,DebitForeign.Value
			,CreditForeign.Value
			,forex.[strCurrencyExchangeRateType]           
		FROM @GLEntries A
		INNER JOIN dbo.tblGLAccount B 
			ON A.intAccountId = B.intAccountId
		INNER JOIN dbo.tblGLAccountGroup C
			ON B.intAccountGroupId = C.intAccountGroupId
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0))  Credit
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitForeign, 0) - ISNULL(A.dblCreditForeign, 0)) DebitForeign
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitForeign, 0) - ISNULL(A.dblCreditForeign, 0))  CreditForeign
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) DebitUnit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0))  CreditUnit
		LEFT JOIN tblSMCurrencyExchangeRateType forex ON forex.intCurrencyExchangeRateTypeId = A.intCurrencyExchangeRateTypeId
		
		IF @@ERROR <> 0	GOTO Post_Rollback;

		SET @success = 1
		SET @successfulCount = @totalRecords
		RETURN;

	END

IF @@ERROR <> 0	GOTO Post_Rollback;

--=====================================================================================================================================
-- 	RETURN TOTAL NUMBER OF VALID JOURNALS
---------------------------------------------------------------------------------------------------------------------------------------

--=====================================================================================================================================
-- 	FINALIZING STAGE
---------------------------------------------------------------------------------------------------------------------------------------
Audit_Log_Invoke:
DECLARE @strDescription AS NVARCHAR(100) 
  ,@actionType AS NVARCHAR(50)
  ,@billId AS NVARCHAR(50);
DECLARE @billCounter INT = 0;
SELECT @actionType = CASE WHEN @post = 0 THEN 'Unposted' ELSE 'Posted' END

WHILE(@billCounter != (@totalRecords))
BEGIN
	SELECT @billId = CAST((SELECT TOP (1) intBillId FROM #tmpPostBillData) AS NVARCHAR(50))

	EXEC dbo.uspSMAuditLog 
	   @screenName = 'AccountsPayable.view.Voucher'		-- Screen Namespace
	  ,@keyValue = @billId								-- Primary Key Value of the Voucher. 
	  ,@entityId = @userId									-- Entity Id.
	  ,@actionType = @actionType                        -- Action Type
	  ,@changeDescription = @strDescription				-- Description
	  ,@fromValue = ''									-- Previous Value
	  ,@toValue = ''									-- New Value

  SET @billCounter = @billCounter + 1
  DELETE FROM #tmpPostBillData WHERE intBillId = @billId
END

Post_Commit:
	COMMIT TRANSACTION
	SET @success = 1
	SET @successfulCount = @totalRecords
	--SELECT * FROM #tmpPostBillData
	GOTO Post_Cleanup
	GOTO Post_Exit

Post_Rollback:
	ROLLBACK TRANSACTION	
	SET @success = 0
	GOTO Post_Exit

Post_Cleanup:
	IF(ISNULL(@recap,0) = 0)
	BEGIN

		IF(@post = 1)
		BEGIN
			--clean gl detail recap after posting
			DELETE FROM tblGLPostRecap
			FROM tblGLPostRecap A
			INNER JOIN #tmpPostBillData B ON A.intTransactionId = B.intBillId 
		END

	END

Post_Exit:
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpPostBillData')) DROP TABLE #tmpPostBillData
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpInvalidBillData')) DROP TABLE #tmpInvalidBillData
