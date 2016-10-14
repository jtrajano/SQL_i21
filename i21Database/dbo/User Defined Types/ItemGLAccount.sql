/*
	This is a user-defined table type used to hold all the g/l account used in item costing. 
*/

CREATE TYPE [dbo].[ItemGLAccount] AS TABLE
(
	intItemId INT NOT NULL 
	,intItemLocationId INT NOT NULL 
	,intInventoryId INT
	,intContraInventoryId INT
	,intWriteOffSoldId INT
	,intRevalueSoldId INT
	,intAutoNegativeId INT	
	,intCostAdjustment INT
	,intRevalueWIP INT
	,intRevalueProduced INT
	,intRevalueTransfer INT
	,intRevalueBuildAssembly INT
	,intRevalueInTransit INT 
	--,intRevalueAdjItemChange INT
	--,intRevalueAdjSplitLot INT
	--,intRevalueAdjLotMerge INT
	--,intRevalueAdjLotMove INT 
	,intTransactionTypeId INT 
	,PRIMARY KEY CLUSTERED (intItemId, intItemLocationId, intTransactionTypeId) 
)
