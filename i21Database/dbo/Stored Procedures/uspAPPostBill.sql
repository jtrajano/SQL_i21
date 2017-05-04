CREATE PROCEDURE uspAPPostBill
	@batchId			AS NVARCHAR(40)		= NULL,
	@billBatchId		AS NVARCHAR(40)		= NULL,
	@transactionType	AS NVARCHAR(30)		= NULL,
	@post				AS BIT				= 0,
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
	@recapId			AS NVARCHAR(250)	= NEWID OUTPUT
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
	[strError] [NVARCHAR](200),
	[strTransactionType] [NVARCHAR](50),
	[strTransactionId] [NVARCHAR](50),
	[intTransactionId] INT
);

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId

--DECLARRE VARIABLES
DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @GLEntries AS RecapTableType 
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Payable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Bill'
DECLARE @validBillIds NVARCHAR(MAX)
DECLARE @billIds NVARCHAR(MAX)
DECLARE @totalRecords INT

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
	SELECT B.intBillId FROM tblAPBillBatch A
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

--=====================================================================================================================================
-- 	GET ALL INVALID TRANSACTIONS
---------------------------------------------------------------------------------------------------------------------------------------
IF (ISNULL(@recap, 0) = 0)
BEGIN

	--VALIDATIONS
	INSERT INTO #tmpInvalidBillData 
	SELECT * FROM fnAPValidatePostBill(@billIds, @post)

END
ELSE
BEGIN

	--VALIDATIONS
	INSERT INTO #tmpInvalidBillData 
	SELECT * FROM fnAPValidateRecapBill(@billIds, @post)
	
END

DECLARE @totalInvalid INT = 0
SELECT @totalInvalid = COUNT(*) FROM #tmpInvalidBillData

IF(@totalInvalid > 0)
BEGIN

	--Insert Invalid Post transaction result
	INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
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
	SET @success = 0
	GOTO Post_Exit
END

BEGIN TRANSACTION

--CREATE TEMP GL ENTRIES
SELECT @validBillIds = COALESCE(@validBillIds + ',', '') +  CONVERT(VARCHAR(12),intBillId)
FROM #tmpPostBillData
ORDER BY intBillId

--CREATE DATA FOR COST ADJUSTMENT
DECLARE @adjustedEntries AS ItemCostAdjustmentTableType

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
	,[intFobPointId]
	,[intInTransitSourceLocationId]
)
SELECT
		[intItemId]							=	B.intItemId
		,[intItemLocationId]				=	D.intItemLocationId
		,[intItemUOMId]						=   itemUOM.intItemUOMId
		,[dtmDate] 							=	A.dtmDate
		,[dblQty] 							=	CASE WHEN B.intWeightUOMId IS NULL THEN B.dblQtyReceived ELSE B.dblNetWeight END 
		,[dblUOMQty] 						=	itemUOM.dblUnitQty
		,[intCostUOMId]						=	voucherCostUOM.intItemUOMId 
		,[dblNewCost] 						=	CASE WHEN A.intCurrencyId <> @intFunctionalCurrencyId THEN 
														-- Convert the voucher cost to the functional currency. 
														dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId, receiptCostUOM.intItemUOMId, B.dblCost) * ISNULL(B.dblRate, 0) 
													ELSE 
														dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId, receiptCostUOM.intItemUOMId, B.dblCost)
												END 
		,[intCurrencyId] 					=	@intFunctionalCurrencyId -- It is always in functional currency. 
		,[dblExchangeRate] 					=	1 -- Exchange rate is always 1. 
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
		,[intFobPointId]					=	fp.intFobPointId
		,[intInTransitSourceLocationId]		=	sourceLocation.intItemLocationId
