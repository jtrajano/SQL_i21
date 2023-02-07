CREATE PROCEDURE [dbo].[uspTRFBankLoanLineActivityReport]
	  @intBankId INT = NULL
	, @intApprovalStatusId INT = NULL
	, @strLimitType NVARCHAR(50)
	, @dtmStartDate DATE = NULL
	, @dtmEndDate DATE = NULL

AS

BEGIN
 	IF ISNULL(@strLimitType, '') = ''
 	BEGIN
 		SET @strLimitType = NULL
 	END
	
 	IF ISNULL(@intApprovalStatusId, 0) = 0
 	BEGIN
 		SET @intApprovalStatusId = NULL
 	END

	IF ISNULL(@intBankId, 0) = 0
 	BEGIN
 		SET @intBankId = NULL
 	END

	SELECT 
		  intRowNumber = ROW_NUMBER() OVER (ORDER BY dtmCreatedDate, strTradeFinanceTransaction, strBank, strLimit, strSublimit)
		, dtmCreatedDate
		, strTradeFinanceTransaction
		, strBank
		, strTransactionNumber
		, strBankTradeReference
		, strLimit
		, strSublimit
		, strAction
		, dblFinanceQty
		, strBankApprovalStatus
		, strBankValuationRule
		, intConcurrencyId = 1
	FROM 
	(
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY t1.strTradeFinanceTransaction, t1.strBank, t1.strLimit, t1.strSublimit
											ORDER BY t1.dtmCreatedDate DESC)
				, * 
		FROM
		(
			-- GET LATEST LOG BY TRADE FINANCE NUMBER AND TRANSACTION NUMBER FIRST BEFORE GROUPING BY BANK, LIMIT AND SUBLIMIT.
			SELECT intGroupNum = ROW_NUMBER() OVER (PARTITION BY tfLog.strTradeFinanceTransaction, tfLog.strTransactionNumber
											ORDER BY tfLog.dtmCreatedDate DESC)
				, tfLog.intBankId
				, intApprovalStatusId = approvalStatus.intApprovalStatusId
				, tfLog.dtmCreatedDate
				, tfLog.strTradeFinanceTransaction
				, tfLog.strBank
				, tfLog.strTransactionNumber
				, tfLog.strBankTradeReference
				, tfLog.strLimit
				, tfLog.strSublimit
				, tfLog.strAction
				, tfLog.dblFinanceQty
				, tfLog.strBankApprovalStatus
				, strBankValuationRule = CASE WHEN ISNULL(tfLog.intOverrideBankValuationId, 0) = 0 
											THEN valRule.strBankValuationRule 
											ELSE tfLog.strOverrideBankValuation END
			FROM tblTRFTradeFinanceLog tfLog
			LEFT JOIN tblCMBorrowingFacilityLimitDetail sublimit
				ON sublimit.intBorrowingFacilityLimitDetailId = intSublimitId
			LEFT JOIN tblCMBankValuationRule valRule
				ON valRule.intBankValuationRuleId = sublimit.intBankValuationRuleId
			LEFT JOIN tblCTApprovalStatusTF approvalStatus
				ON approvalStatus.strApprovalStatus COLLATE Latin1_General_CI_AS = tfLog.strBankApprovalStatus
			OUTER APPLY (
				SELECT TOP 1 ysnDeleted = CAST(1 AS BIT)
				FROM tblTRFTradeFinanceLog tLog
				WHERE tfLog.ysnDeleted = 1
				AND CAST(tLog.dtmCreatedDate AS DATE) >= CAST(ISNULL(@dtmStartDate, tLog.dtmCreatedDate) AS DATE)
				AND CAST(tLog.dtmCreatedDate AS DATE) <= CAST(ISNULL(@dtmEndDate, tLog.dtmCreatedDate) AS DATE)
				AND UPPER(LEFT(strAction, 6)) = 'DELETE'
				AND tfLog.strTransactionNumber = tLog.strTransactionNumber
				AND tfLog.intTransactionHeaderId = tLog.intTransactionHeaderId
				AND tfLog.intTransactionDetailId = tLog.intTransactionDetailId
				AND tfLog.strTradeFinanceTransaction = tLog.strTradeFinanceTransaction
			) deletedRecord
			WHERE CAST(tfLog.dtmCreatedDate AS DATE) >= CAST(ISNULL(@dtmStartDate, tfLog.dtmCreatedDate) AS DATE)
			AND CAST(tfLog.dtmCreatedDate AS DATE) <= CAST(ISNULL(@dtmEndDate, tfLog.dtmCreatedDate) AS DATE)
			AND tfLog.dblFinanceQty >= 0
			AND ISNULL(deletedRecord.ysnDeleted, 0) = 0
		) t1
		WHERE t1.intGroupNum = 1

	) t WHERE t.intRowNum = 1
		AND ISNULL(t.intBankId, 0) = ISNULL(@intBankId, ISNULL(t.intBankId, 0))
		AND ISNULL(t.intApprovalStatusId, '') = ISNULL(@intApprovalStatusId, ISNULL(t.intApprovalStatusId, ''))
		AND ISNULL(t.strLimit, '') = ISNULL(@strLimitType, ISNULL(t.strLimit, ''))
END