CREATE TABLE [dbo].[tblGRChargeAndPremiumDetail]
(
	[intChargeAndPremiumDetailId] INT NOT NULL IDENTITY,
	[intChargeAndPremiumId] INT NOT NULL,
	[intChargeAndPremiumItemId] INT NOT NULL,
	[intCalculationTypeId] INT NOT NULL,
	[intInventoryItemId] INT NULL,
	[intOtherChargeItemId] INT NULL,
	[intCtOtherChargeItemId] INT NULL,
	[dblRate] DECIMAL(18,6) NULL DEFAULT ((0)),
	[strRateType] NVARCHAR(30) NULL,
	[dtmEffectiveDate] DATETIME NULL,
	[dtmTerminationDate] DATETIME NULL,	
	[dtmDateCreated] DATETIME NULL DEFAULT(GETDATE()),
	[intConcurrencyId] INT NULL DEFAULT ((1)),
	[ysnDeductVendor] BIT DEFAULT ((0)),
	CONSTRAINT [PK_tblGRChargeAndPremiumDetail_intChargeAndPremiumDetailId] PRIMARY KEY ([intChargeAndPremiumDetailId]),
	CONSTRAINT [FK_tblGRChargeAndPremiumDetail_intChargeAndPremiumId] FOREIGN KEY ([intChargeAndPremiumId]) REFERENCES [tblGRChargeAndPremiumId]([intChargeAndPremiumId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblGRChargeAndPremiumDetail_intChargeAndPremiumItemId] FOREIGN KEY ([intChargeAndPremiumItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblGRChargeAndPremiumDetail_intCalculationTypeId] FOREIGN KEY ([intCalculationTypeId]) REFERENCES [tblGRCalculationType]([intCalculationTypeId]),
	CONSTRAINT [FK_tblGRChargeAndPremiumDetail_intInventoryItemId] FOREIGN KEY ([intInventoryItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblGRChargeAndPremiumDetail_intOtherChargeItemId] FOREIGN KEY ([intOtherChargeItemId]) REFERENCES [tblICItem]([intItemId]),
	CONSTRAINT [FK_tblGRChargeAndPremiumDetail_intCtOtherChargeItemId] FOREIGN KEY ([intCtOtherChargeItemId]) REFERENCES [tblICItem]([intItemId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblGRChargeAndPremiumDetail_intChargeAndPremiumId]
ON [dbo].[tblGRChargeAndPremiumDetail] ([intChargeAndPremiumId])
GO