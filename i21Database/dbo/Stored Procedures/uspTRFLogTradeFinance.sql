CREATE PROCEDURE [dbo].[uspTRFLogTradeFinance]
	  @TradeFinanceLogs TRFLog READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

BEGIN	
	DECLARE @intId INT
		, @strAction NVARCHAR(100)
		, @strTransactionType NVARCHAR(100)
		, @intTradeFinanceTransactionId INT
		, @strTradeFinanceTransaction NVARCHAR(100)
		, @intTransactionHeaderId INT
		, @intTransactionDetailId INT
		, @strTransactionNumber NVARCHAR(100)
		, @dtmTransactionDate DATETIME
		, @intBankTransactionId INT
		, @strBankTransactionId NVARCHAR(100)
		, @intBankId INT
		, @strBank NVARCHAR(500)
		, @intBankAccountId INT
		, @strBankAccount NVARCHAR(MAX)
		, @intBorrowingFacilityId INT
		, @strBorrowingFacility NVARCHAR(200) 
		, @strBorrowingFacilityBankRefNo NVARCHAR(100) 
		, @dblTransactionAmountAllocated DECIMAL(24, 10)
		, @dblTransactionAmountActual DECIMAL(24, 10)
		, @intLoanLimitId INT
		, @strLoanLimitNumber NVARCHAR(100)
		, @strLoanLimitType NVARCHAR(100)
		, @intLimitId INT
		, @strLimit NVARCHAR(200)
		, @dblLimit DECIMAL(24, 10)
		, @intSublimitId INT 
		, @strSublimit NVARCHAR(200)
		, @dblSublimit DECIMAL(24, 10)
		, @strBankTradeReference NVARCHAR(100) 
		, @dblFinanceQty DECIMAL(24, 10) 
		, @dblFinancedAmount DECIMAL(24, 10) 
		, @strBankApprovalStatus NVARCHAR(100) 
		, @dtmAppliedToTransactionDate DATETIME
		, @intStatusId INT
		, @intWarrantId INT
		, @strWarrantId NVARCHAR(100)
		, @intWarrantStatusId INT
		, @intUserId INT
		, @intConcurrencyId INT
		, @intContractHeaderId INT
		, @intContractDetailId INT
		, @intTotal INT
		, @ysnNegateLog BIT
		, @ysnDeleted BIT
		, @ysnMarkOnlyDeleted BIT
		, @ysnReverseLog BIT
		, @intOverrideBankValuationId INT 
		, @strOverrideBankValuation NVARCHAR(200)

	DECLARE @FinalTable AS TABLE (
		  strAction NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		, intTradeFinanceTransactionId INT NULL
		, strTradeFinanceTransaction NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, intTransactionHeaderId INT NULL
		, intTransactionDetailId INT NULL
		, strTransactionNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		, dtmTransactionDate DATETIME NULL
		, intBankTransactionId INT NULL
		, strBankTransactionId NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, intBankId INT NULL
		, strBank NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL
		, intBankAccountId INT NULL
		, strBankAccount NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		, intBorrowingFacilityId INT NULL
		, strBorrowingFacility NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		, strBorrowingFacilityBankRefNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, dblTransactionAmountAllocated DECIMAL(24, 10) NULL
		, dblTransactionAmountActual DECIMAL(24, 10) NULL
		, intLoanLimitId INT NULL
		, strLoanLimitNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, strLoanLimitType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, intLimitId INT NULL
		, strLimit NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		, dblLimit DECIMAL(24, 10) NULL DEFAULT((0))
		, intSublimitId INT NULL
		, strSublimit NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		, dblSublimit DECIMAL(24, 10) NULL DEFAULT((0))
		, strBankTradeReference NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, dblFinanceQty DECIMAL(24, 10) NULL DEFAULT((0))
		, dblFinancedAmount DECIMAL(24, 10) NULL DEFAULT((0))
		, strBankApprovalStatus NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, dtmAppliedToTransactionDate DATETIME NULL
		, intStatusId INT NULL
		, intWarrantId INT NULL
		, strWarrantId NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, intWarrantStatusId INT NULL
		, intUserId INT NULL
		, intConcurrencyId INT NULL
		, intContractHeaderId INT NULL
		, intContractDetailId INT NULL
		, ysnNegateLog BIT NULL DEFAULT(0)
		, ysnDeleted BIT NULL DEFAULT(0)
		, ysnMarkOnlyDeleted BIT NULL DEFAULT(0)
		, ysnReverseLog BIT NULL DEFAULT(0)
		, intOverrideBankValuationId INT NULL
		, strOverrideBankValuation NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	)

	DECLARE @deletedTable TABLE (
		  intId INT
		, strTradeFinanceTransaction NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		, strTransactionNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL
		, intTransactionHeaderId INT NULL
		, intTransactionDetailId INT NULL
		, dtmTransactionDate DATETIME NULL
	)

	SELECT @intTotal = COUNT(*) FROM @TradeFinanceLogs

	SELECT * INTO #tmpTradeFinanceLogs FROM @TradeFinanceLogs ORDER BY dtmTransactionDate

	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpTradeFinanceLogs)
	BEGIN

		SELECT @intId = NULL
		    , @strAction = NULL
			, @strTransactionType = NULL
			, @intTradeFinanceTransactionId = NULL
			, @strTradeFinanceTransaction = NULL
			, @intTransactionHeaderId = NULL
			, @intTransactionDetailId = NULL
			, @strTransactionNumber = NULL
			, @dtmTransactionDate = NULL
			, @intBankTransactionId = NULL
			, @strBankTransactionId = NULL
			, @intBankId = NULL
			, @strBank = NULL
			, @intBankAccountId = NULL
			, @strBankAccount = NULL
			, @intBorrowingFacilityId = NULL
			, @strBorrowingFacility = NULL
			, @strBorrowingFacilityBankRefNo = NULL
			, @dblTransactionAmountAllocated = NULL
			, @dblTransactionAmountActual = NULL
			, @intLoanLimitId = NULL
			, @strLoanLimitNumber = NULL
			, @strLoanLimitType = NULL
			, @intLimitId = NULL
			, @strLimit = NULL
			, @dblLimit = NULL
			, @intSublimitId = NULL 
			, @strSublimit = NULL
			, @dblSublimit = NULL
			, @strBankTradeReference = NULL
			, @dblFinanceQty = NULL
			, @dblFinancedAmount = NULL
			, @strBankApprovalStatus = NULL
			, @dtmAppliedToTransactionDate = NULL
			, @intStatusId = NULL
			, @intWarrantId = NULL
			, @strWarrantId = NULL
			, @intWarrantStatusId = NULL
			, @intUserId = NULL
			, @intConcurrencyId = NULL
			, @intContractHeaderId = NULL
			, @intContractDetailId = NULL
			, @ysnNegateLog = NULL
			, @ysnDeleted = NULL
			, @ysnMarkOnlyDeleted = NULL
			, @ysnReverseLog = NULL
			, @intOverrideBankValuationId = NULL
			, @strOverrideBankValuation = NULL

		SELECT TOP 1 
		      @intId = tfLog.intId
			, @strAction = tfLog.strAction
			, @strTransactionType = tfLog.strTransactionType
			, @intTradeFinanceTransactionId = tfLog.intTradeFinanceTransactionId
			, @strTradeFinanceTransaction = CASE WHEN ISNULL(tfLog.strTradeFinanceTransaction, '') <> '' THEN tfLog.strTradeFinanceTransaction ELSE tf.strTradeFinanceNumber END COLLATE Latin1_General_CI_AS
			, @intTransactionHeaderId = tfLog.intTransactionHeaderId
			, @intTransactionDetailId = tfLog.intTransactionDetailId
			, @strTransactionNumber = tfLog.strTransactionNumber
			, @dtmTransactionDate = tfLog.dtmTransactionDate
			, @intBankTransactionId = tfLog.intBankTransactionId
			, @strBankTransactionId = CASE WHEN ISNULL(tfLog.strBankTransactionId, '') <> '' THEN tfLog.strBankTransactionId ELSE bankTrans.strTransactionId END  COLLATE Latin1_General_CI_AS
			, @intBankId = tfLog.intBankId
			, @strBank = CASE WHEN ISNULL(tfLog.strBank, '') <> '' THEN tfLog.strBank ELSE bank.strBankName END  COLLATE Latin1_General_CI_AS
			, @intBankAccountId = tfLog.intBankAccountId
			, @strBankAccount = CASE WHEN ISNULL(tfLog.strBankAccount, '') <> '' THEN tfLog.strBankAccount ELSE bankAcct.strBankAccountNo END COLLATE Latin1_General_CI_AS
			, @intBorrowingFacilityId = tfLog.intBorrowingFacilityId
			, @strBorrowingFacility = CASE WHEN ISNULL(tfLog.strBorrowingFacility, '') <> '' THEN tfLog.strBorrowingFacility ELSE facility.strBorrowingFacilityId END COLLATE Latin1_General_CI_AS
			, @strBorrowingFacilityBankRefNo = CASE WHEN ISNULL(tfLog.strBorrowingFacilityBankRefNo, '') <> '' THEN tfLog.strBorrowingFacilityBankRefNo ELSE facility.strBankReferenceNo END COLLATE Latin1_General_CI_AS
			, @dblTransactionAmountAllocated = tfLog.dblTransactionAmountAllocated
			, @dblTransactionAmountActual = tfLog.dblTransactionAmountActual
			, @intLoanLimitId = tfLog.intLoanLimitId
			, @strLoanLimitNumber = CASE WHEN ISNULL(tfLog.strLoanLimitNumber, '') <> '' THEN tfLog.strLoanLimitNumber ELSE loan.strBankLoanId END COLLATE Latin1_General_CI_AS
			, @strLoanLimitType = CASE WHEN ISNULL(tfLog.strLoanLimitType, '') <> '' THEN tfLog.strLoanLimitType ELSE loan.strLimitDescription END COLLATE Latin1_General_CI_AS
			, @intLimitId = tfLog.intLimitId
			, @strLimit = CASE WHEN ISNULL(tfLog.strLimit, '') <> '' THEN tfLog.strLimit ELSE limit.strBorrowingFacilityLimit END COLLATE Latin1_General_CI_AS
			, @dblLimit = tfLog.dblLimit
			, @intSublimitId = tfLog.intSublimitId 
			, @strSublimit = CASE WHEN ISNULL(tfLog.strSublimit, '') <> '' THEN tfLog.strSublimit ELSE sublimit.strLimitDescription END COLLATE Latin1_General_CI_AS   
			, @dblSublimit = tfLog.dblSublimit
			, @strBankTradeReference = tfLog.strBankTradeReference 
			, @dblFinanceQty = tfLog.dblFinanceQty 
			, @dblFinancedAmount = tfLog.dblFinancedAmount 
			, @strBankApprovalStatus = tfLog.strBankApprovalStatus 
			, @dtmAppliedToTransactionDate = tfLog.dtmAppliedToTransactionDate
			, @intStatusId = tfLog.intStatusId
			, @intWarrantId = tfLog.intWarrantId
			, @strWarrantId = tfLog.strWarrantId
			, @intWarrantStatusId = tfLog.intWarrantStatusId
			, @intUserId = tfLog.intUserId
			, @intConcurrencyId = tfLog.intConcurrencyId
			, @intContractHeaderId = tfLog.intContractHeaderId
			, @intContractDetailId = tfLog.intContractDetailId
			, @ysnNegateLog = tfLog.ysnNegateLog
			, @ysnDeleted = tfLog.ysnDeleted
			, @ysnMarkOnlyDeleted = tfLog.ysnMarkOnlyDeleted
			, @ysnReverseLog = tfLog.ysnReverseLog
			, @intOverrideBankValuationId = tfLog.intOverrideBankValuationId
			, @strOverrideBankValuation = CASE WHEN ISNULL(tfLog.strOverrideBankValuation, '') <> '' THEN tfLog.strOverrideBankValuation ELSE bankValuation.strBankValuationRule END COLLATE Latin1_General_CI_AS
		
		FROM #tmpTradeFinanceLogs tfLog
		LEFT JOIN tblCMBank bank
			ON bank.intBankId = tfLog.intBankId
		LEFT JOIN vyuCMBankAccount bankAcct
			ON bankAcct.intBankAccountId = tfLog.intBankAccountId
		LEFT JOIN tblCMBorrowingFacilityLimit limit
			ON limit.intBorrowingFacilityLimitId = tfLog.intLimitId
		LEFT JOIN tblCMBorrowingFacilityLimitDetail sublimit
			ON sublimit.intBorrowingFacilityLimitDetailId = tfLog.intSublimitId
		LEFT JOIN tblCMBankLoan loan
			ON loan.intBankLoanId = tfLog.intLoanLimitId
		LEFT JOIN tblTRFTradeFinance tf
			ON tf.intTradeFinanceId = tfLog.intTradeFinanceTransactionId
		LEFT JOIN tblCMBankTransaction bankTrans
			ON bankTrans.intTransactionId = tfLog.intBankTransactionId
		LEFT JOIN tblCMBorrowingFacility facility
			ON facility.intBorrowingFacilityId = tfLog.intBorrowingFacilityId
		LEFT JOIN tblCMBankValuationRule bankValuation
			ON bankValuation.intBankValuationRuleId = tfLog.intOverrideBankValuationId

		INSERT INTO @FinalTable(
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
				 , intLoanLimitId
				 , strLoanLimitNumber
				 , strLoanLimitType
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
				 , intWarrantStatusId
				 , intUserId
				 , intConcurrencyId
				 , intContractHeaderId
				 , intContractDetailId
				 , ysnNegateLog
				 , ysnDeleted
				 , ysnMarkOnlyDeleted
				 , ysnReverseLog
				 , intOverrideBankValuationId
				 , strOverrideBankValuation
			)
			SELECT @strAction
				 , @strTransactionType
				 , @intTradeFinanceTransactionId
				 , @strTradeFinanceTransaction
				 , @intTransactionHeaderId
				 , @intTransactionDetailId
				 , @strTransactionNumber
				 , @dtmTransactionDate
				 , @intBankTransactionId
				 , @strBankTransactionId
				 , @intBankId
				 , @strBank
				 , @intBankAccountId
				 , @strBankAccount
				 , @intBorrowingFacilityId 
				 , @strBorrowingFacility 
				 , @strBorrowingFacilityBankRefNo
				 , @dblTransactionAmountAllocated
				 , @dblTransactionAmountActual
				 , @intLoanLimitId
				 , @strLoanLimitNumber
				 , @strLoanLimitType
				 , @intLimitId
				 , @strLimit
				 , @dblLimit 
				 , @intSublimitId 
				 , @strSublimit
				 , @dblSublimit
				 , @strBankTradeReference 
				 , @dblFinanceQty 
				 , @dblFinancedAmount 
				 , @strBankApprovalStatus 
				 , @dtmAppliedToTransactionDate
				 , @intStatusId
				 , @intWarrantId
				 , @strWarrantId
				 , @intWarrantStatusId
				 , @intUserId
				 , @intConcurrencyId
				 , @intContractHeaderId
				 , @intContractDetailId
				 , @ysnNegateLog
				 , @ysnDeleted
				 , @ysnMarkOnlyDeleted
				 , @ysnReverseLog
				 , @intOverrideBankValuationId
				 , @strOverrideBankValuation
				 
		-- CREATION OF NEGATE LOGS.
		IF (ISNULL(@ysnNegateLog, 0) = 0 AND ISNULL(@ysnDeleted, 0) = 0)
		BEGIN
			DECLARE @strActionNegate NVARCHAR(100) = 'Moved to ' + @strTransactionType

			IF ISNULL(@ysnMarkOnlyDeleted, 0) = 1
			BEGIN
				-- MARK ALL LOGS WITHIN THIS TRANSACTION AS DELETED TO BE EXCLUDED ON CHECKING OF NEGATE/REVERSE LOGS.
				UPDATE tblTRFTradeFinanceLog
				SET ysnDeleted = 1
				WHERE strTradeFinanceTransaction = @strTradeFinanceTransaction
				AND strTransactionNumber = @strTransactionNumber
				AND strTransactionType = @strTransactionType
				AND intTransactionHeaderId = @intTransactionHeaderId
				AND ISNULL(intTransactionDetailId, 0) = ISNULL(@intTransactionDetailId, 0)
			END

			EXEC uspTRFNegateTFLogFinancedQtyAndAmount 
					  @strTradeFinanceNumber = @strTradeFinanceTransaction
					, @strTransactionType = NULL
					, @strLimitType = NULL
					, @dtmTransactionDate = @dtmTransactionDate
					, @strAction = @strActionNegate
					, @ysnReverse = 0
					, @ysnMarkOnlyDeleted = @ysnMarkOnlyDeleted
		END

		-- ADDED TO LIST FOR CREATION OF REVERSAL LOGS.
		IF (ISNULL(@ysnDeleted, 0) = 1)
		BEGIN
			INSERT INTO @deletedTable (
				  intId
				, strTradeFinanceTransaction
				, strTransactionType
				, strTransactionNumber
				, intTransactionHeaderId
				, intTransactionDetailId
				, dtmTransactionDate
			)
			SELECT @intId
				, @strTradeFinanceTransaction
				, @strTransactionType
				, @strTransactionNumber
				, @intTransactionHeaderId
				, @intTransactionDetailId
				, @dtmTransactionDate
		END

		DELETE FROM #tmpTradeFinanceLogs
		WHERE intId = @intId
	END

	DECLARE @dtmCreatedDate DATETIME = GETDATE()

	INSERT INTO tblTRFTradeFinanceLog(
		  dtmCreatedDate
		, strAction
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
		, intLoanLimitId
		, strLoanLimitNumber
		, strLoanLimitType
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
		, intWarrantStatusId
		, intUserId
		, intConcurrencyId
		, intContractHeaderId
		, intContractDetailId
		, ysnDeleted
		, intOverrideBankValuationId
		, strOverrideBankValuation
	)
							-- REMOVE MILLISECOND TO MAKE NEGATE/DELETE LOG RECORD APPEAR AS EARLIER THAN THE NEW LOG TO BE CREATED.
	SELECT dtmCreatedDate = CASE WHEN (ISNULL(ysnNegateLog, 0) = 1 AND ISNULL(@ysnReverseLog, 0) = 0) OR ISNULL(@ysnDeleted, 0) = 1
								THEN CAST(CONVERT(VARCHAR(10), @dtmCreatedDate, 101) + ' '  + convert(VARCHAR(8), @dtmCreatedDate, 14) AS DATETIME)
								ELSE @dtmCreatedDate
								END
		, strAction
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
		, intLoanLimitId
		, strLoanLimitNumber
		, strLoanLimitType
		, intLimitId
		, strLimit
		, dblLimit 
		, intSublimitId 
		, strSublimit
		, dblSublimit
		, strBankTradeReference 
						-- DELETE ACTION WILL CONTAIN THE NEGATE QTY. ANOTHER LOG WILL BE CREATED TO ADD BACK QTY TO PREV. TRANSACTION/MODULE.
		, dblFinanceQty = CASE WHEN ISNULL(ysnDeleted, 0) = 1 THEN -ABS(dblFinanceQty) ELSE dblFinanceQty END
		, dblFinancedAmount = CASE WHEN ISNULL(ysnDeleted, 0) = 1 THEN -ABS(dblFinancedAmount) ELSE dblFinancedAmount END
		, strBankApprovalStatus 
		, dtmAppliedToTransactionDate
		, intStatusId
		, intWarrantId
		, strWarrantId
		, intWarrantStatusId
		, intUserId
		, intConcurrencyId
		, intContractHeaderId
		, intContractDetailId
		, ysnDeleted = CASE WHEN ISNULL(ysnMarkOnlyDeleted, 0) = 1 THEN 1 ELSE ysnDeleted END
		, intOverrideBankValuationId
		, strOverrideBankValuation
	FROM @FinalTable F
	ORDER BY dtmTransactionDate

	-- DELETE SCENARIO:
	-- CREATION OF REVERSAL LOG FOR THE PREVIOUS TRANSACTION/MODULE (WILL CREATE NEW LOG ON PREVIOUS TRANSACTION NEGATED QTY).
	IF (ISNULL(@ysnDeleted, 0) = 1)
	BEGIN
		WHILE EXISTS (SELECT TOP 1 '' FROM @deletedTable)
		BEGIN
			SELECT @intId = NULL
				, @strTradeFinanceTransaction = NULL
				, @strTransactionNumber = NULL
				, @strTransactionType = NULL
				, @dtmTransactionDate = NULL
				, @intTransactionHeaderId = NULL
				, @intTransactionDetailId = NULL

			SELECT TOP 1 @intId = intId
				, @strTradeFinanceTransaction = strTradeFinanceTransaction
				, @strTransactionNumber = strTransactionNumber
				, @strTransactionType = strTransactionType
				, @intTransactionHeaderId = intTransactionHeaderId
				, @intTransactionDetailId = intTransactionDetailId
				, @dtmTransactionDate = dtmTransactionDate
			FROM @deletedTable

			-- MARK ALL LOGS WITHIN THIS TRANSACTION AS DELETED TO BE EXCLUDED ON CHECKING OF NEGATE/REVERSE LOGS.
			UPDATE tblTRFTradeFinanceLog
			SET ysnDeleted = 1
			WHERE strTradeFinanceTransaction = @strTradeFinanceTransaction
			AND strTransactionNumber = @strTransactionNumber
			AND strTransactionType = @strTransactionType
			AND intTransactionHeaderId = @intTransactionHeaderId
			AND ISNULL(intTransactionDetailId, 0) = ISNULL(@intTransactionDetailId, 0)

			-- REVERSAL
			EXEC uspTRFNegateTFLogFinancedQtyAndAmount 
					  @strTradeFinanceNumber = @strTradeFinanceTransaction
					, @strTransactionType = @strTransactionType
					, @strLimitType = NULL
					, @dtmTransactionDate = @dtmTransactionDate
					, @strAction = NULL
					, @ysnReverse = 1
			
			DELETE FROM @deletedTable
			WHERE  intId = @intId
		END
	END

	DROP TABLE #tmpTradeFinanceLogs
END
