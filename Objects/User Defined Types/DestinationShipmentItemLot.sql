/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[DestinationShipmentItemLot] AS TABLE
(	
	 [intId] INT IDENTITY PRIMARY KEY CLUSTERED

	-- Detail 
	,[intItemId] INT NOT NULL									-- The item. 
	,[intItemLocationId] INT NOT NULL							-- The location where the item is stored.
    ,[dblDestinationQuantityShipped] NUMERIC(38, 20) NOT NULL DEFAULT 0		-- The destination qty of the shipment 
	,[dblDestinationGrossWeight] NUMERIC(38, 20) NULL DEFAULT 0		-- The destination Gross of the shipment. 
	,[dblDestinationTareWeight] NUMERIC(38, 20) NULL DEFAULT 0			-- The destination tare of the shipment. 

	-- Integration Field
	,[intSourceId] INT NULL										-- String Id of the source transaction. 
	,[intInventoryShipmentId] INT NULL							-- Existing id of an Inventory Shipment. 
	,[intInventoryShipmentItemId] INT NULL						-- Existing id of an Inventory Shipment Item Id. 	
	,[intLotId] INT NULL										-- Existing id of an Inventory Shipment Item Lot Id. 	
)
