﻿CREATE TYPE [dbo].[VoucherPayable] AS TABLE
(
	[intEntityVendorId]				INT,
	[dtmDate]						DATETIME,
	[strReference]					NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[strSourceNumber]				NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[strPurchaseOrderNumber]		NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[intPurchaseDetailId]			INT NULL,
	[intItemId]						INT NULL,
	[strMiscDescription]			NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo]						NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strDescription]				NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
	[intPurchaseTaxGroupId]			INT NULL,
	[dblOrderQty]					DECIMAL(18,6),
	[dblPOOpenReceive]				DECIMAL(18,6),
	[dblOpenReceive]				DECIMAL(18,6),
	[dblQuantityToBill]				DECIMAL(18,6),
	[dblQuantityBilled]				DECIMAL(18,6),
	[intLineNo]						INT,
	[intInventoryReceiptItemId]		INT NULL,
	[intInventoryReceiptChargeId]	INT NULL,
	[dblUnitCost]					DECIMAL(18,6),
	[dblTax]						DECIMAL(18,6),
	[dblRate]						DECIMAL(18,6),
	[ysnSubCurrency]				INT NULL,
	[intSubCurrencyCents]			INT NULL,
	[intAccountId]					INT NULL,
	[strAccountId]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strAccountDesc]				NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
	[strName]						NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[strVendorId]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strShipVia]					NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[strTerm]						NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[strContractNumber]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strBillOfLading]				NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[intContractHeaderId]			INT NULL,
	[intContractDetailId]			INT NULL,
	[intScaleTicketId]				INT NULL,
	[strScaleTicketNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intShipmentId]					INT NULL,
	[intShipmentContractQtyId]		INT NULL,
	[intUnitMeasureId]				INT NULL,
	[strUOM]						NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intWeightUOMId]				INT NULL,
	[intCostUOMId]					INT NULL,
	[dblNetWeight]					NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[strCostUOM]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strgrossNetUOM]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dblWeightUnitQty]				DECIMAL(18,6),
	[dblCostUnitQty]				DECIMAL(38,20),
	[dblUnitQty]					DECIMAL(18,6),
	[intCurrencyId]					INT NULL,
	[strCurrency]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intCostCurrencyId]				INT NULL,
	[strCostCurrency]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strVendorLocation]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[str1099Form]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[str1099Type]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
)