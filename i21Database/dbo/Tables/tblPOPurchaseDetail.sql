﻿CREATE TABLE [dbo].[tblPOPurchaseDetail]
(
	[intPurchaseDetailId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY, 
    [intPurchaseId] INT NOT NULL, 
    [intItemId] INT NULL, 
    [intUnitOfMeasureId] INT NOT NULL, 
    [intAccountId] INT NULL, 
	[intStorageLocationId] INT NULL,
	[intSubLocationId] INT NULL,
	[intLocationId] INT NOT NULL,
	[intContractDetailId] INT NULL,
	[intPurchaseDetailTaxId] INT NULL,
	[intContractHeaderId] INT NULL,
    [dblQtyOrdered] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[dblQtyContract] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblQtyReceived] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblVolume] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblWeight] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblDiscount] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblCost] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[dblTotal] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[dblTax] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [strMiscDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
	[strPONumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dtmExpectedDate] DATETIME,
    [intLineNo] INT NOT NULL DEFAULT 1,
	[intConcurrencyId] INT NOT NULL DEFAULT 0, 
    CONSTRAINT [FK_tblPOPurchaseDetail_tblPOPurchase] FOREIGN KEY ([intPurchaseId]) REFERENCES [dbo].[tblPOPurchase] ([intPurchaseId]) ON DELETE CASCADE,
	CONSTRAINT [FK_dbo.tblPOPurchaseDetail_dbo.tblGLAccount_intAccountId] FOREIGN KEY (intAccountId) REFERENCES tblGLAccount(intAccountId),
	CONSTRAINT [FK_tblPOPurchaseDetail_tblICItemUOM_intUnitOfMeasureId] FOREIGN KEY ([intUnitOfMeasureId]) REFERENCES [dbo].[tblICItemUOM] ([intItemUOMId]),
	CONSTRAINT [FK_tblPOPurchaseDetail_tblPOPurchaseDetailTax] FOREIGN KEY ([intPurchaseDetailTaxId]) REFERENCES [tblPOPurchaseDetailTax]([intPurchaseDetailTaxId]),
	CONSTRAINT [FK_tblPOPurchaseDetail_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId]),
	CONSTRAINT [FK_tblPOPurchaseDetail_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId]),
	CONSTRAINT [FK_tblPOPurchaseDetail_tblSMCompanySubLocation_intSubLocationId] FOREIGN KEY ([intSubLocationId]) REFERENCES [dbo].[tblSMCompanyLocationSubLocation] ([intCompanyLocationSubLocationId]),
	CONSTRAINT [FK_tblPOPurchaseDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)
