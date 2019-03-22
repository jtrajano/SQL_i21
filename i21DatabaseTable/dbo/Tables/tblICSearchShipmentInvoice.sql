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
	CREATE TABLE [dbo].[tblICSearchShipmentInvoice]
	(
		[intId] INT NOT NULL IDENTITY,
		[intInventoryShipmentId] INT NOT NULL,
		[intInventoryShipmentItemId] INT NULL,
		[intInventoryShipmentChargeId] INT NULL,
		[strShipmentNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[dtmShipDate] DATETIME NULL,
		[strCustomer] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
		[strLocationName] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[strDestination] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
		[strBOLNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strOrderType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		--[strOrderNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
		[strItemDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
		[dblUnitCost] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblShipmentQty] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblInTransitQty] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblInvoiceQty] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblShipmentLineTotal] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblInTransitTotal] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblInvoiceLineTotal] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblShipmentTax] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblInvoiceTax] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblOpenQty] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblItemsReceivable] NUMERIC(38, 20) NULL DEFAULT 0,
		[dblTaxesReceivable] NUMERIC(38, 20) NULL DEFAULT 0,
		[dtmLastInvoiceDate] DATETIME NULL, 
		[strAllVouchers] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[strFilterString] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
		[dtmCreated] DATETIME NULL, 
		[intCurrencyId] INT NULL,
		[strCurrency] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 		
		[strItemUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
		[intItemUOMId] INT NULL,

		CONSTRAINT [PK_tblICSearchShipmentInvoice] PRIMARY KEY NONCLUSTERED ([intId])

	)
	GO

	CREATE CLUSTERED INDEX [IX_tblICSearchShipmentInvoice_intInventoryShipmentId]
		ON [dbo].[tblICSearchShipmentInvoice]([intInventoryShipmentId] DESC);

	GO 

	CREATE NONCLUSTERED INDEX [IX_tblICSearchShipmentInvoice_strShipmentNumber]
		ON [dbo].[tblICSearchShipmentInvoice]([strShipmentNumber] DESC);

	GO 

	CREATE NONCLUSTERED INDEX [IX_tblICSearchShipmentInvoice_strItemNo]
		ON [dbo].[tblICSearchShipmentInvoice]([strItemNo] ASC);

	GO 

	CREATE NONCLUSTERED INDEX [IX_tblICSearchShipmentInvoice_strCustomer]
		ON [dbo].[tblICSearchShipmentInvoice]([strCustomer] ASC);

	GO 

