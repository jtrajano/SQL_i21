/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
CREATE TABLE [dbo].[tblICItemCategoryChangeLog] (
	[intItemCategoryChangeLogId] INT IDENTITY (1, 1) NOT NULL,
	[intItemId] INT,
	[intOriginalCategoryId] INT,
	[intNewCategoryId] INT,
	[dtmDateChanged] DATETIME NULL,
	[intCreatedByUserId] INT NULL,
	CONSTRAINT [PK_tblICItemCategoryChangeLog] PRIMARY KEY ([intItemCategoryChangeLogId])
	--CONSTRAINT [FK_tblICItemCategoryChangeLog_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	--CONSTRAINT [FK_tblICItemCategoryChangeLog_intOriginalCategoryId] FOREIGN KEY ([intOriginalCategoryId]) REFERENCES [tblICCategory]([intCategoryId]),
	--CONSTRAINT [FK_tblICItemCategoryChangeLog_intNewCategoryId] FOREIGN KEY ([intNewCategoryId]) REFERENCES [tblICCategory]([intCategoryId])
);
GO

CREATE NONCLUSTERED INDEX [IX_tblICItemCategoryChangeLog_intItemId]
	ON [dbo].[tblICItemCategoryChangeLog]([intItemId] ASC, [dtmDateChanged] DESC)
	INCLUDE ([intOriginalCategoryId], [intNewCategoryId])
GO
