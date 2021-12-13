
CREATE TABLE [dbo].[tblCTContractOptionality](
	[intContractOptionalityId] [int] IDENTITY(1,1) NOT NULL,
	[intContractDetailId] [int] NOT NULL,
	[intOptionId] [int] NULL,
	[strValue] [nvarchar](100)  COLLATE Latin1_General_CI_AS NOT NULL,
	[dblPremiumDiscount]  [numeric](18, 6) NULL,
	[intCurrencyId] [int] NULL,
	[intUnitMeasureId] [int] NULL,
	[dtmDateCreated] [datetime] NULL,
	[intConcurrencyId] [int] NOT NULL,
	CONSTRAINT [PK_tblCTContractOptionality_intOptionId] PRIMARY KEY CLUSTERED ([intContractOptionalityId] ASC),
	CONSTRAINT [FK_tblCTContractOptionality_tblCTContractDetail_intContractDetailId] FOREIGN KEY([intContractDetailId]) REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId])ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTContractOptionality_tblCTOption_intOptionId] FOREIGN KEY([intOptionId]) REFERENCES [dbo].[tblCTOption] ([intOptionId]),
	CONSTRAINT [FK_tblCTContractOptionality_tblSMCurrency_intCurrencyId] FOREIGN KEY([intCurrencyId])REFERENCES [dbo].[tblSMCurrency] ([intCurrencyID])
)
