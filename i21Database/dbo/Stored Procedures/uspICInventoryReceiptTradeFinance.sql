﻿CREATE PROCEDURE [dbo].[uspICInventoryReceiptTradeFinance]
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
		,@strTradeFinanceNumber NVARCHAR(100)			
		,@strWarrantStatusAction NVARCHAR(50) = NULL 

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
	AND EXISTS (
		SELECT TOP 1 1 
		FROM 
			tblICInventoryReceipt currentSnapshot INNER JOIN tblICInventoryReceiptBeforeSave previousSnapshot
				ON currentSnapshot.intInventoryReceiptId = previousSnapshot.intInventoryReceiptId
		WHERE
				currentSnapshot.intInventoryReceiptId = @ReceiptId
				AND (
					currentSnapshot.[strTradeFinanceNumber] <> previousSnapshot.[strTradeFinanceNumber] 
					OR (currentSnapshot.[strTradeFinanceNumber] IS NOT NULL AND previousSnapshot.[strTradeFinanceNumber] IS NULL)
					OR currentSnapshot.[intBankId] <> previousSnapshot.[intBankId] 
					OR (currentSnapshot.[intBankId] IS NOT NULL AND  previousSnapshot.[intBankId] IS NULL)
					OR currentSnapshot.[intBankAccountId] <> previousSnapshot.[intBankAccountId] 
					OR (currentSnapshot.[intBankAccountId] IS NOT NULL AND previousSnapshot.[intBankAccountId] IS NULL)
					OR currentSnapshot.[intBorrowingFacilityId] <> previousSnapshot.[intBorrowingFacilityId] 
					OR (currentSnapshot.[intBorrowingFacilityId] IS NOT NULL AND previousSnapshot.[intBorrowingFacilityId] IS NULL)
					OR currentSnapshot.[strBankReferenceNo] <> previousSnapshot.[strBankReferenceNo] 
					OR (currentSnapshot.[strBankReferenceNo] IS NOT NULL AND previousSnapshot.[strBankReferenceNo] IS NULL)
					OR currentSnapshot.[intLimitTypeId] <> previousSnapshot.[intLimitTypeId] 
					OR (currentSnapshot.[intLimitTypeId] IS NOT NULL AND previousSnapshot.[intLimitTypeId] IS NULL)
					OR currentSnapshot.[intSublimitTypeId] <> previousSnapshot.[intSublimitTypeId] 
					OR (currentSnapshot.[intSublimitTypeId] IS NOT NULL AND previousSnapshot.[intSublimitTypeId] IS NULL)
					OR currentSnapshot.[ysnSubmittedToBank] <> previousSnapshot.[ysnSubmittedToBank]
					OR (currentSnapshot.[ysnSubmittedToBank] IS NOT NULL AND previousSnapshot.[ysnSubmittedToBank] IS NULL)
					OR currentSnapshot.[dtmDateSubmitted] <> previousSnapshot.[dtmDateSubmitted] 
					OR (currentSnapshot.[dtmDateSubmitted] IS NOT NULL AND previousSnapshot.[dtmDateSubmitted] IS NULL)
					OR currentSnapshot.[strApprovalStatus] <> previousSnapshot.[strApprovalStatus] 
					OR (currentSnapshot.[strApprovalStatus] IS NOT NULL AND previousSnapshot.[strApprovalStatus] IS NULL)
					OR currentSnapshot.[dtmDateApproved] <> previousSnapshot.[dtmDateApproved] 
					OR (currentSnapshot.[dtmDateApproved] IS NOT NULL AND previousSnapshot.[dtmDateApproved] IS NULL) 
					OR currentSnapshot.[strWarrantNo] <> previousSnapshot.[strWarrantNo] 
					OR (currentSnapshot.[strWarrantNo] IS NOT NULL AND previousSnapshot.[strWarrantNo] IS NULL)
					OR currentSnapshot.[intWarrantStatus] <> previousSnapshot.[intWarrantStatus] 
					OR (currentSnapshot.[intWarrantStatus] IS NOT NULL AND previousSnapshot.[intWarrantStatus] IS NULL) 
					OR currentSnapshot.[strReferenceNo] <> previousSnapshot.[strReferenceNo] 
					OR (currentSnapshot.[strReferenceNo] IS NOT NULL AND previousSnapshot.[strReferenceNo] IS NULL)
					OR currentSnapshot.[intOverrideFacilityValuation] <> previousSnapshot.[intOverrideFacilityValuation] 
					OR (currentSnapshot.[intOverrideFacilityValuation] IS NOT NULL AND previousSnapshot.[intOverrideFacilityValuation] IS NULL)
					OR currentSnapshot.[strComments] <> previousSnapshot.[strComments] 
					OR (currentSnapshot.[strComments] IS NOT NULL AND previousSnapshot.[strComments] IS NULL) 
				)
	)
	BEGIN 
		EXEC [uspTRFModifyTFRecord]
			@records = @TRFTradeFinance
			, @intUserId = @UserId
			, @strAction = 'UPDATE'
			, @dtmTransactionDate = @dtmDate 

		SELECT @strAction = 'Updated' WHERE @strAction IS NULL 
		
		SELECT 
			@strWarrantStatusAction = s.strWarrantStatus
		FROM 
			tblICInventoryReceipt currentSnapshot INNER JOIN tblICInventoryReceiptBeforeSave previousSnapshot
				ON currentSnapshot.intInventoryReceiptId = previousSnapshot.intInventoryReceiptId
			LEFT JOIN tblICWarrantStatus s
				ON currentSnapshot.[intWarrantStatus] = s.intWarrantStatus 
		WHERE
				currentSnapshot.intInventoryReceiptId = @ReceiptId
				AND (
					currentSnapshot.[intWarrantStatus] <> previousSnapshot.[intWarrantStatus] 
					OR (currentSnapshot.[intWarrantStatus] IS NOT NULL AND previousSnapshot.[intWarrantStatus] IS NULL)
				)
				AND s.strWarrantStatus IN ('Released', 'Partially Released', 'Pledged')
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
		-- Get a new trade finance id. 
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

			SELECT 
				@strWarrantStatusAction = s.strWarrantStatus
			FROM 
				tblICInventoryReceipt currentSnapshot LEFT JOIN tblICWarrantStatus s
					ON currentSnapshot.[intWarrantStatus] = s.intWarrantStatus 
			WHERE
					currentSnapshot.intInventoryReceiptId = @ReceiptId
					AND s.strWarrantStatus IN ('Released', 'Partially Released', 'Pledged')
		END 
	END 
	-- Create a new trade finance record. 
	ELSE IF EXISTS (
		SELECT TOP 1 1 
		FROM 
			@TRFTradeFinance 
		WHERE 
			intTradeFinanceId IS NULL
			AND strTradeFinanceNumber IS NOT NULL -- If strTradeFinanceNumber has a value, it means the TF record was deleted. Do not auto-create it. 
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
		SELECT TOP 1 @strTradeFinanceNumber = strTradeFinanceNumber
		FROM @TRFTradeFinance 
		WHERE strTradeFinanceNumber IS NOT NULL

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

			SELECT 
				@strWarrantStatusAction = s.strWarrantStatus
			FROM 
				tblICInventoryReceipt currentSnapshot LEFT JOIN tblICWarrantStatus s
					ON currentSnapshot.[intWarrantStatus] = s.intWarrantStatus 
			WHERE
				currentSnapshot.intInventoryReceiptId = @ReceiptId
				AND s.strWarrantStatus IN ('Released', 'Partially Released', 'Pledged')				
		END 
	END 

	-- Create a trade finance log if the warrant status is changed. 
	IF @strWarrantStatusAction IS NOT NULL 
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
			strAction = 'Warrant Status ' + @strWarrantStatusAction 
			, strTransactionType = 'Inventory' --CASE WHEN r.strReceiptType = 'Inventory Return' THEN 'Inventory Return' ELSE 'Inventory Receipt' END  -- <-- This is module
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
			, dblFinanceQty = openReceiveTotal.dblQty --ISNULL(contractIR.dblQty, directIR.dblQty)
			, dblFinancedAmount = r.dblGrandTotal
			, strBankApprovalStatus = r.strApprovalStatus
			, dtmAppliedToTransactionDate = GETDATE()
			, intStatusId = 1
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
				AND tf.strTransactionNumber = r.strReceiptNumber
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
			--OUTER APPLY (
			--	SELECT 
			--		dblQty = 
			--			SUM(
			--				CASE 
			--					WHEN ri.intWeightUOMId IS NOT NULL THEN 
			--						dbo.fnCalculateQtyBetweenUOM(
			--							ri.intWeightUOMId
			--							,stockUOM.intItemUOMId
			--							,ri.dblNet
			--						)
			--					ELSE 
			--						dbo.fnCalculateQtyBetweenUOM(
			--							ri.intUnitMeasureId
			--							,stockUOM.intItemUOMId
			--							,ri.dblNet
			--						)
			--				END 							
			--			)
			--	FROM 
			--		tblICInventoryReceiptItem ri 
			--		LEFT JOIN tblICItemUOM stockUOM
			--			ON stockUOM.intItemId = ri.intItemId
			--			AND stockUOM.ysnStockUnit = 1
			--	WHERE
			--		ri.intInventoryReceiptId = r.intInventoryReceiptId
			--		AND ISNULL(r.intSourceType, 0) = 0
			--) directIR
			--  OUTER APPLY (
			--	SELECT 
			--		dblQty = SUM(ri.dblOpenReceive)
			--	FROM 
			--		tblICInventoryReceiptItem ri 
			--		LEFT JOIN tblICItemUOM stockUOM
			--		ON stockUOM.intItemId = ri.intItemId
			--		AND stockUOM.ysnStockUnit = 1
			--	WHERE
			--		ri.intInventoryReceiptId = r.intInventoryReceiptId
			--		AND (r.intSourceType <> 0 OR r.intSourceType IS NULL) 
			--  ) contractIR
			OUTER APPLY (
				SELECT 
					dblQty = SUM(ri.dblOpenReceive)
				FROM 
					tblICInventoryReceiptItem ri 			
				WHERE
					ri.intInventoryReceiptId = r.intInventoryReceiptId
		    ) openReceiveTotal
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
	END 
		
	-- Create a trade finance log if data is changed. 
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
			strAction = @strAction + ' ' + CASE WHEN r.strReceiptType = 'Inventory Return' THEN 'Inventory Return' ELSE 'Inventory Receipt' END 
			, strTransactionType = 'Inventory' --CASE WHEN r.strReceiptType = 'Inventory Return' THEN 'Inventory Return' ELSE 'Inventory Receipt' END  -- <-- This is module
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
			, dblFinanceQty = openReceiveTotal.dblQty --ISNULL(contractIR.dblQty, directIR.dblQty)
			, dblFinancedAmount = r.dblGrandTotal
			, strBankApprovalStatus = r.strApprovalStatus
			, dtmAppliedToTransactionDate = GETDATE()
			, intStatusId = 1
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
				AND tf.strTransactionNumber = r.strReceiptNumber
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
			--OUTER APPLY (
			--	SELECT 
			--		dblQty =
			--			SUM(
			--				CASE 
			--					WHEN ri.intWeightUOMId IS NOT NULL THEN 
			--						dbo.fnCalculateQtyBetweenUOM(
			--							ri.intWeightUOMId
			--							,stockUOM.intItemUOMId
			--							,ri.dblNet
			--						)
			--					ELSE 
			--						dbo.fnCalculateQtyBetweenUOM(
			--							ri.intUnitMeasureId
			--							,stockUOM.intItemUOMId
			--							,ri.dblNet
			--						)
			--				END 							
			--			)
			--	FROM 
			--		tblICInventoryReceiptItem ri 
			--		LEFT JOIN tblICItemUOM stockUOM
			--			ON stockUOM.intItemId = ri.intItemId
			--			AND stockUOM.ysnStockUnit = 1
			--	WHERE
			--		ri.intInventoryReceiptId = r.intInventoryReceiptId
			--		AND ISNULL(r.intSourceType, 0) = 0
			--) directIR
			 --  OUTER APPLY (
			--	SELECT 
			--		dblQty = SUM(ri.dblOpenReceive)
			--	FROM 
			--		tblICInventoryReceiptItem ri 
			--		LEFT JOIN tblICItemUOM stockUOM
			--		ON stockUOM.intItemId = ri.intItemId
			--		AND stockUOM.ysnStockUnit = 1
			--	WHERE
			--		ri.intInventoryReceiptId = r.intInventoryReceiptId
			--		AND (r.intSourceType <> 0 OR r.intSourceType IS NULL) 
			--  ) contractIR
			OUTER APPLY (
				SELECT 
					dblQty = SUM(ri.dblOpenReceive)
				FROM 
					tblICInventoryReceiptItem ri 			
				WHERE
					ri.intInventoryReceiptId = r.intInventoryReceiptId
		    ) openReceiveTotal			
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
	END 

	IF EXISTS (SELECT TOP 1 1 FROM @TRFLog) 
	BEGIN 
		EXEC uspTRFLogTradeFinance @TradeFinanceLogs = @TRFLog;
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