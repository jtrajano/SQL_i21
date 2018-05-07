/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICCommodityAttribute]
	(
		[intCommodityAttributeId] INT NOT NULL IDENTITY, 
		[intCommodityId] INT NOT NULL , 
		[strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intDefaultPackingUOMId] INT NULL,
		[intCountryID] INT NULL,
		[intPurchasingGroupId] INT NULL,
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)),
		[dtmDateCreated] DATETIME NULL,
        [dtmDateModified] DATETIME NULL,
        [intCreatedByUserId] INT NULL,
        [intModifiedByUserId] INT NULL, 
		CONSTRAINT [PK_tblICCommodityAttribute] PRIMARY KEY ([intCommodityAttributeId]), 
		CONSTRAINT [PK_tblICCommodityAttribute_tblSMPurchasingGroup] FOREIGN KEY ([intPurchasingGroupId]) REFERENCES [tblSMPurchasingGroup] ([intPurchasingGroupId]),
		CONSTRAINT [PK_tblICCommodityAttribute_tblSMCountry] FOREIGN KEY ([intCountryID]) REFERENCES [tblSMCountry] ([intCountryID]),
		CONSTRAINT [PK_tblICCommodityAttribute_tblICUnitMeasure] FOREIGN KEY ([intDefaultPackingUOMId]) REFERENCES [tblICUnitMeasure] ([intUnitMeasureId]),
		CONSTRAINT [FK_tblICCommodityAttribute_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]) ON DELETE CASCADE
	)
	GO

	CREATE UNIQUE NONCLUSTERED INDEX [IX_tblICCommodityAttribute] ON [dbo].[tblICCommodityAttribute] ([intCommodityId], [strType], [strDescription]) WITH (IGNORE_DUP_KEY = OFF)
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodityAttribute',
		@level2type = N'COLUMN',
		@level2name = N'intCommodityAttributeId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Commodity Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodityAttribute',
		@level2type = N'COLUMN',
		@level2name = N'intCommodityId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Attribute Type',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodityAttribute',
		@level2type = N'COLUMN',
		@level2name = N'strType'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Description',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodityAttribute',
		@level2type = N'COLUMN',
		@level2name = N'strDescription'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodityAttribute',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCommodityAttribute',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'