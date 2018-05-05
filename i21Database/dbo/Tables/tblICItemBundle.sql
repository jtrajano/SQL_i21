﻿/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemBundle]
	(
		[intItemBundleId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL, 
		[intBundleItemId] INT NOT NULL, 
		[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
		[dblQuantity] NUMERIC(38, 20) NULL DEFAULT ((0)), 
		[intItemUnitMeasureId] INT NULL, 
		[ysnAddOn] BIT NOT NULL DEFAULT(0),
		[dblMarkUpOrDown] NUMERIC(38,20) NULL DEFAULT((0)),
		[dtmBeginDate] DATETIME NULL,
		[dtmEndDate] DATETIME NULL,
		--[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)),
		[dtmDateCreated] DATETIME NULL,
        [dtmDateModified] DATETIME NULL,
        [intCreatedByUserId] INT NULL,
        [intModifiedByUserId] INT NULL,
		CONSTRAINT [PK_tblICItemBundle] PRIMARY KEY ([intItemBundleId]),
		CONSTRAINT [FK_tblICItemBundle_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICItemBundle_BundleItem] FOREIGN KEY ([intBundleItemId]) REFERENCES [tblICItem]([intItemId]), 
		CONSTRAINT [FK_tblICItemBundle_tblICItemUOM] FOREIGN KEY ([intItemUnitMeasureId]) REFERENCES [tblICItemUOM]([intItemUOMId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemBundle',
		@level2type = N'COLUMN',
		@level2name = N'intItemBundleId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemBundle',
		@level2type = N'COLUMN',
		@level2name = N'intItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Bundle Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemBundle',
		@level2type = N'COLUMN',
		@level2name = N'intBundleItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Description',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemBundle',
		@level2type = N'COLUMN',
		@level2name = N'strDescription'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Quantity',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemBundle',
		@level2type = N'COLUMN',
		@level2name = N'dblQuantity'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Unit of Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemBundle',
		@level2type = N'COLUMN',
		@level2name = 'intItemUnitMeasureId'
	GO
	
	GO
	
	--GO
	--EXEC sp_addextendedproperty @name = N'MS_Description',
	--	@value = N'Sort Field',
	--	@level0type = N'SCHEMA',
	--	@level0name = N'dbo',
	--	@level1type = N'TABLE',
	--	@level1name = N'tblICItemBundle',
	--	@level2type = N'COLUMN',
	--	@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemBundle',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'