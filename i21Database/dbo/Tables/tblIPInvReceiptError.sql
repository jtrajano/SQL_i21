﻿CREATE TABLE tblIPInvReceiptError
(
	intStageReceiptId			INT IDENTITY(1,1),
	strCompCode					NVARCHAR(20) COLLATE Latin1_General_CI_AS,
	strReceiptNumber			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmReceiptDate				DATETIME,
	strBLNumber					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strLocationName				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strCreatedBy				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmCreated					DATETIME,
	strTrackingNo				INT,

	strTransactionType			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strErrorMessage				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strImportStatus				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strSessionId				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmTransactionDate			DATETIME DEFAULT(GETDATE()),
	ysnMailSent					BIT DEFAULT 0,

	
	intTrxSequenceNo int,
	strERPTransferOrderNo  NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	intActionId int,
	strVendorAccountNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strVendorRefNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strERPReceiptNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strWarehouseRefNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strTransferOrderNo NVARCHAR(50) COLLATE Latin1_General_CI_AS,

	CONSTRAINT [PK_tblIPInvReceiptError_intStageReceiptId] PRIMARY KEY (intStageReceiptId)
)
