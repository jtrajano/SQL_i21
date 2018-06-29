CREATE TABLE [dbo].[tblLGShipmentBLContainerCost]
(
	[intShipmentBLContainerCostId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intShipmentBLContainerId] [int] NOT NULL,
	[intItemId] [int] NOT NULL,
	[intVendorEntityId] [int] NULL,
	[strCostMethod] NVARCHAR(75) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblRate] [numeric](10, 6) NOT NULL,
	[intCostUOMId] [int] NULL,
	[intCurrencyId] [int] NOT NULL,

	CONSTRAINT [PK_tblLGShipmentBLContainerCost] PRIMARY KEY ([intShipmentBLContainerCostId]), 
	CONSTRAINT [FK_tblLGShipmentBLContainerCost_tblLGShipmentBLContainer_intShipmentBLContainerId] FOREIGN KEY ([intShipmentBLContainerId]) REFERENCES [tblLGShipmentBLContainer]([intShipmentBLContainerId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblLGShipmentBLContainerCost_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblLGShipmentBLContainerCost_tblEMEntity_intVendorEntityId] FOREIGN KEY ([intVendorEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblLGShipmentBLContainerCost_tblICItemUOM_intCostUOMId] FOREIGN KEY ([intCostUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblLGShipmentBLContainerCost_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID])
)