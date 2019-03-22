CREATE TABLE [dbo].[tblSMForBatchPosting]
(
	[intBatchPostingId] INT NOT NULL IDENTITY,
	[strBatchId] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionType] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionId] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId] INT NULL,
	[dblAmount] NUMERIC (18, 6) DEFAULT 0 NOT NULL,
	[strVendorInvoiceNumber] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[intEntityVendorId] INT NULL,
	[intEntityId] INT NULL,
	[strUserName] NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[strDescription] NVARCHAR (500) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate] DATETIME NULL,
	[ysnSelected] BIT NULL DEFAULT 0,
    [intConcurrencyId] INT NULL DEFAULT 1, 
    CONSTRAINT [PK_tblSMForBatchPosting] PRIMARY KEY ([intBatchPostingId])
) ON [PRIMARY]
