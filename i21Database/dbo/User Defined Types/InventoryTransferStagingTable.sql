/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[InventoryTransferStagingTable] AS TABLE
(
	 [intId] INT IDENTITY PRIMARY KEY CLUSTERED

	 -- Header
    ,[dtmTransferDate]		DATETIME 
    ,[strTransferType]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL
	,[intSourceType]		INT 
    ,[strDescription]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
    ,[intFromLocationId]	INT NULL
    ,[intToLocationId]		INT NULL
    ,[ysnShipmentRequired]	BIT NULL 
	,[intStatusId]			INT NOT NULL
    ,[intShipViaId]			INT NULL
    ,[intFreightUOMId]		INT NULL

	-- Detail 
	,[intSourceId]			INT NULL
    ,[intItemId]			INT NOT NULL
    ,[intLotId]				INT NULL
    ,[intFromSubLocationId] INT NULL
    ,[intToSubLocationId]	INT NULL
    ,[intFromStorageLocationId]		INT NULL
    ,[intToStorageLocationId]		INT NULL
    ,[dblQuantity]					NUMERIC(18, 6) NULL 
    ,[intItemUOMId]					INT NULL
    ,[strNewLotId]					NVARCHAR(50) COLLATE Latin1_General_CI_AS 

	-- Integration Field
	,[intInventoryTransferId] INT NULL						-- Existing id of an Inventory Transfer
)
