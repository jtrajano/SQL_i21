/*
	This is a user-defined table type used unposting an inventory costing. 
*/

CREATE TYPE [dbo].[InventoryTranactionStockToReverse] AS TABLE
(
	intInventoryTransactionId INT NOT NULL 
	,intTransactionId INT NULL 
	,strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	,strRelatedInventoryTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL
	,intRelatedInventoryTransactionId INT NULL 
	,intTransactionTypeId INT NOT NULL 
)



