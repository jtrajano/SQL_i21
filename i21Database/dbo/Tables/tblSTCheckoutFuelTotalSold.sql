CREATE TABLE [dbo].[tblSTCheckoutFuelTotalSold]
(
	[intFuelTotalSoldId] [int] IDENTITY(1,1) NOT NULL,
	[intCheckoutId] [int] NULL,
	[intProductNumber] [int] NOT NULL,
	[dblDollarsSold] [decimal](18, 6) NOT NULL,
	[dblGallonsSold] [decimal](18, 6) NOT NULL,
	[intConcurrencyId] [int] NULL,
    CONSTRAINT [PK_tblSTCheckoutFuelTotalSold_intFuelTotalSoldId] PRIMARY KEY ([intFuelTotalSoldId]), 
    CONSTRAINT [FK_tblSTCheckoutFuelTotalSold_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE,
    CONSTRAINT [AK_tblSTCheckoutFuelTotalSold_intCheckoutId_intProductNumber] UNIQUE ([intCheckoutId], [intProductNumber]), 
)