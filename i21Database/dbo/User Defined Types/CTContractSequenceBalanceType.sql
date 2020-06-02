CREATE TYPE [dbo].[CTContractSequenceBalanceType] AS TABLE (
	intId INT IDENTITY PRIMARY KEY CLUSTERED
	, intExternalId int NOT NULL										--> Shipment Item Id
	, intContractDetailId int NOT NULL									--> Contract Detail Id
	, dblOldQuantity NUMERIC(24, 10) NOT NULL DEFAULT((0))				--> Shipment quantity (NOTE: If reposting DWG, this should be the previous DWG quantity)
	, dblQuantity NUMERIC(24, 10) NOT NULL DEFAULT((0))					--> DWG quantity
	, intItemUOMId int NOT NULL											--> Shipment Item Item UOM Id
	, strScreenName NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL		--> 'Inventory'
	, intUserId INT NULL												--> Current User Id
)