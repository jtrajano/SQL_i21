﻿/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemOwner]
	(
		[intItemOwnerId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL, 
		[intOwnerId] INT NOT NULL, 
		[ysnDefault] BIT NULL DEFAULT ((0)), 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)),
		[dtmDateCreated] DATETIME NULL,
        [dtmDateModified] DATETIME NULL,
        [intCreatedByUserId] INT NULL,
        [intModifiedByUserId] INT NULL, 
		CONSTRAINT [PK_tblICItemOwner] PRIMARY KEY ([intItemOwnerId]), 
		CONSTRAINT [FK_tblICItemOwner_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICItemOwner_tblARCustomer] FOREIGN KEY ([intOwnerId]) REFERENCES [tblARCustomer]([intEntityId]),
		CONSTRAINT [UN_tblICItemOwner] UNIQUE NONCLUSTERED ([intItemId] ASC, [intOwnerId] ASC)
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemOwner',
		@level2type = N'COLUMN',
		@level2name = N'intItemOwnerId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemOwner',
		@level2type = N'COLUMN',
		@level2name = N'intItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Owner Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemOwner',
		@level2type = N'COLUMN',
		@level2name = N'intOwnerId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Active',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemOwner',
		@level2type = N'COLUMN',
		@level2name = 'ysnDefault'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemOwner',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemOwner',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'