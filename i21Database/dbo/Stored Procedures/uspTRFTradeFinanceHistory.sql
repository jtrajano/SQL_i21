CREATE PROCEDURE [dbo].[uspTRFTradeFinanceHistory]
	  @intTradeFinanceId INT = NULL
	, @strTradeFinanceNumber NVARCHAR(200) = NULL
	, @intUserId INT = NULL
	, @action NVARCHAR(20)
	, @dtmTransactionDate DATETIME = NULL

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		, @strUserName NVARCHAR(100)

	--DECLARE @tradeFinanceTable AS TRFTradeFinance

	SELECT @intUserId = ISNULL(@intUserId, 0)

	SELECT TOP 1 @strUserName = strName FROM tblEMEntity WHERE intEntityId = @intUserId
		
	SELECT TOP 1 *
	INTO #tmpTradeFinanceHistory
	FROM tblTRFTradeFinance 
	WHERE intTradeFinanceId = ISNULL(@intTradeFinanceId, intTradeFinanceId)
	AND strTradeFinanceNumber = ISNULL(@strTradeFinanceNumber, strTradeFinanceNumber)


	INSERT INTO tblTRFTradeFinanceHistory (
		  intTradeFinanceId
		, strTradeFinanceNumber
		, strAction
		, strTransactionType
		, strTransactionNumber
		, intTransactionHeaderId
		, intTransactionDetailId
		, strBankName
		, strBankAccount
		, strBorrowingFacility
		, strBankReferenceNo
		, strLimitType
		, strSublimitType
		, ysnSubmittedToBank
		, dtmDateSubmitted
		, strApprovalStatus
		, dtmDateApproved
		, strRefNo
		, strOverrideFacilityValuation
		, strCommnents
		, dtmCreatedDate
		, intConcurrencyId
		, strUserName
		, dtmTransactionDate
	)
	SELECT tf.intTradeFinanceId
		, tf.strTradeFinanceNumber
		, strAction = @action
		, tf.strTransactionType
		, tf.strTransactionNumber
		, tf.intTransactionHeaderId
		, tf.intTransactionDetailId
		, bank.strBankName
		, bankAccount.strBankAccountNo
		, strBorrowingFacility = facility.strBorrowingFacilityId
		, strBankReferenceNo = facility.strBankReferenceNo
		, strLimitType = limit.strBorrowingFacilityLimit
		, strSublimitType = sublimit.strLimitDescription
		, tf.ysnSubmittedToBank
		, tf.dtmDateSubmitted
		, tf.strApprovalStatus
		, tf.dtmDateApproved
		, tf.strRefNo
		, strOverrideFacilityValuation = valuation.strBankValuationRule
		, tf.strCommnents
		, tf.dtmCreatedDate
		, intConcurrencyId = @intUserId
		, strUserName = @strUserName
		, dtmTransactionDate = @dtmTransactionDate
	
	FROM #tmpTradeFinanceHistory tf
	LEFT JOIN tblCMBank bank
		ON bank.intBankId = tf.intBankId
	LEFT JOIN vyuCMBankAccount bankAccount
		ON bankAccount.intBankAccountId = tf.intBankAccountId
	LEFT JOIN tblCMBorrowingFacility facility
		ON facility.intBorrowingFacilityId = tf.intBorrowingFacilityId
	LEFT JOIN tblCMBorrowingFacilityLimit limit
		ON limit.intBorrowingFacilityLimitId = intLimitTypeId
	LEFT JOIN tblCMBorrowingFacilityLimitDetail sublimit
		ON sublimit.intBorrowingFacilityLimitDetailId = tf.intSublimitTypeId
	LEFT JOIN tblCMBankValuationRule valuation
		ON valuation.intBankValuationRuleId = tf.intOverrideFacilityValuation

	DROP TABLE #tmpTradeFinanceHistory
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH