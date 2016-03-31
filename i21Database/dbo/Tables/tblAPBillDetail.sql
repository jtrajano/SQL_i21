﻿CREATE TABLE [dbo].[tblAPBillDetail] (
    [intBillDetailId] INT             IDENTITY (1, 1) NOT NULL,
    [intBillId]       INT             NOT NULL,
    [strMiscDescription]  NVARCHAR (500)  COLLATE Latin1_General_CI_AS NULL,
	[strComment] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, 
    [intAccountId]    INT             NULL ,
	[intUnitOfMeasureId]    INT             NULL ,
	[intCostUOMId]    INT             NULL ,
	[intWeightUOMId]    INT             NULL ,
	[intItemId]    INT             NULL,
	[intInventoryReceiptItemId]    INT             NULL,
	[intInventoryReceiptChargeId]    INT             NULL,
	[intPaycheckHeaderId]    INT             NULL,
	[intPurchaseDetailId]    INT             NULL,
	[intContractHeaderId]    INT             NULL,
	[intContractDetailId]    INT             NULL,
	[intShipmentContractQtyId]    INT             NULL,
	[intPrepayTypeId]    INT             NULL,
    [dblTotal]        DECIMAL (18, 6) NOT NULL DEFAULT 0,
    [intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [dblQtyContract] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblContractCost] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblQtyOrdered] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblQtyReceived] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblDiscount] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblCost] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblOldCost] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblLandedCost] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblRate] DECIMAL(18, 6) NOT NULL DEFAULT 0,  
	[dblTax] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblActual] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblDifference] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblPrepayPercentage] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblUnitQty] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblNetWeight] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblWeight] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblVolume] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dbl1099] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dtmExpectedDate] DATETIME NULL, 
    [int1099Form] INT NOT NULL DEFAULT 0 , 
    [int1099Category] INT NOT NULL DEFAULT 0 , 
	[ysn1099Printed] BIT NULL DEFAULT 0 ,
	[ysnRestricted] BIT NOT NULL DEFAULT 0 ,
	[ysnSubCurrency] BIT NOT NULL DEFAULT 0 ,
    [intLineNo] INT NOT NULL DEFAULT 1,
    [intTaxGroupId] INT NULL, 
    CONSTRAINT [PK__tblAPBil__DCE2CCF4681FF753] PRIMARY KEY CLUSTERED ([intBillDetailId] ASC) ON [PRIMARY],
    CONSTRAINT [FK_tblAPBillDetail_tblAPBill] FOREIGN KEY ([intBillId]) REFERENCES [dbo].[tblAPBill] ([intBillId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblAPBillDetail_tblGLAccount] FOREIGN KEY ([intAccountId]) REFERENCES [tblGLAccount]([intAccountId]),
	CONSTRAINT [FK_tblAPBillDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblAPBillDetail_tblICInventoryReceiptCharge] FOREIGN KEY ([intInventoryReceiptChargeId]) REFERENCES [tblICInventoryReceiptCharge]([intInventoryReceiptChargeId]),
	--TEMPORARILY REMOVED, WE'LL VERIFY THIS TO AJITH AS THIS MIGHT BECOME MANUAL DATA FIX FIRST BEFORE ENABLING AGAIN
	--CONSTRAINT [FK_tblAPBillDetail_tblICInventoryReceiptItem_intInventoryReceiptItemId] FOREIGN KEY ([intInventoryReceiptItemId]) REFERENCES [dbo].[tblICInventoryReceiptItem] ([intInventoryReceiptItemId]),
	CONSTRAINT [FK_tblAPBillDetail_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId]),
	CONSTRAINT [FK_tblAPBillDetail_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId]),
	CONSTRAINT [FK_tblAPBillDetail_tblLGShipmentContractQty_intShipmentContractQtyId] FOREIGN KEY ([intShipmentContractQtyId]) REFERENCES [dbo].[tblLGShipmentContractQty] ([intShipmentContractQtyId])
) ON [PRIMARY];


GO
