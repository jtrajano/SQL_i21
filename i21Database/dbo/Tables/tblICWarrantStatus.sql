/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICWarrantStatus]
	(
		[intWarrantStatus] TINYINT NOT NULL IDENTITY, 
		[strWarrantStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICWarrantStatus] PRIMARY KEY ([intWarrantStatus])
	)

	GO