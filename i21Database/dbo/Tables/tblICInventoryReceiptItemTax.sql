/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryReceiptItemTax]
	(
		[intInventoryReceiptItemTaxId] INT NOT NULL IDENTITY, 
		[intInventoryReceiptItemId] INT NOT NULL, 
		[intTaxGroupId] INT NULL,
		[intTaxCodeId] INT NULL,
		[intTaxClassId] INT NULL,	
		[strTaxableByOtherTaxes] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
		[strCalculationMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[dblRate] NUMERIC(18, 6) NULL DEFAULT ((0)),
		[dblTax] NUMERIC(18, 6) NULL DEFAULT ((0)),
		[dblAdjustedTax] NUMERIC(18, 6) NULL DEFAULT ((0)),		
		[intTaxAccountId] INT NULL,
		[ysnTaxAdjusted] BIT NULL DEFAULT ((0)),
		[ysnTaxOnly] BIT NULL DEFAULT ((0)),
		[ysnSeparateOnInvoice] BIT NULL DEFAULT ((0)),
		[ysnCheckoffTax] BIT NULL DEFAULT ((0)),
		[ysnTaxExempt] BIT NULL DEFAULT ((0)),
		[strTaxCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[dblQty] NUMERIC(38, 20) NULL DEFAULT ((1)),
		[dblCost] NUMERIC(18, 6) NULL DEFAULT ((0)),
		[intUnitMeasureId] INT NULL,
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)),
		[dtmDateCreated] DATETIME NULL,
        [dtmDateModified] DATETIME NULL,
        [intCreatedByUserId] INT NULL,
        [intModifiedByUserId] INT NULL, 
		CONSTRAINT [PK_tblICInventoryReceiptItemTax] PRIMARY KEY ([intInventoryReceiptItemTaxId]), 
		CONSTRAINT [FK_tblICInventoryReceiptItemTax_tblICInventoryReceiptItem] FOREIGN KEY ([intInventoryReceiptItemId]) REFERENCES [tblICInventoryReceiptItem]([intInventoryReceiptItemId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICInventoryReceiptItemTax_tblSMTaxCode] FOREIGN KEY ([intTaxCodeId]) REFERENCES [tblSMTaxCode]([intTaxCodeId]),
		CONSTRAINT [FK_tblICInventoryReceiptItemTax_tblSMTaxClass] FOREIGN KEY ([intTaxClassId]) REFERENCES [tblSMTaxClass]([intTaxClassId]),
		CONSTRAINT [FK_tblICInventoryReceiptItemTax_tblSMTaxGroup] FOREIGN KEY ([intTaxGroupId]) REFERENCES [tblSMTaxGroup]([intTaxGroupId]),
		CONSTRAINT [FK_tblICInventoryReceiptItemTax_tblGLAccount] FOREIGN KEY ([intTaxAccountId]) REFERENCES [tblGLAccount]([intAccountId])
	)

	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Identity Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemTax',
		@level2type = N'COLUMN',
		@level2name = N'intInventoryReceiptItemTaxId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Inventory Receipt Item Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemTax',
		@level2type = N'COLUMN',
		@level2name = N'intInventoryReceiptItemId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Tax Code Id',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemTax',
		@level2type = N'COLUMN',
		@level2name = N'intTaxCodeId'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Sort Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemTax',
		@level2type = N'COLUMN',
		@level2name = N'intSort'
	GO
	EXEC sp_addextendedproperty @name = N'MS_Description',
		@value = N'Concurrency Field',
		@level0type = N'SCHEMA',
		@level0name = N'dbo',
		@level1type = N'TABLE',
		@level1name = N'tblICInventoryReceiptItemTax',
		@level2type = N'COLUMN',
		@level2name = N'intConcurrencyId'