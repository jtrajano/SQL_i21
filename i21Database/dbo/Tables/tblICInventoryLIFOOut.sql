/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryLIFOOut]
	(
		[intId] INT NOT NULL IDENTITY, 
		[intInventoryLIFOId] INT NULL, 
		[intInventoryTransactionId] INT NOT NULL, 
		[dblQty] NUMERIC(38, 20) NOT NULL,
		[intRevalueLifoId] INT NULL,
		[dblCostAdjustQty] NUMERIC(38, 20) NULL,
		[dblQtyReturned] NUMERIC(38, 20) NULL,
		CONSTRAINT [PK_tblICInventoryLIFOOut] PRIMARY KEY CLUSTERED ([intId])    
	)
GO

	--CREATE NONCLUSTERED INDEX [IX_tblICInventoryLIFOOut_intInventoryTransactionId]
	--	ON [dbo].[tblICInventoryLIFOOut]([intInventoryTransactionId] ASC)
	--	INCLUDE(intInventoryLIFOId);
	--GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryLIFOOut]
		ON [dbo].[tblICInventoryLIFOOut]([intInventoryLIFOId] ASC, [intInventoryTransactionId] ASC)
GO
