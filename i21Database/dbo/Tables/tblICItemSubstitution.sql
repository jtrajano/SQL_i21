/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemSubstitution]
	(
		[intItemSubstitutionId] INT NOT NULL IDENTITY, 
		[intLocationId] INT NOT NULL, 
		[intItemId] INT NOT NULL, 
		[strModification] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[ysnContracted] BIT NULL DEFAULT ((0)),
		[strComment] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICItemSubstitution] PRIMARY KEY ([intItemSubstitutionId]), 
		CONSTRAINT [AK_tblICItemSubstitution_intItemId] UNIQUE ([intLocationId], [intItemId]), 
		CONSTRAINT [FK_tblICItemSubstitution_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
		CONSTRAINT [FK_tblICItemSubstitution_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSubstitution',
		@level2type = N'COLUMN',
		@level2name = N'intItemSubstitutionId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSubstitution',
		@level2type = N'COLUMN',
		@level2name = N'intItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Modification Type',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSubstitution',
		@level2type = N'COLUMN',
		@level2name = N'strModification'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Comment',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSubstitution',
		@level2type = N'COLUMN',
		@level2name = N'strComment'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSubstitution',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSubstitution',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'