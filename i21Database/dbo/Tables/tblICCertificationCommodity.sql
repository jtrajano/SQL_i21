/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code: 
*/
	CREATE TABLE [dbo].[tblICCertificationCommodity]
	(
		[intCertificationCommodityId] INT NOT NULL IDENTITY, 
		[intCertificationId] INT NOT NULL, 
		[intCommodityId] INT NOT NULL, 
		[intCurrencyId] INT NOT NULL, 
		[dblCertificationPremium] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
		[intUnitMeasureId] INT NOT NULL, 
		[dtmDateEffective] DATETIME NOT NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICCertificationCommodity] PRIMARY KEY ([intCertificationCommodityId]), 
		CONSTRAINT [FK_tblICCertificationCommodity_tblICCertification] FOREIGN KEY ([intCertificationId]) REFERENCES [tblICCertification]([intCertificationId]), 
		CONSTRAINT [FK_tblICCertificationCommodity_tblICCommodity] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId]), 
		CONSTRAINT [FK_tblICCertificationCommodity_tblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]), 
		CONSTRAINT [FK_tblICCertificationCommodity_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId]) 
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCertificationCommodity',
		@level2type = N'COLUMN',
		@level2name = N'intCertificationCommodityId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Certification Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCertificationCommodity',
		@level2type = N'COLUMN',
		@level2name = N'intCertificationId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Commodity Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCertificationCommodity',
		@level2type = N'COLUMN',
		@level2name = N'intCommodityId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Currency Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCertificationCommodity',
		@level2type = N'COLUMN',
		@level2name = N'intCurrencyId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCertificationCommodity',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCertificationCommodity',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Date Effective',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCertificationCommodity',
		@level2type = N'COLUMN',
		@level2name = N'dtmDateEffective'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Unit Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCertificationCommodity',
		@level2type = N'COLUMN',
		@level2name = N'intUnitMeasureId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Certification Premium',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCertificationCommodity',
		@level2type = N'COLUMN',
		@level2name = N'dblCertificationPremium'