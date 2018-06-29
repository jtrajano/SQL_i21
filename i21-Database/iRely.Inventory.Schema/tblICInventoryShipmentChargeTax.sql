/*
## Overview
Type the overview for the table here. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICInventoryShipmentChargeTax]
	(
		[intInventoryShipmentChargeTaxId] INT NOT NULL IDENTITY, 
		[intInventoryShipmentChargeId] INT NOT NULL, 
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
		[ysnTaxOnly] BIT NULL DEFAULT ((0)),
		[ysnCheckoffTax] BIT NULL DEFAULT ((0)),
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
		CONSTRAINT [PK_tblICInventoryShipmentChargeTax] PRIMARY KEY ([intInventoryShipmentChargeTaxId]), 
		CONSTRAINT [FK_tblICInventoryShipmentChargeTax_tblICInventoryShipmentCharge] FOREIGN KEY ([intInventoryShipmentChargeId]) REFERENCES [tblICInventoryShipmentCharge]([intInventoryShipmentChargeId]) ON DELETE CASCADE, 
		CONSTRAINT [FK_tblICInventoryShipmentChargeTax_tblSMTaxCode] FOREIGN KEY ([intTaxCodeId]) REFERENCES [tblSMTaxCode]([intTaxCodeId]),
		CONSTRAINT [FK_tblICInventoryShipmentChargeTax_tblSMTaxClass] FOREIGN KEY ([intTaxClassId]) REFERENCES [tblSMTaxClass]([intTaxClassId]),
		CONSTRAINT [FK_tblICInventoryShipmentChargeTax_tblSMTaxGroup] FOREIGN KEY ([intTaxGroupId]) REFERENCES [tblSMTaxGroup]([intTaxGroupId]),
		CONSTRAINT [FK_tblICInventoryShipmentChargeTax_tblGLAccount] FOREIGN KEY ([intTaxAccountId]) REFERENCES [tblGLAccount]([intAccountId])
	)