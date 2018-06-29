/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblMFPackType]
	(
		[intPackTypeId] INT NOT NULL IDENTITY, 
		[strPackName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[intCreatedUserId] [int] NULL,
		[dtmCreated] [datetime] NULL CONSTRAINT [DF_tblMFPackType_dtmCreated] DEFAULT GetDate(),
		[intLastModifiedUserId] [int] NULL,
		[dtmLastModified] [datetime] NULL CONSTRAINT [DF_tblMFPackType_dtmLastModified] DEFAULT GetDate(),	
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblMFPackType] PRIMARY KEY ([intPackTypeId]), 
		CONSTRAINT [UQ_tblMFPackType_strPackName] UNIQUE ([strPackName]) 
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblMFPackType',
		@level2type = N'COLUMN',
		@level2name = N'intPackTypeId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Pack Name',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblMFPackType',
		@level2type = N'COLUMN',
		@level2name = N'strPackName'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Description',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblMFPackType',
		@level2type = N'COLUMN',
		@level2name = N'strDescription'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblMFPackType',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'