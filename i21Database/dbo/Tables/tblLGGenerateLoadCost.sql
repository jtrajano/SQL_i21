CREATE TABLE [dbo].[tblLGGenerateLoadCost]
(
	[intGenerateLoadCostId] [INT] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [INT] NOT NULL,
	[intGenerateLoadId] [INT] NOT NULL,
	[intItemId] [INT] NOT NULL,
	[intVendorId] [INT] NULL,
	[strEntityType] [NVARCHAR](100) COLLATE Latin1_General_CI_AS NULL,
	[strCostMethod] [NVARCHAR](30) COLLATE Latin1_General_CI_AS NOT NULL,
	[intCurrencyId] INT NULL,
	[dblRate] [NUMERIC](18, 6) NULL,
	[dblFX] [NUMERIC](18, 6) NULL,
	[intItemUOMId] [INT] NULL,
	[ysnAccrue] [BIT] NOT NULL CONSTRAINT [DF_tblLGGenerateLoadCost_ysnAccrue] DEFAULT ((1)),
	[ysnPrice] [BIT] NULL DEFAULT ((0)),
	[ysnVendorPrepayment] [BIT] NULL DEFAULT ((0)),

	CONSTRAINT [PK_tblLGGenerateLoadCost] PRIMARY KEY ([intGenerateLoadCostId]), 
	CONSTRAINT [FK_tblLGGenerateLoadCost_tblLGGenerateLoad_intGenerateLoadId] FOREIGN KEY ([intGenerateLoadId]) REFERENCES [tblLGGenerateLoad]([intGenerateLoadId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblLGGenerateLoadCost_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblLGGenerateLoadCost_tblAPVendor_intVendorId] FOREIGN KEY ([intVendorId]) REFERENCES [tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblLGGenerateLoadCost_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblLGGenerateLoadCost_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
)
GO

CREATE NONCLUSTERED INDEX [IX_tblLGGenerateLoadCost_intGenerateLoadId]
ON [dbo].[tblLGGenerateLoadCost]([intGenerateLoadId] ASC)
INCLUDE ([intVendorId]) 
GO