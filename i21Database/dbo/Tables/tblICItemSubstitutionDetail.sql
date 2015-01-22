/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemSubstitutionDetail]
	(
		[intItemSubstitutionDetailId] INT NOT NULL IDENTITY, 
		[intItemSubstitutionId] INT NOT NULL, 
		[intSubstituteItemId] INT NOT NULL, 
		[dtmValidFrom] DATETIME NULL, 
		[dtmValidTo] DATETIME NULL, 
		[dblRatio] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[dblPercent] NUMERIC(18, 6) NULL DEFAULT ((0)), 
		[ysnYearValidationRequired] BIT NULL DEFAULT ((0)), 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICItemSubstitutionDetail] PRIMARY KEY ([intItemSubstitutionDetailId]), 
		CONSTRAINT [FK_tblICItemSubstitutionDetail_tblICItem] FOREIGN KEY ([intSubstituteItemId]) REFERENCES [tblICItem]([intItemId]) 
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSubstitutionDetail',
		@level2type = N'COLUMN',
		@level2name = N'intItemSubstitutionDetailId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Substitution Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSubstitutionDetail',
		@level2type = N'COLUMN',
		@level2name = N'intItemSubstitutionId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Substitute Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSubstitutionDetail',
		@level2type = N'COLUMN',
		@level2name = N'intSubstituteItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Valid From',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSubstitutionDetail',
		@level2type = N'COLUMN',
		@level2name = N'dtmValidFrom'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Valid To',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSubstitutionDetail',
		@level2type = N'COLUMN',
		@level2name = N'dtmValidTo'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Substitution Ratio',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSubstitutionDetail',
		@level2type = N'COLUMN',
		@level2name = N'dblRatio'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Percent / Max Substitution Percentage',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSubstitutionDetail',
		@level2type = N'COLUMN',
		@level2name = N'dblPercent'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Year Validation Required',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSubstitutionDetail',
		@level2type = N'COLUMN',
		@level2name = N'ysnYearValidationRequired'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSubstitutionDetail',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemSubstitutionDetail',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'