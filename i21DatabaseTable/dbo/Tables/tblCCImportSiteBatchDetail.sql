CREATE TABLE [dbo].[tblCCImportSiteBatchDetail]
(
	[intImportSiteBatchDetailId] INT NOT NULL IDENTITY,
	[intImportSiteDetailId] INT NULL DEFAULT 0,
	[strSiteBatch] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblGross] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFees] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblNet] DECIMAL(18, 6) NULL DEFAULT 0, 
	CONSTRAINT [PK_tblCCImportSiteBatchDetail] PRIMARY KEY ([intImportSiteBatchDetailId]),
	CONSTRAINT [FK_tblCCImportSiteBatchDetail_tblCCImportSiteDetail_intImportSiteDetailId] FOREIGN KEY ([intImportSiteDetailId]) REFERENCES [dbo].[tblCCImportSiteDetail] ([intImportSiteDetailId]) ON DELETE CASCADE 
	
)
