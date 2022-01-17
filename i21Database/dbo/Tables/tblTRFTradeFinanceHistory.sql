CREATE TABLE [dbo].[tblTRFTradeFinanceHistory]
(
	intTradeFinanceHistoryId INT IDENTITY(1,1) NOT NULL,
	intTradeFinanceId INT NULL,
	strTransactionType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	intTransactionHeaderId INT NULL,
	intTransactionDetailId INT NULL,
	strBankName NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strBankAccount NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strBorrowingFacility NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strBankReferenceNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strLimitType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strSublimitType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	ysnSubmmitedToBank NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	dtmDateSubmitted DATETIME NULL,
	strApprovalStatus NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,	
	dtmDateApproved DATETIME NULL,
	strRefNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,	
	strOverrideFacilityValuation INT NULL,
	strCommnents NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,	
	dtmTransactionDate DATETIME NULL,
	dtmCreatedDate DATETIME NULL DEFAULT(GETDATE()),
    [intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblTRFTradeFinanceHistory] PRIMARY KEY ([intTradeFinanceHistoryId])
)
GO