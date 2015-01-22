/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code: 
*/
	CREATE TABLE [dbo].[tblICCertification]
	(
		[intCertificationId] INT NOT NULL IDENTITY , 
		[strCertificationName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
		[strIssuingOrganization] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
		[ysnGlobalCertification] BIT NOT NULL, 
		[intCountryId] INT NULL, 
		[strCertificationIdName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICCertification] PRIMARY KEY ([intCertificationId]), 
		CONSTRAINT [AK_tblICCertification_strCertificationName] UNIQUE ([strCertificationName]), 
		CONSTRAINT [FK_tblICCertification_tblSMCountry] FOREIGN KEY ([intCountryId]) REFERENCES [tblSMCountry]([intCountryID])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCertification',
		@level2type = N'COLUMN',
		@level2name = N'intCertificationId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Certification Name',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCertification',
		@level2type = N'COLUMN',
		@level2name = N'strCertificationName'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Issuing Organization',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCertification',
		@level2type = N'COLUMN',
		@level2name = N'strIssuingOrganization'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Global Certification',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCertification',
		@level2type = N'COLUMN',
		@level2name = N'ysnGlobalCertification'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Country Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCertification',
		@level2type = N'COLUMN',
		@level2name = N'intCountryId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Certification Id Name',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCertification',
		@level2type = N'COLUMN',
		@level2name = N'strCertificationIdName'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCertification',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'