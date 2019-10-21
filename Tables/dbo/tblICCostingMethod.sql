/*
## Overview
The master table for all the supported costing methods. 

## Fields, description, and mapping. 
*	[intCostingMethodId] INT NOT NULL IDENTITY
	System control number. 
	Maps: None 


* 	[strCostingMethod] NVARCHAR(50)
	The name of the costing methods
	Maps: None


* 	[intConcurrencyId] INT NULL
	Concurrency field. 
	Maps: None


## Source Code:
*/
	CREATE TABLE [dbo].[tblICCostingMethod]
	(
		[intCostingMethodId] INT NOT NULL IDENTITY, 		
		[strCostingMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)),
		CONSTRAINT [PK_tblICCostingMethod] PRIMARY KEY CLUSTERED ([intCostingMethodId] ASC),
		CONSTRAINT [UN_tblICCostingMethod] UNIQUE NONCLUSTERED ([strCostingMethod] ASC),
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICLot_intCostingMethodId_strCostingMethod]
		ON [dbo].[tblICCostingMethod]([intCostingMethodId] ASC, [strCostingMethod] ASC);

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCostingMethod',
		@level2type = N'COLUMN',
		@level2name = N'intCostingMethodId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Name of the costing method',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCostingMethod',
		@level2type = N'COLUMN',
		@level2name = N'strCostingMethod'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICCostingMethod',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'