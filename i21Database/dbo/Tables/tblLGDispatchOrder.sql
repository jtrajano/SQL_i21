CREATE TABLE [dbo].[tblLGDispatchOrder]
(
	[intDispatchOrderId] INT NOT NULL IDENTITY,
	[strDispatchOrderNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmDispatchDate] DATETIME NULL,
	[dtmDeliveryTimeStart] DATETIME NULL,
	[dtmDeliveryTimeEnd] DATETIME NULL,
	[intEntityShipViaId] INT NULL,
	[intEntityShipViaTruckId] INT NULL, 
	[intDriverEntityId] INT NULL, 
	[intDeliveryStatus] INT NULL, 
	[intFromCompanyLocationId] INT NULL, 
	[intFromCompanyLocationSubLocationId] INT NULL, 
	[strComments] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT NULL DEFAULT((1)), 

	CONSTRAINT [PK_tblLGDispatchOrder_intDispatchOrderId] PRIMARY KEY ([intDispatchOrderId]),
	CONSTRAINT [FK_tblLGDispatchOrder_tblEMEntity_intDriverEntityId] FOREIGN KEY ([intDriverEntityId]) REFERENCES [tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblLGDispatchOrder_tblSMCompanyLocation_intFromCompanyLocationId] FOREIGN KEY ([intFromCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblLGDispatchOrder_tblSMCompanyLocationSubLocation_intFromCompanyLocationSubLocationId] FOREIGN KEY ([intFromCompanyLocationSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
	CONSTRAINT [FK_tblLGDispatchOrder_tblEMEntity_intEntityShipViaId] FOREIGN KEY ([intEntityShipViaId]) REFERENCES [tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblLGDispatchOrder_tblSMShipViaTruck_intEntityShipViaTruckId] FOREIGN KEY ([intEntityShipViaTruckId]) REFERENCES [tblSMShipViaTruck]([intEntityShipViaTruckId])
)
