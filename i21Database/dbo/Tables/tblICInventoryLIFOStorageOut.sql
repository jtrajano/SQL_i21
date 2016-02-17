/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryLIFOStorageOut]
	(
		[intId] INT NOT NULL IDENTITY, 
		[intInventoryLIFOStorageId] INT NULL, 
		[intInventoryTransactionStorageId] INT NOT NULL, 
		[dblQty] NUMERIC(38, 20) NOT NULL,
		[intRevalueLifoId] INT NULL,
		[dblCostAdjustQty] NUMERIC(38, 20) NULL,
		CONSTRAINT [PK_tblICInventoryLIFOStorageOut] PRIMARY KEY CLUSTERED ([intId])    
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryLIFOStorageOut_intInventoryTransactionId]
		ON [dbo].[tblICInventoryLIFOStorageOut]([intInventoryTransactionStorageId] ASC)
		INCLUDE(intInventoryLIFOStorageId);
	GO