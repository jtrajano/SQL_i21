CREATE TYPE [dbo].[ShipmentChargeStagingTable] AS TABLE
(
	intId INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,

	-- Header
	intOrderType INT NOT NULL
	,intSourceType INT NOT NULL
	,intEntityCustomerId INT NULL
	,dtmShipDate DATETIME NOT NULL
	,intShipFromLocationId INT NOT NULL
	,intShipToLocationId INT NULL
	,intFreightTermId INT NOT NULL

	-- Charges
	,intContractId INT NULL
	,intChargeId INT NOT NULL
	,strCostMethod NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	,dblRate NUMERIC(18, 6) NULL
	,intCostUOMId INT NULL
	,intCurrency INT NULL
	,dblAmount NUMERIC(18, 6) NULL
	,ysnAccrue BIT NULL
	,intEntityVendorId INT NULL
	,ysnPrice BIT NULL
	,intForexRateTypeId INT NULL
	,dblForexRate NUMERIC(18, 6) NULL

	-- Fields for Internal Use Only
	,intHeaderId INT NULL
	,intShipmentId INT NULL
)