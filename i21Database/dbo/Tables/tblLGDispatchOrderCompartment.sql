CREATE TABLE [dbo].[tblLGDispatchOrderCompartment]
(
	[intDispatchOrderCompartmentId] INT NOT NULL IDENTITY,
	[intDispatchOrderId] INT NOT NULL,
	[intEntityShipViaTrailerCompartmentId] INT NOT NULL,
	[intCategoryId] INT NULL,
	[dblCapacity] NUMERIC(18, 6) NULL,
	[dblLoadWeight] NUMERIC(18, 6) NULL,
	[intConcurrencyId] INT NULL DEFAULT((1)),

	CONSTRAINT [PK_tblLGDispatchOrderCompartment] PRIMARY KEY ([intDispatchOrderCompartmentId]),
	CONSTRAINT [FK_tblLGDispatchOrderCompartment_tblLGDispatchOrder_intDispatchOrderId] FOREIGN KEY ([intDispatchOrderId]) REFERENCES [tblLGDispatchOrder]([intDispatchOrderId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblLGDispatchOrderCompartment_tblSMShipViaTrailerCompartment_intEntityShipViaTrailerCompartmentId] FOREIGN KEY ([intEntityShipViaTrailerCompartmentId]) REFERENCES [tblSMShipViaTrailerCompartment]([intEntityShipViaTrailerCompartmentId])
)
