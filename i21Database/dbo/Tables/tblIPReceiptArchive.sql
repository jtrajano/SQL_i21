﻿CREATE TABLE [dbo].[tblIPReceiptArchive]
(
	intStageReceiptId INT IDENTITY(1,1),
	strDeliveryNo	NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL ,
	dtmReceiptDate	DATETIME ,
	[strImportStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[strErrorMessage] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	dtmTransactionDate DATETIME NULL  DEFAULT((getdate())),
	CONSTRAINT [PK_tblIPReceiptArchive_intStageReceiptId] PRIMARY KEY ([intStageReceiptId]) 
)
