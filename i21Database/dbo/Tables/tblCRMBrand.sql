﻿CREATE TABLE [dbo].[tblCRMBrand]
(
	[intBrandId]			INT IDENTITY(1,1) NOT NULL,
	[strBrand]				NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
    [strFileType]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strIntegrationObject]	NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strLoginUrl]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strUserName]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strPassword]			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strSendType]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strFrequency]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strDayOfWeek]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[strEnvironmentType]	NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	[ysnHoldSchedule]		BIT				NOT NULL DEFAULT 1,
	[dtmStartTime]			DATETIME		NULL,
	[dtmApprovedDate]		DATETIME		NULL,
	[intVendorId]			INT				NULL,
	[intVendorContactId]	INT				NULL,
	[strNote]				NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NOT NULL DEFAULT 1,
	CONSTRAINT [PK_tblCRMBrand] PRIMARY KEY CLUSTERED ([intBrandId] ASC),
	CONSTRAINT [UQ_tblCRMBrand_strBrand] UNIQUE ([strBrand])
)