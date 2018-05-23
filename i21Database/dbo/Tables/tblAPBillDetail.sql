CREATE TABLE [dbo].[tblAPBillDetail] (
    [intBillDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intBillId]       INT             NOT NULL,
    [strMiscDescription]  NVARCHAR (500)  COLLATE Latin1_General_CI_AS NULL,
	[strBundlecDescription]  NVARCHAR (500)  COLLATE Latin1_General_CI_AS NULL,
	[strComment] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intAccountId]    INT             NULL ,
	[intUnitOfMeasureId]    INT             NULL ,
	[intCostUOMId]    INT             NULL ,
	[intWeightUOMId]    INT             NULL ,
	[intBundletUOMId]    INT             NULL ,
	[intItemId]    INT             NULL,
	[intInventoryReceiptItemId]    INT             NULL,
	[intDeferredVoucherId]			INT				NULL,
	[intInventoryReceiptChargeId]    INT             NULL,
	[intContractCostId]		 INT			NULL,
	[intPaycheckHeaderId]    INT             NULL,
	[intPurchaseDetailId]    INT             NULL,
	[intContractHeaderId]    INT             NULL,
	[intContractDetailId]    INT             NULL,
	[intCustomerStorageId]    INT             NULL,
	[intStorageLocationId] INT             NULL,
	[intLocationId] INT             NULL,
	[intLoadDetailId]    INT             NULL,
	[intLoadId]    INT             NULL,
	[intScaleTicketId]    INT             NULL,
	[intCCSiteDetailId]    INT             NULL,
	[intPrepayTypeId]    INT             NULL,
	[intItemBundleId]	INT 	NULL,
    [dblTotal]        DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [dblQtyContract] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblContractCost] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblQtyOrdered] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblQtyReceived] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblQtyBundleReceived] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblDiscount] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblCost] DECIMAL(38, 20) NOT NULL DEFAULT 0, 
	[dblOldCost] DECIMAL(38, 20) NULL, 
    [dblLandedCost] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblRate] DECIMAL(18, 6) NOT NULL DEFAULT 1,  
	[dblTax] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblActual] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblBasis] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblFutures] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblDifference] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblPrepayPercentage] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblWeightUnitQty] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblCostUnitQty] DECIMAL(38, 20) NOT NULL DEFAULT 0,
	[dblUnitQty] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblBundleUnitQty] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblNetWeight] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblWeight] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblVolume] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblNetShippedWeight] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblWeightLoss] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblFranchiseWeight] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblClaimAmount] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dbl1099] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dtmExpectedDate] DATETIME NULL, 
    [int1099Form] INT NOT NULL DEFAULT 0 , 
    [int1099Category] INT NOT NULL DEFAULT 0 , 
	[ysn1099Printed] BIT NULL DEFAULT 0 ,
	[ysnRestricted] BIT NOT NULL DEFAULT 0 ,
	[ysnSubCurrency] BIT NOT NULL DEFAULT 0 ,
    [intLineNo] INT NOT NULL DEFAULT 1,
    [intTaxGroupId] INT NULL, 
	[intInventoryShipmentChargeId] INT NULL,
	[intCurrencyExchangeRateTypeId] INT NULL,
	[intCurrencyId] INT NULL,
	[strBillOfLading] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intContractSeq] INT NULL,
	[intInvoiceId] INT NULL , 
    [intBuybackChargeId] INT NULL, 
    CONSTRAINT [PK__tblAPBil__DCE2CCF4681FF753] PRIMARY KEY CLUSTERED ([intBillDetailId] ASC) ON [PRIMARY],
    CONSTRAINT [FK_tblAPBillDetail_tblAPBill] FOREIGN KEY ([intBillId]) REFERENCES [dbo].[tblAPBill] ([intBillId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblAPBillDetail_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblAPBillDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblAPBillDetail_tblICInventoryReceiptCharge] FOREIGN KEY ([intInventoryReceiptChargeId]) REFERENCES [tblICInventoryReceiptCharge]([intInventoryReceiptChargeId]),
	CONSTRAINT [FK_tblAPBillDetail_tblAPBillDeferred] FOREIGN KEY ([intDeferredVoucherId]) REFERENCES [tblAPBill]([intBillId]),
	--TEMPORARILY REMOVED, WE'LL VERIFY THIS TO AJITH AS THIS MIGHT BECOME MANUAL DATA FIX FIRST BEFORE ENABLING AGAIN
	--CONSTRAINT [FK_tblAPBillDetail_tblICInventoryReceiptItem_intInventoryReceiptItemId] FOREIGN KEY ([intInventoryReceiptItemId]) REFERENCES [dbo].[tblICInventoryReceiptItem] ([intInventoryReceiptItemId]),
	CONSTRAINT [FK_tblAPBillDetail_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId]),
	CONSTRAINT [FK_tblAPBillDetail_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId]),
	CONSTRAINT [FK_tblAPBillDetail_tblLGLoadDetail_intLoadDetailId] FOREIGN KEY ([intLoadDetailId]) REFERENCES [dbo].[tblLGLoadDetail] ([intLoadDetailId]),
	CONSTRAINT [FK_tblAPBillDetail_tblCCSiteDetail_intCCSiteDetailId] FOREIGN KEY ([intCCSiteDetailId]) REFERENCES [dbo].[tblCCSiteDetail] ([intSiteDetailId]),
	CONSTRAINT [FK_tblAPBillDetail_tblCTContractCost] FOREIGN KEY ([intContractCostId]) REFERENCES [tblCTContractCost]([intContractCostId]),
	CONSTRAINT [FK_tblAPBillDetail_tblICInventoryShipmentCharge] FOREIGN KEY ([intInventoryShipmentChargeId]) REFERENCES [tblICInventoryShipmentCharge]([intInventoryShipmentChargeId]),

	CONSTRAINT [FK_tblAPBillDetail_intUnitOfMeasureId] FOREIGN KEY ([intUnitOfMeasureId]) REFERENCES tblICItemUOM([intItemUOMId]),
	CONSTRAINT [FK_tblAPBillDetail_intCostUOMId] FOREIGN KEY ([intCostUOMId]) REFERENCES tblICItemUOM([intItemUOMId]),
	CONSTRAINT [FK_tblAPBillDetail_intWeightUOMId] FOREIGN KEY ([intWeightUOMId]) REFERENCES tblICItemUOM([intItemUOMId]),
	CONSTRAINT [FK_tblAPBillDetail_intInventoryReceiptItemId] FOREIGN KEY ([intInventoryReceiptItemId]) REFERENCES tblICInventoryReceiptItem([intInventoryReceiptItemId]),
	CONSTRAINT [FK_tblAPBillDetail_intPaycheckHeaderId] FOREIGN KEY ([intPaycheckHeaderId]) REFERENCES tblPRPaycheck([intPaycheckId]),
	CONSTRAINT [FK_tblAPBillDetail_intPurchaseDetailId] FOREIGN KEY ([intPurchaseDetailId]) REFERENCES tblPOPurchaseDetail([intPurchaseDetailId]),
	CONSTRAINT [FK_tblAPBillDetail_intLoadDetailId] FOREIGN KEY ([intLoadDetailId]) REFERENCES tblLGLoadDetail([intLoadDetailId]),
	CONSTRAINT [FK_tblAPBillDetail_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES tblLGLoad([intLoadId]),
	CONSTRAINT [FK_tblAPBillDetail_intInvoiceId] FOREIGN KEY ([intInvoiceId]) REFERENCES tblARInvoice([intInvoiceId]),
) ON [PRIMARY];


