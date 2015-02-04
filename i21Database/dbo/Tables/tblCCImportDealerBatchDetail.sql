CREATE TABLE [dbo].[tblCCImportDealerBatchDetail]
(
	[intImportDealerBatchDetailId] INT NOT NULL IDENTITY,
	[intImportDealerDetailId] INT NULL DEFAULT 0,
	[strDealerBatch] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblGross] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFees] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblNet] DECIMAL(18, 6) NULL DEFAULT 0, 
	CONSTRAINT [PK_tblCCImportDealerBatchDetail] PRIMARY KEY ([intImportDealerBatchDetailId]),
	CONSTRAINT [FK_tblCCImportDealerBatchDetail_tblCCImportDealerDetail_intImportDealerDetailId] FOREIGN KEY ([intImportDealerDetailId]) REFERENCES [dbo].[tblCCImportDealerDetail] ([intImportDealerDetailId]) 
	
)
