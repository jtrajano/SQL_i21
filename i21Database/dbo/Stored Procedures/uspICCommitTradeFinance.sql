﻿CREATE PROCEDURE [dbo].[uspICCommitTradeFinance]
	@strTransactionId AS NVARCHAR(50)
	,@intEntityUserSecurityId AS INT 
AS

DECLARE @TRFTradeFinance AS TRFTradeFinance
		,@TRFLog AS TRFLog
		
IF NOT EXISTS (SELECT TOP 1 1 FROM tblICInventoryTradeFinance itf WHERE itf.strTradeFinanceNumber = @strTransactionId AND ISNULL(itf.ysnCommit, 0) = 0)
	RETURN 0; 
	   
-- Update the commit flag immediately. 
UPDATE itf
SET
	itf.ysnCommit = 1
	,itf.intConcurrencyId += 1 
FROM
	tblICInventoryTradeFinance itf
WHERE
	itf.strTradeFinanceNumber = @strTransactionId
	AND ISNULL(itf.ysnCommit, 0) = 0

DECLARE 
	@dtmDate AS DATETIME 
	,@strAction AS NVARCHAR(50) 
	,@intTradeFinanceId AS INT 

SELECT TOP 1 
	@dtmDate = itf.dtmDateSubmitted
FROM
	tblICInventoryTradeFinance itf
WHERE
	itf.strTradeFinanceNumber = @strTransactionId

-- Create the TF record. 
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
SELECT 
	tf.intTradeFinanceId
	, itf.strTradeFinanceNumber 
	, strTransactionType = 'Inventory Trade Finance'
	, strTransactionNumber = itf.strTradeFinanceNumber
	, intTransactionHeaderId = itf.intInventoryTradeFinanceId
	, intTransactionDetailId = NULL 
	, intBankId = itf.intBankId
	, intBankAccountId = itf.intBankAccountId
	, intBorrowingFacilityId = itf.intBorrowingFacilityId
	, intLimitTypeId = itf.intLimitTypeId
	, intSublimitTypeId = itf.intSublimitTypeId
	, ysnSubmittedToBank = itf.ysnSubmittedToBank
	, dtmDateSubmitted = itf.dtmDateSubmitted
	, strApprovalStatus = itf.strApprovalStatus
	, dtmDateApproved = itf.dtmDateApproved
	, strRefNo = itf.strReferenceNo
	, intOverrideFacilityValuation = itf.intOverrideFacilityValuation
	, strCommnents = itf.strComments
FROM 
	tblICInventoryTradeFinance itf LEFT JOIN tblTRFTradeFinance tf
		ON itf.strTradeFinanceNumber = tf.strTradeFinanceNumber
WHERE
	itf.strTradeFinanceNumber = @strTransactionId

-- Update an existing trade finance record. 
IF EXISTS (SELECT TOP 1 1 FROM @TRFTradeFinance WHERE intTradeFinanceId IS NOT NULL)
BEGIN 
	EXEC [uspTRFModifyTFRecord]
		@records = @TRFTradeFinance
		, @intUserId = @intEntityUserSecurityId
		, @strAction = 'UPDATE'
		, @dtmTransactionDate = @dtmDate 

	SET @strAction = 'Updated'
