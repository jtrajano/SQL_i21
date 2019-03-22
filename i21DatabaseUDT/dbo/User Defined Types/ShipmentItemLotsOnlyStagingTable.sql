CREATE TYPE [dbo].[ShipmentItemLotsOnlyStagingTable] AS TABLE
(
	intId INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,

	-- Shipment Id and Shipment-Item Id. 
	intInventoryShipmentId INT NOT NULL,
	intInventoryShipmentItemId INT NOT NULL,

	-- Lot Details 
	intLotId INT NOT NULL,
	dblQuantityShipped NUMERIC(38, 20) NULL,
	dblGrossWeight NUMERIC(38, 20) NULL,
	dblTareWeight NUMERIC(38, 20) NULL,
	dblWeightPerQty NUMERIC(38, 20) NULL,
	strWarehouseCargoNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
)