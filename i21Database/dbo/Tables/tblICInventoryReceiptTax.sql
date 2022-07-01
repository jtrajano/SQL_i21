/*
## Overview
This table holds the tax that applies to the entire receipt. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryReceiptTax]
	(
		[intInventoryReceiptTaxId] INT NOT NULL IDENTITY, 
		[intInventoryReceiptId] INT NOT NULL, 
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
		CONSTRAINT [PK_tblICInventoryReceiptTax] PRIMARY KEY ([intInventoryReceiptTaxId]), 
		CONSTRAINT [FK_tblICInventoryReceiptTax_tblICInventoryReceipt] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [tblICInventoryReceipt]([intInventoryReceiptId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICInventoryReceiptTax_tblSMTaxCode] FOREIGN KEY ([intTaxCodeId]) REFERENCES [tblSMTaxCode]([intTaxCodeId]),
		CONSTRAINT [FK_tblICInventoryReceiptTax_tblSMTaxClass] FOREIGN KEY ([intTaxClassId]) REFERENCES [tblSMTaxClass]([intTaxClassId]),
		CONSTRAINT [FK_tblICInventoryReceiptTax_tblSMTaxGroup] FOREIGN KEY ([intTaxGroupId]) REFERENCES [tblSMTaxGroup]([intTaxGroupId]),
		CONSTRAINT [FK_tblICInventoryReceiptTax_tblGLAccount] FOREIGN KEY ([intTaxAccountId]) REFERENCES [tblGLAccount]([intAccountId])
	)

	GO
	