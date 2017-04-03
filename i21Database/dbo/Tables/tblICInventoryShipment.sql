/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryShipment]
	(
		[intInventoryShipmentId] INT NOT NULL IDENTITY, 
		[strShipmentNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
		[dtmShipDate] DATETIME NOT NULL DEFAULT (getdate()), 
		[intOrderType] INT NOT NULL, 
		[intSourceType] INT NOT NULL DEFAULT ((0)),
		[strReferenceNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dtmRequestedArrivalDate] DATETIME NULL, 
		[intShipFromLocationId] INT NOT NULL, 
		[intEntityCustomerId] INT NULL, 
		[intShipToLocationId] INT NULL, 
		[intShipToCompanyLocationId] INT NULL, 
		[intFreightTermId] INT NOT NULL, 
		[strBOLNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intCurrencyId] INT NULL, 
		[intShipViaId] INT NULL, 
		[strVessel] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strProNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strDriverId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strSealNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strDeliveryInstruction] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[dtmAppointmentTime] DATETIME NULL, 
		[dtmDepartureTime] DATETIME NULL, 
		[dtmArrivalTime] DATETIME NULL, 
		[dtmDeliveredDate] DATETIME NULL, 
		[dtmFreeTime] DATETIME NULL, 
		[strReceivedBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strComment] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[ysnPosted] BIT DEFAULT((0)),
		[intEntityId] INT NULL,
		[intCreatedUserId] INT NULL,
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		[dtmCreated] DATETIME NULL DEFAULT (GETDATE()),
		CONSTRAINT [PK_tblICInventoryShipment] PRIMARY KEY ([intInventoryShipmentId]), 
		--CONSTRAINT [FK_tblICInventoryShipment_tblSMCompanyLocation] FOREIGN KEY ([intShipFromLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
		CONSTRAINT [FK_tblICInventoryShipment_tblSMFreightTerm] FOREIGN KEY ([intFreightTermId]) REFERENCES [tblSMFreightTerms]([intFreightTermId]), 
		CONSTRAINT [FK_tblICInventoryShipment_tblSMShipVia] FOREIGN KEY ([intShipViaId]) REFERENCES [tblSMShipVia]([intEntityId]), 
		CONSTRAINT [FK_tblICInventoryShipment_ShipFromLocation] FOREIGN KEY ([intShipFromLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
		CONSTRAINT [FK_tblICInventoryShipment_tblEMEntityLocation] FOREIGN KEY ([intShipToLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]), 
		CONSTRAINT [FK_tblICInventoryShipment_ShipToCompanyLocation] FOREIGN KEY ([intShipToCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
		CONSTRAINT [AK_tblICInventoryShipment_strShipmentNumber] UNIQUE ([strShipmentNumber]), 
		CONSTRAINT [FK_tblICInventoryShipment_tblEMEntity] FOREIGN KEY ([intEntityId]) REFERENCES tblEMEntity([intEntityId]),
		CONSTRAINT [FK_tblICInventoryShipment_tblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID])
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryShipment_intInventoryShipmentId]
		ON [dbo].[tblICInventoryShipment]([intInventoryShipmentId] ASC)
		INCLUDE (strShipmentNumber, intEntityCustomerId, strBOLNumber)

	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryShipment_strShipmentNumber]
		ON [dbo].[tblICInventoryShipment]([strShipmentNumber] ASC)
		INCLUDE (intInventoryShipmentId, intEntityCustomerId, strBOLNumber)

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
		@value = N'Entity Customer Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipment',
		@level2type = N'COLUMN',
		@level2name = 'intEntityCustomerId'
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
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Shipment Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'strShipmentNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ship Via Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'intShipViaId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Delivery Instruction',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'strDeliveryInstruction'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Comments',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'strComment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Posted',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'ysnPosted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Entity Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'intEntityId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Created User Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'intCreatedUserId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Source Type',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipment',
    @level2type = N'COLUMN',
    @level2name = N'intSourceType'