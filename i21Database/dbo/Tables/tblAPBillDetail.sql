CREATE TABLE [dbo].[tblAPBillDetail] (
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
	[intSubLocationId] INT             NULL,
	[intLocationId] INT             NULL,
	[intLoadDetailId]    INT             NULL,
	[intLoadShipmentCostId]    INT             NULL,
	[intLoadId]    INT             NULL,
	[intScaleTicketId]    INT             NULL,
	[intTicketId]    INT             NULL,
	[intCCSiteDetailId]    INT             NULL,
	[intPrepayTypeId]    INT             NULL,
	[intPrepayTransactionId]    INT             NULL,
	[intReallocationId]    INT             NULL,
	[intItemBundleId]	INT 	NULL,
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
	CONSTRAINT [FK_tblAPBillDetail_tblHDTicket_intTicketId] FOREIGN KEY ([intTicketId]) REFERENCES tblHDTicket([intTicketId]),
	CONSTRAINT [FK_tblAPBillDetail_tblAPBillReallocation] FOREIGN KEY ([intReallocationId]) REFERENCES tblAPBillReallocation([intReallocationId]),
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

CREATE NONCLUSTERED INDEX [IX_tblAPBillDetail_intLoadDetailId]
		ON [dbo].[tblAPBillDetail]([intLoadDetailId] ASC)
		INCLUDE (intBillDetailId, intBillId, intUnitOfMeasureId, intCostUOMId, intWeightUOMId, intItemId, dblQtyReceived)
GO

CREATE NONCLUSTERED INDEX [IX_tblAPBillDetail_intCustomerStorageId]
		ON [dbo].[tblAPBillDetail]([intCustomerStorageId] ASC)
		INCLUDE (intBillDetailId, intBillId, intUnitOfMeasureId, intCostUOMId, intWeightUOMId, intItemId, dblQtyReceived)
GO

CREATE NONCLUSTERED INDEX [IX_tblAPBillDetail_intSettleStorageId]
		ON [dbo].[tblAPBillDetail]([intSettleStorageId] ASC)
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
CREATE NONCLUSTERED INDEX [IX_tblAPBillDetail_voucherPayable]
    ON [dbo].[tblAPBillDetail](intPurchaseDetailId
								,intContractDetailId
								,intScaleTicketId
								,intInventoryReceiptChargeId
								,intInventoryReceiptItemId
								,intInventoryShipmentChargeId
								,intLoadDetailId DESC);
GO
CREATE TRIGGER trgLogVoucherDetailRisk
ON dbo.tblAPBillDetail
AFTER INSERT, UPDATE, DELETE
AS 
BEGIN
    SET NOCOUNT ON;

    --
    -- Check if this is an INSERT, UPDATE or DELETE Action.
    -- 
    DECLARE @action as char(1);

    SET @action = 'I'; -- Set Action to Insert by default.
    IF EXISTS(SELECT * FROM DELETED)
    BEGIN
        SET @action = 
            CASE
                WHEN EXISTS(SELECT * FROM INSERTED) THEN 'U' -- Set Action to Updated.
                ELSE 'D' -- Set Action to Deleted.       
            END
    END
    ELSE 
        IF NOT EXISTS(SELECT * FROM INSERTED) RETURN; -- Nothing updated or inserted.
		ELSE
			RETURN;
END

GO