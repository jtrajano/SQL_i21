CREATE TYPE [dbo].[ShipmentStagingTable] AS TABLE
(
	intId INT IDENTITY(1,1) PRIMARY KEY CLUSTERED,
	
	-- Header
	-- Required Fields
	intOrderType INT NOT NULL,
	intSourceType INT NOT NULL,
	intEntityCustomerId INT NULL,
	dtmShipDate DATETIME NOT NULL,
	intShipFromLocationId INT NOT NULL,
	intShipToLocationId INT NULL,
	intFreightTermId INT NULL, -- INT NOT NULL,
	strSourceScreenName NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,

	-- Optional Fields
	strReferenceNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	dtmRequestedArrivalDate DATETIME NULL,
	intShipToCompanyLocationId INT NULL,
	strBOLNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	intShipViaId INT NULL,
	strVessel NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strProNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strDriverId	NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strSealNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strDeliveryInstruction NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	dtmAppointmentTime DATETIME NULL,
	dtmDepartureTime DATETIME NULL,
	dtmArrivalTime DATETIME NULL,
	dtmDeliveredDate DATETIME NULL,
	dtmFreeTime DATETIME NULL,
	strFreeTime NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strReceivedBy NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strComment NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	intCurrencyId INT NULL,

	-- Details
	-- Required Field for Details
	intItemId INT NOT NULL,
	intOwnershipType INT NOT NULL,
	dblQuantity NUMERIC(38, 20) NOT NULL CHECK(dblQuantity > 0),
	intItemUOMId INT NOT NULL,
	intStorageScheduleTypeId INT NULL,
	intForexRateTypeId INT NULL,
	dblForexRate NUMERIC(38, 20) NULL, 

	-- This is used to group lots for lotted items
	intItemLotGroup INT NULL,

	intOrderId INT NULL,
	intSourceId INT NULL,
	intLineNo INT NULL,
	intSubLocationId INT NULL,
	intStorageLocationId INT NULL,
	intItemCurrencyId INT NULL,
	intWeightUOMId INT NULL,
	dblUnitPrice NUMERIC(38, 20) NULL,
	intDockDoorId INT NULL,
	strNotes NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	intGradeId INT NULL,
	intDiscountSchedule INT NULL,
	intDestinationGradeId INT NULL,
	intDestinationWeightId INT NULL,
	
	-- Fields for Internal Use Only
	intHeaderId INT NULL,
	intShipmentId INT NULL
	--UNIQUE (intItemLotGroup, intOrderType, intSourceType, intEntityCustomerId, dtmShipDate, intShipFromLocationId, intShipToLocationId, intFreightTermId)
)