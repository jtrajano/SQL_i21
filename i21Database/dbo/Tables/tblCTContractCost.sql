CREATE TABLE [dbo].[tblCTContractCost](
	[intContractCostId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intContractDetailId] [int] NOT NULL,
	[intItemId] [int] NULL,
	[intVendorId] [int] NULL,
	[strCostMethod] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[intCurrencyId] [int],
	[dblRate] [numeric](18, 6) NOT NULL,
	[intItemUOMId] [int] NULL,
	[dblFX] numeric(18,6),
	[ysnAccrue] [bit] NOT NULL CONSTRAINT [DF_tblCTContractCost_ysnAccrue]  DEFAULT ((1)),
	[ysnMTM] [bit] NULL,
	[ysnPrice] [bit] NULL,
	[ysnAdditionalCost] [bit] NULL,

	CONSTRAINT [PK_tblCTContractCost_intContractCostId] PRIMARY KEY CLUSTERED ([intContractCostId] ASC),
	CONSTRAINT [FK_tblCTContractCost_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTContractCost_tblAPVendor_intVendorId] FOREIGN KEY ([intVendorId]) REFERENCES [tblAPVendor]([intEntityVendorId]),
	CONSTRAINT [FK_tblCTContractCost_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblCTContractCost_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblCTContractCost_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)