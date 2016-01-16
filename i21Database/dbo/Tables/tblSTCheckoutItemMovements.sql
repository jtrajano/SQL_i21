CREATE TABLE [dbo].[tblSTCheckoutItemMovements]
(
	[intItemMovementId] INT NOT NULL IDENTITY,
	[intCheckoutId] INT,
    [intItemUPCId] INT NULL, 
    [strDescription] NVARCHAR(MAX) NULL, 
    [intVendorId] INT NULL, 
    [intQtySold] INT NULL, 
    [dblCurrentPrice] DECIMAL(18, 6) NULL, 
    [dblTotalSales] DECIMAL(18, 6) NULL, 
    [intConcurrencyId] INT NULL, 
	CONSTRAINT [PK_tblSTCheckoutItemMovements_intItemMovementId] PRIMARY KEY ([intItemMovementId]), 
	CONSTRAINT [FK_tblSTCheckoutItemMovements_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]), 
    CONSTRAINT [FK_tblSTCheckoutItemMovements_tblICItemUOM] FOREIGN KEY ([intItemUPCId]) REFERENCES [tblICItemUOM]([intItemUOMId]) 

)
