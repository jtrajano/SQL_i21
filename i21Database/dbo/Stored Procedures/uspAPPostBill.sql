﻿CREATE PROCEDURE uspAPPostBill
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
SET ANSI_WARNINGS ON

IF @userId IS NULL
BEGIN
	RAISERROR('User is required', 16, 1);
	RETURN;
END

IF NULLIF(@param, '') IS NULL AND NULLIF(@billBatchId, '') IS NULL
BEGIN
	RAISERROR('@param is empty. No voucher to post.', 16, 1);
	RETURN;
END

-- Start the transaction 
BEGIN TRANSACTION

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
DECLARE @GLEntriesTemp AS RecapTableType 
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
DECLARE @billIdsInventoryLog AS Id;

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

DECLARE @idForPost As Id;
--INSERT BILL THAT IS NOT YET IN tblAPBillForPosting
--DO NOT ALLOW PARALLEL EXECUTION OF POSTING TO INSERT WHILE INSERT IS NOT DONE
--THE LOCK WILL RELEASE ON COMMIT/ROLLBACK TRANSACTION
INSERT INTO tblAPBillForPosting WITH(TABLOCKX)(intBillId, ysnIsPost)
OUTPUT inserted.intBillId INTO @idForPost
SELECT 
	A.intBillId 
	,@post
FROM #tmpPostBillData A
LEFT JOIN tblAPBillForPosting B ON A.intBillId = B.intBillId
WHERE B.intId IS NULL

--GET ALL intBillId WHICH IS ALREADY IN tblAPBillForPosting
--BUT uspAPPostBill calls again for the same intBillId
--DELETE THE intBillId ON THE LIST OF FOR POST VOUCHERS
--THAT IS ALREADY PART OF tblAPBillForPosting
DELETE A  
FROM #tmpPostBillData A  
LEFT JOIN @idForPost B ON A.intBillId = B.intId  
LEFT JOIN tblAPBill C ON A.intBillId = C.intBillId
WHERE B.intId IS NULL OR (C.ysnPosted = 1 AND @post = 1) OR (C.ysnPosted = 0 AND @post = 0)

--SET THE UPDATED @billIds
SELECT @billIds = COALESCE(@billIds + ',', '') +  CONVERT(VARCHAR(12),intBillId)
FROM #tmpPostBillData
ORDER BY intBillId

IF NULLIF(@billIds, '') IS NULL
BEGIN
	RAISERROR('Posting/unposting already in process or already posted.', 16, 1);
	GOTO Post_Rollback
