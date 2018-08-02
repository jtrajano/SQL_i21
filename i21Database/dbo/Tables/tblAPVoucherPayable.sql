CREATE TABLE [dbo].[tblAPVoucherPayable]
(
	[intVoucherPayableId]			INT NOT NULL PRIMARY KEY IDENTITY, 
    [intEntityVendorId]				INT,
	[strVendorId]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intLocationId]					INT NULL,
	[strLocationName] 				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
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
	[strContractNumber]				NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intScaleTicketId]				INT NULL,
	[strScaleTicketNumber]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intInventoryReceiptItemId]		INT NULL,
	[intInventoryReceiptChargeId]	INT NULL,
	[intLoadShipmentId]				INT NULL,
	[intLoadShipmentDetailId]		INT NULL,
	[intItemId]						INT NULL,
	[strItemNo]						NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[intPurchaseTaxGroupId]			INT NULL,
	[strMiscDescription]			NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL,
	[dblOrderQty]					DECIMAL(18,6),	
	[dblOrderUnitQty]				DECIMAL(38,20),	
	[intOrderUOMId]					INT NULL,
	[strOrderUOM]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dblQuantityToBill]				DECIMAL(18,6),
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
	[str1099Type]					NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateEntered]				DATETIME DEFAULT(GETDATE()),
    [intConcurrencyId]				INT NOT NULL DEFAULT 0
);
GO
CREATE NONCLUSTERED INDEX [IX_tblAPVoucherPayable_deleteIX]
    ON [dbo].[tblAPVoucherPayable]([intEntityVendorId, intPurchaseDetailId, intContractDetailId, intScaleTicketId, intInventoryReceiptChargeId, intInventoryReceiptItemId, intLoadShipmentDetailId] ASC);
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