/*
## Overview
This tables holds all the transaction types supported in Inventory. 
The list of transaction types is maintained in the 1_InventoryTransactionTypes.sql file. 

The transaction types are: 
*	Type id 1 is Inventory Auto Negative
*	Type id 2 is Inventory Write-Off Sold
*	Type id 3 is Inventory Revalue Sold
*	Type id 4 is Inventory Receipt
*	Type id 5 is Inventory Shipment
*	Type id 6 is Purchase Order
*	Type id 7 is Sales Order

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryTransactionType]
	(
		[intTransactionTypeId] INT NOT NULL, 
		[strName] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
		CONSTRAINT [PK_tblICInventoryTransactionType] PRIMARY KEY CLUSTERED ([intTransactionTypeId])
	)
