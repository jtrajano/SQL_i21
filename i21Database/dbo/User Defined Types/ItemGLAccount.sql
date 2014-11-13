/*
	This is a user-defined table type used to hold all the g/l account used in item costing. 
*/

CREATE TYPE [dbo].[ItemGLAccount] AS TABLE
(
	intItemId INT
	,intItemLocationId INT
	,intInventoryId INT
	,intContraInventoryId INT
	,intWriteOffSoldId INT
	,intRevalueSoldId INT
	,intAutoNegativeId INT
)
