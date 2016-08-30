/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[InventoryTransferStagingTable] AS TABLE
(
	 [intId] INT IDENTITY PRIMARY KEY CLUSTERED

	 -- Header
    ,[dtmTransferDate]		DATETIME NOT NULL									-- Date of the transfer. 
	,[strTransferType]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL	-- Type of Inventory Transfer. Values can be: 'Location to Location' and 'Storage to Storage'
	,[intSourceType]		INT NOT NULL										-- Values can be: 0 (None), 1 (Scale), 2 (Inbound Shipment), 3 (Transports)
    ,[strDescription]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL		-- Description pertaining to an inventory transfer. 
    ,[intFromLocationId]	INT NOT NULL										-- Company location id where the stock is coming from. 
    ,[intToLocationId]		INT NOT NULL										-- Company location id where the stock is going to. 
    ,[ysnShipmentRequired]	BIT NULL											-- Values can be: 0 - It does not need a separate shipment and it is not tracked by logistics. 1 - It indicates that the transfer requires shipment and tracked by logistics. 
	,[intStatusId]			INT NOT NULL										-- Values can be: 1 (Open), 2 (Partial), 3 (Closed), 4 (Short Closed). 
    ,[intShipViaId]			INT NULL											-- Ship Via from Entity. 
    ,[intFreightUOMId]		INT NULL											-- Unit of Measure. 
	,[strActualCostId]		NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL -- Direct Cost Id

	-- Detail 
	,[intItemId]				INT NOT NULL									-- Item id to transfer
	,[intLotId]					INT NULL										-- Existing Lot number to transfer
    ,[intItemUOMId]				INT NULL										-- UOM used for the transfer. Ex. Gallon
    ,[dblQuantityToTransfer]	NUMERIC(38, 20) NULL							-- Qty to transfer related to the UOM. Ex. "10" gallons. 
    ,[strNewLotId]				NVARCHAR(50) COLLATE Latin1_General_CI_AS		-- New lot number to use when stock is transferred to the new location.
	,[intFromSubLocationId]		INT NULL										-- Source sub location of the item. 
    ,[intToSubLocationId]		INT NULL										-- Target sub location of the item. 
    ,[intFromStorageLocationId]	INT NULL										-- Source storage location id of the item.
    ,[intToStorageLocationId]	INT NULL										-- Target storage location id of the item.
	,[intOwnershipType] INT NULL DEFAULT ((1))									-- Ownership Type. 1 = Own, 2 = Storage, 3 = Consigned Purchase; Default to 1;

	-- Integration Field
	,[intInventoryTransferId] INT NULL											-- Existing id of an Inventory Transfer
	,[intSourceId] INT NOT NULL													-- PK id of the source transaction. Ex. Transport Load id. 
	,[strSourceId] NVARCHAR(50) NULL											-- String Id of the source transaction. 
	,[strSourceScreenName] NVARCHAR(50) NULL									-- Name of the screen name where the transaction is coming from.	

)
