CREATE TABLE [dbo].[tblCCImportDealerDetail]
(
	[intImportDealerDetailId] INT NOT NULL IDENTITY,
	[intImportDealerHeaderId] INT NULL DEFAULT 0,
	[strDealerSite] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblGross] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFees] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblNet] DECIMAL(18, 6) NULL DEFAULT 0, 
	CONSTRAINT [PK_tblCCImportDealerDetail] PRIMARY KEY ([intImportDealerDetailId]),
	CONSTRAINT [FK_tblCCImportDealerDetail_tblCCImportDealerHeader_intImportDealerHeaderId] FOREIGN KEY ([intImportDealerHeaderId]) REFERENCES [dbo].[tblCCImportDealerHeader] ([intImportDealerHeaderId]) 
)
