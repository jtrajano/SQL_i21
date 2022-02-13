CREATE TABLE [dbo].[tblGRAppliedChargeAndPremium] (
    [intAppliedChargeAndPremiumId] INT NOT NULL IDENTITY,
    [intConcurrencyId] INT NULL DEFAULT ((1)),
    [intTransactionId] INT NOT NULL,
    [intTransactionDetailId] INT NULL,
    [strTransactionType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    [intChargeAndPremiumId] INT NOT NULL,
    [strChargeAndPremiumId] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    [intChargeAndPremiumDetailId] INT NOT NULL,
	[intChargeAndPremiumItemId] INT NOT NULL,
    [intCalculationTypeId] INT NOT NULL,
    [dblRate] DECIMAL(18,6) NOT NULL,
    [strRateType] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
	[dblQty] NUMERIC(38, 20) NOT NULL,
    [intChargeAndPremiumItemUOMId] INT NOT NULL,
	[dblCost] NUMERIC(38, 20) NULL,
    [intOtherChargeItemId] INT NULL,
    [intInventoryItemId] INT NULL,
    [dblInventoryItemNetUnits] NUMERIC(38, 20) NULL,
    [dblInventoryItemGrossUnits] NUMERIC(38, 20) NULL,
    CONSTRAINT [PK_tblGRAppliedChargeAndPremium_intAppliedChargeAndPremiumId] PRIMARY KEY ([intAppliedChargeAndPremiumId]),
    CONSTRAINT [FK_tblGRAppliedChargeAndPremium_tblGRCalculationType_intCalculationTypeId] FOREIGN KEY ([intCalculationTypeId]) REFERENCES [tblGRCalculationType]([intCalculationTypeId]),
    CONSTRAINT [FK_tblGRAppliedChargeAndPremium_tblICItem_intOtherChargeItemId] FOREIGN KEY ([intOtherChargeItemId]) REFERENCES [tblICItem]([intItemId]),
    CONSTRAINT [FK_tblGRAppliedChargeAndPremium_tblICItem_intInventoryItemId] FOREIGN KEY ([intInventoryItemId]) REFERENCES [tblICItem]([intItemId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblGRAppliedChargeAndPremium_intTransactionId]
ON [dbo].[tblGRAppliedChargeAndPremium] ([intTransactionId])
GO

CREATE NONCLUSTERED INDEX [IX_tblGRAppliedChargeAndPremium_intTransactionDetailId]
ON [dbo].[tblGRAppliedChargeAndPremium] ([intTransactionDetailId])
GO