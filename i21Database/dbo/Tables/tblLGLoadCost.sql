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
	[dblRate] [numeric](18, 6) NULL,
	[dblAmount] [numeric](18, 6) NULL,
	[dblFX] [numeric](18, 6) NULL,
	[intItemUOMId] [int] NULL,
	[ysnAccrue] [bit] NOT NULL CONSTRAINT [DF_tblLGLoadCost_ysnAccrue]  DEFAULT ((1)),
	[ysnMTM] [bit] NULL,
	[ysnPrice] [bit] NULL,
	[intBillId] [int] NULL,
	[intLoadCostRefId] INT NULL,


	[ysnVendorPrepayment] [BIT] NULL,

	CONSTRAINT [PK_tblLGLoadCost] PRIMARY KEY ([intLoadCostId]), 
	CONSTRAINT [FK_tblLGLoadCost_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblLGLoadCost_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblLGLoadCost_tblAPVendor_intVendorId] FOREIGN KEY ([intVendorId]) REFERENCES [tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblLGLoadCost_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblLGLoadCost_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	CONSTRAINT [FK_tblLGLoadCost_tblAPBill_intBillId] FOREIGN KEY ([intBillId]) REFERENCES [tblAPBill]([intBillId]) ON DELETE SET NULL
)
GO
CREATE NONCLUSTERED INDEX [IX_tblLGLoadCost_intLoadId] ON [dbo].[tblLGLoadCost]
(
 [intLoadId] ASC
)
INCLUDE (  
 [intLoadCostId],
 [intVendorId]
) 
GO