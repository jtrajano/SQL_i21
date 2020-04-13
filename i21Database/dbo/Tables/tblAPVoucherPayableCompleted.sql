﻿CREATE TABLE [dbo].[tblAPVoucherPayableCompleted]
(
	[intVoucherPayableId]			INT NOT NULL PRIMARY KEY IDENTITY, 
	[intTransactionType]			INT NOT NULL DEFAULT(0),
    [intEntityVendorId]				INT,
	[strVendorId]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strName]						NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intLocationId]					INT NULL,
	[strLocationName] 				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyId]					INT NULL,
	[strCurrency]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate]						DATETIME,
	[strReference]					NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[strSourceNumber]				NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[intPurchaseDetailId]			INT NULL,
	[strPurchaseOrderNumber]		NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[intContractHeaderId]			INT NULL,
	[intContractDetailId]			INT NULL,
	[intContractSeqId]				INT NULL,
	[intContractCostId]				INT NULL,
	[strContractNumber]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intScaleTicketId]				INT NULL,
	[intTicketId]				INT NULL,
	[strScaleTicketNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intInventoryReceiptItemId]		INT NULL,
	[intInventoryReceiptChargeId]	INT NULL,
	[intInventoryShipmentItemId]	INT NULL,
	[intInventoryShipmentChargeId]	INT NULL,
	[intLoadShipmentId]				INT NULL,
	[intLoadShipmentDetailId]		INT NULL,
	[intLoadShipmentCostId]			INT NULL,
	[intCustomerStorageId]			INT NULL,
	[intSettleStorageId] 			INT NULL,
	[intItemId]						INT NULL,
	[strItemNo]						NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intPurchaseTaxGroupId]			INT NULL,
	[strTaxGroup]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intItemLocationId]				INT NULL,
	[strItemLocationName]			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intStorageLocationId]			INT NULL,
	[strStorageLocationName]		NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intSubLocationId]				INT NULL,
	[strSubLocationName]			NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strMiscDescription]			NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
	[dblOrderQty]					DECIMAL(38,15),	
	[dblOrderUnitQty]				DECIMAL(38,20),	
	[intOrderUOMId]					INT NULL,
	[strOrderUOM]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dblQuantityToBill]				DECIMAL(38,15),
	[dblQtyToBillUnitQty]			DECIMAL(38,20),	
	[intQtyToBillUOMId]				INT NULL,
	[strQtyToBillUOM]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dblCost]						DECIMAL(38,20),
	[dblCostUnitQty]				DECIMAL(38,20),
	[intCostUOMId]					INT NULL,
	[strCostUOM]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dblNetWeight]					DECIMAL(18,6),
	[dblWeightUnitQty]				DECIMAL(38,20),
	[intWeightUOMId]				INT NULL,
	[strWeightUOM]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intCostCurrencyId]				INT NULL,
	[strCostCurrency]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dblTax]						DECIMAL(18,2),
	[dblDiscount]					DECIMAL(18,2),
	[intCurrencyExchangeRateTypeId]	INT NULL,
	[strRateType]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dblExchangeRate]				DECIMAL(38,20) DEFAULT(1),
	[ysnSubCurrency]				INT NULL,
	[intSubCurrencyCents]			INT NULL,
	[intAccountId]					INT NULL,
	[strAccountId]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strAccountDesc]				NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
	[intShipViaId]					INT NULL,
	[strShipVia]					NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[intTermId]						INT NULL,
	[strTerm]						NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[strBillOfLading]				NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[int1099Form]					INT NULL,
	[str1099Form]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[int1099Category]				INT NULL,
	[dbl1099]						DECIMAL(18,6) DEFAULT(0) NULL,
	[str1099Type]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateEntered]				DATETIME DEFAULT(GETDATE()),
	[ysnReturn]						BIT NULL,
    [intConcurrencyId]				INT NOT NULL DEFAULT 0
);
GO
CREATE NONCLUSTERED INDEX [IX_tblAPVoucherPayableCompleted_deleteIX]
    ON [dbo].[tblAPVoucherPayableCompleted](intEntityVendorId
								,intPurchaseDetailId
								,intContractDetailId
								,intScaleTicketId
								,intInventoryReceiptChargeId
								,intInventoryReceiptItemId
								,intInventoryShipmentItemId
								,intInventoryShipmentChargeId
								,intCustomerStorageId
								,intSettleStorageId
								,intLoadShipmentDetailId 
								,intLoadShipmentCostId
								,intItemId DESC);
GO