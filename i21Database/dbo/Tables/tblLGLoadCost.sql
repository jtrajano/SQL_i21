CREATE TABLE [dbo].[tblLGLoadCost]
(
	[intLoadCostId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intLoadId] [int] NOT NULL,
	[intCostTypeId] [int] NOT NULL,
	[intVendorId] [int] NULL,
	[intCostMethod] [int] NOT NULL,
	[dblRate] [numeric](10, 4) NOT NULL,
	[intUnitMeasureId] [int] NULL,
	[intCurrencyId] [int] NOT NULL,
	[ysnAccrue] [bit] NOT NULL,
	[ysnMTM] [bit] NULL,
	[ysnPrice] [bit] NULL,

	CONSTRAINT [PK_tblLGLoadCost] PRIMARY KEY ([intLoadCostId]), 
	CONSTRAINT [FK_tblLGLoadCost_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblLGLoadCost_tblCTCostType_intCostTypeId] FOREIGN KEY ([intCostTypeId]) REFERENCES [tblCTCostType]([intCostTypeId]),
	CONSTRAINT [FK_tblLGLoadCost_tblAPVendor_intVendorId] FOREIGN KEY ([intVendorId]) REFERENCES [tblAPVendor]([intVendorId]),
	CONSTRAINT [FK_tblLGLoadCost_tblICUnitMeasure_intUnitMeasureId] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]),
	CONSTRAINT [FK_tblLGLoadCost_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID])
)