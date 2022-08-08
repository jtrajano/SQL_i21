CREATE TABLE [dbo].[tblSTCheckoutFuelSalesByGradeAndPricePoint]
(
	[intFuelSalesByGradeAndPricePointId] [int] IDENTITY(1,1) NOT NULL,
	[intCheckoutId] [int] NOT NULL,
	[intProductNumber] [int] NOT NULL,
	[dblPrice] [decimal](18,2) NOT NULL,
	[dblDollarsSold] [decimal](18, 2) NOT NULL,
	[dblGallonsSold] [decimal](18, 3) NOT NULL,
	[intItemUOMId] [int] NULL,
    [intConcurrencyId] [int] NOT NULL, 
    CONSTRAINT [PK_tblSTCheckoutFuelSalesByGradeAndPricePoint_intFuelSalesByGradeAndPricePointId] PRIMARY KEY ([intFuelSalesByGradeAndPricePointId]), 
    CONSTRAINT [FK_tblSTCheckoutFuelSalesByGradeAndPricePoint_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblSTCheckoutFuelSalesByGradeAndPricePoint_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]) ,
)