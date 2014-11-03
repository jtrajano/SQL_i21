/*
	This is a user-defined table type used to hold all the g/l account used in item costing. 
*/

CREATE TYPE [dbo].[ItemGLAccount] AS TABLE
(
	[Inventory] INT NULL
	,[ContraInventory] INT NULL
	,[RevalueSold] INT NULL
	,[WriteOffSold] INT NULL
	,[AutoNegative] INT NULL
)
