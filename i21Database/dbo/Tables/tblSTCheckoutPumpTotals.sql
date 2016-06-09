CREATE TABLE [dbo].[tblSTCheckoutPumpTotals]
(
	[intPumpTotalsId] INT NOT NULL IDENTITY, 
	[intCheckoutId] INT,
    [intPumpCardCouponId] INT NOT NULL,
	[intCategoryId] int NULL, 
    [strDescription] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [dblPrice] DECIMAL(18, 6) NULL, 
    [dblQuantity] DECIMAL(18, 6) NULL, 
    [dblAmount] DECIMAL(18, 6) NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutPumpTotals_intPumpTotalsId] PRIMARY KEY ([intPumpTotalsId]), 
    CONSTRAINT [FK_tblSTCheckoutPumpTotals_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSTCheckoutPumpTotals_tblICItemUOM] FOREIGN KEY ([intPumpCardCouponId]) REFERENCES [tblICItemUOM]([intItemUOMId]) ,
	CONSTRAINT [FK_tblSTCheckoutPumpTotals_tblICCategory] FOREIGN KEY ([intCategoryId]) REFERENCES [dbo].[tblICCategory] ([intCategoryId])
)
