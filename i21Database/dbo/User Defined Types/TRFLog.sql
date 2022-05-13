CREATE TYPE [dbo].[TRFLog] AS TABLE (
	  intId INT IDENTITY PRIMARY KEY CLUSTERED
	, strAction NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
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
	, ysnReverseLog BIT NULL DEFAULT(0)
)