END 
-- Create a new TF record
ELSE
BEGIN 
	EXEC uspTRFCreateTFRecord
		@records = @TRFTradeFinance
		, @intUserId = @intEntityUserSecurityId
		, @dtmTransactionDate = @dtmDate
		, @intTradeFinanceId = @intTradeFinanceId OUTPUT 

	SET @strAction = 'Created'
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
		strAction = @strAction + ' ' + 'Inventory Trade Finance'
		, strTransactionType = 'Inventory Finance Trade' 
		, intTradeFinanceTransactionId = tf.intTradeFinanceId
		, strTradeFinanceTransaction = tf.strTradeFinanceNumber
		, intTransactionHeaderId = itf.intInventoryTradeFinanceId
		, intTransactionDetailId = itfLot.intInventoryTradeFinanceLotId 
		, strTransactionNumber = itf.strTradeFinanceNumber
		, dtmTransactionDate = itf.dtmDateSubmitted
		, intBankTransactionId = NULL 
		, strBankTransactionId = NULL 
		, intBankId = itf.intBankId
		, strBank = ba.strBankName
		, intBankAccountId = ba.intBankAccountId
		, strBankAccount  = ba.strBankAccountNo
		, intBorrowingFacilityId = itf.intBorrowingFacilityId
		, strBorrowingFacility = fa.strBorrowingFacilityId
		, strBorrowingFacilityBankRefNo = itf.strBankReferenceNo
		, dblTransactionAmountAllocated = valuation.dblTotal
		, dblTransactionAmountActual = valuation.dblTotal
		--, intLoanLimitId 
		--, strLoanLimitNumber 
		--, strLoanLimitType 
		, intLimitId = itf.intLimitTypeId
		, strLimit = fl.strBorrowingFacilityLimit
		, dblLimit = fl.dblLimit
		, intSublimitId = itf.intSublimitTypeId
		, strSublimit = fld.strLimitDescription
		, dblSublimit = fld.dblLimit
		, strBankTradeReference = itf.strBankReferenceNo
		, dblFinanceQty = valuation.dblQty
		, dblFinancedAmount = valuation.dblTotal
		, strBankApprovalStatus = itf.strApprovalStatus
		, dtmAppliedToTransactionDate = GETDATE()
		, intStatusId = 1
				--CASE 
				--	WHEN tf.intStatusId = 1 THEN 'Active' 
				--	WHEN tf.intStatusId = 2 THEN 'Completed'
				--	WHEN tf.intStatusId = 0 THEN 'Cancelled'							
				--END
		, intWarrantId = NULL 
		, strWarrantId = itf.strWarrantNo
		, intUserId = COALESCE(itf.intModifiedByUserId, itf.intCreatedByUserId) 
		, intConcurrencyId = 1
		, intContractHeaderId = lot.intContractHeaderId
		, intContractDetailId = lot.intContractDetailId
	FROM 
		tblICInventoryTradeFinance itf
		
		LEFT JOIN tblTRFTradeFinance tf
			ON itf.strTradeFinanceNumber = tf.strTradeFinanceNumber

		LEFT JOIN (
			tblICInventoryTradeFinanceLot itfLot INNER JOIN tblICLot lot
				ON itfLot.intLotId = lot.intLotId
		)
			ON itfLot.intInventoryTradeFinanceId = itf.intInventoryTradeFinanceId				
		
		OUTER APPLY (
			SELECT 
				dblTotal = 
					SUM(
						ROUND(
							dbo.fnMultiply(
								(ISNULL(cb.dblStockIn, 0) - ISNULL(cb.dblStockOut, 0))
								,cb.dblCost
							)
							, 2
						) 
					) 
				,dblQty = SUM(
						-- convert the cost bucket to stock uom. 
						dbo.fnCalculateQtyBetweenUOM(
							cb.intItemUOMId
							,stockUOM.intItemUOMId
							,(ISNULL(cb.dblStockIn, 0) - ISNULL(cb.dblStockOut, 0))
						)						
					)
			FROM 
				tblICInventoryLot cb					
				LEFT JOIN tblICItemUOM stockUOM
					ON stockUOM.intItemId = cb.intItemId
					AND stockUOM.ysnStockUnit = 1
			WHERE
				cb.intLotId = itfLot.intLotId 
		) valuation

		LEFT JOIN vyuCMBankAccount ba 
			ON ba.intBankAccountId = itf.intBankAccountId
		LEFT JOIN tblCMBorrowingFacility fa
			ON fa.intBorrowingFacilityId = itf.intBorrowingFacilityId
		LEFT JOIN tblCMBorrowingFacilityLimit fl 
			ON fl.intBorrowingFacilityLimitId = itf.intLimitTypeId
		LEFT JOIN tblCMBorrowingFacilityLimitDetail fld
			ON fld.intBorrowingFacilityLimitDetailId = itf.intSublimitTypeId
		LEFT JOIN tblCMBankValuationRule bvr
			ON bvr.intBankValuationRuleId = itf.intOverrideFacilityValuation
	
	WHERE
		itf.strTradeFinanceNumber = @strTransactionId

	IF EXISTS (SELECT TOP 1 1 FROM @TRFLog) 
	BEGIN 
		EXEC uspTRFLogTradeFinance @TradeFinanceLogs = @TRFLog;
	END 
END 

-- Update the lot TF, Warrant No, and Warrant Status
BEGIN 
	UPDATE lot
	SET
		lot.intTradeFinanceId = tf.intTradeFinanceId
		,lot.intWarrantStatus = itf.intWarrantStatus
		,lot.strWarrantNo = itf.strWarrantNo
	FROM 
		tblICInventoryTradeFinance itf
		
		LEFT JOIN tblTRFTradeFinance tf
			ON itf.strTradeFinanceNumber = tf.strTradeFinanceNumber

		LEFT JOIN (
			tblICInventoryTradeFinanceLot itfLot INNER JOIN tblICLot lot
				ON itfLot.intLotId = lot.intLotId
		)
			ON itfLot.intInventoryTradeFinanceLotId = itf.intInventoryTradeFinanceId			
	WHERE
		itf.strTradeFinanceNumber = @strTransactionId
END
RETURN 0
