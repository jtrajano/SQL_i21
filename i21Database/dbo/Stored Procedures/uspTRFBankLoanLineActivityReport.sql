CREATE PROCEDURE [dbo].[uspTRFBankLoanLineActivityReport]
	  @intBankId INT = NULL
	, @intApprovalStatusId INT = NULL
	, @strLimitType NVARCHAR(50)
	, @dtmStartDate DATETIME = NULL
	, @dtmEndDate DATETIME = NULL

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
	FROM 
	(
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY tfLog.strTradeFinanceTransaction, tfLog.strBank, tfLog.strLimit, tfLog.strSublimit
										ORDER BY tfLog.dtmCreatedDate DESC)
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
			, valRule.strBankValuationRule
		FROM tblTRFTradeFinanceLog tfLog
		LEFT JOIN tblCMBorrowingFacilityLimitDetail sublimit
			ON sublimit.intBorrowingFacilityLimitDetailId = intSublimitId
		LEFT JOIN tblCMBankValuationRule valRule
			ON valRule.intBankValuationRuleId = sublimit.intBankValuationRuleId
		LEFT JOIN tblCTApprovalStatusTF approvalStatus
			ON approvalStatus.strApprovalStatus COLLATE Latin1_General_CI_AS = tfLog.strBankApprovalStatus  COLLATE Latin1_General_CI_AS
		WHERE ISNULL(tfLog.intBankId, 0) = ISNULL(@intBankId, ISNULL(tfLog.intBankId, 0))
		AND ISNULL(approvalStatus.intApprovalStatusId, '') = ISNULL(@intApprovalStatusId, ISNULL(approvalStatus.intApprovalStatusId, ''))
		AND ISNULL(tfLog.strLimit, '') = ISNULL(@strLimitType, ISNULL(tfLog.strLimit, ''))
		AND CONVERT(NVARCHAR, tfLog.dtmCreatedDate, 111) >= CONVERT(NVARCHAR, ISNULL(@dtmStartDate, tfLog.dtmCreatedDate), 111)
		AND CONVERT(NVARCHAR, tfLog.dtmCreatedDate, 111) <= CONVERT(NVARCHAR, ISNULL(@dtmEndDate, tfLog.dtmCreatedDate), 111)
		AND tfLog.dblFinanceQty >= 0
	) t WHERE t.intRowNum = 1
END