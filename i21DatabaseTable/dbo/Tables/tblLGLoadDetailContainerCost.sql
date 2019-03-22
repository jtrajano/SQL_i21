CREATE TABLE [dbo].[tblLGLoadDetailContainerCost]
(
	[intLoadDetailContainerCostId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intLoadDetailContainerLinkId] [int] NOT NULL,
	[intItemId] [int] NOT NULL,
	[strCostMethod] NVARCHAR(75) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblRate] [numeric](10, 6) NOT NULL,
	[intCostUOMId] [int] NULL,
	[intCurrencyId] [int] NOT NULL,

	CONSTRAINT [PK_tblLGLoadDetailContainerCost] PRIMARY KEY ([intLoadDetailContainerCostId]), 
	CONSTRAINT [FK_tblLGLoadDetailContainerCost_tblLGLoadDetailContainerLink_intLoadDetailContainerLinkId] FOREIGN KEY ([intLoadDetailContainerLinkId]) REFERENCES [tblLGLoadDetailContainerLink]([intLoadDetailContainerLinkId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblLGLoadDetailContainerCost_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblLGLoadDetailContainerCost_tblICItemUOM_intCostUOMId] FOREIGN KEY ([intCostUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblLGLoadDetailContainerCost_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID])
)