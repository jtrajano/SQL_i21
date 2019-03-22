/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
CREATE TABLE [dbo].[tblICItemUomUpc]
(
	[intItemUomUpcId] INT NOT NULL IDENTITY , 
	[intItemUOMId] INT NOT NULL , 
	[strUpcCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[strLongUpcCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NULL DEFAULT ((0)),
    [dtmDateCreated] DATETIME NULL,
    [dtmDateModified] DATETIME NULL,
    [intCreatedByUserId] INT NULL,
    [intModifiedByUserId] INT NULL, 
	CONSTRAINT [PK_tblICItemUOMAltUPC] PRIMARY KEY ([intItemUomUpcId]), 
	CONSTRAINT [FK_tblICItemUOMAltUPC_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]) ON DELETE CASCADE
)
GO
	CREATE NONCLUSTERED INDEX [IX_tblICItemUomUpc]
	ON [dbo].[tblICItemUomUpc]([intItemUOMId] ASC)
	INCLUDE(strUpcCode, strLongUpcCode); 

GO 
	CREATE UNIQUE NONCLUSTERED INDEX [AK_tblICItemUomUpc_strUpcCode]
	ON tblICItemUomUpc([strUpcCode])
	WHERE 
		[strUpcCode] IS NOT NULL 
		AND [strUpcCode] <> '';
GO

	CREATE UNIQUE NONCLUSTERED INDEX [AK_tblICItemUomUpc_strLongUpcCode]
	ON tblICItemUomUpc([strLongUpcCode])
	WHERE 
		[strLongUpcCode] IS NOT NULL
		AND [strLongUpcCode] <> '';		
GO