END

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

	--.Net is sending default value if parameter is not provided
	IF ISNULL(NULLIF(@transactionType,''),'') = ''
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
	-- UNION ALL
	-- SELECT
	-- 	strError
	-- 	,strTransactionType
	-- 	,strTransactionNo
	-- 	,intTransactionId
	-- 	,27
	-- FROM dbo.[fnGRValidateBillPost](@billIds, @post, @transactionType)
	
	--if there are invalid applied amount, undo updating of amountdue and payment
	IF EXISTS(SELECT 1 FROM #tmpInvalidBillData)
	BEGIN
		DECLARE @invalidAmountAppliedIds NVARCHAR(MAX);
		--undo updating of transactions for those invalid only
		SELECT DISTINCT
			@invalidAmountAppliedIds = COALESCE(@invalidAmountAppliedIds + ',', '') +  CONVERT(VARCHAR(12),intTransactionId)
		FROM #tmpInvalidBillData
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

IF EXISTS(SELECT 1 FROM #tmpPostBillData)
BEGIN
	--CREATE TEMP GL ENTRIES
	SELECT @validBillIds = COALESCE(@validBillIds + ',', '') +  CONVERT(VARCHAR(12),intBillId)
	FROM #tmpPostBillData
	ORDER BY intBillId

	EXEC uspAPUpdateAccountOnPost @validBillIds
END

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

BEGIN TRANSACTION

--START LOCKING THE VOUCHER RECORD BEING POSTED
UPDATE A
SET A.intConcurrencyId = ISNULL(A.intConcurrencyId,0) + 1
FROM tblAPBill A
INNER JOIN #tmpPostBillData B ON A.intBillId = B.intBillId

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

-- Call Starting number for Receipt Detail Update to prevent deadlocks. 
BEGIN
	DECLARE @strUpdateRIDetail AS NVARCHAR(50)
	EXEC uspSMGetStartingNumber 155 ,@strUpdateRIDetail OUTPUT
END 

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
FROM dbo.fnAPCreateReceiptItemCostAdjustment(@voucherIds, @intFunctionalCurrencyId)

-- Remove zero cost adjustments. 
DELETE FROM @adjustedEntries WHERE ROUND(dblNewValue, 2) = 0 

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
	A.intBillId IN (SELECT intBillId FROM #tmpPostBillData)
	AND B.intInventoryReceiptChargeId IS NOT NULL 
	AND rc.ysnInventoryCost = 1 --create cost adjustment entries for Inventory only for inventory cost yes
	AND (
		(B.dblCost <> (CASE WHEN rc.strCostMethod IN ('Amount','Percentage') THEN rc.dblAmount ELSE rc.dblRate END))
		OR ISNULL(NULLIF(rc.dblForexRate,0),1) <> B.dblRate
	)
	AND A.intTransactionReversed IS NULL
	AND A.intTransactionType IN (1)
UNION ALL
SELECT 
	[intInventoryReceiptChargeId] = rc.intInventoryReceiptChargeId
	,[dblNewValue] =
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
			ELSE
				-- Formula: 
				-- 1. {Voucher Other Charge} minus {IR Other Charge} 
					CAST(
						(B.dblQtyReceived * B.dblCost)  
						AS DECIMAL(18,2)
					)
		END 
	,[dblNewForexValue] =
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
			ELSE
				-- Formula: 
				-- 1. {Voucher Other Charge} minus {IR Other Charge} 
				CAST(
					(B.dblQtyReceived * B.dblCost )  
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
FROM tblAPBill A 
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN (
	tblICInventoryReceipt r INNER JOIN tblICInventoryReceiptCharge rc 
		ON r.intInventoryReceiptId = rc.intInventoryReceiptId
) ON rc.intInventoryReceiptChargeId = B.intInventoryReceiptChargeId
WHERE A.intBillId IN (SELECT intBillId FROM #tmpPostBillData)
AND B.intInventoryReceiptChargeId IS NOT NULL 
AND rc.ysnInventoryCost = 1
AND A.intTransactionReversed IS NULL
AND A.intTransactionType IN (3)

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

DECLARE @ItemsForInTransitCosting AS ItemInTransitCostingTableType
DECLARE @ValueToPost AS ItemInTransitValueOnlyTableType
INSERT INTO @ValueToPost (
	[intItemId] 
	,[intOtherChargeItemId]
	,[intItemLocationId] 
	,[dtmDate] 
	,[dblValue] 
	,[intTransactionId] 
	,[intTransactionDetailId] 
	,[strTransactionId] 
	,[intTransactionTypeId] 
	,[intLotId] 
	,[intSourceTransactionId] 
	,[strSourceTransactionId] 
	,[intSourceTransactionDetailId] 
	,[intFobPointId] 
	,[intInTransitSourceLocationId] 
	,[intCurrencyId] 
	,[intForexRateTypeId] 
	,[dblForexRate] 
	,[intSourceEntityId] 
	,[strSourceType] 
	,[strSourceNumber] 
	,[strBOLNumber] 
	,[intTicketId]
)
SELECT 
	[intItemId] = LD.intItemId
	,[intOtherChargeItemId] = BD.intItemId
	,[intItemLocationId] = IL.intItemLocationId
	,[dtmDate] = B.dtmDate
	,[dblValue] = BD.dblTotal
	,[intTransactionId] = B.intBillId
	,[intTransactionDetailId] = BD.intBillDetailId
	,[strTransactionId] = B.strBillId
	,[intTransactionTypeId] = 27 --Voucher
	,[intLotId] = NULL
	,[intSourceTransactionId] = L.intLoadId
	,[strSourceTransactionId] = L.strLoadNumber
	,[intSourceTransactionDetailId] = LD.intLoadDetailId
	,[intFobPointId] = FP.intFobPointId
	,[intInTransitSourceLocationId] = IL.intItemLocationId
	,[intCurrencyId] = B.intCurrencyId
	,[intForexRateTypeId] = BD.intCurrencyExchangeRateTypeId
	,[dblForexRate] = BD.dblRate
	,[intSourceEntityId] = NULL
	,[strSourceType] = NULL
	,[strSourceNumber] = NULL 
	,[strBOLNumber] = NULL 
	,[intTicketId] = NULL 
FROM @voucherIds IDS
INNER JOIN tblAPBill B ON B.intBillId = IDS.intId
INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
INNER JOIN tblLGLoadCost LC ON LC.intLoadCostId = BD.intLoadShipmentCostId
INNER JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
INNER JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
INNER JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId AND IL.intLocationId = LD.intPCompanyLocationId
LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = B.intFreightTermId
LEFT JOIN tblICFobPoint FP ON FP.strFobPoint = FT.strFobPoint
WHERE ISNULL(LC.ysnInventoryCost, 0) = 1 AND BD.intLoadShipmentCostId IS NOT NULL AND BD.intInventoryReceiptChargeId IS NULL AND B.intTransactionType IN (1)
UNION ALL
SELECT 
	[intItemId] = LD.intItemId
	,[intOtherChargeItemId] = BD.intItemId
	,[intItemLocationId] = IL.intItemLocationId
	,[dtmDate] = B.dtmDate
	,[dblValue] = LC.dblAmount * -1
	,[intTransactionId] = B.intBillId
	,[intTransactionDetailId] = BD.intBillDetailId
	,[strTransactionId] = B.strBillId
	,[intTransactionTypeId] = 27 --Voucher
	,[intLotId] = NULL
	,[intSourceTransactionId] = L.intLoadId
	,[strSourceTransactionId] = L.strLoadNumber
	,[intSourceTransactionDetailId] = LD.intLoadDetailId
	,[intFobPointId] = FP.intFobPointId
	,[intInTransitSourceLocationId] = IL.intItemLocationId
	,[intCurrencyId] = B.intCurrencyId
	,[intForexRateTypeId] = BD.intCurrencyExchangeRateTypeId
	,[dblForexRate] = BD.dblRate
	,[intSourceEntityId] = NULL
	,[strSourceType] = NULL
	,[strSourceNumber] = NULL 
	,[strBOLNumber] = NULL 
	,[intTicketId] = NULL 
FROM @voucherIds IDS
INNER JOIN tblAPBill B ON B.intBillId = IDS.intId
INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
INNER JOIN tblLGLoadCost LC ON LC.intLoadCostId = BD.intLoadShipmentCostId
INNER JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
INNER JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
INNER JOIN tblICItemLocation IL ON IL.intItemId = LD.intItemId AND IL.intLocationId = LD.intPCompanyLocationId
LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = B.intFreightTermId
LEFT JOIN tblICFobPoint FP ON FP.strFobPoint = FT.strFobPoint
WHERE ISNULL(LC.ysnInventoryCost, 0) = 1 AND BD.intLoadShipmentCostId IS NOT NULL AND BD.intInventoryReceiptChargeId IS NULL AND B.intTransactionType IN (1)

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
		SourceCreditUnit.Value,
		SourceDebitUnit.Value,
		commodity.intCommodityId,
		intSourceLocationId	
	FROM dbo.fnAPCreateBillGLEntries(@validBillIds, @userId, @batchId) A
	CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0)) Debit
	CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebit, 0) - ISNULL(A.dblCredit, 0))  Credit
	CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitForeign, 0) - ISNULL(A.dblCreditForeign, 0)) DebitForeign
	CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitForeign, 0) - ISNULL(A.dblCreditForeign, 0))  CreditForeign
	CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0)) DebitUnit
	CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblDebitUnit, 0) - ISNULL(A.dblCreditUnit, 0))  CreditUnit
	CROSS APPLY dbo.fnGetDebit(ISNULL(A.dblSourceUnitDebit, 0) - ISNULL(A.dblSourceUnitCredit, 0)) SourceDebitUnit
	CROSS APPLY dbo.fnGetCredit(ISNULL(A.dblSourceUnitDebit, 0) - ISNULL(A.dblSourceUnitCredit, 0))  SourceCreditUnit
	OUTER APPLY dbo.fnAPGetVoucherCommodity(A.intTransactionId) commodity
	ORDER BY intTransactionId

	DECLARE @intReturnValue AS INT 
	DECLARE @errorAdjustment NVARCHAR(200) 

	-- Call the Item's Transit Reversal
	IF EXISTS(SELECT 1 FROM @ValueToPost)
	BEGIN	
		BEGIN TRY
			EXEC @intReturnValue = dbo.uspICPostInTransitCosting  
					@ItemsForInTransitCosting  
					,@batchId  
					,NULL 
					,@userId
					,NULL
					,@ValueToPost

			INSERT INTO @GLEntriesTemp (
					[dtmDate] 
					,[strBatchId]
					,[intAccountId]
					,[dblDebit]
					,[dblCredit]
					,[dblDebitUnit]
					,[dblCreditUnit]
					,[strDescription]
					,[strCode]
					,[strReference]
					,[intCurrencyId]
					,[dblExchangeRate]
					,[dtmDateEntered]
					,[dtmTransactionDate]
					,[strJournalLineDescription]
					,[intJournalLineNo]
					,[ysnIsUnposted]
					,[intUserId]
					,[intEntityId]
					,[strTransactionId]					
					,[intTransactionId]
					,[strTransactionType]
					,[strTransactionForm] 
					,[strModuleName]
					,[intConcurrencyId]
					,[dblDebitForeign]
					,[dblDebitReport]
					,[dblCreditForeign]
					,[dblCreditReport]
					,[dblReportingRate]
					,[dblForeignRate]
					,[intSourceEntityId]
					,[intCommodityId]
					,[strRateType]
			)			
			EXEC @intReturnValue = dbo.uspICCreateGLEntriesOnInTransitValueAdjustment								
				@strBatchId = @batchId
				,@strTransactionId = NULL
				,@intEntityUserSecurityId = @userId
				,@strGLDescription = NULL
				,@AccountCategory_Cost_Adjustment = DEFAULT 

			--DELETE APC ACCOUNT IN CREDIT SIDE THIS IS SUPPOSED TO BE AP ACCOUNT BUT IC MODULE ASK US TO REMOVE IT AS AP ACCOUNT IS NOT HANDLED BY THEIR SP
			DELETE GL 
			FROM @GLEntriesTemp GL
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = GL.intAccountId
			WHERE AD.intAccountCategoryId = 45 AND GL.dblCredit <> 0

			INSERT INTO @GLEntries
			SELECT * FROM @GLEntriesTemp

			--CONVERT OTHER CHARGE CURRENCY TO ITEM CURRENCY
			DELETE GL 
			FROM @GLEntriesTemp GL
			INNER JOIN vyuGLAccountDetail AD ON AD.intAccountId = GL.intAccountId
			WHERE AD.intAccountCategoryId = 45
			
			--WASH OUT ENTRY
			INSERT INTO @GLEntries (
					[dtmDate] 
					,[strBatchId]
					,[intAccountId]
					,[dblDebit]
					,[dblCredit]
					,[dblDebitUnit]
					,[dblCreditUnit]
					,[strDescription]
					,[strCode]
					,[strReference]
					,[intCurrencyId]
					,[dblExchangeRate]
					,[dtmDateEntered]
					,[dtmTransactionDate]
					,[strJournalLineDescription]
					,[intJournalLineNo]
					,[ysnIsUnposted]
					,[intUserId]
					,[intEntityId]
					,[strTransactionId]					
					,[intTransactionId]
					,[strTransactionType]
					,[strTransactionForm] 
					,[strModuleName]
					,[intConcurrencyId]
					,[dblDebitForeign]
					,[dblDebitReport]
					,[dblCreditForeign]
					,[dblCreditReport]
					,[dblReportingRate]
					,[dblForeignRate]
					,[intSourceEntityId]
					,[intCommodityId]
					,[strRateType]
			)
			SELECT 	[dtmDate] 
					,[strBatchId]
					,[intAccountId]
					,[dblCredit]
					,[dblDebit]
					,[dblCreditUnit]
					,[dblDebitUnit]
					,[strDescription]
					,[strCode]
					,[strReference]
					,[intCurrencyId]
					,[dblExchangeRate]
					,[dtmDateEntered]
					,[dtmTransactionDate]
					,[strJournalLineDescription]
					,[intJournalLineNo]
					,[ysnIsUnposted]
					,[intUserId]
					,[intEntityId]
					,[strTransactionId]					
					,[intTransactionId]
					,[strTransactionType]
					,[strTransactionForm] 
					,[strModuleName]
					,[intConcurrencyId]
					,[dblCreditForeign]
					,[dblCreditReport]
					,[dblDebitForeign]
					,[dblDebitReport]
					,[dblReportingRate]
					,[dblForeignRate]
					,[intSourceEntityId]
					,[intCommodityId]
					,[strRateType]
			FROM @GLEntriesTemp
			UNION ALL
			SELECT 	[dtmDate] 
					,[strBatchId]
					,[intAccountId]
					,[dblDebit]
					,[dblCredit]
					,[dblDebitUnit]
					,[dblCreditUnit]
					,[strDescription]
					,[strCode]
					,[strReference]
					,LS.intPriceCurrencyId
					,ISNULL(FX.dblForexRate, 1)
					,[dtmDateEntered]
					,[dtmTransactionDate]
					,[strJournalLineDescription]
					,[intJournalLineNo]
					,[ysnIsUnposted]
					,[intUserId]
					,[intEntityId]
					,[strTransactionId]					
					,[intTransactionId]
					,[strTransactionType]
					,[strTransactionForm] 
					,[strModuleName]
					,[intConcurrencyId]
					,[dblDebitForeign] * ISNULL(ShipmentToChargeCurrency.dblForexRate, 1)
					,[dblDebitReport]
					,[dblCreditForeign] * ISNULL(ShipmentToChargeCurrency.dblForexRate, 1)
					,[dblCreditReport]
					,[dblReportingRate]
					,ISNULL(FX.dblForexRate, 1)
					,[intSourceEntityId]
					,[intCommodityId]
					,FX.strCurrencyExchangeRateType
			FROM @GLEntriesTemp GLEntries
			OUTER APPLY (
				SELECT TOP 1 intPriceCurrencyId
				FROM tblICInventoryTransaction IT
				INNER JOIN tblAPBillDetail BD ON BD.intBillDetailId = IT.intTransactionDetailId
				INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = BD.intLoadDetailId
				WHERE IT.intInventoryTransactionId = GLEntries.intJournalLineNo
			) LS
			OUTER APPLY (
			SELECT TOP 1 
					dblForexRate = ISNULL(dblRate, 0),
					strCurrencyExchangeRateType
				FROM vyuGLExchangeRate
				WHERE intFromCurrencyId = LS.intPriceCurrencyId
					AND intToCurrencyId = @intFunctionalCurrencyId
					AND intCurrencyExchangeRateTypeId = intCurrencyExchangeRateTypeId
				ORDER BY dtmValidFromDate DESC
			) FX
			OUTER APPLY (
				SELECT TOP 1
					dblForexRate = ISNULL(dblRate, 0),
					intCurrencyExchangeRateTypeId
				FROM vyuGLExchangeRate
				WHERE intFromCurrencyId = GLEntries.intCurrencyId
					AND intToCurrencyId = LS.intPriceCurrencyId
				ORDER BY dtmValidFromDate DESC
			) ShipmentToChargeCurrency
			WHERE LS.intPriceCurrencyId <> GLEntries.intCurrencyId

			UPDATE @GLEntries SET strModuleName = 'Accounts Payable'
		END TRY
		BEGIN CATCH
			SET @errorAdjustment = ERROR_MESSAGE()
			RAISERROR(@errorAdjustment, 16, 1);
			GOTO Post_Rollback
		END CATCH
	END

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
			,intCurrencyExchangeRateTypeId
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

	-- Call the Item's Transit Reversal
	IF EXISTS(SELECT 1 FROM @ValueToPost)
	BEGIN	
		BEGIN TRY
			UPDATE @ValueToPost SET dblValue = dblValue * -1

			EXEC @intReturnValue = dbo.uspICPostInTransitCosting  
					@ItemsForInTransitCosting  
					,@batchId  
					,NULL 
					,@userId
					,NULL
					,@ValueToPost

			INSERT INTO @GLEntriesTemp (
					[dtmDate] 
					,[strBatchId]
					,[intAccountId]
					,[dblDebit]
					,[dblCredit]
					,[dblDebitUnit]
					,[dblCreditUnit]
					,[strDescription]
					,[strCode]
					,[strReference]
					,[intCurrencyId]
					,[dblExchangeRate]
					,[dtmDateEntered]
					,[dtmTransactionDate]
					,[strJournalLineDescription]
					,[intJournalLineNo]
					,[ysnIsUnposted]
					,[intUserId]
					,[intEntityId]
					,[strTransactionId]					
					,[intTransactionId]
					,[strTransactionType]
					,[strTransactionForm] 
					,[strModuleName]
					,[intConcurrencyId]
					,[dblDebitForeign]
					,[dblDebitReport]
					,[dblCreditForeign]
					,[dblCreditReport]
					,[dblReportingRate]
					,[dblForeignRate]
					,[intSourceEntityId]
					,[intCommodityId]
					,[strRateType]
			)			
			EXEC @intReturnValue = dbo.uspICCreateGLEntriesOnInTransitValueAdjustment								
				@strBatchId = @batchId
				,@strTransactionId = NULL
				,@intEntityUserSecurityId = @userId
				,@strGLDescription = NULL
				,@AccountCategory_Cost_Adjustment = DEFAULT 
		END TRY
		BEGIN CATCH
			SET @errorAdjustment = ERROR_MESSAGE()
			RAISERROR(@errorAdjustment, 16, 1);
			GOTO Post_Rollback
		END CATCH
	END

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
			,intCurrencyExchangeRateTypeId
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


