/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryReceiptChargeTax]
	(
		[intInventoryReceiptChargeTaxId] INT NOT NULL IDENTITY, 
		[intInventoryReceiptChargeId] INT NOT NULL, 
		[intTaxGroupId] INT NULL,
		[intTaxCodeId] INT NULL,
		[intTaxClassId] INT NULL,	
		[strTaxableByOtherTaxes] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[strCalculationMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[dblRate] NUMERIC(18, 6) NULL DEFAULT ((0)),
		[dblTax] NUMERIC(18, 6) NULL DEFAULT ((0)),
		[dblAdjustedTax] NUMERIC(18, 6) NULL DEFAULT ((0)),		
		[intTaxAccountId] INT NULL,
		[ysnTaxAdjusted] BIT NULL DEFAULT ((0)),
		[ysnCheckoffTax] BIT NULL DEFAULT ((0)),
		[strTaxCode] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[intSort] INT NULL, 
		[intConcurrencyId] INT NULL DEFAULT ((0)), 
		CONSTRAINT [PK_tblICInventoryReceiptChargeTax] PRIMARY KEY ([intInventoryReceiptChargeTaxId]), 
		CONSTRAINT [FK_tblICInventoryReceiptChargeTax_tblICInventoryReceiptCharge] FOREIGN KEY ([intInventoryReceiptChargeId]) REFERENCES [tblICInventoryReceiptCharge]([intInventoryReceiptChargeId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICInventoryReceiptChargeTax_tblSMTaxCode] FOREIGN KEY ([intTaxCodeId]) REFERENCES [tblSMTaxCode]([intTaxCodeId]),
		CONSTRAINT [FK_tblICInventoryReceiptChargeTax_tblSMTaxClass] FOREIGN KEY ([intTaxClassId]) REFERENCES [tblSMTaxClass]([intTaxClassId]),
		CONSTRAINT [FK_tblICInventoryReceiptChargeTax_tblSMTaxGroup] FOREIGN KEY ([intTaxGroupId]) REFERENCES [tblSMTaxGroup]([intTaxGroupId]),
		CONSTRAINT [FK_tblICInventoryReceiptChargeTax_tblGLAccount] FOREIGN KEY ([intTaxAccountId]) REFERENCES [tblGLAccount]([intAccountId])
	)