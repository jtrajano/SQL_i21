/*
	This tables holds all the transaction types supported in Inventory. 
	The list of transaction types is maintained in the 1_InventoryTransactionTypes.sql file. 
*/

CREATE TABLE [dbo].[tblICInventoryTransactionType]
(
	[intTransactionTypeId] INT NOT NULL, 
    [strName] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK_tblICInventoryTransactionType] PRIMARY KEY CLUSTERED ([intTransactionTypeId])
)