--QUANTITY ADJUSTMENT
DECLARE @qtyAdjustmentTable AS TABLE (
		intBillId  INT
		,intBillDetailId  INT
		,intItemId  INT
		,dtmDate  DATETIME 
		,intLocationId  INT	
		,intSubLocationId  INT	
		,intStorageLocationId  INT	
		,strLotNumber  NVARCHAR(50)
		,dblAdjustByQuantity  NUMERIC(38,20)
		,dblNewUnitCost  NUMERIC(38,20)
		,intItemUOMId  INT 
		,intSourceId  INT
		,strDescription  NVARCHAR(1000)
		,intContractHeaderId  INT NULL
		,intContractDetailId  INT NULL
		,intEntityId  INT NULL
)

DECLARE @intBillId AS INT
		,@intBillDetailId AS INT
		,@intItemId AS INT
		,@dtmDate AS DATETIME 
		,@intLocationId AS INT	
		,@intSubLocationId AS INT	
		,@intStorageLocationId AS INT	
		,@strLotNumber AS NVARCHAR(50) 
		,@intOwnershipType AS INT = 1
		,@dblAdjustByQuantity AS NUMERIC(38,20)
		,@dblNewUnitCost AS NUMERIC(38,20)
		,@intItemUOMId AS INT 
		,@intSourceId AS INT
		,@intSourceTransactionTypeId AS INT = 27
		,@intEntityUserSecurityId AS INT = @userId
		,@strDescription2 AS NVARCHAR(1000)
		,@ysnPost AS BIT = @post
		,@intContractHeaderId AS INT
		,@intContractDetailId AS INT
		,@intEntityId AS INT
		,@InventoryAdjustmentIntegrationId AS InventoryAdjustmentIntegrationId
		,@intInventoryAdjustmentId AS INT

