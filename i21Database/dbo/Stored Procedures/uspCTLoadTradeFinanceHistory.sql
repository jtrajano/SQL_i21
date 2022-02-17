Create PROCEDURE [dbo].[uspCTLoadTradeFinanceHistory]
	@intContractDetailId	INT
AS
	SELECT	intTradeFinanceHistoryId
			,intTradeFinanceId
			,strTradeFinanceNumber
			,strAction
			,strTransactionType
			,strTransactionNumber
			,intTransactionHeaderId
			,intTransactionDetailId
			,strBankName
			,strBankName
			,strBankAccount
			,strBorrowingFacility
			,strBankReferenceNo
			,strLimitType
			,strSublimitType
			,ysnSubmittedToBank
			,dtmDateSubmitted = CASE WHEN dtmDateSubmitted = '1900-01-01' THEN NULL ELSE dtmDateSubmitted END
			,strApprovalStatus
			,dtmDateApproved = CASE WHEN dtmDateApproved = '1900-01-01' THEN NULL ELSE dtmDateApproved END
			,strRefNo
			,strOverrideFacilityValuation
			,strCommnents
			,strUserName
			,dtmTransactionDate
			,dtmCreatedDate
			,intConcurrencyId
	FROM [tblTRFTradeFinanceHistory]
	WHERE intTransactionDetailId = @intContractDetailId



