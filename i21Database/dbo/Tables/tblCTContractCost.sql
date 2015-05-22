CREATE TABLE [dbo].[tblCTContractCost](
	[intContractCostId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intContractDetailId] [int] NOT NULL,
	[intCostTypeId] [int] NOT NULL,
	[intVendorId] [int] NULL,
	[intCostMethodId] [int] NOT NULL,
	[dblRate] [numeric](10, 4) NOT NULL,
	[intUnitMeasureId] [int] NULL,
	[intCurrencyId] [int] NOT NULL,
	[ysnAccrue] [bit] NOT NULL CONSTRAINT [DF_tblCTContractCost_ysnAccrue]  DEFAULT ((1)),
	[ysnMTM] [bit] NULL,
	[ysnPrice] [bit] NULL,
	[ysnFreight] [bit] NULL,
	CONSTRAINT [PK_tblCTContractCost_intContractCostId] PRIMARY KEY CLUSTERED ([intContractCostId] ASC),
	CONSTRAINT [FK_tblCTContractCost_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]),
	CONSTRAINT [FK_tblCTContractCost_tblCTCostType_intCostTypeId] FOREIGN KEY ([intCostTypeId]) REFERENCES [tblCTCostType]([intCostTypeId]),
	CONSTRAINT [FK_tblCTContractCost_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCTContractCost_tblAPVendor_intVendorId] FOREIGN KEY ([intVendorId]) REFERENCES [tblAPVendor]([intEntityVendorId]),
	CONSTRAINT [FK_tblCTContractCost_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblCTContractCost_tblCTCostMethod_intCostMethodId] FOREIGN KEY ([intCostMethodId]) REFERENCES [tblCTCostMethod]([intCostMethodId])
)