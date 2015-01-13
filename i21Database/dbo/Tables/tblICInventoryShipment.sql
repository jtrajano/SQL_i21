CREATE TABLE [dbo].[tblICInventoryShipment]
(
	[intInventoryShipmentId] INT NOT NULL IDENTITY, 
    [strBOLNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [dtmShipDate] DATETIME NOT NULL DEFAULT (getdate()), 
    [intOrderType] INT NOT NULL, 
    [strReferenceNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dtmRequestedArrivalDate] DATETIME NULL, 
    [intShipFromLocationId] INT NOT NULL, 
	[intShipToLocationId] INT NOT NULL, 
    [intCustomerId] INT NULL, 
    [intFreightTermId] INT NOT NULL, 
    [ysnDirectShipment] BIT NULL DEFAULT ((0)), 
    [intCarrierId] INT NULL, 
    [strVessel] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strProNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strDriverId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strSealNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [dtmAppointmentTime] DATETIME NULL, 
    [dtmDepartureTime] DATETIME NULL, 
    [dtmArrivalTime] DATETIME NULL, 
    [dtmDeliveredDate] DATETIME NULL, 
    [dtmFreeTime] DATETIME NULL, 
    [strReceivedBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strDeliveryInstruction] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[strComment] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
	[ysnPosted] BIT DEFAULT((0)),
	[intEntityId] INT NULL,
	[intCreatedUserId] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICInventoryShipment] PRIMARY KEY ([intInventoryShipmentId]), 
    CONSTRAINT [AK_tblICInventoryShipment_strBOLNumber] UNIQUE ([strBOLNumber]), 
    CONSTRAINT [FK_tblICInventoryShipment_tblSMCompanyLocation] FOREIGN KEY ([intShipFromLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [FK_tblICInventoryShipment_tblSMFreightTerm] FOREIGN KEY ([intFreightTermId]) REFERENCES [tblSMFreightTerms]([intFreightTermId]), 
    CONSTRAINT [FK_tblICInventoryShipment_tblSMShipVia] FOREIGN KEY ([intCarrierId]) REFERENCES [tblSMShipVia]([intShipViaID]), 
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identity Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'intInventoryShipmentId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'BOL Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'strBOLNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ship Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'dtmShipDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Order Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'intOrderType'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reference Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'strReferenceNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Requested Arrival Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'dtmRequestedArrivalDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ship From Location Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'intShipFromLocationId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Customer Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'intCustomerId'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Freight Term Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'intFreightTermId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Direct Shipment',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'ysnDirectShipment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Carrier Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'intCarrierId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Vessel/Vehicle',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'strVessel'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Pro Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'strProNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Driver Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'strDriverId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Seal Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'strSealNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Appointment Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'dtmAppointmentTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Departure Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'dtmDepartureTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Arrival Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'dtmArrivalTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delivered Date',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'dtmDeliveredDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Free Time',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'dtmFreeTime'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Received By',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'strReceivedBy'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ship To Location',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'intShipToLocationId'