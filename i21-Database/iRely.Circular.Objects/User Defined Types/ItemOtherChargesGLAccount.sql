/*
	This is a user-defined table type used to hold all the g/l account used in item costing. 
*/

CREATE TYPE [dbo].[ItemOtherChargesGLAccount] AS TABLE
(
	intChargeId INT NOT NULL 
	,intItemLocationId INT NOT NULL 
	,intAPClearing INT 
	,intOtherChargeExpense INT
	,intOtherChargeIncome INT
	,intOtherChargeAsset INT
	,intTransactionTypeId INT 
	,PRIMARY KEY CLUSTERED (intChargeId, intItemLocationId, intTransactionTypeId) 
)
