CREATE TABLE [dbo].[tblTRFTradeFinanceLog]
(
	intTradeFinanceLogId INT IDENTITY(1,1) NOT NULL,
	dtmCreatedDate DATETIME NULL DEFAULT(GETDATE()),
	strAction NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,	
	strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	intTradeFinanceTransactionId INT NULL,
	strTradeFinanceTransaction NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	intTransactionHeaderId INT NULL,
	intTransactionDetailId INT NULL,
	strTransactionNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	dtmTransactionDate DATETIME NULL,
	intContractHeaderId INT NULL,
	intContractDetailId INT NULL,
	intBankId INT NULL,
	strBank NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	intBankAccountId INT NULL,
	strBankAccount NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	intBorrowingFacilityId INT NULL,
	strBorrowingFacility NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	strBorrowingFacilityBankRefNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	intBankTransactionId INT NULL,
	strBankTransactionId NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	dblTransactionAmountAllocated DECIMAL(24, 10) NULL DEFAULT((0)),
	dblTransactionAmountActual DECIMAL(24, 10) NULL DEFAULT((0)),
	intLoanLimitId INT NULL,
	strLoanLimitNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strLoanLimitType NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	intLimitId INT NULL,
	strLimit NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	dblLimit DECIMAL(24, 10) NULL DEFAULT((0)),
	intSublimitId INT NULL,
	strSublimit NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	dblSublimit DECIMAL(24, 10) NULL DEFAULT((0)),
	strBankTradeReference NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	dblFinanceQty DECIMAL(24, 10) NULL DEFAULT((0)),
	dblFinancedAmount DECIMAL(24, 10) NULL DEFAULT((0)),
	strBankApprovalStatus NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	dtmAppliedToTransactionDate DATETIME NULL,
	intStatusId INT NULL,
	intWarrantId INT NULL,
	strWarrantId NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	intUserId INT NULL, 
	ysnDeleted BIT NULL DEFAULT(0),
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTRFTradeFinanceLog] PRIMARY KEY ([intTradeFinanceLogId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblTRFTradeFinanceLog_intContractDetailId]
	ON [dbo].[tblTRFTradeFinanceLog] ([intContractDetailId]);   
GO 

CREATE NONCLUSTERED INDEX [IX_tblTRFTradeFinanceLog_intContractHeaderId]
	ON [dbo].[tblTRFTradeFinanceLog] ([intContractHeaderId]);   
GO 