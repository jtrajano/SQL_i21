CREATE TABLE [dbo].[tblFABookDepreciation](
	[intBookDepreciationId] [int] IDENTITY(1,1) NOT NULL,
	[intDepreciationMethodId] [int] NOT NULL,
	[intAssetId] [int] NOT NULL,
	[dblCost] [numeric](18, 6) NOT NULL,
	[dblSalvageValue] [numeric](18, 6) NOT NULL,
	[dtmPlacedInService] [datetime] NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intBookId] [int] NULL,
 CONSTRAINT [PK_tblFABookDepreciation] PRIMARY KEY CLUSTERED 
(
	[intBookDepreciationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[tblFABookDepreciation]  WITH CHECK ADD  CONSTRAINT [FK_tblFABookDepreciation_tblFADepreciationMethod] FOREIGN KEY([intDepreciationMethodId])
REFERENCES [dbo].[tblFADepreciationMethod] ([intDepreciationMethodId])
GO

ALTER TABLE [dbo].[tblFABookDepreciation] CHECK CONSTRAINT [FK_tblFABookDepreciation_tblFADepreciationMethod]
GO

ALTER TABLE [dbo].[tblFABookDepreciation]  WITH CHECK ADD  CONSTRAINT [FK_tblFABookDepreciation_tblFAFixedAsset] FOREIGN KEY([intAssetId])
REFERENCES [dbo].[tblFAFixedAsset] ([intAssetId])
GO

ALTER TABLE [dbo].[tblFABookDepreciation] CHECK CONSTRAINT [FK_tblFABookDepreciation_tblFAFixedAsset]
GO

