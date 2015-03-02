/*
## Overview
The master table for lot numbers. 
Lot numbers are unique per item-location. 

## Fields, description, and mapping. 
*	[intLotId] INT NOT NULL IDENTITY
	System control number. 
	Maps: None 


* 	[intItemLocationId] INT NOT NULL
	Foreign key to tblICItemLocation. One of the primary keys in this table. 
	Maps: None


* 	[strLotNumber] NVARCHAR(50)
	One of the primary keys in this table. A lot number is unique per item-location
	Maps: None


* 	[intConcurrencyId] INT NULL
	Concurrency field. 
	Maps: None


## Source Code:
*/
	CREATE TABLE [dbo].[tblICLot]
	(
		[intLotId] INT NOT NULL IDENTITY, 		
		[intItemLocationId] INT NOT NULL,
		[intItemUOMId] INT NOT NULL,
		[strLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
		[dblOnHand] NUMERIC(18,6) DEFAULT ((0)),
		[intConcurrencyId] INT NULL DEFAULT ((0)),
		CONSTRAINT [PK_tblICLot] PRIMARY KEY CLUSTERED ([intLotId] ASC),
		CONSTRAINT [UN_tblICLot] UNIQUE NONCLUSTERED ([intItemLocationId] ASC, [strLotNumber] ASC),
		CONSTRAINT [FK_tblICLot_tblICItemLocation] FOREIGN KEY ([intItemLocationId]) REFERENCES [tblICItemLocation]([intItemLocationId]),
		CONSTRAINT [FK_tblICLot_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]) 
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICLot_intItemLocationId_strLotNumber]
		ON [dbo].[tblICLot]([intItemLocationId] ASC, [strLotNumber] ASC);

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICLot',
		@level2type = N'COLUMN',
		@level2name = N'intLotId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Lot Number for an Item',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICLot',
		@level2type = N'COLUMN',
		@level2name = N'strLotNumber'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICLot',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'