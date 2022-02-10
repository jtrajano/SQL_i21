CREATE TABLE [dbo].[tblGRChargeAndPremiumDetailRange]
(
	[intChargeAndPremiumDetailRangeId] INT NOT NULL IDENTITY,
	[intChargeAndPremiumDetailId] INT NOT NULL,
	[dblFrom] DECIMAL(18,6) NULL DEFAULT ((0)),
	[dblTo] DECIMAL(18,6) NULL DEFAULT ((0)),
	[dblRangeRate] DECIMAL(18,6) NULL DEFAULT ((0)),
	[intConcurrencyId] INT NULL DEFAULT ((1)),
	CONSTRAINT [PK_tblGRChargeAndPremiumDetailRange_intChargeAndPremiumDetailRangeId] PRIMARY KEY ([intChargeAndPremiumDetailRangeId]),
	CONSTRAINT [FK_tblGRChargeAndPremiumDetailRange_intChargeAndPremiumDetailId] FOREIGN KEY ([intChargeAndPremiumDetailId]) REFERENCES [tblGRChargeAndPremiumDetail]([intChargeAndPremiumDetailId]) ON DELETE CASCADE
)
GO

CREATE NONCLUSTERED INDEX [IX_tblGRChargeAndPremiumDetailRange_intChargeAndPremiumDetailId]
ON [dbo].[tblGRChargeAndPremiumDetailRange] ([intChargeAndPremiumDetailId])
GO