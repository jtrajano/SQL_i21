CREATE TABLE [dbo].[tblLGDispatchOrderCompartmentQty]
(
	[intDispatchOrderCompartmentQtyId] INT NOT NULL IDENTITY,
	[intDispatchOrderCompartmentId] INT NOT NULL,
	[intDispatchOrderDetailId] INT NOT NULL,
	[dblQuantity] NUMERIC(18, 6) NULL,
	[intConcurrencyId] INT NULL DEFAULT((1)),

	CONSTRAINT [PK_tblLGDispatchOrderCompartmentQty] PRIMARY KEY ([intDispatchOrderCompartmentQtyId]),
	CONSTRAINT [FK_tblLGDispatchOrderCompartment_tblLGDispatchOrderCompartment_intDispatchOrderCompartmentId] FOREIGN KEY ([intDispatchOrderCompartmentId]) REFERENCES [tblLGDispatchOrderCompartment]([intDispatchOrderCompartmentId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblLGDispatchOrderCompartment_tblLGDispatchOrderDetail_intDispatchOrderDetailId] FOREIGN KEY ([intDispatchOrderDetailId]) REFERENCES [tblLGDispatchOrderDetail]([intDispatchOrderDetailId])
)
