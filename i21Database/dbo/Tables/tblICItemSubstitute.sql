/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
CREATE TABLE [dbo].[tblICItemSubstitute]
(
	[intItemSubstituteId] INT NOT NULL IDENTITY, 
	[intItemId] INT NOT NULL, 
	[intSubstituteItemId] INT NOT NULL, 
	[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[dblQuantity] NUMERIC(38, 20) NULL DEFAULT ((0)), 
	[intItemUOMId] INT NULL, 
	[dblMarkUpOrDown] NUMERIC(38,20) NULL DEFAULT((0)),
	[dtmBeginDate] DATETIME NULL,
	[dtmEndDate] DATETIME NULL,
	[intConcurrencyId] INT NULL DEFAULT ((0)),
	[dtmDateCreated] DATETIME NULL,
	[dtmDateModified] DATETIME NULL,
	[intCreatedByUserId] INT NULL,
	[intModifiedByUserId] INT NULL, 
	CONSTRAINT [PK_tblICItemSubstitute] PRIMARY KEY ([intItemSubstituteId]),
	CONSTRAINT [FK_tblICItemSubstitute_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
	CONSTRAINT [FK_tblICItemSubstitute_SubstituteItem] FOREIGN KEY ([intSubstituteItemId]) REFERENCES [tblICItem]([intItemId]), 
	CONSTRAINT [FK_tblICItemSubstitute_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId])
)