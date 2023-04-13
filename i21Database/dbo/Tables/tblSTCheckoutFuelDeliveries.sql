CREATE TABLE [dbo].[tblSTCheckoutFuelDeliveries]
(
	[intFuelDeliveryId] INT NOT NULL IDENTITY, 
	[intCheckoutId] INT NOT NULL,
    [intDeviceId] INT NOT NULL,
    [dblGallons] DECIMAL(18, 6) NOT NULL, 
    [dtmDeliveryDate] DATETIME NOT NULL,
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutFuelDeliveries_intFuelDeliveryId] PRIMARY KEY ([intFuelDeliveryId]), 
    CONSTRAINT [FK_tblSTCheckoutFuelDeliveries_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSTCheckoutFuelDeliveries_tblTMDevice] FOREIGN KEY ([intDeviceId]) REFERENCES [dbo].[tblTMDevice] ([intDeviceId]),
)