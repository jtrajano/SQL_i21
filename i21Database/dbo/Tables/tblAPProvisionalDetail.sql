CREATE TABLE [dbo].[tblAPProvisionalDetail] (
    [intBillDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intBillId]       INT             NOT NULL,
    [strMiscDescription]  NVARCHAR (500)  COLLATE Latin1_General_CI_AS NULL,
	[strBundleDescription]  NVARCHAR (500)  COLLATE Latin1_General_CI_AS NULL,
	[strComment] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intAccountId]    INT             NULL ,
	[intUnitOfMeasureId]    INT             NULL ,
	[intCostUOMId]    INT             NULL ,
	[intWeightUOMId]    INT             NULL ,
	[intBundletUOMId]    INT             NULL ,
	[intInvoiceDetailRefId]    INT             NULL ,
	[intItemId]    INT             NULL,
	[intInventoryReceiptItemId]    INT             NULL,
	[intDeferredVoucherId]			INT				NULL,
	[intInventoryReceiptChargeId]    INT             NULL,
	[intContractCostId]		 INT			NULL,
	[intPaycheckHeaderId]    INT             NULL,
	[intPurchaseDetailId]    INT             NULL,
	[intContractHeaderId]    INT             NULL,
	[intContractDetailId]    INT             NULL,
	[intPriceFixationDetailId] INT 			NULL,
	[intCustomerStorageId]    INT             NULL,
	[intSettleStorageId] INT NULL,
	[intStorageLocationId] INT             NULL,
	[intStorageChargeId] INT             NULL,
	[intSubLocationId] INT             NULL,
	[intLocationId] INT             NULL,
	[intLoadDetailId]    INT             NULL,
	[intLoadShipmentCostId]    INT             NULL,
	[intLoadId]    INT             NULL,
	[intWeightClaimId]    INT             NULL,
	[intWeightClaimDetailId]    INT             NULL,
	[intScaleTicketId]    INT             NULL,
	[intTicketId]    INT             NULL,
	[intCCSiteDetailId]    INT             NULL,
	[intPrepayTypeId]    INT             NULL,
	[intPrepayTransactionId]    INT             NULL,
	[intReallocationId]    INT             NULL,
	[intItemBundleId]	INT 	NULL,
	[intLinkingId]	INT NULL,
	[intComputeTotalOption] TINYINT NOT NULL DEFAULT(0),
    [dblTotal]        DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[dblBundleTotal]        DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [dblQtyContract] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblContractCost] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblQtyOrdered] DECIMAL(38, 15) NOT NULL DEFAULT 0, 
    [dblQtyReceived] DECIMAL(38, 15) NOT NULL DEFAULT 0, 
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
	[dblWeightUnitQty] DECIMAL(38, 20) NOT NULL DEFAULT 0, 
	[dblCostUnitQty] DECIMAL(38, 20) NOT NULL DEFAULT 0,
	[dblUnitQty] DECIMAL(38, 20) NOT NULL DEFAULT 0, 
	[dblBundleUnitQty] DECIMAL(18, 6) NOT NULL DEFAULT 0,
	[dblNetWeight] DECIMAL(38, 20) NOT NULL DEFAULT 0, 
    [dblWeight] DECIMAL(38, 20) NOT NULL DEFAULT 0, 
    [dblVolume] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblNetShippedWeight] DECIMAL(38, 20) NOT NULL DEFAULT 0, 
	[dblWeightLoss] DECIMAL(38, 20) NOT NULL DEFAULT 0, 
	[dblFranchiseWeight] DECIMAL(38, 20) NOT NULL DEFAULT 0,
	[dblFranchiseAmount] DECIMAL(38, 20) NOT NULL DEFAULT 0,  
	[dblClaimAmount] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dbl1099] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dtmExpectedDate] DATETIME NULL, 
    [int1099Form] INT NOT NULL DEFAULT 0 , 
    [int1099Category] INT NOT NULL DEFAULT 0 , 
	[ysn1099Printed] BIT NULL DEFAULT 0 ,
	[ysnRestricted] BIT NOT NULL DEFAULT 0 ,
	[ysnSubCurrency] BIT NOT NULL DEFAULT 0 ,
	[ysnStage] BIT NOT NULL DEFAULT 0 ,
    [intLineNo] INT NOT NULL DEFAULT 1,
    [intTaxGroupId] INT NULL, 
	[intFreightTermId] INT NULL, 
	[intInventoryShipmentChargeId] INT NULL,
	[intCurrencyExchangeRateTypeId] INT NULL,
	[intCurrencyId] INT NULL,
	[strBillOfLading] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[intContractSeq] INT NULL,
	[intInvoiceId] INT NULL , 
	[intLotId]	INT 	NULL,
    [intBuybackChargeId] INT NULL, 
	[intTicketDistributionAllocationId] INT NULL,
	[dblCashPrice] DECIMAL(18, 6) NOT NULL DEFAULT 0,
	[dblQualityPremium] DECIMAL(18, 6) NOT NULL DEFAULT 0,
 	[dblOptionalityPremium] DECIMAL(18, 6) NOT NULL DEFAULT 0,
	[dblRounding] DECIMAL (18, 6) NOT NULL DEFAULT 0,
	[ysnOverrideForexRate] BIT NOT NULL DEFAULT 0,
	[strReasonablenessComment] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    CONSTRAINT [PK__tblAPProvisional__DCE2CCF4681FF753] PRIMARY KEY CLUSTERED ([intBillDetailId] ASC) ON [PRIMARY],
    CONSTRAINT [FK_tblAPProvisionalDetail_tblAPBill] FOREIGN KEY ([intBillId]) REFERENCES [dbo].[tblAPProvisional] ([intBillId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblAPProvisionalDetail_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_tblICInventoryReceiptCharge] FOREIGN KEY ([intInventoryReceiptChargeId]) REFERENCES [tblICInventoryReceiptCharge]([intInventoryReceiptChargeId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_tblAPBillDeferred] FOREIGN KEY ([intDeferredVoucherId]) REFERENCES [tblAPProvisional]([intBillId]),
	--TEMPORARILY REMOVED, WE'LL VERIFY THIS TO AJITH AS THIS MIGHT BECOME MANUAL DATA FIX FIRST BEFORE ENABLING AGAIN
	--CONSTRAINT [FK_tblAPBillDetail_tblICInventoryReceiptItem_intInventoryReceiptItemId] FOREIGN KEY ([intInventoryReceiptItemId]) REFERENCES [dbo].[tblICInventoryReceiptItem] ([intInventoryReceiptItemId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_tblLGLoadDetail_intLoadDetailId] FOREIGN KEY ([intLoadDetailId]) REFERENCES [dbo].[tblLGLoadDetail] ([intLoadDetailId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_tblCCSiteDetail_intCCSiteDetailId] FOREIGN KEY ([intCCSiteDetailId]) REFERENCES [dbo].[tblCCSiteDetail] ([intSiteDetailId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_tblCTContractCost] FOREIGN KEY ([intContractCostId]) REFERENCES [tblCTContractCost]([intContractCostId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_tblICInventoryShipmentCharge] FOREIGN KEY ([intInventoryShipmentChargeId]) REFERENCES [tblICInventoryShipmentCharge]([intInventoryShipmentChargeId]),

	CONSTRAINT [FK_tblAPProvisionalDetail_intUnitOfMeasureId] FOREIGN KEY ([intUnitOfMeasureId]) REFERENCES tblICItemUOM([intItemUOMId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_intCostUOMId] FOREIGN KEY ([intCostUOMId]) REFERENCES tblICItemUOM([intItemUOMId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_intWeightUOMId] FOREIGN KEY ([intWeightUOMId]) REFERENCES tblICItemUOM([intItemUOMId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_intInventoryReceiptItemId] FOREIGN KEY ([intInventoryReceiptItemId]) REFERENCES tblICInventoryReceiptItem([intInventoryReceiptItemId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_intPaycheckHeaderId] FOREIGN KEY ([intPaycheckHeaderId]) REFERENCES tblPRPaycheck([intPaycheckId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_intPurchaseDetailId] FOREIGN KEY ([intPurchaseDetailId]) REFERENCES tblPOPurchaseDetail([intPurchaseDetailId]),
	--CONSTRAINT [FK_tblAPBillDetail_intLoadDetailId] FOREIGN KEY ([intLoadDetailId]) REFERENCES tblLGLoadDetail([intLoadDetailId]), /* this is a duplicate FK */
	CONSTRAINT [FK_tblAPProvisionalDetail_intLoadId] FOREIGN KEY ([intLoadId]) REFERENCES tblLGLoad([intLoadId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_intWeightClaimDetailId] FOREIGN KEY ([intWeightClaimDetailId]) REFERENCES tblLGWeightClaimDetail([intWeightClaimDetailId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_intInvoiceId] FOREIGN KEY ([intInvoiceId]) REFERENCES tblARInvoice([intInvoiceId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_tblHDTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES tblHDTicket([intTicketId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_tblAPBillReallocation] FOREIGN KEY ([intReallocationId]) REFERENCES tblAPBillReallocation([intReallocationId]),
	CONSTRAINT [FK_tblAPProvisionalDetail_tblSCTicketDistributionAllocation] FOREIGN KEY ([intTicketDistributionAllocationId]) REFERENCES tblSCTicketDistributionAllocation([intTicketDistributionAllocationId]),
) ON [PRIMARY];


GO

CREATE NONCLUSTERED INDEX [IX_tblAPProvisionalDetail_intInventoryShipmentChargeId]
		ON [dbo].[tblAPProvisionalDetail]([intInventoryShipmentChargeId] ASC)
		INCLUDE (intBillDetailId, intBillId, intUnitOfMeasureId, intCostUOMId, intWeightUOMId, intItemId, dblQtyReceived)
GO

CREATE NONCLUSTERED INDEX [IX_tblAPProvisionalDetail_intInventoryReceiptItemId]
		ON [dbo].[tblAPProvisionalDetail]([intInventoryReceiptItemId] ASC)
		INCLUDE (intBillDetailId, intBillId, intUnitOfMeasureId, intCostUOMId, intWeightUOMId, intItemId, dblQtyReceived, intInventoryReceiptChargeId)
GO

CREATE NONCLUSTERED INDEX [IX_tblAPProvisionalDetail_intInventoryReceiptChargeId]
		ON [dbo].[tblAPProvisionalDetail]([intInventoryReceiptChargeId] ASC)
		INCLUDE (intBillDetailId, intBillId, intUnitOfMeasureId, intCostUOMId, intWeightUOMId, intItemId, dblQtyReceived, intInventoryReceiptItemId)
GO

CREATE NONCLUSTERED INDEX [IX_tblAPProvisionalDetail_intLoadDetailId]
		ON [dbo].[tblAPProvisionalDetail]([intLoadDetailId] ASC)
		INCLUDE (intBillDetailId, intBillId, intUnitOfMeasureId, intCostUOMId, intWeightUOMId, intItemId, dblQtyReceived)
GO

CREATE NONCLUSTERED INDEX [IX_tblAPProvisionalDetail_intCustomerStorageId]
		ON [dbo].[tblAPProvisionalDetail]([intCustomerStorageId] ASC)
		INCLUDE (intBillDetailId, intBillId, intUnitOfMeasureId, intCostUOMId, intWeightUOMId, intItemId, dblQtyReceived)
GO

CREATE NONCLUSTERED INDEX [IX_tblAPProvisionalDetail_intSettleStorageId]
		ON [dbo].[tblAPProvisionalDetail]([intSettleStorageId] ASC)
		INCLUDE (intBillDetailId, intBillId, intUnitOfMeasureId, intCostUOMId, intWeightUOMId, intItemId, dblQtyReceived)
GO
CREATE NONCLUSTERED INDEX [IX_tblAPProvisionalDetail_intContractDetailId]
		ON [dbo].[tblAPProvisionalDetail]([intContractDetailId] ASC)
		INCLUDE (intBillDetailId, intBillId, intUnitOfMeasureId, intCostUOMId, intWeightUOMId, intItemId, dblQtyReceived)
GO
