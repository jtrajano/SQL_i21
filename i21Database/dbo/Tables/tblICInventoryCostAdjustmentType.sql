/*
## Overview
	This table lists out the different types of cost adjustments. 

## Fields, description, and mapping. 
*	[intInventoryCostAdjustmentTypeId] INT NOT NULL, 
	Primay key. 
	Maps: None 


## Source Code:
*/
CREATE TABLE [dbo].[tblICInventoryCostAdjustmentType]
(
	[intInventoryCostAdjustmentTypeId] INT NOT NULL, 
	[strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 		
	CONSTRAINT [PK_tblICInventoryCostAdjustmentType] PRIMARY KEY CLUSTERED ([intInventoryCostAdjustmentTypeId])
)
