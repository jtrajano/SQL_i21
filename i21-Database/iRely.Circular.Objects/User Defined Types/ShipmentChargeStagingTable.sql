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
	,intFreightTermId INT NULL

	-- Charges
	,intContractId INT NULL
	,intContractDetailId INT NULL
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
	,strChargesLink NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL 
	,strAllocatePriceBy NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL

	-- Fields for Internal Use Only
	,intHeaderId INT NULL
	,intShipmentId INT NULL
)