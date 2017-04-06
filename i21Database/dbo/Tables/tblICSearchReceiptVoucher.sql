/*
## Overview
This is a temporary table used by vyuICGetInventoryReceiptVoucher. Data is populated on this table using a button from the Receipt Search. 
Data here is used in the Voucher tab/grid. 

## Fields, description, and mapping. 
*	Type the field name here
	Type the description of the field here
	Maps: Type the mapping to origin. Type None if not applicable.


## Source Code:
*/
	CREATE TABLE [dbo].[tblICSearchReceiptVoucher]
	(
		[intId] INT NOT NULL IDENTITY,
		[intInventoryReceiptId] INT NOT NULL, 
		[intInventoryReceiptItemId] INT NULL,
		[dtmReceiptDate] DATETIME NULL, 
		[strVendor] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[strLocationName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[strReceiptNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strBillOfLading] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[strReceiptType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strOrderNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strItemDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
		[dblUnitCost] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblReceiptQty] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblVoucherQty] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblReceiptLineTotal] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblVoucherLineTotal] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblReceiptTax] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblVoucherTax] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblOpenQty] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblItemsPayable] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblTaxesPayable] NUMERIC(38, 20) NULL DEFAULT 0,
		[dtmLastVoucherDate] DATETIME NULL, 
		[strAllVouchers] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[strFilterString] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[dtmCreated] DATETIME NULL, 
		[intCurrencyId] INT NULL,
		[strCurrency] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 		
		[strContainerNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
		[intLoadContainerId] INT NULL,
		[strItemUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[intItemUOMId] INT NULL,
		[strCostUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[intCostUOMId] INT NULL,		
		CONSTRAINT [PK_tblICSearchReceiptVoucher] PRIMARY KEY NONCLUSTERED ([intId])
	)
	GO

	CREATE CLUSTERED INDEX [IX_tblICSearchReceiptVoucher_intInventoryReceiptId]
		ON [dbo].[tblICSearchReceiptVoucher]([intInventoryReceiptId] DESC);

	GO 

	CREATE NONCLUSTERED INDEX [IX_tblICSearchReceiptVoucher_strReceiptNumber]
		ON [dbo].[tblICSearchReceiptVoucher]([strReceiptNumber] DESC);

	GO 

	CREATE NONCLUSTERED INDEX [IX_tblICSearchReceiptVoucher_strItemNo]
		ON [dbo].[tblICSearchReceiptVoucher]([strItemNo] ASC);

	GO 

	CREATE NONCLUSTERED INDEX [IX_tblICSearchReceiptVoucher_strVendor]
		ON [dbo].[tblICSearchReceiptVoucher]([strVendor] ASC);

	GO 

