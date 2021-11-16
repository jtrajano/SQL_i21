CREATE PROCEDURE [dbo].[uspTRFLogTradeFinance]
	  @TradeFinanceLogs TRFLog READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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
		, @dblTransactionAmountAllocated DECIMAL(24, 10)
		, @dblTransactionAmountActual DECIMAL(24, 10)
		, @intLoanLimitId INT
		, @strLoanLimitNumber NVARCHAR(100)
		, @strLoanLimitType NVARCHAR(100)
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
			, dblTransactionAmountAllocated DECIMAL(24, 10) NULL
			, dblTransactionAmountActual DECIMAL(24, 10) NULL
			, intLoanLimitId INT NULL
			, strLoanLimitNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
			, strLoanLimitType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
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
			, @dblTransactionAmountAllocated = NULL
			, @dblTransactionAmountActual = NULL
			, @intLoanLimitId = NULL
			, @strLoanLimitNumber = NULL
			, @strLoanLimitType = NULL
			, @dtmAppliedToTransactionDate = NULL
			, @intStatusId = NULL
			, @intWarrantId = NULL
			, @strWarrantId = NULL
			, @intUserId = NULL
			, @intConcurrencyId = NULL
			, @intContractHeaderId = NULL
			, @intContractDetailId = NULL

		SELECT TOP 1 
		      @intId = intId
			, @strAction = strAction
			, @strTransactionType = strTransactionType
			, @intTradeFinanceTransactionId = intTradeFinanceTransactionId
			, @strTradeFinanceTransaction = strTradeFinanceTransaction
			, @intTransactionHeaderId = intTransactionHeaderId
			, @intTransactionDetailId = intTransactionDetailId
			, @strTransactionNumber = strTransactionNumber
			, @dtmTransactionDate = dtmTransactionDate
			, @intBankTransactionId = intBankTransactionId
			, @strBankTransactionId = strBankTransactionId
			, @dblTransactionAmountAllocated = dblTransactionAmountAllocated
			, @dblTransactionAmountActual = dblTransactionAmountActual
			, @intLoanLimitId = intLoanLimitId
			, @strLoanLimitNumber = strLoanLimitNumber
			, @strLoanLimitType = strLoanLimitType
			, @dtmAppliedToTransactionDate = dtmAppliedToTransactionDate
			, @intStatusId = intStatusId
			, @intWarrantId = intWarrantId
			, @strWarrantId = strWarrantId
			, @intUserId = intUserId
			, @intConcurrencyId = intConcurrencyId
			, @intContractHeaderId = intContractHeaderId
			, @intContractDetailId = intContractDetailId
		
		FROM #tmpTradeFinanceLogs
		
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
				 , dblTransactionAmountAllocated
				 , dblTransactionAmountActual
				 , intLoanLimitId
				 , strLoanLimitNumber
				 , strLoanLimitType
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
				 , @dblTransactionAmountAllocated
				 , @dblTransactionAmountActual
				 , @intLoanLimitId
				 , @strLoanLimitNumber
				 , @strLoanLimitType
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

	DECLARE @dtmCreatedDate DATETIME = GETUTCDATE()

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
		, dblTransactionAmountAllocated
		, dblTransactionAmountActual
		, intLoanLimitId
		, strLoanLimitNumber
		, strLoanLimitType
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
		, dblTransactionAmountAllocated
		, dblTransactionAmountActual
		, intLoanLimitId
		, strLoanLimitNumber
		, strLoanLimitType
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
