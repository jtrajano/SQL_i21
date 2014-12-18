CREATE TABLE [dbo].[tblCTCostType](
	[intCostTypeId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intFreightTermId] [int] NULL,
	[strCostTypeName] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[ysnInventoryCost] [bit] NOT NULL CONSTRAINT [DF_tblCTCostType_ysnInventoryCost]  DEFAULT ((0)),
	[ysnAccrue] [bit] NOT NULL CONSTRAINT [DF_tblCTCostType_ysnAccrue]  DEFAULT ((0)),
	[ysnMTM] [bit] NOT NULL CONSTRAINT [DF_tblCTCostType_ysnMTM]  DEFAULT ((0)),
	[ysnPrice] [bit] NOT NULL CONSTRAINT [DF_tblCTCostType_ysnPrice]  DEFAULT ((0)),
	[intCostMethod] [int] NOT NULL,
	[dblAmount] [numeric](12, 4) NOT NULL,
	[intUnitMeasureId] [int] NULL,
	[intCurrencyId] [int] NOT NULL,
	[ysnFreightRelated] [bit] NOT NULL CONSTRAINT [DF_tblCTCostType_ysnFreightRelated]  DEFAULT ((0)),
	[ysnActive] [bit] NOT NULL CONSTRAINT [DF_tblCTCostType_ysnActive]  DEFAULT ((1)),
 CONSTRAINT [PK_tblCTCostType_intCostTypeId] PRIMARY KEY CLUSTERED 
(
	[intCostTypeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblCTCostType]  WITH CHECK ADD  CONSTRAINT [FK_tblCTCostType_tblCTCostMethod_intCostMethod] FOREIGN KEY([intCostMethod])
REFERENCES [dbo].[tblCTCostMethod] ([Value])
GO

ALTER TABLE [dbo].[tblCTCostType] CHECK CONSTRAINT [FK_tblCTCostType_tblCTCostMethod_intCostMethod]
GO

ALTER TABLE [dbo].[tblCTCostType]  WITH CHECK ADD  CONSTRAINT [FK_tblCTCostType_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY([intUnitMeasureId])
REFERENCES [dbo].[tblICUnitMeasure] ([intUnitMeasureId])
GO

ALTER TABLE [dbo].[tblCTCostType] CHECK CONSTRAINT [FK_tblCTCostType_tblICUnitMeasure_intUnitMeasureId]
GO

ALTER TABLE [dbo].[tblCTCostType]  WITH CHECK ADD  CONSTRAINT [FK_tblCTCostType_tblSMCurrency_intCurrencyId] FOREIGN KEY([intCurrencyId])
REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID])
GO

ALTER TABLE [dbo].[tblCTCostType] CHECK CONSTRAINT [FK_tblCTCostType_tblSMCurrency_intCurrencyId]
GO

ALTER TABLE [dbo].[tblCTCostType]  WITH CHECK ADD  CONSTRAINT [FK_tblCTCostType_tblSMFreightTerms_intFreightTermId] FOREIGN KEY([intFreightTermId])
REFERENCES [dbo].[tblSMFreightTerms] ([intFreightTermId])
GO

ALTER TABLE [dbo].[tblCTCostType] CHECK CONSTRAINT [FK_tblCTCostType_tblSMFreightTerms_intFreightTermId]
GO


