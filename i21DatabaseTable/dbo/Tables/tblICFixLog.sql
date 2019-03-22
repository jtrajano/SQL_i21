/*
## Overview
This table logs any required data fix that needs to be executed in a deployment. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code: 
*/
	CREATE TABLE [dbo].[tblICFixLog]
	(
		[id] INT NOT NULL IDENTITY, 
		[strFixName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strFixDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[dtmLog] DATETIME NULL,
		CONSTRAINT [PK_tblICFixLog] PRIMARY KEY ([strFixName])
	)

