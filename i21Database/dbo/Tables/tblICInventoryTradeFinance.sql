/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
CREATE TABLE [dbo].[tblICInventoryTradeFinance]
(
	[intInventoryTradeFinanceId] [int] IDENTITY NOT NULL,
	[strTradeFinanceNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intLocationId] INT NULL,
	[intBankId] INT NULL,
	[intBankAccountId] INT NULL,
	[intBorrowingFacilityId] INT NULL,
	[strBankReferenceNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,	
	[intLimitTypeId] INT NULL,
	[intSublimitTypeId] INT NULL,
	[ysnSubmittedToBank] BIT NULL, 
	[dtmDateSubmitted] DATETIME NULL,
	[strApprovalStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,	
	[dtmDateApproved] DATETIME NULL,
	[strWarrantNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,	
	[intWarrantStatus] INT NULL,
	[strReferenceNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,	
	[intOverrideFacilityValuation] INT NULL,
	[strComments] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,	
	[ysnCommit] BIT NULL, 

	[intConcurrencyId] [int] NULL DEFAULT ((0)),
	[dtmDateCreated] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [intCreatedByUserId] INT NULL,
    [intModifiedByUserId] INT NULL,

	CONSTRAINT [PK_tblICInventoryTradeFinance] PRIMARY KEY ([intInventoryTradeFinanceId]), 
	CONSTRAINT [AK_tblICInventoryTradeFinance_strTradeFinanceNumber] UNIQUE ([strTradeFinanceNumber]), 
	CONSTRAINT [FK_tblICInventoryTradeFinance_tblCMBank_intBankId] FOREIGN KEY ([intBankId]) REFERENCES [tblCMBank] ([intBankId]),
	CONSTRAINT [FK_tblICInventoryTradeFinance_tblCMBankAccount_intBankAccountId] FOREIGN KEY ([intBankAccountId]) REFERENCES [tblCMBankAccount]([intBankAccountId]),
	CONSTRAINT [FK_tblICInventoryTradeFinance_tblCMBorrowingFacility_intBorrowingFacilityId] FOREIGN KEY ([intBorrowingFacilityId]) REFERENCES [tblCMBorrowingFacility] ([intBorrowingFacilityId])
)
GO