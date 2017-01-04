﻿CREATE TABLE [dbo].[tblIPEntityError]
(
	[intStageEntityId] INT IDENTITY(1,1),
	strName NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strEntityType NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strAddress NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	strAddress1 NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	strCity NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	strState NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	strCountry NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	strZipCode NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	strPhone NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strAccountNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strTaxNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strFLOId NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strTerm NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
	strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dtmCreated DATETIME NULL DEFAULT((getdate())),
	strCreatedUserName NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strErrorMessage NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
	[strImportStatus] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,  
	dtmTransactionDate DATETIME NULL  DEFAULT((getdate())),
	CONSTRAINT [PK_tblIPEntityError_intStageEntityId] PRIMARY KEY ([intStageEntityId])
)
