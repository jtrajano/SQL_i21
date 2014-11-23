CREATE TABLE [dbo].[tblCTFreightRate](
	[intFreightRateId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[strOrigin] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strDest] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intRateType] [int] NOT NULL,
	[dblRate] [numeric](12, 4) NOT NULL,
	[intUnitMeasureId] [int] NULL,
	[intCurrencyId] [int] NOT NULL,
	[dtmExpire] [datetime] NOT NULL,
 CONSTRAINT [PK_tblCTFreightRate_intFreightRateId] PRIMARY KEY CLUSTERED 
(
	[intFreightRateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblCTFreightRate]  WITH CHECK ADD  CONSTRAINT [FK_tblCTFreightRate_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY([intUnitMeasureId])
REFERENCES [dbo].[tblICUnitMeasure] ([intUnitMeasureId])
GO

ALTER TABLE [dbo].[tblCTFreightRate] CHECK CONSTRAINT [FK_tblCTFreightRate_tblICUnitMeasure_intUnitMeasureId]
GO

ALTER TABLE [dbo].[tblCTFreightRate]  WITH CHECK ADD  CONSTRAINT [FK_tblCTFreightRate_tblSMCurrency_intCurrencyId] FOREIGN KEY([intCurrencyId])
REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID])
GO

ALTER TABLE [dbo].[tblCTFreightRate] CHECK CONSTRAINT [FK_tblCTFreightRate_tblSMCurrency_intCurrencyId]
GO

