CREATE TABLE [dbo].[tblPOPurchaseDetail]
(
	[intPurchaseDetailId] INT IDENTITY (1, 1) NOT NULL PRIMARY KEY, 
    [intPurchaseId] INT NOT NULL, 
    [intItemId] INT NULL, 
    [intUnitOfMeasureId] INT NULL,
	[intCostUOMId]    INT             NULL ,
	[intWeightUOMId]    INT             NULL , 
    [intAccountId] INT NULL, 
	[intStorageLocationId] INT NULL,
	[intSubLocationId] INT NULL,
	[intLocationId] INT NULL,
	[intContractDetailId] INT NULL,
	[intContractHeaderId] INT NULL,
    [dblQtyOrdered] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[dblQtyContract] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblQtyReceived] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[dblWeightUnitQty] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblCostUnitQty] DECIMAL(18, 6) NOT NULL DEFAULT 0,
	[dblUnitQty] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
	[dblNetWeight] DECIMAL(18, 6) NOT NULL DEFAULT 0, 
    [dblVolume] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblWeight] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblDiscount] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [dblCost] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
	[dblTotal] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
	[dblTax] NUMERIC(18, 6) NOT NULL DEFAULT 0, 
    [strMiscDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL, 
	[strPONumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[dtmExpectedDate] DATETIME,
    [intLineNo] INT NOT NULL DEFAULT 1,
	[intConcurrencyId] INT NOT NULL DEFAULT 0, 
    [intTaxGroupId] INT NULL, 
	[intCurrencyId] INT NULL,
	[intForexRateTypeId] INT NULL, 	
	[dblForexRate] DECIMAL(18, 6) NOT NULL DEFAULT 0,  
	[ysnSubCurrency] BIT NOT NULL DEFAULT 0,
    CONSTRAINT [FK_tblPOPurchaseDetail_tblPOPurchase] FOREIGN KEY ([intPurchaseId]) REFERENCES [dbo].[tblPOPurchase] ([intPurchaseId]) ON DELETE CASCADE,
	CONSTRAINT [FK_dbo.tblPOPurchaseDetail_dbo.tblGLAccount_intAccountId] FOREIGN KEY (intAccountId) REFERENCES tblGLAccount(intAccountId),
	CONSTRAINT [FK_tblPOPurchaseDetail_tblICItemUOM_intUnitOfMeasureId] FOREIGN KEY ([intUnitOfMeasureId]) REFERENCES [dbo].[tblICItemUOM] ([intItemUOMId]),
	CONSTRAINT [FK_tblPOPurchaseDetail_tblCTContractHeader_intContractHeaderId] FOREIGN KEY ([intContractHeaderId]) REFERENCES [dbo].[tblCTContractHeader] ([intContractHeaderId]),
	CONSTRAINT [FK_tblPOPurchaseDetail_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [dbo].[tblCTContractDetail] ([intContractDetailId]),
	CONSTRAINT [FK_tblPOPurchaseDetail_tblSMCompanySubLocation_intSubLocationId] FOREIGN KEY ([intSubLocationId]) REFERENCES [dbo].[tblSMCompanyLocationSubLocation] ([intCompanyLocationSubLocationId]),
	CONSTRAINT [FK_tblPOPurchaseDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)

GO

CREATE TRIGGER [dbo].[VoucherPayable_tblPOPurchaseDetail]
    ON [dbo].[tblPOPurchaseDetail]
    AFTER DELETE
    AS
    BEGIN
		--THIS TRIGGER WILL MAINTAIN THE tblAPVoucherPayable References
        SET NoCount ON
		DECLARE @poId INT;
		SELECT TOP 1 @poId = intPurchaseId FROM deleted
		EXEC uspAPVoucherPayablePO @poId, 0
    END
