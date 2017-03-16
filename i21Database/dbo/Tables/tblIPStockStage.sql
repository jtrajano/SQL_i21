CREATE TABLE [dbo].[tblIPStockStage]
(
	[intStageStockId] INT IDENTITY(1,1),
	[strItemNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strSubLocation] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strStockType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[dblInspectionQuantity] NUMERIC(38,20),
	[dblBlockedQuantity] NUMERIC(38,20),
	[dblUnrestrictedQuantity] NUMERIC(38,20),
	[dblQuantity] NUMERIC(38,20),
	[strImportStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strErrorMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strSessionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmTransactionDate] DATETIME NULL DEFAULT GETDATE(),
	CONSTRAINT [PK_tblIPStockStage_intStageStockId] PRIMARY KEY ([intStageStockId]) 
)
