CREATE TABLE [dbo].[tblFABookDepreciation](
	[intBookDepreciationId] [int] IDENTITY(1,1) NOT NULL,
	[intDepreciationMethodId] [int] NOT NULL,
	[intAssetId] [int] NOT NULL,
	[dblCost] [numeric](18, 6) NULL,
	[dblSalvageValue] [numeric](18, 6) NULL,
	[dblSection179] [numeric](18, 6) NULL,
	[dblBonusDepreciation] [numeric](18, 6) NULL,
	[dtmPlacedInService] [datetime] NOT NULL,
	[ysnFullyDepreciated] BIT NULL,
	[intConcurrencyId] [int] DEFAULT 1 NOT NULL,
	[intBookId] [int] NULL,
	[intCurrencyId]					[int] NULL,
	[intFunctionalCurrencyId]		[int] NULL,
	[intCurrencyExchangeRateTypeId] [int] NULL,
	[dblRate]						NUMERIC(18, 6) NULL DEFAULT ((1)),
	[dblFunctionalCost]				NUMERIC(18, 6) NULL,
	[dblFunctionalSalvageValue]		NUMERIC(18, 6) NULL,
	[dblFunctionalSection179]		NUMERIC(18, 6) NULL,
	[dblFunctionalBonusDepreciation] NUMERIC(18, 6) NULL,
	[dblMarketValue]				NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dblFunctionalMarketValue]		NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dblInsuranceValue]				NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dblFunctionalInsuranceValue]	NUMERIC(18, 6) NULL DEFAULT ((0)),
	[intLedgerId]					INT NULL,
	[dtmImportDepThruDate]			[datetime] NOT NULL,
	[dblImportDepreciationToDate]	NUMERIC(18, 6) NULL DEFAULT ((0)),
 CONSTRAINT [PK_tblFABookDepreciation] PRIMARY KEY CLUSTERED 
(
	[intBookDepreciationId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY], 
	CONSTRAINT [FK_tblFABookDepreciation_tblSMCurrency] FOREIGN KEY([intCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
	CONSTRAINT [FK_tblFABookDepreciation_tblSMCurrency2] FOREIGN KEY([intFunctionalCurrencyId]) REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID]),
	CONSTRAINT [FK_tblFABookDepreciation_tblSMCurrencyExchangeRateType] FOREIGN KEY([intCurrencyExchangeRateTypeId]) REFERENCES [dbo].[tblSMCurrencyExchangeRateType] ([intCurrencyExchangeRateTypeId])
) ON [PRIMARY]
GO

GO

ALTER TABLE [dbo].[tblFABookDepreciation]  WITH CHECK ADD  CONSTRAINT [FK_tblFABookDepreciation_tblFADepreciationMethod] FOREIGN KEY([intDepreciationMethodId])
REFERENCES [dbo].[tblFADepreciationMethod] ([intDepreciationMethodId])
GO

ALTER TABLE [dbo].[tblFABookDepreciation] CHECK CONSTRAINT [FK_tblFABookDepreciation_tblFADepreciationMethod]
GO

ALTER TABLE [dbo].[tblFABookDepreciation]  WITH CHECK ADD  CONSTRAINT [FK_tblFABookDepreciation_tblFAFixedAsset] FOREIGN KEY([intAssetId])
REFERENCES [dbo].[tblFAFixedAsset] ([intAssetId])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[tblFABookDepreciation] CHECK CONSTRAINT [FK_tblFABookDepreciation_tblFAFixedAsset]
GO

