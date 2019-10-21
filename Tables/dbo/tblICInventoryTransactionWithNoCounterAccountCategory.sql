/*
## Overview
This table list all inventory transactions that are allowed to use NULL counter account category 
when calling the uspICPostCosting. 

A good example is the Build Assembly. The inventory account of the assembly item is on the debit while
the component(s) are on the credit side. 

	Dr ................. Inventory (Assembly Item)
	Cr .......................... Inventory (Component 1)
	Cr .......................... Inventory (Component ...)
	Cr .......................... Inventory (Component X)

The first call to uspICPostCosting is to reduce the stock of the components. It generates one sided gl entries to the credit side. 
The second call to uspICPostCosting is to increase the stock of the assembly item. This generates one side gl entries on the debit side. 

Mix the gl entries from the first and second call of uspICPostCosting to complete the gl entries for build assembly. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.
## Source Code:
*/
CREATE TABLE [dbo].[tblICInventoryTransactionWithNoCounterAccountCategory]
(
	[intTransactionTypeId] INT NOT NULL, 
	CONSTRAINT [PK_tblICInventoryTransactionWithNoCounterAccountCategory] PRIMARY KEY CLUSTERED ([intTransactionTypeId]),
	CONSTRAINT [FK_tblICInventoryTransactionWithNoCounterAccountCategory_tblICInventoryTransactionType] FOREIGN KEY ([intTransactionTypeId]) REFERENCES [tblICInventoryTransactionType]([intTransactionTypeId])	
)
