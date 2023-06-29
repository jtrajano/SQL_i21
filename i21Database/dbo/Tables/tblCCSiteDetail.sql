﻿CREATE TABLE [dbo].[tblCCSiteDetail]
(
	[intSiteDetailId] INT NOT NULL IDENTITY,
	[intSiteHeaderId] INT NULL DEFAULT 0,
	[intSiteId] INT NULL DEFAULT 0,
	[dblGross] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblFees] DECIMAL(18, 6) NULL DEFAULT 0, 
	[dblNet] DECIMAL(18, 6) NULL DEFAULT 0, 
	[intSort] [int] NULL,
	[strTransactionSource] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCCSiteDetail] PRIMARY KEY ([intSiteDetailId]),
	CONSTRAINT [FK_tblCCSiteDetail_tblCCSiteHeader_intSiteHeaderId] FOREIGN KEY ([intSiteHeaderId]) REFERENCES [dbo].[tblCCSiteHeader] ([intSiteHeaderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCCSiteDetail_tblCCSite_intSiteId] FOREIGN KEY ([intSiteId]) REFERENCES [dbo].[tblCCSite] ([intSiteId]),
)
GO

CREATE NONCLUSTERED INDEX [IX_tblCCSiteDetail_intSiteHeaderId] ON [dbo].[tblCCSiteDetail] ([intSiteHeaderId])
GO

CREATE NONCLUSTERED INDEX [IX_tblCCSiteDetail_intSiteId] ON [dbo].[tblCCSiteDetail] ([intSiteId])
GO
