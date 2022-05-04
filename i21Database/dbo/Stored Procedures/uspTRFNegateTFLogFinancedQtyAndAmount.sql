CREATE PROCEDURE [dbo].[uspTRFNegateTFLogFinancedQtyAndAmount]
		@strTradeFinanceNumber NVARCHAR(100)
	  , @strTransactionType NVARCHAR(100) 
	  , @strLimitType NVARCHAR(100) 
	  , @dtmTransactionDate DATETIME
	  , @strAction NVARCHAR(100)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

BEGIN	
	DECLARE @trfTable TRFLog

	-- REMOVE MILLISECOND TO MAKE NEGATE RECORD APPEAR AS EARLIER THAN THE NEW LOG TO BE CREATED.
	SELECT @dtmTransactionDate = CAST(CONVERT(VARCHAR(10), @dtmTransactionDate, 101) + ' '  + convert(VARCHAR(8), @dtmTransactionDate, 14) AS DATETIME)

	-- RETRIEVE LATEST LOG FOR THE SELECTED PARAMETERS.
	SELECT TOP 1 * 
	INTO #tmpTRFLogNegateStaging
	FROM tblTRFTradeFinanceLog
	WHERE strTradeFinanceTransaction = @strTradeFinanceNumber
	AND strTransactionType = CASE WHEN ISNULL(@strTransactionType, '') = '' THEN strTransactionType ELSE @strTransactionType END
	AND strLimit = CASE WHEN ISNULL(@strLimitType, '') = '' THEN strLimit ELSE @strLimitType END
	ORDER BY dtmCreatedDate DESC

	-- CHECK IF LATEST LOG CONTAINS QTY AND AMOUNT TO BE NEGATED. 
	-- IF FINANCE QTY <= 0, WILL NOT BE CREATING NEGATE LOG DUE TO NO QTY TO BE NEGATED OR QTY WAS ALREADY NEGATED
	IF EXISTS (SELECT TOP 1 '' FROM #tmpTRFLogNegateStaging)
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
			, intUserId
			, intConcurrencyId
			, ysnNegateLog
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
			, intUserId
			, intConcurrencyId
			, ysnNegateLog = CAST(1 AS BIT)
		FROM #tmpTRFLogNegateStaging
	END

	DROP TABLE #tmpTRFLogNegateStaging

	IF EXISTS (SELECT TOP 1 '' FROM @trfTable)
	BEGIN
		EXEC uspTRFLogTradeFinance @trfTable
	END
END