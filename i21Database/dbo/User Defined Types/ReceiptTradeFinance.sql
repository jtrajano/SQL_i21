/*
	This is a user-defined table type used in sp uspICAddItemReceipt to add Lot Records 
*/
CREATE TYPE [dbo].[ReceiptTradeFinance] AS TABLE
	(
		[intId] INT IDENTITY PRIMARY KEY CLUSTERED

		--Following fields are needed to match the Receipt
		,[intEntityVendorId] INT NULL
		,[strReceiptType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,[intLocationId] INT NULL    
		,[intShipViaId] INT NULL 
		,[intShipFromId] INT NULL	
		,[intCurrencyId] INT NULL		
		,[intSourceType] INT NULL  
		,[strBillOfLadding] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,[strVendorRefNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,[intShipFromEntityId] INT NULL 

		,[strTradeFinanceNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL
		,[intBankId] INT NULL
		,[intBankAccountId] INT NULL
		,[intBorrowingFacilityId] INT NULL
		,[strBankReferenceNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
		,[intLimitTypeId] INT NULL
		,[intSublimitTypeId] INT NULL
		,[ysnSubmittedToBank] BIT NULL 
		,[dtmDateSubmitted] DATETIME NULL
		,[strApprovalStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL	
		,[dtmDateApproved] DATETIME NULL
		,[strWarrantNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL	
		,[intWarrantStatus] INT NULL
		,[strReferenceNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL	
		,[intOverrideFacilityValuation] INT NULL
		,[strComments] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	)