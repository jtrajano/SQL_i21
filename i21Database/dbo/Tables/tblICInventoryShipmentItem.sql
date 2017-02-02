/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryShipmentItem]
	(
		[intInventoryShipmentItemId] INT NOT NULL IDENTITY, 
		[intInventoryShipmentId] INT NOT NULL, 
		[intOrderId] INT NULL,
		[intSourceId] INT NULL,
		[intLineNo] INT NULL,
		[intItemId] INT NOT NULL, 
		[intSubLocationId] INT NULL, 
		[intStorageLocationId] INT NULL,
		[intOwnershipType] INT NOT NULL DEFAULT ((1)),
		[dblQuantity] NUMERIC(38, 20) NOT NULL DEFAULT ((0)), 
		[intItemUOMId] INT NOT NULL, 
		[intCurrencyId] INT NULL,
		[intWeightUOMId] INT NULL,
		[dblUnitPrice] NUMERIC(38, 20) NULL DEFAULT ((0)), 
		[intDockDoorId] INT NULL, 
		[strNotes] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[intGradeId] INT NULL,
		[intDestinationGradeId] INT NULL,
		[intDestinationWeightId] INT NULL,
		[intDiscountSchedule] INT NULL,
		[intStorageScheduleTypeId] INT NULL,
		[intSort] INT NULL, 
		[intForexRateTypeId] INT NULL, 
		[dblForexRate] NUMERIC(18, 6) NULL,
		[intConcurrencyId] INT NULL DEFAULT ((0)),		
		CONSTRAINT [PK_tblICInventoryShipmentItem] PRIMARY KEY ([intInventoryShipmentItemId]), 
		CONSTRAINT [FK_tblICInventoryShipmentItem_tblICInventoryShipment] FOREIGN KEY ([intInventoryShipmentId]) REFERENCES [tblICInventoryShipment]([intInventoryShipmentId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICInventoryShipmentItem_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
		CONSTRAINT [FK_tblICInventoryShipmentItem_tblICItemUOM] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
		CONSTRAINT [FK_tblICInventoryShipmentItem_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]), 
		CONSTRAINT [FK_tblICInventoryShipmentItem_WeightUOM] FOREIGN KEY ([intWeightUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
		CONSTRAINT [FK_tblICInventoryShipmentItem_tblICCommodityAttribute] FOREIGN KEY ([intGradeId]) REFERENCES [tblICCommodityAttribute]([intCommodityAttributeId]), 
		CONSTRAINT [FK_tblICInventoryShipmentItem_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]), 
		CONSTRAINT [FK_tblICInventoryShipmentItem_tblGRDiscountId] FOREIGN KEY ([intDiscountSchedule]) REFERENCES [tblGRDiscountId]([intDiscountId]), 
		CONSTRAINT [FK_tblICInventoryShipmentItem_tblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]), 
		CONSTRAINT [FK_tblICInventoryShipmentItem_tblCTWeightGrade_Grades] FOREIGN KEY ([intDestinationGradeId]) REFERENCES [tblCTWeightGrade]([intWeightGradeId]),
		CONSTRAINT [FK_tblICInventoryShipmentItem_tblCTWeightGrade_Weights] FOREIGN KEY ([intDestinationWeightId]) REFERENCES [tblCTWeightGrade]([intWeightGradeId]),
		CONSTRAINT [FK_tblICInventoryShipmentItem_tblSMCurrencyExchangeRateType] FOREIGN KEY ([intForexRateTypeId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItem',
		@level2type = N'COLUMN',
		@level2name = N'intInventoryShipmentItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Inventory Shipment Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItem',
		@level2type = N'COLUMN',
		@level2name = N'intInventoryShipmentId'
	GO
	
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItem',
		@level2type = N'COLUMN',
		@level2name = N'intItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sub Location Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItem',
		@level2type = N'COLUMN',
		@level2name = N'intSubLocationId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Quantity',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItem',
		@level2type = N'COLUMN',
		@level2name = N'dblQuantity'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Item Unit of Measure Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItem',
		@level2type = N'COLUMN',
		@level2name = 'intItemUOMId'
	GO
	
	GO
	
	GO
	
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Unit Price',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItem',
		@level2type = N'COLUMN',
		@level2name = N'dblUnitPrice'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Dock Door Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItem',
		@level2type = N'COLUMN',
		@level2name = N'intDockDoorId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Notes',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItem',
		@level2type = N'COLUMN',
		@level2name = N'strNotes'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItem',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryShipmentItem',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Source Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'intSourceId'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Line No',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'intLineNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weight Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'intWeightUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Order Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryShipmentItem',
    @level2type = N'COLUMN',
    @level2name = N'intOrderId'