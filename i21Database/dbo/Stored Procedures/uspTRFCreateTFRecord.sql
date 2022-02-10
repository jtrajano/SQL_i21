CREATE PROCEDURE [dbo].[uspTRFCreateTFRecord]
	  @records TRFTradeFinance READONLY
	  , @intUserId INT = NULL
	  , @dtmTransactionDate DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN	
	DECLARE @strTradeFinanceNumber NVARCHAR(200) = NULL 
		, @intTradeFinanceId INT = NULL

	-- SUPPORTS ONLY 1 RECORD CREATION AT A TIME
	IF ((SELECT COUNT('') FROM @records) = 1)
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
			, strApprovalStatus
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
			, strApprovalStatus
			, strCommnents
			, dtmCreatedDate
			, intConcurrencyId
		FROM @records

		SELECT @intTradeFinanceId = SCOPE_IDENTITY()

		SELECT strTradeFinanceNumber
		INTO #tmpTradeFinance
		FROM @records


		WHILE EXISTS (SELECT TOP 1 '' FROM #tmpTradeFinance)
		BEGIN
			SELECT TOP 1 @strTradeFinanceNumber = strTradeFinanceNumber FROM #tmpTradeFinance
		
			EXEC uspTRFTradeFinanceHistory @intTradeFinanceId, NULL, @intUserId, 'ADD', @dtmTransactionDate

			DELETE FROM #tmpTradeFinance
			WHERE strTradeFinanceNumber = @strTradeFinanceNumber
		END

		DROP TABLE #tmpTradeFinance
	END
END
