﻿CREATE TABLE tblIPSampleError
(
	intStageSampleId			INT IDENTITY(1,1),
	strERPPONumber				NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strERPItemNumber			NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strSampleNumber				NVARCHAR(30) COLLATE Latin1_General_CI_AS,
	strSampleTypeName			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strItemNo					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strVendor					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dblQuantity					NUMERIC(18, 6),
	strQuantityUOM				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strSampleRefNo				NVARCHAR(30) COLLATE Latin1_General_CI_AS,
	strSampleNote				NVARCHAR(512) COLLATE Latin1_General_CI_AS,
	strSampleStatus				NVARCHAR(30) COLLATE Latin1_General_CI_AS,
	strRefNo					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strMarks					NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strSamplingMethod			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strSubLocationName			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strCourier					NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strCourierRef				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strComment					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strCreatedBy				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmCreated					DATETIME,

	strTransactionType			NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strErrorMessage				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS,
	strImportStatus				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	strSessionId				NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	dtmTransactionDate			DATETIME DEFAULT(GETDATE()),
	ysnMailSent					BIT DEFAULT 0,

	CONSTRAINT [PK_tblIPSampleError_intStageSampleId] PRIMARY KEY ([intStageSampleId])
)
