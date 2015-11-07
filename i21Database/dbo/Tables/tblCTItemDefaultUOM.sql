CREATE TABLE [dbo].[tblCTItemDefaultUOM]
(
	[intItemId] INT NOT NULL,
	[intStockUOMId] INT NOT NULL,
	[intPurchaseUOMId] INT NOT NULL,
	
	CONSTRAINT [PK_tblCTItemDefaultUOM] PRIMARY KEY ([intItemId])
)