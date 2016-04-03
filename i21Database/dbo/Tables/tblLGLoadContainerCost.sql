CREATE TABLE [dbo].[tblLGLoadContainerCost]
(
	[intLoadContainerCostId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intLoadContainerId] [int] NOT NULL,
	[intItemId] [int] NOT NULL,
	[strCostMethod] NVARCHAR(75) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblRate] [numeric](10, 6) NOT NULL,
	[intCostUOMId] [int] NULL,
	[intCurrencyId] [int] NOT NULL,

	CONSTRAINT [PK_tblLGLoadContainerCost] PRIMARY KEY ([intLoadContainerCostId]), 
	CONSTRAINT [FK_tblLGLoadContainerCost_tblLGLoadContainer_intLoadContainerId] FOREIGN KEY ([intLoadContainerId]) REFERENCES [tblLGLoadContainer]([intLoadContainerId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblLGLoadContainerCost_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblLGLoadContainerCost_tblICItemUOM_intCostUOMId] FOREIGN KEY ([intCostUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblLGLoadContainerCost_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID])
)