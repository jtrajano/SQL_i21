CREATE TABLE [dbo].[tblLGStandardAdjustment]
(
	[intStandardAdjustmentId] INT NOT NULL PRIMARY KEY,
	[intAdjustmentType] INT NULL,
	[intRecordId] INT NULL,
	[dblRate] NUMERIC(18, 6),
	[intCurrencyId] INT NULL,
	[intItemUOMId] INT NULL,
	[dtmValidFrom] DATETIME,
	[dtmValidTo] DATETIME,
	[intConcurrencyId] INT NOT NULL DEFAULT 1
)
