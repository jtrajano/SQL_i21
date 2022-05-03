CREATE PROCEDURE [dbo].[uspICInventoryReceiptTradeFinance]
	@ReceiptId INT 
	,@UserId INT
	,@strAction NVARCHAR(50) = NULL 
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  

DECLARE @TRFTradeFinance AS TRFTradeFinance
		,@TRFLog AS TRFLog

		,@intTradeFinanceId	INT = NULL 
		,@dtmDate DATETIME				

SELECT 
	@dtmDate = dtmReceiptDate 
FROM 
	tblICInventoryReceipt r 
WHERE 
	r.intInventoryReceiptId = @ReceiptId

-- Create or update the Trade Finance record. 
BEGIN 
	INSERT INTO @TRFTradeFinance (
		intTradeFinanceId 
		, strTradeFinanceNumber 
		, strTransactionType 
		, strTransactionNumber 
		, intTransactionHeaderId 
		, intTransactionDetailId 
		, intBankId 
		, intBankAccountId 
		, intBorrowingFacilityId 
		, intLimitTypeId 
		, intSublimitTypeId 
		, ysnSubmittedToBank 
		, dtmDateSubmitted 
		, strApprovalStatus 
		, dtmDateApproved 
		, strRefNo 
		, intOverrideFacilityValuation 
		, strCommnents 
	)
	SELECT TOP 1 
		tf.intTradeFinanceId 
		, r.strTradeFinanceNumber 
		, strTransactionType = CASE WHEN r.strReceiptType = 'Inventory Return' THEN 'Inventory Return' ELSE 'Inventory Receipt' END 
		, strTransactionNumber = r.strReceiptNumber
		, intTransactionHeaderId = r.intInventoryReceiptId
		, intTransactionDetailId = NULL 
		, intBankId = r.intBankId
		, intBankAccountId = r.intBankAccountId
		, intBorrowingFacilityId = r.intBorrowingFacilityId
		, intLimitTypeId = r.intLimitTypeId
		, intSublimitTypeId = r.intSublimitTypeId
		, ysnSubmittedToBank = r.ysnSubmittedToBank
		, dtmDateSubmitted = r.dtmDateSubmitted
		, strApprovalStatus = r.strApprovalStatus
		, dtmDateApproved = r.dtmDateApproved
		, strRefNo = r.strReferenceNo
		, intOverrideFacilityValuation = r.intOverrideFacilityValuation
		, strCommnents = r.strComments
	FROM 
		tblICInventoryReceipt r LEFT JOIN tblTRFTradeFinance tf
			ON r.strTradeFinanceNumber = tf.strTradeFinanceNumber
	WHERE
		r.intInventoryReceiptId = @ReceiptId

	-- Update an existing trade finance record. 
	IF EXISTS (SELECT TOP 1 1 FROM @TRFTradeFinance WHERE intTradeFinanceId IS NOT NULL)
	BEGIN 
		EXEC [uspTRFModifyTFRecord]
			@records = @TRFTradeFinance
			, @intUserId = @UserId
			, @strAction = 'UPDATE'
			, @dtmTransactionDate = @dtmDate 

		SELECT @strAction = 'Updated' WHERE @strAction IS NULL 
	END 
	-- Create a new trade finance record. 
	ELSE IF EXISTS (
		SELECT TOP 1 1 
		FROM 
			@TRFTradeFinance 
		WHERE 
			intTradeFinanceId IS NULL
			AND strTradeFinanceNumber IS NULL -- If strTradeFinanceNumber has a value, it means the TF record was deleted. Do not auto-create it. 
			AND (
				intBankId IS NOT NULL 
				OR intBankAccountId IS NOT NULL 
				OR intBorrowingFacilityId IS NOT NULL 
				OR intLimitTypeId IS NOT NULL 
				OR intSublimitTypeId IS NOT NULL 
				OR ysnSubmittedToBank IS NOT NULL 
				OR dtmDateSubmitted IS NOT NULL 
				OR strApprovalStatus IS NOT NULL 
				OR dtmDateApproved IS NOT NULL 
				OR strRefNo IS NOT NULL 
				OR intOverrideFacilityValuation IS NOT NULL 
				OR strCommnents IS NOT NULL 
			)
	)
	BEGIN 
		-- Get the trade finance id. 
		DECLARE @strTradeFinanceNumber NVARCHAR(100)	
		EXEC uspSMGetStartingNumber 166, @strTradeFinanceNumber OUT

		UPDATE @TRFTradeFinance 
		SET strTradeFinanceNumber = @strTradeFinanceNumber

		EXEC uspTRFCreateTFRecord
			@records = @TRFTradeFinance
			, @intUserId = @UserId
			, @dtmTransactionDate = @dtmDate
			, @intTradeFinanceId = @intTradeFinanceId OUTPUT 

		IF @intTradeFinanceId IS NOT NULL 
		BEGIN 
			UPDATE r
			SET 
				r.strTradeFinanceNumber = @strTradeFinanceNumber
			FROM 
				tblICInventoryReceipt r
			WHERE 
				r.intInventoryReceiptId = @ReceiptId
				AND @strTradeFinanceNumber IS NOT NULL 

			SELECT @strAction = 'Created' WHERE @strAction IS NULL 
		END 
	END 
		
	-- Create a trade finance log.
	IF @strAction IS NOT NULL 
	BEGIN 
		INSERT INTO @TRFLog (
			strAction 
			, strTransactionType 
			, intTradeFinanceTransactionId 
			, strTradeFinanceTransaction 
			, intTransactionHeaderId 
			, intTransactionDetailId 
			, strTransactionNumber 
			, dtmTransactionDate 
			, intBankTransactionId 
			, strBankTransactionId 
			, intBankId 
			, strBank 
			, intBankAccountId 
			, strBankAccount 
			, intBorrowingFacilityId 
			, strBorrowingFacility 
			, strBorrowingFacilityBankRefNo 
			, dblTransactionAmountAllocated 
			, dblTransactionAmountActual 
			--, intLoanLimitId 
			--, strLoanLimitNumber 
			--, strLoanLimitType 
			, intLimitId 
			, strLimit 
			, dblLimit 
			, intSublimitId 
			, strSublimit 
			, dblSublimit 
			, strBankTradeReference 
			, dblFinanceQty 
			, dblFinancedAmount 
			, strBankApprovalStatus 
			, dtmAppliedToTransactionDate 
			, intStatusId 
			, intWarrantId 
			, strWarrantId 
			, intUserId 
			, intConcurrencyId 
			, intContractHeaderId 
			, intContractDetailId 
		)
		SELECT 
			strAction = @strAction + ' ' + CASE WHEN r.strReceiptType = 'Inventory Return' THEN 'Inventory Return' ELSE 'Inventory Receipt' END 
			, strTransactionType = CASE WHEN r.strReceiptType = 'Inventory Return' THEN 'Inventory Return' ELSE 'Inventory Receipt' END 
			, intTradeFinanceTransactionId = tf.intTradeFinanceId
			, strTradeFinanceTransaction = tf.strTradeFinanceNumber
			, intTransactionHeaderId = r.intInventoryReceiptId
			, intTransactionDetailId = NULL 
			, strTransactionNumber = r.strReceiptNumber
			, dtmTransactionDate = r.dtmReceiptDate
			, intBankTransactionId = NULL 
			, strBankTransactionId = NULL 
			, intBankId = r.intBankId
			, strBank = ba.strBankName
			, intBankAccountId = ba.intBankAccountId
			, strBankAccount  = ba.strBankAccountNo
			, intBorrowingFacilityId = r.intBorrowingFacilityId
			, strBorrowingFacility = fa.strBorrowingFacilityId
			, strBorrowingFacilityBankRefNo = r.strBankReferenceNo
			, dblTransactionAmountAllocated = r.dblGrandTotal 
			, dblTransactionAmountActual = r.dblGrandTotal
			--, intLoanLimitId 
			--, strLoanLimitNumber 
			--, strLoanLimitType 
			, intLimitId = r.intLimitTypeId
			, strLimit = fl.strBorrowingFacilityLimit
			, dblLimit = fl.dblLimit
			, intSublimitId = r.intSublimitTypeId
			, strSublimit = fld.strLimitDescription
			, dblSublimit = fld.dblLimit
			, strBankTradeReference = r.strBankReferenceNo
			, dblFinanceQty = ri.dblQty
			, dblFinancedAmount = r.dblGrandTotal
			, strBankApprovalStatus = r.strApprovalStatus
			, dtmAppliedToTransactionDate = GETDATE()
			, intStatusId = 1
					--CASE 
					--	WHEN tf.intStatusId = 1 THEN 'Active' 
					--	WHEN tf.intStatusId = 2 THEN 'Completed'
					--	WHEN tf.intStatusId = 0 THEN 'Cancelled'							
					--END
			, intWarrantId = NULL 
			, strWarrantId = r.strWarrantNo
			, intUserId = COALESCE(r.intModifiedByUserId, r.intCreatedUserId, r.intCreatedByUserId) 
			, intConcurrencyId = 1
			, intContractHeaderId = receiptContract.intContractHeaderId
			, intContractDetailId = receiptContract.intContractDetailId
		FROM 
			tblICInventoryReceipt r LEFT JOIN tblTRFTradeFinance tf
				ON r.strTradeFinanceNumber = tf.strTradeFinanceNumber
			LEFT JOIN vyuCMBankAccount ba 
				ON ba.intBankAccountId = r.intBankAccountId
			LEFT JOIN tblCMBorrowingFacility fa
				ON fa.intBorrowingFacilityId = r.intBorrowingFacilityId
			LEFT JOIN tblCMBorrowingFacilityLimit fl 
				ON fl.intBorrowingFacilityLimitId = r.intLimitTypeId
			LEFT JOIN tblCMBorrowingFacilityLimitDetail fld
				ON fld.intBorrowingFacilityLimitDetailId = r.intSublimitTypeId
			LEFT JOIN tblCMBankValuationRule bvr
				ON bvr.intBankValuationRuleId = r.intOverrideFacilityValuation				
			OUTER APPLY (
				SELECT 
					dblQty = 
						SUM(
							CASE 
								WHEN ri.intWeightUOMId IS NOT NULL THEN 
									dbo.fnCalculateQtyBetweenUOM(
										ri.intWeightUOMId
										,stockUOM.intItemUOMId
										,ri.dblNet
									)
								ELSE 
									dbo.fnCalculateQtyBetweenUOM(
										ri.intUnitMeasureId
										,stockUOM.intItemUOMId
										,ri.dblNet
									)
							END 							
						)
				FROM 
					tblICInventoryReceiptItem ri 
					LEFT JOIN tblICItemUOM stockUOM
						ON stockUOM.intItemId = ri.intItemId
						AND stockUOM.ysnStockUnit = 1
				WHERE
					ri.intInventoryReceiptId = r.intInventoryReceiptId
			) ri
			OUTER APPLY (
				SELECT TOP 1 
					ri.intContractHeaderId
					,ri.intContractDetailId
				FROM 
					tblICInventoryReceiptItem ri 
				WHERE
					ri.intInventoryReceiptId = r.intInventoryReceiptId
			) receiptContract
		WHERE
			r.intInventoryReceiptId = @ReceiptId

		IF EXISTS (SELECT TOP 1 1 FROM @TRFLog) 
		BEGIN 
			EXEC uspTRFLogTradeFinance @TradeFinanceLogs = @TRFLog;
		END 
	END 
