/*
	This is a user-defined table type used in the inventory costing stored procedures. 
*/
CREATE TYPE [dbo].[ItemLotTableType] AS TABLE
(
	[intId] INT IDENTITY PRIMARY KEY CLUSTERED
	,[intItemId] INT NOT NULL -- The item. 
	,[strItemNo] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL
	,[intItemLocationId] INT NOT NULL -- The location where the item is stored.
	,[intItemUOMId] INT NOT NULL -- The UOM used for the lot. 
	,[intDetailId] INT NOT NULL
	,[intLotId] INT NULL -- Place holder field for lot numbers
	,[strLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL -- Place holder field for lot numbers	
	,[intLotTypeId] INT NULL 
)
