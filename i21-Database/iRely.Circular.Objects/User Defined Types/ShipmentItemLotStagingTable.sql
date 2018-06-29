CREATE TYPE [dbo].[ShipmentItemLotStagingTable] AS TABLE
(
	intId INT IDENTITY(1, 1) PRIMARY KEY CLUSTERED,

	-- Shipment Item Header
	intOrderType INT NOT NULL,
	intSourceType INT NOT NULL,
	intEntityCustomerId INT NULL,
	dtmShipDate DATETIME NOT NULL,
	intShipFromLocationId INT NOT NULL,
	intShipToLocationId INT NULL,
	intFreightTermId INT NOT NULL,
	-- Used to identify to which item this lot belongs to
	intItemLotGroup INT NOT NULL,

	-- Details
	intLotId INT NOT NULL,
	dblQuantityShipped NUMERIC(38, 20) NULL,
	dblGrossWeight NUMERIC(38, 20) NULL,
	dblTareWeight NUMERIC(38, 20) NULL,
	dblWeightPerQty NUMERIC(38, 20) NULL,
	strWarehouseCargoNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
)