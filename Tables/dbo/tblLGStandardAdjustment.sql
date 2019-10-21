CREATE TABLE [dbo].[tblLGStandardAdjustment]
(
	[intStandardAdjustmentId] INT NOT NULL IDENTITY PRIMARY KEY,
	[intAdjustmentType] INT NULL,
	[strMasterRecord] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL,
	[dblRate] NUMERIC(18, 6),
	[intCurrencyId] INT NULL,
	[intUnitMeasureId] INT NULL,
	[dtmValidFrom] DATETIME,
	[dtmValidTo] DATETIME,
	[intConcurrencyId] INT NOT NULL DEFAULT 1
)
