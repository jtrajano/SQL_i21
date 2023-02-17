CREATE TABLE [dbo].[tblSTCheckoutTierProducts]
(
	[intTierProductId] INT NOT NULL IDENTITY, 
	[intCheckoutId] INT NOT NULL,
    [intProductNumber] INT NOT NULL,
    [dblAmount] DECIMAL(18, 6) NOT NULL,
    [dblVolume] DECIMAL(18, 6) NOT NULL,
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutTierProducts_intTierProductId] PRIMARY KEY ([intTierProductId]), 
    CONSTRAINT [FK_tblSTCheckoutTierProducts_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE,
)