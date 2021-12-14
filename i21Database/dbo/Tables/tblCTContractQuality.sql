
CREATE TABLE [dbo].[tblCTContractQuality](
	[intQualityId] [int] IDENTITY(1,1) NOT NULL,
	[intSampleId] [int] NOT NULL,
	[intContractDetailId] [int] NOT NULL,
	[intItemId] [int] NULL,
	[intPropertyId] [int] NULL,
	[strPropertyName] [nvarchar](100) COLLATE Latin1_General_CI_AS  NULL,
	[dblTargetValue] [numeric](18, 6) NULL,
	[dblMinValue] [numeric](18, 6) NULL,
	[dblMaxValue] [numeric](18, 6) NULL,
	[dblFactorOverTarget] [numeric](18, 6) NULL,
	[dblPremium] [numeric](18, 6) NULL,
	[dblFactorUnderTarget] [numeric](18, 6) NULL,
	[dblDiscount] [numeric](18, 6) NULL,
	[strCostMethod] [nvarchar](100) NULL,
	[intCurrencyId] [int] NULL,
	[intUnitMeasureId] [int] NULL,
	[strCurrency] [nvarchar](100) COLLATE Latin1_General_CI_AS  NULL,
	[strUnitMeasure] [nvarchar](100) COLLATE Latin1_General_CI_AS  NULL,
	[dblActualValue] [numeric](18, 6) NULL,
	[ysnImpactPricing] [bit] NULL,
	[intConcurrencyId] [int] NULL,
	CONSTRAINT [PK_tblCTContractQuality] PRIMARY KEY CLUSTERED ([intQualityId] ASC),
	CONSTRAINT [FK_tblCTContractQuality_tblICUnitMeasure] FOREIGN KEY([intUnitMeasureId]) REFERENCES [dbo].[tblICUnitMeasure] ([intUnitMeasureId]),
	CONSTRAINT [FK_tblCTContractQuality_tblSMCurrency] FOREIGN KEY([intCurrencyId])REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID])
)


GO

ALTER TABLE [dbo].[tblCTContractQuality] ADD  DEFAULT ((0)) FOR [intConcurrencyId]
GO