INSERT INTO @qtyAdjustmentTable
SELECT B.intBillId,
		BD.intBillDetailId,
		BD.intItemId, 
		B.dtmDate,
		L.intLocationId,
		L.intSubLocationId,
		L.intStorageLocationId,
		L.strLotNumber,
		--BD.dblQtyReceived - BD.dblQtyOrdered,
		CASE 
			WHEN @ysnPost = 1 THEN BD.dblQtyReceived - ri.dblOpenReceive
			WHEN @ysnPost = 0 THEN -(BD.dblQtyReceived - ri.dblOpenReceive)
		END,
		BD.dblCost,
		BD.intUnitOfMeasureId,
		B.intBillId,
		B.strBillId,
		BD.intContractHeaderId,
		BD.intContractDetailId,
		B.intEntityVendorId
FROM tblAPBill B
INNER JOIN #tmpPostBillData IDS ON IDS.intBillId = B.intBillId
INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
INNER JOIN tblICLot L ON L.intLotId = BD.intLotId
INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptItemId = BD.intInventoryReceiptItemId
WHERE 
	B.ysnFinalVoucher = 1 
	--AND BD.dblQtyReceived <> BD.dblQtyOrdered
	AND (BD.dblQtyReceived - ri.dblOpenReceive) <> 0 

