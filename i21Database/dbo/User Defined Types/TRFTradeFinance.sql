CREATE TYPE [dbo].[TRFTradeFinance] AS TABLE (
	  intId INT IDENTITY PRIMARY KEY CLUSTERED
	, intTradeFinanceId INT NULL
	, strTradeFinanceNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, strTransactionNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, intTransactionHeaderId INT NULL
	, intTransactionDetailId INT NULL
	, intBankId INT NULL
	, intBankAccountId INT NULL
	, intBorrowingFacilityId INT NULL
	, intLimitTypeId INT NULL
	, intSublimitTypeId INT NULL
	, ysnSubmittedToBank BIT NULL
	, dtmDateSubmitted DATETIME NULL
	, strApprovalStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL	
	, dtmDateApproved DATETIME NULL
	, strRefNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL	
	, intOverrideFacilityValuation INT NULL
	, strCommnents NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL	
	, dtmCreatedDate DATETIME NULL DEFAULT(GETDATE())
    , [intConcurrencyId] INT NULL DEFAULT ((1))
)