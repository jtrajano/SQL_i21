CREATE TABLE [dbo].[tblCCDealerBatchDetail]
(
	[intDealerBatchDetailId] INT NOT NULL IDENTITY,
	[intDealerDetailId] INT NULL DEFAULT 0,
	[strBatch] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblGross] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFees] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblNet] DECIMAL(18, 6) NULL DEFAULT 0, 
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCCDealerBatchDetail] PRIMARY KEY ([intDealerBatchDetailId]),
	CONSTRAINT [FK_tblCCDealerBatchDetail_tblCCDealerDetail_intDealerDetailId] FOREIGN KEY ([intDealerDetailId]) REFERENCES [dbo].[tblCCDealerDetail] ([intDealerDetailId])
)
