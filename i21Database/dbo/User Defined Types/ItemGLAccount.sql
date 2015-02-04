/*
	This is a user-defined table type used to hold all the g/l account used in item costing. 
*/

CREATE TYPE [dbo].[ItemGLAccount] AS TABLE
(
	intItemId INT NOT NULL 
	,intLocationId INT NOT NULL 
	,intInventoryId INT
	,intContraInventoryId INT
	,intWriteOffSoldId INT
	,intRevalueSoldId INT
	,intAutoNegativeId INT
	,PRIMARY KEY CLUSTERED (intItemId, intLocationId) 
)
