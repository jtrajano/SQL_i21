/*
	This is a user-defined table type used in adding items to the inventory count detail via uspICAddInventoryCount. 
*/
CREATE TYPE [dbo].[InventoryCountStagingTable] AS TABLE
(
	 [intId] INT IDENTITY PRIMARY KEY CLUSTERED
	,intItemId INT 
	,intItemUOMId INT
	,dblPhysicalCount NUMERIC(38, 20) NULL 	
)
