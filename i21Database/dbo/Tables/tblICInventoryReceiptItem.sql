/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryReceiptItem]
	(
		[intInventoryReceiptItemId] INT NOT NULL IDENTITY, 
		[intInventoryReceiptId] INT NOT NULL, 
		[intLineNo] INT NOT NULL, 
		[intOrderId] INT NULL,
		[intSourceId] INT NULL,
		[intItemId] INT NOT NULL, 
		[intContainerId] INT NULL,
		[intSubLocationId] INT NULL,
		[intStorageLocationId] INT NULL,
		[intOwnershipType] INT NOT NULL DEFAULT ((1)),
		[dblOrderQty] NUMERIC(38, 15) NULL DEFAULT ((0)), 
		[dblBillQty] NUMERIC(38, 15) NULL DEFAULT ((0)), 
		[dblOpenReceive] NUMERIC(38, 15) NULL DEFAULT ((0)),
		[intLoadReceive] INT NULL DEFAULT ((0)), 
		[dblReceived] NUMERIC(38, 15) NULL DEFAULT ((0)), 
		[intUnitMeasureId] INT NOT NULL, 
		[intWeightUOMId] INT NULL,
		[intCostUOMId] INT NULL,
		[dblUnitCost] NUMERIC(38, 15) NULL DEFAULT ((0)),
		[dblUnitRetail] NUMERIC(38, 15) NULL DEFAULT ((0)),
		[ysnSubCurrency] BIT NULL DEFAULT ((0)),
		[dblLineTotal] NUMERIC(38, 15) NULL DEFAULT ((0)), 
		[intGradeId] INT NULL,		
		[dblGross] NUMERIC(38, 15) NULL DEFAULT ((0)),
		[dblNet] NUMERIC(38, 15) NULL DEFAULT ((0)),
		[dblTax] NUMERIC(38, 15) NULL DEFAULT ((0)),
		[intDiscountSchedule] INT NULL,
		[ysnExported] BIT NULL,
		[dtmExportedDate] DATETIME NULL,
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		[strComments] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[intTaxGroupId] INT NULL,
		[intSourceInventoryReceiptItemId] INT NULL,
		[dblQtyReturned] NUMERIC(38, 15) NULL DEFAULT ((0)),
		[dblGrossReturned] NUMERIC(38, 15) NULL DEFAULT ((0)),
		[dblNetReturned] NUMERIC(38, 15) NULL DEFAULT ((0)),		
		[intForexRateTypeId] INT NULL, 
		[dblForexRate] NUMERIC(38, 15) NULL,
		[ysnLotWeightsRequired] BIT NULL DEFAULT((0)),
		[strChargesLink] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
		[strItemType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strWarehouseRefNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[intParentItemLinkId] INT NULL,
		[intChildItemLinkId] INT NULL,
		[intCostingMethod] INT NULL,
        [dtmDateCreated] DATETIME NULL,
        [dtmDateModified] DATETIME NULL,
        [intCreatedByUserId] INT NULL,
        [intModifiedByUserId] INT NULL,
		[intTicketId] INT NULL, -- Scale Ticket Id
		[intInventoryTransferId] INT NULL, -- Inventory Transfer Header Id
		[intInventoryTransferDetailId] INT NULL, -- Inventory Transfer Detail Id
		[intPurchaseId] INT NULL, -- Purchase Order Header Id
		[intPurchaseDetailId] INT NULL, -- Purchase Order Detail Id
		[intContractHeaderId] INT NULL, -- Contract Header Id
		[intContractDetailId] INT NULL, -- Contract Detail Id
		[intLoadShipmentId] INT NULL,
		[intLoadShipmentDetailId] INT NULL,
		[ysnAllowVoucher] BIT NULL,
		[strActualCostId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		CONSTRAINT [PK_tblICInventoryReceiptItem] PRIMARY KEY ([intInventoryReceiptItemId]), 
		CONSTRAINT [FK_tblICInventoryReceiptItem_tblICInventoryReceipt] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [tblICInventoryReceipt]([intInventoryReceiptId]), -- ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICInventoryReceiptItem_tblICItemUOM] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
		CONSTRAINT [FK_tblICInventoryReceiptItem_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]) ON DELETE NO ACTION, 
		CONSTRAINT [FK_tblICInventoryReceiptItem_WeightUOM] FOREIGN KEY ([intWeightUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
		CONSTRAINT [FK_tblICInventoryReceiptItem_tblICCommodityAttribute] FOREIGN KEY ([intGradeId]) REFERENCES [tblICCommodityAttribute]([intCommodityAttributeId]), 
		CONSTRAINT [FK_tblICInventoryReceiptItem_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId]), 
		CONSTRAINT [FK_tblICInventoryReceiptItem_CostUOM] FOREIGN KEY ([intCostUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
		CONSTRAINT [FK_tblICInventoryReceiptItem_tblGRDiscountId] FOREIGN KEY ([intDiscountSchedule]) REFERENCES [tblGRDiscountId]([intDiscountId]), 
		--CONSTRAINT [FK_tblICInventoryReceiptItem_tblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID])
		CONSTRAINT [Check_AllowOnlyWeightOrVolumeTypeOnGrossNetUOM] CHECK (dbo.fnICIsShrinkableUOM(intWeightUOMId) = 1),
		--CONSTRAINT [FK_tblICInventoryReceiptItem_tblSMTaxGroup] FOREIGN KEY ([intTaxGroupId]) REFERENCES [tblSMTaxGroup]([intTaxGroupId])
		CONSTRAINT [FK_tblICInventoryReceiptItem_tblSMCurrencyExchangeRateType] FOREIGN KEY ([intForexRateTypeId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId])
	)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryReceiptItem]
		ON [dbo].[tblICInventoryReceiptItem]([intInventoryReceiptId] ASC, [intInventoryReceiptItemId] ASC, [strChargesLink] ASC);

	GO
	
	CREATE NONCLUSTERED INDEX IX_tblICInventoryReceiptItem_SourceId
		ON tblICInventoryReceiptItem (intSourceId, intLineNo, intOrderId)
	GO

	CREATE NONCLUSTERED INDEX [IX_tblICInventoryReceiptItem_intLineNo]
		ON [dbo].[tblICInventoryReceiptItem] ([intLineNo])
		INCLUDE ([intInventoryReceiptId],[intSourceId])
	GO
		
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Inventory Receipt Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItem',
		@level2type = N'COLUMN',
		@level2name = N'intInventoryReceiptId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItem',
		@level2type = N'COLUMN',
		@level2name = N'intInventoryReceiptItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Line No',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItem',
		@level2type = N'COLUMN',
		@level2name = N'intLineNo'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Source Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intSourceId'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intItemId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Order Qauantity',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'dblOrderQty'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quantity to Receive',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'dblOpenReceive'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Received',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'dblReceived'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Item Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intUnitMeasureId'
GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Cost',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'dblUnitCost'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Line Total',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'dblLineTotal'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Sort Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intSort'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Concurrency Field',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intConcurrencyId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Weign Unit of Measure Id',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intWeightUOMId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Unit Retail',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'dblUnitRetail'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Order Number',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intOrderId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Container Id for Inbound Shipments',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'tblICInventoryReceiptItem',
    @level2type = N'COLUMN',
    @level2name = N'intContainerId'

GO

CREATE TRIGGER trg_tblICInventoryReceiptItem 
   ON [dbo].[tblICInventoryReceiptItem]
   INSTEAD OF DELETE
AS 
BEGIN
	SET NOCOUNT ON;
	DELETE FROM tblICInventoryReceiptChargePerItem WHERE intInventoryReceiptItemId IN (SELECT intInventoryReceiptItemId FROM DELETED)
	DELETE FROM tblICInventoryReceiptItem WHERE intInventoryReceiptItemId IN (SELECT intInventoryReceiptItemId FROM DELETED)
END

GO