IF EXISTS(SELECT 1 FROM @qtyAdjustmentTable)
BEGIN
	WHILE EXISTS(SELECT TOP 1 1 FROM @qtyAdjustmentTable)
	BEGIN
		SELECT TOP 1 @intBillId = intBillId
					,@intBillDetailId = intBillDetailId
					,@intItemId = intItemId
					,@dtmDate = dtmDate
					,@intLocationId = intLocationId
					,@intSubLocationId = intSubLocationId
					,@intStorageLocationId = intStorageLocationId
					,@strLotNumber = strLotNumber
					,@dblAdjustByQuantity = dblAdjustByQuantity
					,@dblNewUnitCost = dblNewUnitCost
					,@intItemUOMId = intItemUOMId
					,@intSourceId = intSourceId
					,@strDescription2 = strDescription
					,@intContractHeaderId = intContractHeaderId
					,@intContractDetailId = intContractDetailId
					,@intEntityId = intEntityId
		FROM @qtyAdjustmentTable

		INSERT INTO @InventoryAdjustmentIntegrationId
		SELECT NULL, NULL, NULL, NULL, @intBillId

		EXEC uspICInventoryAdjustment_CreatePostQtyChange
			@intItemId = @intItemId
			,@dtmDate = @dtmDate
			,@intLocationId	= @intLocationId
			,@intSubLocationId = @intSubLocationId
			,@intStorageLocationId = @intStorageLocationId
			,@strLotNumber = @strLotNumber
			,@intOwnershipType = @intOwnershipType
			,@dblAdjustByQuantity = @dblAdjustByQuantity
			,@dblNewUnitCost = @dblNewUnitCost
			,@intItemUOMId = @intItemUOMId
			,@intSourceId = @intSourceId
			,@intSourceTransactionTypeId = @intSourceTransactionTypeId
			,@intEntityUserSecurityId = @intEntityUserSecurityId
			,@strDescription = @strDescription2
			,@ysnPost = @ysnPost
			,@InventoryAdjustmentIntegrationId = @InventoryAdjustmentIntegrationId
			,@intContractHeaderId = @intContractHeaderId
			,@intContractDetailId = @intContractDetailId
			,@intEntityId = @intEntityId
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

		DELETE @qtyAdjustmentTable WHERE intBillDetailId = @intBillDetailId
	END
