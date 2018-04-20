﻿/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICFuelTaxClass]
	(
		[intFuelTaxClassId] INT NOT NULL IDENTITY, 
		[strTaxClassCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strIRSTaxCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intCompanyId] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICFuelTaxClass] PRIMARY KEY ([intFuelTaxClassId]), 
		CONSTRAINT [AK_tblICFuelTaxClass_strTaxClassCode] UNIQUE ([strTaxClassCode])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelTaxClass',
		@level2type = N'COLUMN',
		@level2name = N'intFuelTaxClassId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Tax Class Code',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelTaxClass',
		@level2type = N'COLUMN',
		@level2name = N'strTaxClassCode'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Description',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelTaxClass',
		@level2type = N'COLUMN',
		@level2name = N'strDescription'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'IRS Tax Code',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelTaxClass',
		@level2type = N'COLUMN',
		@level2name = N'strIRSTaxCode'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICFuelTaxClass',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'