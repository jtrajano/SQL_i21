CREATE TABLE [dbo].[tblCCImportSiteDetail]
(
	[intImportSiteDetailId] INT NOT NULL IDENTITY,
	[intImportSiteHeaderId] INT NULL DEFAULT 0,
	[strSite] nvarchar(50) COLLATE Latin1_General_CI_AS NULL,
	[dblGross] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFees] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblNet] DECIMAL(18, 6) NULL DEFAULT 0, 
	CONSTRAINT [PK_tblCCImportSiteDetail] PRIMARY KEY ([intImportSiteDetailId]),
	CONSTRAINT [FK_tblCCImportSiteDetail_tblCCImportSiteHeader_intImportSiteHeaderId] FOREIGN KEY ([intImportSiteHeaderId]) REFERENCES [dbo].[tblCCImportSiteHeader] ([intImportSiteHeaderId]) ON DELETE CASCADE 
)
