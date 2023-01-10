CREATE PROCEDURE [dbo].[uspTRFNegateTFLogFinancedQtyAndAmount]
		@strTradeFinanceNumber NVARCHAR(100)
	  , @strTransactionType NVARCHAR(100) 
	  , @strLimitType NVARCHAR(100) 
	  , @dtmTransactionDate DATETIME
	  , @strAction NVARCHAR(100)
	  , @ysnReverse BIT = 0
	  , @ysnMarkOnlyDeleted BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

BEGIN	
	DECLARE @trfTable TRFLog

	IF @ysnReverse = 0
	BEGIN
		-- REMOVE MILLISECOND TO MAKE NEGATE RECORD APPEAR AS EARLIER THAN THE NEW LOG TO BE CREATED.
		SELECT @dtmTransactionDate = CAST(CONVERT(VARCHAR(10), @dtmTransactionDate, 101) + ' '  + convert(VARCHAR(8), @dtmTransactionDate, 14) AS DATETIME)
	END

	-- RETRIEVE LATEST LOG FOR THE SELECTED PARAMETERS.
	SELECT TOP 1 * 
	INTO #tmpTRFLogNegateStaging
	FROM tblTRFTradeFinanceLog
	WHERE strTradeFinanceTransaction = @strTradeFinanceNumber
	AND (	(ISNULL(@ysnMarkOnlyDeleted, 0) = 0
			AND ISNULL(ysnDeleted, 0) = 0
			-- IF REVERSE, THE BASIS WILL BE ALL THE NEGATE LOG OF PREVIOUS TRANSACTION/MODULE.
			AND ((@ysnReverse = 1 AND dblFinanceQty < 0)
				  OR
				 (@ysnReverse = 0))
			)
			OR
			ISNULL(@ysnMarkOnlyDeleted, 0) = 1
			AND ( ISNULL(ysnDeleted, 0) = 0
				  OR
				 (ISNULL(ysnDeleted, 0) = 1 AND ISNULL(dblFinanceQty, 0) > 0)
				)
		)
	ORDER BY dtmCreatedDate DESC, intTradeFinanceLogId DESC

	-- CHECK IF LATEST LOG CONTAINS QTY AND AMOUNT TO BE NEGATED. 
	-- IF FINANCE QTY <= 0, WILL NOT BE CREATING NEGATE LOG DUE TO NO QTY TO BE NEGATED OR QTY WAS ALREADY NEGATED.
	IF  @ysnReverse = 0 
		AND EXISTS (SELECT TOP 1 '' FROM #tmpTRFLogNegateStaging)
		AND ISNULL((SELECT TOP 1 dblFinanceQty FROM #tmpTRFLogNegateStaging), 0) > 0
	BEGIN
		INSERT INTO @trfTable (
			  strAction
			, strTransactionType
			, intTradeFinanceTransactionId
			, strTradeFinanceTransaction
			, intTransactionHeaderId
			, intTransactionDetailId
			, strTransactionNumber
			, dtmTransactionDate
			, intContractHeaderId
			, intContractDetailId
			, intBankId
			, intBankAccountId
			, intBorrowingFacilityId
			, intBankTransactionId
			, dblTransactionAmountAllocated
			, dblTransactionAmountActual
			, intLoanLimitId
			, intLimitId
			, dblLimit
			, intSublimitId
			, dblSublimit
			, strBankTradeReference
			, dblFinanceQty 
			, dblFinancedAmount
			, strBankApprovalStatus
			, dtmAppliedToTransactionDate
			, intStatusId 
			, intWarrantId
			, strWarrantId
			, intWarrantStatusId
			, intUserId
			, intConcurrencyId
			, ysnNegateLog
			, intOverrideBankValuationId
			, strOverrideBankValuation
			, ysnMarkOnlyDeleted
		)
		SELECT @strAction
			, strTransactionType
			, intTradeFinanceTransactionId
			, strTradeFinanceTransaction
			, intTransactionHeaderId
			, intTransactionDetailId
			, strTransactionNumber
			, dtmTransactionDate = @dtmTransactionDate
			, intContractHeaderId
			, intContractDetailId
			, intBankId
			, intBankAccountId
			, intBorrowingFacilityId
			, intBankTransactionId
			, dblTransactionAmountAllocated
			, dblTransactionAmountActual
			, intLoanLimitId
			, intLimitId
			, dblLimit
			, intSublimitId
			, dblSublimit
			, strBankTradeReference
			, dblFinanceQty = dblFinanceQty * -1
			, dblFinancedAmount = dblFinancedAmount * -1
			, strBankApprovalStatus
			, dtmAppliedToTransactionDate
			, intStatusId 
			, intWarrantId
			, strWarrantId
			, intWarrantStatusId
			, intUserId
			, intConcurrencyId
			, ysnNegateLog = CAST(1 AS BIT)
			, intOverrideBankValuationId
			, strOverrideBankValuation
			, @ysnMarkOnlyDeleted
		FROM #tmpTRFLogNegateStaging
	END
	ELSE IF (@ysnReverse = 1)
		AND EXISTS (SELECT TOP 1 '' FROM #tmpTRFLogNegateStaging)
	BEGIN 
		INSERT INTO @trfTable (
			  strAction
			, strTransactionType
			, intTradeFinanceTransactionId
			, strTradeFinanceTransaction
			, intTransactionHeaderId
			, intTransactionDetailId
			, strTransactionNumber
			, dtmTransactionDate
			, intContractHeaderId
			, intContractDetailId
			, intBankId
			, intBankAccountId
			, intBorrowingFacilityId
			, intBankTransactionId
			, dblTransactionAmountAllocated
			, dblTransactionAmountActual
			, intLoanLimitId
			, intLimitId
			, dblLimit
			, intSublimitId
			, dblSublimit
			, strBankTradeReference
			, dblFinanceQty 
			, dblFinancedAmount
			, strBankApprovalStatus
			, dtmAppliedToTransactionDate
			, intStatusId 
			, intWarrantId
			, strWarrantId
			, intWarrantStatusId
			, intUserId
			, intConcurrencyId
			, ysnNegateLog
			, ysnReverseLog
			, intOverrideBankValuationId
			, strOverrideBankValuation
		)
		SELECT strAction = 'Moved to ' + strTransactionType --@strAction
			, strTransactionType
			, intTradeFinanceTransactionId
			, strTradeFinanceTransaction
			, intTransactionHeaderId
			, intTransactionDetailId
			, strTransactionNumber
			, dtmTransactionDate = @dtmTransactionDate
			, intContractHeaderId
			, intContractDetailId
			, intBankId
			, intBankAccountId
			, intBorrowingFacilityId
			, intBankTransactionId
			, dblTransactionAmountAllocated
			, dblTransactionAmountActual
			, intLoanLimitId
			, intLimitId
			, dblLimit
			, intSublimitId
			, dblSublimit
			, strBankTradeReference
			, dblFinanceQty = ABS(dblFinanceQty)
			, dblFinancedAmount = ABS(dblFinancedAmount)
			, strBankApprovalStatus
			, dtmAppliedToTransactionDate
			, intStatusId 
			, intWarrantId
			, strWarrantId
			, intWarrantStatusId
			, intUserId
			, intConcurrencyId
			, ysnNegateLog = CAST(1 AS BIT)
			, ysnReverseLog = @ysnReverse
			, intOverrideBankValuationId
			, strOverrideBankValuation
		FROM #tmpTRFLogNegateStaging
	END

	DROP TABLE #tmpTRFLogNegateStaging

	IF EXISTS (SELECT TOP 1 '' FROM @trfTable)
	BEGIN
		EXEC uspTRFLogTradeFinance @trfTable
	END
END