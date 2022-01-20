CREATE PROCEDURE [dbo].[uspTRFCreateTFRecord]
	  @records TRFTradeFinance READONLY
	  , @intUserId INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN	
	INSERT INTO tblTRFTradeFinance (
		  strTradeFinanceNumber
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
		, dtmDateApproved
		, strRefNo
		, intOverrideFacilityValuation
		, strCommnents
		, dtmCreatedDate
		, intConcurrencyId
	)
	SELECT strTradeFinanceNumber
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
		, dtmDateApproved
		, strRefNo
		, intOverrideFacilityValuation
		, strCommnents
		, dtmCreatedDate
		, intConcurrencyId
	FROM @records

	SELECT strTradeFinanceNumber
	INTO #tmpTradeFinance
	FROM @records

	DECLARE @strTradeFinanceNumber NVARCHAR(200) = NULL 

	WHILE EXISTS (SELECT TOP 1 '' FROM #tmpTradeFinance)
	BEGIN
		SELECT TOP 1 @strTradeFinanceNumber = strTradeFinanceNumber FROM #tmpTradeFinance
		
		EXEC uspTRFTradeFinanceHistory NULL, @strTradeFinanceNumber, @intUserId, 'ADD'

		DELETE FROM #tmpTradeFinance
		WHERE strTradeFinanceNumber = @strTradeFinanceNumber
	END

	DROP TABLE #tmpTradeFinance
END