FROM	tblAPBill A INNER JOIN tblAPBillDetail B
			ON A.intBillId = B.intBillId
		INNER JOIN (
			tblICInventoryReceipt E1 INNER JOIN tblICInventoryReceiptItem E2 
				ON E1.intInventoryReceiptId = E2.intInventoryReceiptId
			LEFT JOIN tblICItemLocation sourceLocation
				ON sourceLocation.intItemId = E2.intItemId
				AND sourceLocation.intLocationId = E1.intLocationId
			LEFT JOIN tblSMFreightTerms ft
				ON ft.intFreightTermId = E1.intFreightTermId
			LEFT JOIN tblICFobPoint fp
				ON fp.strFobPoint = ft.strFreightTerm
		)
			ON B.intInventoryReceiptItemId = E2.intInventoryReceiptItemId
		INNER JOIN tblICItem item 
			ON B.intItemId = item.intItemId
		INNER JOIN tblICItemLocation D
			ON D.intLocationId = A.intShipToId AND D.intItemId = item.intItemId
		LEFT JOIN tblICItemUOM itemUOM
			ON itemUOM.intItemUOMId = B.intUnitOfMeasureId
		LEFT JOIN tblICItemUOM voucherCostUOM
			ON voucherCostUOM.intItemUOMId = ISNULL(B.intCostUOMId, B.intUnitOfMeasureId)
		LEFT JOIN tblICItemUOM receiptCostUOM
			ON receiptCostUOM.intItemUOMId = ISNULL(E2.intCostUOMId, E2.intUnitMeasureId)
		LEFT JOIN tblICInventoryTransactionType transType
			ON transType.strName = 'Bill' -- 'Cost Adjustment'

WHERE	A.intBillId IN (SELECT intBillId FROM #tmpPostBillData)
		AND B.intInventoryReceiptChargeId IS NULL 
		-- Compare the cost used in Voucher against the IR cost. 
		-- Compare the ForexRate use in Voucher against IR Rate
		-- If there is a difference, add it to @adjustedEntries table variable. 
		AND (
			dbo.fnCalculateCostBetweenUOM(voucherCostUOM.intItemUOMId, receiptCostUOM.intItemUOMId, B.dblCost) <> E2.dblUnitCost
			OR E2.dblForexRate <> B.dblRate
		) 
		
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
	    strRateType 
	)
	SELECT     
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
	    strRateType 	 
	FROM dbo.fnAPCreateBillGLEntries(@validBillIds, @userId, @batchId)

	IF EXISTS(SELECT 1 FROM @adjustedEntries)
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
		)
		EXEC uspICPostCostAdjustment @adjustedEntries, @batchId, @userId
	END
END
ELSE
BEGIN

	DECLARE @Ids AS Id
	INSERT INTO @Ids
	SELECT intBillId FROM #tmpPostBillData

	INSERT INTO @GLEntries
	SELECT * FROM dbo.fnAPReverseGLEntries(@Ids, 'Bill', DEFAULT, @userId, @batchId)
