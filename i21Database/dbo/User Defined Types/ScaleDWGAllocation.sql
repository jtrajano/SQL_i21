
CREATE TYPE [dbo].ScaleDWGAllocation AS TABLE
(
	[intTicketId]	INT NOT NULL									
	,[intInventoryShipmentItemId] INT NOT NULL							
	,dblUnitAdjustment NUMERIC(38,20) NOT NULL
)
