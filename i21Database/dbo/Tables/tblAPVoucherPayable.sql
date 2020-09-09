CREATE TABLE [dbo].[tblAPVoucherPayable]
(
	[intVoucherPayableId]			INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
	[intTransactionType]			INT NOT NULL  DEFAULT(0),
    [intEntityVendorId]				INT,
	[strVendorId]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[strName]						NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intLocationId]					INT NULL,
	[strLocationName] 				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intShipToId]					INT NULL,
	[intShipFromId]					INT NULL,
	[intShipFromEntityId]			INT NULL,
	[intPayToAddressId]				INT NULL,
	[intCurrencyId]					INT NULL,
	[strCurrency]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dtmDate]						DATETIME,
	[dtmVoucherDate]				DATETIME,
	[strReference]					NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[strSourceNumber]				NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[strVendorOrderNumber]			NVARCHAR(MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strCheckComment]				NVARCHAR (200)  COLLATE Latin1_General_CI_AS NULL,
	[intPurchaseDetailId]			INT NULL,
	[strPurchaseOrderNumber]		NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL,
	[intContractHeaderId]			INT NULL,
	[intContractDetailId]			INT NULL,
	[intContractSeqId]				INT NULL,
	[intContractCostId]				INT NULL,
	[strContractNumber]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intScaleTicketId]				INT NULL,
	[strScaleTicketNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intInventoryReceiptItemId]		INT NULL,
	[intInventoryReceiptChargeId]	INT NULL,
	[intInventoryShipmentItemId]	INT NULL,
	[intInventoryShipmentChargeId]	INT NULL,
	[strLoadShipmentNumber]			NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intLoadShipmentId]				INT NULL,
	[intLoadShipmentDetailId]		INT NULL,
	[intLoadShipmentCostId]			INT NULL,
	[intCustomerStorageId]			INT NULL,
	[intTicketId]					INT NULL,
	[intPaycheckHeaderId]			INT NULL,
	[intCCSiteDetailId]				INT NULL,
	[intInvoiceId]					INT NULL,
	[intBuybackChargeId]			INT NULL,
	[intItemId]						INT NULL,
	[strItemNo]						NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intFreightTermId]				INT NULL,
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
	[dblQuantityBilled]				DECIMAL(18,6) NOT NULL DEFAULT(0),
	[dblOldCost]					DECIMAL(38,20) NULL,
	[dblCost]						DECIMAL(38,20) NOT NULL DEFAULT(0),
	[dblCostUnitQty]				DECIMAL(38,20) NOT NULL DEFAULT(0),
	[intCostUOMId]					INT NULL,
	[strCostUOM]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dblWeight]						DECIMAL(18,6),
	[dblNetWeight]					DECIMAL(18,6),
	[dblWeightUnitQty]				DECIMAL(38,20),
	[intWeightUOMId]				INT NULL,
	[strWeightUOM]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intCostCurrencyId]				INT NULL,
	[strCostCurrency]				NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dblTax]						DECIMAL(18,2) NOT NULL DEFAULT(0),
	[dblDiscount]					DECIMAL(18,2) NOT NULL DEFAULT(0),
	[dblBasis]						DECIMAL(18, 6) NOT NULL DEFAULT(0),
	[dblFutures]					DECIMAL(18, 6) NOT NULL DEFAULT(0),
	[dblDetailDiscountPercent]		DECIMAL(18,2) NOT NULL DEFAULT(0),
	[ysnDiscountOverride]			BIT DEFAULT(0),
	[intDeferredVoucherId]			INT NULL,
	[dtmDeferredInterestDate]		DATETIME NULL,
	[dtmInterestAccruedThru]		DATETIME NULL,
	[dblPrepayPercentage]			DECIMAL(18,6) NOT NULL DEFAULT(0),
	[intPrepayTypeId]				INT NULL,
	[dblNetShippedWeight]			DECIMAL(18,6) NOT NULL DEFAULT(0),
	[dblWeightLoss]					DECIMAL(18,6) NOT NULL DEFAULT(0),
	[dblFranchiseWeight]			DECIMAL(18,6) NOT NULL DEFAULT(0),
	[dblFranchiseAmount]			DECIMAL(18,6) NOT NULL DEFAULT(0),
	[dblActual]						DECIMAL(18,6) NOT NULL DEFAULT(0),
	[dblDifference]					DECIMAL(18,6) NOT NULL DEFAULT(0),
	[intCurrencyExchangeRateTypeId]	INT NULL,
	[strRateType]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dblExchangeRate]				DECIMAL(38,20) DEFAULT(1),
	[ysnSubCurrency]				INT NULL,
	[intSubCurrencyCents]			INT NULL,
	[intAPAccount]					INT NULL,
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
	[dbl1099]						DECIMAL(18,6) DEFAULT(0),
	[str1099Type]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateEntered]				DATETIME DEFAULT(GETDATE()),
	[ysnReturn]						BIT NULL,
	[intLineNo]						INT NULL,
    [intConcurrencyId]				INT NOT NULL DEFAULT 0
);
GO
CREATE NONCLUSTERED INDEX [IX_tblAPVoucherPayable_deleteIX]
    ON [dbo].[tblAPVoucherPayable](intEntityVendorId
								,intPurchaseDetailId
								,intContractDetailId
								,intScaleTicketId
								,intInventoryReceiptChargeId
								,intInventoryReceiptItemId
								--,intInventoryShipmentItemId
								,intInventoryShipmentChargeId
								,intCustomerStorageId
								,intLoadShipmentCostId
								,intLoadShipmentDetailId
								,intItemId DESC);
-- GO
-- CREATE NONCLUSTERED INDEX [IX_tblAPVoucherPayable_intPurchaseDetailId]
--     ON [dbo].[tblAPVoucherPayable]([intPurchaseDetailId] ASC);
-- GO
-- CREATE NONCLUSTERED INDEX [IX_tblAPVoucherPayable_intContractDetailId]
--     ON [dbo].[tblAPVoucherPayable]([intContractDetailId] ASC);
-- GO
-- CREATE NONCLUSTERED INDEX [IX_tblAPVoucherPayable_intScaleTicketId]
--     ON [dbo].[tblAPVoucherPayable]([intScaleTicketId] ASC);
-- GO
-- CREATE NONCLUSTERED INDEX [IX_tblAPVoucherPayable_intInventoryReceiptChargeId]
--     ON [dbo].[tblAPVoucherPayable]([intInventoryReceiptChargeId] ASC);
-- GO
-- CREATE NONCLUSTERED INDEX [IX_tblAPVoucherPayable_intLoadShipmentDetailId]
--     ON [dbo].[tblAPVoucherPayable]([intLoadShipmentDetailId] ASC);
GO