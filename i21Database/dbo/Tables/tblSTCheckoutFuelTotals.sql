CREATE TABLE [dbo].[tblSTCheckoutFuelTotals]
(
	[intFuelTotalsId] INT NOT NULL IDENTITY, 
	[intCheckoutId] INT,
    [intFuelingPositionId] INT NOT NULL,
    [intProductNumber] INT NOT NULL,
    [dblFuelVolume] DECIMAL(18, 6) NOT NULL,
    [dblFuelMoney] DECIMAL(18, 6) NOT NULL,
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutFuelTotals_intFuelTotalsId] PRIMARY KEY ([intFuelTotalsId]), 
    CONSTRAINT [FK_tblSTCheckoutFuelTotals_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE,
    CONSTRAINT [AK_tblSTCheckoutFuelTotals_intCheckoutId_intFuelingPositionId_intProductNumber] UNIQUE ([intCheckoutId], [intFuelingPositionId], [intProductNumber]), 
)