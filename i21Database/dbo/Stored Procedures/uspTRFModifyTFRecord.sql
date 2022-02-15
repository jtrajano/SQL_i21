CREATE PROCEDURE [dbo].[uspTRFModifyTFRecord]
	    @records TRFTradeFinance READONLY
	  , @intUserId INT = NULL
	  , @strAction NVARCHAR(200)
	  , @dtmTransactionDate DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN	
	IF ((SELECT COUNT('') FROM @records) <> 0)
	BEGIN
		
		DECLARE @intId INT
			, @intTradeFinanceId INT
			, @strTransactionType NVARCHAR(50)
			, @strTransactionNumber NVARCHAR(100)
			, @intTransactionHeaderId INT
			, @intTransactionDetailId INT
			, @intBankId INT
			, @intBankAccountId INT
			, @intBorrowingFacilityId INT
			, @intLimitTypeId INT
			, @intSublimitTypeId INT
			, @ysnSubmittedToBank BIT
			, @dtmDateSubmitted DATETIME
			, @dtmDateApproved DATETIME
			, @strRefNo NVARCHAR(100)
			, @intOverrideFacilityValuation INT
			, @strApprovalStatus NVARCHAR(100)
			, @strCommnents NVARCHAR(MAX)
			, @intConcurrencyId INT

		SELECT * 
		INTO #tmpTRFModified 
		FROM @records

		WHILE EXISTS (SELECT TOP 1 '' FROM #tmpTRFModified)
		BEGIN
			
			SELECT @intId = NULL
				, @intTradeFinanceId = NULL
				, @strTransactionType = NULL
				, @strTransactionNumber = NULL
				, @intTransactionHeaderId = NULL
				, @intTransactionDetailId = NULL
				, @intBankId = NULL
				, @intBankAccountId  = NULL
				, @intBorrowingFacilityId = NULL
				, @intLimitTypeId = NULL
				, @intSublimitTypeId  = NULL
				, @ysnSubmittedToBank = NULL
				, @dtmDateSubmitted = NULL
				, @dtmDateApproved = NULL
				, @strRefNo = NULL
				, @intOverrideFacilityValuation = NULL
				, @strApprovalStatus = NULL
				, @strCommnents = NULL
				, @intConcurrencyId = NULL

			SELECT TOP 1 @intId = intId 
				, @intTradeFinanceId = intTradeFinanceId
				, @strTransactionType = strTransactionType
				, @strTransactionNumber = strTransactionNumber
				, @intTransactionHeaderId = intTransactionHeaderId 
				, @intTransactionDetailId = intTransactionDetailId 
				, @intBankId = intBankId
				, @intBankAccountId  = intBankAccountId
				, @intBorrowingFacilityId = intBorrowingFacilityId
				, @intLimitTypeId = intLimitTypeId
				, @intSublimitTypeId  = intSublimitTypeId
				, @ysnSubmittedToBank = ysnSubmittedToBank
				, @dtmDateSubmitted = dtmDateSubmitted
				, @dtmDateApproved = dtmDateApproved
				, @strRefNo = strRefNo
				, @intOverrideFacilityValuation = intOverrideFacilityValuation
				, @strApprovalStatus = strApprovalStatus
				, @strCommnents = strCommnents
				, @intConcurrencyId = intConcurrencyId
			FROM #tmpTRFModified

			IF (ISNULL(@intTradeFinanceId, 0) <> 0)
			BEGIN
				IF (@strAction = 'DELETE')
				BEGIN
					-- LOG DELETE HISTORY
					EXEC uspTRFTradeFinanceHistory @intTradeFinanceId, NULL, @intUserId, 'DELETE', @dtmTransactionDate

					DELETE FROM tblTRFTradeFinance 
					WHERE intTradeFinanceId = @intTradeFinanceId
				END
				ELSE IF (@strAction = 'UPDATE')
				BEGIN
					UPDATE tblTRFTradeFinance 
					SET 
						  strTransactionType = ISNULL(@strTransactionType, strTransactionType)
						, strTransactionNumber = ISNULL(@strTransactionNumber, strTransactionNumber)
						, intTransactionHeaderId = CASE WHEN @intTransactionHeaderId = 0 THEN NULL ELSE ISNULL(@intTransactionHeaderId, intTransactionHeaderId) END
						, intTransactionDetailId = CASE WHEN @intTransactionDetailId = 0 THEN NULL ELSE ISNULL(@intTransactionDetailId, intTransactionDetailId) END
						, intBankId = CASE WHEN @intBankId = 0 THEN NULL ELSE ISNULL(@intBankId, intBankId) END
						, intBankAccountId = CASE WHEN @intBankAccountId = 0 THEN NULL ELSE ISNULL(@intBankAccountId, intBankAccountId) END
						, intBorrowingFacilityId = CASE WHEN @intBorrowingFacilityId = 0 THEN NULL ELSE ISNULL(@intBorrowingFacilityId, intBorrowingFacilityId) END
						, intLimitTypeId = CASE WHEN @intLimitTypeId = 0 THEN NULL ELSE ISNULL(@intLimitTypeId, intLimitTypeId) END
						, intSublimitTypeId = CASE WHEN @intSublimitTypeId = 0 THEN NULL ELSE ISNULL(@intSublimitTypeId, intSublimitTypeId) END
						, ysnSubmittedToBank = ISNULL(@ysnSubmittedToBank, ysnSubmittedToBank)
						, dtmDateSubmitted = ISNULL(@dtmDateSubmitted, dtmDateSubmitted)
						, dtmDateApproved = ISNULL(@dtmDateApproved, dtmDateApproved)
						, strRefNo = ISNULL(@strRefNo, strRefNo)
						, intOverrideFacilityValuation = CASE WHEN @intOverrideFacilityValuation = 0 THEN NULL ELSE ISNULL(@intOverrideFacilityValuation, intOverrideFacilityValuation) END
						, strApprovalStatus = ISNULL(@strApprovalStatus, strApprovalStatus)
						, strCommnents = ISNULL(@strCommnents, strCommnents)
						, intConcurrencyId = CASE WHEN @intConcurrencyId = 0 THEN NULL ELSE ISNULL(@intConcurrencyId, intConcurrencyId) END
					WHERE intTradeFinanceId = @intTradeFinanceId

					-- LOG UPDATE HISTORY
					EXEC uspTRFTradeFinanceHistory @intTradeFinanceId, NULL, @intUserId, 'UPDATE', @dtmTransactionDate
				END
				ELSE IF (@strAction = 'UPDATE REJECTED') -- UPDATE REJECTED, PREVENT ADD NEW HISTORY RECORD. UPDATE ONLY MOST RECENT HISTORY
				BEGIN
					UPDATE tblTRFTradeFinance 
					SET 
						  strTransactionType = ISNULL(@strTransactionType, strTransactionType)
						, strTransactionNumber = ISNULL(@strTransactionNumber, strTransactionNumber)
						, intTransactionHeaderId = CASE WHEN @intTransactionHeaderId = 0 THEN NULL ELSE ISNULL(@intTransactionHeaderId, intTransactionHeaderId) END
						, intTransactionDetailId = CASE WHEN @intTransactionDetailId = 0 THEN NULL ELSE ISNULL(@intTransactionDetailId, intTransactionDetailId) END
						, intBankId = CASE WHEN @intBankId = 0 THEN NULL ELSE ISNULL(@intBankId, intBankId) END
						, intBankAccountId = CASE WHEN @intBankAccountId = 0 THEN NULL ELSE ISNULL(@intBankAccountId, intBankAccountId) END
						, intBorrowingFacilityId = CASE WHEN @intBorrowingFacilityId = 0 THEN NULL ELSE ISNULL(@intBorrowingFacilityId, intBorrowingFacilityId) END
						, intLimitTypeId = CASE WHEN @intLimitTypeId = 0 THEN NULL ELSE ISNULL(@intLimitTypeId, intLimitTypeId) END
						, intSublimitTypeId = CASE WHEN @intSublimitTypeId = 0 THEN NULL ELSE ISNULL(@intSublimitTypeId, intSublimitTypeId) END
						, ysnSubmittedToBank = ISNULL(@ysnSubmittedToBank, ysnSubmittedToBank)
						, dtmDateSubmitted = ISNULL(@dtmDateSubmitted, dtmDateSubmitted)
						, dtmDateApproved = ISNULL(@dtmDateApproved, dtmDateApproved)
						, strRefNo = ISNULL(@strRefNo, strRefNo)
						, intOverrideFacilityValuation = CASE WHEN @intOverrideFacilityValuation = 0 THEN NULL ELSE ISNULL(@intOverrideFacilityValuation, intOverrideFacilityValuation) END
						, strApprovalStatus = ISNULL(@strApprovalStatus, strApprovalStatus)
						, strCommnents = ISNULL(@strCommnents, strCommnents)
						, intConcurrencyId = CASE WHEN @intConcurrencyId = 0 THEN NULL ELSE ISNULL(@intConcurrencyId, intConcurrencyId) END
					WHERE intTradeFinanceId = @intTradeFinanceId

					DECLARE @intTradeFinanceHistoryId INT = NULL

					SELECT TOP 1 @intTradeFinanceHistoryId = intTradeFinanceHistoryId 
					FROM tblTRFTradeFinanceHistory
					WHERE intTradeFinanceId = @intTradeFinanceId
					ORDER BY intTradeFinanceHistoryId DESC

					UPDATE hist 
					SET   hist.strTransactionType = tf.strTransactionType
						, hist.strTransactionNumber = tf.strTransactionNumber
						, hist.intTransactionHeaderId = tf.intTransactionHeaderId
						, hist.intTransactionDetailId = tf.intTransactionDetailId
						, hist.strBankName = bank.strBankName
						, hist.strBankAccount = bankAccount.strBankAccountNo
						, hist.strBorrowingFacility = facility.strBorrowingFacilityId
						, hist.strBankReferenceNo = facility.strBankReferenceNo
						, hist.strLimitType = limit.strBorrowingFacilityLimit
						, hist.strSublimitType = sublimit.strLimitDescription
						, hist.ysnSubmittedToBank = tf.ysnSubmittedToBank
						, hist.dtmDateSubmitted = tf.dtmDateSubmitted
						, hist.strApprovalStatus = tf.strApprovalStatus
						, hist.dtmDateApproved = tf.dtmDateApproved
						, hist.strRefNo = tf.strRefNo
						, hist.strOverrideFacilityValuation = valuation.strBankValuationRule
						, hist.strCommnents = tf.strCommnents
						, hist.dtmCreatedDate = tf.dtmCreatedDate
						, hist.intConcurrencyId = tf.intConcurrencyId
					FROM tblTRFTradeFinanceHistory hist
					LEFT JOIN tblTRFTradeFinance tf
						ON tf.intTradeFinanceId = hist.intTradeFinanceId
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
					WHERE hist.intTradeFinanceHistoryId = @intTradeFinanceHistoryId
				END
			END

			DELETE FROM #tmpTRFModified
			WHERE intId = @intId
		END

		DROP TABLE #tmpTRFModified
	END 
END
