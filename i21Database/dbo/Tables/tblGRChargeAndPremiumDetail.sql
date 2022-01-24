CREATE TABLE [dbo].[tblGRChargeAndPremiumDetail]
(
	[intChargeAndPremiumDetailId] INT NOT NULL IDENTITY,
	[intChargeAndPremiumId] INT NOT NULL,
	[intChargeAndPremiumItemId] INT NOT NULL,
	[intCalculationTypeId] INT NOT NULL,
	[intInventoryItemId] INT NULL,
	[intOtherChargeItemId] INT NULL,
	[dblRate] DECIMAL(38,20) NULL DEFAULT ((0)),
	[dtmDateCreated] DATETIME NULL DEFAULT(GETDATE()),
	[intConcurrencyId] INT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblGRChargeAndPremiumDetail_intChargeAndPremiumDetailId] PRIMARY KEY ([intChargeAndPremiumDetailId]),
	CONSTRAINT [FK_tblGRChargeAndPremiumDetail_intChargeAndPremiumId] FOREIGN KEY ([intChargeAndPremiumId]) REFERENCES [tblGRChargeAndPremiumId]([intChargeAndPremiumId]),
	CONSTRAINT [FK_tblGRChargeAndPremiumDetail_intChargeAndPremiumItemId] FOREIGN KEY ([intChargeAndPremiumItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblGRChargeAndPremiumDetail_intCalculationTypeId] FOREIGN KEY ([intCalculationTypeId]) REFERENCES [tblGRCalculationType]([intCalculationTypeId]),
	CONSTRAINT [FK_tblGRChargeAndPremiumDetail_intInventoryItemId] FOREIGN KEY ([intInventoryItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblGRChargeAndPremiumDetail_intOtherChargeItemId] FOREIGN KEY ([intOtherChargeItemId]) REFERENCES [tblICItem]([intItemId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblGRChargeAndPremiumDetail_intChargeAndPremiumId]
ON [dbo].[tblGRChargeAndPremiumDetail] ([intChargeAndPremiumId])
GO