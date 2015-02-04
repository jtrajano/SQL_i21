/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICItemUPC]
	(
		[intItemUPCId] INT NOT NULL IDENTITY, 
		[intItemId] INT NOT NULL, 
		[intItemUnitMeasureId] INT NOT NULL, 
		[dblUnitQty] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
		[strUPCCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICItemUPC] PRIMARY KEY ([intItemUPCId]), 
		CONSTRAINT [FK_tblICItemUPC_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICItemUPC_tblICItemUOM] FOREIGN KEY ([intItemUnitMeasureId]) REFERENCES [tblICItemUOM]([intItemUOMId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICItemUPC',
		@level2type = N'COLUMN',
		@level2name = N'intItemUPCId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICItemUPC',
    @level2type = N'COLUMN',
    @level2name = N'intItemUnitMeasureId'