/*
## Overview
This tables holds a matrix on what type of transactions are allowed to interact with each another. 

For example, a transaction from Grain module can directy create and post inventory adjustments but 
it will not allow inventory adjustments coming from Inventory Receipts. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.
## Source Code:
*/
CREATE TABLE [dbo].[tblICInventoryTransactionPostingIntegration]
(
	[intId] INT NOT NULL IDENTITY,
	[intTransactionTypeId] INT NOT NULL, 
	[intLinkAllowedTransactionTypeId] INT NOT NULL, 
	CONSTRAINT [PK_tblICInventoryAdjustmentAllowableType] PRIMARY KEY CLUSTERED ([intId]),
	CONSTRAINT [FK_tblICInventoryAdjustmentAllowableType_tblICInventoryTransactionType_InventoryModule] FOREIGN KEY ([intTransactionTypeId]) REFERENCES [tblICInventoryTransactionType]([intTransactionTypeId]),
	CONSTRAINT [FK_tblICInventoryAdjustmentAllowableType_tblICInventoryTransactionType_LinkAllowedModule] FOREIGN KEY ([intLinkAllowedTransactionTypeId]) REFERENCES [tblICInventoryTransactionType]([intTransactionTypeId]) 
)