END

INSERT INTO @qtyAdjustmentTable
SELECT B.intBillId,
		BD.intBillDetailId,
		BD.intItemId, 
		B.dtmDate,
		L.intLocationId,
		L.intSubLocationId,
		L.intStorageLocationId,
		L.strLotNumber,
		--dbo.fnDivide(BD.dblNetWeight, BD.dblQtyReceived),
		CASE 
			WHEN @ysnPost = 1 THEN dbo.fnDivide(BD.dblNetWeight, BD.dblQtyReceived)
			WHEN @ysnPost = 0 THEN dbo.fnDivide(ri.dblNet, ri.dblOpenReceive) 
		END,
		BD.dblCost,
		BD.intUnitOfMeasureId,
		B.intBillId,
		B.strBillId,
		BD.intContractHeaderId,
		BD.intContractDetailId,
		B.intEntityVendorId
FROM tblAPBill B
INNER JOIN #tmpPostBillData IDS ON IDS.intBillId = B.intBillId
INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
INNER JOIN tblICLot L ON L.intLotId = BD.intLotId
INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptItemId = BD.intInventoryReceiptItemId
WHERE 
	B.ysnFinalVoucher = 1 
	AND BD.ysnNetWeightChanged = 1
	-- compare the weight change between IR and final voucher
	AND (
		ROUND(
			dbo.fnMultiply(
				dbo.fnDivide(BD.dblNetWeight, BD.dblQtyReceived) -- wgt/qty in final voucher
				,BD.dblQtyReceived
			)
			,2
		) 
		<> 
		ROUND(
			dbo.fnMultiply(
				dbo.fnDivide(ri.dblNet, ri.dblOpenReceive) -- wgt/qty from receipt
				,BD.dblQtyReceived
			)
			,2
		)
	)

