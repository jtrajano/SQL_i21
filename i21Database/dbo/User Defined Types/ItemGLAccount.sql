/*
	This is a user-defined table type used to hold all the g/l account used in item costing. 
*/

CREATE TYPE [dbo].[ItemGLAccount] AS TABLE
(
	[Inventory] INT NULL
	,[CostOfGoods] INT NULL
	,[PurchaseAccount] INT NULL
)
