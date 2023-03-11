CREATE TABLE [dbo].[tblSTCheckoutFuelInventory]
(
	[intFuelInventoryId] INT NOT NULL IDENTITY, 
	[intCheckoutId] INT NOT NULL,
    [intDeviceId] INT NOT NULL,
    [dblGallons] DECIMAL(18, 6) NOT NULL, 
    [dtmFuelInventoryDate] DATETIME NOT NULL,
    [ysnIsManualEntry] BIT NOT NULL,
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutFuelInventory_intFuelInventoryId] PRIMARY KEY ([intFuelInventoryId]), 
    CONSTRAINT [FK_tblSTCheckoutFuelInventory_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblSTCheckoutFuelInventory_tblTMDevice] FOREIGN KEY ([intDeviceId]) REFERENCES [dbo].[tblTMDevice] ([intDeviceId]),
)