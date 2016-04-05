CREATE TABLE [dbo].[tblLGShipmentBLContainerContractCost]
(
	[intShipmentBLContainerContractCostId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL,
	[intShipmentBLContainerContractId] [int] NOT NULL,
	[intItemId] [int] NOT NULL,
	[intVendorEntityId] [int] NULL,
	[strCostMethod] NVARCHAR(75) COLLATE Latin1_General_CI_AS NOT NULL,
	[dblRate] [numeric](10, 6) NOT NULL,
	[intCostUOMId] [int] NULL,
	[intCurrencyId] [int] NOT NULL,

	CONSTRAINT [PK_tblLGShipmentBLContainerContractCost] PRIMARY KEY ([intShipmentBLContainerContractCostId]), 
	CONSTRAINT [FK_tblLGShipmentBLContainerContractCost_tblLGShipmentBLContainerContract_intShipmentBLContainerContractId] FOREIGN KEY ([intShipmentBLContainerContractId]) REFERENCES [tblLGShipmentBLContainerContract]([intShipmentBLContainerContractId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblLGShipmentBLContainerContractCost_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblLGShipmentBLContainerContractCost_tblEMEntity_intVendorEntityId] FOREIGN KEY ([intVendorEntityId]) REFERENCES tblEMEntity([intEntityId]),
	CONSTRAINT [FK_tblLGShipmentBLContainerContractCost_tblICItemUOM_intCostUOMId] FOREIGN KEY ([intCostUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
	CONSTRAINT [FK_tblLGShipmentBLContainerContractCost_tblSMCurrency_intCurrencyId] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID])
)