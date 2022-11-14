CREATE TABLE [dbo].[tblSTCheckoutTankReadings]
(
	[intTankReadingsId] INT NOT NULL IDENTITY, 
	[intCheckoutId] INT NOT NULL,
    [intDeviceId] INT NOT NULL,
    [dblFuelLvl] DECIMAL(18, 6) NULL, 
    [dblFuelVolume] DECIMAL(18, 6) NULL, 
    [dblFuelTemperature] DECIMAL(18, 6) NULL, 
    [dblUllage] DECIMAL(18, 6) NULL,
    [dblWaterLevel] DECIMAL(18, 6) NULL,
	[dblSumOfDeliveriesPerTank] DECIMAL(18, 6) NULL,
	[dblTankVolume] DECIMAL(18, 6) NULL,
	[dblCalculatedVariance] AS dbo.fnSTGetCalculatedVariance(intCheckoutId,intDeviceId,dblFuelVolume,dblSumOfDeliveriesPerTank,dblTankVolume),
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutTankReadings_intTankReadingsId] PRIMARY KEY ([intTankReadingsId]), 
    CONSTRAINT [FK_tblSTCheckoutTankReadings_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSTCheckoutTankReadings_tblTMDevice] FOREIGN KEY ([intDeviceId]) REFERENCES [dbo].[tblTMDevice] ([intDeviceId]),
)
