CREATE TABLE [dbo].[tblLGLoadCost]
(
	[intLoadCostId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intLoadId] [int] NOT NULL,
	[intItemId] [int] NOT NULL,
	[intVendorId] [int] NULL,
	[strEntityType] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[strCostMethod] [nvarchar](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[intCurrencyId] INT NULL,
	[dblRate] [numeric](10, 4) NOT NULL,
	[dblAmount] [numeric](10, 4) NULL,
	[intItemUOMId] [int] NULL,
	[ysnAccrue] [bit] NOT NULL CONSTRAINT [DF_tblLGLoadCost_ysnAccrue]  DEFAULT ((1)),
	[ysnMTM] [bit] NULL,
	[ysnPrice] [bit] NULL,

	CONSTRAINT [PK_tblLGLoadCost] PRIMARY KEY ([intLoadCostId]), 
	CONSTRAINT [FK_tblLGLoadCost_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblLGLoadCost_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblLGLoadCost_tblAPVendor_intVendorId] FOREIGN KEY ([intVendorId]) REFERENCES [tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblLGLoadCost_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblLGLoadCost_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID])
)