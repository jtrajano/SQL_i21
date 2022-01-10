CREATE TABLE [dbo].[tblLGDispatchOrder]
(
	[intDispatchOrderId] INT NOT NULL IDENTITY,
	[strDispatchOrderNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmDispatchDate] DATETIME NULL,
	[intEntityShipViaId] INT NULL,
	[intEntityShipViaTruckId] INT NULL, 
	[intEntityShipViaTrailerId] INT NULL, 
	[intDriverEntityId] INT NULL, 
	[intDispatchStatus] INT NULL, 
	[strComments] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NULL DEFAULT((1)), 

	CONSTRAINT [PK_tblLGDispatchOrder_intDispatchOrderId] PRIMARY KEY ([intDispatchOrderId]),
	CONSTRAINT [FK_tblLGDispatchOrder_tblEMEntity_intDriverEntityId] FOREIGN KEY ([intDriverEntityId]) REFERENCES [tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblLGDispatchOrder_tblEMEntity_intEntityShipViaId] FOREIGN KEY ([intEntityShipViaId]) REFERENCES [tblEMEntity]([intEntityId]),
	CONSTRAINT [FK_tblLGDispatchOrder_tblSMShipViaTruck_intEntityShipViaTruckId] FOREIGN KEY ([intEntityShipViaTruckId]) REFERENCES [tblSMShipViaTruck]([intEntityShipViaTruckId]),
	CONSTRAINT [FK_tblLGDispatchOrder_tblSMShipViaTrailer_intEntityShipViaTrailerId] FOREIGN KEY ([intEntityShipViaTrailerId]) REFERENCES [tblSMShipViaTrailer]([intEntityShipViaTrailerId])
)
