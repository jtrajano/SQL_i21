/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code: 
*/
	CREATE TABLE [dbo].[tblICInventoryGLAccountUsedOnPostLog]
	(
		[intId] INT NOT NULL IDENTITY , 
		[intItemId] INT NOT NULL, 
		[intItemLocationId] INT NOT NULL, 
		[intInventoryId] INT NULL, 
		[intContraInventoryId] INT NULL, 
		[intWriteOffSoldId] INT NULL DEFAULT ((0)), 
		[intRevalueSoldId] INT NULL, 
		[intAutoNegativeId] INT NULL, 
		[strBatchId] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
		[dtmDateCreated] DATETIME NULL DEFAULT (GETDATE()), 
		CONSTRAINT [PK_tblICInventoryGLAccountUsedOnPostLog] PRIMARY KEY ([intId])
	)

