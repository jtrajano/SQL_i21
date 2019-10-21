CREATE TABLE [dbo].[tblLGLoadStorageCost]
(
	[intLoadStorageCostId] INT IDENTITY(1,1),
	[intConcurrencyId] INT,
	[intLoadId] INT NOT NULL,
	[intLoadDetailLotId] INT NOT NULL,
	[dblPrice] NUMERIC(18,6),
	[intPriceCurrencyId] INT,
	[intPriceUOMId] INT,
	[dblAmount] NUMERIC(18,6),
	[intCurrency] INT,
	[intCostType] INT,
	[ysnSubCurrency] BIT,
	[intLoadStorageCostRefId] INT NULL,

	CONSTRAINT [PK_intLoadStorageCostId] PRIMARY KEY ([intLoadStorageCostId]), 
	CONSTRAINT [FK_tblLGLoadStorageCost_tblLGLoad_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES [tblLGLoad]([intLoadId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblLGLoadStorageCost_tblLGLoadDetailLot_intLoadDetailLotId] FOREIGN KEY ([intLoadDetailLotId]) REFERENCES [tblLGLoadDetailLot]([intLoadDetailLotId]),
	CONSTRAINT [FK_tblLGLoadStorageCost_tblICItem_intItemId] FOREIGN KEY ([intCostType]) REFERENCES [tblICItem]([intItemId]),
)
