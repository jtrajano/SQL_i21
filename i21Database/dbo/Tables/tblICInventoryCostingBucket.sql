/*
	This table breaks-down the cost associated to an inbound stock. This table is linked to tblICInventoryTransaction table. 
	
	1. This table allows the accrual of cost to an item. Inbound items may have one or more accruals on them. Some accruals will be marked
	   These items may be flat rate or per UOM and could potentially differ in different currencies. 	   
	   Some of the item will be marked as Freight related and will be kept in a separate inventory cost bucket. 

	2. Cost types:
		1. Basis - This is the basis value on the transaction. 
		2. G/F - This is the premiums/discounts associated to the transaction. 
		3. Freight - This is the cost accruals that are marked to be included in the inventory cost. 
		4. Other - This is the other cost accruals that needs to be included in the inventory cost. 

	3.	If there is one or more costing bucket record/s for transaction, the cost in tblICInventoryTransaction.dblCost will represent the total cost here in the costing bucket table. 
		Ex.: 

			The value for tblICInventoryTransaction.dblCost is $100.00
			The total cost of all the related records here in tblICInventoryCostingBucket should be $100.00 as well. 
*/

CREATE TABLE [dbo].[tblICInventoryCostingBucket]
(
	[intCostingBucketId] INT NOT NULL IDENTITY, 
    [intItemId] INT NOT NULL, 
    [intItemLocationStoreId] INT NOT NULL, 
    [dtmDate] INT NOT NULL, 
    [intGLAccountId] INT NOT NULL, 
	[dblUnitQty] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[dblUOMQty] NUMERIC(18, 6) NOT NULL DEFAULT 1, 
    [dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblExchangeRate] NUMERIC(18, 6) NOT NULL DEFAULT 1, 
	[intCurrencyId] INT NULL ,
    [intCostType] INT NOT NULL, 
	[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intInventoryTransactionId] INT NOT NULL, 
    [intTransactionId] INT NOT NULL, 
    [strTransactionId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL, 
    CONSTRAINT [PK_tblICInventoryCostingBucket] PRIMARY KEY ([intCostingBucketId]) 
)
