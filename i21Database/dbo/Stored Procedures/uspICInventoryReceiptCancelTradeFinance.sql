CREATE PROCEDURE [dbo].[uspICInventoryReceiptCancelTradeFinance]
	@ReceiptId INT 
	,@UserId INT
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS ON  

DECLARE @TRFTradeFinance AS TRFTradeFinance
DECLARE @TRFLog AS TRFLog
DECLARE @dtmDate DATETIME

-- Create a cancelled history
BEGIN 
	SELECT 
		@dtmDate = dtmReceiptDate 
	FROM 
		tblICInventoryReceipt r 
	WHERE 
		r.intInventoryReceiptId = @ReceiptId

	UPDATE r
	SET
		r.strApprovalStatus = 'Cancelled'
	FROM 
		tblICInventoryReceipt r LEFT JOIN tblTRFTradeFinance tf
			ON r.strTradeFinanceNumber = tf.strTradeFinanceNumber
	WHERE 
		r.intInventoryReceiptId = @ReceiptId
		AND tf.intTradeFinanceId IS NOT NULL 

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
		, strTransactionType = 'Inventory' --CASE WHEN r.strReceiptType = 'Inventory Return' THEN 'Inventory Return' ELSE 'Inventory Receipt' END  -- <-- This is module
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
			--  Added strTransactionType since each module has separate Trade Finance Record.
			AND tf.strTransactionType = 'Inventory'
			AND tf.strTransactionNumber = r.strReceiptNumber
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

	END 
END 

-- Create a cancelled trade finance log.
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
		, strWarrantId 
		, intWarrantStatusId  
		, intUserId 
		, intConcurrencyId 
		, intContractHeaderId 
		, intContractDetailId 
		, intOverrideBankValuationId
		, strOverrideBankValuation
	)
	SELECT 
		strAction = 'Cancelled ' + CASE WHEN r.strReceiptType = 'Inventory Return' THEN 'Inventory Return' ELSE 'Inventory Receipt' END 
		, strTransactionType = 'Inventory' 
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
		, strBankTradeReference = r.strReferenceNo --r.strBankReferenceNo
		, dblFinanceQty = 0 --ISNULL(contractIR.dblQty, directIR.dblQty)
		, dblFinancedAmount = 0 --r.dblGrandTotal
		, strBankApprovalStatus = r.strApprovalStatus
		, dtmAppliedToTransactionDate = GETDATE()
		, intStatusId = 0
				--CASE 
				--	WHEN tf.intStatusId = 1 THEN 'Active' 
				--	WHEN tf.intStatusId = 2 THEN 'Completed'
				--	WHEN tf.intStatusId = 0 THEN 'Cancelled'							
				--END
		, strWarrantId = r.strWarrantNo
		, intWarrantStatusId = r.intWarrantStatus 
		, intUserId = COALESCE(r.intModifiedByUserId, r.intCreatedUserId, r.intCreatedByUserId) 
		, intConcurrencyId = 1
		, intContractHeaderId = receiptContract.intContractHeaderId
		, intContractDetailId = receiptContract.intContractDetailId
		, intOverrideFacilityValuation = bvr.intBankValuationRuleId
		, strOverrideFacilityValuation = bvr.strBankValuationRule
	FROM 
		tblICInventoryReceipt r LEFT JOIN tblTRFTradeFinance tf
			ON r.strTradeFinanceNumber = tf.strTradeFinanceNumber
			--  Added strTransactionType since each module has separate Trade Finance Record.
			AND tf.strTransactionType = 'Inventory'
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
				AND ISNULL(r.intSourceType, 0) = 0
		) directIR
		OUTER APPLY (
			SELECT 
				dblQty = SUM(ri.dblOpenReceive)
			FROM 
				tblICInventoryReceiptItem ri 
				LEFT JOIN tblICItemUOM stockUOM
				ON stockUOM.intItemId = ri.intItemId
				AND stockUOM.ysnStockUnit = 1
			WHERE
				ri.intInventoryReceiptId = r.intInventoryReceiptId
				AND (r.intSourceType <> 0 OR r.intSourceType IS NULL) 
		) contractIR
		OUTER APPLY (
			SELECT TOP 1 
				ri.intContractHeaderId
				,ri.intContractDetailId
			FROM 
				tblICInventoryReceiptItem ri 
			WHERE
				ri.intInventoryReceiptId = r.intInventoryReceiptId
		) receiptContract
		--OUTER APPLY (
		--	SELECT TOP 1 
		--		lg.strTradeFinanceReferenceNo
		--	FROM 
		--		tblLGLoad lg
		--	WHERE
		--		lg.strTradeFinanceNo = r.strTradeFinanceNumber
		--) logistics
	WHERE
		r.intInventoryReceiptId = @ReceiptId

	IF EXISTS (SELECT TOP 1 1 FROM @TRFLog) 
	BEGIN 
		EXEC uspTRFLogTradeFinance @TradeFinanceLogs = @TRFLog;
	END 
END 
