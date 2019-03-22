CREATE TABLE [dbo].[tblIPPreShipmentSampleError]
(
	[intStageSampleId] INT NOT NULL IDENTITY(1,1),
	[dtmSampleDate] DATETIME,
	[strPONo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strPOItemNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strItemNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dblQuantity] NUMERIC(38,20) NULL,
	[strUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strSampleNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strReferenceNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strLotNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strImportStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strErrorMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strSessionId] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[dtmTransactionDate] DATETIME NULL DEFAULT GETDATE(),
	CONSTRAINT [PK_tblIPPreShipmentSampleError_intStageSampleId] PRIMARY KEY ([intStageSampleId]) 
)
