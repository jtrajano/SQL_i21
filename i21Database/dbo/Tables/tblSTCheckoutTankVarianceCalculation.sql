CREATE TABLE [dbo].[tblSTCheckoutTankVarianceCalculation]
(
	[intTankVarianceId] INT NOT NULL IDENTITY, 
	[intCheckoutId] INT NOT NULL,
    [intDeviceId] INT NOT NULL,
    [dblStartFuelVolume] DECIMAL(18, 6) NULL, 
    [dblDeliveries] DECIMAL(18, 6) NULL, 
    [dblSales] DECIMAL(18, 6) NULL, 
    [dblEndFuelVolume] DECIMAL(18, 6) NULL,
    [dblCalculatedVariance] DECIMAL(18, 6) NULL,
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutTankVarianceCalculation_intTankVarianceId] PRIMARY KEY ([intTankVarianceId]), 
    CONSTRAINT [FK_tblSTCheckoutTankVarianceCalculation_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSTCheckoutTankVarianceCalculation_tblTMDevice] FOREIGN KEY ([intDeviceId]) REFERENCES [dbo].[tblTMDevice] ([intDeviceId]),
)