END
--=====================================================================================================================================
-- 	CHECK IF THE PROCESS IS RECAP OR NOT
---------------------------------------------------------------------------------------------------------------------------------------
IF ISNULL(@recap, 0) = 0
BEGIN

	--handel error here as we do not get the error here
	IF @totalRecords = 1 AND @isBatch = 0
	BEGIN
		BEGIN TRY
		EXEC uspGLBookEntries @GLEntries, @post
		END TRY
		BEGIN CATCH
			DECLARE @error NVARCHAR(200) = ERROR_MESSAGE()
			RAISERROR(@error, 16, 1);
			GOTO Post_Rollback
		END CATCH
	END
	ELSE
	BEGIN
		EXEC uspGLBatchPostEntries @GLEntries, @batchId, @userId, @post
		DELETE A
		FROM #tmpPostBillData A
		INNER JOIN tblGLPostResult B ON A.intBillId = B.intTransactionId
		WHERE B.strDescription NOT LIKE '%success%' AND B.strBatchId = @batchId

		INSERT INTO tblAPPostResult(strMessage, strTransactionType, strTransactionId, intTransactionId)
		SELECT 
			A.strDescription
			,A.strTransactionType
			,A.strTransactionId
			,A.intTransactionId
		FROM tblGLPostResult A
		WHERE A.strBatchId = @batchId
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
				ysnPaid = 0
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
		EXEC uspAPUpdatePrepayAndDebitMemo @validBillIds, 0

		IF EXISTS(SELECT 1 FROM @adjustedEntries)
		BEGIN
			--Unpost Cost Adjustment
			DECLARE @billsToUnpost AS Id
			INSERT INTO @billsToUnpost
			SELECT DISTINCT intTransactionId FROM @adjustedEntries

			EXEC uspAPUnpostCostAdjustmentGL  @billsToUnpost, @batchId, @userId
		END

		UPDATE tblGLDetail
			SET ysnIsUnposted = 1
		WHERE tblGLDetail.[strTransactionId] IN (SELECT strBillId FROM tblAPBill WHERE intBillId IN 
				(SELECT intBillId FROM #tmpPostBillData))

		--Update Inventory Item Receipt
		UPDATE A
			SET A.dblBillQty = A.dblBillQty - B.dblQtyReceived --(CASE WHEN C.intTransactionType != 1 THEN B.dblQtyReceived * -1 ELSE B.dblQtyReceived END)
		FROM tblICInventoryReceiptItem A
			INNER JOIN tblAPBillDetail B ON B.[intInventoryReceiptItemId] = A.intInventoryReceiptItemId
			INNER JOIN tblAPBill C ON B.intBillId = C.intBillId
		AND B.intBillId IN (SELECT [intBillId] FROM #tmpPostBillData) AND B.intInventoryReceiptChargeId IS NULL

		--UPDATE CHARGES (Accrue)
		UPDATE	Charge
		SET		Charge.dblAmountBilled = Charge.dblAmountBilled - BillDetail.dblTotal
		FROM	tblAPBill Bill INNER JOIN tblAPBillDetail BillDetail 
					ON Bill.intBillId = BillDetail.intBillId
				INNER JOIN #tmpPostBillData
					ON #tmpPostBillData.intBillId = Bill.intBillId
				INNER JOIN tblICInventoryReceiptCharge Charge 
					ON BillDetail.[intInventoryReceiptChargeId] = Charge.intInventoryReceiptChargeId
					AND Charge.intEntityVendorId = Bill.intEntityVendorId
		WHERE	BillDetail.dblTotal > 0 

		--UPDATE CHARGES (Price)
		UPDATE	Charge
		SET		Charge.dblAmountPriced = Charge.dblAmountPriced - BillDetail.dblTotal
		FROM	tblAPBill Bill INNER JOIN tblAPBillDetail BillDetail 
					ON Bill.intBillId = BillDetail.intBillId
				INNER JOIN #tmpPostBillData
					ON #tmpPostBillData.intBillId = Bill.intBillId
				INNER JOIN tblICInventoryReceiptCharge Charge 
					ON BillDetail.[intInventoryReceiptChargeId] = Charge.intInventoryReceiptChargeId
				INNER JOIN tblICInventoryReceipt Receipt
					ON Receipt.intInventoryReceiptId = Charge.intInventoryReceiptId
					AND Receipt.intEntityVendorId = Bill.intEntityVendorId
		WHERE	ISNULL(Charge.ysnPrice, 0) = 1
				AND BillDetail.dblTotal < 0 
				

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
			SET ysnPosted = 1
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
		EXEC uspAPUpdatePrepayAndDebitMemo @validBillIds, 1

		--If Prepaid was made the bill fully paid, update the ysnPaid to 1
		UPDATE A
			SET A.ysnPaid = (CASE WHEN A.dblAmountDue = 0 THEN 1 ELSE 0 END)
		FROM tblAPBill A
		WHERE A.intBillId IN (SELECT intBillId FROM #tmpPostBillData)

		--Update Inventory Item Receipt
		UPDATE A
			SET A.dblBillQty = A.dblBillQty + B.dblQtyReceived
		FROM tblICInventoryReceiptItem A
			INNER JOIN tblAPBillDetail B ON B.[intInventoryReceiptItemId] = A.intInventoryReceiptItemId
		AND B.intBillId IN (SELECT [intBillId] FROM #tmpPostBillData)  AND B.intInventoryReceiptChargeId IS NULL

		--UPDATE CHARGES (Accrue)
		UPDATE	Charge
		SET		Charge.dblAmountBilled = Charge.dblAmountBilled + BillDetail.dblTotal
		FROM	tblAPBill Bill INNER JOIN tblAPBillDetail BillDetail 
					ON Bill.intBillId = BillDetail.intBillId
				INNER JOIN #tmpPostBillData
					ON #tmpPostBillData.intBillId = Bill.intBillId
				INNER JOIN tblICInventoryReceiptCharge Charge 
					ON BillDetail.[intInventoryReceiptChargeId] = Charge.intInventoryReceiptChargeId
					AND Charge.intEntityVendorId = Bill.intEntityVendorId
		WHERE	BillDetail.dblTotal > 0 

		--UPDATE CHARGES (Price)
		UPDATE	Charge
		SET		Charge.dblAmountPriced = Charge.dblAmountPriced + BillDetail.dblTotal
		FROM	tblAPBill Bill INNER JOIN tblAPBillDetail BillDetail 
					ON Bill.intBillId = BillDetail.intBillId
				INNER JOIN #tmpPostBillData
					ON #tmpPostBillData.intBillId = Bill.intBillId
				INNER JOIN tblICInventoryReceiptCharge Charge 
					ON BillDetail.[intInventoryReceiptChargeId] = Charge.intInventoryReceiptChargeId
				INNER JOIN tblICInventoryReceipt Receipt
					ON Receipt.intInventoryReceiptId = Charge.intInventoryReceiptId
					AND Receipt.intEntityVendorId = Bill.intEntityVendorId
		WHERE	ISNULL(Charge.ysnPrice, 0) = 1
				AND BillDetail.dblTotal < 0 
				
		
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
		IF EXISTS(SELECT 1 FROM tblAPBillDetail A INNER JOIN tblICItem B 
					ON A.intItemId = B.intItemId 
					WHERE B.strType IN ('Service','Software','Non-Inventory','Other Charge')
					AND A.intBillId IN (SELECT intBillId FROM #tmpPostBillData)
					AND A.[intPurchaseDetailId] > 0)
		BEGIN
			DECLARE @countReceivedMisc INT = 0, @billIdReceived INT;
			WHILE @countReceivedMisc != @totalRecords
			BEGIN
				SET @countReceivedMisc = @countReceivedMisc + 1;
				SELECT TOP(1) @billIdReceived = intBillId FROM #tmpPostBillData
				EXEC [uspPOReceivedMiscItem] @billIdReceived
				DELETE FROM #tmpPostBillData WHERE intBillId = @billIdReceived
			END
		END

	END TRY
	BEGIN CATCH
		DECLARE @integrationError NVARCHAR(200) = ERROR_MESSAGE()
		RAISERROR(@integrationError, 16, 1);
		GOTO Post_Rollback
	END CATCH

	--GOTO Audit_Log_Invoke
	IF @@ERROR <> 0	GOTO Post_Rollback;

END
ELSE
	BEGIN

		ROLLBACK TRANSACTION; --ROLLBACK CHANGES MADE FROM OTHER STORED PROCEDURE e.g. cost adjustment
		--TODO:
		--DELETE TABLE PER Session
		DELETE FROM tblGLDetailRecap
			WHERE intTransactionId IN (SELECT intBillId FROM #tmpPostBillData);

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
			,A.[dblDebitUnit]
			,A.[dblCreditUnit]
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
			,A.[strRateType]           
		FROM @GLEntries A
		INNER JOIN dbo.tblGLAccount B 
			ON A.intAccountId = B.intAccountId
		INNER JOIN dbo.tblGLAccountGroup C
			ON B.intAccountGroupId = C.intAccountGroupId
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0))  Credit
		CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitForeign, 0) - ISNULL(A.dblCreditForeign, 0)) DebitForeign
		CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitForeign, 0) - ISNULL(A.dblCreditForeign, 0))  CreditForeign;
		
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