IF EXISTS(SELECT 1 FROM @qtyAdjustmentTable)
BEGIN
	WHILE EXISTS(SELECT TOP 1 1 FROM @qtyAdjustmentTable)
	BEGIN
		SELECT TOP 1 @intBillId = intBillId
					,@intBillDetailId = intBillDetailId
					,@intItemId = intItemId
					,@dtmDate = dtmDate
					,@intLocationId = intLocationId
					,@intSubLocationId = intSubLocationId
					,@intStorageLocationId = intStorageLocationId
					,@strLotNumber = strLotNumber
					,@dblAdjustByQuantity = dblAdjustByQuantity
					,@dblNewUnitCost = dblNewUnitCost
					,@intItemUOMId = intItemUOMId
					,@intSourceId = intSourceId
					,@strDescription2 = strDescription
					,@intContractHeaderId = intContractHeaderId
					,@intContractDetailId = intContractDetailId
					,@intEntityId = intEntityId
		FROM @qtyAdjustmentTable

		-- INSERT INTO @InventoryAdjustmentIntegrationId
		-- SELECT NULL, NULL, NULL, NULL, @intBillId

		EXEC uspICInventoryAdjustment_CreatePostLotWeight
			@intItemId = @intItemId
			,@dtmDate = @dtmDate
			,@intLocationId	= @intLocationId
			,@intSubLocationId = @intSubLocationId
			,@intStorageLocationId = @intStorageLocationId
			,@strLotNumber = @strLotNumber
			,@dblNewLotWeight = NULL
			,@dblNewWeightPerQty = @dblAdjustByQuantity
			,@intSourceId = @intSourceId
			,@intSourceTransactionTypeId = @intSourceTransactionTypeId
			,@intEntityUserSecurityId = @intEntityUserSecurityId
			,@strDescription = @strDescription2
			--,@ysnPost = @ysnPost
			,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT

		DELETE @qtyAdjustmentTable WHERE intBillDetailId = @intBillDetailId
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

	SELECT * FROM @GLEntries

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

		--LOG TO tblAPClearing
		BEGIN TRY
			DECLARE @clearingIds AS Id
			DECLARE @APClearing AS APClearing

			INSERT INTO @clearingIds
			SELECT intBillId FROM #tmpPostBillData

			IF EXISTS(
				SELECT 1
				FROM tblAPBillDetail A
				INNER JOIN #tmpPostBillData B ON A.intBillId = B.intBillId
				WHERE
					A.intInventoryReceiptItemId > 0
				OR A.intInventoryReceiptChargeId > 0
				OR A.intInventoryShipmentChargeId > 0
				OR A.intLoadDetailId > 0
				OR A.intLoadShipmentCostId > 0
				OR A.intSettleStorageId > 0
			)
			BEGIN
				INSERT INTO @APClearing
				SELECT * FROM fnAPClearing(@clearingIds)

				IF EXISTS(SELECT 1 FROM @APClearing)
				BEGIN
					EXEC uspAPClearing @APClearing = @APClearing, @post = @post
				END
			END

		END TRY
		BEGIN CATCH
				DECLARE @errorClearing NVARCHAR(200) = ERROR_MESSAGE()
				SET @invalidCount = @invalidCount + 1;
				SET @totalRecords = @totalRecords - 1;
				RAISERROR(@errorClearing, 16, 1);
				GOTO Post_Rollback
		END CATCH
	END
	ELSE
	BEGIN
		DECLARE @postError NVARCHAR(200);
		SELECT TOP 1 @postError = strMessage FROM tblAPPostResult WHERE strBatchNumber = @batchId
		RAISERROR(@postError, 16, 1);
		GOTO Post_Rollback
	END

	BEGIN TRY
		--POST INTEGRATION
		DECLARE @postIntegrationError TABLE(intBillId INT, strBillId NVARCHAR(50), strError NVARCHAR(200));

		--DECLARE THE TEMP TABLE HERE NOT IS SP AND RETURN, NESTED INSERT EXEC IS NOT ALLOWED
		IF OBJECT_ID(N'tempdb..#tmpPostVoucherIntegrationError') IS NOT NULL DROP TABLE #tmpPostVoucherIntegrationError
		CREATE TABLE #tmpPostVoucherIntegrationError(intBillId INT, strBillId NVARCHAR(50), strError NVARCHAR(200));
		
		DECLARE @voucherIdsIntegration AS Id;
		INSERT INTO @voucherIdsIntegration
		SELECT DISTINCT intBillId FROM #tmpPostBillData	

		EXEC uspAPCallPostVoucherIntegration @billIds = @voucherIdsIntegration, @post = @post, @intUserId = @userId

		IF EXISTS(SELECT 1 FROM #tmpPostVoucherIntegrationError)
		BEGIN
			--REMOVE FAILED POST VOUCHER INTEGRATION FROM UPDATING VOUCHER TABLE
			DELETE A
			FROM #tmpPostBillData A
			INNER JOIN #tmpPostVoucherIntegrationError B ON A.intBillId = B.intBillId
		END
	END TRY
	BEGIN CATCH
		DECLARE @errorPostIntegration NVARCHAR(200) = ERROR_MESSAGE()
		SET @invalidCount = @invalidCount + 1;
		SET @totalRecords = @totalRecords - 1;
		RAISERROR(@errorPostIntegration, 16, 1);
		--ROLLBACK ALL IF UNKNOWN ERROR OCCURS
		GOTO Post_Rollback
	END CATCH

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
				-- intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
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

		INSERT INTO @billIdsInventoryLog
		SELECT intBillId FROM #tmpPostBillData
		EXEC uspAPLogInventorySubLedger @billIds = @billIdsInventoryLog, @remove = 1, @userId = @userId

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
			SET ysnPosted = 1--, intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
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

		INSERT INTO @billIdsInventoryLog
		SELECT intBillId FROM #tmpPostBillData
		EXEC uspAPLogInventorySubLedger @billIds = @billIdsInventoryLog, @remove = 0, @userId = @userId
		
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
			,ISNULL(A.[dblForeignRate], 1)
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
		
		--CLEAN UP TRACKER FOR POSTING
		DELETE A
		FROM tblAPBillForPosting A
		
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

--CLEAN ysnInPayment, dblPaymentTemp, & ysnPrepayHasPayment
--WE CAN ASSUME NEWLY POSTED VOUCHERS DOES NOT HAVE PAYMENT YET
UPDATE B
SET B.ysnInPayment = 0,
	B.dblPaymentTemp = 0,
	B.ysnPrepayHasPayment = 0
FROM tblAPBill B
INNER JOIN #tmpPostBillData BD ON BD.intBillId = B.intBillId
WHERE B.ysnPaid = 0 AND @post = 1

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
	--CLEAN UP TRACKER FOR POSTING
	DELETE A
	FROM tblAPBillForPosting A

