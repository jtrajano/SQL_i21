CREATE TABLE [dbo].[tblICInventoryShipmentCharge]
(
	[intInventoryShipmentChargeId] INT NOT NULL IDENTITY, 
    [intInventoryShipmentId] INT NOT NULL, 
    [intContractId] INT NULL,
	[intContractDetailId] INT NULL,
    [intChargeId] INT NOT NULL, 
    [strCostMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT ('Per Unit'), 
    [dblRate] NUMERIC(18, 6) NULL DEFAULT ((0)), 
    [intCostUOMId] INT NULL, 
	[intCurrencyId] INT NULL,
    [dblAmount] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[strAllocatePriceBy] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT (''), 
	[ysnAccrue] BIT NULL DEFAULT ((0)),
	[intEntityVendorId] INT NULL, 
	[ysnPrice] BIT NULL DEFAULT ((0)),
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
	[ysnSubCurrency] BIT NULL DEFAULT ((0)),
	[intCent] INT NULL,
	[dblAmountBilled] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblAmountPaid] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblAmountPriced] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[intForexRateTypeId] INT NULL, 
	[dblForexRate] NUMERIC(18, 6) NULL,
	[dblQuantity] NUMERIC(18, 6) NULL DEFAULT ((1)), 
	[dblQuantityBilled] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[dblQuantityPriced] NUMERIC(18, 6) NULL DEFAULT ((0)), 
	[intTaxGroupId] INT NULL,
	[dblTax] NUMERIC(18, 6) NULL DEFAULT ((0)),
	[dblAdjustedTax] NUMERIC(18, 6) NULL DEFAULT ((0)),		
	[strChargesLink] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[dtmDateCreated] DATETIME NULL,
	[dtmDateModified] DATETIME NULL,
	[intCreatedByUserId] INT NULL,
	[intModifiedByUserId] INT NULL,
    CONSTRAINT [PK_tblICInventoryShipmentCharge] PRIMARY KEY ([intInventoryShipmentChargeId]), 
    CONSTRAINT [FK_tblICInventoryShipmentCharge_tblICItem] FOREIGN KEY ([intChargeId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [FK_tblICInventoryShipmentCharge_tblICItemLocation] FOREIGN KEY ([intCostUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]), 
    CONSTRAINT [FK_tblICInventoryShipmentCharge_tblAPVendor] FOREIGN KEY ([intEntityVendorId]) REFERENCES [tblAPVendor]([intEntityId]), 
    CONSTRAINT [FK_tblICInventoryShipmentCharge_tblSMCurrency] FOREIGN KEY ([intCurrencyId]) REFERENCES [tblSMCurrency]([intCurrencyID]), 
    CONSTRAINT [FK_tblICInventoryShipmentCharge_tblICInventoryShipment] FOREIGN KEY ([intInventoryShipmentId]) REFERENCES [tblICInventoryShipment]([intInventoryShipmentId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblICInventoryShipmentCharge_tblSMCurrencyExchangeRateType] FOREIGN KEY ([intForexRateTypeId]) REFERENCES [tblSMCurrencyExchangeRateType]([intCurrencyExchangeRateTypeId])
)
GO 

CREATE NONCLUSTERED INDEX [IX_tblICInventoryShipmentCharge]
	ON [dbo].[tblICInventoryShipmentCharge]([intInventoryShipmentId] ASC)
	INCLUDE ([intChargeId]);

GO