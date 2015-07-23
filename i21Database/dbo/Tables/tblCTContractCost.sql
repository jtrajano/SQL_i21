CREATE TABLE [dbo].[tblCTContractCost](
	[intContractCostId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intContractDetailId] [int] NOT NULL,
	[intItemId] [int] NOT NULL DEFAULT 0,
	[intVendorId] [int] NULL,
	[strCostMethod] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblRate] [numeric](10, 4) NOT NULL,
	[intItemUOMId] [int] NULL,
	[ysnAccrue] [bit] NOT NULL CONSTRAINT [DF_tblCTContractCost_ysnAccrue]  DEFAULT ((1)),
	[ysnMTM] [bit] NULL,
	[ysnPrice] [bit] NULL,
	CONSTRAINT [PK_tblCTContractCost_intContractCostId] PRIMARY KEY CLUSTERED ([intContractCostId] ASC),
	CONSTRAINT [FK_tblCTContractCost_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTContractCost_tblAPVendor_intVendorId] FOREIGN KEY ([intVendorId]) REFERENCES [tblAPVendor]([intEntityVendorId]),
	CONSTRAINT [FK_tblCTContractCost_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)