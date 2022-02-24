CREATE PROCEDURE [dbo].[uspTRFLogTradeFinance]
	  @TradeFinanceLogs TRFLog READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

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
		, @strBank NVARCHAR(200)
		, @intBankAccountId INT
		, @strBankAccount NVARCHAR(200)
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
		, @intUserId INT
		, @intConcurrencyId INT
		, @intContractHeaderId INT
		, @intContractDetailId INT
		, @intTotal INT

	DECLARE @FinalTable AS TABLE (
		  strAction NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		, intTradeFinanceTransactionId INT NULL
		, strTradeFinanceTransaction NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		, intTransactionHeaderId INT NULL
		, intTransactionDetailId INT NULL
		, strTransactionNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		, dtmTransactionDate DATETIME NULL
		, intBankTransactionId INT NULL
		, strBankTransactionId NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		, intBankId INT NULL
		, strBank NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
		, intBankAccountId INT NULL
		, strBankAccount NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
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
		, intUserId INT NULL
		, intConcurrencyId INT NULL
		, intContractHeaderId INT NULL
		, intContractDetailId INT NULL
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
			, @intUserId = NULL
			, @intConcurrencyId = NULL
			, @intContractHeaderId = NULL
			, @intContractDetailId = NULL

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
			, @intUserId = tfLog.intUserId
			, @intConcurrencyId = tfLog.intConcurrencyId
			, @intContractHeaderId = tfLog.intContractHeaderId
			, @intContractDetailId = tfLog.intContractDetailId
		
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
				 , intUserId
				 , intConcurrencyId
				 , intContractHeaderId
				 , intContractDetailId)
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
				 , @intUserId
				 , @intConcurrencyId
				 , @intContractHeaderId
				 , @intContractDetailId

		DELETE FROM #tmpTradeFinanceLogs
		WHERE intId = @intId
	END

	DECLARE @dtmCreatedDate DATETIME = GETDATE() --GETUTCDATE()

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
		, intUserId
		, intConcurrencyId
		, intContractHeaderId
		, intContractDetailId)
	SELECT dtmCreatedDate = @dtmCreatedDate
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
		, intUserId
		, intConcurrencyId
		, intContractHeaderId
		, intContractDetailId
	FROM @FinalTable F
	ORDER BY dtmTransactionDate

	DROP TABLE #tmpTradeFinanceLogs
END
