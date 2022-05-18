/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryReceiptBeforeSave]
	(
		[intInventoryReceiptLogId] [int] IDENTITY NOT NULL,
		[intInventoryReceiptId] [int] NOT NULL,
		[strTradeFinanceNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
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
		CONSTRAINT [PK_tblICInventoryReceiptBeforeSave] PRIMARY KEY ([intInventoryReceiptLogId])
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryReceiptBeforeSave_intInventoryReceiptId]
		ON [dbo].[tblICInventoryReceiptBeforeSave]([intInventoryReceiptId] ASC)

	GO
