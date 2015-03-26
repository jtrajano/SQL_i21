CREATE TABLE [dbo].[tblCCSiteBatchDetail]
(
	[intSiteBatchDetailId] INT NOT NULL IDENTITY,
	[intSiteDetailId] INT NULL DEFAULT 0,
	[strBatch] nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblGross] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFees] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblNet] DECIMAL(18, 6) NULL DEFAULT 0, 
	[intSort] [int] NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCCSiteBatchDetail] PRIMARY KEY ([intSiteBatchDetailId]),
	CONSTRAINT [FK_tblCCSiteBatchDetail_tblCCSiteDetail_intSiteDetailId] FOREIGN KEY ([intSiteDetailId]) REFERENCES [dbo].[tblCCSiteDetail] ([intSiteDetailId]) ON DELETE CASCADE
)