GO

CREATE NONCLUSTERED INDEX [IX_tblAPBillDetail_intInventoryShipmentChargeId]
		ON [dbo].[tblAPBillDetail]([intInventoryShipmentChargeId] ASC)
		INCLUDE (intBillDetailId, intBillId, intUnitOfMeasureId, intCostUOMId, intWeightUOMId, intItemId, dblQtyReceived)
GO

CREATE NONCLUSTERED INDEX [IX_tblAPBillDetail_intInventoryReceiptItemId]
		ON [dbo].[tblAPBillDetail]([intInventoryReceiptItemId] ASC)
		INCLUDE (intBillDetailId, intBillId, intUnitOfMeasureId, intCostUOMId, intWeightUOMId, intItemId, dblQtyReceived)
GO

CREATE NONCLUSTERED INDEX [IX_tblAPBillDetail_intInventoryReceiptChargeId]
		ON [dbo].[tblAPBillDetail]([intInventoryReceiptChargeId] ASC)
		INCLUDE (intBillDetailId, intBillId, intUnitOfMeasureId, intCostUOMId, intWeightUOMId, intItemId, dblQtyReceived)
GO

CREATE NONCLUSTERED INDEX [IX_rptAging_1] ON [dbo].[tblAPBillDetail]
(
	[intBillId] ASC,
	[intBillDetailId] ASC
)
INCLUDE ( 	[dblTotal],
	[dblRate]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_rptAging_2] ON [dbo].[tblAPBillDetail]
(
	[intBillDetailId] ASC,
	[intBillId] ASC
)
INCLUDE ( 	[dblTotal],
	[dblRate]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
