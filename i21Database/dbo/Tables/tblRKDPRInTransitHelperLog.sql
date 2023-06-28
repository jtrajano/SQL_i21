CREATE TABLE [dbo].[tblRKDPRInTransitHelperLog]
(
	[intDPRInTransitHelperLogId] INT IDENTITY NOT NULL , 
	[dtmDate] DATETIME,
	[intCommodityId] INT,
    [intTransactionReferenceId] INT NOT NULL, 
	[intInvoiceId] INT NULL,
	[intInventoryReceiptId] INT NULL,
    [strBucketType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [dblQty] NUMERIC(24, 10) NULL,
	[intContractDetailId] INT NULL,
	[strTransactionType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NULL DEFAULT ((1)), 
    CONSTRAINT [PK_tblRKDPRInTransitHelperLog] PRIMARY KEY ([intDPRInTransitHelperLogId])
)