CREATE TABLE [dbo].[tblTRFTradeFinance]
(
	intTradeFinanceId INT IDENTITY NOT NULL,
	strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intTransactionHeaderId INT NULL,
	intTransactionDetailId INT NULL,
	intBankId INT NULL,
	intBankAccountId INT NULL,
	intBorrowingFacilityId INT NULL,
	intLimitTypeId INT NULL,
	intSublimitTypeId INT NULL,
	ysnSubmittedToBank BIT NULL, 
	dtmDateSubmitted DATETIME NULL,
	strApprovalStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,	
	dtmDateApproved DATETIME NULL,
	strRefNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,	
	intOverrideFacilityValuation INT NULL,
	strCommnents NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,	
	dtmCreatedDate DATETIME NULL DEFAULT(GETDATE()),
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTRFTradeFinance] PRIMARY KEY ([intTradeFinanceId]),
	CONSTRAINT [FK_tblTRFTradeFinance_tblCMBank_intBankId] FOREIGN KEY ([intBankId]) REFERENCES [tblCMBank] ([intBankId]),
	CONSTRAINT [FK_tblTRFTradeFinance_tblCMBankAccount_intBankAccountId] FOREIGN KEY ([intBankAccountId]) REFERENCES [tblCMBankAccount]([intBankAccountId]),
	CONSTRAINT [FK_tblTRFTradeFinance_tblCMBorrowingFacility_intBorrowingFacilityId] FOREIGN KEY ([intBorrowingFacilityId]) REFERENCES [tblCMBorrowingFacility] ([intBorrowingFacilityId])
)
GO