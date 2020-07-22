CREATE TABLE [dbo].[tblICInventoryReceiptCharge]
(
	[intInventoryReceiptChargeId] INT NOT NULL IDENTITY, 
    [intInventoryReceiptId] INT NOT NULL, 
	[intContractId] INT NULL,
	[intContractDetailId] INT NULL,
    [intChargeId] INT NOT NULL, 
    [ysnInventoryCost] BIT NULL DEFAULT ((0)), 
    [strCostMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('Per Unit'), 
    [dblRate] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intCostUOMId] INT NULL, 
	[ysnSubCurrency] BIT NULL DEFAULT ((0)),
	[intCurrencyId] INT NULL,
	[dblExchangeRate] NUMERIC(38, 20) DEFAULT((1)), 
	[intCent] INT NULL,
    [dblAmount] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [strAllocateCostBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT (''), 
	[ysnAccrue] BIT NULL DEFAULT ((0)),
	[intEntityVendorId] INT NULL, 
	[ysnPrice] BIT NULL DEFAULT ((0)),
	[dblAmountBilled] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblAmountPaid] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblAmountPriced] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intSort] INT NULL, 
	[dblTax] NUMERIC(18, 6) NULL DEFAULT ((0)),
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
	[intTaxGroupId] INT NULL,
	[intForexRateTypeId] INT NULL, 
	[dblForexRate] NUMERIC(18, 6) NULL,
	[dblQuantity] NUMERIC(18, 6) NULL DEFAULT ((1)), 
	[dblQuantityBilled] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblQuantityPriced] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[strChargesLink] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[intLoadShipmentId] INT NULL,
	[intLoadShipmentCostId] INT NULL,
	[dtmDateCreated] DATETIME NULL,
	[dtmDateModified] DATETIME NULL,
	[intCreatedByUserId] INT NULL,
	[intModifiedByUserId] INT NULL, 
	[ysnAllowVoucher] BIT NULL,
    CONSTRAINT [PK_tblICInventoryReceiptCharge] PRIMARY KEY ([intInventoryReceiptChargeId]), 
    CONSTRAINT [FK_tblICInventoryReceiptCharge_tblICInventoryReceipt] FOREIGN KEY ([intInventoryReceiptId]) REFERENCES [tblICInventoryReceipt]([intInventoryReceiptId]), --ON DELETE CASCADE, 
    CONSTRAINT [FK_tblICInventoryReceiptCharge_tblICItem] FOREIGN KEY ([intChargeId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblICInventoryReceiptCharge_tblAPVendor] FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblAPVendor]([intEntityId]), 
    CONSTRAINT [FK_tblICInventoryReceiptCharge_tblICItemUOM] FOREIGN KEY ([intCostUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
    CONSTRAINT [FK_tblICInventoryReceiptCharge_tblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]),
	--CONSTRAINT [FK_tblICInventoryReceiptCharge_tblSMTaxGroup] FOREIGN KEY ([intTaxGroupId]) REFERENCES [tblSMTaxGroup]([intTaxGroupId])
	CONSTRAINT [FK_tblICInventoryReceiptCharge_tblSMCurrencyExchangeRateType] FOREIGN KEY ([intForexRateTypeId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId]), 
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryReceiptCharge]
	ON [dbo].[tblICInventoryReceiptCharge]([intInventoryReceiptId] ASC)
	INCLUDE ([intChargeId]);

GO

CREATE TRIGGER trg_tblICInventoryReceiptCharge 
	ON [dbo].[tblICInventoryReceiptCharge]
	INSTEAD OF DELETE
AS 
BEGIN
	SET NOCOUNT ON;
	DELETE FROM tblICInventoryReceiptChargePerItem WHERE intInventoryReceiptChargeId IN (SELECT intInventoryReceiptChargeId FROM DELETED)
	DELETE FROM tblICInventoryReceiptCharge WHERE intInventoryReceiptChargeId IN (SELECT intInventoryReceiptChargeId FROM DELETED)
END

GO