END 

-- Update the released lots
BEGIN
	DECLARE @LotsToRelease AS LotReleaseTableType 

	INSERT INTO @LotsToRelease (
		[intItemId] 
		,[intItemLocationId] 
		,[intItemUOMId] 
		,[intLotId] 
		,[intSubLocationId] 
		,[intStorageLocationId] 
		,[dblQty] 
		,[intTransactionId] 
		,[strTransactionId] 
		,[intTransactionTypeId] 
		,[intOwnershipTypeId] 
		,[dtmDate] 
	)
	SELECT 
		[intItemId] = ri.intItemId
		,[intItemLocationId] = il.intItemLocationId
		,[intItemUOMId] = ril.intItemUnitMeasureId
		,[intLotId] = ril.intLotId
		,[intSubLocationId] = ril.intSubLocationId
		,[intStorageLocationId] = ril.intStorageLocationId
		,[dblQty] = ril.dblQuantity
		,[intTransactionId] = r.intInventoryReceiptId
		,[strTransactionId] = r.strReceiptNumber
		,[intTransactionTypeId] = 4
		,[intOwnershipTypeId] = ri.intOwnershipType
		,[dtmDate] = r.dtmReceiptDate
	FROM 
		tblICInventoryReceipt r 
		INNER JOIN tblICInventoryReceiptItem ri
			ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		INNER JOIN tblICInventoryReceiptItemLot ril 
			ON ril.intInventoryReceiptItemId = ri.intInventoryReceiptItemId		
		INNER JOIN tblICItemLocation il
			ON il.intItemId = ri.intItemId
			AND il.intLocationId = r.intLocationId
		LEFT JOIN tblICWarrantStatus warrantStatus
			ON warrantStatus.intWarrantStatus = ril.intWarrantStatus	
	WHERE
		r.intInventoryReceiptId = @ReceiptId
		AND r.ysnPosted = 1

	EXEC [uspICCreateLotRelease]
		@LotsToRelease = @LotsToRelease 
		,@intTransactionId = @ReceiptId
		,@intTransactionTypeId = 4
		,@intUserId = @UserId
END 