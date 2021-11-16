CREATE TYPE [dbo].[TRFLog] AS TABLE (
	  intId INT IDENTITY PRIMARY KEY CLUSTERED
	, strAction NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
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