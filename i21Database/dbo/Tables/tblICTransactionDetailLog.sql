CREATE TABLE [dbo].[tblICTransactionDetailLog]
(
	[intTransactionDetailLogId] INT NOT NULL IDENTITY, 
    [strTransactionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intTransactionId] INT NOT NULL, 
    [intTransactionDetailId] INT NOT NULL, 
    [intOrderNumberId] INT NULL, 
	[intOrderType] INT NOT NULL DEFAULT((0)),
    [intSourceNumberId] INT NULL, 
	[intSourceType] INT NOT NULL DEFAULT((0)),
    [intLineNo] INT NULL, 
    [intItemId] INT NULL, 
	[strItemType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [intItemUOMId] INT NULL, 
    [dblQuantity] NUMERIC(38, 20) NOT NULL DEFAULT ((0)), 
	[ysnLoad] BIT NULL DEFAULT((0)),
	[intLoadReceive] INT NULL DEFAULT ((0)),
	[dblGross] NUMERIC(38, 20) NULL DEFAULT ((0)), 
	[dblNet] NUMERIC(38, 20) NULL DEFAULT ((0)), 
	[intSourceInventoryDetailId] INT NULL,
	[intCompanyId] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 

	[strTransactionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dtmReceiptDate] [datetime] NULL DEFAULT (GETDATE()),
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

    CONSTRAINT [PK_tblICTransactionDetailLog] PRIMARY KEY ([intTransactionDetailLogId]) 
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICTransactionDetailLog]
	ON [dbo].[tblICTransactionDetailLog]([strTransactionType] ASC, [intTransactionId] ASC);
GO
