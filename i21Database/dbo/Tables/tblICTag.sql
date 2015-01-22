/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICTag]
	(
		[intTagId] INT NOT NULL  IDENTITY, 
		[strTagNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[ysnHazMat] BIT NULL DEFAULT ((0)), 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICTag] PRIMARY KEY ([intTagId]), 
		CONSTRAINT [AK_tblICTag_strTagNumber] UNIQUE ([strTagNumber])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICTag',
		@level2type = N'COLUMN',
		@level2name = N'intTagId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Tag Number',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICTag',
		@level2type = N'COLUMN',
		@level2name = N'strTagNumber'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Description',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICTag',
		@level2type = N'COLUMN',
		@level2name = N'strDescription'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Message',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICTag',
		@level2type = N'COLUMN',
		@level2name = N'strMessage'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Hazardous Material',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICTag',
		@level2type = N'COLUMN',
		@level2name = N'ysnHazMat'